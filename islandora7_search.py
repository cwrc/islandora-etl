#!/user/bin/env python3
#####
# Query a Solr collection and return all direct members (not decendants).
# Input a file of PIDs.
# Output: one or more file of PIDs with a name containin the input PID as the suffix
#
# python3 islandora7_search.py --input_file /tmp/z --server https://example.ca --output_file /tmp/zz
#
#######

import argparse
import logging
import json
import mimetypes
import os
import requests
import xml.etree.cElementTree as etree
from getpass import getpass
from functools import reduce
from urllib.parse import urljoin

#
def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--input_file', required=True, help='List of Islandora PIDs, one per line.')
    parser.add_argument('--server', required=True, help='Base server name of the Islandora Legacy (Drupal 7) site.')
    parser.add_argument('--output_file', required=True, help='File to write output of search.')
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
def find_set_members_search(item, session, args):

    query_params = "RELS_EXT_isMemberOfCollection_uri_mt:\""+item+"\"?fl=PID,RELS_EXT_hasModel_uri_s&rows=999999&start=0&wt=json&sort=PID+asc"

    response = session.get(
        reduce(urljoin, [args.server, 'islandora/rest/v1/solr/',  query_params])
    )
    response.raise_for_status()
    print(response.request.url)

    return response.json()


# Main
def main():
    args = parse_args()
    session = init_session(args)

    # open file list
    input_list = open(args.input_file)

    for item in input_list:
        item = item.strip()

        output_file = args.output_file + "_" + item
        with open(output_file, 'w') as file:
            member_list = find_set_members_search(item, session, args)
            for obj in member_list['response']['docs']:
                file.write(f"{obj['PID']}\n")

if __name__ == "__main__":
    main()
