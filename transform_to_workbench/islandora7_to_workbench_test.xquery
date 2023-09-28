xquery version "3.1" encoding "utf-8";

import module namespace tHelper="transformationHelpers" at "islandora7_to_workbench_utils.xquery";

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
    let $file_list := tHelper:get_list_of_possible_files()
    
    (: enhance speed by creating a map of collection paths outside of object loop :)
    let $collection_path_map := tHelper:get_collection_path_map()  
    let $book_map := tHelper:get_book_map()  
    
    for $metadata in /metadata[
      not(@models = $tHelper:UNSUPPORTED_MODELS)
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
   
    let $cModel := tHelper:get_cModel($metadata)
    let $id := tHelper:get_id($metadata)
    let $title := tHelper:get_title($metadata, $cModel)
    let $field_model := tHelper:get_model_from_cModel($cModel,$id)
    let $field_resource_type := tHelper:get_type_from_cModel($cModel,$id)
    let $main_file := $metadata/media_exports/media[@ds_id/data() = tHelper:get_main_file_dsid_from_cModel($cModel,$id)]/@filepath/data()
    
    (: a list of all associated files with the object -- don't exclude the main file used as Drupal media original file :)
    let $possible_associated_files := $file_list
    
    
    (: list collections at the top of the CSV followed by book/compound :)
    (: :)
    (: let $member_of := tHelper:get_member_of($metadata, $FIELD_MEMBER_OF) :)
    let $member_of := tHelper:get_member_of_cached_collections($metadata, $collection_path_map, $book_map, $FIELD_MEMBER_OF) 
    let $collection_path := map:get($collection_path_map, $id)
    let $is_collection := tHelper:is_collectionCModel($cModel)
    let $is_book_or_compound := tHelper:is_book_or_compound($cModel)
    order by $is_collection descending, $is_book_or_compound descending, $collection_path

    return
        <record>
            <id>{$id}</id>
            <title>{$title}</title>
            <field_member_of>{map:get($member_of,"field_member_of")}</field_member_of>
            <parent_id>{map:get($member_of,"parent_id")}</parent_id>
            <multiple_parent_collections>{tHelper:extract_member_of($metadata)}</multiple_parent_collections>
            <parent_of_page>{tHelper:extract_parent_of_page($metadata)}</parent_of_page>
            <collection_path>{$collection_path}</collection_path>
            <field_model>{$field_model}</field_model>
             <field_resource_type>{$field_resource_type}</field_resource_type>
            <file>{$main_file}</file>
            { tHelper:build_associated_files($possible_associated_files, $metadata, [$main_file]) }
        </record>

        (: :)      
  }
</csv>
