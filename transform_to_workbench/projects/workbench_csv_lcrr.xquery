xquery version "3.1" encoding "utf-8";

(: tpatt project specifics :)
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
(:
: Required properties:
:  * field_linked_agent
:  * field_related_item_contributor_s
:)
declare function local:generic_custom_function($metadata as item()*) as element()*
{
    <field_linked_agent>
    {
        (: ToDo: very simplistic; add project specific code, if needed :)
        tH:generic_linked_agent(
            $metadata/resource_metadata/mods:mods/mods:name[exists(mods:namePart/text())]
            )
    }
    </field_linked_agent>,
    <field_related_item_contributor_s>
    {
        (: ToDo: don't use this placeholder; add project specific code, if needed :)
        tH:generic_linked_agent(
            $metadata/resource_metadata/mods:mods/mods:relatedItem/mods:name[exists(mods:namePart/text())]
            )
    }
    </field_related_item_contributor_s>
};

(: define the list of PIDs to transform :)
let $id_list := [
'lcrr:root',
'islandora:e223fe3c-3e0f-43f6-bbe3-dbc0055abde3',
'islandora:aa869c70-9664-4798-abe6-8ee4479532ff',
'lcrr:bibliographie',
'lcrr:inProgress-correspondence',
'lcrr:inProgress',
'islandora:8620b243-f4e8-47b8-9b88-db5071724325',
'islandora:45b310cb-b6b7-4c5d-92c3-a14d15bdfb78',
'islandora:9cb03afe-40a6-4e66-b23a-82d6510446a8',
'islandora:3c9cca6c-a351-4d6c-9588-c861b1594816',
'lcrr:cd84cf2e-d5b3-48ab-9d4b-09e039d269d5',
'islandora:c8bbc5d5-90d8-4f1c-a746-dbdc038242f1',
'islandora:027cc1ed-8641-4485-94c0-0a4e991e6baa',
'islandora:489fc56c-6492-4f24-8abc-422a2cb8aa8d',
'islandora:e19bb7d0-0226-48b4-8d30-466c3e77fa11',
'islandora:b50f03ba-7314-4841-ac66-4610c283fe96',
'islandora:4d76e1ac-9ff3-4f50-8cf4-4f567837d065',
'islandora:4eb97ce8-d4aa-40ce-9079-0a571bd05572',
'lcrr:82750c73-a908-4c41-a420-78649567270e',
'islandora:a11bc175-5396-46f8-be7f-68e44baa3c81',
'islandora:6835eb18-f7e8-483d-87c3-95ac339fdb7c',
'islandora:2d318a04-80a6-4949-a72f-735993a9cdbb',
'islandora:b5fa0548-f559-446e-bb57-6e163281561a',
'islandora:fe85eb3d-49e7-4914-b6af-f1a5bf641096',
'islandora:46444ff3-5644-47bc-9833-e18bf3fe58b6',
'islandora:8afb1c47-458d-4f5b-9eb6-5cfe461fedd1',
'islandora:f160a605-3f5b-460b-b551-f46d3d957071',
'islandora:49e2ff6e-6e79-4ce1-9498-701eadeb1b35',
'islandora:0d695b88-ec94-47e2-b41b-6ee1dd9137b4',
'islandora:f0f73986-fd4d-4e77-a6fc-511acf0b0802',
'islandora:abe3e18b-5b62-4159-a3bc-2b952e977ccc',
'islandora:cba7a6fa-43aa-4543-9b84-736d11977ec5',
'islandora:be689ef9-df57-4a54-b277-910b6e6ab3e7',
'islandora:54efc1a7-c9aa-4782-8ea8-d8a247c59ae3',
'islandora:136b387a-d46c-46aa-9e76-73acef5ee3f2',
'islandora:a676d2fb-7519-4d2e-a72d-f909ceff93ed',
'islandora:56343bcd-07bb-4719-8f7e-abcc1b7b4672',
'islandora:cb1f1927-9d80-4d32-b512-502d37ecd504',
'islandora:21e35691-538b-472f-862c-40fdfbc16237',
'islandora:c35632ad-4d80-4ac4-b562-ea42ec8e1cf8',
'islandora:d0b9e691-1c5d-43d6-ae7d-4513601d8ac8',
'islandora:c47182b5-6d0e-4afb-a1b9-7f2624b3ebae',
'islandora:4639a8d5-247e-4109-a7e2-3e5083f296f0',
'islandora:aac2638e-2d90-4734-bde3-f5b2d2abd22e',
'islandora:f07f9ab9-a616-4362-b4d3-61d128cf8716',
'islandora:b44d837d-bbec-4ce2-bd06-d7174c35f1cd',
'islandora:ba13b48e-fb2f-464d-91c5-c04f93030892',
'islandora:465454ec-7eb5-4e88-bf18-dc0cc745f8b8',
'islandora:1168c57c-7c13-4217-aa0c-c51b3849e122',
'islandora:304011bd-4516-4250-be7b-c3169b30610a',
'islandora:79e4a951-385d-42f3-a19e-f8f827383d72',
'lcrr:d0eb62e6-4726-4949-8843-79ae61ae30bd',
'lcrr:b25804bc-09b1-4fa5-abae-40e80bcfe163',
'lcrr:d580cff2-f2c4-4334-9b3d-f15cddc9b8e0',
'lcrr:08e317a9-f396-4ca5-a2ea-66dc8937dbeb',
'lcrr:1ca80d61-15c2-4230-9978-0e1b95a4df61',
'lcrr:790d2a37-bda1-4286-917b-31d029631eef',
'lcrr:2a39b1d4-389b-44d6-8fbf-09fc7839a36b',
'lcrr:51147b67-dee7-4827-be72-c186993f029c',
'lcrr:7534c0d4-b5ff-48a9-9d5f-7ffd1595c73d',
'lcrr:679b7935-a9f5-4d40-9e4c-01e3e00b6e5d',
'lcrr:1646c905-180b-4fda-b7f3-8e2fc335cb8b',
'lcrr:19d26f18-5d6e-499e-bbad-9ccdb76eb03d',
'lcrr:b4f4ca91-8579-4f6e-8809-07426b50074a',
'lcrr:6bf5ec92-5e0f-46d6-9f58-b3663fb186df',
'lcrr:78d93d63-3e3f-4a8b-bf9f-65808a7d8325',
'lcrr:3e94abfd-b4f8-48cc-a251-137744c1d622',
'lcrr:c4274cf1-1b63-4c8a-be34-b0f9e1d9574e',
'lcrr:b55fcaf3-10b4-4f57-be06-018bef70d362',
'lcrr:249003f9-8838-4141-bfb1-9809c0eabcc1',
'lcrr:538f4e8e-9629-42a9-8f7b-559f0982cf2f',
'lcrr:45dcffa9-c9d2-475f-a98d-ad87f0fe4536',
'lcrr:d7461bee-4386-4834-85b7-b86c23decd6d',
'lcrr:0503c308-fc36-4e8a-8ff1-0a1926204d6e',
'lcrr:4eabb997-6a62-46b3-a3a1-ad50ad39d753',
'lcrr:3c445686-5bf5-4808-82ed-84b5e93ea139',
'lcrr:956e273f-8a32-47d6-be01-3d9316b788d0',
'lcrr:e98c5506-f3af-4ee2-84f8-099084737f3f',
'lcrr:3d6ab07e-ce4e-42d1-bcd1-a429ba93000b',
'lcrr:a291d2c3-e277-407c-aa5c-2c1a88b8b7fd',
'lcrr:3f2d5699-14b2-4d1c-a0d6-3a5865d2c17b',
'lcrr:24a308bd-0c43-44e5-b8cc-c6b092f018c2',
'lcrr:9bde4bc2-93b4-4ebc-afd4-60aa395c2d09',
'islandora:c8a76856-69f6-4090-afe8-e5d6757cdc3e',
'lcrr:95cf1c84-9fc9-4e06-8dff-e87cd8a7ee34',
'lcrr:60f109e0-1e2b-4e2f-b213-8733b2b20e0b',
'islandora:9518bb58-3c09-45d2-b112-425807d71057',
'lcrr:acc48629-99f9-4d5f-a5f0-c661d0c57daa',
'lcrr:652c2792-0ae4-41e2-b357-610e8e13661f',
'lcrr:b110e446-e5e2-43b8-9d59-8efa1ac7cf51',
'lcrr:7d355224-c6c8-4b45-b23c-8c73e1d931fa',
'lcrr:6882addf-4e13-4bc5-af71-1b7fc989cb10',
'lcrr:64e1ae22-08dd-4bf6-bd5f-caad849d2985',
'lcrr:3473a3c9-9eb2-416a-9e09-ebaf494104ae',
'lcrr:236cb94c-e4f8-48b2-8952-0944bece02f6',
'islandora:052b9df2-038c-45ec-acb4-60b52e048ba1',
'islandora:9b0e7d1f-d0e4-4fb4-a095-57c7d808234d',
'islandora:a4efad9a-b98f-46d3-9eec-887f12d38763',
'islandora:98109329-2978-47c2-aa4d-d2421427c6d3',
'islandora:55738b8b-1aa6-48df-a8d9-ca1c55c2042f',
'islandora:5f07ba87-d83e-4220-a054-62da49508a52',
'islandora:4ff89a82-8bb9-4c89-8185-3c23e5ced1fc',
'islandora:a2ea61cc-9c1f-47af-94a2-41549d285f66',
'islandora:69805440-5ef4-40b4-890a-2258e5e87567',
'islandora:4cfcf99b-347e-484a-8bcc-226a19d10703',
'islandora:eda4a5c3-fbc8-41e2-b7f9-4627abb7429d',
'islandora:a345b8f9-eead-4dd3-af4f-658414704f5f',
'islandora:d0b50153-4337-4dcd-845b-d6b01bacbf08',
'islandora:086c4708-43a7-432a-b3e1-06a8fb922ad5',
'islandora:b04c9b03-55ca-4aac-b493-aba785c7fd92',
'islandora:980a3e10-187d-4b86-9279-7371210168d4',
'islandora:29e56be0-8fb5-4fff-b01a-d23b61ce357c',
'islandora:c4a26f8c-0d8d-4bc2-b627-d0c46ce0c9ef',
'islandora:985d0885-fe54-4826-b9c8-9e65a6a8d41d',
'islandora:4db5f8f0-c77c-421b-85a3-82cb5026c820',
'islandora:759fd30c-0216-4c1b-846e-2fe04a796b3b',
'islandora:ffa2a83c-c6c8-4a9d-a183-1bb59b0e582e',
'islandora:c38aa315-2d60-4961-8be3-63ef3975bd42',
'islandora:5952e424-71aa-44b9-aaee-5f42a7cce214',
'islandora:7e40937e-f885-4ff2-b93a-04059e1b2734',
'islandora:a527b488-5471-468f-8c66-837b6324f638',
'islandora:058fd0f8-aa90-415b-adb8-565960a475cb',
'islandora:4aa2e097-59ca-471e-882f-e6cdd747e2db',
'islandora:0f988bc1-2ebb-45a9-bf26-b3f6b98df921',
'islandora:8a261689-6a86-4073-997d-c74b333899c3',
'islandora:0684cf75-9df3-4d65-a9c1-e19ac2a19dfa',
'islandora:f7808f92-7a39-47fa-ae53-1fcc9a2e7a0f',
'islandora:e8ffd4a2-0764-4699-bad3-9d0600fa517a',
'islandora:d65505da-342b-4389-a761-7e36fdfb0ab0',
'islandora:fdc62dec-9047-4f73-9dcb-c6db5fc1321c',
'islandora:4a14af92-634e-4754-a9ec-dbde5de59657',
'islandora:71b456c4-939f-4801-824c-de71cab75685',
'islandora:df6ab36a-acd6-46ff-997b-bee20a7da53d',
'islandora:c8616a3e-415c-413a-bbd5-096af5edeec4',
'islandora:a29f2ad5-443a-4a2f-8074-1fdc0472f3b4',
'islandora:4a12ce51-6782-4405-bf36-cea214d17775',
'islandora:c0b73142-64a6-4378-8c00-9f7bafe4e812',
'islandora:c487f36e-3a5e-42a9-9f57-09a7fbbfa44d',
'islandora:a4bf7a6f-4bf3-41cd-9696-8da5fd9d700c',
'islandora:cb769bde-8280-4104-b804-0acca5e1252f',
'islandora:9ba8051c-1d24-4be2-9ef4-17171a267228',
'islandora:7e8c0caa-42cc-47a9-9fcb-4e2f324a9a08',
'islandora:5114aa20-7974-49df-b663-917545de82ef',
'islandora:36ce9e2e-003e-487e-8583-f867a30d3f60',
'islandora:8b3e9224-8337-4883-b5d7-38eccb5c8d3d',
'islandora:fdf797ec-bdaa-41dc-b182-b9f3b75792b2',
'islandora:f6080fba-257d-43a6-b72e-ff6568faae5f',
'islandora:ba9caff4-41b2-43d9-87af-f83e3a871218',
'islandora:cf158e25-50ea-4d44-ae9c-862eec524ae1',
'islandora:1ce3a8c3-8c88-44a8-89c7-87f7c049b96e',
'islandora:57ae55ac-b6a3-4d49-ae58-a2f25debf1ad',
'islandora:a41e8ba2-354c-49ec-88e5-c5fb1b63c8d6',
'islandora:c89a3772-6072-4788-9913-fb64691ad63a',
'islandora:1aeb64ee-b2b5-4c92-b509-82c4149904f5',
'islandora:ec1e42f9-d6e8-4778-bb38-c4ec619b0c86',
'islandora:d3825b18-b8cb-4fbb-b9ed-569f83275945',
'islandora:7a1ced59-09e2-4054-bf64-a21e76451593',
'islandora:290375d7-d3e8-44b1-93a9-0adda930a421',
'islandora:ac06c595-f47b-48a8-b441-974dc8cbe09d',
'islandora:8f4e11c2-09b3-4360-85a1-2d02f17bf744',
'islandora:51adb77a-7969-4382-895a-4412cf405ea5',
'islandora:3e394cea-8a68-4a30-a2bd-9041314c8087',
'islandora:1d0ea3fb-23bf-4c1a-849b-99d262aa4655',
'islandora:e1b86df7-b487-4733-aee6-88afb7223590',
'islandora:a5038490-8075-477c-8c5c-9a0bad42d32b',
'islandora:febdf315-afd0-477c-bbcd-c0f870f446ef',
'islandora:fd8965f0-176c-4f96-9204-a40582d6a5da',
'islandora:dd7cb873-00f5-4259-9762-d5c14311f940',
'islandora:661aaf74-27b9-40dd-8f12-36c73fccb8d8',
'islandora:6516331d-df4e-4fe2-9af2-cbbc8d3c0626',
'islandora:ca8209bc-b67d-4857-be60-987d0c29bed4',
'islandora:6f3cb4af-274d-4a63-8197-ac1a6822fed8',
'islandora:10decc59-88c7-443a-9c5b-13f7e939b56a',
'islandora:2fe49fa5-5ade-46f4-8ab6-c22ff20526d9',
'islandora:750d2433-ba72-469a-a0de-15a63abd2f61',
'islandora:1358114a-cb7b-483e-972d-55d4e21e8833',
'islandora:0f541057-1bba-47f6-806b-60b4833c9613',
'islandora:22cb9982-9e18-4648-b8bf-8665f0e3c509',
'islandora:dede8afa-35cd-4902-9907-a7ddeb41578d',
'islandora:21c3ffc5-ae65-4e4e-aaa0-d147b199511e',
'islandora:a54096ff-59ac-4d24-b8d4-cc70ecad1c41',
'islandora:1a94c2d7-206e-4e03-aff0-124fee545c6a',
'islandora:44700aff-9c1d-4e7a-8bd2-52617c7a26bc',
'islandora:6f2e30c9-78b8-489f-bb12-cf49ea873fdd',
'islandora:3b5f887d-e219-42f3-b273-cf55113e61f3',
'islandora:3a46ac3a-ce7a-4cc9-8904-584e599f6837',
'islandora:3ad46c88-d19b-48a9-a1c7-a4f937bbc317',
'islandora:e1d81bf4-f856-4235-a4a6-16fad3b2f8dd',
'islandora:6d9ac480-0c80-4e3d-ac7f-08d3d5d7f131',
'islandora:4d5c58f1-34f4-40e6-bea7-26af5892d0ac',
'islandora:1429cca8-8832-4d58-83d5-f7922f79ba8a',
'islandora:e8bef713-a8c0-4619-8cfb-af4a69882242',
'islandora:f30255ac-e764-4673-95d9-53feb47a10ea',
'islandora:27545c6d-a52a-4538-8d43-0373f802470f',
'islandora:b13ddcfe-0d06-4956-be98-172addbbb486',
'islandora:db57f489-250e-499a-be7c-1b95d43378ce',
'islandora:60c23b8b-8bf1-44a7-8929-b28271fa1b6b',
'islandora:fa8ec970-fe70-4741-80a1-bdaed1538650',
'islandora:4baff99c-d6c6-4827-b8f7-cd2a372bc4dc',
'islandora:cf4e2dc0-23a1-4668-b912-a0986b8a4991',
'islandora:645094e3-8bcf-4a03-8024-483dea91aae9',
'islandora:cb7df149-e116-4722-87d7-137a2de01063',
'islandora:9488906e-a162-4e64-8371-76a84f73215d',
'islandora:9f9867b3-7649-4848-bf41-81bc5b9e6f26',
'islandora:92e8fde8-a5a1-4e36-aa65-2dfb52a4ee92',
'islandora:58a3315a-2183-4e43-9759-6daa73ff6ab9',
'islandora:57895bd7-3e26-4e6b-a3b8-e8a5e2b907cf',
'islandora:43df72f5-459a-4508-9934-12caad54480d',
'islandora:58b7ae10-b993-47d0-b63f-e264ac33c95b',
'islandora:6190d4ee-f9f8-43f1-b5e3-a2c3bbb53736',
'islandora:fd643379-0abd-4883-888a-0b4e52cb847e',
'islandora:4500c7e9-b3ff-4cff-bdd0-b965d10eadca',
'islandora:d3fc83f0-2fbc-49d8-8288-4322a0544a6a',
'islandora:2554c596-5d7f-4210-b4e9-7d7e2c9e13a3',
'islandora:c26667d4-3ee0-4822-82c3-5f60a3dd6db7',
'islandora:2935a8c6-9ea1-4b70-877d-08779f1b7a2d',
'islandora:a762751d-d257-4308-911b-9c380d448adb',
'islandora:df6a0232-802b-43fd-9b3f-7907dc565fa5',
'islandora:391e79e4-3672-495e-88c7-ba7c42aec2f1',
'islandora:6d189735-286a-4998-a47a-c3525e4b74a0',
'islandora:a0d3cfa9-3ac8-40de-9345-02d396a9eb85',
'islandora:09e6b821-4adf-46da-ba43-fbc2ef446f70',
'islandora:e3b40ddb-ddcf-407a-9079-07ea84fb25da',
'islandora:a8097733-62c6-4988-97b3-39977dc5520e',
'islandora:ad1509ed-0cd2-44f8-8813-b876a683cfe3',
'islandora:83c5bdfb-c51e-47b6-bf63-11a6b914c990',
'islandora:23fb2bdb-cab5-4690-b29a-83afc6a6e3a4',
'islandora:65179e03-d565-4599-b045-94ebc3df9db9',
'islandora:8c2fbe93-1946-46cf-b23d-0a85cee0040b',
'islandora:baada09e-a2e7-4e4c-b1b2-15e3842a1dd3',
'islandora:b0d9d285-45f1-49d1-b35a-50faec65c217',
'islandora:f1c57561-94a4-47a8-9999-8c985b0d0fe6',
'islandora:e6e395ca-8edf-47dc-abd8-10bb2fed7eb3',
'islandora:318055cc-66c1-4925-a98c-de6ee6d86259',
'islandora:06019c74-a0a7-45be-bf61-7ffb734d41de',
'islandora:0e8e168e-5915-4702-96d6-6404bef3970b',
'islandora:869509e0-8f55-4791-9441-1edc24e78821',
'islandora:04d71b9d-a2d9-4146-9bc8-91b3543ada4c',
'islandora:a7456abb-e1b3-46bd-800c-f2d162f7e7fd',
'islandora:090164aa-ca8e-4021-a1f1-319f123ea7d2',
'islandora:cc6740e9-e758-4b07-bf26-944bde99d18f',
'islandora:75c8a5cf-9d4f-47b7-9680-08212c5f1b2a',
'islandora:5cc9639d-8b93-4abc-8325-ff44bfde0e31',
'islandora:c1f5d070-fa1e-40c1-a929-182c5b073af3',
'islandora:fab6f3f6-bac5-4380-b463-ba2baa4c68fc',
'islandora:f991e6ed-e357-48ee-b4a1-f310128367fe',
'islandora:04534e8b-188c-4b9d-b27a-a4aff17d96da',
'islandora:fb681ea6-5541-465a-aa54-90c22162fd84',
'islandora:2fe5c2d2-c497-4bb2-91d2-ca55964d336c',
'islandora:4c07e8fd-5019-4c10-b6fe-ef2dcb5ab478',
'islandora:89729dfd-64c4-446c-bd21-e09ad43819ec',
'islandora:4ae8e962-2a2e-47cc-9cd5-7dc36fa8bb07',
'islandora:8ee118f7-568e-4e13-b112-92df1b5d2b65',
'islandora:ced36a87-7ac9-4810-ad28-c4b80a37c880',
'islandora:36792ce7-0b06-4a84-8156-f9dff465c224',
'islandora:5f8b6107-2e60-4455-9572-eab8d47c3ad1',
'islandora:70d08270-ceaf-4558-88a4-61f9209acf02',
'islandora:0c4f09b1-2569-486e-b2e1-07acb5838461',
'islandora:ac61d946-a7a3-4144-9659-d03d3252240a',
'islandora:2d9352ba-96d6-4c73-877f-4ba84a0bb98e',
'islandora:17ed8848-f2ca-4d3c-9b01-d5d47685c758',
'islandora:7a774b78-fc13-447c-87cc-1baf6b877bad',
'islandora:5c665501-3d15-4b32-83ca-9e59b45fd2e4']
let $items := /metadata[   
        @pid=$id_list 
    ]

(: Create a local:generic_custom_function to create custom, non-generic fields specific to a given project such as "linked agent" :)
(: The `#2` in the function: the digit represents the number of arguments of your function (otherwise get an empty-sequence error). :)
return tC:output_csv($items, local:generic_custom_function#1, tC:generic_custom_properties#4, $FIELD_MEMBER_OF)
