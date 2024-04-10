xquery version "3.1" encoding "utf-8";

(: Orlando project specifics :)
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
declare variable $FIELD_MEMBER_OF external := "9999902";

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
        (: toDo: very simplistic; assumes mods:namePart contains text and in test; expand :)
        for $mods_name at $pos in $metadata/resource_metadata/mods:mods/mods:name[exists(mods:namePart/text())]
            let $role_list := tH:mods_name_role($mods_name/mods:role)
            let $person_type := tH:mods_name_type($mods_name)
            let $separator :=
                if ($pos > 1 or count($mods_name/mods:role) > 1)
                then $tH:WORKBENCH_SEPARATOR
                else ""

            return
                (: custom name formatter :)
                let $formatted_name := tH:mods_name_formater($mods_name)
                (: if mods name has multiple roles :)
                for $role in $role_list
                    return concat($separator, 'relators:', $role, ":", $person_type, ":", $formatted_name)
    }
    </field_linked_agent>,
    <field_related_item_contributor_s>
    {
        (: toDo: don't use this placeholder, add project specific code :)
        tH:generic_linked_agent($metadata/resource_metadata/mods:mods/mods:relatedItem/mods:name[exists(mods:namePart/text())])
    }
    </field_related_item_contributor_s>
};

(: define the list of PIDs to transform :)
let $id_list := [
]

let $items := /metadata[
    (
        @pid=$id_list
        or contains(@pid/data(), "orlando:")
        (: and @pid="orlando:136825c0-4753-43d4-904c-d03dbcad0644" :)
    )
    and not(@models = $tH:UNSUPPORTED_MODELS)
    and not(@pid= [
        (: only alt title :)
        "orlando:12eee6fb-61bd-4206-b61a-429d408df490",
        "orlando:1ef27b89-cdd2-4a33-bde1-f87a6e17bc6b",
        "orlando:26123127-c104-4cf3-bdb6-481cc096ed7f",
        "orlando:3b3899b1-3a76-4316-b27a-1a9076d53071",
        "orlando:50e7a5e6-6057-4fd4-82e2-eeca52ed96e4",
        "orlando:6aa3ed44-fb97-4c96-a1a7-f3260e512676",
        "orlando:79656acb-d97c-4674-92a1-32ad71f6a35f",
        "orlando:cde423bb-f0da-4f54-af3c-4f161883a15c",
        "orlando:d80a29cd-6155-4e7c-92db-46a414a2fa24",
        (: no main title and no dc:title that are within the list of supported cModels :)
        "orlando:0f83e42a-e9d8-425c-bf0a-aa84346f905b",
        "orlando:01442a17-0d8c-4aa8-8e80-abdb8c48fc88",
        "orlando:035d0c20-b0c3-4096-8440-b6c5e3f8f696",
        "orlando:0a632400-e37a-4063-bdc1-a79072f34057",
        "orlando:0bd1ee72-17cb-4ddf-9f72-580a355480cb",
        "orlando:0d1a3308-eefb-4f39-9490-d450a0c7731e",
        "orlando:0d3f4029-e265-4fae-9099-f7c2cd31e043",
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
        "orlando:fc8a01ac-e741-4841-a21c-a1c238522e27"
        ])
    ]

(: Create a local:generic_custom_function to create custom, non-generic fields specific to a given project such as "linked agent" :)
(: The `#2` in the function: the digit represents the number of arguments of your function (otherwise get an empty-sequence error). :)
return tC:output_csv($items, local:generic_custom_function#1, tC:generic_custom_properties#4, $FIELD_MEMBER_OF)
