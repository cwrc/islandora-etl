xquery version "3.1" encoding "utf-8";

(: set of sample utilities to report element path and help with clean-up or information gathering :)

declare namespace map = "http://www.w3.org/2005/xpath-functions/map";

declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace fedora="info:fedora/fedora-system:def/relations-external#";
declare namespace fedora-model="info:fedora/fedora-system:def/model#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";

declare function local:element_path_to_nodes( $nodes as node()* ) as xs:string* 
{
  $nodes/concat('/',string-join(ancestor-or-self::*/name(.), '/'))
};

(: to use fully qualified path: XQuery 3.0 comes with a path function: https://www.w3.org/TR/2011/WD-xpath-functions-30-20111213/#func-path :)

(: return an xpath of element names with ability to exclude specific elements :)
declare function local:element_path_to_node( $node as node(), $exclude_elm as xs:string* ) as xs:string 
{
  $node/concat('/',string-join(ancestor-or-self::*[not(name(.)=$exclude_elm)]/name(.), '/'))
};

(: return an xpath of element names plus attributes with ability to exclude specific elments/attributes :)
declare function local:element_attribute_path_to_node( $node as node(), $exclude_elm as xs:string*, $exclude_attr as xs:string* ) as xs:string 
{
  let $path := 
    for $elm in $node/ancestor-or-self::*[not(name(.)=$exclude_elm)]
      let $attr_nodes := $elm/@*[not(name(.)=$exclude_attr)]
      let $attr_str := 
        for $attr in $attr_nodes
        let $attr_label := $attr/name(.)
        order by $attr_label
        return 
          concat("@", $attr_label, "='", $attr/data(), "'")
      let $ret :=
        if (exists($attr_str)) then 
          concat($elm/name(.), "[", string-join($attr_str," "), "]" )
        else
          $elm/name(.)
    return 
      $ret
      
  return concat("/", string-join($path, "/"))
  
};

(:
local:element_path_to_node( (/metadata/media_exports)[1] )  
:)  


(: update set of excluded attributes :)
let $exclude_attributes :=  ("xsi:schemaLocation","modified", "valueURI", "ID", "key", "version", "displayLabel", "ns5:href", "ns6:href") (: ,:)

(: update set of excluded elements :)
let $exclude_elements :=  ("metadata", "mods:modsCollection", "mods:extension", "tei:orgname", "tei:name", "tei:title", "tei:sic", "tei:socalled", "tei:emph", "tei:foreign", "tei:quote")

(: set starting node set:)
let $start_node := //mods:mods//mods:titleInfo

(: for all items in the node set (and descendants), find the ancestor path in the form of /1/2/3 :)
let $path_list := 
  for $x in $start_node/descendant-or-self::node()
  (: $path := local:element_path_to_node($x, $exclude_elements) :)
  let $path := local:element_attribute_path_to_node($x, $exclude_elements, $exclude_attributes)
  order by $path
  return $path
return distinct-values($path_list)


