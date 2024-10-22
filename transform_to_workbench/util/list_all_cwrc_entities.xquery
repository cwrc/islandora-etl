declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace oai_dc = "http://www.openarchives.org/OAI/2.0/oai_dc/";
declare namespace fedora="info:fedora/fedora-system:def/relations-external#";
declare namespace fedora-model="info:fedora/fedora-system:def/model#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";

(: CSV output method if XML tooling supports (e.g., basex.org) :)
declare option output:method "csv";
declare option output:csv "header=yes, separator=comma";

<csv>
{
  (: :)
  let $resources :=
    /metadata[
      (resource_metadata/rdf:RDF/rdf:Description/fedora-model:hasModel/@rdf:resource/data() =
        [
                  "info:fedora/cwrc:person-entityCModel",
                  "info:fedora/cwrc:organization-entityCModel",
                  "info:fedora/cwrc:place-entityCModel"
        ]
      )
    ]

  for $i in $resources
    order by $i/@models, $i/@pid
    let $media_export_array := array {
      for $media in $i/media_exports/media
      return $media/@filepath/data()
    }
    return
      <record>
        <pid>{$i/@pid/data()}</pid>
        <model>{$i/@models/data()}</model>
        <label>{$i/@label/data()}</label>
        <media_list_json>{json:serialize($media_export_array)}</media_list_json>
      </record>

}
</csv>