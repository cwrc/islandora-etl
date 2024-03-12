declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace oai_dc = "http://www.openarchives.org/OAI/2.0/oai_dc/";
declare namespace dc = "http://purl.org/dc/elements/1.1/";


/metadata[not(resource_metadata/mods:mods/mods:titleInfo/mods:title) and not(resource_metadata/oai_dc:dc/dc:title) and not(resource_metadata/mods:modsCollection)]/@pid/data()

(:
for $i in /metadata[not(resource_metadata/mods:mods/mods:titleInfo/mods:title) and not(resource_metadata/oai_dc:dc/dc:title) and not(resource_metadata/mods:modsCollection)]/resource_metadata/(mods:mods|oai_dc:dc)/child::*/name()
group by $i
order by $i
return $i
:)
