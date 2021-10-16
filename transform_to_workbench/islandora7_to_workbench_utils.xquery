xquery version "3.1" encoding "utf-8";

module namespace th = "transformationHelpers";

declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace fedora="info:fedora/fedora-system:def/relations-external#";
declare namespace fedora-model="info:fedora/fedora-system:def/model#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";


(:
declare namespace saxon="http://saxon.sf.net/";
declare option output:method "xml";
declare option output:indent   "yes";
declare option output:csv "header=yes, separator=comma";
declare option output:encoding "UTF-8";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare variable $FIELD_MEMBER_OF external := "1";
declare option saxon:output "method=xml";
:)
(: :)




declare function th:get_model_from_cModel ($uri as xs:string) as xs:string
{
    switch ($uri)
        case "info:fedora/cwrc:documentCModel" return "15"
        case "infor:fedora/islandora:image" return "13"
        case "info:fedora/islandora:sp-audioCModel" return "10"
        case "info:fedora/islandora:collection" return "23"
        default return "error"
};

declare function th:get_type_from_cModel ($uri as xs:string) as xs:string
{
    switch ($uri)
        case "info:fedora/cwrc:documentCModel" return "33"
        case "infor:fedora/islandora:image" return "25"
        case "info:fedora/islandora:sp-audioCModel" return "30"
        case "info:fedora/islandora:video" return "27"
        case "info:fedora/islandora:collection" return "12"
        default return "error"
};


(: ToDo: map from cModel to main file for Workbench :)
declare function th:get_main_file_from_cModel ($uri as xs:string) as xs:string
{
    switch ($uri)
        case "info:fedora/cwrc:documentCModel" return "CWRC"
        case "info:fedora/islandora:image"    return "OBJ"
        case "info:fedora/islandora:sp-audioCModel" return "OBJ"
        default return "error"
};

(::)
declare function th:get_id ($node as node()) as xs:string
{
    $node/@pid/data()
};

(::)
declare function th:get_cModel ($node as node()) as xs:string
{
    $node/resource_metadata/rdf:RDF/rdf:Description/fedora-model:hasModel/@rdf:resource/data() 
};

(::)
declare function th:get_title ($node as node()) as xs:string
{
    $node/resource_metadata/mods:mods/mods:titleInfo/mods:title/text()
};
