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

(: https://www.loc.gov/standards/datetime/ :)
declare variable $th:EDTF_RANGE_SEPARATOR as xs:string := "/";

declare variable $th:UNSUPPORTED_MODELS := (
      "['cwrc:place-entityCModel', 'fedora-system:FedoraObject-3.0']",
      "['cwrc:person-entityCModel', 'fedora-system:FedoraObject-3.0']",
      "['cwrc:title-entityCModel', 'fedora-system:FedoraObject-3.0']",
      "['cwrc:organization-entityCModel', 'fedora-system:FedoraObject-3.0']",
      "['cwrc:documentTemplateCModel', 'fedora-system:FedoraObject-3.0']",
      "['cwrc:schemaCModel', 'fedora-system:FedoraObject-3.0']"
    );

(::)
declare function th:extract_member_of($node as node()) as xs:string*
{
    let $list :=
        for $item in $node/resource_metadata/rdf:RDF/rdf:Description/fedora:isMemberOfCollection/@rdf:resource/data()
        return fn:substring-after($item, "/")
    return
        if (exists($list)) then
            $list
        else
            ()
};

(::)
declare function th:extract_member_of_as_string($list as xs:string*) as xs:string
{
    if (exists($list)) then
        string-join($list, $th:WORKBENCH_SEPARATOR)
    else
        ""
};

(::)
declare function th:extract_parent_of_page($node as node()) as xs:string*
{
    let $list :=
        for $item in $node/resource_metadata/rdf:RDF/rdf:Description/fedora:isMemberOf/@rdf:resource/data()
        return fn:substring-after($item, "/")
    return
        if (exists($list)) then
            $list
        else
            ()
};

(::)
declare function th:extract_parent_of_page_as_string($list as xs:string*) as xs:string
{
    if (exists($list)) then
        string-join($list, $th:WORKBENCH_SEPARATOR)
    else
        ""
};



(::)
declare function th:get_parent_node($member_of as xs:string?) as node()?
{
    collection()/metadata[@pid/data()=$member_of]
};


(: use a cached list of collections to avoid the lookup in the entire collection :)
(: assumes usage of the default Drupal collection node id if collection is not present in the set :)
(: ToDo :)
(: specify collection as per https://mjordan.github.io/islandora_workbench_docs/paged_and_compound/#creating-collections-and-members-together :)
(: if the member_of is not found in the current collection  :)
declare function th:get_member_of_cached_collections($node as node(), $collection_cache as map(*), $book_cache as map(*), $default as xs:string) as map(*)
{
    let $member_of := th:extract_member_of($node)
    let $page_of := th:extract_parent_of_page($node)
    let $is_page_of_found :=  (exists($page_of) and exists(map:get($book_cache, th:extract_parent_of_page_as_string($page_of))))

    return
        (: todo: assume a page can be attached to only one book :)
        if (exists($page_of) and $is_page_of_found ) then
            map { 'parent_id' : th:extract_parent_of_page_as_string($page_of), 'field_member_of' : "" }
        else if (exists($page_of) and not($is_page_of_found) ) then
            (: fn:error(xs:QName('page_of'), concat('Book ', $page_of, " is missing; no parent of page ", th:get_id($node), " in the set")) :)
            map { 'parent_id' : "", 'field_member_of' : "missing parent; page orphaned" }
        (: else if (exists($member_of) and exists(map:get($collection_cache, $member_of)) ) then :)
        else if (exists($member_of)) then
            let $member_of_string :=
                for $parent in $member_of
                return
                    if (exists(map:get($collection_cache, $parent)) ) then
                        $parent
                    else
                        $default
            return
                map { 'parent_id' : th:extract_member_of_as_string($member_of_string), 'field_member_of' : "" }
        else
            map { 'parent_id' : "", 'field_member_of' : $default }
};



(: assumes usage of the default Drupal collection node id if collection is not present in the set :)
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
    let $member_of := th:extract_member_of($node)[1] (: Todo: this assumes usage of the first member_of :)
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

(: given a set, find all Book objects and return a mapping of the book id -- to use as a lookup for page of book objects :)
declare function th:get_book_map() as map(*)
{
    map:merge(
        for $book in collection()/metadata[resource_metadata/rdf:RDF/rdf:Description/fedora-model:hasModel/@rdf:resource/data() = "info:fedora/islandora:bookCModel"]
        return
            map { th:get_id($book) : "" }
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
        case "info:fedora/islandora:sp_large_image_cmodel"  return "Image"
        case "info:fedora/islandora:sp_pdf"                 return "Digital Document"
        case "info:fedora/islandora:sp_videoCModel"         return "Video"
        case "info:fedora/islandora:binaryObjectCModel"     return "Binary"
        case "info:fedora/islandora:bookCModel"             return "Paged Content"
        case "info:fedora/islandora:compoundCModel"         return "Compound Object"
        case "info:fedora/islandora:newspaperCModel"        return "Newspaper"
        case "info:fedora/islandora:newspaperIssueCModel"   return "Publication Issue"
        case "info:fedora/islandora:newspaperPageCModel"    return "Page"
        case "info:fedora/islandora:pageCModel"             return "Page"
        case "info:fedora/cwrc:citationCModel"              return "Citation"
        case "info:fedora/cwrc:documentCModel"              return "Digital Document"
        case "info:fedora/cwrc:dtocCModel"                  return "Digital Document"
        case "info:fedora/islandora:tei-rdfCModel"          return "UNKNOWN"
        case "info:fedora/islandora:versionCModel"          return "UNKNOWN"
        case "info:fedora/islandora:transcriptionCModel"    return "UNKNOWN"
        case "info:fedora/ir:citationCModel"                return "UNKNOWN"
        case "info:fedora/islandora:sp_html_snippet"        return "UNKNOWN"
        case "info:fedora/islandora:OACCModel"              return "UNKNOWN"
        case "info:fedora/islandora:criticalEditionCModelPage" return "UNKNOWN"
        case "info:fedora/islandora:criticalEditionContainerCModel" return "UNKNOWN"
        case "info:fedora/islandora:criticalEditionCModel"  return "UNKNOWN"
        case "info:fedora/islandora:digitalusCModel"        return "UNKNOWN"
        case "info:fedora/islandora:markupeditorschemaCModel" return "UNKNOWN"
        case "info:fedora/islandora:eventCModel"            return "UNKNOWN"

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
        case "info:fedora/islandora:sp_large_image_cmodel"  return "Still Image"
        case "info:fedora/islandora:sp_pdf"                 return "Text"
        case "info:fedora/islandora:sp_videoCModel"         return "Moving Image"
        case "info:fedora/islandora:binaryObjectCModel"     return "UNKNOWN"
        case "info:fedora/islandora:bookCModel"             return "Collection"
        case "info:fedora/islandora:compoundCModel"         return "Collection"
        case "info:fedora/islandora:newspaperCModel"        return "Collection"
        case "info:fedora/islandora:newspaperIssueCModel"   return "Collection"
        case "info:fedora/islandora:newspaperPageCModel"    return "Text"
        case "info:fedora/islandora:pageCModel"             return "Text"
        case "info:fedora/cwrc:citationCModel"              return "Text"
        case "info:fedora/cwrc:documentCModel"              return "Text"
        case "info:fedora/cwrc:dtocCModel"                  return "Text"
        case "info:fedora/islandora:tei-rdfCModel"          return "UNKNOWN"
        case "info:fedora/islandora:versionCModel"          return "UNKNOWN"
        case "info:fedora/islandora:transcriptionCModel"    return "UNKNOWN"
        case "info:fedora/ir:citationCModel"                return "UNKNOWN"
        case "info:fedora/islandora:sp_html_snippet"        return "UNKNOWN"
        case "info:fedora/islandora:OACCModel"              return "UNKNOWN"
        case "info:fedora/islandora:criticalEditionCModelPage" return "UNKNOWN"
        case "info:fedora/islandora:criticalEditionContainerCModel" return "UNKNOWN"
        case "info:fedora/islandora:criticalEditionCModel"  return "UNKNOWN"
        case "info:fedora/islandora:digitalusCModel"        return "UNKNOWN"
        case "info:fedora/islandora:markupeditorschemaCModel" return "UNKNOWN"
        case "info:fedora/islandora:eventCModel"            return "UNKNOWN"

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
        case "info:fedora/islandora:compoundCModel"         return ("")
        case "info:fedora/islandora:sp_html_snippet"        return ("") (: used by 'yale' Fedora 3 namespace:)
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
declare function th:get_marcrelator_term_from_text($role as xs:string, $id as xs:string?) as xs:string
{
    (: alter role so only first letter is uppercase, e.g., Art Director -> Art director) :)
    let $role_case := concat(upper-case(substring($role,1,1)), lower-case(substring($role,2)))
    return
    switch ($role_case)
        case "Actor"                        return ("act")
        case "Adaptor"                      return ("adp")
        case "Addressee"                    return ("rcp")
        case "Animator"                     return ("anm")
        case "Art director"                 return ("adi")
        case "Artist"                       return ("art")
        case "Author"                       return ("aut")
        case "Author of introduction, etc." return ("aui")
        case "Cartographer"                 return ("ctg")
        case "Commentator"                  return ("cmm")
        case "Compiler"                     return ("com")
        case "Composer"                     return ("cmt")
        case "Contributor"                  return ("ctr")
        case "Cover designer"               return ("cov")
        case "Creator"                      return ("cre")
        case "Curator"                      return ("cur")
        case "Data Manager"                 return ("dtm")
        case "Degree grantor"               return ("dgg")
        case "Designer"                     return ("dsr")
        case "Director"                     return ("drt")
        case "Editor"                       return ("edt")
        case "Editor of moving image work"  return ("edm")
        case "Editorial director"           return ("edd")
        case "Encoder"                      return ("mrk")
        case "Film editor"                  return ("flm")
        case "Filmmaker"                    return ("fmk")
        case "Founder"                      return ("fon")
        case "Funder"                       return ("fnd")
        case "Host"                         return ("hst")
        case "Illuminator"                  return ("ilu")
        case "Illustrator"                  return ("ill")
        case "Interviewee"                  return ("ive")
        case "Interviewer"                  return ("ivr")
        case "Lyricist"                     return ("lyr")
        case "Musical director"             return ("msd")
        case "Musician"                     return ("mus")
        case "Narrator"                     return ("nrt")
        case "Performer"                    return ("prf")
        case "Photographer"                 return ("pht")
        case "Presenter "                   return ("pre")
        case "Producer"                     return ("pro")
        case "Production manager"           return ("pmn")
        case "Project director"             return ("pdr")
        case "Project supervisor"           return ("pdr")
        case "Publisher"                    return ("pbl")
        case "Reporter"                     return ("rpt")
        case "Repository"                   return ("rps")
        case "Recipient"                    return ("rcp")
        case "Researcher"                   return ("res")
        case "Research team head"           return ("rth")
        case "Reviewer"                     return ("rev")
        case "Screenwriter"                 return ("aus")
        case "Speaker"                      return ("spk")
        case "Sponsor"                      return ("spn")
        case "Surveyor"                     return ("svr")
        case "Thesis advisor"               return ("ths")
        case "Transcriber"                  return ("ths")
        case "Translator"                   return ("trl")
        case "Videographer"                 return ("vdg")
        default (: Exceptions found in the tpatt collection :)
            return
            switch ($role)
                case "art"          return ("art") (: sometimes code is entered when text is specified :)
                case "aut"          return ("aut") (: sometimes code is entered when text is specified :)
                case "edt"          return ("edt") (: sometimes code is entered when text is specified :)
                case "trl"          return ("trl") (: sometimes code is entered when text is specified :)
                case "Photographers" return ("pht")(: tpatt problem :)
                case "author"                       return ("aut")
                case "archivist"    return ("aut") (: tpatt problem :)
                case "co-editor"   return ("edt") (: tpatt problem :)
                case "Author of introduction, etc"        return ("aui")
                case "photographer" return ("pht")
                default
                return
                    fn:error(xs:QName('marcrelator'), concat('Marcrelator mapping missing: [', $role, ']', ' [', $id, ']'))
};


(: BaseX CSV serialization doesn't generate a header that matches a variable number of columns (nor does it generate empty columns for rows with empty cell). The workaround:  retrieve the full list of associated files (datastreams) of all items in the collection and then add items (empty or full so there is no varibility) :)

declare function th:get_list_of_possible_files() as xs:string*
{
    distinct-values(collection()/metadata[not(@models = $th:UNSUPPORTED_MODELS)]/media_exports/media/@ds_id/data())
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

(:
: build a list of all possible columns representing all possible file/media - blank if unused
: if an exception, leave blank
:)
declare function th:build_associated_files($possible_associated_files as xs:string*, $metadata as node(), $exception_list as xs:string*) as element()*
{
    for $item in $possible_associated_files
        order by lower-case($item)
        let $media := $metadata/media_exports/media[@ds_id/data() = $item]
        let $value :=
            if (exists($media) and not($media/@filepath/data()=$exception_list)) then
                $media/@filepath/data()
                 else ()
        return
            element {concat('file_',lower-case($item))} { $value }

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

(: Drupal title field has a limited length; try to align with <https://style.mla.org/shortening-a-long-title/> :)
declare function th:truncate_string($str as xs:string, $len as xs:integer) as xs:string
{
    (: truncate at last delimiter before the max length; remove punctuation at end :)
    if (string-length($str) > $len)
    then
        let $delim := '[ ]'
        let $str_substring := substring($str, 1, $len)
        return
            if (matches($str_substring, $delim))
            then
                (: substring-before-last($str_substring, $delim) :)
                (: find the last occurance: note this relies on the greedy regex matching - not sure if reliable;  motivated by: http://www.xqueryfunctions.com/xq/functx_substring-before-last.html :)
                let $truncated := replace($str_substring, concat("^(.*)",$delim,".*"), '$1')
                let $ending_punctuation := "[.,;:!?]+$"
                return
                    (: remove punctuation at the end:)
                    if (matches($truncated, $ending_punctuation))
                    then
                        replace($truncated, concat("^(.*)",$ending_punctuation), '$1')
                    else
                        $truncated
          else
                fn:error(xs:QName('title'), concat('can not trucate title: ', $str_substring))
    else
        $str
};

(: mods/titleInfo[not @type]; there may be no mods and title might be in `$metadata/resource_metadata/oai_dc:dc/dc:title/text()` therefore use @label :)
(: A complext example
 <title>Review: Teresa Ransom:
  <extension>
   <tei:title level="m">The Mysterious Miss Marie Corelli</tei:title>
  </extension>
; Annette R. Federico:
  <extension>
   <tei:title level="m">Idol of Suburbia</tei:title>
  </extension>
 </title>
:)
declare function th:get_title($node as node(), $cModel as xs:string) as xs:string
{
    let $title := $node/resource_metadata/(mods:mods|mods:modsCollection/mods:mods)/mods:titleInfo[not(@type)]/mods:title
    return
      if (exists($title) and count($title)=1) then
        normalize-space(string-join($title//text(), ""))
      else if (exists($title) and count($title)>1) then
        fn:error(xs:QName('label'), concat('title/label is multivalued - possible content error: ', th:get_id($node)))
      else if ($cModel = ("info:fedora/islandora:pageCModel", "info:fedora/islandora:collectionCModel", "info:fedora/islandora:criticalEditionCModelPage", "info:fedora/islandora:tei-rdfCModel", "info:fedora/islandora:transcriptionCModel") )  then
        $node/@label/data()
      else
        fn:error(xs:QName('label'), concat('title/label required field is missing: ', th:get_id($node)))
};

(: A truncated version of the title: used for the Drupal title field that has a limited length :)
declare function th:get_title_255_characters($node as node(), $cModel as xs:string) as xs:string
{
    let $title := th:get_title($node, $cModel)
    let $str_length := 255 - 3 (: for the "..." in the truncated string :)
    return
        if (string-length($title) > $str_length)
        then concat(th:truncate_string($title, $str_length), "...")
        else
            $title
};

(: The extented Drupal title field :)
declare function th:get_title_full($node as node(), $cModel as xs:string) as xs:string
{
    let $title := th:get_title($node, $cModel)
    let $sub_title := $node/resource_metadata/(mods:mods)/mods:titleInfo[not(@type)]/mods:subTitle
    return
        string-join( ($title, $sub_title), ": ")
};

(: mods/titleInfo[@type="translated" @xml:lang="[lang code]"] :)
(: TODO :)

(: mods/titleInfo[@type="alternative" or @type="abbreviated" or @type="uniform"] :)
declare function th:get_title_alt($node as node()) as xs:string
{
    string-join($node/resource_metadata/mods:mods/mods:titleInfo[@type="alternative" or @type="abbreviated" or @type="uniform"]/mods:title/text(), $th:WORKBENCH_SEPARATOR)
};


declare function th:mods_name_role($mods_role as element()*) as xs:string+
{
    (: assume if no text() then default to author :)
    if (exists($mods_role/mods:roleTerm/text()))
    then
        for $role_term in $mods_role/mods:roleTerm
            return
                switch($role_term/@type/data())
                case "text"
                    return th:get_marcrelator_term_from_text($role_term/text(), $role_term/ancestor::metadata/@pid/data())
                case "code"
                    return $role_term/text()
                default
                    return 'aut'
    else
        th:get_marcrelator_term_from_text('Author', $mods_role/ancestor::metadata/@pid/data())
};

declare function th:mods_name_type($mods_name as element()) as xs:string
{
    switch($mods_name/@type/data())
        case 'personal' return 'presonal'
        case 'corporate' return 'corporate'
        default return 'personal'
};

declare function th:mods_name_formater($mods_name as node()) as xs:string
{
    if ( ($mods_name/mods:namePart)[1]/@type/data() = 'family' and ($mods_name/mods:namePart)[2]/@type/data() = 'given'  )
    then
        string-join($mods_name/mods:namePart/text(), ", ")
    else if (($mods_name/mods:namePart)[1]/@type/data() = 'given' and ($mods_name/mods:namePart)[2]/@type/data() = 'family'  )
    then
        concat( ($mods_name/mods:namePart)[2]/text(), ", ", ($mods_name/mods:namePart)[1]/text() )
    else
        string-join($mods_name/mods:namePart/text(), " ")
};


(: Linked agents at the MODS root or within MODS relatedItem: generic handling; not meant to cover all cases :)
(: toDo: very simplistic; assumes mods:namePart contains text and in test; expand :)
declare function th:generic_linked_agent($mods_name as node()*) as xs:string*
{
    (: $metadata/resource_metadata/mods:mods/mods:name[exists(mods:namePart/text())] :)
    for $mods_name at $pos in $mods_name
        let $role_list := th:mods_name_role($mods_name/mods:role)
        let $person_type := th:mods_name_type($mods_name)
        let $separator :=
            if ($pos > 1 or count($mods_name/mods:role) > 1)
            then $th:WORKBENCH_SEPARATOR
            else ""
        return
            let $formated_name := string-join($mods_name/mods:namePart/text())
            (: if mods name has multiple roles :)
            for $role in $role_list
                return concat($separator, 'relators:', $role, ":person:", $formated_name)
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
    let $list := $node/resource_metadata/mods:mods/mods:originInfo/mods:dateIssued
    return
        th:generic_date($list)
};

(: mods/originInfo/dateCreated :)
declare function th:get_date_created($node as node()) as xs:string
{
    let $list := $node/resource_metadata/mods:mods/mods:originInfo/mods:dateCreated
    return
        th:generic_date($list)
};

(: mods/originInfo/dateValid :)
declare function th:get_date_valid($node as node()) as xs:string
{
    let $list := $node/resource_metadata/mods:mods/mods:originInfo/mods:dateValid
    return
        th:generic_date($list)
};

(: mods/originInfo/dateCaptured :)
declare function th:get_date_captured($node as node()) as xs:string
{
    let $list := $node/resource_metadata/mods:mods/mods:originInfo/mods:dateCaptured
    return
        th:generic_date($list)
};

(: mods/originInfo/dateModified :)
declare function th:get_date_modified($node as node()) as xs:string
{
    let $list := $node/resource_metadata/mods:mods/mods:originInfo/mods:dateModified
    return
        th:generic_date($list)
};

(: mods/originInfo/copyrightDate :)
declare function th:get_date_copyright($node as node()) as xs:string
{
    let $list := $node/resource_metadata/mods:mods/mods:originInfo/mods:copyrightDate
    return
        th:generic_date($list)
};

(: mods/originInfo/dateOther :)
declare function th:get_date_other($node as node()) as xs:string
{
    (: assume no point `end` without a point `start` - verified in data :)
    (: two items have a point `start` without a point `end` -- these may have a trailing `/` :)
    let $list := $node/resource_metadata/mods:mods/mods:originInfo/mods:dateOther
    return
        th:generic_date($list)
};

(: generic date handler :)
declare function th:generic_date($list as element()*) as xs:string
{
    let $cnt := count($list)
    let $tmp :=
        for $item at $i in $list
            let $wb_separator :=
                if (
                        $i < $cnt
                        and ($list/@point = "start" or $list/@type = "start")
                        and ($list[$i + 1]/@point = "end" or $list[$i + 1]/@type = "end")
                    )
                then (
                    (: range with begin and end - no workbench separator :)
                    ""
                )
                else if ($i = $cnt) then (
                    ""
                )
                else (
                    $th:WORKBENCH_SEPARATOR
                )
            let $edtf := $item/text()
            let $wb_content :=
                if ( ($item/@point = "start" or $item/@type = "start") ) then (
                    (: range with begin and end :)
                    concat($edtf, $th:EDTF_RANGE_SEPARATOR)
                )
                else if (
                        ($item/@point = "end" or $item/@type = "end")
                        and ($i = 0 or not($list[$i - 1]/@point = "start" or $list[$i - 1]/@type = "start"))
                        )
                then (
                    (: open range end with no begin :)
                    concat($th:EDTF_RANGE_SEPARATOR, $edtf)
                )
                else (
                    $edtf
                )
        return
            concat($wb_content, $wb_separator)
    return
        string-join($tmp, "")
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

(: convert an text language to iso639-1 (Drupal/Islandora) https://git.drupalcode.org/project/drupal/-/blob/8.8.x/core/lib/Drupal/Core/Language/LanguageManager.php#L224 :)
declare function th:convert_text_to_iso639_1($value as xs:string, $id as xs:string) as xs:string
{
    switch($value)
        case 'English' return 'en'
        case 'French' return 'fr'
        case 'Spanish' return 'es'
        case 'creeng' return 'en'
        case 'engcre' return 'en'
        case 'cre eng' return 'en'
        case 'eng' return 'en'
        case 'eng hai' return 'en'
        case 'eng mic' return 'en'
        case 'engfre' return 'en'
        case 'dgr eng' return 'en'
        case 'eng sal' return 'en'
        case 'engtli' return 'en'
        case 'engalg' return 'en'
        case 'English1180-0666' return 'en'
        case 'Includes some text in Dene, Lakota, and Plains Cree languages' return 'en'
        case 'Latin' return 'la'
        case 'latin' return 'la'
        case '' return ''
        default
            return
                fn:error(xs:QName('Resource_model'), concat('langauge text error: ', $id, " val: ", $value))
};

(: convert an iso639-2b language code to iso639-1 (Drupal/Islandora) https://git.drupalcode.org/project/drupal/-/blob/8.8.x/core/lib/Drupal/Core/Language/LanguageManager.php#L224 :)
declare function th:convert_iso639_2b_to_iso639_1($value as xs:string, $id as xs:string) as xs:string
{
    switch($value)
        case 'eng' return 'en'
        case 'fre' return 'fr'
        case 'lat' return 'la'
        case 'English' return 'en'
        case '' return ''
        default
            return
                fn:error(xs:QName('Resource_model'), concat('langauge code error: ', $id, " val: ", $value))
};

(: mods/language :)
(: convert to iso639-1 from https://git.drupalcode.org/project/drupal/-/blob/8.8.x/core/lib/Drupal/Core/Language/LanguageManager.php#L224 :)
declare function th:get_langcode($node as node()) as xs:string
{
    let $values :=
        for $item in $node/resource_metadata/mods:mods/mods:language/mods:languageTerm
        return
            if ($item/@authority = 'iso639-2b' and $item/@type = 'code' and exists($item/text())) then
                th:convert_iso639_2b_to_iso639_1($item/text(), $node/@pid)
            else if (lower-case($item/@type) = 'text' and exists($item/text())) then
                th:convert_text_to_iso639_1($item/text(), $node/@pid)
            else
                $item/text()
    return string-join($values, $th:WORKBENCH_SEPARATOR)
};

(: mods/language :)
declare function th:get_langauge($node as node()) as xs:string
{
    string-join($node/resource_metadata/mods:mods/mods:language/mods:languageTerm/text(), $th:WORKBENCH_SEPARATOR)
};

(: mods/physicalDescription/form :)
declare function th:get_form($node as node()) as xs:string
{
    (: account for empty elements :)
    let $values :=
        for $item in $node/resource_metadata/mods:mods/mods:physicalDescription/text()
        return
            if (empty(fn:normalize-space($item)) ) then ($item)
            else ()
    return string-join($values, $th:WORKBENCH_SEPARATOR)
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
    (: account for empty elements :)
    let $values :=
        for $item in
            $node/resource_metadata/mods:mods/mods:subject/mods:geographic/text() |
            $node/resource_metadata/mods:mods/mods:subject/mods:geographicCode/text() |
            $node/resource_metadata/mods:mods/mods:subject/mods:hierarchicalGeographic/text()
        return
            if (empty(fn:normalize-space($item)) ) then ($item) else ()
    return string-join($values, $th:WORKBENCH_SEPARATOR)
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
        $node/resource_metadata/mods:mods/mods:subject/mods:temporal[exists(text())]
    return
        th:generic_date($list)
};

(: Works with only subject/name content as the function make several assumptions that a valid only in the subject/name context
  * nd assumes all have type="given" and type="family" attribute values
  :)
declare function th:get_subject_name_with_type($item as node()) as xs:string
{
    concat($item/mods:namePart[type="given"]/text(), " ", $item/mods:namePart[type="family"]/text())
};

(: mods/subject/name :)
(: todo: doesn't work well with taxonomy :)
declare function th:get_subject_name($node as node()) as xs:string
{
    let $list :=
        for $item in $node/resource_metadata/mods:mods/mods:subject/mods:name
            (: set the vocabulary as repository item field "field_subjects_name" is a taxonomy reference :)
            let $vocabulary :=
                switch ($item/@type/data())
                    case "personal"     return "person"
                    case "corporate"    return "corporate_body"
                    default             return "person"
            let $id :=
                if (exists($item[mods:namePart[@type='family'] and mods:namePart[@type='given']])) then
                    th:get_subject_name_with_type(@item)
                else if (exists($item/mods:namePart[not(mods:namePart[@type='family'] or mods:namePart[@type='given']) and text()])) then
                (: else if (exists($item/mods:namePart)) then :)
                    string-join($item/mods:namePart/text(), " ")
                (: else if (exists($item/text()) and count(item/text()=1)) then :)
                else if (exists(normalize-space($item/text()))) then
                    normalize-space(string-join($item/text()))
                else if (exists($item/@valueURI)) then
                    $item/@valueURI/data()
                else
                    fn:error(xs:QName('subject_name'), concat(': Subject name invalid [', string-join($item//(@*|text())), '] ' , $node/@pid/data()))
                    (: fn:error(xs:QName('subject_name'), concat(': Subject name invalid [', $item/(@*|text()), '] ' , $node/@pid/data())) :)
            return
                (: if (count($id)!=1) then :)
                if (count($id)>1) then
                    fn:error(xs:QName('subject_name'), concat(': Subject name weird : ' , $node/@pid/data()))
                else if (count($id)=0 or $id='') then
                    ()
                else
                    concat($vocabulary, ':', $id)
    return
        string-join($list, $th:WORKBENCH_SEPARATOR)
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


(: Related Item true/false:)
declare function th:get_related_item_place_boolean($node as node()) as xs:string
{
    if ($node/resource_metadata/mods:mods/mods:relatedItem) then
        "1"
    else
        ""
};

(: Related Item Title :)
(: $node/resource_metadata/mods:mods/mods:relatedItem/mods:titleInfo[not(@*) or @usage='primary']
                /mods:title/text()
 :)
declare function th:get_related_item_title($node as node()) as xs:string
{
    (: filter out mods:place with newline characters :)
    let $normalized_space_values :=
        for $i in
            $node/resource_metadata/mods:mods/mods:relatedItem/mods:titleInfo
                [not(@*) or @usage='primary']
                /mods:title/text()
        return
            if (normalize-space($i) != '') then
                $i
            else
                ()
    return
        string-join($normalized_space_values, $th:WORKBENCH_SEPARATOR)

};

(: The extented Drupal title field :)
declare function th:get_related_item_title_full($node as node()) as xs:string
{
    let $title := th:get_related_item_title($node)
    let $sub_title := $node/resource_metadata/(mods:mods)/mods:relatedItem/mods:titleInfo[not(@type)]/mods:subTitle/text()
    return
        if (not(empty($sub_title)))
        then
            string-join( ($title, $sub_title), ": ")
        else
            $title
};

(: mods/relatedItem/titleInfo[@type="alternative" or @type="abbreviated" or @type="uniform"] :)
declare function th:get_related_item_title_alt($node as node()) as xs:string
{
    string-join(
        $node/resource_metadata/mods:mods/mods:relatedItem/mods:titleInfo[@type="alternative" or @type="abbreviated" or @type="uniform"]/mods:title/text(),
        $th:WORKBENCH_SEPARATOR
        )
};

(: mods/relatedItem/originInfo/dateIssued :)
declare function th:get_related_item_date_issued($node as node()) as xs:string
{
    let $list := $node/resource_metadata/mods:mods/mods:relatedItem/mods:originInfo/mods:dateIssued
    return
        th:generic_date($list)
};

(: mods/relatedItem/originInfo/dateCreated :)
declare function th:get_related_item_date_created($node as node()) as xs:string
{
    let $list := $node/resource_metadata/mods:mods/mods:relatedItem/mods:originInfo/mods:dateCreated
    return
        th:generic_date($list)
};

(: Related Item Identifier - not doi/issn/isbn :)
(: relatedItem/identifier and not(@type=('doi', 'issn', 'isbn')) :)
declare function th:get_related_item_idenifier($node as node()) as xs:string
{
    string-join(
        $node/resource_metadata/mods:mods/mods:relatedItem/mods:identifier[
            not(@type=['doi', 'DOI', 'issn', 'ISSN', 'isbn', 'ISBN'])
            ]/text(),
        $th:WORKBENCH_SEPARATOR
        )
};


(: Related Item Identifier DOI :)
(: relatedItem/identifier and @type='doi' :)
declare function th:get_related_item_idenifier_doi($node as node()) as xs:string
{
    string-join(
        $node/resource_metadata/mods:mods/mods:relatedItem/mods:identifier[@type=['doi', 'DOI']]/text(),
        $th:WORKBENCH_SEPARATOR
        )
};


(: Related Item Identifier ISBN :)
(: relatedItem/identifier and @type='isbn' :)
declare function th:get_related_item_idenifier_isbn($node as node()) as xs:string
{
    string-join(
        $node/resource_metadata/mods:mods/mods:relatedItem/mods:identifier[@type=['isbn', 'ISBN']]/text(),
        $th:WORKBENCH_SEPARATOR
        )
};


(: Related Item Identifier ISSN :)
(: relatedItem/identifier and @type='issn' :)
declare function th:get_related_item_idenifier_issn($node as node()) as xs:string
{
    string-join(
        $node/resource_metadata/mods:mods/mods:relatedItem/mods:identifier[@type=['issn', 'ISSN']]/text(),
        $th:WORKBENCH_SEPARATOR
        )
};

(: Related Item Place Published :)
(:
    $node/resource_metadata/mods:mods/mods:relatedItem/mods:originInfo/mods:place/text()
    or
    $node/resource_metadata/mods:mods/mods:relatedItem/mods:originInfo/mods:place/mods:placeTerm/text()
 :)
declare function th:get_related_item_place_published($node as node()) as xs:string
{
    (: filter out mods:place with newline characters :)
    let $normalized_space_values :=
        for $i in $node/resource_metadata/mods:mods/mods:relatedItem/mods:originInfo/mods:place/(text() | mods:placeTerm/text())
        return
            if (normalize-space($i) != '') then
                $i
            else
                ()
    return
        string-join($normalized_space_values, $th:WORKBENCH_SEPARATOR)
};

(: Related Item Type :)
(: :)
declare function th:get_related_item_type($node as node()) as xs:string
{
    let $item_list :=
        for $i in $node/resource_metadata/mods:mods/mods:relatedItem/@type/data()
        return
                switch ($i)
                    case "host" return $i
                    case "series" return $i
                    case "original" return $i
                    case "succeeding" return $i
                    case "constituent" return $i
                    case "otherVersion" return $i
                    case "otherFormat" return "other format"
                    case "" return ()
                    default
                        return
                            fn:error(xs:QName('Related_type'), concat('Invalid related type: ', base-uri($node)))
    return
        string-join($item_list, $th:WORKBENCH_SEPARATOR)
};


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
