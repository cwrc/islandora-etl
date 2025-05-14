#!/user/bin/env python3
##############################################################################################
# desc: Given a list of PIDs, find the associated export from "islandora7_export.py"
#       and move the directory/files into the destination directory.
#       The usecase: remove deleted PIDs from past "islandora7_export.py"
#       or undiserable PIDs (e.g., workshop material) from the content to ingest into Repository v2
#       Nov 2024 version uses CSV output from list_select_items.xquery or list_all_cwrc_entities.xquery, or any csv in the form of "pid,,,media_list_json"
# 
# usage:
#       python3 islandora7_move_to_directory.py --id_list ${id_list_one_per_line} --source_dir ${SRC} --destination_dir ${DST}
# license: CC0 1.0 Universal (CC0 1.0) Public Domain Dedication
# date: October 3, 2024
##############################################################################################


import argparse
import csv
import glob
import json
import logging
import hashlib
import shutil
import os


#
def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--id_list', required=True, help='List of Islandora PIDs, one per line.')
    parser.add_argument('--source_dir', required=True, help='Source directory root.')
    parser.add_argument('--destination_dir', required=True, help='Destination directory to move object into.')
    parser.add_argument('--modify', action='store_true', help='Default is a dry run without modification.')
    parser.add_argument('--checksum', action='store_true', help='Calculate checksum.')
    return parser.parse_args()


# Deprecated
def handle_media(pid, dir_set, dst_dir, modify):
    if pid in dir_set:
        dst_dir = os.path.join(dst_dir, "media")
        if modify is True:
            #shutil.move(dir_set[pid], dst_dir)
            # untested
            shutil.copytree(dir_set[pid], dst_dir, dirs_exist_ok=True)
        else:
            print(f"Move media {dir_set[pid]} to {dst_dir}")
    else:
        print(f"[WARNING] Media - PID [{pid}] not found")


#
def copy_attached_media(pid, media_list_json, dest_dir, modify=False, checksum=True):
    for media_path in json.loads(media_list_json):
        dest_filename = os.path.basename(media_path)
        dest_root = os.path.join(dest_dir, pid)
        dest_path = os.path.join(dest_root, dest_filename)
        if not os.path.exists(dest_root):
            os.makedirs(dest_root)
        if modify is True:
            #print(f"Metadata [{pid}] {media_path} to {dest_path}")
            shutil.copy(media_path, dest_path)
        elif (checksum):
            if calculate_checksum(media_path) != calculate_checksum(dest_path):
                print(f"[WARNING] PID [{pid}] checksum mismatch")
            else:
                print(f"PID [{pid}] checksum match")
        else:
            print(f"Metadata [{pid}] {media_path} to {dest_path}")


#
def handle_combined_metadata(pid, dir_set, dest_dir, modify=False, checksum=True):
    if pid in dir_set:
        dest_filename = os.path.basename(dir_set[pid])
        dest_path = os.path.join(dest_dir, dest_filename)
        if modify is True:
            #print(f"Metadata {dir_set[pid]} to {dest_path}")
            #shutil.move(dir_set[pid], dst_path)
            # untested
            shutil.copy(dir_set[pid], dest_path)
        elif (checksum):
            if calculate_checksum(dir_set[pid]) != calculate_checksum(dest_path):
                print(f"[WARNING] PID [{pid}] checksum mismatch")
            else:
                print(f"PID [{pid}] checksum match")
        else:
            print(f"Move metadata {dir_set[pid]} to {dest_dir}")

    else:
        print(f"[WARNING] Metadata - PID [{pid}] not found")


def calculate_checksum(file_path, hash_algorithm='sha256'):
    hash_func = getattr(hashlib, hash_algorithm)()
    try:
        with open(file_path, 'rb') as file:
            while chunk := file.read(8192):
                hash_func.update(chunk)
        return hash_func.hexdigest()
    except FileNotFoundError:
        print(f"File not found: {file_path}")
        return None


# Deprecated
def build_index_media(args):
    print(f"Building index of media directories")
    media_dir_set = {}
    glob_pattern = os.path.join(args.source_dir, '**', 'media', '*')
    for item in glob.glob(glob_pattern, recursive=True):
        if os.path.isdir(item):
            #dir_set.add(item_path)
            key = os.path.basename(item)
            media_dir_set[key] = item
    return media_dir_set

#
def build_index_metadata(args):
    print(f"Building index of combined metadata files")
    metadata_dir_set = {}
    # glob_pattern = os.path.join(args.source_dir, '**', 'combined_metadata', '*')
    glob_pattern = os.path.join(args.source_dir, '*')
    for item in glob.glob(glob_pattern, recursive=True):
        if os.path.isfile(item):
            #dir_set.add(item_path)
            key = os.path.basename(item)
            key = key.split("__metadata.xml")[0]
            metadata_dir_set[key] = item
    return metadata_dir_set


# Main
def main():
    args = parse_args()

    print(f"Modify: {args.modify}")

    # disable media & test using metadata directories
    # media_dir_set = build_index_media(args)
    metadata_dir_set = build_index_metadata(args)

    # open file list
    print(f"Processing ID list")
    with open(args.id_list, 'r') as csv_fd:

        csv_reader = csv.DictReader(csv_fd)

        # copy metadata
        metadata_dest_dir = os.path.join(args.destination_dir, "combined_metadata")
        if not os.path.exists(metadata_dest_dir):
            os.makedirs(metadata_dest_dir)

        # copy media
        media_dest_dir = os.path.join(args.destination_dir, "media")
        if not os.path.exists(media_dest_dir):
            os.makedirs(media_dest_dir)

        for row in csv_reader:
            pid = row['pid']
            logging.info(f"id: {id}")
            # handle_media(pid, media_dir_set, args.destination_dir, args.modify)
            handle_combined_metadata(pid, metadata_dir_set, metadata_dest_dir, args.modify, args.checksum)
            copy_attached_media(pid, row['media_list_json'], media_dest_dir, args.modify, args.checksum)


if __name__ == "__main__":
    main()
