xquery version "3.1" encoding "utf-8";

(: Test one column :)
(:
:)

import module namespace tH="transformationHelpers" at "../islandora7_to_workbench_utils.xquery";
import module namespace tC="transformationCommon" at "../islandora7_to_workbench_common.xquery";

declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace oai_dc = "http://www.openarchives.org/OAI/2.0/oai_dc/";
declare namespace fedora="info:fedora/fedora-system:def/relations-external#";
declare namespace fedora-model="info:fedora/fedora-system:def/model#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";

(: Uncomment to output as XML for the use case: XML to CSV conversion in a tool such as OxygenXML :)

(:
declare namespace saxon="http://saxon.sf.net/";
declare option output:method    "xml";
declare option output:indent    "yes";
declare option saxon:output     "method=xml";
:)

(: CSV output method if XML tooling supports (e.g., basex.org) :)
declare option output:method "csv";
declare option output:csv "header=yes, separator=comma";


(: CHANGE ME - ID of the default base collection :)
declare variable $FIELD_MEMBER_OF external := "50";

(: custom content handler :)
declare function local:generic_custom_function($metadata as item()*) as element()*
{
    (: Using the squenence syntax (notice the "()" and "," comma. This also works with "element" syntax "element test {function($metadata)}"

    :)
    let $cModel := tH:get_cModel($metadata)
    return
    (
        <field_title_full>{tH:get_title_full($metadata,$cModel)}</field_title_full>,
        <field_title_trunc>{tH:get_title_255_characters($metadata,$cModel)}</field_title_trunc>,
        <field_title_alternative>{tH:get_title_alt($metadata)}</field_title_alternative>,

        <field_related_item_title>{tH:get_related_item_title($metadata)}</field_related_item_title>,
        <field_related_item_title_full>{tH:get_related_item_title_full($metadata)}</field_related_item_title_full>,
        <field_related_item_alternative_t>{tH:get_related_item_title_alt($metadata)}</field_related_item_alternative_t>,
        <a></a>
    )
};

(: define the list of PIDs to transform :)
let $id_list := [
]

let $items := /metadata[
    (
        @pid=$id_list
        or
        (
            not(@models = $tH:UNSUPPORTED_MODELS)

            (:
            resource_metadata/mods:mods/mods:relatedItem/mods:titleInfo/mods:subTitle
            or
            resource_metadata/mods:mods/mods:titleInfo/mods:subTitle
            or
            resource_metadata/mods:mods/mods:titleInfo[(not(@*) or @usage/data()='primary')]/mods:title[string-length(normalize-space(string-join(.//text(),"")))>255]
            resource_metadata/mods:mods/mods:titleInfo/mods:title (: some items don't have a title, remove from test for now :)
            :)
            (: verify items have a title :)
            (: resource_metadata/(mods:mods|mods:modsCollection/mods:mods)/mods:titleInfo[(not(@*) or @usage/data()='primary')]/mods:title :)

            (:
            and resource_metadata/(mods:mods|mods:modsCollection/mods:mods)
            :)
            (: or contains(@pid/data(), "tpattzzzzzz") :)

        )
    )

    (: Test set of interesting objects :)
    (:
    :)
    and @pid/data() = [
            "cwrc:0314fd25-4516-419c-abc2-fe3c480ce876", (: nonsort "La":)
            "cwrc:049ada3a-7fe4-41d3-aa6a-0928652a4fd3", (: nonSort "L'":)
            "cwrc:4b113f6b-0831-4183-8fc4-5d82bb9384e0", (: basic:)
            "orlando:1155fe3e-6b41-477b-a7c2-51fdfd0cbd55", (: title with sub-element mods:extension :)
            "orlando:09800b1f-fc45-4a38-969c-9fe795064f9e",  (: title with sub-element mods:extension more complex :)
            "enip:034f90bb-271e-4c8b-b221-b11737122637",  (: title with multiple relatedItem title & newline in title :)
            ""
    ]
    (: possibily interesting test cases; the last 3 Orlando have complex titles :)
    (:
    and @pid/data() = [
      'cjww:be0d8a1e-def6-4bf5-982f-5091426cf87a',
      'cwrc:96625e12-5100-4748-8db7-806d8fa2bf3f',
      'cwrc:f06d59b8-702d-4b59-9820-fa691bb0a1ba',
      'cwrc:f4eb1dad-1bf9-42f8-9630-d8f41bbdeae3',
      'cwrc:f5a34588-9c9c-4ac3-90ef-2bd85a82e135',
      'digitalpage:1158b947-9568-4941-b612-ed0523fdf3fb',
      'digitalpage:6abb9b35-918e-4ae5-b0e0-96af4f93e172',
      'digitalpage:bad4754a-7dc7-4dba-9ab3-386dcdab7259',
      'digitalpage:c2dee765-9488-4563-a3b9-bdc8512405f6',
      'islandora:03055d22-2b66-4d06-8d66-05a37a75079b',
      'islandora:10a53a3d-b740-4e9a-b93f-0b862611fc8c',
      'orlando:1155fe3e-6b41-477b-a7c2-51fdfd0cbd55',
      'orlando:1041f3b4-6698-4a2d-b958-4220ec021db4',
      'orlando:10429544-b413-4ac9-bfe9-99475c349906',
      'orlando:0f83e42a-e9d8-425c-bf0a-aa84346f905b'
    ]
    :)
    and not(@pid/data() = [
      "orlando:12eee6fb-61bd-4206-b61a-429d408df490", (: only alt title :)
      "orlando:1ef27b89-cdd2-4a33-bde1-f87a6e17bc6b",
      "orlando:26123127-c104-4cf3-bdb6-481cc096ed7f",
      "orlando:3b3899b1-3a76-4316-b27a-1a9076d53071",
      "orlando:50e7a5e6-6057-4fd4-82e2-eeca52ed96e4",
      "orlando:6aa3ed44-fb97-4c96-a1a7-f3260e512676",
      "orlando:79656acb-d97c-4674-92a1-32ad71f6a35f",
      "orlando:cde423bb-f0da-4f54-af3c-4f161883a15c",
      "orlando:d80a29cd-6155-4e7c-92db-46a414a2fa24"
    ])
    and not(@pid/data() = [
      'cwrc:4b9f29d1-1175-4a5d-a940-36fe3f2c1000'(: cmodel missing :)
    ])
    and not(@pid/data() = [
      "cwrc:514cdf25-088a-43c4-936c-6cd31fe5bc81", (: second titleInfo present with @displayLabel:)
      "cwrc:405bc80c-c5f1-4b17-ae68-f3ed9bec6829",
      "cwrc:5bd1a665-7441-45ce-b41b-47d59f3a6463",
      "cwrc:97df9a19-51fa-483e-a8fe-9c8bcb100ea0"
    ])
    and not(@pid/data() = [
      "cwrc:82771672-6210-41dd-976c-eaddf5a4817b" (: mods:modsCollection with multiple mods:mods :)
    ])
    and not(@pid/data() = [
      "tpatt:f996dd38-add2-4dd9-80c5-f231f63b7e4d" (: multiple titleInfo :)
    ])
    and not(@pid/data() = [
      (: customMods datastream :)
      "cwrc:024e3b4c-6475-4106-b44d-50163b88de33",
      "cwrc:0afde7e3-9bcb-4575-acbe-506137518c14",
      "cwrc:16c7eb11-20d5-40d8-846b-407ddde593b0",
      "cwrc:1eeac9af-8c76-4cfe-8a4f-ca1251491481",
      "cwrc:1f2ffec2-130c-4972-9d6e-5893ac817cf3",
      "cwrc:2b0f3fa5-195a-4155-98e2-b3a2acf82a7c",
      "cwrc:3954e8e3-4b91-4f0f-b3ad-02c9a6359e31",
      "cwrc:52e277a7-7199-4bdb-aeda-fee777a6568f",
      "cwrc:4209cad7-a8b5-4df0-bffe-813b18769cde",
      "cwrc:7ce6d435-5065-4f60-bba7-d48dda56abf4",
      "cwrc:809f9380-d505-40f0-a603-3c87820dbb93",
      "cwrc:80e2231d-21a4-4ca2-817a-4203b467f62b",
      "cwrc:821e8883-5fc9-42ce-9c1d-90ae4b25dabe",
      "cwrc:82771e96-20df-473d-addf-e4ae8fa1e4b2",
      "cwrc:8d92cfbc-a0c5-4eb9-a87e-9a8937472366",
      "cwrc:96b96a20-be74-4b8f-a94e-e185e2fbfe46",
      "cwrc:a2b2ae6b-5dfd-4f1f-888f-4e74e90dd434",
      "cwrc:b12a6c3a-3897-4064-8ccd-2c1308a0ccfb",
      "cwrc:b79b54b2-b578-44f8-81ff-bdf28d6200c2",
      "cwrc:cfeda34a-7234-4f39-aa96-ad0b27365c02",
      "cwrc:d1c3614e-d493-4368-8e7a-bb726be6167b",
      "cwrc:ea86b4d7-55d7-4bc7-96ab-f4bd9e5dd410",
      "cwrc:f80469f0-0e7b-4085-8c3c-157619d22246",
      "cwrc:f5dbdbbb-3278-4118-a81e-9a8e99f5cc2e",
      "cwrc:f85000bd-976c-46d8-91fa-06ef4786e331",
      "islandora:0420d279-288b-44ad-842b-aa2fd79ab514",
      "islandora:0848bfac-e872-40f8-bd7d-7f671a9176ac",
      "islandora:06d28f5a-c1a4-4a38-bfb5-0ff632ffc2e9",
      "islandora:0809c4e9-d1e1-4b32-a2e1-89526162083a",
      "islandora:0d8c7793-3834-4b6a-94da-da78bff64b8c",
      "islandora:192f762d-ce2e-4bf9-bb84-8ef3dc04d4fd",
      "islandora:2332e223-30ca-4ebc-91ee-ca3eacecd3dd",
      "islandora:26db603d-f286-4200-9628-9b894dcd9d82",
      "islandora:2eda9222-1061-4c91-b8ba-00221bd2dca4",
      "islandora:31eed935-74fb-46b4-a556-bab2b2d32302",
      "islandora:34df1745-6e7a-4b07-a161-4c7d0aa455dc",
      "islandora:373b03be-d0f9-47a5-b32d-4557b42b05e2",
      "islandora:4064c176-7df2-41e0-b743-499213d14919",
      "islandora:464888cb-d3a5-4b47-b8a8-7b7441a78309",
      "islandora:6f716484-f9e1-4397-a80e-e1094d608e8c",
      "islandora:72cf498d-da07-4e47-8f84-6c471d68e576",
      "islandora:73c394a0-a535-4b30-bc4d-223304331c5b",
      "islandora:78ec8701-1967-4072-b556-f437cd8e926b",
      "islandora:7fcc8eae-0530-4438-aa06-b320104db5a6",
      "islandora:83c8fba8-94f1-407a-905d-f33cb779d2a1",
      "islandora:8703dc6a-9d77-46a1-9635-e9d27531b2be",
      "islandora:e3688739-4a29-4c14-85c0-a3a1353cfc0a",
      "islandora:88cbbb0e-eafd-48a1-a77f-a0395ceae8f5",
      "islandora:88ef05e3-d467-4f76-a71d-056f4fc642d9",
      "islandora:e5b3a92e-d777-4803-8d2e-8bebf4be31da",
      "islandora:e610c477-4991-4c7b-86e5-a50a49ca5871",
      "islandora:e6ea2bf6-6661-4d36-b1b0-9798cf1ebfc3",
      "islandora:8a87f1f7-0dc5-44ee-bb5a-9e81dbcfbedd",
      "islandora:f014a55d-3d70-4d68-b167-6ab607aa9f0e",
      "islandora:92b236f5-448a-42cf-926d-3f11faaac46d",
      "islandora:95ce6a30-ac2b-4776-a243-ad762659c009",
      "islandora:a0692243-073e-41e3-b0d4-bc8ae8a5ba65",
      "islandora:a1ce963e-3b32-4eb7-bdbf-35293825df55",
      "islandora:a6baa954-d970-48d9-8f9b-47e4985d2095",
      "islandora:af7b38a1-1b45-4f21-8d38-f153001e6e23",
      "islandora:b9152ddf-aafb-4c1a-b961-af67b0ba85d4",
      "islandora:bc26490b-c058-43aa-acee-550177979293",
      "islandora:bedef0f0-61bf-4673-b445-812bcf09e56f",
      "islandora:c187323e-b959-4434-9835-492534d0057a",
      "islandora:d102f4b0-2be7-450a-aa74-370bbe88cf94",
      "islandora:d172a74e-f5e7-4e25-b453-5df6782ffd7e",
      "islandora:d27030ee-0745-42fd-9fee-7b92f5e79150",
      "islandora:d7151390-7de1-4ad3-99fc-dc35f73073aa",
      "islandora:d900a10f-ca96-4dab-ab87-5544f0dedc79",
      "islandora:d918399e-480d-441b-9943-969b69a17fbc",
      "islandora:dccfec62-5d6e-4ff9-9de9-4da392ab1ee7",
      "islandora:e0013f9a-af8b-4576-b5c0-5f03f2ac861a"
      ])
    (:
    no main title and no dc:title that are within the list of supported cModels
    /metadata[
        not(@models = $tH:UNSUPPORTED_MODELS)
        and not(resource_metadata/(mods:mods|mods:modsCollection/mods:mods)/mods:titleInfo[(not(@*) or @usage/data()='primary')]/mods:title)
        and not(resource_metadata/oai_dc:dc/dc:title)
    ]/@pid/data()
    :)
    and not(@pid/data() = [
      "cjww:be0d8a1e-def6-4bf5-982f-5091426cf87a",
      "cwrc:1c854a9b-665e-477b-a5a2-ef930a6c0e98",
      "cwrc:461446eb-3df3-4ac1-acb2-e434af35eefb",
      "cwrc:5e2c611d-9c33-433e-9c82-987129c962da",
      "cwrc:96625e12-5100-4748-8db7-806d8fa2bf3f",
      "cwrc:b7fe8314-66d6-4b4c-b601-c76f3907ea1c",
      "cwrc:f06d59b8-702d-4b59-9820-fa691bb0a1ba",
      "cwrc:f4eb1dad-1bf9-42f8-9630-d8f41bbdeae3",
      "cwrc:f5a34588-9c9c-4ac3-90ef-2bd85a82e135",
      "digitalpage:1158b947-9568-4941-b612-ed0523fdf3fb",
      "emic:04d8a099-ab89-4670-8c98-61725aa629ae",
      "digitalpage:6abb9b35-918e-4ae5-b0e0-96af4f93e172",
      "digitalpage:bad4754a-7dc7-4dba-9ab3-386dcdab7259",
      "digitalpage:c2dee765-9488-4563-a3b9-bdc8512405f6",
      "emic:8ca7a29c-e881-4e34-a6f7-ca04dadcf435",
      "islandora:03055d22-2b66-4d06-8d66-05a37a75079b",
      "islandora:10a53a3d-b740-4e9a-b93f-0b862611fc8c",
      "islandora:1673b8cb-a67f-4980-af7c-aa15e67daa76",
      "islandora:364404f5-5be3-469d-bbca-2a1be3b4a077",
      "orlando:0f83e42a-e9d8-425c-bf0a-aa84346f905b",
      "orlando:01442a17-0d8c-4aa8-8e80-abdb8c48fc88",
      "orlando:035d0c20-b0c3-4096-8440-b6c5e3f8f696",
      "orlando:0a632400-e37a-4063-bdc1-a79072f34057",
      "orlando:0bd1ee72-17cb-4ddf-9f72-580a355480cb",
      "orlando:0d1a3308-eefb-4f39-9490-d450a0c7731e",
      "orlando:0d3f4029-e265-4fae-9099-f7c2cd31e043",
      "islandora:d85ffb1d-80e9-4228-8463-49fa10d71bca",
      "orlando:173afbf2-5897-4c10-b8a6-3b047bccae21",
      "orlando:17542068-a2e0-460a-8675-ba66a0933e97",
      "orlando:19222c3d-7aea-4029-8ce8-84cb6773186a",
      "orlando:19d1e1a7-baee-4fee-89af-7fa37d5b7303",
      "orlando:202767b5-10e9-4bbd-8b0e-596c7180bb7b",
      "orlando:21611c98-d9a7-4511-b3bb-93fee0ef30ca",
      "orlando:22e78f0d-5a6d-4519-89dd-4a75a320abb8",
      "orlando:440713d6-b7a3-4667-b7ac-7ed5d19db0b9",
      "orlando:3c20a48d-c42d-4086-bf1a-58da87ce7b30",
      "orlando:27d66aba-1d93-4b1a-86fa-3558fbfa1f0f",
      "orlando:453c78bc-0430-4612-8805-60dece65b7f0",
      "orlando:2a371f87-6dba-4ca9-a6d7-bbcc9474b32c",
      "orlando:2bb1afde-b4c3-45c9-9390-9aab54f09f75",
      "orlando:2d03ca67-1531-45da-86de-528877d6ed20",
      "orlando:48b44dd9-7217-4d9c-ac3f-a632dd0a109d",
      "orlando:361d147b-8d7f-44db-8eb3-d8db485211e4",
      "orlando:4f298eef-0a28-4c53-9f41-aa131ffb34a4",
      "orlando:39095770-57ff-49c6-b787-a7c736aa86c0",
      "orlando:52f19b15-1b4e-48e5-94d6-c128909063c3",
      "orlando:53173924-1cb9-45d4-a8d3-880d0f319ea6",
      "orlando:576bfa87-13b7-40b7-a984-e11e5dfd8f4c",
      "orlando:57816d09-4843-41a9-9323-1680359cbfc7",
      "orlando:5a45efb9-fa2e-4270-925c-563c79d60805",
      "orlando:5be90e8a-6930-43fc-bf61-32b5dcdc750a",
      "orlando:5cafd1fd-df7f-47fd-90e7-ddbc0b8a41fe",
      "orlando:5ce6d129-9839-4182-bc87-fe61e79af06a",
      "orlando:5ed38401-e176-4916-8f0a-0383b0503ec8",
      "orlando:6a216d8c-c431-4a62-b9ef-1549e29bf632",
      "orlando:6acf18f2-adb4-4477-a068-64447e34109c",
      "orlando:6dd1d188-d61b-44dc-bec9-0d306f48ce12",
      "orlando:71f0e6fa-7535-4697-9871-9f0356b62a02",
      "orlando:72dba0db-03a4-41f6-be6e-0b4fd6886096",
      "orlando:7402af00-a0af-46c4-93aa-08d3009e2ebb",
      "orlando:75dab356-b0b1-4113-bca5-bc749129bc22",
      "orlando:76145750-a494-4418-9902-4f0f6393a38d",
      "orlando:7b678e5a-9f8b-4105-86e6-1f82c5afc866",
      "orlando:7c12cf04-3bc9-4989-b8a8-43c46bf7bfbc",
      "orlando:7ef166df-8520-4d16-8627-41cdb2eac1f1",
      "orlando:8091f794-6138-46ca-a794-92bcb6322e8c",
      "orlando:82ab3f3c-e4f6-4986-a208-49b8e45388f5",
      "orlando:84225e07-96a5-4c13-bcad-ecdc7f2d1a7a",
      "orlando:8a889093-5f85-4a2a-bb4f-b40c4cc8f06a",
      "orlando:8b17a994-f5c1-4252-bb6d-078eb03b8d77",
      "orlando:8f751dd9-a023-4e58-9084-6ffd19150ce6",
      "orlando:90f6bb6c-1f32-4310-b050-fcabc6cdcf6b",
      "orlando:98d98a7f-3c0b-4e13-917c-f48354713b24",
      "orlando:99cbdf7c-6027-43b4-8d14-715e23170e7a",
      "orlando:a23f6a21-89eb-4c05-b39e-b9fbf2b9df4f",
      "orlando:a40795a1-421a-447f-9fa8-6a1b4b1f253c",
      "orlando:ab4e2d6a-4c44-4c92-a54b-e380b32ad880",
      "orlando:bd440b09-9244-4432-abd9-86c1ea04a17c",
      "orlando:be97b402-b752-486a-a3e7-87940879a93e",
      "orlando:c01a0f4e-444e-4ee7-938d-a76a9b446e32",
      "orlando:c1bb018a-d8dd-4a30-b65b-19fec6cd7728",
      "orlando:c3eb177d-1e8a-4ee1-9422-f235b7438a5b",
      "orlando:c621bbd5-15d0-4346-8e32-7915519d83ca",
      "orlando:ca6db9c8-d2e9-46f5-bf97-cb104d84bb14",
      "orlando:d1b87208-57b0-47d3-a7bc-36b23e6bc8e6",
      "orlando:d04a705e-b7da-4bb5-bf8d-171e65404109",
      "orlando:d761214b-fe5e-4cb1-95d1-c24b65ab0958",
      "orlando:daaa0fbf-9876-48b2-a823-7b47c886c696",
      "orlando:e769ba67-94a8-4763-b9ee-b359ae89d8df",
      "orlando:ec3753ef-a4cf-4c41-98b6-883352de600c",
      "orlando:f40feeef-3ab4-4790-aaf7-40e244019a4c",
      "orlando:fb734966-b0fd-4ee8-b7df-87d06d3569eb",
      "orlando:fbded2c8-e03b-4bde-8fea-1e52f82a53ea",
      "orlando:fc8a01ac-e741-4841-a21c-a1c238522e27",
      "tpatt:e6e1e1d0-a4e6-4ded-9356-0441f9fcba3f"
      ])

    (: No MODS datastream -- some from CEWW (others likely removed by dataset pruning of non-migration collections :)
    and not(@pid/data() = [
      "cwrc:b71ca122-a1eb-4260-9d13-4640ad189488", (: ['cwrc:citationCModel', 'fedora-system:FedoraObject-3.0'] New Object :)
      "cwrc:c2103407-fb85-418e-9c26-a61817e91ba3", (: ['cwrc:citationCModel', 'fedora-system:FedoraObject-3.0'] New Object :)
      "islandora:15929477-e97e-48bf-bdaa-197ae04f84a6", (: ['cwrc:citationCModel', 'fedora-system:FedoraObject-3.0'] The Romance Of A Princess :)
      "islandora:1a632a5d-3b4e-4e15-b34a-5ec626b9f12b", (: ['cwrc:citationCModel', 'fedora-system:FedoraObject-3.0'] “Sepass Poems: Ancient Songs of Y-Ail-Mihth.” :)
      "islandora:22b1d946-fd04-4ab1-9472-0e1d3f7e16b2", (: ['cwrc:citationCModel', 'fedora-system:FedoraObject-3.0'] The History of Canada :)
      "islandora:3925df73-d8ca-4c4b-adf5-ad7e13b55132", (: ['cwrc:citationCModel', 'fedora-system:FedoraObject-3.0'] We and the World, Part II: :)
      "islandora:5dae139b-75d3-4f3a-81ef-51ffbf3d7e6c", (: ['cwrc:citationCModel', 'fedora-system:FedoraObject-3.0'] Eunice :)
      "islandora:5e4b39ad-07b6-4c19-ac94-955e895d49c6", (: ['cwrc:citationCModel', 'fedora-system:FedoraObject-3.0'] Beyond The Grave :)
      "islandora:80909985-7085-4142-a2ae-c65580157772", (: ['cwrc:citationCModel', 'fedora-system:FedoraObject-3.0'] One Hundred Years With The Baptists In Amherst :)
      "islandora:901250d3-9032-4cc5-b9b0-46aeec28ee98", (: ['cwrc:citationCModel', 'fedora-system:FedoraObject-3.0'] Annie Louise (Laird) Yeigh fonds :)
      "islandora:97f3dc06-047a-414a-94b0-9f221f7564ff", (: ['cwrc:citationCModel', 'fedora-system:FedoraObject-3.0'] Sketches of Labrador Life, by a Labrador Woman :)
      "islandora:9b4cbcb7-4e9e-497c-bced-4cabea467eb2", (: ['cwrc:citationCModel', 'fedora-system:FedoraObject-3.0'] Songs of the Great Dominion: Voices From the Forests Andwaters, the Cities of Canada :)
      "islandora:a8bd8d7d-ff5e-469e-9d69-c6a2d46abbb0", (: ['cwrc:citationCModel', 'fedora-system:FedoraObject-3.0'] Lila and the Waterfall Fairies :)
      "islandora:b445766d-4806-4a2e-86b9-093b84281fd8", (: ['cwrc:citationCModel', 'fedora-system:FedoraObject-3.0'] Dictionary of Literary Biography :)
      "islandora:c48390b2-c7d1-4d8f-9a45-870b5b2a7531", (: ['cwrc:citationCModel', 'fedora-system:FedoraObject-3.0'] Songs of the Great Dominion :)
      "islandora:ca8b302e-a92c-42ae-9ee8-6092b0d566cb", (: ['cwrc:citationCModel', 'fedora-system:FedoraObject-3.0'] New Object :)
      "islandora:d00c4691-fc20-4ffd-bd4e-dfb5739883e7", (: ['cwrc:citationCModel', 'fedora-system:FedoraObject-3.0'] The Canadian Bookman :)
      "islandora:e3c097d8-21ee-48f3-9687-feeb16f566ec", (: ['cwrc:citationCModel', 'fedora-system:FedoraObject-3.0'] One Hundred Years With The Baptists In Amherst :)
      "islandora:e886e949-d27b-4baf-b1e5-4b675e7651b4", (: ['cwrc:citationCModel', 'fedora-system:FedoraObject-3.0'] The Canadian Birthday Book With Poetical Selections For Every Day in the Year From Canadian Writers, English and French :)
      "islandora:f7bb9c39-c290-4bc9-b2c6-013578b8d251", (: ['cwrc:citationCModel', 'fedora-system:FedoraObject-3.0'] The Romance Of A Princess :)
      "islandora:f7c7b659-7be8-44f8-b6ca-6a17200e1a27", (: ['cwrc:citationCModel', 'fedora-system:FedoraObject-3.0'] A Gentlewoman in Upper Canada :)
      "islandora:0739ace9-b30c-4bf8-835c-c12672f75039", (: ['fedora-system:FedoraObject-3.0'] New Object :)
      "islandora:63c206cd-ee0b-4e9a-923c-40eefdba3e86", (: ['fedora-system:FedoraObject-3.0'] New Object :)
      "cwrc:410129e7-3fed-4d30-9263-9be8ddeea2d8",      (: ['islandora:binaryObjectCModel', 'fedora-system:FedoraObject-3.0'] New Object :)
      "digitalpage:27d026b8-7c92-4974-9637-48bfe40eed74", (: ['islandora:bookCModel', 'fedora-system:FedoraObject-3.0'] mods000002 :)
      "emic:4379",                                      (: ['islandora:bookCModel', 'fedora-system:FedoraObject-3.0'] An Open Letter to Louis Dudek :)
      "emic:5023",                                      (: ['islandora:bookCModel', 'fedora-system:FedoraObject-3.0'] New Object :)
      "digitalpage:33045eb2-6873-461b-9602-aed1dcc535f3", (: ['islandora:eventCModel', 'islandora:entityCModel', 'fedora-system:FedoraObject-3.0'] Murder of Mrs. Sibley :)
      "islandora:tei_sample_schema",                    (:['islandora:markupeditorschemaCModel', 'fedora-system:FedoraObject-3.0'] CWRC_EMiC_TEI_Schema :)
      "cwrc:f2f8506f-39ce-426a-ad33-9ed2e276e1e9",      (: ['islandora:sp-audioCModel', 'fedora-system:FedoraObject-3.0'] test audio 2020 :)
      "cwrc:f281637e-42af-4a7b-9e56-58de1b29a61b",      (: ['islandora:sp_html_snippet', 'fedora-system:FedoraObject-3.0'] New Object :)
      "cwrc:f0b1b6a5-33fa-40e4-92a7-137ebf58613a"       (: ['islandora:versionCModel', 'fedora-system:FedoraObject-3.0'] New Object :)
    ])
  ]

(: Create a local:generic_custom_function to create custom, non-generic fields specific to a given project such as "linked agent" :)
(: The `#2` in the function: the digit represents the number of arguments of your function (otherwise get an empty-sequence error). :)
return tC:output_csv_test_min($items, local:generic_custom_function#1, tC:generic_custom_properties#4, $FIELD_MEMBER_OF)
