xquery version "3.1" encoding "utf-8";

(: Common parts of a transform :)

module namespace sb = "exportSetBuilder";
declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace dc = "http://purl.org/dc/elements/1.1/";


(: A generic / base xquery to produce input for islandora7_move_to_directory.py:)
declare function sb:output_csv(
    $item_list as item()*
    ) as element()*
{
    <csv>
        {

        for $i in $item_list
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
};


(::)
declare function sb:test_media(
    $item_list as item()*
    ) as element()*
{
    <csv>
        {

        for $i in $item_list
            order by $i/@models, $i/@pid
            for $media in $i/media_exports/media

            return
            <record>
                <pid>{$i/@pid/data()}</pid>
                <model>{$i/@models/data()}</model>
                <label>{$i/@label/data()}</label>
                <media>{$media/@filepath/data()}</media>
            </record>

        }
    </csv>
};



