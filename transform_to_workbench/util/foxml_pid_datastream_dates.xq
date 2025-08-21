xquery version "3.1" encoding "utf-8";


declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace oai_dc = "http://www.openarchives.org/OAI/2.0/oai_dc/";
declare namespace fedora="info:fedora/fedora-system:def/relations-external#";
declare namespace fedora-model="info:fedora/fedora-system:def/model#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace foxml="info:fedora/fedora-system:def/foxml#";

(: CSV output method if XML tooling supports (e.g., basex.org) :)

declare option output:method "csv";
declare option output:csv "header=yes, separator=comma";


let $input_group := foxml:digitalObject
return
<csv>
{
  for $obj in $input_group
    let $cwrc_datastream_version_timestamp_seq := 
      for $cwrc_datastream_version in $obj/foxml:datastream[@ID="CWRC"]/foxml:datastreamVersion
      order by xs:dateTime($cwrc_datastream_version/@CREATED) descending
      (: return $cwrc_datastream_version :)
      return $cwrc_datastream_version
    let $cwrc_datastream_latest_version_timestamp := ($cwrc_datastream_version_timestamp_seq)[1]/@CREATED/data()
    let $cwrc_datastream_latest_version_id := ($cwrc_datastream_version_timestamp_seq)[1]/@ID/data()
  order by $cwrc_datastream_latest_version_timestamp descending, $obj/@PID/data() ascending
  return
    <record>
      <pid>{$obj/@PID/data()}</pid>
      <timestamp>{$cwrc_datastream_latest_version_timestamp}</timestamp>
      <ds_version_id>{$cwrc_datastream_latest_version_id}</ds_version_id>
    </record>
}
</csv>

(: 2018-11-19T21:32:46.586Z :)