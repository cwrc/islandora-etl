xquery version "3.1" encoding "utf-8";

(: Test MODS name handling:
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
            concat($separator, 'relators:', $role, ":person:", string-join($mods_name/mods:namePart/text(), " ") )

    }
    </field_linked_agent>
};


(: MAIN :)

<csv>
  {

    (: enhance speed by creating a map of collection paths outside of object loop :)
    let $collection_path_map := tH:get_collection_path_map()
    let $book_map := tH:get_book_map()

    for $metadata in /metadata[
      not(@models = $tH:UNSUPPORTED_MODELS)
      and resource_metadata/mods:mods/mods:name
      and contains(@pid/data(), "tpatt")
    ]

    (: base variables :)
    let $cModel := tH:get_cModel($metadata)
    let $id := tH:get_id($metadata)
    let $title := tH:get_title($metadata, $cModel)

    (: list collections at the top of the CSV followed by book/compound :)
    (: :)
    (: let $member_of := tH:get_member_of($metadata, $FIELD_MEMBER_OF) :)
    let $member_of := tH:get_member_of_cached_collections($metadata, $collection_path_map, $book_map, $FIELD_MEMBER_OF)
    let $collection_path := map:get($collection_path_map, $id)
    let $is_collection := tH:is_collectionCModel($cModel)
    let $is_book_or_compound := tH:is_book_or_compound($cModel)

    (: list collections at the top of the CSV (based on hierarchy/path of collection) followed by book/compound :)
    order by $is_collection descending, $is_book_or_compound descending, $collection_path, map:get($member_of,"field_member_of"), tH:extract_parent_of_page($metadata)

    return
        <record>
            <id>{$id}</id>
            <field_member_of>{map:get($member_of,"field_member_of")}</field_member_of>
            <parent_id>{map:get($member_of,"parent_id")}</parent_id>
            <multiple_parent_collections>{tH:extract_member_of($metadata)}</multiple_parent_collections>
            <parent_of_page>{tH:extract_parent_of_page($metadata)}</parent_of_page>
            <collection_path>{$collection_path}</collection_path>
            <title>{$title}</title>
            {local:generic_custom_function($metadata)}
        </record>

        (: :)
  }
</csv>
