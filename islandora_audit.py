#!/user/bin/env python3
# -*- coding: utf-8 -*-

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
exclude_datastream_list = ['COLLECTION_POLICY'] 

#
def parse_args ():
    parser = argparse.ArgumentParser()
    parser.add_argument('--id_list', required=True, help='List of Islandora Legacy (Drupal 7) PIDs, one per line.')
    parser.add_argument('--islandora_legacy', required=True, help='Base server name of the Islandora Legacy (Drupal 7) site.')
    parser.add_argument('--islandora', required=True, help='Base server name of the Islandora Legacy (Drupal 7) site.')
    parser.add_argument('--comparison_config', required=True, help='JSON file defining how to compare the content from Old to New.')
    return parser.parse_args()


# Islandora Legacy (Drupal 7) session
def init_session_legacy (args):
    # get username / password for Islandora 7 site
    username = input('Username:')
    password = getpass('Password:')

    # initial session with Islandora 7 site
    session = requests.Session()
    session.auth = (username, password)

    response = session.post(
        args.islandora_legacy + 'rest/user/login',
        json={'username': username, 'password': password},
        headers={'Content-Type': 'application/json'}
        )
    response.raise_for_status()
    #print (response.cookies)
    return session

# Islandora session
def init_session_islandora(args):
    # initial session with Islandora 7 site
    session = requests.Session()
    return session


# Lookup the MODS datastream on an Islandora Legacy (Drupal 7) server
def lookup_legacy_mods(pid, session, args):
    # get datastream content
    ds_id = 'MODS'
    response = session.get(
        args.islandora_legacy + 'islandora/rest/v1/object/' + pid.strip() + '/datastream/' + ds_id + '/?content=true'
    )
    response.raise_for_status()

    return response

# Lookup the JSON-LD on an Islandora (Drupal 8+) server
def lookup_jsonld(pid, session, args):
    # get datastream content
    response = session.get(
        args.islandora + '/islandora/' + pid + '?_format=jsonld'
    )
    response.raise_for_status()

    return response

# Audit comparing the old (Islandora Legacy Drupal 7) to new Islandora (Drupal 8+)
# ToDo: optimize - exit for loops quicker once found
def audit(old, new, comparison):
    ns = {'mods': 'http://www.loc.gov/mods/v3'}
    old_xml = etree.fromstring(old)
    for key, value in comparison['comparison'].items():
        text_match = False
        print(f"testing: [{key}] with paths -- old: [{value['old']}] and new: [{value['new']}]")

        for old_path in old_xml.findall(f"./{value['old']}", ns):
            for i in new['@graph']: 
                new_str = False 
                for val in i.get(value['new'],[]):
                    if '@value' in val:
                        new_str = val['@value']
                    elif '@id' in val:
                        new_str = val['@id']
                    print(f"matching: old:[{old_path.text}] - new [{new_str}]")
                    if old_path.text == new_str:
                        text_match = True
                        continue
                if (new_str):
                    continue
            if text_match:
                print(f"testing: [{key}] with paths -- old: [{value['old']}] and new: [{value['new']}] - [{old_path.text}] - MATCH")
            else:
                print(f"testing: [{key}] with paths -- old: [{value['old']}] and new: [{value['new']}] - FAIL")




# Main
def main():
    args = parse_args()
    session_legacy = init_session_legacy(args)
    session_islandora = init_session_islandora(args)

    # open comparision file 
    with open(args.comparison_config) as file:
        comparison_json = json.loads(file.read())

    # open file list of ids
    ids_fd = open(args.id_list)

    id_count = 0
    for pid in ids_fd:
        id_count += 1
        pid = pid.strip()
        print(pid)

        legacy_response = lookup_legacy_mods(pid, session_legacy, args)
        # ToDo: how do the IDs map from Legacy to new?
        pid = 'kingsgate-bc-delete'
        islandora_response = lookup_jsonld(pid, session_islandora, args)
        islandora_jsonld = json.loads(islandora_response.text)

        audit(legacy_response.text, islandora_jsonld, comparison_json)
        #audit("<a><b>1</b><b>2</b></a>", islandora_jsonld, comparison_json)


if __name__ == "__main__":
    main()

