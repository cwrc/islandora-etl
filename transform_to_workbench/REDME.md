# A suite of transform and inquiry tools

## Projects

Contains a set of CWRC project-specific transforms from the `islandora7_export.py` format into an Islandora Workbench compatible CSV file. What makes the transform project-specific is that in the Islandora7 legacy version of CWRC, projects had flexibility on how to input content, for example, how to input authors. These XQuery-based transforms offer the ability to include customizations based on project-specific choices while leveraging a common library of transforms where common practices where utilized.

The general pattern:

* project specifics included in this `projects` directory files:
  * list of objects to export
  * function for name handling
  * function for producing overrides for the generic properties
  * `return tC:output_csv($items, local:generic_custom_function#1, tC:generic_custom_properties#4, $FIELD_MEMBER_OF)`
    * the main function call that generates the CSV; the signature accepts two functions:
      * one that creates custom fields (e.g., author name) and
      * one that allows overriding the generic/common handing of metadata (and is likely to be used rarely)
* generic Islandora Workbench CSV field creation functions
  * imported into the project-specific XQuery file via `islandora7_to_workbench_common.xquery`
    * `common_columns`: is a mapping of CSV column headings (Drupal fields) as keys and a function to populate the value
    * `islandora7_to_workbench_util.xquery` contains the function to transform metadata into strings that can populate field values (the mapping in the `common_columns`)


## Prototypes

The `/prototype` directory contains a set of tests and inquiry tools to work with the `islandora7_export.py` format. These include:

* test ordering of collections versus members of collections and books
* test approaches to generate Islandora Workbench CSV input

## Utilities

The `/utilities` directory contains a set of inquiry tools to work with the `islandora7_export.py` format. These include:

* inquiry tools to learn more about how the `mod:name` XML is structured
* list pages of books
* EDTF date inspections
* collection hierarchy information
