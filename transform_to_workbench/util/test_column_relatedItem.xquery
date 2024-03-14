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
    <field_title_full>{tH:get_title_full($metadata,"")}</field_title_full>,
    :)
    (
        <field_title_trunc>{tH:get_title_255_characters($metadata,"")}</field_title_trunc>,

        <general>{tH:get_related_item_idenifier($metadata)}</general>,
        <doi>{tH:get_related_item_idenifier_doi($metadata)}</doi>,
        <isbn>{tH:get_related_item_idenifier_isbn($metadata)}</isbn>,
        <issn>{tH:get_related_item_idenifier_issn($metadata)}</issn>,
        <field_related_item_place_publish>{tH:get_related_item_place_published($metadata)}</field_related_item_place_publish>,
        <field_related_item_type>{tH:get_related_item_type($metadata)}</field_related_item_type>,
        <field_related_item_boolean>{tH:get_related_item_place_boolean($metadata)}</field_related_item_boolean>,
        <field_related_item_title>{tH:get_related_item_title($metadata)}</field_related_item_title>,
        <field_related_item_title_full>{tH:get_related_item_title_full($metadata)}</field_related_item_title_full>,
        <field_related_item_alternative_t>{tH:get_related_item_title_alt($metadata)}</field_related_item_alternative_t>,
        <field_related_item_date_created>{tH:get_related_item_date_created($metadata)}</field_related_item_date_created>,
        <field_related_item_date_issued>{tH:get_related_item_date_issued($metadata)}</field_related_item_date_issued>,
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
            resource_metadata/mods:mods/mods:relatedItem//mods:identifier/text()
            or
            resource_metadata/mods:mods/mods:relatedItem/mods:originInfo/mods:place
            or
            resource_metadata/mods:mods/mods:relatedItem/mods:titleInfo/mods:title
            or
            resource_metadata/mods:mods/mods:relatedItem[@type]
            or
            resource_metadata/mods:mods/mods:relatedItem//mods:dateIssued
            or
            resource_metadata/mods:mods/mods:relatedItem//mods:dateCreated
            or
            resource_metadata/mods:mods/mods:relatedItem/mods:titleInfo/mods:subTitle
            or
            resource_metadata/mods:mods/mods:titleInfo/mods:subTitle
            :)
            resource_metadata/mods:mods/mods:titleInfo[(not(@*) or @usage/data()='primary')]/mods:title[string-length(normalize-space(string-join(.//text(),"")))>255]
          )
          and
          resource_metadata/mods:mods/mods:titleInfo/mods:title (: some items don't have a title, remove from test for now :)
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
      'cwrc:4b9f29d1-1175-4a5d-a940-36fe3f2c1000', (: cmodel missing :)
      'islandora:6f716484-f9e1-4397-a80e-e1094d608e8c',
      'islandora:a6baa954-d970-48d9-8f9b-47e4985d2095',
      'orlando:26123127-c104-4cf3-bdb6-481cc096ed7f',
      'orlando:3b3899b1-3a76-4316-b27a-1a9076d53071',
      'orlando:6aa3ed44-fb97-4c96-a1a7-f3260e512676',
      'tpatt:f996dd38-add2-4dd9-80c5-f231f63b7e4d',
      'orlando:12eee6fb-61bd-4206-b61a-429d408df490'
    ])
    ]

(: Create a local:generic_custom_function to create custom, non-generic fields specific to a given project such as "linked agent" :)
(: The `#2` in the function: the digit represents the number of arguments of your function (otherwise get an empty-sequence error). :)
return tC:output_csv_test_min($items, local:generic_custom_function#1, tC:generic_custom_properties#4, $FIELD_MEMBER_OF)
