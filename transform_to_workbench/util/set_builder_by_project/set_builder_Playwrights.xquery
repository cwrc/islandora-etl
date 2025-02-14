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
    "islandora:b0b967a1-4226-4ba7-9040-4ca8cb256a97",
    "cwrc:f52b2b67-3847-47b3-b372-256db410db30",
    "cwrc:playwrights_project",
    "cwrc:fff44d46-ec9c-46f8-9ef4-2d25c53cc3cf",
    "cwrc:d242b3e8-bd59-45d8-862e-8d6e3a5fc9e7",
    "cwrc:playwrights",
    "cwrc:26b7f88e-d453-4324-90bf-c167aecd76bf",
    "cwrc:e1b105f4-94b0-45a8-bf99-d72d8952863f",
    "cwrc:8fca2aaf-6a15-48b6-aa27-f9f83cf16e92",
    "cwrc:0c9c1f2b-5787-4df4-9234-e4f02c916f12",
    "cwrc:db7ebd60-11c8-47ea-9f22-9d4ba0a701fd",
    "cwrc:b43f05d3-f25e-4a60-aca6-d6e8ad6ec776",
    "cwrc:afab8f94-42b1-48e5-b7d8-b5a8ffb1284d",
    "cwrc:417e5fde-4f6e-4019-8d36-d3a7b1fa6c10",
    "cwrc:af1e11da-7146-4368-ba02-158e49062526",
    "cwrc:b9736f71-9835-4172-9361-859131b4c17f",
    "cwrc:0eff270d-f4da-4f36-81db-64fd85288ba0",
    "cwrc:7334d91c-3533-458f-a84d-fa14f41e61e1",
    "cwrc:b49e0cee-bb80-4ba0-b6d8-7010e620913d",
    "cwrc:82200494-b175-4b18-b765-b13a78f300c5",
    "cwrc:6b9cf609-11e2-4bc3-8e58-6e126ff74bf3",
    "cwrc:59c0e6e3-2f40-4d8c-91f0-925cea1e1be2",
    "cwrc:2e0f1ea0-253d-48d2-bf2d-fbcd9e40b256",
    "cwrc:d66bc16b-b93e-4c85-8445-b45b017a4589",
    "cwrc:48d32cac-d571-47be-bbda-91a9f6c9a3b8",
    "cwrc:95c0e2e8-83b5-4583-a776-47f6a20dd880",
    "cwrc:0ccc6dc0-b6ac-44a7-bc41-7a888222caf8",
    "cwrc:13022366-2320-46e6-8754-b14e2942c342",
    "cwrc:09ce9511-5cfb-4d71-8ff5-3aaef2bc782e",
    "cwrc:5a6fdcbe-4e6c-49f0-a1d6-12f98af9f41c",
    "cwrc:0fed2336-78d8-4e69-a104-7048835bbfa5",
    "cwrc:972a6773-07fb-4bf5-8ad4-8ec9a5595497",
    "cwrc:429933aa-69d3-4ea4-bfa4-25cd3be1fc64",
    "cwrc:d666bb95-aa26-4a37-a844-b870d2401a65",
    "cwrc:df333ed8-5462-4264-b401-2b98723e6075",
    "cwrc:8c93a77b-93fb-46ae-93e1-d76d2bfa98ad",
    "cwrc:7718bbb4-1e8b-4091-8385-5bf53abf6625",
    "cwrc:4ba7a959-494d-4c1b-8562-6e157e31b286",
    "cwrc:649155a1-85ac-4c10-8678-67b3636b7232",
    "cwrc:b02e1a02-51fc-4e5c-8214-e0e9c4605aab",
    "cwrc:680696c6-f89d-404e-bb41-f65740ce9173",
    "cwrc:09e65b7f-a837-480c-8195-26f2afeed330",
    "cwrc:a473c18e-6663-41dc-8734-1924409a4b29",
    "cwrc:67c449c9-674d-4b73-9f73-ef29918b1594",
    "cwrc:2ee08141-06c5-4ae8-ad0f-7e8d9e6f3fe6",
    "cwrc:3ddd0d8e-908c-47f5-9c75-4f7f6ba8923e",
    "cwrc:d17fb0be-ad55-47b9-8181-682ad13dfd08",
    "cwrc:1f59e5c9-63bc-44e2-8146-e612d9aa9a7a",
    "cwrc:8c6a177d-aeec-4597-a96e-debb39125270",
    "cwrc:c405bd27-e0c0-4368-8556-2bc0de5e6d65",
    "cwrc:2080950b-f156-4f60-9270-d89199638d34",
    "cwrc:0fa0d13b-d9d6-4b6b-af44-88a4a2c43ae6",
    "cwrc:ef762408-0a5d-4ba9-9898-5776114b45c4",
    "cwrc:23cd1dd3-fff6-4e54-b38c-f726176bdc1d",
    "cwrc:8625b6cb-d43a-4d37-88d9-80bb2b71cd45",
    "cwrc:53bf983f-2025-4c27-ae1e-86ddb0e11645",
    "cwrc:4f42d093-3f78-475a-9f99-1ebf7f5b94ad",
    "cwrc:3ee994d7-9d38-4c4e-a926-8006b7b67db2",
    "cwrc:c90beef6-75ce-44aa-8c7e-522c3abe5326",
    "cwrc:84f3002b-bb69-41a1-9c7b-04aeb2a1126a",
    "cwrc:23249e87-7da7-46a1-93b8-4fb620924d1a",
    "cwrc:2b7dd783-e77f-4ef1-b4c9-9ae19a8bb9f9",
    "cwrc:e636be74-92f7-4c22-ab66-646e3076abe3",
    "cwrc:d32c7967-acc6-4e23-b441-56d59a4eb7c1",
    "cwrc:8d0e3d0a-0ab0-4bcd-8746-4c760c9214b3",
    "cwrc:ef4347a3-aac6-45e1-8476-c982b8b4d9bf",
    "cwrc:c1b8c515-ab2e-40e0-b41f-62f0afffd254",
    "cwrc:47201086-bcb4-4716-9452-8fd49663555b",
    "cwrc:c90bb99c-7478-42b1-8c33-28be723435e4",
    "cwrc:0e2c5a02-6314-4d41-b0bb-c9e8a59e4370",
    "cwrc:dfba949c-f8bc-4467-96eb-5e9ca125bb94",
    "cwrc:845ef767-6ac1-44a4-a8c1-c6368176238b",
    "cwrc:c172a8f5-8739-4943-8594-9cde5e21b9f4",
    "cwrc:6d862c98-2188-4ad4-8eaf-8ead1e1a4331",
    "cwrc:9bb1eccf-dde6-4875-9b55-f8da23648e98",
    "cwrc:ecb0fe87-de36-4d73-9bb4-ef2eb106f92b",
    "cwrc:b33650c6-5d65-4017-a995-a22ee3d725a2",
    "cwrc:894fd9e3-03a8-46a3-b4b1-deb7a4f5aa05",
    "cwrc:2e3158dd-8b4e-4481-871f-ea3ce4922816",
    "cwrc:e20fbe77-f383-4beb-8114-f683750504af",
    "cwrc:c2fdd554-a5f0-43ce-b0dc-79b710c624e0",
    "cwrc:9e88daf9-b46f-40ed-add8-987c3703e63a",
    "cwrc:a99b876b-08f4-4dd8-8dd1-81ae9c1afd31",
    "cwrc:2c1b644d-1e5b-46fb-bf0b-15a74a2a6525",
    "cwrc:cc2446de-69e6-4083-916b-a4aaf4b9eefc",
    "cwrc:5592964f-b3f1-4f93-8781-b5d3e895f063",
    "cwrc:9517d524-caf9-4826-bd13-dd013f8c479c",
    "cwrc:2d35e129-e8f4-4275-bfb5-75ef81e0b668",
    "cwrc:a2b9930e-41e8-4441-8168-26b7ed283a1c",
    "cwrc:a5df22bd-34f2-43e8-9a5c-198db2423cf4",
    "cwrc:4a949795-c585-45af-81eb-c07024b540a9",
    "cwrc:4850f736-b779-46d6-8122-8d212c4080a2",
    "cwrc:88b20d3e-5553-478b-bfcb-5f7aa01a76ce",
    "cwrc:7119a11e-bc28-4cb9-86a6-41715f03a192",
    "cwrc:645a79dd-a88b-4571-ba8d-67810e674bc2",
    "cwrc:33bad426-6c81-4855-9349-27a6b9e59d62",
    "cwrc:a3ed213b-c4aa-4ac3-bfb0-fdcabc62bcba",
    "cwrc:ec0c6f4d-7668-4076-a69c-c259774602a4",
    "cwrc:2951c05d-d876-4194-acb2-4448408eb0a5",
    "cwrc:11400597-b38f-4594-9b12-96fdbb470f6b",
    "cwrc:007d73ec-b901-4815-9514-05a83f9ea9cb",
    "cwrc:bfd842c8-8233-4c14-9b73-e571ff0ee3be",
    "cwrc:025d7633-dc1a-456a-9ece-2de6e20f6604",
    "cwrc:0e6ffb95-572a-4990-99b2-134efe3f6237",
    "cwrc:a30610bf-cf3c-4d13-904c-77ff1204d312",
    "cwrc:457c5b25-9952-4d84-a1af-6827a4ff58ce",
    "cwrc:96969717-b5be-4219-808e-dc1c994f7ec3",
    "cwrc:0150f44d-3ccf-47b7-a845-666c274657ae",
    "cwrc:8de800d1-ebfc-411b-b583-15febef512f0",
    "cwrc:482d93c4-6ada-4ec4-9702-e252c429b321",
    "cwrc:3ae22fa8-56b3-4e94-b8b6-d9c5a6c60b35",
    "cwrc:e31a270b-2ba2-407c-810d-37fe6a705d8f",
    "cwrc:de3707c8-dee3-42e6-89ee-5e199d3a5064",
    "cwrc:c228d8d9-51c1-4998-94dc-686336afd2d6",
    "cwrc:0d01f74f-1bef-4515-9acc-c545b61b32b8",
    "cwrc:f5c88d44-19d0-4854-8de6-0bc1259908be",
    "cwrc:225f25f5-7383-4bc9-a547-4273a60633c6",
    "cwrc:d09ee929-bfa4-4b3f-b465-a8cec8f34ab2",
    "cwrc:576b2e05-8789-4f32-885f-df177d99f9d8",
    "cwrc:5fbfba14-0d80-42ad-93b1-7a357bff375b",
    "cwrc:380e3549-dd71-4f8b-bd9f-326f5a82dfd5",
    "islandora:4544a4ff-57aa-4726-859f-4446e5da3ade",
    "islandora:c29e8d9f-e129-43fd-89a3-6aaa96549aa8",
    "islandora:048c1fd5-312c-45af-8f8c-51ede77f7312",
    "islandora:b7246915-f299-4aab-a9cf-67fd0ca9b903",
    "islandora:d09b9db3-c496-4535-a99d-7085980bec7e",
    "islandora:64b8cc31-5e05-4f94-8131-3b71ea821671",
    "islandora:7b5f22ea-d7d1-4e12-9f21-ddf89b7e00e7",
    "islandora:1569c82c-91ca-419f-9b19-0581b71bf494",
    "islandora:38d2451d-b31b-4af1-b569-b5795fef870d",
    "cwrc:50fcbeeb-c4f2-4788-9190-528f5b61abe9",
    "cwrc:5e7569be-c723-4277-b223-6195bbebf07e",
    "cwrc:31be2363-c95f-4a52-8b8b-9bdc07ac894b",
    "cwrc:497c12fc-7dcc-49bd-93fb-e06cc062e79e",
    "cwrc:0caf54dd-5196-4642-8212-35dbb056f512",
    "cwrc:1b6eeaf6-cfbf-465d-a720-9cd29250692e",
    "cwrc:943c1617-538c-4953-b6b3-6321cb462f23",
    "cwrc:e08da5dc-ff32-4ee0-a5d8-d0ff0ac237fa",
    "cwrc:5bfa8adb-fdc0-4095-8da2-ed112bf5ca31",
    "cwrc:9c6cc2ef-7c56-4f5d-bdaf-06d78e51c385",
    "cwrc:c5954134-2774-4305-afe0-0f91f739bb11",
    "cwrc:712dbbbb-cbfe-4209-b3b9-d9ce6b46c66f",
    "cwrc:468e3a9c-28de-4bc5-bd75-ea5cb6f46566",
    "cwrc:9c742ce4-eac7-4ada-9bc9-bb58ab391fc8",
    "cwrc:46352ad1-f1ac-4dcc-8665-ec2351740b98",
    "cwrc:2c0bb65c-a2fd-40a2-9ce9-8bcf20867a53",
    "cwrc:3218e6d2-5512-430a-bb43-601171d7d16c",
    "cwrc:2f809a71-9667-433a-b51a-a119d44f53b7",
    "cwrc:9a015d86-1e3e-41f6-80b0-9d11554c52bc",
    "cwrc:c724d347-f236-4a24-9394-56a0502b3865",
    "cwrc:188e1978-a832-40da-8ed1-95e35e9ee99b",
    "cwrc:e15f5058-7fe9-4ada-aac9-7061e753924f",
    "cwrc:304d4110-eb8c-4558-9c5d-6ba3924685f6",
    "cwrc:17eec1cd-d73a-448c-a0fc-f8247e6e21ba",
    "cwrc:6ec9b954-23f6-46a5-8cbf-0c8b229d8b49",
    "cwrc:c81e6ccc-ed30-44cc-acfc-e0f3da9ef2aa",
    "cwrc:5755dd7a-086d-43a8-8039-1bcb27b73c08",
    "cwrc:0b84dc1f-5f5d-479e-b843-9c63b37c3b85",
    "cwrc:92f58bb9-619c-4370-8d9b-0b6ef611811a",
    "cwrc:84e22608-a753-4737-a83a-cc77459da21c",
    "cwrc:ac9f9afe-d3ea-4a6d-bd9d-d9f89932a156",
    "cwrc:4b563ad2-b510-4430-8443-d5b82abbce13",
    "cwrc:a62a173d-dcf1-40e2-a58f-38c522a35d91",
    "cwrc:09366c4c-68a9-4eef-b6e2-a7209ed21bcd",
    "cwrc:f9e5f9de-35ce-4101-bbca-331d6556001c",
    "cwrc:1fce8de0-34ce-47d1-93cd-6c4ac8e5134e",
    "cwrc:e3715e12-8792-4c68-a91a-528f865dccf3",
    "cwrc:b6ee7b77-48a1-48ea-ac85-f6943c6f4a1f",
    "cwrc:fce7907a-92cd-40bf-a8f2-6c9395595ea4",
    "cwrc:9ed73cd9-8daf-4709-bb73-284d66399afa",
    "cwrc:459d7b97-59ca-4225-beeb-762ee6a0a6f7",
    "cwrc:02be28a8-68c9-4d09-b1b3-85b3a1913961",
    "cwrc:0f59356d-c29a-4bdd-bc57-0fa6b482a029",
    "cwrc:de84469e-e8aa-43de-89c9-c761ba681176",
    "cwrc:80c9ecdc-4ac2-4e75-9fc8-dddd4eadebe5",
    "cwrc:357f08d3-ad8b-4fe4-8700-175cee89c646",
    "cwrc:dc8174d5-4b1f-4333-8050-a6cdea7574da",
    "cwrc:744938d0-4816-48e5-87bf-5b506ca88795",
    "cwrc:e8b84154-ad50-4f3a-8f81-f4bbcd655d59",
    "cwrc:25769106-0643-432d-8981-884892f026fe",
    "cwrc:762c334a-052f-47af-8360-4caf5b6c4c44",
    "cwrc:a445552e-204b-4372-900a-f2119bf7e6e8",
    "cwrc:e05c9c85-2048-4215-b26a-207065974054",
    "cwrc:523b9820-7ef5-4c4d-8704-6e5af5adfe7f",
    "cwrc:4b60d89e-6509-44bb-b4d0-94c4a5c222d5",
    "cwrc:35a00892-912c-49d1-bf72-7f6cc67a42c1",
    "cwrc:759d5bf1-fabe-44da-8581-11d9e6a38e76",
    "cwrc:628cfbde-5d77-48b8-9703-752b21bf7157",
    "cwrc:f7c4440c-5155-451d-8dc4-2acaec5e391f",
    "cwrc:19c583db-3232-4568-ac18-b8353c477278",
    "cwrc:00ab6fa9-f40f-4812-a308-1c1e14d17f3e",
    "cwrc:f9b7e489-d7b9-48dd-8635-e9a585e27b18",
    "cwrc:5eb4cd5b-15f9-4cca-ba17-a463094072fc",
    "cwrc:869e2476-219c-4bd8-b980-2bc92bb1706e",
    "cwrc:18045a1f-ec98-4319-9267-def99e05599b",
    "cwrc:1ecfa870-49af-4885-8647-eff6b7782c42",
    "cwrc:5b041677-0677-428c-b6a5-7706f1b5e011",
    "cwrc:7ee4eaf8-8335-47ad-b537-30b470166b72",
    "cwrc:ccb38bb2-eae9-4c44-a09e-46bc32c63d74",
    "cwrc:d18c551a-0e22-4392-b666-c14ddd5982ed",
    "cwrc:f7c642f5-7742-4553-bf2a-cbce3e334f5e",
    "cwrc:fac769d4-6f74-41aa-9d3f-647885908b4a",
    "cwrc:5fa5c55f-4bb8-46e3-891b-10c6fd8d05da",
    "cwrc:e8a37f15-c965-4a89-9407-8d03753a6910",
    "cwrc:7b5f9523-bb9d-48b1-a5a4-d95dbc3ed62e",
    "cwrc:3892d5ae-8e26-4296-9f47-7c4b07a3c0ad",
    "cwrc:4afca9a9-aa85-463e-9ceb-b35688aaa5df",
    "cwrc:5214a9cd-9669-4ba2-805d-a55c82b54354",
    "cwrc:deba3b43-ce63-4685-8251-1b324df9fb6c",
    "cwrc:a61daf29-34ae-47dd-be40-23763cfc7dde",
    "cwrc:f6194c28-a744-43af-b246-7e8fabe6ff6c",
    "cwrc:820d2f8f-cd59-40c4-803b-570f047f3927",
    "cwrc:75e83c8d-0869-4278-a37a-039377629df0",
    "cwrc:c290dbef-865e-4988-8754-5a458851d02e",
    "cwrc:0101d0ff-ed3d-4793-88b2-2b498798cf17",
    "cwrc:24351e6c-f622-41fc-af5d-c57c24edfaa5",
    "cwrc:fb3b5c62-0fa2-467f-8450-e704f809309e",
    "cwrc:46fd0dc4-117b-4586-805d-9a9a9d5d0121",
    "cwrc:104711c3-9a86-4fd8-a619-84b159703d59",
    "cwrc:e01419d8-c485-4b03-a4a4-4c9f31db46e8",
    "cwrc:48f1e8d7-f574-4fe4-b1fc-46f004a2dfe4",
    "cwrc:5b4fcda5-5126-469d-ab2a-5fbe2bbfe820",
    "cwrc:74e8fe49-6402-4f47-b313-b61419d65141",
    "cwrc:c3086571-faf8-412f-a44f-a704d8adbbe5",
    "cwrc:bfa4951c-fda8-43a6-9d21-8681f89d9727",
    "cwrc:b6781098-c142-4f41-838a-5f7f6eea4136",
    "cwrc:1b6e24e1-58de-4eff-bbe0-8171820d0bc5",
    "cwrc:5e55b29a-a605-4a1d-829b-244df1878ba1",
    "cwrc:5c5fa716-7529-481d-a4dc-741b5f2d4ac9",
    "cwrc:dd8b6d7f-268e-4ce3-8c64-8d6bc6bf28e9",
    "cwrc:f9fb62eb-bc28-42fc-8cb6-9486c51311e3",
    "cwrc:fdc5386b-7858-49de-bfd5-5f70561a6851",
    "cwrc:cd162937-dbca-4584-9aa4-461c60ecce90",
    "cwrc:fd91dbc7-b9d9-40c4-a2e6-733cc68e317e",
    "cwrc:de6312fb-db03-4846-bdec-8350644691c7",
    "cwrc:9fc0cddb-7878-41d8-8a6c-29d33f85b225",
    "cwrc:f5cf897f-c7e1-47cf-a35f-e7de3446bbc2",
    "cwrc:46592b31-e4f4-41da-bb7f-4f2730089179",
    "cwrc:8f9ab5ee-9be9-47d8-9df8-6090e2e1094a",
    "cwrc:fac1673d-3819-4f98-ac9f-28cb7f23763b",
    "cwrc:d5265f22-967d-43b4-b448-5e3782d57641",
    "islandora:cdf1dfe1-7845-41f5-9ae9-df4de411438b",
    "islandora:cdd452a2-cbe2-4517-baa6-0ee6f8050c8a",
    "islandora:2db5f711-f60b-4db0-b2ae-4e477636fe77",
    "islandora:2f231508-689c-4df4-9065-ef712a74d3bd",
    "islandora:cc480194-bb6e-4a90-971a-4474dbe8ca99",
    "islandora:04ebb489-c997-42a0-b7e2-88bd15b67a79",
    "islandora:8ce20696-c752-4bb3-af31-3dafc68f2eb9",
    "islandora:50a06491-a26a-4ff0-9cff-595acdafc765",
    "islandora:6caf3168-8d64-4965-a35e-ea179356ce1b",
    "islandora:b9ebf72a-f37a-4192-b03d-3fc0f5220841",
    "islandora:33810a8e-86b1-4247-aeca-b740d74f7c43",
    "islandora:a6621292-f8f2-41f0-87af-dc2473aad35b",
    "islandora:2832f6af-486b-46ae-b732-f6cd7e09fe40",
    "islandora:82779a56-23b2-4d4c-b046-784cb12d02fb",
    "islandora:5ef88bf3-e041-493d-9b90-9308889bb1b3",
    "islandora:7cd30e77-155e-4d1b-bda4-4347cadbde34",
    "islandora:46320c4b-b294-4611-af10-1dffb26ef238",
    "islandora:673c52bf-5da6-452f-a60a-c98a745268d5",
    "islandora:aa0de99f-f48e-4285-bb02-4e3edfadd854",
    "islandora:515fde4a-5b67-4667-9850-460d6ce54541",
    "islandora:0c51590c-4589-486d-b611-dbbf62481f55",
    "islandora:30f650b9-9e13-40b2-bc3b-8cfc5aed3dbd",
    "islandora:ef848217-6adb-40ab-b2fe-08bbe58d0508",
    "islandora:e73a5128-d081-4a8c-89f8-9d6653609ecf",
    "islandora:708806d0-c7b7-4a14-afb0-650bccd30251",
    "islandora:efc1750c-b338-40a3-bdc4-d6f79e983c9f",
    "islandora:31852751-6178-4b84-b96a-b87e43f48dee",
    "islandora:e16e27cd-358e-4697-ad91-ead31f4b2bce",
    "islandora:203b0d0f-dfdf-4224-a70f-3991f41325b9",
    "cwrc:6c4be9d2-32a2-424f-a982-d49d0ff82334",
    "islandora:646fd507-9d46-42a1-b6a7-c82b5370a6e4",
    "islandora:67a6886f-6cab-422d-92ee-d52ed72ef510",
    "cwrc:3891bc3c-ff63-4756-8606-42fe4aec9b69",
    "cwrc:947e7bd7-eacc-41fd-8b19-f3f8d0cd73e2",
    "islandora:2858cbcf-7209-406c-a6fc-7dd2e21b63aa",
    "islandora:7afb464a-afbc-4144-8de9-d979daef2a5c",
    "islandora:0468bd21-4f4a-46d8-a4b3-d10b55705879",
    "islandora:de0500aa-b74d-4b0f-9d5a-94ffcbe9902c",
    "islandora:8c7525bf-13ef-4af3-8f12-4852aa5f1ed9",
    "islandora:514bb149-e852-4a4a-87dd-20d77c51d12f",
    "islandora:9b692f9c-8961-4ac1-ad96-1c130e7458e0",
    "cwrc:52832734-8f82-4d86-97ce-f6fe0ec39bb0",
    "cwrc:41ab0874-eeb9-4a11-85b2-b9c93d9c3928",
    "cwrc:1fd8c71a-899e-402e-871c-d6f9f02cfd21",
    "cwrc:d6cdf0c7-a32c-4ece-b89c-b02ebd27b0b1",
    "cwrc:cd7050ba-714f-45a9-9d56-264d9df1ae5c",
    "cwrc:2726f057-9c76-4949-8d10-eecd20b2fe23",
    "cwrc:7f4fe6a7-dcf9-4bbd-8333-8dff0cc6a2c5",
    "cwrc:02ffe367-6dc8-4ca9-85a2-aac565650d9b",
    "cwrc:cafd5fb9-4380-4835-8c00-234a46acebe8",
    "cwrc:f2d41a88-eaaa-4617-b2fe-0b7ef9cbe196",
    "cwrc:8d91d94a-7c2f-4fca-8cda-177d2555f24c",
    "cwrc:3d59e91e-1d7a-444e-b80a-cd7b2a7840b6",
    "cwrc:005893a5-fe0a-4536-8996-7358d0f5fbf9",
    "cwrc:a6601e7d-e025-4757-ab99-5589487e68eb",
    "cwrc:95d4c4c1-28a1-4fd2-91a6-dbc5394560b1",
    "cwrc:bafe1789-490e-4d54-a885-d76601939c4f",
    "cwrc:db9caf0e-7cc6-49a2-b182-383397d38223",
    "cwrc:1c1a63a4-6bf6-4b20-b590-b7c673689a74",
    "cwrc:ad1865b0-70ec-4bb2-a350-0282d47dcc88",
    "islandora:8ddf71a7-24ec-4cda-a2e3-95a71127b6d8",
    "islandora:95fb3c9f-e2a5-4471-8e8e-4e4a5203694c",
    "islandora:5bb2e1cf-f2db-4b78-ac04-0f554dc5f732",
    "islandora:546210c2-cc99-4619-afd2-cf70af222a55",
    "islandora:858b8eac-4ed9-4483-bfc1-3e730bda1367",
    "islandora:ac1254d1-711a-45df-bd6c-d68fb3637335",
    "islandora:4921c131-c7f0-4a52-8151-52f62d9c4507",
    "islandora:290b2bdb-803b-4908-94d3-dc080c50223d",
    "islandora:0af3149e-f5b0-4ba8-af63-7f6019d3cb75",
    "islandora:84955613-3ef2-4ebe-9f90-db7cbd4bd0b0",
    "islandora:074bc6da-4b4f-478b-b8a0-cd9a7b65dcfa",
    "islandora:f26496b8-e832-4dec-863d-2029843f7b98",
    "islandora:54c7c095-9b1d-4970-b68b-b8f30bedfb6c",
    "islandora:52bcfe14-9306-4bbc-b4a0-a76988ad9c7f",
    "islandora:38b1f3ea-2236-4ddd-a04a-e499b86096a2",
    "islandora:7b90ba4a-55bb-4ac8-9fe5-b4ed49041db4",
    "islandora:da59d420-d5db-4f77-b787-3ca8d6e35820",
    "islandora:0a08eca8-836f-4d7c-a049-00cf144bab5d",
    "islandora:40421ab1-29aa-4b8c-b853-85524591c741",
    "islandora:1fea0497-3683-4b8d-9bc9-b5229a32b4c4",
    "islandora:adbf7c68-0a1d-4e2c-9ff3-1f9b44121484",
    "islandora:eafcc7d4-2f87-4801-96d2-9d9ad5510442",
    "islandora:a38dd4fd-27de-4abc-beec-620756f429e6",
    "islandora:5e203528-2b18-4e7b-b821-aa25b69dc38a",
    "islandora:573b11d8-9c43-416c-9225-33b28f43e786",
    "islandora:b6769ecd-9e26-4a1a-9372-e2eca0d730fe",
    "islandora:0a98a5c1-5625-42bb-abf1-fe96e002304f",
    "islandora:0be64cd2-0f50-4875-9d6d-293b6cf8f175",
    "islandora:3812bbe4-daac-42e0-a329-08e078b5094c",
    "islandora:0a8a234d-c97d-4f19-94b7-ac9203057d07",
    "islandora:18ea8780-4816-4c30-8c38-40dd1a654dcf",
    "islandora:d21e1f46-2303-43dd-a986-80ed94d417dc",
    "islandora:e18008ca-944e-4404-804e-408bdf3553aa",
    "islandora:6d0bd495-59b4-4154-b113-2ca21123bbbb",
    "islandora:72ac4b1d-de6f-4455-8398-5351dfe5048c",
    "islandora:34e6e07d-1ac3-4401-95f3-3e4902c287fb",
    "islandora:39e80c91-a7c6-4379-8674-08a300e9c5b8",
    "islandora:12e6293c-b6da-4777-9bb0-a5e34cad5c9a",
    "islandora:db03c412-9e0a-4b79-949b-9bd61bb75bfd",
    "islandora:0019d07a-409f-43f0-9d4e-b222c128f958",
    "islandora:d7035544-8e8b-4ef1-af9e-1577ab025f6d",
    "cwrc:897d4777-4832-4b16-91aa-f58b43c17641",
    "islandora:400eb028-cc3b-4aaa-a898-f93dd9aba7ee",
    "islandora:4e54b0e4-1e89-4cb2-a416-579b8c83be6e",
    "islandora:e256ea43-a7f7-4266-9e31-7fab59939e7e",
    "islandora:da125ec7-e22d-4df5-941b-9c64952688ac",
    "islandora:8d2e600c-fd51-4f3a-8e7a-22ee75168128",
    "islandora:32e0fa66-d350-40f1-bc28-9ffe69879525",
    "islandora:e4fc4daf-237b-4ded-b8a4-c02cfef0b3f5",
    "islandora:bd0907e8-18b7-43f9-99f4-c8aa543b12b1",
    "islandora:9a897210-a694-477d-819f-21821d952133",
    "islandora:df4be89c-4048-44ab-930b-ab751e42dbb0",
    "islandora:1bcef80e-dd71-4dd3-9553-b763d3e7cac7",
    "islandora:e771f8c6-aad3-463b-8f31-95b1b871cde7",
    "islandora:540e5e59-d2a4-485a-8d65-130d93ff4284",
    "islandora:5a84a483-8767-48a4-9672-8b872e8dbaff",
    "islandora:cef3a9ec-7de3-463a-97dc-a8bdea93487f",
    "islandora:79df427b-9a40-46b4-88e4-ee4dd0126d3e",
    "islandora:aec04bcb-5883-4118-88f5-5f4a2174347b",
    "islandora:f2aa8b83-2286-4449-83fb-0671472c5182",
    "islandora:f237166f-6024-4618-8eb1-04c08246e80a",
    "islandora:92d9d15b-5948-4c5b-a70a-a5529d3c4d2b",
    "islandora:5ffbda5d-e4dc-4493-a7b7-7b0103d1e149",
    "islandora:56371bae-5ea3-4faa-8eac-5bbb3fd5d6fb",
    "islandora:ca002e9c-71e4-44a1-bd6d-d631c026b335",
    "islandora:ea0846aa-b4c0-4ba8-bd11-6d60be523d37",
    "islandora:876d8d2e-c828-4643-bc8b-2770275eb34b",
    "islandora:1c2c34a0-01fc-4961-b348-a3865194eb92",
    "islandora:27652c07-6f50-47a3-8ca7-9cd11d5d43a6",
    "islandora:eeed13e2-0f2d-491e-ba55-0033cc2ad1c5",
    "islandora:edca17ab-1cef-4b62-b5b6-12a615bba390",
    "islandora:e446e1dc-2f82-4d87-8b37-e364ad37a4e0",
    "islandora:5e3762b7-f129-4060-9ee8-1678ed2ea947",
    "islandora:6112e13a-cda7-4985-a671-d5f9192aa5c6",
    "islandora:111d489f-4add-4787-b572-423f8e792bd6",
    "islandora:d3704b92-115c-4178-ba5f-ce953328bd64",
    "islandora:4b39acfc-e561-457e-a335-84c9990d99d9",
    "islandora:0275fb5c-9451-4fad-ae8e-283b80491859",
    "islandora:67efacb0-c56f-4a93-9a7d-87a885498383",
    "islandora:0d5a1b48-eda7-4f28-89cd-1d8398d36ddd",
    "islandora:d6021f2b-eb9b-4278-a9e3-153b5c4ef98f",
    "islandora:907a2108-efe7-4a2a-9901-a7f4028255d3",
    "islandora:a1478972-0f9e-4a83-b568-b3c7e154925e",
    "islandora:919b91f1-67da-41a9-a419-6f5f26110582",
    "islandora:c44baf20-fceb-4027-9887-91e4263d48d5",
    "islandora:fb53d968-cc93-4c71-8500-d0a4e439c94a",
    "islandora:b2bbe67b-4bbe-413b-8fcc-752003b3878c",
    "islandora:6f6afc2d-864b-4c8e-beeb-e3d141be67ca",
    "islandora:22137f21-9d2a-4c4f-9b70-0d8f07f8ee51",
    "islandora:82d32cfc-0044-4e5f-9f99-feaa207c955d",
    "islandora:0fa2836d-3588-4709-a6d3-987c08b46a0a",
    "islandora:a1d43d3c-d290-4428-8d16-906188f9e9ff",
    "islandora:f29fceda-fb0d-481c-8905-4f58d3dd4fff",
    "islandora:3b0c2976-c154-4820-a472-169073d5c400",
    "islandora:a29a103e-f206-4bfa-819f-d33717b15ae9",
    "islandora:96e68fc5-759b-4cec-ad80-294920a2993d",
    "islandora:9da6b5c5-409e-4ea6-8c54-dad4645724bd",
    "islandora:491c016f-6c33-4def-b925-7a650347a5e2",
    "islandora:2268b06f-4864-4448-a38a-8e135c8a8bd7",
    "islandora:c1ec9332-a8e3-4b33-8bcf-3fbe19b56aeb",
    "islandora:08271aa7-affe-47da-8c1f-e63f4b2c8485",
    "islandora:a209831b-6015-4f38-a7b3-7c7f5e879e7d",
    "islandora:2af25c01-7ef6-493f-9a23-75ccfb1fa72c",
    "islandora:8ad27d86-9865-4c5e-813b-2baf6bf04104",
    "islandora:8f1f7db2-e611-471d-b201-dc0e405dfe23",
    "islandora:cd36df94-a138-4ce7-a3ab-e78ecb16f107",
    "islandora:741e2cb1-a549-43ef-bcd3-3ef476eb1923",
    "islandora:be6d219a-594b-4bd8-a875-da087b683293",
    "islandora:826ff457-85ca-47e2-9a1d-3d4c1f7bc6f2",
    "islandora:0447998d-36da-44f9-bcfc-4d2a231e40f7",
    "islandora:815dd988-3c37-4bed-b733-b9417c44d484",
    "islandora:7afc182b-b6f7-410c-8253-98598e2078d4",
    "islandora:ebe3340b-c83d-4abd-bb15-55a4c5f91981",
    "islandora:83515954-8949-42ab-8917-d294b7edc258",
    "islandora:4716f28e-df0f-4309-a44c-0b11dfd417cd",
    "islandora:68c8f085-489e-4a9f-8446-91107f2dd8f9",
    "islandora:f3466b4a-2cda-4db1-a329-6eedf21381a5",
    "islandora:1c2882c0-eab1-4a03-9949-bfeeb0af4f33",
    "islandora:7ebd6b2b-6793-4345-b70c-7b472e5f570a",
    "islandora:7d13ec0b-0de6-48ff-9fe4-31fed57c41f5",
    "cwrc:acc41981-b964-425d-aa1f-e71ce3e68f4e",
    "islandora:3b729647-5e55-4e8e-96c6-1c98dbe1986d",
    "islandora:ce7b0449-d4ea-4aaf-9949-b7d62ae01ef6",
    "islandora:ed490d2f-c045-4ec6-85b5-f05f5012e377",
    "islandora:ff2badf5-ce35-41f3-8ed0-1f9231f09602",
    "islandora:e8e40a21-6cb8-4b78-9f97-dfd171e8b377",
    "islandora:d92a4ee0-ba0c-45a4-baba-44eab73a2faf",
    "islandora:bc819028-49cf-4bca-b42d-85b02c84e889",
    "islandora:d15bd002-3990-4a1f-b6d8-637357b532c0",
    "islandora:7dfc7ad1-d2a8-42e2-a732-6ad4b936d8ec",
    "islandora:47e13809-cfa0-4ff0-9450-b9ed5e68c71f",
    "islandora:6e5508f9-97fa-496b-94cc-e6f197c3ee15",
    "islandora:2795463c-f20c-459c-b3eb-d0eec89d1ce7",
    "islandora:9dec6360-ac08-461e-8e4e-a1c4a37956c9",
    "islandora:636f70cf-9a36-41b5-9cbd-b99fb4d6de01",
    "islandora:2f7090f4-c72c-4cc4-8154-4207b0f8335a",
    "islandora:faa26429-8dc3-4fd1-a870-04e36135ea0f",
    "islandora:e8c5a030-e3b4-4d89-9f79-99e3830f0e60",
    "islandora:8bd2110b-cc27-487a-8654-a907006963e8",
    "islandora:194f6a1f-aecb-40be-b187-351148225062",
    "islandora:be6305d8-f215-4632-a898-f90d70348c8a",
    "islandora:c0c81093-a11a-4517-b2e2-34b538c470b9",
    "islandora:7af78645-0b62-40e8-807e-a09b6892fe9a",
    "islandora:ad2e5295-c0e5-469e-a31b-f309aae111fe",
    "cwrc:bdebd588-da9b-4316-9d99-a8055a786651",
    "cwrc:a34733fb-c7a2-4f22-aee9-d6cf711aa5a3",
    "cwrc:6af1091e-355b-4e7e-b0d2-04aac8c94e87",
    "cwrc:edd5cc54-03a5-44cc-b781-e075f21a7199",
    "cwrc:4851ea15-8821-44e3-b3fe-83a1bb938b7a",
    "cwrc:0ae2ec84-3d27-4820-ae32-5959aadcb9f0",
    "islandora:1477bc9f-3265-4581-a4b7-5fa1a601ff5c",
    "islandora:a3a9e680-47b5-4970-bcad-65b7748f7945",
    "islandora:75dde460-bbe7-46ef-8d71-1eafcddb0785",
    "cwrc:9ef4c4a9-3584-41b7-bcf3-86ded15af1e8",
    "cwrc:932b0cc5-f538-41d6-9e7f-bd834e149377",
    "cwrc:4efab26c-7627-48b1-9b54-78d5a7a7cd11",
    "cwrc:b62e2b6d-c3d7-4c67-92d8-ba33f6f49676",
    "cwrc:15b7ade0-51d6-45c9-8f3a-162b66e40b39",
    "cwrc:a313ab90-d68c-469f-b9d4-097542085046",
    "cwrc:1e832c96-fce7-4209-89cf-f469d037b163",
    "cwrc:82269d4a-2da8-4f33-b4d6-8ab46efb1047",
    "cwrc:2dfab811-5b11-44ab-8716-61551e87131f",
    "cwrc:e52a479f-cd03-48d2-9bf5-5b123b185011",
    "cwrc:ef2b8970-0bef-41a6-bcc0-33d22461597c",
    "cwrc:ca9e1a87-107c-4061-8529-98bd968e6d03",
    "cwrc:36b26253-cc4e-4d8e-802e-da53dec69e8b",
    "cwrc:6d6d0ae8-3903-4cfd-b8b6-347d7221e6fa",
    "cwrc:d3068927-5895-43a5-b432-077db522c9de",
    "islandora:81eb1bd4-bea2-4a1b-8c3c-146093cbf670",
    "islandora:c6f79594-8ca8-4b02-b4ad-aa95cda775ec",
    "islandora:911df338-1b9b-4732-8748-90177f74f2ef",
    "islandora:a2b55873-b96e-4abc-98bc-78e28ca11645",
    "islandora:ae7a24cb-6e43-43d3-aea2-6598c87d683e",
    "islandora:c24a907c-ce5d-419a-bf82-e0d137cc97b6",
    "cwrc:6c096534-a60c-41bf-9baa-4b2aca91601e",
    "cwrc:263e10bd-371f-464f-81a0-0f06938b66c1",
    "cwrc:ab2429fb-47ec-4ec6-a431-069961188c39",
    "cwrc:4409fc8b-991a-49e5-9632-b353160fbcad",
    "cwrc:90f561fe-4eb1-4eea-9b19-37e132733c45",
    "cwrc:86d1a3bf-c9f0-4689-ab94-ebd214964683",
    "cwrc:a33ff8e0-5e74-4d66-b8f1-47617f23b240",
    "cwrc:5092dd4c-65c2-4b12-aa19-b631de42c5fd",
    "cwrc:4d79fcc9-3da8-40b8-94ee-9647a5f9dbaa",
    "cwrc:2d07b343-3b49-409b-80bf-7bba1e34401e",
    "cwrc:c2532ac8-b8a8-4230-9677-ebe4ce6f6d39",
    "cwrc:1a3bf2ad-498d-4885-bc36-8410f4d1b43a",
    "cwrc:ea9b82f7-ec0b-4d7b-aea9-ba27df560ca6",
    "cwrc:88f7e7b5-066d-4884-9516-07139b98e4be",
    "cwrc:9933f98e-4f87-4e74-b652-618a179f37d9",
    "cwrc:657b3121-c73e-485d-b777-b5077d2a9a1f",
    "cwrc:a5a285d1-a2f0-4916-a072-88e3bc99a320",
    "cwrc:f02aff00-fa92-4aa3-b29b-a3edfee94a03",
    "cwrc:1edb7823-6b84-448a-8943-4439d8dec796",
    "cwrc:c0a77962-220e-4747-a60b-04886fd2e0fb",
    "cwrc:68dddbcf-bb75-4e2b-ad84-c27d8317ccea",
    "cwrc:9d0b3aa6-19fe-4c61-b3d6-4a0157dc9e3b",
    "cwrc:5a3b69d0-8ea7-440f-8965-3f42b1086d66",
    "cwrc:966bc4bc-701a-4338-b45e-554a89a779d6",
    "cwrc:f3a63f8d-5518-4220-96ef-6f4adbb84880",
    "cwrc:6c7bd174-add0-4ba7-9c16-a2083ed5f7a1",
    "cwrc:7164ba1b-72ac-4367-8239-772540f703ba",
    "cwrc:c2396df4-f31d-450c-a073-db2c9a6c2fe7",
    "cwrc:090401eb-8d79-4b2f-b61b-a12e1de39ea6",
    "cwrc:df81607e-bb59-41cb-a5f5-0e068a49a37c",
    "cwrc:c0bec961-6440-4ffb-a368-c4e309eebdf1",
    "cwrc:c8af09b6-7390-4dbd-83d1-c91b1358671d",
    "cwrc:066d48b2-0fe2-4caf-bc91-9653ce45860f",
    "cwrc:a2c851c1-74d1-4336-a130-7aff02a86a51",
    "cwrc:7843d736-6acf-4530-94d8-6a27f054bbdc",
    "cwrc:a2331a8f-c7c2-4fc8-abc1-e65d7067e6f2",
    "cwrc:c122c537-1716-49ad-90e6-528a299e26e4",
    "cwrc:280e145b-9cb4-48eb-a7d1-2a4d66414870",
    "cwrc:a09e2e55-0e6f-4f22-b2d0-23167836c553",
    "cwrc:8aabbf16-896b-49ec-a055-c33df17d128c",
    "cwrc:e2a5c645-a129-4556-8d01-62a76d511b48",
    "cwrc:fdf43e95-6a29-4ea5-afe6-b742e453808b",
    "cwrc:8660a85c-d76b-4c34-99e5-bd5a5510171b",
    "cwrc:24e53767-6ec3-4d66-b38f-bb7b92129bef",
    "cwrc:a076a1b7-9eb5-4a1c-82a1-4579199c7a99",
    "cwrc:c196cc24-8687-4c13-b316-90d5cb2b2d57",
    "cwrc:91921afa-af8f-408f-b36f-6c809f575de1",
    "cwrc:8416968b-af54-4f35-901d-c64db99c81b6",
    "cwrc:a4847a81-a372-408d-acde-be25cf448fb3",
    "cwrc:da12d45b-c57e-4d8b-a8ac-4f2217a1b5ed",
    "cwrc:de2e22ac-1f6f-4ac6-9c3f-9804807759dd",
    "cwrc:a1418cca-cf34-4d37-a9ce-61547aca5267",
    "cwrc:60093851-6187-4d70-8b61-3771ff9366e3",
    "cwrc:f81b76f2-27fe-4153-97a8-ce114b5a4c3a",
    "cwrc:1aad1a92-361b-471f-b79a-3407a89a23ab",
    "cwrc:9b304650-7414-4e17-91aa-073b6922d8de",
    "cwrc:f2c336a1-901c-4499-9bba-3bbafbbac424",
    "cwrc:5ddbe017-d158-474c-932c-9a863d125237",
    "cwrc:302f5259-67fd-4dee-b0b8-57ce7a57b6f2",
    "cwrc:aa506d53-7472-427c-98ce-e030b80798c8",
    "cwrc:977dbd3e-beb9-45ba-ba11-1814f8b46101",
    "cwrc:8cd8d7fc-6b36-4c3c-b5f1-e36679102174",
    "cwrc:8085a40a-c336-4348-8007-dee4bb698e44",
    "cwrc:4b1bc2ac-b8a1-4ef9-b822-952cf76e6872",
    "cwrc:fdaa016b-e833-4ad2-bf8d-71e609cebd5b",
    "cwrc:53489234-8645-4ea4-8404-fc9589689433",
    "cwrc:d1be0af4-e817-4576-a552-7fa86d984f16",
    "cwrc:fd32d818-1717-4ca0-88c7-dda0e3b47d6f",
    "cwrc:020d7673-ec60-4bd1-ba4b-9499a5fc05ac",
    "cwrc:36d32461-ecbb-4bb3-8c2c-77c06801fbae",
    "cwrc:99f55004-af0f-4242-9e90-1ba74f84894c",
    "cwrc:98a39aef-909e-4bd5-af10-cbc70c8a376c",
    "cwrc:f5066944-eed0-4663-adc6-5c56a0815a42",
    "cwrc:4fa42493-7352-4b70-b29a-f186cfe3381d",
    "cwrc:6b4decf3-63d8-4abf-9b64-d289c529d67b",
    "cwrc:38c308d3-644a-4c91-b6e9-2b01dd5ce7c9",
    "cwrc:b4fe19e8-a930-4f2b-aacc-9d18715a5b87",
    "cwrc:69be09b9-8458-4783-b8d2-7219953e8462",
    "cwrc:1d586cc9-0f5e-4bea-a76c-3e51c1eae79a",
    "cwrc:6f249127-c19b-46d7-b017-eca232635bf7",
    "cwrc:02f44616-bdca-454a-866a-b994d081b728",
    "cwrc:fd26990b-d47b-4fd5-bfc6-5195410aa269",
    "cwrc:d1e85f0f-508c-4832-b3c1-9a4d8e10d711",
    "cwrc:fca5d3a3-512c-47c6-85cf-d85cea2876b4",
    "cwrc:23f87d0c-b07f-4c14-a8f3-3b2a5e1f58dd",
    "cwrc:e289b730-ddec-4b74-8587-f67f6d1d18e4",
    "cwrc:39ae3a8a-1158-455a-affc-7f2ce189fa78",
    "cwrc:d6bc316e-8a02-4803-bcf0-083bbe8604e0",
    "cwrc:d90f0aa4-7b73-43dc-93c6-43cab4996e5a",
    "cwrc:49b90eb2-2488-4259-a0d7-2de64353cc6c",
    "cwrc:45953659-d123-4919-b05a-89d8446f9175",
    "cwrc:67ac65a8-d948-4a28-9e6c-3509e8170a15",
    "cwrc:e923781a-daed-4e7e-87f5-66331dcdb2e9",
    "cwrc:fe855eb5-60e4-4873-b47f-1a8175cbe6ba",
    "cwrc:adbc5d33-1646-4709-b726-bc7a06b12421",
    "cwrc:caac6980-88c0-4e52-8240-d0432df21b6c",
    "cwrc:34a810a1-7f17-43df-8dad-57b09511e6ed",
    "cwrc:5d4f31d2-deb2-4d99-afcc-e69c7bf125e4",
    "cwrc:50d3a722-93c7-45ea-8dbd-bc947aad64b9",
    "cwrc:27313f00-1d5d-4a6e-ad6d-d23925055f72",
    "cwrc:f46cfdde-beca-4620-addb-2a218a6b0784",
    "cwrc:1041ab11-7dd4-4f7f-b1d1-0ea77613f86a",
    "cwrc:855d03c4-5051-42b5-a1b0-cddc690feae1",
    "cwrc:2dd67471-bb91-4b6d-b03b-d324d8285696",
    "cwrc:33598254-9f43-4ab9-8d3d-cdbbcf40fecb",
    "cwrc:94010b47-254b-49d4-9614-522e7cd42ccd",
    "cwrc:ec1aa4a7-15bb-4741-b9f1-83db9c8ca178",
    "cwrc:ea424e87-a65d-47a6-b462-f4cd828f2168",
    "cwrc:b2ead425-8656-4ee1-bbd4-765bdbf2a27e",
    "cwrc:2f30e5d9-f51d-4ad4-ba1d-983dddc6bb97",
    "cwrc:9d6ef293-49d1-43b3-94dd-43bfa942ea2b",
    "cwrc:52415d22-68cd-4d33-a739-783bd8ac409a",
    "cwrc:aa75579a-c7c8-48dd-9672-67ee35a55332",
    "cwrc:ced2f96d-ab47-4c93-b5f8-108137a27bcd",
    "cwrc:bfa97287-a1bb-4210-b4a6-bc5fdbb0162a",
    "cwrc:88db149b-3600-4aae-9890-bfbbf854b5a1",
    "cwrc:878ac547-38de-423a-b756-82619068bd61",
    "cwrc:1bd28d8c-eecc-40b9-9a97-c5bdf026acd3",
    "cwrc:9976182a-be91-45f2-b2c5-f4a842b53357",
    "cwrc:33d1d2f1-bb7d-4c4d-bfe4-bbe329c83983",
    "cwrc:d19f406c-f465-43a1-b7b9-c6925ee4fb3b",
    "cwrc:4db88dc8-ac30-41a8-8f87-d0ca765ee67d",
    "cwrc:4b84cbcd-36a8-410d-8e5a-339fe49b12e8",
    "cwrc:8a253796-4846-483f-89f5-b214058eddac",
    "cwrc:7f16f60d-589b-42fa-bdf6-d163f9978bb6",
    "cwrc:53af7fef-a70f-4261-9e2a-aaa4d75a75c5",
    "cwrc:9e318a4e-b3fb-427d-a7ba-d49e50d7906e",
    "cwrc:3ef9af88-9b8a-4d30-82d2-e27b8367b02b",
    "cwrc:61baac67-3c45-4b7e-aa35-2665f7d91e22",
    "cwrc:17d1f006-ed7d-445d-b345-705149fea548",
    "cwrc:974f124e-8dda-44e5-ae9e-3d9687bda579",
    "cwrc:70541fd2-ab4f-458d-8739-c53c01c345b2",
    "cwrc:990c73af-083c-4566-87dc-0d27fb37e786",
    "cwrc:90cbacb2-b76f-43b3-ae14-b7bc9df58381",
    "cwrc:575745e1-a887-4e69-9139-539a992bc2b0",
    "cwrc:01ce9721-d0d9-441d-a1fa-80105e7dd17c",
    "cwrc:1beae63b-8272-4c31-9ff5-33dba9d1d7f9",
    "cwrc:d2cd7be8-27db-4c02-b4bb-2b6407f7b336",
    "cwrc:6ec135ec-f338-4f4a-9c65-b234013fcd4c",
    "cwrc:fcc7bf0a-9c49-4d2f-ac96-7677118bc9f4",
    "cwrc:ec01448c-fe7b-4674-b956-b4c877393eb3",
    "cwrc:91512304-1b43-46c1-a3b9-6325a739f0a0",
    "cwrc:74b4c7c3-1ab0-4307-93bf-031dc443224d",
    "cwrc:ad8b5946-7426-4886-808d-a2652f725157",
    "cwrc:89568a23-387c-4565-8d0c-18d19d610e58",
    "cwrc:5780ba3e-fa7e-49bf-80d8-625ffef4afeb",
    "cwrc:9e012ec2-7950-4ef7-8369-087a9ab32c76",
    "cwrc:a0297224-728b-46d8-a511-d642be39d10a",
    "cwrc:7885718b-62c3-4357-adef-dcac6983cb31",
    "cwrc:06af2d8e-0028-422f-b13e-79788a207121",
    "cwrc:57bc72d2-0a7a-4b8c-bb30-053aca7b8deb",
    "cwrc:632fb2d3-1443-46bc-8fde-a195a992cb92",
    "cwrc:2b910023-4726-4585-bfe7-877b5607c71a",
    "cwrc:e1d2b39d-6f4a-43aa-a88b-93a45585e3b6",
    "cwrc:b5afd2d1-65c6-4615-aeb4-c5afa9733cdc",
    "cwrc:0f495244-f8a2-4e12-a73a-73a15642443f",
    "cwrc:130c3492-a2c7-434d-8d06-5bfe9b7a6b30",
    "cwrc:2c8961fb-a020-4ea3-879e-a78dec664e93",
    "cwrc:afd43e0b-6ade-43dd-8bcc-21ff3a118af1",
    "cwrc:4619c7d2-7c1b-4043-aa73-17965cc8190b",
    "cwrc:685a68a0-b021-4060-aca9-913578a3382a",
    "cwrc:8ead6d48-1f95-4879-a3d6-eab8757ecec4",
    "cwrc:5301c883-a770-4adb-9c7a-356f5299df57",
    "cwrc:d195e83a-34bb-4acd-9fd7-908e66ff7077",
    "cwrc:72337365-7c33-47d4-b418-018f25916e6a",
    "cwrc:d9aed8be-0c5d-44cb-a277-7ec2bb66bb6d",
    "cwrc:b63df165-cf87-4818-89a4-ca6543016a1c",
    "cwrc:c988e772-dabc-45bb-816e-9c038dfdf958",
    "cwrc:d7f31787-92fb-441a-8075-1040ecf4e703",
    "cwrc:bfb4bdd8-45b2-48b3-9231-5181320215fa",
    "cwrc:ada629bf-4148-42a9-9429-404382941334",
    "cwrc:478df5d5-9b24-4695-ba41-465bb7e4e9a7",
    "cwrc:6b5f6075-d6e0-4d79-84f3-27557f8261f0",
    "cwrc:f1f980fd-67c2-408e-990f-217de9e33b9a",
    "cwrc:2856dbd9-092b-49ea-a827-d3102c938a0e",
    "cwrc:cfe1fea5-a80b-4bf9-8d04-f04788bbedf0",
    "cwrc:726b342b-ebd1-4a17-a887-bb9a25f12e9e",
    "cwrc:fd1e016b-29e5-497a-8461-0a3505af10d1",
    "cwrc:0d425eb5-7bbf-45e9-92f9-0611bdf5370d",
    "cwrc:d0bb17b1-af1e-4e5e-b15b-2232826a62a8",
    "cwrc:b180cafc-145f-4335-9272-0a659e5660fb",
    "cwrc:eeb421c9-8ece-40fe-8519-81ce5b102a59",
    "cwrc:412ae010-794d-4e0d-b431-686f0215c37d",
    "cwrc:31dac69c-0481-4539-b934-dc74c242d3d6",
    "cwrc:3ad868a3-1ee8-49d6-b317-a5746230baca",
    "cwrc:0458562a-d58a-4b84-bf1c-a32af2853236",
    "cwrc:99439bb9-4bb0-4b26-afa0-2f6a6f5fcbb9",
    "cwrc:990525f3-fbdb-4496-9309-460f6108331d",
    "cwrc:b9a7345d-e11d-4135-af0c-34ef04e1d968",
    "cwrc:ab8cb09a-b424-4a0b-bd22-a35f64b2664a",
    "cwrc:afe6cdf4-e8d3-4fcb-99b6-88587dcf0351",
    "cwrc:14c0f009-9b5b-45f0-8573-6ae8834db485",
    "cwrc:9d27ac7d-4f97-4716-8e4f-18bf391a9afa",
    "cwrc:c958f3a3-e569-4a80-80b6-c81b02209fc9",
    "cwrc:9cd43910-3eb0-477c-b1b6-c41d651ba72f",
    "cwrc:ba951bb8-dc6c-4732-b2d6-753b78a37028",
    "cwrc:5ba59ce7-a762-48a0-a107-dabb7c1c5a8b",
    "cwrc:292f68d7-6640-451e-bd27-3a93764d22ca",
    "cwrc:6d91d98a-cbc3-4470-b7aa-1d309a732512",
    "cwrc:57bbd01d-f432-4d42-8176-4a8240be6791",
    "cwrc:c4c346db-3d98-4de6-8900-d61ac610caf6",
    "cwrc:f3414c80-cca0-4fbc-a859-2a6a02fecf0d",
    "cwrc:0dd232f7-53ed-471f-810c-96c2cd1adc39",
    "cwrc:860389f9-53a5-4681-838f-2aed6743ca3b",
    "cwrc:2595ac4d-d08a-4e47-a6e8-c4f7b9f657df",
    "cwrc:30c92c49-ae9c-47e7-aa5f-9ba8bccd2821",
    "cwrc:de1545d0-0bb3-47d2-a8cc-bc0379609000",
    "cwrc:ca6d2b33-ce0d-4a39-a15f-8e8a2ca5428a",
    "cwrc:3cba5d49-5f7e-43e8-8141-a439e83d40c2",
    "cwrc:38d3b680-af3f-4172-9ca2-fcaa936cc8b8",
    "cwrc:4ad72f25-4a43-4b40-9a2b-8e82940c35f5",
    "cwrc:6ea46626-9632-40b0-aa74-ba7e7d2acd30",
    "cwrc:3743a36c-d03a-4171-88c0-81e73c314b75",
    "cwrc:120fbc8b-d816-4927-9195-030b18bae1d1",
    "cwrc:a20c7005-fac8-4a02-8097-4daa93e0a868",
    "cwrc:413f52f9-fdc3-4fbe-ad8b-f7bda7208de4",
    "cwrc:d922edbe-6cdf-4a5a-a9d9-9bb285f923de",
    "cwrc:3b99f638-309e-4a90-ab9e-f9f6c9b7aea9",
    "cwrc:315039ea-daf4-4f1c-a9d6-ade1e712c844",
    "cwrc:60d4d167-8780-4e97-a871-80f6c5522ce0",
    "cwrc:1a77806e-b15c-46d2-913f-85f7602cabd4",
    "cwrc:7e994f1f-12b0-4a63-b915-ee390a15a5fd",
    "cwrc:ce990aaf-7246-4c9d-85df-dc1f5da50b10",
    "cwrc:691444c9-a18c-4db5-b0da-994464c4a310",
    "cwrc:6d1fff3f-4692-4833-9bc0-fcf9b773d5c0",
    "cwrc:00a6ab52-e099-4e28-9ee6-14af12583cd5",
    "cwrc:390d3add-2ae7-4993-8b2e-846bfb3618db",
    "cwrc:aec50b09-64b8-4552-95b2-a456d44b1737",
    "cwrc:c45bb04a-8a96-4b1e-ad22-90dcc10e295c",
    "cwrc:fb4c90d1-c29c-4540-87fe-bcfc8bc237d8",
    "cwrc:a84338d4-5780-4237-9994-10364d29acdb",
    "cwrc:7d47ea26-d18a-4d55-9d54-bef4cbc2ae49",
    "cwrc:15f19260-1284-4bd6-b385-5f91391a70bc",
    "cwrc:2b7a1a6e-479b-4439-a6e7-90294fb5578e",
    "cwrc:e61607f8-5131-4d87-b4fc-4c119e5262f3",
    "cwrc:69658a84-807c-484b-a1f9-c6d218779bc6",
    "cwrc:71fb8ca7-995c-4f20-9e01-2bba932944d1",
    "cwrc:a9d20500-e42c-45b6-bfda-671703a9c5f8",
    "cwrc:212e0042-aaae-4fb4-8cbb-f8483c932f59",
    "cwrc:dffb0369-24d7-4f49-8b17-9907b5b8bf2d",
    "cwrc:788cb1b2-aa57-449d-af0a-1be524fb0abf",
    "cwrc:51f62eef-2dcf-412e-a1fe-114f717f51e2",
    "cwrc:a712f7cf-a9d2-43fb-8ead-dc96083a1360",
    "cwrc:3c457e2f-cb81-4771-bc14-e0d477de05e6",
    "cwrc:cf2392d7-ca3c-455b-80d6-9f6f7bae8c99",
    "cwrc:000d3001-efad-45ba-8ae0-89b57f9d4b0d",
    "cwrc:be12f12c-4820-4c96-9756-0c6e195440d2",
    "cwrc:b624da95-3a5a-47e6-bfc9-17f787da85ec",
    "cwrc:f025680a-162a-4d74-8c54-fb72a1a69698",
    "cwrc:1ec89092-5f4a-42d3-a64f-c2473d3a62b1",
    "cwrc:4e27cb36-538c-49ae-b155-711b7cbd2740",
    "cwrc:523bb506-e2fc-40c0-9f7f-ea2ce0f91745",
    "cwrc:da881df1-1c71-43cd-8384-a2e81f0e1167",
    "cwrc:814eaacd-be98-4b2e-929b-ad7c431f158d",
    "cwrc:5594f529-a4f5-4a16-b4e2-3d053fe9f36d",
    "cwrc:e285b87f-896f-4fcb-9984-b04c9a6c6afc",
    "cwrc:cb7f32e4-7f7c-404f-a79d-1186f8179b88",
    "cwrc:a626375b-d480-43bf-980c-3fe756e3ad56",
    "cwrc:0a23854f-9d37-42ad-96f8-e8f33e8e4478",
    "cwrc:aca009ee-7ac2-405d-8f39-af7917c36201",
    "cwrc:a4cba3dc-ef59-4e4c-89a8-c766479e6e72",
    "cwrc:49f047eb-9731-4946-a3a2-2dbb86071e11",
    "cwrc:813c439c-23a0-4cad-ae1c-5efe0e156a5f",
    "cwrc:b3a8f97e-c460-4132-9f22-51aa34137e90",
    "cwrc:b65b4a3e-14fa-4d8d-a4e7-95a66678089f",
    "cwrc:137ef3ef-f5f5-4fc2-887c-83a81e91cea1",
    "cwrc:003209fc-f35e-421b-abb3-14686cc9beac"
];

let $resources := /metadata[@pid/data() = $pids]
return sb:output_csv($resources)
