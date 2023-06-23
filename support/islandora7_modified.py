#!/user/bin/env python3
##############################################################################################
# desc: Connect to the CWRC Islandora 7 site and for each PID in the list, report the versions
#       report for the specified datastream the version metadata, if applicable.
#       exploritory / proof-of-concept code
# usage:
#       python3 islandora7_modified.py --id_list ${id_list_on_per_line} --server ${server_url} --dsid PERSON
# license: CC0 1.0 Universal (CC0 1.0) Public Domain Dedication
# date: June 22, 2023
##############################################################################################


import argparse
import logging
import json
import mimetypes
import os
import requests
import xml.etree.cElementTree as etree
from getpass import getpass
from urllib.parse import urljoin


#
def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--id_list', required=True, help='List of Islandora PIDs, one per line.')
    parser.add_argument('--dsid', required=True, help='Datastream ID to investigate.')
    parser.add_argument('--server', required=True, help='Base server name of the Islandora Legacy (Drupal 7) site.')
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
        urljoin(args.server, 'rest/user/login'),
        json={'username': username, 'password': password},
        headers={'Content-Type': 'application/json'}
    )
    response.raise_for_status()
    # print (response.cookies)
    return session


#
def lookup_object_description(pid, session, args):
    response = session.get(
        urljoin(args.server, 'islandora/rest/v1/object/' + pid)
    )
    response.raise_for_status()
    # print(response.request.url)
    # print(response.content)

    return response.json()


# XML metadata superset
def process_object(pid, session, args, object_metadata):

    dsid = args.dsid
    print(object_metadata)

    for datastream in object_metadata['datastreams']:
        if datastream['dsid'] == dsid:
            print(f"PID: [{pid}] current: [{datastream['created']}] versions: [{datastream['versions']}]")


# Main
def main():
    args = parse_args()
    session = init_session(args)

    # open file list
    ids_fd = open(args.id_list)

    for pid in ids_fd:
        pid = pid.strip()

        object_metadata = lookup_object_description(pid, session, args)
        logging.info(f"{object_metadata}")
        process_object(pid, session, args, object_metadata)


if __name__ == "__main__":
    main()
