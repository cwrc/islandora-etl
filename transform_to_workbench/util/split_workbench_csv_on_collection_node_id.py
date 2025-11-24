"""                                                                             
##############################################################################################
# desc: split_workbench_csv_on_collection_node_id.py:
#   Given an Islandora Workbench input/export CSV
#   create two new files one with and one without the items in a given collection 
# usage:
#   split_workbench_csv_on_collection_node_id.py \
#        --node_id ${node_id} \
#        --input ${input} \
#        --output_without_nid ${output_without_nid} \
#        --output_only_nid ${output_only_nid} \
# license: CC0 1.0 Universal (CC0 1.0) Public Domain Dedication
# date: Nov 21, 2025
##############################################################################################
"""
 
import argparse
import csv
import logging
import sys

def parse_args():
    """
    Parse command line arguments
    """

    parser = argparse.ArgumentParser()

    parser.add_argument(
        "--target_nid",
        required=True,
        help="The Drupal Node ID target id of a Collection to separate.",
    )

    parser.add_argument(
        "--input",
        required=True,
        help="The Islandora Workbench CSV ingest/export CSV.",
    )

    parser.add_argument(
        "--output_without_nid",
        required=True,
        help="The CSV without the node_id and decendants rows.",
    )

    parser.add_argument(
        "--output_only_nid",
        required=True,
        help="The CSV only containing rows with node_id and decendants.",
    )

    parser.add_argument(
        "--log_level",
        choices=["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"],
        default="INFO",
        help="Logging level.",
        required=False,
    )

    return parser.parse_args()


def build_member_of_map(rows):
    """
    Build a map datastructure of parent -> children relationships
    via field_member_of using the node_id as the target
    """
    member_of_map = {}
    for row in rows:
        node_id = row["node_id"]
        member_of = row["field_member_of"]
        if member_of:
            member_of_map.setdefault(member_of, []).append(node_id)
    return member_of_map
           
def get_descendants(target_nid, parent_map): 
    """
    Recusive function: given a target ID find all members of (children)
    and recuse to the next level
    """
    descendants = []

    for child in parent_map.get(target_nid, []):
        descendants.append(child)
        # recusive
        descendants.extend(get_descendants(child, parent_map))
    return descendants


def process(rows, target_nid, without_nid_writer, only_nid_writer):
  
    member_of_map = build_member_of_map(rows)

    # Nids to separate out
    nids_to_separate = {target_nid} # include the target_nid
    nids_to_separate.update(get_descendants(target_nid, member_of_map))


    for row in rows:
        if row["node_id"] in nids_to_separate:
            # Desendants of the target id
            only_nid_writer.writerow(row)
        else:
            # Not desendants of the target id
            without_nid_writer.writerow(row)

#
def main():
    """
    Main entry point
    """

    args = parse_args()

     # Configure logging
    logging.basicConfig(
        level=getattr(logging, args.log_level),
        format="%(asctime)s [%(levelname)s] %(message)s"
    )

    with open(args.input, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        rows = list(reader)

    with open(args.output_without_nid, "w", newline="", encoding="utf-8") as f_without:
        with open(args.output_only_nid, "w", newline="", encoding="utf-8") as f_only:
            without_nid_writer = csv.DictWriter(f_without, fieldnames=reader.fieldnames)
            without_nid_writer.writeheader()
            only_nid_writer = csv.DictWriter(f_only, fieldnames=reader.fieldnames)
            only_nid_writer.writeheader()
            process(rows, args.target_nid, without_nid_writer, only_nid_writer)


#
if __name__ == "__main__":
    main()

