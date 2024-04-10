xquery version "3.1" encoding "utf-8";

(: tpatt project specifics :)
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
(:
: Required properties:
:  * field_linked_agent
:  * field_related_item_contributor_s
:)
declare function local:generic_custom_function($metadata as item()*) as element()*
{
    <field_linked_agent>
    {
        (: ToDo: very simplistic; add project specific code, if needed :)
        tH:generic_linked_agent(
            $metadata/resource_metadata/mods:mods/mods:name[exists(mods:namePart/text())]
            )
    }
    </field_linked_agent>,
    <field_related_item_contributor_s>
    {
        (: ToDo: don't use this placeholder; add project specific code, if needed :)
        tH:generic_linked_agent(
            $metadata/resource_metadata/mods:mods/mods:relatedItem/mods:name[exists(mods:namePart/text())]
            )
    }
    </field_related_item_contributor_s>
};

(: define the list of PIDs to transform :)
let $id_list := [
]

let $items := /metadata[
    (
        @pid=$id_list
        or contains(@pid/data(), "tpatt")
    )
    and not(@models = $tH:UNSUPPORTED_MODELS)
    and not(@pid = 'tpatt:e6e1e1d0-a4e6-4ded-9356-0441f9fcba3f') (: missing title :)
    and not(@pid = 'tpatt:f996dd38-add2-4dd9-80c5-f231f63b7e4d') (: multiple titleInfo :)
    ]

(: Create a local:generic_custom_function to create custom, non-generic fields specific to a given project such as "linked agent" :)
(: The `#2` in the function: the digit represents the number of arguments of your function (otherwise get an empty-sequence error). :)
return tC:output_csv($items, local:generic_custom_function#1, tC:generic_custom_properties#4, $FIELD_MEMBER_OF)
