declare namespace mods = "http://www.loc.gov/mods/v3";

for $obj in /metadata[contains(@pid/data(),'tpatt:')]/resource_metadata/mods:mods/mods:name
  for $name_node in $obj/descendant-or-self::element()

    let $j :=
      for $item in $name_node/ancestor-or-self::element()
      return
        switch(name($item))
          case "metadata" return concat(name($item), "[@pid=", "'", $item/@pid/data(), "']")
          case "mods:roleTerm" return concat(name($item), "[@type=", "'", $item/@type, "'] [", $item/@authority, "] [", $item/text(), "]")
          case "mods:namePart" return concat(name($item), "[@type=", "'", $item/@type, "'] [", $item/text(), "]")
          default return name($item)
    return
      string-join($j, "/")