#!/user/bin/env python3

import argparse
import logging
import json
import mimetypes
import os
import requests
import xml.etree.cElementTree as etree
from getpass import getpass
from progress_bar import InitBar

# List of datastream ids to exclude from the export
exclude_datastream_list = [
    'COLLECTION_POLICY',
    #'OBJ',
    #'PROXY_MP3'
]

# List of XML datastreams to merge into a metadata document for transformation in another script
include_metadata_datastreams = [
    'MODS',
    'MODs',  # some object mistakenly use this datastream id
    'RELS-EXT',
    'WORKFLOW'
]


# Map mimeType from Islandora 7 to a file extention
# Todo: refactor as the guess_extension is failing for an number of cases
def mimeType_ext_mapper(mimeType):
    if (mimeType == 'application/xml'):
        return '.xml'
    elif (mimeType == 'text/xml'):
        return '.xml'
    elif (mimeType == 'application/rdf+xml'):
        return '.xml'
    elif (mimeType == 'video/x-matroska'):
        return '.mkv'
    elif (mimeType == 'audio/mpeg'):
        return '.mp3'
    elif (mimeType == 'image/jpeg'):
        return '.jpeg'
    elif (mimeType == 'image/jp2'):
        return '.jp2'
    else:
        return mimetypes.guess_extension(mimeType, strict=True)


#
def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--id_list', required=True, help='List of Islandora PIDs, one per line.')
    parser.add_argument('--server', required=True, help='Base server name of the Islandora Legacy (Drupal 7) site.')
    parser.add_argument('--export_dir', required=True, help='Export destination directory.')
    return parser.parse_args()


#
def init_session(args):
    # get username / password for Islandora 7 site
    username = input('Username:')
    password = getpass('Password:')

    # initial session with Islandora 7 site
    session = requests.Session()
    session.auth = (username, password)

    response = session.post(
        args.server + 'rest/user/login',
        json={'username': username, 'password': password},
        headers={'Content-Type': 'application/json'}
    )
    response.raise_for_status()
    # print (response.cookies)
    return session


#
def lookup_object_description(pid, session, args):
    response = session.get(
        args.server + 'islandora/rest/v1/object/' + pid
    )
    response.raise_for_status()
    print(response.request.url)

    return response.json()


#
def lookup_object_datastream(ds_id, pid, session, args):
    # get datastream content
    response = session.get(
        args.server + 'islandora/rest/v1/object/' + pid.strip() + '/datastream/' + ds_id + '/?content=true'
    )
    response.raise_for_status()

    return response


#
def write_datastream(filename, pid, args, ds_id, ds_content, export_media):
    # output to file
    path = os.path.join(args.export_dir, 'media', pid)
    if not os.path.exists(path):
        os.makedirs(path)
    # Todo: don't use mime type guessing as doesn't work well with xml
    filepath = os.path.join(path, filename)
    #print(filepath)
    with open(filepath, 'wb') as file:
        file.write(ds_content)

    return filepath


#
def metadata_combined_init(pid, object_metadata):
    # add namespaces
    etree.register_namespace('mods', 'http://www.loc.gov/mods/v3')
    etree.register_namespace('islandora', 'http://islandora.ca/ontology/relsext#')
    etree.register_namespace('fedora', 'info:fedora/fedora-system:def/relations-external#')
    etree.register_namespace('fedora-model', 'info:fedora/fedora-system:def/model#')

    # add root element
    export_root = etree.Element(
        'metadata',
        {
            'pid': pid,
            'label': object_metadata['label'],
            'owner': object_metadata['owner'],
            'models': object_metadata['models'],
            'created': object_metadata['created'],
            'modified': object_metadata['modified']
        },
    )
    export_media = etree.SubElement(export_root, 'media_exports')
    export_metadata = etree.SubElement(export_root, 'resource_metadata')

    return (export_root, export_media, export_metadata)


#
def metadata_record_filepath(export_media, filepath, ds_id):
    # record datastream export location
    etree.SubElement(export_media, 'media', {'filepath': filepath, 'ds_id': ds_id})


#
def metadata_combined_add_datastream(export_metadata, ds_id, ds_content):
    if ds_id in include_metadata_datastreams:
        # add to metadata element set of approved metadata containing datastreams
        export_metadata.append(etree.fromstring(ds_content))


#
def write_metadata(export_dir, export_root, pid):
    # output metadata xml
    path = os.path.join(export_dir, 'combined_metadata')
    if not os.path.exists(path):
        os.makedirs(path)
    filepath = os.path.join(path, pid + '__metadata.xml')
    with open(filepath, 'wb') as file:
        etree.ElementTree(export_root).write(file, encoding='utf-8', xml_declaration=True, method="xml")


# XML metadata superset
def process_object(pid, session, args, object_metadata):

    (export_root, export_media, export_metadata) = metadata_combined_init(pid, object_metadata)

    for datastream in object_metadata['datastreams']:

        if datastream['dsid'] not in exclude_datastream_list:
            response = lookup_object_datastream(datastream['dsid'], pid, session, args)
            file_ext = mimeType_ext_mapper(datastream['mimeType'])
            if (file_ext is None):
                print(datastream)
                print('[ERROR] missing extension [' + pid + '] ' + datastream['dsid'])
            filename = pid + '__' + datastream['dsid'] + file_ext
            print("  [" + pid + "] adding dsid [" + datastream['dsid'] + "] " + datastream['mimeType'] + " " + filename)
            filepath = write_datastream(filename, pid, args, datastream['dsid'], response.content, export_media)
            metadata_record_filepath(export_media, filepath, datastream['dsid'])
            metadata_combined_add_datastream(export_metadata, datastream['dsid'], response.content)

    write_metadata(args.export_dir, export_root, pid)


# Main
def main():
    args = parse_args()
    session = init_session(args)

    # open file list
    ids_fd = open(args.id_list)

    id_count = 0
    for pid in ids_fd:
        id_count += 1
        pid = pid.strip()
        # print(id)

        object_metadata = lookup_object_description(pid, session, args)
        process_object(pid, session, args, object_metadata)


if __name__ == "__main__":
    main()
