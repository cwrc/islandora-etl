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

## Extract from Islandora Legacy

* define a list of pid to export from the Islandora Legacy site and added to a file, one per line

* execute the extraction script
  * `--id_list` : list of PIDs to export
  * `--server` : the Islandora Legacy server (Drupal 7)
  * `--export_dir` : directory to store the export package

``` bash
python3 islandora7_export_2.py --id_list test_data/z --server ${ISLANDORA_LEGACY:-https://example.com} --export_dir /tmp/z/
```

* results in the export directory
  * each Fedora 3 datastream extracted as a file (not in the exclusion list defined in the script)
  * a combination of metadata combined into a single output file (metadata datastreams defined in the script) 

``` xml
<metadata pid="" label="" owner="" created="" modified="">
  <media_exports>
    </media filepath="" ds_id="">
    <!-- a list of Islandora Legacy extracted datastreams with their path and datastream id -->
  </media_exports>
  <resource_metadata>
    <!-- a list of extracted metadata datastreams including MODS, RELS-EXT, ect. -->
  </resource_metadata>
</metadata>
```

## Transformation and metadata inquiry tools

This script compares the Islandora Legacy content with the new imported via Islandora Workbench content in the new Islandora site to verify/audit the export, transformation, and loading phase. The comparison is made between the Islandora Legacy MODS metadata and the Islandora JSON-LD output.

Reference for the metadata conversion: [Islandora MIG](https://github.com/islandora-interest-groups/Islandora-Metadata-Interest-Group/wiki/MIG-MODS-to-RDF-Working-Documents) and [Islandora MIG (Metadata Interest Group) MODS-RDF Simplified Mapping](https://docs.google.com/spreadsheets/d/18u2qFJ014IIxlVpM3JXfDEFccwBZcoFsjbBGpvL0jJI/edit#gid=0)

* setup and running transformation and metadata inquiry tools
  * install basex.org according to the basex.org documentation
  * create new database and import the `combined_metadata` directory contents produced by the `Exraction` step
  * run XQuery from the `Transformation` directory to transform XML metadata into a CSV for use with Islandora Workbench

## Loading to Islandora

* Load via [Islandora Workbench](https://github.com/mjordan/islandora_workbench) using the CSV created during the the transformation section. See the Workbench documentation for details. A sample config is included in the `test_data` directory.

* to check

```bash
 python3 workbench --config ../workbench_config/workbench_config_test_02.yaml --check
 ````

### Auditing: running the after Islandora Workbench import verification script

Attempts to compare Islandora Legacy XML to the JSON-LD output of Islandora (Drupal 8+) node using the mappings defined by the [Islandora MIG](https://github.com/islandora-interest-groups/Islandora-Metadata-Interest-Group/wiki/MIG-MODS-to-RDF-Working-Documents) and with the document: [Islandora MIG (Metadata Interest Group) MODS-RDF Simplified Mapping](https://docs.google.com/spreadsheets/d/18u2qFJ014IIxlVpM3JXfDEFccwBZcoFsjbBGpvL0jJI/edit#gid=0)


`python3 islandora_audit.py --id_list test_data/z --islandora_legacy https://example.com/ --islandora https://example_9.com/ --comparison_config test_data/comparison_config.sample.json`

### ToDo

* how to find mapping between UUID in Islandora Legacy and identifier in new Islandora
* hot to handle mappings where the new Islandora JSON LD returns a taxonomy ID where Islandora Legacy uses textual terms

## Testing

To run tests:

`python3 tests/export_unit_tests.py`

## Style

`pycodestyle --show-source --show-pep8 --ignore=E402,W504 --max-line-length=200 .`
