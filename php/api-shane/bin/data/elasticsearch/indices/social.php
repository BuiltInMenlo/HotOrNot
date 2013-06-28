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
        'number_of_replicas' => 1,
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
        'friends' => array(
            "_source" => array( "compress" => true),
            "_timestamp" => array( "enabled" => true ),
			'properties' => array(
                'source' => array('type' => 'integer', 'include_in_all' => false, 'index' => 'not_analyzed'),
                'target' => array('type' => 'integer', 'include_in_all' => false, 'index' => 'not_analyzed'),
                'init_time' => array('type' => 'integer', 'include_in_all' => false, 'index' => 'not_analyzed'),
                'accept_time' => array('type' => 'integer', 'include_in_all' => false, 'index' => 'not_analyzed'),
                'state' => array('type' => 'integer', 'include_in_all' => false, 'index' => 'not_analyzed'),
                'source_data' => array(
                    'properties' => array(
                		'id' => array('type' => 'integer', 'include_in_all' => false, 'index' => 'not_analyzed'),
                		'avatar_url' => array('type' => 'string', 'include_in_all' => false, 'index' => 'not_analyzed'),
                		'username' => array('type' => 'string', 'include_in_all' => false, 'index' => 'not_analyzed'),
                    )
                ),
                'target_data' => array(
                    'properties' => array(
                		'id' => array('type' => 'integer', 'include_in_all' => false, 'index' => 'not_analyzed'),
                		'avatar_url' => array('type' => 'string', 'include_in_all' => false, 'index' => 'not_analyzed'),
                		'username' => array('type' => 'string', 'include_in_all' => false, 'index' => 'not_analyzed'),
                    )
                )
            )
        )
    )
);