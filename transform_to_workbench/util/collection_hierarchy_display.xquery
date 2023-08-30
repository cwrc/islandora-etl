xquery version "3.1" encoding "utf-8";

import module namespace tHelper="transformationHelpers" at "../islandora7_to_workbench_utils.xquery";

(: Get all collections and their path (i.e., anscestors) :)

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
    
    (: enhance speed by creating a map of collection paths outside of object loop :)
    let $collection_path_map := tHelper:get_collection_path_map()  
    let $book_map := tHelper:get_book_map()  
    
    for $metadata in /metadata[
      @models/data() ="['islandora:collectionCModel', 'fedora-system:FedoraObject-3.0']"
      (: and @pid/data() = ["tpatt:56e23894-4720-4d89-a710-b4222870d783"] :)
    ]
   
    let $cModel := tHelper:get_cModel($metadata)
    let $id := tHelper:get_id($metadata)
    let $title := tHelper:get_title($metadata, $cModel)
    let $field_model := tHelper:get_model_from_cModel($cModel,$id)
    let $field_resource_type := tHelper:get_type_from_cModel($cModel,$id)
   
    
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
            <parent_id__if_not_found_zzzzzzz>{map:get($member_of,"parent_id")}</parent_id__if_not_found_zzzzzzz>
            <parent_collection>{tHelper:extract_member_of($metadata)}</parent_collection>
            <parent_of_page>{tHelper:extract_parent_of_page($metadata)}</parent_of_page>
            <collection_path>{$collection_path}</collection_path>
            <field_model>{$field_model}</field_model>
            <field_resource_type>{$field_resource_type}</field_resource_type>

        </record>

        (: :)      
  }
</csv>