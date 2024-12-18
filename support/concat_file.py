##############################################################################################
# desc: starting with a workbench CSV input file, loop through all file_* columns and
#           write allow listed files into a zip file; create a new Workbench CSV with
#           new column for the zip file
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
import zipfile

from pathlib import Path



def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--output_dir', required=True, help='Location to store zip files.')
    parser.add_argument('--output_csv', required=True, help='Location to store edited CSV with the additional column file_combined_zip.')
    parser.add_argument('--input', required=True, help='Input CSV; output of the islandora-elt XQuery tools.')
    parser.add_argument('--logging_level', required=False, help='Logging level.', default=logging.WARNING)
    #parser.add_argument('--logging_level', required=False, help='Logging level.', default=logging.INFO)
    return parser.parse_args()

#
def print_progress_bar(iteration, length=50, fill='.'):
    if iteration % length == 0:
        print(f'{fill}', end="")


#
def is_file_for_archive(file_column, row):
    valid = False
    if file_column in ["file_workflow", "file_rels-ext", "file_mods"] or (file_column == "file_obj" and Path(row['file_obj']).suffix == '.tiff') :
        logging.info(f"{row}")
        logging.info(f"{file_column} {row[file_column]}")
        if row[file_column] != '':
            valid = True
    return valid

#
def filter_header_keys_by_prefix(row, prefix="file_"):
    return {k: v for k, v in row.items() if k.startswith(prefix)}


#
def process(input_csv, output_csv, output_dir):

    for i, row in enumerate(input_csv):
        zip_file_path = os.path.join(output_dir, row['id'] + ".zip")
        with zipfile.ZipFile(zip_file_path, 'w') as zip_file:
            for index, file_column in enumerate(filter_header_keys_by_prefix(row)):
                if (is_file_for_archive(file_column, row)):
                    zip_file.write(
                            row[file_column],
                            arcname=os.path.join(file_column, os.path.basename(row[file_column]))
                            )
            # Todo: only write and add row if zip not empty
            if (index > 0):
                row['file_combined_zip']=zip_file_path
                output_csv.writerow(row)
                logging.info(row)
            else:
                logging.warning(f"WARNING: no files found for row [{row}]")
        print_progress_bar(i + 1, length=100)
    print()


#
def main():

    args = parse_args()

    logging.basicConfig(level=args.logging_level)

    if not os.path.exists(args.output_dir): os.makedirs(args.output_dir)

    with open(args.input, 'r', encoding="utf-8", newline='') as input_file:
        input_csv = csv.DictReader(input_file)
        with open(args.output_csv, 'wt', encoding="utf-8", newline='') as output_file:
            logging.info(input_csv.fieldnames)
            output_fieldnames = input_csv.fieldnames + ["file_combined_zip"]
            output_csv = csv.DictWriter(output_file, fieldnames=output_fieldnames)
            output_csv.writeheader()
            process(input_csv, output_csv, args.output_dir)


#
if __name__ == "__main__":
    main()
