xquery version "3.1" encoding "utf-8";

module namespace th = "transformationHelpers";


declare namespace map = "http://www.w3.org/2005/xpath-functions/map";

declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace fedora="info:fedora/fedora-system:def/relations-external#";
declare namespace fedora-model="info:fedora/fedora-system:def/model#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace islandora="http://islandora.ca/ontology/relsext#";


(: change from default as default character used in text and there doesn't appear to be a way to escape
https://mjordan.github.io/islandora_workbench_docs/configuration/#input-csv-file-settings :)
declare variable $th:WORKBENCH_SEPARATOR as xs:string := "^|.|^";

(::)
declare function th:extract_member_of($node as node()) as xs:string
{
    fn:substring-after($node/resource_metadata/rdf:RDF/rdf:Description/fedora:isMemberOfCollection/@rdf:resource/data(), "/")
};

(::)
declare function th:extract_parent_of_page($node as node()) as xs:string
{
    fn:substring-after($node/resource_metadata/rdf:RDF/rdf:Description/fedora:isMemberOf/@rdf:resource/data(), "/")
};


(::)
declare function th:get_parent_node($member_of as xs:string) as node()?
{
    collection()/metadata[@pid/data()=$member_of]
};

(: ToDo :)
(: specify collection as per https://mjordan.github.io/islandora_workbench_docs/paged_and_compound/#creating-collections-and-members-together :)
(: if the member_of is not found in the current collection  :)
declare function th:get_member_of($node as node(), $default as xs:string) as map(*)
{
    let $member_of := th:extract_member_of($node)
    let $page_of := th:extract_parent_of_page($node)
    
    return
        if (exists($page_of) and exists(collection()/metadata/@pid[data()=$page_of]) ) then
            map { 'parent_id' : $page_of, 'field_member_of' : "" }
        else if (exists($member_of) and exists(collection()/metadata/@pid[data()=$member_of]) ) then
            map { 'parent_id' : $member_of, 'field_member_of' : "" }
        else 
            map { 'parent_id' : "", 'field_member_of' : $default }
};

(: given a node, get a path string in the form of /1/2 where 1 and 2 are parents of the current node :)
declare function th:get_collection_path($node as node(), $path)
{
    let $member_of := th:extract_member_of($node)
    let $parent_node := th:get_parent_node($member_of)

    return
        if (exists($member_of) and $member_of != "" and exists($parent_node) )
        then
            th:get_collection_path(
                $parent_node,
                concat("/", $member_of, $path) 
                )
        else 
            $path
};

(: given a set, find all collection objects and return a mapping of the collection id and associated ancestor path :)
declare function th:get_collection_path_map() as map(*)
{
    map:merge(
        for $collection in collection()/metadata[resource_metadata/rdf:RDF/rdf:Description/fedora-model:hasModel/@rdf:resource/data() = "info:fedora/islandora:collectionCModel"]
        return
            map { th:get_id($collection) : th:get_collection_path($collection, concat("/", th:get_id($collection))) }
    )
};

(: given a node, test if is a collection cModel :)
declare function th:is_book_or_compound($uri as xs:string) as xs:boolean
{
    switch ($uri)
        case "info:fedora/islandora:bookCModel"       return true()
        case "info:fedora/islandora:compoundCModel"   return true()
        default                                       return false()
};

(: given a node, test if is a collection cModel :)
declare function th:is_collectionCModel($uri as xs:string) as xs:boolean
{
    switch ($uri)
        case "info:fedora/islandora:collectionCModel"       return true()
        default                                             return false()
};

(: Islandora Model type :)
(: ToDo: verify mapping; see missing cModels and Unknown return :)
(: Can use ID or taxonomy term 10 or "Audio" :)
declare function th:get_model_from_cModel($uri as xs:string, $id as xs:string) as xs:string
{
    switch ($uri)
        case "info:fedora/islandora:collectionCModel"       return "Collection"
        case "info:fedora/islandora:sp-audioCModel"         return "Audio"
        case "info:fedora/islandora:sp_basic_image"         return "Image"
        case "info:fedora/islandora:binaryObjectCModel"     return "Binary"
        case "info:fedora/islandora:bookCModel"             return "Paged Content"
        case "info:fedora/islandora:compoundCModel"         return "Compound Object"
        case "info:fedora/islandora:sp_large_image_cmodel"  return "Image"
        case "info:fedora/islandora:newspaperCModel"        return "Newspaper"
        case "info:fedora/islandora:newspaperIssueCModel"   return "Publication Issue"
        case "info:fedora/islandora:newspaperPageCModel"    return "Page"
        case "info:fedora/islandora:pageCModel"             return "Page"
        case "info:fedora/islandora:sp_pdf"                 return "Digital Document"
        case "info:fedora/islandora:sp_videoCModel"         return "Video"
        case "info:fedora/cwrc:citationCModel"              return "UNKNOWN"
        case "info:fedora/cwrc:documentCModel"              return "Digital Document"
        case "info:fedora/cwrc:dtocCModel"                  return "Digital Document"
        case "info:fedora/cwrc:documentTemplateCModel"      return "UNKNOWN"
        
        default
          return 
            fn:error(xs:QName('Resource_model'), concat('resource type field is missing: ', $id))
};

(: Islandora resource type :)
(: ToDo: verify mapping; see missing cModels and Unknown return :)
(: Can use ID or taxonomy term:)
declare function th:get_type_from_cModel($uri as xs:string, $id as xs:string) as xs:string
{
    switch ($uri)
        case "info:fedora/islandora:collectionCModel"       return "Collection"
        case "info:fedora/islandora:sp-audioCModel"         return "Sound"
        case "info:fedora/islandora:sp_basic_image"         return "Still Image"
        case "info:fedora/islandora:binaryObjectCModel"     return "UNKNOWN"
        case "info:fedora/islandora:bookCModel"             return "Collection"
        case "info:fedora/islandora:compoundCModel"         return "Collection"
        case "info:fedora/islandora:sp_large_image_cmodel"  return "Still Image"
        case "info:fedora/islandora:newspaperCModel"        return "Collection"
        case "info:fedora/islandora:newspaperIssueCModel"   return "Collection"
        case "info:fedora/islandora:newspaperPageCModel"    return "Text"
        case "info:fedora/islandora:pageCModel"             return "Text"
        case "info:fedora/islandora:sp_pdf"                 return "Text"
        case "info:fedora/islandora:sp_videoCModel"         return "Moving Image"
        case "info:fedora/cwrc:citationCModel"              return "UNKNOWN"
        case "info:fedora/cwrc:documentCModel"              return "Text"
         case "info:fedora/cwrc:dtocCModel"                 return "Text"
        case "info:fedora/cwrc:documentTemplateCModel"      return "UNKNOWN"
        
        default
          return 
            fn:error(xs:QName('Resource_type'), concat('resource type field is missing: ', $id))
};


(: ToDo: verify mapping :)
(: ToDo: map from cModel to the main file field for Workbench :)
declare function th:get_main_file_dsid_from_cModel($uri as xs:string, $id as xs:string) as item()*
{
    switch ($uri)
        case "info:fedora/islandora:collectionCModel"       return ("")
        case "info:fedora/islandora:sp-audioCModel"         return ("OBJ")
        case "info:fedora/islandora:bookCModel"             return ("OBJ","PDF","") (: ToDo: check if valid or if only "" necessary :)
        case "info:fedora/cwrc:documentCModel"              return ("CWRC")
        case "info:fedora/cwrc:dtocCModel"                  return ("DTOC")
        case "info:fedora/islandora:pageCModel"             return ("OBJ")
        case "info:fedora/islandora:sp_pdf"                 return ("OBJ")
        case "info:fedora/islandora:sp_videoCModel"         return ("OBJ") 
        case "info:fedora/islandora:sp_large_image_cmodel"  return ("OBJ")
        case "info:fedora/islandora:sp_basic_image"         return ("OBJ")
        case "info:fedora/islandora:sp-audioCModel"         return ("OBJ")
        case "info:fedora/cwrc:citationCModel"              return ("")
        default 
          return 
            fn:error(xs:QName('Main_file'), concat('Main file is missing: ', $id))
};

(: page of book sequence number :)
declare function th:get_page_sequence_number($node as node()) as xs:string
{
    let $page_num := $node/resource_metadata/rdf:RDF/rdf:Description/islandora:isSequenceNumber/text()
    return
        if (exists($page_num)) then
            $page_num
        else
            ""
};


(: map marcrelators text to term :)
(: https://www.loc.gov/marc/relators/relaterm.html :)
declare function th:get_marcrelator_term_from_text($role as xs:string) as xs:string
{
     switch ($role)
        case "Author"       return ("aut")
        case "Editor"       return ("edt")
        case ""             return ("")
        default 
          return 
            fn:error(xs:QName('marcrelator'), concat('Marcrelator mapping missing: [', $role, ']'))   
};

(::)
declare function th:get_main_file_name($metadata as node(), $ds_id_array as item()*, $id as xs:string) as item()*
{
    let $main_file := $metadata/media_exports/media[@ds_id/data() eq $ds_id_array[1]]/@filepath/data()
    return
        if (exists($main_file) or empty($ds_id_array)) then (
            $main_file
        )
        else (
            th:get_main_file_name($metadata, subsequence($ds_id_array,2), $id) 
        )
};

(: find the path to the main file; Todo: enhance for additional usecases where there is not a one-to-one mapping, if applicable :)
declare function th:get_main_file($metadata as node(), $cModel as xs:string, $id as xs:string) as xs:string
{
    (: assume a collection doesn't have an attached file :)
    switch ($cModel)
        case "info:fedora/islandora:collectionCModel"
            return ""
        case "info:fedora/cwrc:citationCModel"
            return ""
        default 
            return
                let $ds_id_array := th:get_main_file_dsid_from_cModel($cModel,$id)
                return
                if (not(exists($ds_id_array)) or empty($ds_id_array)) then (
                    fn:error(xs:QName('Main_file'), concat('Main file is dsid not found: ', $id))
                )
                else
                    let $main_file := th:get_main_file_name($metadata, $ds_id_array, $id) 
                    return
                        if (not(exists($main_file))) then (
                            (: ToDo: verify assmption that bookCModel may or may not contain a file datastream :)
                            if ($cModel = "info:fedora/islandora:bookCModel") then (
                                ""
                            )
                            else (
                                fn:error(xs:QName('main_filename'), concat('main file name required field is missing: ', $id))
                            )
                        )
                        else (
                            $main_file
                        )
};

(::)
declare function th:get_id($node as node()) as xs:string
{
    let $id := $node/@pid/data()
    return
      if (not(exists($id))) then (
        fn:error(xs:QName('ID'), 'ID is missing: ')
      )
      else (
        $id
      )
};

(::)
declare function th:get_cModel($node as node()) as xs:string
{
    let $cModel := $node/resource_metadata/rdf:RDF/rdf:Description/fedora-model:hasModel/@rdf:resource/data() 
    return
      if (not(exists($cModel))) then (
        fn:error(xs:QName('cModel'), concat('cModel required field is missing: ', th:get_id($node)))
      )
      else (
        $cModel
      )
};

(: mods/titleInfo[not @type] :)
declare function th:get_title($node as node(), $cModel as xs:string) as xs:string
{
    let $title := $node/resource_metadata/mods:mods/mods:titleInfo[not(@type)]/mods:title/text()
    return
      if (exists($title)) then
        $title
      else if ($cModel = "info:fedora/islandora:pageCModel") then 
        $node/@label/data()
      else
        fn:error(xs:QName('label'), concat('title/label required field is missing: ', th:get_id($node)))
};

(: mods/titleInfo[@type="translated" @xml:lang="[lang code]"] :)
(: TODO :)

(: mods/titleInfo[@type="alternative" or @type="abbreviated" or @type="uniform"] :)
declare function th:get_title_alt($node as node()) as xs:string
{
    string-join($node/resource_metadata/mods:mods/mods:titleInfo[@type="alternative" or @type="abbreviated" or @type="uniform"]/mods:title/text(), $th:WORKBENCH_SEPARATOR)
};

(: ToDo :)
(:
mods/name/namePart -- if roles absent
mods/name/namePart with mods/name/role = "author" or "aut"
mods/name/namePart with mods/name/role = "contributor" or "ctb"
mods/name/namePart with mods/name/role = [any other code or term in marcrelators]
mods/name/namePart with mods/name/role = [a term that is not in marcrelators]
:)

(: mods/typeOfResource :)
(: ToDo: reference instead of string? Or should this come from the cModel type? :)
(:
declare function th:get_resource_type ($node as node()) as xs:string
{
};
:)

(: mods/genre :)
(: ToDo: reference instead of string? :)
declare function th:get_genre($node as node()) as xs:string
{
    string-join($node/resource_metadata/mods:mods/mods:genre/text(), $th:WORKBENCH_SEPARATOR)
};


(: mods/originInfo/dateIssued :)
declare function th:get_date_issued($node as node()) as xs:string
{
    string-join($node/resource_metadata/mods:mods/mods:originInfo/mods:dateIssued/text(), $th:WORKBENCH_SEPARATOR)
};

(: mods/originInfo/dateCreated :)
declare function th:get_date_created($node as node()) as xs:string
{
    string-join($node/resource_metadata/mods:mods/mods:originInfo/mods:dateCreated/text(), $th:WORKBENCH_SEPARATOR)
};

(: mods/originInfo/dateValid :)
declare function th:get_date_valid($node as node()) as xs:string
{
    string-join($node/resource_metadata/mods:mods/mods:originInfo/mods:dateValid/text(), $th:WORKBENCH_SEPARATOR)
};

(: mods/originInfo/dateCaptured :)
declare function th:get_date_captured($node as node()) as xs:string
{
    string-join($node/resource_metadata/mods:mods/mods:originInfo/mods:dateValid/text(), $th:WORKBENCH_SEPARATOR)
};

(: mods/originInfo/dateModified :)
declare function th:get_date_modified($node as node()) as xs:string
{
    string-join($node/resource_metadata/mods:mods/mods:originInfo/mods:dateModified/text(), $th:WORKBENCH_SEPARATOR)
};

(: mods/originInfo/copyrightDate :)
declare function th:get_date_copyright($node as node()) as xs:string
{
    string-join($node/resource_metadata/mods:mods/mods:originInfo/mods:copyrightDate/text(), $th:WORKBENCH_SEPARATOR)
};

(: mods/originInfo/dateOther :)
declare function th:get_date_other($node as node()) as xs:string
{
    string-join($node/resource_metadata/mods:mods/mods:originInfo/mods:dateOther/text(), $th:WORKBENCH_SEPARATOR)
};

(: mods/originInfo/publisher :)
declare function th:get_publisher($node as node()) as xs:string
{
    string-join($node/resource_metadata/mods:mods/mods:originInfo/mods:publisher, $th:WORKBENCH_SEPARATOR)
};

(: mods/originInfo/place/placeTerm [with type="text" or no type] :)
(: mods/originInfo/place/placeTerm [with type="code" and authority="marccountry"] :)
declare function th:get_place_term($node as node()) as xs:string
{
    string-join($node/resource_metadata/mods:mods/mods:originInfo/mods:place/mods:placeTerm/text(), $th:WORKBENCH_SEPARATOR)
};

(: mods/originInfo/frequency :)
declare function th:get_frequency($node as node()) as xs:string
{
    string-join($node/resource_metadata/mods:mods/mods:originInfo/mods:frequency/text(), $th:WORKBENCH_SEPARATOR)
};

(: mods/originInfo/issuance :)
declare function th:get_issuance($node as node()) as xs:string
{
    string-join($node/resource_metadata/mods:mods/mods:originInfo/mods:issuance/text(), $th:WORKBENCH_SEPARATOR)
};

(: mods/originInfo/edition :)
declare function th:get_edition($node as node()) as xs:string
{
    string-join($node/resource_metadata/mods:mods/mods:originInfo/mods:edition/text(), $th:WORKBENCH_SEPARATOR)
};

(: mods/language :)
declare function th:get_langauge($node as node()) as xs:string
{
    string-join($node/resource_metadata/mods:mods/mods:language/mods:languageTerm/text(), $th:WORKBENCH_SEPARATOR)
};

(: mods/physicalDescription/form :)
declare function th:get_form($node as node()) as xs:string
{
    string-join($node/resource_metadata/mods:mods/mods:physicalDescription/text(), $th:WORKBENCH_SEPARATOR)
};

(: mods/physicalDescription/extent :)
declare function th:get_extent($node as node()) as xs:string
{
    string-join($node/resource_metadata/mods:mods/mods:extent/text(), $th:WORKBENCH_SEPARATOR)
};

(: mods/physicalDescription/internetMediaType :)
declare function th:get_internet_media_type($node as node()) as xs:string
{
    string-join($node/resource_metadata/mods:mods/mods:internetMediaType/text(), $th:WORKBENCH_SEPARATOR)
};

(: mods/physicalDescription/digitalOrigin :)
declare function th:get_digital_origin($node as node()) as xs:string
{
    string-join($node/resource_metadata/mods:mods/mods:digitalOrigin/text(), $th:WORKBENCH_SEPARATOR)
};

(: mods/physicalDescription/note :)
declare function th:get_physical_note($node as node()) as xs:string
{
    string-join($node/resource_metadata/mods:mods/mods:physicalDescription/mods:note/text(), $th:WORKBENCH_SEPARATOR)
};

(: mods/physicalDescription/reformattingQuality :)
declare function th:get_reformatting_quality($node as node()) as xs:string
{
    string-join($node/resource_metadata/mods:mods/mods:reformattingQuality/text(), $th:WORKBENCH_SEPARATOR)
};

(: abstract :)
(: mods/abstract :)
declare function th:get_abstract($node as node()) as xs:string
{
    string-join($node/resource_metadata/mods:mods/mods:abstract/text(), $th:WORKBENCH_SEPARATOR)
};

(: tableOfContents :)
(: mods/tableOfContents :)
declare function th:get_table_of_contents($node as node()) as xs:string
{
    string-join($node/resource_metadata/mods:mods/mods:tableOfContents/text(), $th:WORKBENCH_SEPARATOR)
};

(: targetAudience :)
(: mods/targetAudience :)
declare function th:get_target_audience($node as node()) as xs:string
{
    string-join($node/resource_metadata/mods:mods/mods:targetAudience/text(), $th:WORKBENCH_SEPARATOR)
};

(: note :)
(: mods/note [concat( @displayLabel or @type, ": ", text())] :)
declare function th:get_note($node as node()) as xs:string
{
    let $notes :=
        for $i in $node/resource_metadata/mods:mods/mods:note
        let $label := 
            if ($i/@displayLabel) then (
                concat($i/@displayLabel, ": ")
            )
            else if ($i/@type) then (
                concat($i/@type, ": ")
            )
            else ""
        return
            concat( $label, $i/text() )
    return
        string-join($notes, $th:WORKBENCH_SEPARATOR)
};

(: subject :)
declare function th:get_geographic_subjects($node as node()) as xs:string
{
    string-join(
        $node/resource_metadata/mods:mods/mods:subject/mods:geographic/text() |
        $node/resource_metadata/mods:mods/mods:subject/mods:geographicCode/text() |
        $node/resource_metadata/mods:mods/mods:subject/mods:hierarchicalGeographic/text(),

        $th:WORKBENCH_SEPARATOR)
};

(: mods/subject/geographic :)
declare function th:get_subject_geographic($node as node()) as xs:string
{
    string-join($node/resource_metadata/mods:mods/mods:subject/mods:geographic/text(), $th:WORKBENCH_SEPARATOR)
};

(: mods/subject/cartographic/coordinates :)
declare function th:get_subject_cartographic_coordinates($node as node()) as xs:string
{
    string-join($node/resource_metadata/mods:mods/mods:subject/mods:cartographic/mods:coordinates/text(), $th:WORKBENCH_SEPARATOR)
};

(: mods/subject/geographicCode :)
declare function th:get_subject_geographic_code($node as node()) as xs:string
{
    string-join($node/resource_metadata/mods:mods/mods:subject/mods:geographicCode/text(), $th:WORKBENCH_SEPARATOR)
};

(: mods/subject/hierarchicalGeographic :)
declare function th:get_subject_hierarchical_geographic($node as node()) as xs:string
{
    string-join($node/resource_metadata/mods:mods/mods:subject/mods:hierarchicalGeographic/text(), $th:WORKBENCH_SEPARATOR)
};

(: mods/subject/topic :)
declare function th:get_subject_topic($node as node()) as xs:string
{
    let $list :=
        for $item in $node/resource_metadata/mods:mods/mods:subject/mods:topic/text()
        return concat("subject:", $item)
    return
        string-join($list, $th:WORKBENCH_SEPARATOR)
};

(: mods/subject/temporal :)
(: needs to handle both a text plus a point="begin" and point="end" :)
declare function th:get_subject_temporal($node as node()) as xs:string
{
    let $list :=
        $node/resource_metadata/mods:mods/mods:subject/mods:temporal
    return 
        if (exists($list[not(exists(@point))]))  then (
            string-join($list/text(), $th:WORKBENCH_SEPARATOR)
        )
        else if  ($list[@point] and not($list[not(exists(@point))]))  then (
            (: todo: verify assumtion order of point="begin" and point="end" in docs :)
            string-join($list/text(), $th:ETDF_RANGE_SEPARATOR)
        )
        else if (not(exists($list))) then (
            ""
        )
        else (
            fn:error(xs:QName('subject_temporal'), concat('subject temporal combination not handled - report bug: ', th:get_id($node)))
        )
};

(: mods/subject/name :)
declare function th:get_subject_name($node as node()) as xs:string
{
    string-join($node/resource_metadata/mods:mods/mods:subject/mods:name/text(), $th:WORKBENCH_SEPARATOR)
};

(: mods/subject/occupation :)
declare function th:get_subject_occupation($node as node()) as xs:string
{
    string-join($node/resource_metadata/mods:mods/mods:subject/mods:name/text(), $th:WORKBENCH_SEPARATOR)
};

(: classification :)
(: mods/classification[@authority="lcc"] :)
declare function th:get_classification_lcc($node as node()) as xs:string
{
    string-join($node/resource_metadata/mods:mods/mods:classification[@authority='lcc']/text(), $th:WORKBENCH_SEPARATOR)
};

(: mods/classification[@authority="ddc"] :)
declare function th:get_classification_ddc($node as node()) as xs:string
{
    string-join($node/resource_metadata/mods:mods/mods:classification[@authority='ddc']/text(), $th:WORKBENCH_SEPARATOR)
};

(: mods/classification :)
declare function th:get_classification_other($node as node()) as xs:string
{
    string-join($node/resource_metadata/mods:mods/mods:classification[not(@authority=['lcc','ddc'])]/text(), $th:WORKBENCH_SEPARATOR)
};

(: Todo: :)
(: relatedItem :)
(: mods/relatedItem succeeding :)
(: mods/relatedItem preceding :)
(: mods/relatedItem original :)
(: mods/relatedItem constituent :)
(: mods/relatedItem series :)
(: mods/relatedItem otherVersion :)
(: mods/relatedItem otherFormat :)
(: mods/relatedItem isReferencedBy :)
(: mods/relatedItem references :)
(: mods/relatedItem reviewOf :)
(: mods/relatedItem host (see below under part!) :)
(: mods/relatedItem[@type="host"]/titleInfo/title :)
(: mods/relatedItem[@type="host"]/titleInfo[@type="abbreviated"]/title :)
(: mods/relatedItem[@type="host"]/originInfo/issuance :)
(: mods/relatedItem[@type="host"]/genre :)
(: mods/relatedItem[@type="host"]/identifier[@type="issn"] :)
(: mods/relatedItem[@type="host"]/identifier[@type="serial number"] :)
(: mods/relatedItem[@type="host"]/name[@type='corporate' and role/roleTerm="author"]/mods:namePart[not(@type)] :)

(: identifier :)
(: mods/identifier (no type, or any type but ISBN, OCLC, local, ...etc.) :)
declare function th:get_idenifier($node as node()) as xs:string
{
    string-join($node/resource_metadata/mods:mods/mods:identifier[not(@type=['ISBN','OCLC','local'])]/text(), $th:WORKBENCH_SEPARATOR)
};


(: mods/identifier type="ISBN" :)
declare function th:get_identifier_ISBN($node as node()) as xs:string
{
    string-join($node/resource_metadata/mods:mods/mods:identifier[@type=['ISBN']]/text(), $th:WORKBENCH_SEPARATOR)
};

(: mods/identifier type="OCLC" :)
declare function th:get_identifier_OCLC($node as node()) as xs:string
{
    string-join($node/resource_metadata/mods:mods/mods:identifier[@type=['OCLC']]/text(), $th:WORKBENCH_SEPARATOR)
};

(: mods/identifier type="local" :)
declare function th:get_identifier_local($node as node()) as xs:string
{
    string-join($node/resource_metadata/mods:mods/mods:identifier[@type=['local']]/text(), $th:WORKBENCH_SEPARATOR)
};

(: ToDo: :)
(: location :)
(: mods/location :)
(: mods/location/url :)
(: mods/location/physicalLocation[not @authority] :)
(: mods/location/physicalLocation[@authority = "marcorg" OR @authority="oclcorg"] :)
(: mods/location/shelfLocator :)
(: mods/location/holdingSimple/copyInformation :)
(: mods/location/holdingExternal :)

(: accessCondition :)
(: mods/accessCondition :)
declare function th:get_access_condition($node as node()) as xs:string
{
    let $accessConditionList :=
        for $a in $node/resource_metadata/mods:mods/mods:accessCondition
        return string-join($a/descendant-or-self::*/text(),'')
    return
        string-join($accessConditionList, $th:WORKBENCH_SEPARATOR)
};

(: ToDo: :)
(: part :)
(: mods/part/detail/title :)
(: mods/part/date :)
(: mods/part/detail[@type="volume"]/number :)
(: mods/part/detail[@type="issue"]/number :)
(: mods/part/extent[@unit="page"]/start :)
(: mods/part/extent[@unit="page"]/end :)

(: ToDo: :)
(: extension :)
(: mods/extension :)

(: ToDo: :)
(: recordInfo :)
