xquery version "3.1" encoding "utf-8";

import module namespace tH="transformationHelpers" at "islandora7_to_workbench_utils.xquery";

declare namespace map = "http://www.w3.org/2005/xpath-functions/map";

declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace fedora="info:fedora/fedora-system:def/relations-external#";
declare namespace fedora-model="info:fedora/fedora-system:def/model#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:encoding "UTF-8";

(: Uncomment to output as XML for the use case a XML to CSV conversion such as OxygenXML :)
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


(: MAIN :)

(: enhance speed by creating a map of collection paths outside of object loop :)
let $collection_path_map := tH:get_collection_path_map()

return
<csv>
  {

    for $metadata in /metadata
   
    let $cModel := tH:get_cModel($metadata)
    let $is_collection := tH:is_collectionCModel($cModel)
    let $id := tH:get_id($metadata)
    let $member_of := tH:get_member_of($metadata, $FIELD_MEMBER_OF)
    let $collection_path := map:get($collection_path_map, $id)
    let $title := tH:get_title($metadata, $cModel)
    let $title_alt :=  tH:get_title_alt($metadata)
    let $field_model := tH:get_model_from_cModel($cModel, $id)
    let $field_resource_type := tH:get_type_from_cModel($cModel, $id)
    let $langcode := tH:get_langauge($metadata)

    let $field_classification := tH:get_classification_other($metadata)
    let $field_coordinates := tH:get_subject_cartographic_coordinates($metadata)
    let $field_coordinates_text := tH:get_subject_cartographic_coordinates($metadata)
    (:ToDo: what is the difference between field_description and field_description_long :)
    let $field_description := tH:get_physical_note($metadata)
    let $field_description_long := tH:get_physical_note($metadata)
    let $field_dewey_classification := tH:get_classification_ddc($metadata)
    (: let $field_display_hints := :)
    (: let $field_display_title := :)
    let $field_edition := tH:get_edition($metadata)
    let $field_edtf_date := tH:get_date_other($metadata)
    let $field_edtf_date_created := tH:get_date_created($metadata)
    let $field_edtf_date_issued := tH:get_date_issued($metadata)
    let $field_extent := tH:get_extent($metadata)
    let $field_genre := tH:get_genre($metadata)
    let $field_geographic_subject := tH:get_geographic_subjects($metadata)
    let $field_identifier := tH:get_idenifier($metadata)
    let $field_isbn := tH:get_identifier_ISBN($metadata)
    let $field_language := tH:get_langauge($metadata)
    let $field_lcc_classification := tH:get_classification_lcc($metadata)
    (: let $field_linked_agent := :)
    let $field_local_identifier := tH:get_identifier_local($metadata)
    (: let $field_main_banner := :)
    let $field_note := tH:get_note($metadata)
    let $field_oclc_number := tH:get_identifier_OCLC($metadata)
    let $field_physical_form := tH:get_form($metadata)
    let $field_pid := tH:get_id($metadata)
    let $field_place_published := tH:get_place_term($metadata)
    let $field_rights := tH:get_access_condition($metadata)
    let $field_subject := tH:get_subject_topic($metadata)
    let $field_subjects_name := tH:get_subject_name($metadata)
    let $field_table_of_contents := tH:get_table_of_contents($metadata)
    let $field_temporal_subject := tH:get_subject_temporal($metadata)
    (: let $field_weight := :)

    let $main_file := tH:get_main_file($metadata, $cModel, $id)
    let $associated_files := $metadata/media_exports/media[@filepath/data() != $main_file or not(exists($main_file))]

    (: list collections at the top of the CSV:)
    order by $is_collection descending, map:get($member_of,"parent_id"), $collection_path

    return
        <record>
            <id>{$id}</id>
            <parent_id>{map:get($member_of,"parent_id")}</parent_id>
            <field_member_of>{map:get($member_of,"field_member_of")}</field_member_of>
            <url_alias>/islandora/object/{$id}</url_alias>
            <title>{$title}</title>
            <field_alternative_title>{$title_alt}</field_alternative_title>
            <field_model>{$field_model}</field_model>
            <field_resource_type>{$field_resource_type}</field_resource_type>

            <langcode></langcode>

            <field_classification>{$field_classification}</field_classification>
            <field_coordinates>{$field_coordinates}</field_coordinates>
            <field_coordinates_text>{$field_coordinates_text}</field_coordinates_text>
            <field_description>{$field_description}</field_description>
            <field_description_long>{$field_description_long}</field_description_long>
            <field_dewey_classification>{$field_dewey_classification}</field_dewey_classification>
            <field_display_hints></field_display_hints>
            <field_display_title></field_display_title>
            <field_edition>{$field_edition}</field_edition>
            <field_edtf_date>{$field_edtf_date}</field_edtf_date>
            <field_edtf_date_created>{$field_edtf_date_created}</field_edtf_date_created>
            <field_edtf_date_issued>{$field_edtf_date_issued}</field_edtf_date_issued>
            <field_extent>{$field_extent}</field_extent>
            <field_genre>{$field_genre}</field_genre>
            <field_geographic_subject>{$field_geographic_subject}</field_geographic_subject>
            <field_identifier>{$field_identifier}</field_identifier>
            <field_isbn>{$field_isbn}</field_isbn>
            <field_language>{$field_language}</field_language>
            <field_lcc_classification>{$field_lcc_classification}</field_lcc_classification>
            <field_local_identifier>{$field_local_identifier}</field_local_identifier>
            <field_main_banner></field_main_banner>
            <field_note>{$field_note}</field_note>
            <field_oclc_number>{$field_oclc_number}</field_oclc_number>
            <field_physical_form>{$field_physical_form}</field_physical_form>
            <field_pid>{$field_pid}</field_pid>
            <field_place_published>{$field_place_published}</field_place_published>
            <field_rights>{$field_rights}</field_rights>
            <field_subject>{$field_subject}</field_subject>
            <field_subjects_name>{$field_subjects_name}</field_subjects_name>
            <field_table_of_contents>{$field_table_of_contents}</field_table_of_contents>
            <field_temporal_subject>{$field_temporal_subject}</field_temporal_subject>
            <field_weight></field_weight>

            <file>{$main_file}</file>

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
                  concat($separator, 'relators:', $role, ":person:", string-join($mods_name/mods:namePart/text(), " ") )
                 
            }
            </field_linked_agent>
        </record>
  }
</csv>
