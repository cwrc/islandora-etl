xquery version "3.1" encoding "utf-8";

(: A generic / base xquery to produce input for Islandora workbench :) 
(:
  * cleanup after 2023-08-10
    * cleanup orphaned pages & record
      * grep -v 'missing parent;' tpatt_test_cwrc.cw_all_2022-07-14_sort_unique_part_15.csv > tpatt_test_cwrc.ca_all_2022-07-14_sort_unique_part_15_no_orphans.csv
    * cleanup member_of (e.g., find collections that are not in the current set and change to Drupal node Id
      * a default, assumed drupal node id is added if the member_of PID from islandora7 is not in the dataset
:)

import module namespace tH="transformationHelpers" at "islandora7_to_workbench_utils.xquery";
import module namespace tC="transformationCommon" at "islandora7_to_workbench_common.xquery";

declare namespace map = "http://www.w3.org/2005/xpath-functions/map";

declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace oai_dc = "http://www.openarchives.org/OAI/2.0/oai_dc/";
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


(: set to be the default Drupal node id of the collection to attach the ingested item/collection to if no parent :)
declare variable $FIELD_MEMBER_OF external := "zzzzzz";


(: MAIN :)

<csv>
  {
    (: BaseX CSV serialization doesn't generate a header that matches a variable number of columns (nor does it generate empty columns for rows with empty cell). The workaround:  retrieve the full list of associated files (datastreams) of all items in the collection and then add items (empty or full so there is no varibility) :)
    (: let $file_list := distinct-values(/metadata[not(@models = $tHelper:UNSUPPORTED_MODELS)]/media_exports/media/@ds_id/data()) :)
    let $file_list := tH:get_list_of_possible_files()
    
    (: enhance speed by creating a map of collection paths outside of object loop :)
    let $collection_path_map := tH:get_collection_path_map()  
    let $book_map := tH:get_book_map()  
    
    for $metadata in /metadata[
      not(@models = $tH:UNSUPPORTED_MODELS)
      and contains(@pid/data(), "tpatt")
      and not(@pid/data() = 
        [
          "tpatt:e6e1e1d0-a4e6-4ded-9356-0441f9fcba3f",
          "tpatt:f996dd38-add2-4dd9-80c5-f231f63b7e4d",
          "tpatt:51aa7a57-a231-4339-a18c-7c0a766cf2c0",
          "tpatt:af58fff1-3a92-4be6-aecb-0238309ceaf1"
       ])
      (: and @pid/data() = ["tpatt:56e23894-4720-4d89-a710-b4222870d783"] :)
    ]

    (: base variables :) 
    let $cModel := tH:get_cModel($metadata)
    let $id := tH:get_id($metadata)
    let $title := tH:get_title($metadata, $cModel)
    let $field_model := tH:get_model_from_cModel($cModel,$id)
    let $field_resource_type := tH:get_type_from_cModel($cModel,$id)
    let $main_file := $metadata/media_exports/media[@ds_id/data() = tH:get_main_file_dsid_from_cModel($cModel,$id)]/@filepath/data()
    
    (: Commom properties :)
    let $properties := tC:common_columns($metadata, $cModel, $id)
        
    (: a list of all associated files with the object -- don't exclude the main file used as Drupal media original file :)
    let $possible_associated_files := $file_list
    
    (: list collections at the top of the CSV followed by book/compound :)
    (: :)
    (: let $member_of := tH:get_member_of($metadata, $FIELD_MEMBER_OF) :)
    let $member_of := tH:get_member_of_cached_collections($metadata, $collection_path_map, $book_map, $FIELD_MEMBER_OF) 
    let $collection_path := map:get($collection_path_map, $id)
    let $is_collection := tH:is_collectionCModel($cModel)
    let $is_book_or_compound := tH:is_book_or_compound($cModel)

        (: list collections at the top of the CSV (based on hierarchy/path of collection) followed by book/compound :)
    order by $is_collection descending, $is_book_or_compound descending, $collection_path

    



    return
        <record>
            <id>{$id}</id>
            <title>{$title}</title>
            <field_member_of>{map:get($member_of,"field_member_of")}</field_member_of>
            <parent_id>{map:get($member_of,"parent_id")}</parent_id>
            <multiple_parent_collections>{tH:extract_member_of($metadata)}</multiple_parent_collections>
            <parent_of_page>{tH:extract_parent_of_page($metadata)}</parent_of_page>
            <collection_path>{$collection_path}</collection_path>
            <field_model>{$field_model}</field_model>
            <field_resource_type>{$field_resource_type}</field_resource_type>
            <file>{$main_file}</file>
            { tH:build_associated_files($possible_associated_files, $metadata, [$main_file]) }
            { tC:common_columns($properties) }

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

        (: :)      
  }
</csv>
