declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace oai_dc = "http://www.openarchives.org/OAI/2.0/oai_dc/";
declare namespace fedora="info:fedora/fedora-system:def/relations-external#";
declare namespace fedora-model="info:fedora/fedora-system:def/model#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";

import module namespace sb="exportSetBuilder" at "./set_builder_base.xquery";

(: CSV output method if XML tooling supports (e.g., basex.org) :)
declare option output:method "csv";
declare option output:csv "header=yes, separator=comma";



(: List from https://docs.google.com/spreadsheets/d/15ey4b-U2LaiBolgOoipR38rtBNff-toM/edit?gid=988689388#gid=988689388 :)
declare variable $pids := [
  "islandora:root",
  "islandora:root"
];

let $resources := /metadata[@pid/data() = $pids]
return sb:output_csv($resources)
