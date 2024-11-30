##############################################################################################
# desc: starting with a workbench input file, loop through all file_* columns
#           write allow listed files into a zip file and add to a new CSV column
#       output:  
#       input: 
# usage: python3 concat_file.py \
#           --output_csv ${output_csv_path} \
#           --output_file ${output_file_path} \
#           -input ${input_path}
# license: CC0 1.0 Universal (CC0 1.0) Public Domain Dedication
# date: Nov 29, 2024
##############################################################################################


import argparse
import csv
import logging
import os
import shutil
import tempfile
import zipfile

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--output_dir', required=True, help='Location to store file.')
    parser.add_argument('--output_csv', required=True, help='Location to store edited CSV .')
    parser.add_argument('--input', required=True, help='Input CSV.')
    parser.add_argument('--logging_level', required=False, help='Logging level.', default=logging.WARNING)
    return parser.parse_args()

def filter_header_keys_by_prefix(row, prefix="file_"):
    return {k: v for k, v in row.items() if k.startswith(prefix)}


#
def process(input_csv, report_csv, output_dir):

    for i, row in enumerate(input_csv):
        zip_file_path = os.path.join(output_dir, row['id'] + ".zip")
        with zipfile.ZipFile(zip_file_path, 'w') as zip_file:
            with tempfile.TemporaryDirectory() as tmp_dir:
                for file_column in filter_header_keys_by_prefix(row):
                    if file_column in ["file_b"]:
                        shutil.copy(row[file_column], tmp_dir)
                        zip_file.write(row[file_column], arcname=os.path.join(file_column, os.path.basename(file_column)))


#
def main():
    args = parse_args()

    with open(args.input, 'r', encoding="utf-8", newline='') as input_file:
        input_csv = csv.DictReader(input_file)
        with open(args.output_csv, 'wt', encoding="utf-8", newline='') as output_file:
            print(input_csv.fieldnames)
            output_fieldnames = input_csv.fieldnames + ["file_combined_zip"]
            output_csv = csv.DictWriter(output_file, fieldnames=output_fieldnames)
            output_csv.writeheader()
            process(input_csv, output_csv, args.output_dir)


#
if __name__ == "__main__":
    main()
