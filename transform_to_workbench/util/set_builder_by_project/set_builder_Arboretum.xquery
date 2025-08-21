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
    "islandora:3bdba7b4-5002-413e-b8f6-894bc9795a79",
    "islandora:a6462865-71e7-4b9e-ab45-65d1ae81b53a",
    "islandora:29da1b07-9797-483f-a651-2bb41ff97bc7",
    "islandora:7d30a662-df16-4f13-9f6c-b2464e98ab5c",
    "islandora:292e945f-0dfd-46e1-b5f7-5eed58a7baaf",
    "islandora:2fa134f1-b62a-4c55-acbe-536a12eb29f6",
    "islandora:63c9be6f-5a53-4c48-b402-e3c6ba58e64b",
    "islandora:505a7f75-3e04-4c31-a2d2-f621c2d436a9",
    "islandora:d2d396c2-fad5-4a27-b26a-e5e7af3c2607",
    "islandora:8d46329c-32a8-43e7-aa61-1a74f5dd6f95",
    "islandora:02594da1-021c-4cc9-9f3f-96731835c837",
    "islandora:868b03e9-9f17-48bc-b90a-26f08531bdf9",
    "islandora:b20b6849-a6a4-4268-8dba-a4b340ff4872",
    "islandora:174cdca8-fb09-481b-935c-19b2c803a66c",
    "islandora:1c4665e4-4269-417c-a4b0-784f30f25f67",
    "islandora:f98abd9d-cdb7-4681-97e8-63b609527023",
    "islandora:7f14a51e-2a96-4db6-8a94-7ea93dd640a7",
    "islandora:76fc5128-ec24-4361-bb59-1f1f664305b6",
    "islandora:b85ceffd-b1e8-4fbd-8a88-782da8aa2cca",
    "islandora:85f71266-f757-4595-9570-dd17a8558024",
    "islandora:634530f3-3a54-4899-9b0b-bb528307a193",
    "islandora:12ed6572-751b-45b0-9da2-644a2d8b6d44",
    "islandora:a34cfd81-b883-4029-80b2-881e5e939742",
    "islandora:7c67891d-e0ef-4de7-9843-f0110bdcc750",
    "islandora:eeedaddd-2908-490a-82c5-9ff41ccdf415",
    "islandora:d90a21c9-802e-4d36-83e6-c0303922dfcb",
    "islandora:22aca92c-2c30-4823-ac9f-a5edb4a5c665",
    "islandora:3d342040-8e84-40e6-926b-d53426e249b5",
    "islandora:9d4bf5e5-a0fa-4360-86cc-e4aea773acfe",
    "islandora:8c82e6fd-7ff7-4c44-b374-6f8355902ed1",
    "islandora:483a7b50-7d2a-48d4-bc3a-acee79efd94b",
    "islandora:429f35e2-d334-41d6-9dc1-61751c515b08",
    "islandora:cd150d5e-8080-462c-ab90-77d9c03d7190",
    "islandora:265a46a4-9f17-41b4-a640-170253beb1f8",
    "islandora:48fe4ecf-9ff5-4e58-ba75-67436e265887",
    "islandora:44af9948-8b6c-491a-89b1-fff19ba433db",
    "islandora:cb16c1b7-4446-40b8-a49b-c59f045ff5dd",
    "islandora:a8dbecbf-2bb6-4da7-aa74-93f288301332",
    "islandora:9b68cdc0-29ee-42ba-b026-3cadd381b5b2",
    "islandora:2e8e077b-3863-4bca-9340-c52a0293e092",
    "islandora:e4f63bd9-c24e-40b4-892d-3094c6c34b2e",
    "islandora:3968d6dc-620e-40cf-bf21-84562fb221c4",
    "islandora:c874a233-89e9-48af-9a39-c234d13bb747",
    "islandora:1293242a-7f9f-4112-9d5c-1acd0b114075",
    "islandora:dd55cf28-0c46-4552-acd2-ed05a7bc422e",
    "islandora:ea242ada-b9df-434a-86ee-81b7d7067a26",
    "islandora:649a1ff2-9838-48c1-ad94-888e197ec3a1",
    "islandora:7712e240-724f-45ef-acd4-e1cc07ac928e",
    "islandora:a10301c4-199c-42df-b6a9-266b336b04c7",
    "islandora:b050d886-94e3-42fa-8d3d-f69ac8ce5e05",
    "islandora:74071bc8-ad2e-4379-9919-0ab26cc1e638",
    "islandora:ca791dfe-d6cb-448f-adee-d4459dec54ea",
    "islandora:d9b405b7-1be1-44ec-999e-932f4746a141",
    "islandora:27fd15c9-ee41-4530-a266-1939d504a911",
    "islandora:8b9e5104-846d-4433-b5c2-79ad48a34ef2",
    "islandora:edd8e009-ec85-45f8-9395-e17ea2edf4d1",
    "islandora:57704898-33e6-44fa-8031-51db6422c421",
    "islandora:361be498-69c7-44b7-a035-ffa4543bec2d",
    "islandora:82cb3aec-3e36-4e97-8461-7830c40c6909",
    "islandora:eb6546a9-95ac-4352-af0c-870e5a636d19",
    "islandora:a9d62e2c-d6f7-42b6-b56f-f5b2272ab5b8",
    "islandora:d6ca95eb-3414-40a1-bde8-a2e544fbe33d",
    "islandora:6d8b8844-f55a-453e-a873-0bae75f255ce",
    "islandora:97dcd7d6-3549-48ff-b938-452946a993bd",
    "islandora:6802893e-ae10-4da9-b39b-b1600546d5b0",
    "islandora:47fddb47-bc48-4694-9ec7-e53b1724db88",
    "islandora:a877499f-0d95-46df-901f-97242ef86408",
    "islandora:76d7d5a9-e433-40f5-a9b4-cf917eb45842",
    "islandora:142db1d4-b89f-4de6-8b7c-3296f3206b32",
    "islandora:08cbed11-ca6a-46d0-9950-2c2521447be0",
    "islandora:119e403c-e09e-4ad2-b3b5-c63b053e3018",
    "islandora:3db650d8-3e64-4da6-831a-cb902140dc0d",
    "islandora:34420f31-abc6-4cdc-afea-7e87a148fe3e",
    "islandora:8ec96780-7a13-419b-bd52-bfb3a0d12862",
    "islandora:0ebbf1a3-fc12-4c8d-982a-6f67cada86d1",
    "islandora:817d849c-8046-439d-a9df-42ff1aba9f75",
    "islandora:d2bf0946-b882-44d1-98d5-b23d9094616d",
    "islandora:c8c79a1b-b5a4-40e3-a476-28c498245bd5",
    "islandora:833231de-f84b-4df8-894f-aeeafc8d5997",
    "islandora:21fb35df-8d94-4e27-9da4-fb84f3d1f59c",
    "islandora:56339470-33a8-4c40-9563-2c675c34efb3",
    "islandora:1fd6835b-414c-4190-82c2-81b953e6f823"
];

let $resources := /metadata[@pid/data() = $pids]
return sb:output_csv($resources)
