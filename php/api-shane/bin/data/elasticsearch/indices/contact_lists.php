<?php
/**
contact_lists
{
    phone: {
        user_id : the volley user id that owns the list
        hashed_number: the hashed phone number of the volley user
        hashed_list : [ an array of hashed numbers ]
    }
}
*/
return array(
    'settings' => array(
        'number_of_shards' => 10,
        'number_of_replicas' => 2,
        'analysis' => array(
            'analyzer' => array(
                'indexAnalyzer' => array(
                    'type' => 'custom',
                    'tokenizer' => 'standard',
                    'filter' => array('lowercase')
                ),
                'searchAnalyzer' => array(
                    'type' => 'custom',
                    'tokenizer' => 'standard',
                    'filter' => array('lowercase')
                )
            )
        )
    ),
    'mappings' => array(
        'phone' => array(
            "_source" => array( "compress" => true),
            "_timestamp" => array( "enabled" => true ),
			'properties' => array(
                'user_id' => array('type' => 'integer', 'include_in_all' => false, 'index' => 'not_analyzed'),
    			'hashed_number' => array('type' => 'string', 'include_in_all' => false, 'index' => 'not_analyzed'),
                'hashed_list' => array('type' => 'string', 'include_in_all' => false, 'index' => 'not_analyzed'),
            )
        )
    )
);