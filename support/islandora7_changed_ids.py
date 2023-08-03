#!/user/bin/env python3
##############################################################################################
# desc: Connect to the CWRC Islandora 7 site and return a list of ID changed
# usage:
#       python3 islandora7_changed_ids.py --server ${server_url} --date "2022-08-01T00:00:00.000Z" 
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
    parser.add_argument('--server', required=True, help='Base server name of the Islandora Legacy (Drupal 7) site.')
    parser.add_argument('--date', required=False, help='Filter after date.')
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
def lookup_object_date(session, args):
    response = session.get(
        urljoin(args.server, 'services/bagit_extension/audit_by_date/' + args.date)
    )
    response.raise_for_status()
    # print(response.request.url)
    # print(response.content)

    return response.json()



# Main
def main():
    args = parse_args()
    session = init_session(args)

    results = lookup_object_date(session, args)
    for item in results['objects']:
        print(f"{item['pid']}")
    


if __name__ == "__main__":
    main()
