declare namespace mods = "http://www.loc.gov/mods/v3";


/metadata[contains(@pid, "tpatt:") and not(exists(resource_metadata/mods:mods//mods:roleTerm/text())) and resource_metadata/mods:mods/mods:name]/resource_metadata/mods:mods/mods:name