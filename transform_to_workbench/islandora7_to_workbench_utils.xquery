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


declare variable $th:WORKBENCH_SEPARATOR as xs:string := "|";


declare function th:get_model_from_cModel($uri as xs:string) as xs:string
{
    switch ($uri)
        case "info:fedora/cwrc:documentCModel" return "15"
        case "infor:fedora/islandora:image" return "13"
        case "info:fedora/islandora:sp-audioCModel" return "10"
        case "info:fedora/islandora:collection" return "23"
        default return "error"
};

declare function th:get_type_from_cModel($uri as xs:string) as xs:string
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
declare function th:get_main_file_from_cModel($uri as xs:string) as xs:string
{
    switch ($uri)
        case "info:fedora/cwrc:documentCModel" return "CWRC"
        case "info:fedora/islandora:image"    return "OBJ"
        case "info:fedora/islandora:sp-audioCModel" return "OBJ"
        default return "error"
};

(::)
declare function th:get_id($node as node()) as xs:string
{
    $node/@pid/data()
};

(::)
declare function th:get_cModel($node as node()) as xs:string
{
    $node/resource_metadata/rdf:RDF/rdf:Description/fedora-model:hasModel/@rdf:resource/data() 
};

(: mods/titleInfo[not @type] :)
declare function th:get_title($node as node()) as xs:string
{
    $node/resource_metadata/mods:mods/mods:titleInfo[not(@type)]/mods:title/text()
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
    string-join($node/resource_metadata/mods:mods/mods:language/text(), $th:WORKBENCH_SEPARATOR)
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
    string-join($node/resource_metadata/mods:mods/mods:note/text(), $th:WORKBENCH_SEPARATOR)
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
    string-join($node/resource_metadata/mods:mods/mods:subject/mods:topic/text(), $th:WORKBENCH_SEPARATOR)
};

(: mods/subject/temporal :)
declare function th:get_subject_temporal($node as node()) as xs:string
{
    string-join($node/resource_metadata/mods:mods/mods:subject/mods:temporal/text(), $th:WORKBENCH_SEPARATOR)
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
    string-join($node/resource_metadata/mods:mods/mods:accessCondition/text(), $th:WORKBENCH_SEPARATOR)
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