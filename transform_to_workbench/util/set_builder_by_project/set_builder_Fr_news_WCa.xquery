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
    "cwrc:cbd7303b-a483-4ca4-9955-2d9b6fafd3f9",
    "cwrc:fiction",
    "cwrc:saynetes",
    "cwrc:artChronique",
    "cwrc:correspondancesImaginaires",
    "cwrc:plaisirLecture",
    "cwrc:animauxChoses",
    "cwrc:nuit",
    "cwrc:pluie",
    "cwrc:heroines",
    "cwrc:industrialisation",
    "cwrc:traversModernite",
    "cwrc:contributions",
    "cwrc:printemps",
    "cwrc:automne",
    "cwrc:hiver",
    "cwrc:jeunesseEducationMaternite",
    "cwrc:lOuestCanadien",
    "cwrc:lesExcesDeLaModernite",
    "cwrc:laGuerre_tenirDurer",
    "cwrc:lArtDeLaCorrespondance",
    "cwrc:educationEtPreservationDuFrancais",
    "cwrc:variationsLitteraires",
    "cwrc:tableauxNaturels",
    "cwrc:porttraitsEtParolesDenfants",
    "cwrc:ephemerides",
    "cwrc:lesFemmes",
    "cwrc:laFibreMaternelle",
    "cwrc:laFrance",
    "cwrc:qualitesEtDefauts",
    "cwrc:femmesOuest",
    "cwrc:migrants",
    "cwrc:souvenirs",
    "cwrc:nouvelles",
    "cwrc:colonisation",
    "cwrc:ete",
    "cwrc:contes",
    "cwrc:immigration",
    "cwrc:noel",
    "cwrc:lettresPionnieres",
    "cwrc:feminisme",
    "cwrc:mythesEtRealites",
    "cwrc:stereotypes",
    "cwrc:amitiesFeminines",
    "cwrc:portraits",
    "cwrc:toussaint",
    "cwrc:jourDesRois",
    "cwrc:nouvelAn",
    "cwrc:paques",
    "cwrc:conseilDeLecture",
    "cwrc:dan_lombre-journal_intime",
    "cwrc:dan_lombre-voyage_de_noces",
    "cwrc:journal_dan_lombre_images",
    "cwrc:french_newspapers-archive_images",
    "cwrc:ArchivesJournauxPatrioteDeLOuest",
    "cwrc:ArchivesJournauxCanadienFrancais",
    "cwrc:ArchivesJournaux-Progres",
    "cwrc:dan_lombre-femmes",
    "cwrc:dan_lombre-vie_quotidienne",
    "cwrc:dan_lombre-ouest_canadien",
    "cwrc:dan_lombre-nouvelles",
    "cwrc:dan_lombre-education",
    "cwrc:dan_lombre-religion",
    "cwrc:dan_lombre-ephemerides",
    "cwrc:dan_lombre-lecture",
    "cwrc:dan_lombre-oeuvres_des_bons_livres",
    "cwrc:dan_lombre-qualites",
    "cwrc:dan_lombre-portraits",
    "cwrc:dan_lombre-religion_identite",
    "cwrc:dan_lombre-religion_foi",
    "cwrc:73f8e733-5222-4370-8a77-4701e1c56de6",
    "cwrc:madrina_vieilles_filles",
    "cwrc:madrina_vertus",
    "cwrc:madrina_malchance",
    "cwrc:madrina_generations",
    "cwrc:madrina_vivre",
    "cwrc:madrina_bonheur",
    "cwrc:madrina_fete_meres",
    "cwrc:madrina_epiphanie",
    "cwrc:madrina_paques",
    "cwrc:madrina_education",
    "cwrc:madrina_fin_annee",
    "cwrc:madrina_ephemerides",
    "cwrc:madrina_nouvel_an",
    "cwrc:madrina_toussaint",
    "cwrc:madrina_noel",
    "cwrc:f433b2d5-65a0-4013-b97c-7e7adf071f15",
    "cwrc:madrina_monde",
    "cwrc:madrina_art",
    "cwrc:madrina_mondain",
    "cwrc:madrina_negatif",
    "cwrc:madrina_prejuges",
    "cwrc:madrina_traits_familiaux",
    "cwrc:madrina_nature",
    "cwrc:madrina_premarriage",
    "cwrc:madrina_characteres",
    "cwrc:madrina_couples",
    "cwrc:madrina_voyage",
    "cwrc:madrina_famille",
    "cwrc:madrina_parents",
    "cwrc:madrina_patriotisme",
    "cwrc:madrina_francais",
    "cwrc:madrina_comparaison",
    "cwrc:madrina_femmes",
    "cwrc:madrina_traditions_modernite",
    "cwrc:madrina_problemes_modernes",
    "cwrc:madrina_piete",
    "cwrc:madrina_qualites",
    "cwrc:madrina_la_survivance",
    "cwrc:madrina_parental_role",
    "cwrc:madrina_mauvais_exemple",
    "cwrc:madrina_ecole",
    "cwrc:emma-morrier",
    "cwrc:madrina_francocanadien",
    "cwrc:madrina_activistes",
    "cwrc:blanche-boulanger",
    "cwrc:emma_morrier_archives",
    "cwrc:465e50bd-631f-4a7f-bd91-1009094c8cf6",
    "cwrc:madrina-chroniques",
    "cwrc:madrina_le_patriote_de_l_ouest",
    "cwrc:patriote_monde",
    "cwrc:patriote_ephemeride",
    "cwrc:patriote_defauts_stereotype",
    "cwrc:patriote_vertuss",
    "cwrc:patriote_famille",
    "cwrc:patriote_vivre",
    "cwrc:madrina_educ_religion",
    "cwrc:be81c382-6a92-41a2-9292-174d3aeb5ded",
    "cwrc:376aee05-c6b7-4cb9-9e77-031fc888ffeb",
    "cwrc:5015fa4f-33cd-4fe0-b767-8698072b6ccb",
    "cwrc:e4bd9ae4-6bdc-4569-8afa-d745d991a961",
    "cwrc:1ff335b1-dd08-4e5a-ad42-4dae8f65ac04",
    "cwrc:ff5bf076-4127-4545-b503-6e2b405e2c75",
    "cwrc:c82e5780-44f5-4304-bb3b-a52cee8b74bd",
    "cwrc:69bbd33b-8951-4b24-864b-207d86f982b3",
    "cwrc:6c3272e1-d925-49c6-8dc7-b7b8ee866ee1",
    "cwrc:ac4a9817-1256-465a-a431-a256867a7ade",
    "cwrc:4c2baa77-f223-4ac9-9649-845f2a833ffe",
    "cwrc:a96ab44a-07c4-4fc8-91b1-f0123ae6aa23",
    "cwrc:c159777f-2bf4-42a3-a054-9512b4b01621",
    "cwrc:17163af8-3708-46e3-afbc-b14621e9ed1d",
    "cwrc:9d03dfda-5a30-46af-bf68-57d2bf796edd",
    "cwrc:6576d66b-4970-4a8c-a014-e29dd012b55b",
    "cwrc:f341db6d-5fc8-4ec2-acc7-01ba128bfb45",
    "cwrc:f76d0088-f830-4d02-96a1-883d1386d4dd",
    "cwrc:e1ecaa5d-5555-44e6-b479-6bd58c7fcb2b",
    "cwrc:897c5ad3-f5a4-4a32-a0c9-fb5bba084b49",
    "cwrc:52620e74-2ebd-44f1-bc01-41ffa8fde8af",
    "cwrc:f99a5dfd-06f7-4830-84da-aca6780a82e4",
    "cwrc:7bea2c1f-2a18-44a9-8d63-bc4ddf3aa36d",
    "cwrc:f26eac6d-542a-4b7c-b72b-dc04fd9f42be",
    "cwrc:7622ca1f-b035-41cc-bdd7-a9046d954652",
    "cwrc:7bff8d43-36ed-4eb2-8868-c615e00b9318",
    "cwrc:93d59242-d944-46e6-876f-09924cb7e7de",
    "cwrc:267c01dc-6493-4a32-b4e2-d1efc6ddbaa1",
    "cwrc:6119b184-fe97-4a12-9ca3-276ec382c8a0",
    "cwrc:74140456-017b-4d16-a3b2-950ff7a7b0a1",
    "cwrc:708f46ad-dae5-4a4b-8247-e943e00cf10d",
    "cwrc:9015427e-8659-409b-bd83-e32da4b8276c",
    "cwrc:1b197d40-e803-4117-b1c9-9a590a9659b3",
    "cwrc:7cd8f57e-4942-4003-b238-124c8eb995bc",
    "cwrc:b70f266b-7ab5-46f6-ba88-b9ff9cd19221",
    "cwrc:a6539b86-920a-44ca-8f7a-4225c0089067",
    "cwrc:4c5e2907-68b5-4156-8f3c-2a6a0a5b2b42",
    "cwrc:3a498b93-d5a1-4435-a574-ba8f0802788a",
    "cwrc:18b91bca-2a78-4453-b365-fcd61bae3bf1",
    "cwrc:29e97a3c-b766-4504-b4b8-7135fb24d348",
    "cwrc:32fa2cac-b345-4108-b0f0-6f2bafdec91d",
    "cwrc:5852b10b-6a6a-48ec-8704-4ed88c2c4908",
    "cwrc:b9935ded-7488-468b-9076-d31314ecf11f",
    "cwrc:d684b2aa-bbdb-4724-ba9d-a4bd1de527be",
    "cwrc:9eb3c5e6-1ac0-483c-9786-17ba0e8ded85",
    "cwrc:e89cf954-761a-45e9-89b7-173499d9ded2",
    "cwrc:39dc042b-bfcc-4755-8ddf-1fc0836e7d8f",
    "cwrc:4053e2f4-1158-4afe-9398-674ab8866c9c",
    "cwrc:ff1e369b-29a1-4a6e-bf96-59d00ae50007",
    "cwrc:ef7e9103-b7c5-49ff-b990-e111ea3effa5",
    "cwrc:c49ca614-2ef2-47c6-a4da-0dcde8bd924b",
    "cwrc:262ca89a-7b63-4903-b0b5-e7e0b51eef15",
    "cwrc:e9720d74-01fe-4d21-b696-e9746061fe58",
    "cwrc:a7c52481-71cb-4ccf-882c-dc5c56f9bb68",
    "cwrc:4859cef7-c721-4377-a152-a2e544827212",
    "cwrc:4a34fa94-bc97-42b7-831e-c0e84556b206",
    "cwrc:0119cf12-bc2a-4151-9967-2392030751de",
    "cwrc:f0c8835e-ce0e-4e3c-b607-aa2a320b5da0",
    "cwrc:8a6d99cf-2a80-4211-8caa-c576f3313985",
    "cwrc:0875a319-1576-4b94-a4d3-815ddf0535d6",
    "cwrc:33f6604c-05ef-44e1-b39c-6b3d483139b8",
    "cwrc:bd6fa777-13f3-4ac0-8527-d7a4c234f4c2",
    "cwrc:b7d609da-fc46-49b8-9902-d228334910a1",
    "cwrc:7051e393-b660-43fc-ab3c-b8aa1a1f321e",
    "cwrc:b4c06652-eba2-4a19-ab39-6a82781e41fc",
    "cwrc:c4dba7be-49ab-4b20-ae9c-d16f376e796c",
    "cwrc:65e0b836-f934-4328-a48c-25890957366e",
    "cwrc:49472811-115c-4c00-bf5a-797abde770f9",
    "cwrc:3a94cb28-9995-47cd-8b01-bca1fc615693",
    "cwrc:2a22f8a5-0db5-4eaa-8fec-8f26d60beaed",
    "cwrc:8a638142-41ba-4083-af50-5d0ca6c7dc1f",
    "cwrc:31fc1430-54c0-43e7-8d65-6adc4f1e5832",
    "cwrc:150e443a-9b81-4b3a-a242-c4d7ac03621f",
    "cwrc:8e0ec426-f88b-4bfc-b5e2-910d9bc29808",
    "cwrc:d69105d5-50aa-4b6e-b260-8c6a5d7d39f5",
    "cwrc:77493f31-aa4b-4a47-a391-5b10e7b3e263",
    "cwrc:d18b6684-1994-4446-ad47-428e29855efd",
    "cwrc:0c369451-dc41-43bc-b8ca-c9517a40c68d",
    "cwrc:39bd5c57-6436-477a-b7cc-9a4b977a1144",
    "cwrc:8a8a1545-2ec4-48ba-8059-bc6f5214402b",
    "cwrc:70f889b8-e089-4f12-97d5-846b8d63e200",
    "cwrc:b9d4b9be-33b3-4b86-b3e2-2dda60a4a0fb",
    "cwrc:ab73b797-3648-48c2-851a-8e3cdf920664",
    "cwrc:664094f6-639f-44f1-ac78-95c19b22a843",
    "cwrc:16acf77b-5287-4a05-868a-9627174b30e0",
    "cwrc:4d8d9815-9dd2-4433-8189-2c8a0e7f10f6",
    "cwrc:3b1adc67-ee6d-40a5-82b8-26279ff24069",
    "cwrc:6f874988-8813-45b0-a0a2-0447f20f8750",
    "cwrc:9f66302d-76d8-4c56-8174-90c3e6e97391",
    "cwrc:e14f2325-ea7b-47cd-a8f5-7b491c37698e",
    "cwrc:c2aa4206-8368-4d53-8194-fc3ba4a51909",
    "cwrc:77eb3bda-4339-43f8-9313-03381c9d52de",
    "cwrc:743affd5-bc66-4f86-8deb-ec5e25b4e290",
    "cwrc:2fc3285f-2e49-455d-b3ed-e8efb7f9beb9",
    "cwrc:f344031d-79a6-4fc6-a5ac-fb78c7b12072",
    "cwrc:d451ac52-0bcc-4867-9659-94f064a17db3",
    "cwrc:92cf84c3-6f5a-4e0b-b2f1-c67e81e7fa4a",
    "cwrc:2006f183-ae33-4164-bb2d-d203b6a08805",
    "cwrc:b6e7d391-3b2f-492d-a9bb-4c4cf4fb47ec",
    "cwrc:3e739af8-3b16-46ba-bf52-a162d24c3ac3",
    "cwrc:b0257f78-4f90-43bb-b483-f72806d2434c",
    "cwrc:7bcef4fa-d7d2-47d0-894c-903dbf104c48",
    "cwrc:eb131a79-d45b-4702-8bcb-27806bf0cad7",
    "cwrc:705510f0-9c83-4989-a246-4570b074edee",
    "cwrc:b77dd96b-a570-4b2f-a580-255b182090e4",
    "cwrc:d447d746-ecd3-431b-8041-081b9efb7c19",
    "cwrc:dc102ac2-2cd3-4c65-b55c-a860a4b31661",
    "cwrc:5c81daa8-3194-48ea-abb9-392484a9e2e5",
    "cwrc:229bbbe3-846a-4648-b64d-3b44d813f4a4",
    "cwrc:4774c8e7-e68c-4f41-a6a2-c65e942dd2ec",
    "cwrc:fd64a759-fcdc-488a-93d4-8a32b32bc46c",
    "cwrc:b26c403a-725e-4b43-afcb-7fdf7743e64e",
    "cwrc:7b9e7a20-34f2-46cf-b8d0-4983a81273ac",
    "cwrc:4272a085-9383-4adb-a9e0-84e2bb1cbdaf",
    "cwrc:bebc7328-5777-4f90-9d18-b50d76fa7c62",
    "cwrc:a9ef1947-595e-4b24-ac9c-7940187f6120",
    "cwrc:41c7bb51-c81e-40d7-b3b4-66822cd28d49",
    "cwrc:021b3f4d-cdbf-4074-bbf5-be4b1c2c5719",
    "cwrc:a6f1bffd-d4d2-4025-818f-71f61f57e746",
    "cwrc:adfef01f-89a1-40c7-b8e0-b693a1aabb23",
    "cwrc:f659347c-b415-4418-ac96-ee00b956487e",
    "cwrc:28ffdffc-ed1f-4f45-ba84-70170f50d7c9",
    "cwrc:96c51a00-deb4-4390-a0d8-019d39ade5e2",
    "cwrc:e96d00fa-4167-4eac-8bd1-77cdde9d11e8",
    "cwrc:2d4dbd44-21c8-479a-ba4a-fb6f9e677a2b",
    "cwrc:d5dbebe9-549f-49bb-b288-5d0a9afc28cb",
    "cwrc:1bea26c9-8533-4e41-a1c1-1da9a8dc61d1",
    "cwrc:a5ae4518-2315-438d-96e1-d500f532eb25",
    "cwrc:464d8f29-e5dd-43c1-a383-666cdf5e93e2",
    "cwrc:9452c033-7b8f-4bd2-9ff1-d961464f26b1",
    "cwrc:2965a2c6-92dd-42ae-b0ef-7c745d38c68c",
    "cwrc:35d12648-530b-4ed6-9abe-4e4f941ebf7d",
    "cwrc:682ee3ed-ed25-433b-8329-0cb942f5e2ed",
    "cwrc:264b07ad-ecfa-450b-8c35-345c5e34c263",
    "cwrc:48cade72-7e16-4b70-8bb8-cf2151a9f86c",
    "cwrc:71336ebd-48a5-4132-8db2-dbaf24396598",
    "cwrc:5abd464d-cfec-4a56-991c-e8ec6a477057",
    "cwrc:23e0af41-c6b3-412c-a305-3a0304f89cfb",
    "cwrc:9f91548d-7af4-44d9-9124-5f71614fb447",
    "cwrc:c7d8c538-5f27-4d6d-bfed-60d56ef7fbe9",
    "cwrc:70d70025-ac82-4538-8fbd-b2ec9ad51c82",
    "cwrc:4816b4c1-d563-4931-8fdc-1f847c954964",
    "cwrc:4e51a449-e6c5-4d70-bfc5-a6083ef60174",
    "cwrc:43020c30-877a-4a96-88cf-dbed490aca06",
    "cwrc:132d6d99-38e6-4c2a-902a-11dce744184f",
    "cwrc:dac1e35b-5bfa-4fcf-839d-22f7bd7dbafd",
    "cwrc:aaeaaa14-ff83-4e77-9ad8-8ee3287ea24f",
    "cwrc:2339ee72-dbfa-450f-9260-4c4a6fa05f08",
    "cwrc:84cf5d9d-264c-42b3-b125-61d6f362ea52",
    "cwrc:13cb53e8-52a2-4879-bfbd-72c2234971e0",
    "cwrc:08a787ff-59dc-494e-a0ac-26e1c8105aca",
    "cwrc:f7de7469-7f44-447d-bcde-a2186fd8ffff",
    "cwrc:5502be36-f4e0-46f1-b8aa-eddefe33cd32",
    "cwrc:98da9968-e31a-4b0d-98b9-24f624b60f17",
    "cwrc:0e451a50-149a-4072-b50f-7b16e64a91a1",
    "cwrc:92d5b228-2e56-4d86-bbdf-c4ad29f6900e",
    "cwrc:c1ff436a-0094-4f28-b32a-2351b97cc34d",
    "cwrc:2d942dd3-1195-4c1e-a14d-8149d9ec9d33",
    "cwrc:f6e39559-d861-4836-b117-acac6ab4e289",
    "cwrc:4053f0e8-ec95-4fba-a845-a7453f7e1c85",
    "cwrc:afa5fa13-dabd-43b9-9d74-72b047ab1fca",
    "cwrc:d41a6424-fa25-4201-92ae-e816a032c47c",
    "cwrc:8df887a6-3469-453c-a8bc-a8c1f0265e51",
    "cwrc:50054e53-f814-4c85-9678-49d4e04faf48",
    "cwrc:62dc05ae-6892-4b25-b670-ced5d52662f2",
    "cwrc:5a750422-2b1c-4059-bbfc-46cd518e2300",
    "cwrc:24886963-db36-4fd5-b0ad-c9832f346d3e",
    "cwrc:13d4fb9a-232d-4bc5-9d61-ba18c63a31c7",
    "cwrc:cdfc946b-b462-4838-91b3-8cbf3db388af",
    "cwrc:a7896c4e-e501-478e-92c9-59b500b26cdd",
    "cwrc:ec643488-b8f0-407e-bf9c-d213115484c1",
    "cwrc:d95b4281-49c1-4fca-8a0a-f029b8e4e487",
    "cwrc:d422e078-c9b6-41d7-8626-6d9d95805204",
    "cwrc:b9618254-50ee-4e40-8945-e74e472a83ed",
    "cwrc:b484bf0f-90dc-456c-8001-b684888555ce",
    "cwrc:29a46b98-b4ee-4f36-97b6-e68991bc8bf7",
    "cwrc:51c59901-502f-4d89-ae90-700cc642756f",
    "cwrc:e520dc3e-e773-4aab-8442-3595207c24b7",
    "cwrc:5ab956c6-bc2e-4287-ace9-cbee99415234",
    "cwrc:aefed1b2-f58e-480e-a91d-e43a861f4d35",
    "cwrc:730198ec-19d2-4b4a-ad92-5ba9522bede4",
    "cwrc:e844fe96-be95-46dd-8e41-f87618c4425b",
    "cwrc:967ac52b-fdd0-44cb-bbf5-bbac385e1607",
    "cwrc:9e8febc4-272b-40bd-9952-5e6f07767077",
    "cwrc:44c2369d-907e-4358-96ad-197afdeac2d8",
    "cwrc:a293f30a-5f10-40e5-b54b-44e57ceec445",
    "cwrc:2a4715ae-1b7b-4822-bf12-4b3829f339c0",
    "cwrc:6af0156c-2f45-43c8-bf3c-5f1fd2bddf40",
    "cwrc:8b1dc78d-cf5a-4aef-80d3-8d8a547f93aa",
    "cwrc:2446e561-e804-43b0-990a-20676713785b",
    "cwrc:689efca7-6afe-4f26-9e55-533c0a421e1d",
    "cwrc:8cb29765-c82e-48b3-8436-5a6fb382a030",
    "cwrc:3df59cb0-1d21-48ee-a7be-2adbca832e35",
    "cwrc:6f924d0a-beda-4b18-91aa-bf029e9e9672",
    "cwrc:fa3b88ef-01bc-4b8b-b2ee-5d3d6bb962b2",
    "cwrc:28ee0199-de28-4a99-9ee7-5a28500abe11",
    "cwrc:6657157a-288d-4f35-afa5-298af08e5099",
    "cwrc:35d6e1f7-2e94-4729-92ba-6534b232a9a9",
    "cwrc:1a46ed09-b234-4e77-a285-5acc068561b7",
    "cwrc:bb5c5328-051b-4e45-8a42-d8d87406fbe9",
    "cwrc:628c2ab9-b17d-4716-ac65-07e88ba0cc40",
    "cwrc:f78fb550-f818-4e13-965c-bcc2d632559d",
    "cwrc:da23a5b7-ef0a-461b-9527-f9fd1ff59c21",
    "cwrc:f887b273-de30-4cb8-b604-e4f625ac5144",
    "cwrc:69981302-2034-4c73-be4a-1da78f053e8e",
    "cwrc:29542920-7705-4087-9912-3c8dfe22478b",
    "cwrc:193751f2-7712-4cde-9a79-f938f1e2b443",
    "cwrc:04108a54-4bdb-4954-9a4a-f17f0f8972c8",
    "cwrc:20f30525-d017-4de4-a0e7-0a66dd55c923",
    "cwrc:5674fbf1-ce11-4922-9f60-5888841c78bd",
    "cwrc:86418118-638b-49dd-800b-57be4b196f17",
    "cwrc:14d08ba3-d491-4086-9b09-19147e78d3e1",
    "cwrc:d81712ff-b56a-41dd-bd2d-0ecef2ce4869",
    "cwrc:ff6d72fa-2ea5-4c3e-8e2e-18eed0d2a6a7",
    "cwrc:da00238e-5773-46ce-9044-3007420bf228",
    "cwrc:e6d8ee1c-6bc6-4996-ab34-e5989f3320d1",
    "cwrc:7fb1c2bc-85b7-4a22-ac8b-243233802adf",
    "cwrc:97691b39-8fc2-4c1e-9372-89dcd8cdad92",
    "cwrc:f70afaba-1652-41ae-a0f2-906bd19fe4d0",
    "cwrc:40ac355c-98e3-4cc1-8f89-adcc8e9eb886",
    "cwrc:ba54938c-589e-44e0-b242-4316dde7cda0",
    "cwrc:5afecac5-b565-4fc3-a3e7-05a916f554ef",
    "cwrc:94b1d1e3-d6fa-4f42-b0b5-c00804c30602",
    "cwrc:96626832-7a00-4a56-b416-c6322b98a9fc",
    "cwrc:07af086a-8ac5-434c-bcf6-dd7c9ebaec73",
    "cwrc:8ca9395d-56f1-4d40-a7b4-663bc1ecb632",
    "cwrc:9d952b20-e911-414c-849a-9216b2d7734f",
    "cwrc:239fac41-3e30-44aa-956d-52f3e28b9917",
    "cwrc:ceb0835c-9ccf-46ae-ae92-dfd2eaef3512",
    "cwrc:82c44509-3d45-450f-bfe0-a585b8ceaedb",
    "cwrc:081b0557-67da-4950-a113-9703c023b1ed",
    "cwrc:acf2f723-06d5-4667-ba71-5279ae26d6c1",
    "cwrc:ff0f9685-4ef7-4bba-a6c7-fda57d11b84d",
    "cwrc:eafb123d-90f6-436c-8d34-f66972497e27",
    "cwrc:d1f33e7c-97e8-4410-9a8d-4048a565900a",
    "cwrc:135547d8-d825-49a1-82f5-c298b6b8e4aa",
    "cwrc:e41dd3c4-03dd-4387-beb1-6e5618bbc02f",
    "cwrc:3f1ba322-6be3-429e-add7-4ca1f167dd61",
    "cwrc:d541ebf0-4e99-4e43-a045-0ef4fa6cf104",
    "cwrc:8d0bd393-fdfb-4db6-a61f-71f001064f9f",
    "cwrc:81cd31c4-2646-4cc7-9ea8-834fbc20a0b1",
    "cwrc:26b3a096-f4dd-42bc-a59e-49923cb4300e",
    "cwrc:cea4ac84-4ac5-49e8-bb04-d55433276015",
    "cwrc:d27259b6-15de-4641-ac84-7b7b06091a36",
    "cwrc:0ce96ca0-3515-4f07-ba17-4d7728b865b2",
    "cwrc:d6e3fb9d-884d-42a4-9fa7-100447997216",
    "cwrc:6947a2fc-7121-4646-aef1-889643bad8f6",
    "cwrc:6bb2a92b-cb3f-4499-9acb-cd789087eabc",
    "cwrc:3aa19539-05a0-41fd-bd58-967a7dd42bc9",
    "cwrc:dae23828-a733-4124-ba12-98022feca319",
    "cwrc:0195a4af-2264-4efb-95d1-1813181c80cf",
    "cwrc:8450ca12-24b1-42ae-9614-328c23865b98",
    "cwrc:5acafb88-5540-4a29-bf7d-16df6e172e54",
    "cwrc:2f4d2289-b670-4081-9029-7a9c9420ba4f",
    "cwrc:c6518947-5f11-47f1-89cc-ff5c0839eba7",
    "cwrc:6b470ec0-8f09-430f-9f47-a5388086406d",
    "cwrc:f73cbb3c-11a0-4776-ad58-abf87c7b6279",
    "cwrc:2d9bce47-866e-4630-b20b-666883485a05",
    "cwrc:8a159b47-b19d-41b1-b5bb-2ef8ab5cd0f8",
    "cwrc:879f291f-6323-4bd1-a453-e18769b719cb",
    "cwrc:65b2f94e-f17f-42bc-8883-646ce3330e96",
    "cwrc:8772b76f-32af-4edc-b8e5-cf9974594b3d",
    "cwrc:f5f7839d-5495-43d9-921e-68b61a3bb4b9",
    "cwrc:5c8040f3-8001-448d-aa47-d1d2284dac79",
    "cwrc:cf348c21-4728-406a-8256-a62f59e36886",
    "cwrc:98e09b70-b570-4c66-9f7f-04eea74602c5",
    "cwrc:d61dc083-e4f0-4665-8981-a170875efeca",
    "cwrc:3723bc22-4ea7-4a64-8390-2c0f7acb7f2a",
    "cwrc:5523d599-416d-450f-a8bb-bca0dd5d2030",
    "cwrc:b62cc9fc-1355-4b79-b708-e5aba3580362",
    "cwrc:f8053b69-c047-48b7-bde4-53249cb0a674",
    "cwrc:542c686b-834f-4599-89ef-72171c1d172f",
    "cwrc:79c68810-9766-410e-8eff-71ad06653521",
    "cwrc:e8d4712e-6cb9-4e2c-b26b-7a82340fb3d6",
    "cwrc:cfdcc044-dd7d-4786-beb5-e42fc907c3ce",
    "cwrc:7fabf056-e1e0-4c45-a68b-fc674609599e",
    "cwrc:5043cae0-5008-4926-af97-7cf817e5f006",
    "cwrc:434da2ca-4203-4ef0-92a5-f3cb420d1ff9",
    "cwrc:d7329f48-2f8c-450f-8675-27b7555cb1c1",
    "cwrc:a14299a0-125e-438d-a70a-6fd6a7b700c8",
    "cwrc:66a83190-b020-4de8-b606-0872e8412796",
    "cwrc:11b1aa5d-5533-4adf-b09e-1f3ab5ac20c8",
    "cwrc:2c7aa7cf-a250-4505-90e7-0936bf1d3a70",
    "cwrc:b63d667d-8395-4cd0-9667-106db22dfca5",
    "cwrc:a38de54b-e89b-49a7-84b0-a7fc1d1ff842",
    "cwrc:6db160bf-b6d6-4b84-8ed0-2b0844f81046",
    "cwrc:32ce261b-6934-45d7-ab6b-5dd5e2f98eec",
    "cwrc:e904f606-e936-4cb3-92f1-8fa14b9174dd",
    "cwrc:da7e059d-85c2-4b0b-8427-bd7a44b4f36f",
    "cwrc:98bbeccc-46d5-4fee-854f-a311f5044470",
    "cwrc:75993f73-d198-4788-9204-c1d051ca1c02",
    "cwrc:2f8b92cd-e70b-4d6b-a204-27dd76033271",
    "cwrc:929c31cd-d485-4a7a-baeb-e011a39e9ad7",
    "cwrc:4b65f35a-d8e1-442d-a53a-4cbaa893ea82",
    "cwrc:25c452ca-8963-4c95-a67e-0ee5ca0b69e7",
    "cwrc:13034ad7-dd89-4787-8c37-3fefae4f71d1",
    "cwrc:686abc23-1159-4f6d-b5bb-c2bc4a6225cd",
    "cwrc:31f1ac6b-f875-41f6-b9da-eaa7f2dfc12b",
    "cwrc:ce607198-9431-4819-9400-b8b481e29e42",
    "cwrc:16dec562-74f0-4830-a320-51512aa2f2af",
    "cwrc:f6edb834-55da-4192-a032-671b7997cd35",
    "cwrc:40b0fac7-5cda-4056-8f9c-d8edb202a4f5",
    "cwrc:8761b759-398c-4e5d-80f6-dfc5ae63c21d",
    "cwrc:64a8d143-2b49-482f-90f5-976d85cb2ff2",
    "cwrc:b3511b08-6d49-41db-898b-948744454817",
    "cwrc:6f4ab95e-ab7e-403a-9e91-003da04edd64",
    "cwrc:6be754da-1123-4cf3-aa97-850091301279",
    "cwrc:e3d69c68-b3bb-4c68-a28f-cf119c4b93d2",
    "cwrc:7c8bc176-5c29-45bd-88d4-ce418449e9c8",
    "cwrc:fc265e0a-0cf0-45b8-af58-f9c4ce69b305",
    "cwrc:80a51859-d331-477d-8eab-5ffb3621e431",
    "cwrc:dcc78740-cf3e-4f5c-a74b-c2a6156832fa",
    "cwrc:c2717ab0-4b26-468a-b7a1-17c8c0ffa381",
    "cwrc:9f75f008-b375-4bf6-8556-593f787e4bdc",
    "cwrc:a4453a3b-d363-405c-92fa-a02a67be8383",
    "cwrc:8ebb6285-9253-40d4-8ff9-d75ebd4f81e5",
    "cwrc:92c45d52-a51a-4377-a013-cffaf6464043",
    "cwrc:bb0213c5-f50b-4a3b-bd2e-1d8917ed8d60",
    "cwrc:23baba82-2a76-465c-9b0b-07e11fbe5453",
    "cwrc:1c6578b1-ff29-4581-aa50-8ab629df9a04",
    "cwrc:77cf41fa-f6dd-434c-a45d-a1f5d4904c22",
    "cwrc:1a72754f-e2dd-4183-bcf3-0bb18fa00f95",
    "cwrc:fc3cbf63-5849-4cd8-b2a2-9df5a18daef1",
    "cwrc:31e3c93f-ddb3-4c45-80c0-a267df93d34b",
    "cwrc:eacb97e8-4aef-4a56-8be2-1f9539d69841",
    "cwrc:1939f16d-091d-4130-94a1-206e97df97cb",
    "cwrc:f159038d-ad4b-40af-8a2e-3a93307c63af",
    "cwrc:77dc93d4-aecb-4540-9c5a-15e21b03f3d1",
    "cwrc:1a722caa-adaa-4b3a-bae5-eea0fb8fa17a",
    "cwrc:4447afe6-debd-48dc-ac89-08a08f6134b7",
    "cwrc:5367a0b9-12fc-4d6d-bcb1-f76bfdc665ec",
    "cwrc:cd008506-30f3-4565-9521-f60ab012626a",
    "cwrc:c1dced58-960c-433e-aea3-356099deb719",
    "cwrc:2fefe6ef-d427-4ab8-9f67-c81007dd89d1",
    "cwrc:696580e7-9b22-46db-8eb0-364759a094db",
    "cwrc:dab5e2b5-422c-4c80-a8af-4c5fb1eeec78",
    "cwrc:5f14fe33-52cb-4e47-a6d6-b797517b481e",
    "cwrc:214ce1c9-f4e0-476c-9457-14e9ef0e5dd4",
    "cwrc:18262737-fd4a-47a5-ae92-26c3fb61fcbc",
    "cwrc:0b4cb6e8-4115-4e77-96a5-5f6731095bd9",
    "cwrc:8595b589-3cca-4eb5-9c7f-ed3cd7147065",
    "cwrc:2d945beb-10dc-42b8-98be-02d8d19c872c",
    "cwrc:de8bcc88-5ac0-4a95-83a4-5d8c1c5d11f0",
    "cwrc:5905baf8-f742-4d09-8dd7-1491c0abdc0f",
    "cwrc:61263eac-76cd-4bd7-8b31-81ff3e962b41",
    "cwrc:215d5520-d9e9-418c-838e-b6a7d3a902e3",
    "cwrc:25a7cdf9-ce5b-4ea7-9396-510eab8b319e",
    "cwrc:2d2c7ddb-42f0-4302-a15d-124f07a96e8d",
    "cwrc:7398bf0d-aa3d-4c33-976e-1bbbf5eccbf4",
    "cwrc:42baf908-2254-438a-9255-580fb373d93e",
    "cwrc:3f195246-d227-466f-ae6a-c57d85789c5b",
    "cwrc:d47a3ee0-587d-4aa6-b28b-76c64b4b3e2c",
    "cwrc:545cfc62-e738-44c3-b4b9-6a70a12ef86f",
    "cwrc:ea847996-134f-4051-b42c-243c606f8b9f",
    "cwrc:5fd62e14-453a-4675-b24c-e86c8a293842",
    "cwrc:839144a0-746c-4da8-a704-9332d9e4e8f6",
    "cwrc:66853250-840a-4692-9e5f-a96dd0d62842",
    "cwrc:e27dc57f-c0e8-4a0e-8d7d-cbe9cae1206c",
    "cwrc:8b051400-c078-42aa-9205-6a3dc82351b3",
    "cwrc:dc4b9663-9d4e-4f45-abc5-ef43c33ba603",
    "cwrc:f199f90e-2589-473b-a7ae-8644ddd1020e",
    "cwrc:e9ff5716-8f02-4a44-910a-37b2921a4aa6",
    "cwrc:725174a8-d9af-4f0d-997f-62723c4cded7",
    "cwrc:60b95721-c1f3-4dde-affb-f9889eb8b3f3",
    "cwrc:1928399c-8f6d-414a-90d6-23f0f806739c",
    "cwrc:58a1609f-4f17-4c3f-932f-0d0c82ddd11c",
    "cwrc:c69350b3-dbd7-47cc-8e06-8a2be70ef702",
    "cwrc:7519e070-dbc6-44b1-b1ad-6db01fa8c17c",
    "cwrc:076139cb-0d05-4644-aa23-425934b99dab",
    "cwrc:96aecc51-448c-4037-8b21-d925e852acd0",
    "cwrc:6aea131f-ce81-4e98-9c99-cc2d97ee6214",
    "cwrc:c5e87343-b907-4da5-b5b5-c3db17e8822c",
    "cwrc:4eb5f5e6-4b08-4f8d-ba3f-d2a1804d4fbc",
    "cwrc:e62a07cf-44d0-4a94-b224-d9cdd42c6273",
    "cwrc:0805fec9-f6ca-43e0-805f-67c0a060149f",
    "cwrc:03735748-028b-4386-9d05-28d8c1f012ab",
    "cwrc:9d139658-bf85-4fe7-9c04-b6ac6cba79c1",
    "cwrc:c7eae4da-b4a1-4f2a-9645-b5fe1f725079",
    "cwrc:0564cec0-09d0-48ff-904d-d17da24b298f",
    "cwrc:2a731178-1731-4aa1-a5f2-8334b3035626",
    "cwrc:e8d44f8a-34b4-4e23-b5aa-92f59cb95e94",
    "cwrc:57709fc6-9d5f-4627-83cf-96eb779ddc47",
    "cwrc:d3b7efda-66ba-415a-b6c6-26dd7c4d8d47",
    "cwrc:8c6fa230-a487-4ee9-bb77-f5355c709fb7",
    "cwrc:b077972d-a9c2-4466-9ddb-ed83f5a1898e",
    "cwrc:902c5df2-8a9a-4d89-addc-cc1108859b1d",
    "cwrc:c4be2f6e-a23a-4916-9936-e90611923ac5",
    "cwrc:e495ca58-ccf8-4d89-bdd2-17d3d1a435fe",
    "cwrc:24e136ef-27c7-4506-be78-e04f77f27999",
    "cwrc:6ca0d52f-a82d-4c16-80c3-41901fb36e17",
    "cwrc:be28d1b1-834c-4031-950d-f4ff71333556",
    "cwrc:cd21156d-c015-42c6-9740-3166ac01f53e",
    "cwrc:5e330d0e-0bb2-47d3-b6fe-d87f2ef2a906",
    "cwrc:d84ba4d5-3520-4555-ab3a-60bd52cda617",
    "cwrc:f1aad3f4-42c2-458b-b5a7-bbe3bffb7bde",
    "cwrc:0698e1d1-7831-46bb-9f4d-13a4ba5bcaf1",
    "cwrc:4c6a5d3b-bdb1-4a18-81f8-1755f922f832",
    "cwrc:55b9855c-8264-45a0-82fb-57971e51dfbf",
    "cwrc:3585d602-5b97-4d7a-87f0-cd4b7b219a60",
    "cwrc:87c34007-74b1-4beb-9cf5-36965b3fe243",
    "cwrc:88e555c4-4b68-4465-ae5d-a2c4fa95c57d",
    "cwrc:c218a80c-91ee-47ad-94ef-e554c577f25d",
    "cwrc:9aa90292-16a4-4c47-8a0c-aa5f716c5ad5",
    "cwrc:a80f5a69-3ece-4adc-aa0d-63a67cf089b4",
    "cwrc:64898509-4b27-442e-8d60-e16ee5d1c21e",
    "cwrc:bba1623e-6df9-4bfa-8771-5b553c802943",
    "cwrc:04e79723-b6a5-4e18-8941-0e8cad884bb3",
    "cwrc:1b556ee2-550c-4cc2-b907-a56333c26b7a",
    "cwrc:1db828f8-dffd-4df5-8f5f-055147d62a98",
    "cwrc:b064ec09-a73d-481d-b033-ccadc5595b3c",
    "cwrc:f4218819-1a64-40bf-b382-2ef5bbfb5ddc",
    "cwrc:06e26540-a08e-4365-98cc-22af85e0b8ec",
    "cwrc:d30e31a0-3f39-40ca-8c82-aa4796578cfd",
    "cwrc:ba6fa615-3d2d-4f1d-b3f8-6ddc10581f1b",
    "cwrc:8ea7f32d-21f4-405f-9090-6a6bd86aa9bc",
    "cwrc:44799d76-aa3b-4800-90a7-0ccb82b40cf4",
    "cwrc:36090dd3-ccaf-493e-93c4-aea88f181ae6",
    "cwrc:7ade978f-2fe4-44ff-8af2-b57cc4b5b9e7",
    "cwrc:58e881ae-3748-4f76-8b70-93a118603f0a",
    "cwrc:8cb7ac26-05e2-4435-88e8-5956af3cf306",
    "cwrc:72bc1e94-72ea-4548-a529-c2fb8aed6e75",
    "cwrc:830f6fb4-1be7-46ad-95b2-a94e9899b2e5",
    "cwrc:7f9055d5-263a-4169-923b-e285dc03fe06",
    "cwrc:86e4452c-2be9-41b5-a8b4-24c497873fde",
    "cwrc:aaa5c08e-3e94-4b11-a46e-924490c2c552",
    "cwrc:0512f7af-7e03-4462-b8e1-699b7f53e989",
    "cwrc:ddb3e771-3478-4a3c-bfd7-228c8e086131",
    "cwrc:95250d27-d1e8-49c7-8bc6-380e426e7851",
    "cwrc:3418a4b1-1e91-4364-b7e1-1a7e50c3ecfb",
    "cwrc:b7e798fc-d8f7-4271-99a2-8d1e6257cadf",
    "cwrc:61bf1ff1-3b45-4cb8-9d34-656b2c764970",
    "cwrc:be71f313-a35e-4723-a524-62e670d77638",
    "cwrc:db2ac557-d3e4-45b9-8ea3-cf5e29d6987c",
    "cwrc:e364de03-f829-44c6-9203-ee9ae514251b",
    "cwrc:444b4d24-ea72-4d63-8693-7966c537d938",
    "cwrc:45f20368-ec03-41e6-8a81-532095df8906",
    "cwrc:2f2f5bb0-186d-4311-86ba-1ea3fb48b404",
    "cwrc:675f9305-50ba-427e-a9d7-653f56aaf460",
    "cwrc:3c20f396-2319-4741-ad6e-9f75c622e915",
    "cwrc:64536a80-3219-4e4d-b49b-5caf37eca08f",
    "cwrc:9e49f49d-2dc9-4506-9288-a82e0de8fb84",
    "cwrc:7e59aa4c-3152-4ef6-a909-a99b1743f368",
    "cwrc:f44eb4f7-4344-4fd9-b48e-1b576f66a52a",
    "cwrc:4f9fd8ea-b789-4221-9da0-3eba3f29d8c2",
    "cwrc:d2551985-1a8e-476f-a311-44a6fe8e831a",
    "cwrc:e3f0e2c4-cebf-421f-b1fe-6a4c967b9f64",
    "cwrc:111b60c2-dbb5-4b54-beb6-a29081452986",
    "cwrc:91bd3c57-cefa-4ec4-8df1-bab4ea7be6a0",
    "cwrc:28fcd13d-ca28-477a-98f8-cb148c79509a",
    "cwrc:5a1a3407-a953-496a-81cd-ab2ac6b83b37",
    "cwrc:23458f55-6edb-48e2-916b-d082c3a1252b",
    "cwrc:b9117919-a2d6-470c-8d56-b7e65d0a4e9d",
    "cwrc:01f5c15c-b4a5-46b6-99f2-df51e2da1167",
    "cwrc:46f92092-4690-4b3e-b063-c44e2051a459",
    "cwrc:630e8b75-41ae-4c4d-85b6-3e3181b07143",
    "cwrc:fe9f8ec0-1904-480c-879a-a32b68fe72f0",
    "cwrc:651201d4-98fd-4861-9bc2-43dade6ce935",
    "cwrc:a93a9b8d-1cce-4453-a0db-82537083ccea",
    "cwrc:ca80bf36-0a05-4332-8057-3718db19e6b7",
    "cwrc:ac0b32a5-0a53-487f-bbb8-b9e6a8d43e6a",
    "cwrc:a32a37ff-cc54-4a00-89dd-a5d735a63a17",
    "cwrc:9d80c502-8768-4301-82d3-c90202d2cf83",
    "cwrc:e1357fe1-387d-4259-a89a-5776e99c7317",
    "cwrc:6fb14127-4f63-4bcd-984a-35f2a42511d8",
    "cwrc:22a49241-d36e-4ad8-9556-421a765d41c4",
    "cwrc:10bde60c-c3b8-4ad6-894d-2d639eea2ef5",
    "cwrc:230d92f7-c6de-48c6-9832-e5ba253f7c65",
    "cwrc:45796695-9f86-4425-9888-1b929d61b626",
    "cwrc:37b05228-6bd3-4c92-9abf-3938cdfacb03",
    "cwrc:b878b2bb-3b0c-40df-a1c1-e62cd6801f0d",
    "cwrc:f5167b64-608a-4a14-9819-bbbb9dc8aff8",
    "cwrc:7186132a-26ba-4f7a-a3a2-7499e6ec9d2a",
    "cwrc:ae8aa1b0-f78a-4b33-8a49-843931d7d652",
    "cwrc:519e56fa-7dd1-4b1b-bc65-4bc3e9f6e203",
    "cwrc:caadef13-d11b-463e-9b40-636cdf2ba638",
    "cwrc:b9e04c0e-bdfc-4adf-905f-07e64151e684",
    "cwrc:1008be3d-c73f-4c1b-81a2-1a3bd5e114a1",
    "cwrc:13a4aeaf-f39a-499b-850d-75f1a673b4e3",
    "cwrc:41d248f3-a69f-493e-bf34-a512f79c35d3",
    "cwrc:df306bb5-087d-4f81-b12d-db2792c02878",
    "cwrc:4601f91e-f346-44b0-b464-ce62a88e488c",
    "cwrc:60a69c87-35d5-42fe-b307-ad3aeac51607",
    "cwrc:a3716584-71a2-47e6-aaac-5e6670d575e2",
    "cwrc:c56d2083-a853-4cdd-afc7-ea612cccf849",
    "cwrc:a283205c-6c83-4f37-b216-09ef8f52ec53",
    "cwrc:a93833ff-6b92-49e5-8546-a3ec28b9909d",
    "cwrc:a819c23a-f62c-40b3-be0d-bd1875023016",
    "cwrc:e6e14e87-7ebe-479d-adb5-d90796fb39a6",
    "cwrc:5589b4da-c652-41e8-8da5-270098d4ca61",
    "cwrc:24a96699-6452-4f9c-bce1-b9fa15a0181d",
    "cwrc:f704ba6f-a93e-4408-8d44-8937f648ba50",
    "cwrc:3943705f-6ea4-4df5-b945-3df9ec1af57c",
    "cwrc:3aeddd41-b241-4d13-a44b-23537083ae39",
    "cwrc:a405b1d4-c831-4275-b954-328d1de9a93e",
    "cwrc:8e2ddf49-4ad9-4c9e-a4b4-7538faa268ce",
    "cwrc:f5999651-48c3-41f7-808d-b7a23d7347df",
    "cwrc:e01a07e3-2c03-4ee3-9c9a-a2a668c07e42",
    "cwrc:9648fd60-db2b-473c-8e30-c591b8576529",
    "cwrc:fa2ad8b3-ed36-4c4c-8b97-edef875be146",
    "cwrc:3f0a3a7f-7ace-41ce-96b7-3dd0307a8918"
];

let $resources := /metadata[@pid/data() = $pids]
return sb:output_csv($resources)
