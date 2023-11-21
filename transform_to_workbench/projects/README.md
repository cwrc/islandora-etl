# Project specific workspace

This directory holds the project-specific XQuery scripts (that import the generic methods for handling the metadata).

## Template of a project-specific XQuery

* setup and preamble.
* an optional custom project-specific function adding project-specific custom CSV columns (e.g., linked-agent, etc.).
* an optional custom project-specific function overriding the common CSV column value (e.g., lang code, etc.).
* a list of PIDs comprising the project or another method to define the list of `metadata` nodes to process
* a call to a function that creates the CSV output whereby two project-specific functions (new column or overridden field value) can be passed into to customize the CSV output

Note: output from these templates requires the following Islandora Workbench config options:

1. ignore columns added for debugging

``` yaml
# https://mjordan.github.io/islandora_workbench_docs/ignoring_csv_rows_and_columns/
ignore_csv_columns: ['collection_path', 'multiple_parent_collections', 'parent_of_page']
```

1. a custom media use term for Islandora-legacy datastreams archived in LEAF (where 94 is replaced with the ID of the new media use term attached to the legacy datastream contents being archived or altered to other media use terms as required)

``` yaml
# add custom Islandora Media Use terms
# name: Islandora7 Archive File
# desc: An object datastream imported from the previous version of Islandora / CWRC (Islandora7) - not for display in the current version of Islandora.
# https://mjordan.github.io/islandora_workbench_docs/adding_multiple_media/
additional_files:
  - file_rels-ext: 94
  - file_mods: 94
  - file_dc: 94
  - file_policy: 94
  - file_workflow: 94
  - file_tn: 19
  - file_pdf: 94
  - file_obj: 94
  - file_techmd: 94
  - file_preview: 94
  - file_full_text: 94
  - file_legacy_mods: 94
  - file_cwrc: 94
  - file_medium_size: 94
  - file_legacy_writing_xml: 94
  - file_legacy_writing_sccs: 94
  - file_legacy_biography_xml: 94
  - file_legacy_biography_sccs: 94
  - file_jpg: 94
  - file_jp2: 94
  - file_rels-int: 94
  - file_archive_wikitext: 94
  - file_dtoc: 94
  - file_full_text: 94
  - file_pdf: 94
  - file_ocr: 94
  - file_hocr: 94
  - file_proxy_mp3: 94
  - file_mp4: 94
  - file_mkv: 94
  - file_image: 94
```

1. Workbench sub delimiter (the following is the default in this group of transforms)

``` yaml

subdelimiter: "^|.|^"
```
