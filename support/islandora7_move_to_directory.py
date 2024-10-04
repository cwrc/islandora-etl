#!/user/bin/env python3
##############################################################################################
# desc: Given a list of PIDs, find the associated export from "islandora7_export.py"
#       and move the directory/files into the destination directory.
#       The usecase: remove deleted PIDs from past "islandora7_export.py"
#       or undiserable PIDs (e.g., workshop material) from the content to ingest into Repository v2
# usage:
#       python3 islandora7_move_to_directory.py --id_list ${id_list_one_per_line} --source_dir ${SRC} --destination_dir ${DST}
# license: CC0 1.0 Universal (CC0 1.0) Public Domain Dedication
# date: October 3, 2024
##############################################################################################


import argparse
import glob
import logging
import shutil
import os


#
def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--id_list', required=True, help='List of Islandora PIDs, one per line.')
    parser.add_argument('--source_dir', required=True, help='Source directory root.')
    parser.add_argument('--destination_dir', required=True, help='Destination directory to move object into.')
    parser.add_argument('--modify', action='store_true', help='Default is a dry run without modification.')
    return parser.parse_args()


#
def move_media(pid, dir_set, dst_dir, modify):
    if pid in dir_set:
        dst_dir = os.path.join(dst_dir, "media")
        if modify is True:
            #shutil.move(dir_set[pid], dst_dir)
            # untested
            shutil.copytree(dir_set[pid], dst_dir, dirs_exist_ok=True)
        else:
            print(f"Move media {dir_set[pid]} to {dst_dir}")
    else:
        print(f"[WARNING] Media move - PID [{pid}] not found")


def move_combined_metadata(pid, dir_set, dst_dir, modify):
    if pid in dir_set:
        dst_dir = os.path.join(dst_dir, "combined_metadata")
        if modify is True:
            #shutil.move(dir_set[pid], dst_dir)
            # untested
            #shutil.copy(dir_set[pid], dst_dir)
        else:
            print(f"Move metadata {dir_set[pid]} to {dst_dir}")
    else:
        print(f"[WARNING] Metadata move - PID [{pid}] not found")

#
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
    glob_pattern = os.path.join(args.source_dir, '**', 'combined_metadata', '*')
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

    media_dir_set = build_index_media(args)
    metadata_dir_set = build_index_metadata(args)

    # open file list
    print(f"Processing ID list")
    with open(args.id_list, 'r') as ids_fd:

        for pid in ids_fd:
            pid = pid.strip()
            logging.info(f"id: {id}")
            move_media(pid, media_dir_set, args.destination_dir, args.modify)
            move_combined_metadata(pid, metadata_dir_set, args.destination_dir, args.modify)


if __name__ == "__main__":
    main()
