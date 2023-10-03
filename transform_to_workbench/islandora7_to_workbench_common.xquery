xquery version "3.1" encoding "utf-8";

(: Common parts of a transform :)

module namespace tc = "transformationCommon";

import module namespace tH="transformationHelpers" at "islandora7_to_workbench_utils.xquery";

(: Propertier are mapped to CSV columns:)
declare function tc:common_columns($metadata as node(), $cModel as xs:string, $id as xs:string) as map(*)
{
    map {
        (: optional fields :)
        "url_alias" : concat("/islandora/object/", $id),
        "langcode" : tH:get_langcode($metadata),

        "field_alternative_title" : tH:get_title_alt($metadata),
        "field_classification" : tH:get_classification_other($metadata),
        "field_coordinates" : tH:get_subject_cartographic_coordinates($metadata),
        "field_coordinates_text" : tH:get_subject_cartographic_coordinates($metadata),
        (:ToDo: what is the difference between field_description and field_description_long :)
        "field_description" : tH:get_physical_note($metadata),
        "field_description_long" : tH:get_physical_note($metadata),
        "field_dewey_classification" : tH:get_classification_ddc($metadata),
        (: let $field_display_hints := :)
        (: let $field_display_title := :)
        "field_edition" : tH:get_edition($metadata),
        "field_edtf_date" : tH:get_date_other($metadata),
        "field_edtf_date_created" : tH:get_date_created($metadata),
        "field_edtf_date_issued" : tH:get_date_issued($metadata),
        "field_extent" : tH:get_extent($metadata),
        "field_genre" : tH:get_genre($metadata),
        "field_geographic_subject" : tH:get_geographic_subjects($metadata),
        "field_identifier" : tH:get_idenifier($metadata),
        "field_isbn" : tH:get_identifier_ISBN($metadata),
        "field_language" : tH:get_langauge($metadata),
        "field_lcc_classification" : tH:get_classification_lcc($metadata),
        (: let $field_linked_agent := :)
        "field_local_identifier" : tH:get_identifier_local($metadata),
        (: let $field_main_banner := :)
        "field_note" : tH:get_note($metadata),
        "field_oclc_number" : tH:get_identifier_OCLC($metadata),
        "field_physical_form" : tH:get_form($metadata),
        "field_pid" : tH:get_id($metadata),
        "field_place_published" : tH:get_place_term($metadata),
        "field_rights" : tH:get_access_condition($metadata),
        "field_subject" : tH:get_subject_topic($metadata),
        "field_subjects_name" : tH:get_subject_name($metadata),
        "field_table_of_contents" : tH:get_table_of_contents($metadata),
        "field_temporal_subject" : tH:get_subject_temporal($metadata),
        (: let $field_weight := :)
        "field_weight" : tH:get_page_sequence_number($metadata)
    }

};

declare function tc:common_columns($properties as map(*)) as element()*
{
    for $key in map:keys($properties)
    order by $key
    return
        element {$key} {map:get($properties, $key)}

    (:
        <field_alternative_title>{$title_alt}</field_alternative_title>

        <field_weight>{$page_sequence_number}</field_weight>
        <url_alias>/islandora/object/{$id}</url_alias>

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
    :)
};
