xquery version "3.1" encoding "utf-8";

(: enip project specifics :)
(:
:)

import module namespace tH="transformationHelpers" at "../islandora7_to_workbench_utils.xquery";
import module namespace tC="transformationCommon" at "../islandora7_to_workbench_common.xquery";

declare namespace map = "http://www.w3.org/2005/xpath-functions/map";

declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace oai_dc = "http://www.openarchives.org/OAI/2.0/oai_dc/";
declare namespace fedora="info:fedora/fedora-system:def/relations-external#";
declare namespace fedora-model="info:fedora/fedora-system:def/model#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";

(: Uncomment to output as XML for the use case: XML to CSV conversion in a tool such as OxygenXML :)
(:
declare namespace saxon="http://saxon.sf.net/";
declare option output:method    "xml";
declare option output:indent    "yes";
declare option saxon:output     "method=xml";
:)

(: CSV output method if XML tooling supports (e.g., basex.org) :)
declare option output:method "csv";
declare option output:csv "header=yes, separator=comma";


(: CHANGE ME - ID of the default base collection :)
declare variable $FIELD_MEMBER_OF external := "";

(: define the list of PIDs to transform :)
let $id_list := [
    "tpatt:tpattroot"
]

let $items := /metadata[
    @pid=$id_list
    and not(@models = $tH:UNSUPPORTED_MODELS)
    ]

(: Create a local:generic_custom_function to create custom, non-generic fields specific to a given project such as "linked agent" :)
(: The `#2` in the function: the digit represents the number of arguments of your function (otherwise get an empty-sequence error). :)
return tC:output_csv($items, tC:generic_custom_function#1, tC:generic_custom_properties#4, $FIELD_MEMBER_OF)
