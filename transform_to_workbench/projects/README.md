# Project specific workspace

This directory holds the project-specific XQuery scripts (that import the generic methods for handling the metadata).

## Template of a project-specific XQuery

* setup and preamble.
* an optional custom project-specific function adding project-specific custom CSV columns (e.g., linked-agent, etc.).
* an optional custom project-specific function overriding the common CSV column value (e.g., langcode, etc.).
* a list of PIDs comprising the project or another method to define the list of `metadata` nodes to process
* a call to a function that creates the CSV output whereby two project-specific functions (new column or overridden field value) can be passed into to customize the CSV output
