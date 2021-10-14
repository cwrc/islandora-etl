# Islandora Legacy (Drupal 7) Exporter

A set of tools to

* export from an Islandora Legacy (Drupal 7)
* transform the export package into proper package to work with [Islandora Workbench](https://github.com/mjordan/islandora_workbench)
* verify the ingest into Islandora (Drupal 9) by comparing the MODS in Islandora-Legacy site to JSON-LD respresentation in Islandora (Drupal 9)

## Features

* Python command-line script to export content via the [Islandora REST API](https://github.com/discoverygarden/islandora_rest) on the Islandora Legacy site thus able to run anywhere
  * Export package includes downloading all datastreams (exclusion list controlled) plus an `XML Metadata` file
  * The `XML Metadata` file contains the source metadata in XML from for use by a transformation step to build the CVS formate required by Islandora Workbench, (i.e., FOXML Fedora Metadata, plus MODS xml, plus datastream export locations)

* Set of XQuery scripts to convert the metadata into a CSV format (used with BaseX.org) -- we're using BaseX.org to bulk explore/surface how metadata has been recorded in MODS as CWRC doesn't use the defualt XML Form Builder forms

* Python command-line script to verify contents, to a specified degree, that the Islandora Legacy MODS metadata exists in the new Islandora site via a comparison with the JSON-LD serialization

## Installing

Git clone the repository

Install Python 3+ (haven tried with other versions)

Add Python libraries -- local user (not system wide)

`python3 setup.py install --user`

Add Python libraries -- system wide

`sudo python3 setup.py install`

## Running the export

* define a list of pid to export from the Islandora Legacy site and added to a file, one per line

* execute the export script
  * `--id_list` : list of PIDs to export
  * `--server` : the Islandora Legacy server (Drupal 7)
  * `--export_dir` : directory to store the export package

`python3 islandora7_export_2.py --id_list test_data/z --server https://example.com/ --export_dir /tmp/z/`

## Running the XQuery transforms and metadata inquiry tools

* install basex.org
* create new database and import the `combined_metadata` directory contents produced by the export
* run XQuery from the `xqery` directory to transform XML metadata into a CSV for use with Islandora Workbench

## Running the after Islandora Workbench import verification script

This script compares the Islandora Legacy content with the new imported via Islandora Workbench content in the new Islandora site to verify/audit the export, transformation, and loading phase. The comparison is made between the Islandora Legacy MODS metadata and the Islandora JSON-LD output.

`python3 islandora_audit.py --id_list test_data/z --islandora_legacy https://example.com/ --islandora https://example_9.com/ --comparison_config test_data/comparison_config.sample.json`

ToDo:

* how to find mapping between UUID in Islandora Legacy and identifier in new Islandora
* hot to handle mappings where the new Islandora JSON LD returns a taxonomy ID where Islandora Legacy uses textual terms

## Testing

To run tests:

`python3 tests/export_unit_tests.py`

## Style

`pycodestyle --show-source --show-pep8 --ignore=E402,W504 --max-line-length=200 .`
