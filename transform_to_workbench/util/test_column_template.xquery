xquery version "3.1" encoding "utf-8";

(: Test one colume :)
(:
:)

import module namespace tH="transformationHelpers" at "../islandora7_to_workbench_utils.xquery";
import module namespace tC="transformationCommon" at "../islandora7_to_workbench_common.xquery";

declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
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
declare variable $FIELD_MEMBER_OF external := "50";

(: custom content handler :)
declare function local:generic_custom_function($metadata as item()*) as element()*
{
    (
    element test {tH:get_subject_name($metadata)},
    element test2 {tH:get_subject_name($metadata)}
    )

};

(: define the list of PIDs to transform :)
let $id_list := [
"cwrc:e3d5316d-3ecf-4392-a8c1-7dbd0be1f1c1",
"cwrc:a97c371b-acfc-408e-ab09-90206de022ff",
"cwrc:a0d11f5c-7897-4145-b5c3-ca6ca21211c9",
"cwrc:9b3b85b2-92d2-4dd8-8453-3ce569fc2668",
"cwrc:ff83e727-c67a-470a-8d78-8b9aa81be70e",
(:"cwrc:70b1bce7-ae7d-4f36-91a4-6fd8335c4a34",:)
"cwrc:3361e484-3d1b-465a-8dff-4da505796729",
"cwrc:e2f0b246-f560-4f16-ac88-a062e7c8565b",
"cwrc:3db6ca9f-ba83-48d6-afe8-5371029d583a",
"cwrc:5a779bf0-317e-40af-8895-e7d2d2fc1f16",
"cwrc:2de0ed9a-8750-4ee2-85f8-3c5c176f3982",
"cwrc:6d59455f-0e10-483d-b9ad-2b4487e5da59"(:,
"cwrc:92876fe6-c04b-4580-b6b4-6bb25a2ec01e":)
]

let $items := /metadata[
    (
        @pid=$id_list
        or contains(@pid/data(), "tpattzzzzzz")
    )
    and not(@models = $tH:UNSUPPORTED_MODELS)
    and not(@pid = 'tpatt:e6e1e1d0-a4e6-4ded-9356-0441f9fcba3f')
    and not(@pid = 'tpatt:f996dd38-add2-4dd9-80c5-f231f63b7e4d')
    ]

(: Create a local:generic_custom_function to create custom, non-generic fields specific to a given project such as "linked agent" :)
(: The `#2` in the function: the digit represents the number of arguments of your function (otherwise get an empty-sequence error). :)
return tC:output_csv_test_min($items, local:generic_custom_function#1, tC:generic_custom_properties#4, $FIELD_MEMBER_OF)
