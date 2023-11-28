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


(: Format nameParts into a linked agent :)
declare function local:mods_name_formater($mods_name as node()) as xs:string
{
    if ( ($mods_name/mods:namePart)[1]/@type/data() = 'family' and ($mods_name/mods:namePart)[2]/@type/data() = 'given'  )
    then
        string-join($mods_name/mods:namePart/text(), ", ")
    else if (($mods_name/mods:namePart)[1]/@type/data() = 'given' and ($mods_name/mods:namePart)[2]/@type/data() = 'family'  )
    then
        concat( ($mods_name/mods:namePart)[2]/text(), ", ", ($mods_name/mods:namePart)[1]/text() )
    else
        string-join($mods_name/mods:namePart/text(), " ")
};


(: declare function tc:generic_custom_function($item_metadata as item()) as element()* :)
declare function local:generic_custom_function($metadata as item()*) as element()*
{
    <field_linked_agent>
    {
        (: toDo: very simplistic; assumes mods:namePart contains text and in test; expand :)
        for $mods_name at $pos in $metadata/resource_metadata/mods:mods/mods:name[exists(mods:namePart/text())]
            let $role :=
                if ($mods_name/role)
                then
                    for $role_node in $mods_name/role
                    return tH:get_marcrelator_term_from_text($role_node/roleTerm/text())
                else
                    tH:get_marcrelator_term_from_text('Author')
            let $separator :=
                if ($pos > 1)
                then $tH:WORKBENCH_SEPARATOR
                else ""

            return
                concat($separator, 'relators:', $role, ":person:", local:mods_name_formater($mods_name) )
    }
    </field_linked_agent>
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
    and not(@pid = 'tpatt:e6e1e1d0-a4e6-4ded-9356-0441f9fcba3f')
    and not(@pid = 'tpatt:f996dd38-add2-4dd9-80c5-f231f63b7e4d')
    ]

(: Create a local:generic_custom_function to create custom, non-generic fields specific to a given project such as "linked agent" :)
(: The `#2` in the function: the digit represents the number of arguments of your function (otherwise get an empty-sequence error). :)
return tC:output_csv($items, local:generic_custom_function#1, tC:generic_custom_properties#4, $FIELD_MEMBER_OF)
