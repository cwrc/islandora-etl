declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace oai_dc = "http://www.openarchives.org/OAI/2.0/oai_dc/";
declare namespace fedora="info:fedora/fedora-system:def/relations-external#";
declare namespace fedora-model="info:fedora/fedora-system:def/model#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";

import module namespace sb="exportSetBuilder" at "./set_builder_base.xquery";

(: CSV output method if XML tooling supports (e.g., basex.org) :)
declare option output:method "csv";
declare option output:csv "header=yes, separator=comma";



(: List from https://docs.google.com/spreadsheets/d/15ey4b-U2LaiBolgOoipR38rtBNff-toM/edit?gid=988689388#gid=988689388 :)
declare variable $pids := [
    "islandora:f1330e7a-778d-4919-afa7-786e7c0e5f0b",
    "islandora:1fed2ea8-83ae-4e20-9a98-f9421c166ec7",
    "islandora:95ce6a30-ac2b-4776-a243-ad762659c009",
    "islandora:31e42e32-864d-419f-84fe-8934420ee2b2",
    "islandora:e073df22-fb59-45c3-832c-d951aaae3287",
    "islandora:6f716484-f9e1-4397-a80e-e1094d608e8c",
    "islandora:a6baa954-d970-48d9-8f9b-47e4985d2095",
    "islandora:0420d279-288b-44ad-842b-aa2fd79ab514",
    "islandora:a1ce963e-3b32-4eb7-bdbf-35293825df55",
    "islandora:e610c477-4991-4c7b-86e5-a50a49ca5871",
    "cwrc:8d92cfbc-a0c5-4eb9-a87e-9a8937472366",
    "islandora:828e114e-1ec6-454a-a659-5d1aa7aa2639",
    "islandora:192f762d-ce2e-4bf9-bb84-8ef3dc04d4fd",
    "islandora:78ec8701-1967-4072-b556-f437cd8e926b",
    "islandora:88ef05e3-d467-4f76-a71d-056f4fc642d9",
    "islandora:d102f4b0-2be7-450a-aa74-370bbe88cf94",
    "islandora:48b0e8e4-d2d6-44e7-9d78-64ed543bb8fb",
    "islandora:97a0aed6-d4da-479f-a57b-5a95cae5fee7"
];

let $resources := /metadata[@pid/data() = $pids]
return sb:output_csv($resources)
