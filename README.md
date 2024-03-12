# Islandora Legacy (Drupal 7) Exporter

A set of tools to

* export from an Islandora Legacy (Drupal 7)
* transform the export package into a proper package (CSV) to work with [Islandora Workbench](https://github.com/mjordan/islandora_workbench)
* verify the ingest into Islandora (Drupal 9) by comparing the MODS in Islandora-Legacy site to JSON-LD respresentation in Islandora (Drupal 9)

## Features

* Python command-line script to export content via the [Islandora REST API](https://github.com/discoverygarden/islandora_rest) on the Islandora Legacy site thus able to run anywhere
  * The export package includes downloading all data streams (exclusion list controlled) plus an `XML Metadata` file
  * The `XML Metadata` file contains the source metadata in XML form for use by a transformation step to build the CVS format required by Islandora Workbench, (i.e., FOXML Fedora Metadata, plus MODS XML, plus datastream export locations)

* Set of XQuery scripts to convert the metadata into a CSV format (used with BaseX.org) -- we're using BaseX.org to bulk explore/surface how metadata has been recorded in MODS as CWRC doesn't use the default XML Form Builder forms

* Python command-line script to verify contents, to a specified degree, that the Islandora Legacy MODS metadata exists in the new Islandora site via a comparison with the JSON-LD serialization

## Installing

Git clone the repository

Install Python 3+ (haven't tried with other versions)

Add Python libraries -- local user (not systemwide)

`python3 setup.py install --user`

Add Python libraries -- systemwide

`sudo python3 setup.py install`

## Extract from Islandora Legacy

* define a list of pid to export from the Islandora Legacy site and added to a file, one per line

* execute the extraction script
  * `--id_list` : list of PIDs to export
  * `--server` : the Islandora Legacy server (Drupal 7)
  * `--export_dir` : directory to store the export package

``` bash
python3 islandora7_export.py --id_list test_data/z --server ${ISLANDORA_LEGACY:-https://example.com} --export_dir /tmp/z/
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
  * create a new database and import the `combined_metadata` directory contents produced by the `Extraction` step
  * run XQuery from the `Transformation` directory to transform XML metadata into a CSV for use with Islandora Workbench

### How to find the Islandora fields available?

A list of available fields can be discovered via the `--get_csv_template` option within [Islandora Workbench](https://mjordan.github.io/islandora_workbench_docs/csv_file_templates/). The fields available depend on the combination of the Drupal config created either via the [Islandora defaults](https://github.com/Islandora/islandora_defaults) profile or the Drupal config subsequently added initial Drupal setup.

### version alignment with configured Drupal fields

* current commit aims for string type alignment with
  * "islandora/islandora_defaults": "dev-8.x-1.x#0d9a59a"
  * working towards: [Islandora MIG (Metadata Interest Group) MODS-RDF Simplified Mapping](https://docs.google.com/spreadsheets/d/18u2qFJ014IIxlVpM3JXfDEFccwBZcoFsjbBGpvL0jJI/edit#gid=0)

### How to specify the parent collection?

* [Creation of content and collection in the same CSV](https://mjordan.github.io/islandora_workbench_docs/paged_and_compound/#creating-collections-and-members-together)

* the sample transform attempts to use the `parent_id` if the collection object is in the exported set in the previous set otherwise defaults to the specified `node_id` in the XQuery transform

***Care needs to be taken with collections otherwise resources can be added without a collection***

Collections need to appear before children/members in the workbench CSV (see [creating collections and members together](https://mjordan.github.io/islandora_workbench_docs/paged_and_compound/#creating-collections-and-members-together))

2021-10-22: add some logic that attempts to order items in CSV by collection hierarchy: this only works if the items in the collection hierarchy are present and also not already in Islandora. Note: the `url_alias` should trigger a warning if one tries to add a collection that pre-exists.

Each item should have either a `parent_id` (if the parent collection is referenced in the workbench CSV) or `field_member_of` (if the parent collection pre-exists in Drupal). Note: if not, then resources will float without a parent.  [Creating collections and members together](https://mjordan.github.io/islandora_workbench_docs/paged_and_compound/#creating-collections-and-members-together))

* if collection preexists in Drupal then lookup the Drupal node ID for the collection
  * option 1: if workbench CSV contains collections meant to be the direct child of a pre-existing Drupal collection then add the Drupal node id to the `field_member_of` to all collections without a `parent_id`
  * option 2: if the workbench CSV contains no collections then add the Drupal node ID to each row
* if the collection is added via the workbench CSV, the `parent_id` of the member should reference the `id` of the parent


If items are added without a collection, the `output_csv` Islandora Workbench config will provide a way to update existing items (don't lose the file) assuming they have not changed via the UI. See Islandora Workbench documentation for details.

todo: flesh out potential problem areas around the collection hierarchy and loading

* [islandora7_to_workbench_generic.xquery](./transform_to_workbench/islandora7_to_workbench_generic.xquery) (circe 2023-08-29) is a worked example of how to handle collections and book objects using tpatt data
* [collection_hierarchy_display.xquery](./transform_to_workbench/util/collection_hierarchy_display.xquery) help to display the collection hierarchy

#### note: Islandora Workbench subdelimiter - using non-default

Due to archival records containing the `|` character, the Islandora Workbench subdelimiter is set to a custom value as the Workbench default is `|`. This requires updating (2022 version is [^|.|^](https://github.com/cwrc/islandora-etl/blob/41ef5601a6e3673eb05d27a498499eb28e93617f/transform_to_workbench/islandora7_to_workbench_utils.xquery#L16))
* [Workbench config](https://mjordan.github.io/islandora_workbench_docs/configuration/#input-csv-file-settings)
* [the XQuery transform](https://github.com/cwrc/islandora-etl/blob/41ef5601a6e3673eb05d27a498499eb28e93617f/transform_to_workbench/islandora7_to_workbench_utils.xquery#L16)

## Loading to Islandora

* Load via [Islandora Workbench](https://github.com/mjordan/islandora_workbench) using the CSV created during the transformation section. See the Workbench documentation for details. A sample config is included in the `test_data` directory.

* to check that the CSV to import is valid

``` bash
 python3 workbench --config ../workbench_config/workbench_config_test_02.yaml --check
 ```

* to load, remove the `--check` parameter from the above

``` bash
 python3 workbench --config ../workbench_config/workbench_config_test_02.yaml
 ```

More information:

* [Workbench Fields](https://mjordan.github.io/islandora_workbench_docs/fields/)

### Note: to verify EDTF dates (faster than Islandora Workbench --check)

[verify_edtf_date_in_csv.py](transform_to_workbench/util/verify_edtf_date_in_csv.py)


## Auditing: running the after Islandora Workbench import verification script

Attempts to compare Islandora Legacy XML to the JSON-LD output of Islandora (Drupal 8+) node using the mappings defined by the [Islandora MIG](https://github.com/islandora-interest-groups/Islandora-Metadata-Interest-Group/wiki/MIG-MODS-to-RDF-Working-Documents) and with the document: [Islandora MIG (Metadata Interest Group) MODS-RDF Simplified Mapping](https://docs.google.com/spreadsheets/d/18u2qFJ014IIxlVpM3JXfDEFccwBZcoFsjbBGpvL0jJI/edit#gid=0)

``` bash
python3 islandora_audit.py --id_list test_data/z --islandora_legacy https://example.com/ --islandora https://example_9.com/ --comparison_config test_data/comparison_config.sample.json
```

### ToDo

* how to find mapping between UUID in Islandora Legacy and identifier in new Islandora
  * investigate PathAuto URL Alias or Workbench URL Alias
  * investigate Workbench output_csv as a source of the old/new mapping
* hot to handle mappings where the new Islandora JSON LD returns a taxonomy ID where Islandora Legacy uses textual terms

## How to gather a list of PIDs from an Islandora Legacy (aka Islandora07) collection

Purpose: to return a list of all the direct members of a specified collection. As of 2022-04-19: It doesn't traverse the descendent collections of the specified collection.

See the `islandora_search.py script`

``` bash
python3 islandora7_search.py --input_file input_file_listing_collection_PIDs --server https://cwrc.ca --output_file output_file_to_store_results
```

## Testing

To run tests:

`python3 tests/export_unit_tests.py`

## Style

`pycodestyle --show-source --show-pep8 --ignore=E402,W504 --max-line-length=200 .`

## FAQ

Media files fail to load via Islandora Workbench (or via the Drupal UI)

* check that the Drupal user has the `fedoraAdmin` role

How to gather a set of PID from Islandora Legacy (Islandora 7)?

* direct query to Solr is one way - the following outputs a list of PIDs contained within the collection plus the collection itself:
  * `collection_PID=some_islandora_collection_pid`
  * `curl "http://localhost:8080/solr/select?rows=999999&start=0&fl=PID&q=RELS_EXT_isMemberOfCollection_uri_ms:%22info:fedora/${collection_PID}%22%20OR%20PID:%22${collection_PID}%22&wt=csv&sort=PID+asc"`

## Todo

* linked agent:
  * the role is not often specified, will have to set it manually? For each collection?

* `<mods:typeOfResource>sound recording-nonmusical</mods:typeOfResource>`:
  * where should this go? `field_resource_type` is this a special Islandora vocabulary?

* `field_resource_type` and `field_model`: mapping via the Islandora Legacy cModel type to Islandora taxonomy terms -- is this correct?

* `<mods:issuance>monographic</mods:issuance>`
  * where?

* recordInfo: need mapping

* langcode?

## useful queries

List all models
```
for $i in /metadata/@models
group by $i
return $i
```

Lookup by PID
```
let $pid = "digitalpage:881e0ee6-52ed-4f05-9e8d-c5e51c5c1a31"
for $i in /metadata[@pid=$pid]
return $i
```


