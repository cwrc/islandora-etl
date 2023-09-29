#!/user/bin/env python3
#####
# Verify a workbench export for valid EDTF dates within a specified CSV colum
# Input: a CSV file in the Workbench format.
# Output:
#
# python3 transform_to_workbench/util/test_edtf_date_in_csv.py --column 2 --input_file /data-migration/delete_me.csv
#
# Notes
# * https://github.com/ixc/python-edtf
# * https://pypi.org/project/edtf/#description
#######

import argparse
import logging
import os
import csv
import re
import edtf_validate.valid_edtf

DEFAULT_DATE_SEPARATOR = "^|.|^"
#
def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--input_file', required=True, help='List of Islandora PIDs, one per line.')
    parser.add_argument('--delimiter', required=False, default=DEFAULT_DATE_SEPARATOR, help='Islandora Workbench multi.')
    parser.add_argument('--column', required=True, help='CSV column to test edtf date (numerical index).')
    return parser.parse_args()


def is_multiple_edtf_valid(date_str, delimiter):
    is_valid = False
    for item in date_str.split(delimiter):
        if (edtf_validate.valid_edtf.is_valid(item) == False):
            is_valid = False
            break
        else:
            is_valid = True 

    return is_valid


# Main
def main():
    args = parse_args()

    with open(args.input_file) as csv_file :
        csv_reader = csv.reader(csv_file, delimiter=',')
        line_count = 0
        column = int(args.column)
        for row in csv_reader:
            # assume first row is a header
            if (line_count == 0) :
                print(f'\trow[{line_count}] - skipping header: {row[column]}')
                line_count += 1
            else:
                if (row[column] != "") :
                    edtf_valid = is_multiple_edtf_valid(row[column], args.delimiter)
                    print(f'\trow:[{line_count}] - valid:[{edtf_valid}] - [{row[column]}] - [{row[0]}].')
            line_count += 1
        print(f'Processed {line_count} lines.')
        


if __name__ == "__main__":
    main()
