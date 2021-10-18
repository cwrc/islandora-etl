xquery version "3.1" encoding "utf-8";

import module namespace tHelper="transformationHelpers" at "islandora7_to_workbench_utils.xquery";

declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace fedora="info:fedora/fedora-system:def/relations-external#";
declare namespace fedora-model="info:fedora/fedora-system:def/model#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:encoding "UTF-8";

(:
declare namespace saxon="http://saxon.sf.net/";
declare option output:method    "xml";
declare option output:indent    "yes";
declare option saxon:output     "method=xml";

:)

declare option output:method "csv";
declare option output:csv "header=yes, separator=comma";
(: :)


declare variable $FIELD_MEMBER_OF external := "1";


(: MAIN :)

<csv>
  {

    for $metadata in /metadata
   
    let $cModel := tHelper:get_cModel($metadata)
    let $id := tHelper:get_id($metadata)
    let $title := $metadata/resource_metadata/mods:mods/mods:titleInfo/mods:title/text()
    let $field_model := tHelper:get_model_from_cModel($cModel)
    let $field_resource_type := tHelper:get_type_from_cModel($cModel)
    let $main_file := $metadata/media_exports/media[@ds_id/data() eq tHelper:get_main_file_from_cModel($cModel)]/@filepath/data()
    let $associated_files := $metadata/media_exports/media[@filepath/data() != $main_file or not(exists($main_file))]

    return
        <record>
            <id>{$id}</id>
            <url_alias>/islandora/object/{$id}</url_alias>
            <title>{$title}</title>
            <field_member_of>{$FIELD_MEMBER_OF}</field_member_of>
            <field_model>{$field_model}</field_model>
            <field_resource_type>{$field_resource_type}</field_resource_type>
        </record>
      
  }
</csv>
