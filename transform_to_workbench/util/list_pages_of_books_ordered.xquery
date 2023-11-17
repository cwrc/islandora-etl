(: for a given book, lookup the associated pages and return in order of their page number :)
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace oai_dc = "http://www.openarchives.org/OAI/2.0/oai_dc/";
declare namespace fedora="info:fedora/fedora-system:def/relations-external#";
declare namespace fedora-model="info:fedora/fedora-system:def/model#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace islandora="http://islandora.ca/ontology/relsext#";

let $resource := 'info:fedora/tpatt:19e97453-1ef3-4f95-8497-8e81abc03584'

for $item in /metadata[resource_metadata/rdf:RDF/rdf:Description/islandora:isPageOf[@rdf:resource=$resource]]
  let $page := xs:integer($item/resource_metadata/rdf:RDF/rdf:Description/islandora:isSequenceNumber/text())
order by $page
return concat($item/@pid/data(), ' - ', $page)