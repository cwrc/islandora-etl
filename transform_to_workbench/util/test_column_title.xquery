xquery version "3.1" encoding "utf-8";

(: Test one column :)
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
    (: Using the squenence syntax (notice the "()" and "," comma. This also works with "element" syntax "element test {function($metadata)}"
    
    :)
    (
        <field_title_full>{tH:get_title_full($metadata,"")}</field_title_full>,
        <field_title_trunc>{tH:get_title_255_characters($metadata,"")}</field_title_trunc>,
        <field_title_alternative>{tH:get_title_alt($metadata)}</field_title_alternative>,

        <field_related_item_title>{tH:get_related_item_title($metadata)}</field_related_item_title>,
        <field_related_item_title_full>{tH:get_related_item_title_full($metadata)}</field_related_item_title_full>,
        <field_related_item_alternative_t>{tH:get_related_item_title_alt($metadata)}</field_related_item_alternative_t>,
        <a></a>
    )
};

(: define the list of PIDs to transform :)
let $id_list := [
]

let $items := /metadata[
    (
        @pid=$id_list
        or
        (
          (
            (:
            resource_metadata/mods:mods/mods:relatedItem/mods:titleInfo/mods:subTitle
            or
            resource_metadata/mods:mods/mods:titleInfo/mods:subTitle
            or 
            resource_metadata/mods:mods/mods:titleInfo[(not(@*) or @usage/data()='primary')]/mods:title[string-length(normalize-space(string-join(.//text(),"")))>255]
            resource_metadata/mods:mods/mods:titleInfo/mods:title (: some items don't have a title, remove from test for now :)
            :)
            
            resource_metadata/(mods:mods|mods:modsCollection/mods:mods)/mods:titleInfo[not(@type)]/mods:title
            
          )
          and
          @pid/data() = ["cwrc:0314fd25-4516-419c-abc2-fe3c480ce876","cwrc:049ada3a-7fe4-41d3-aa6a-0928652a4fd3"]
        )
        (: or contains(@pid/data(), "tpattzzzzzz") :)
    )

    and not(@models = $tH:UNSUPPORTED_MODELS)
    (: possibily interesting test cases; the last 3 Orlando have complex titles
    and @pid/data() = [
      'cjww:be0d8a1e-def6-4bf5-982f-5091426cf87a',
      'cwrc:96625e12-5100-4748-8db7-806d8fa2bf3f',
      'cwrc:f06d59b8-702d-4b59-9820-fa691bb0a1ba',
      'cwrc:f4eb1dad-1bf9-42f8-9630-d8f41bbdeae3',
      'cwrc:f5a34588-9c9c-4ac3-90ef-2bd85a82e135',
      'digitalpage:1158b947-9568-4941-b612-ed0523fdf3fb',
      'digitalpage:6abb9b35-918e-4ae5-b0e0-96af4f93e172',
      'digitalpage:bad4754a-7dc7-4dba-9ab3-386dcdab7259',
      'digitalpage:c2dee765-9488-4563-a3b9-bdc8512405f6',
      'islandora:03055d22-2b66-4d06-8d66-05a37a75079b',
      'islandora:10a53a3d-b740-4e9a-b93f-0b862611fc8c',
      'orlando:1155fe3e-6b41-477b-a7c2-51fdfd0cbd55',
      'orlando:1041f3b4-6698-4a2d-b958-4220ec021db4',
      'orlando:10429544-b413-4ac9-bfe9-99475c349906',
      'orlando:0f83e42a-e9d8-425c-bf0a-aa84346f905b'
    ]
:)
    and not(@pid/data() = [
      'cwrc:4b9f29d1-1175-4a5d-a940-36fe3f2c1000' (: cmodel missing :)
    ])
    ]

(: Create a local:generic_custom_function to create custom, non-generic fields specific to a given project such as "linked agent" :)
(: The `#2` in the function: the digit represents the number of arguments of your function (otherwise get an empty-sequence error). :)
return tC:output_csv_test_min($items, local:generic_custom_function#1, tC:generic_custom_properties#4, $FIELD_MEMBER_OF)
