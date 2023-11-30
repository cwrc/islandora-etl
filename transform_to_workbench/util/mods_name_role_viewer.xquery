declare namespace mods = "http://www.loc.gov/mods/v3";


for $item in /metadata/resource_metadata/mods:mods//mods:roleTerm/text()
group by $item
order by $item
return $item