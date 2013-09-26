<?php
require_once('vendor/autoload.php');

$indices = array(
    array(
    	'name' => 'contact_lists_bkp',
    	'mappings' => require '/home/shane/dev/hotornot-dev/php/api-shane/bin/data/elasticsearch/indices/contact_lists.php',
    ),
    /*
     array(
    	'name' => 'contact_lists',
    	'mappings' => require '/home/shane/dev/hotornot-dev/php/api-shane/bin/data/elasticsearch/indices/contact_lists.php',
    ),
    */
    /*
    array(
    	'name' => 'social',
    	'mappings' => require '/home/shane/dev/hotornot-dev/php/api-shane/bin/data/elasticsearch/indices/social.php',
    )
    */
);

dropIndices($indices);
makeIndices($indices);


function dropIndices( $indices ){
    $esClient = new BIM_DAO_ElasticSearch( BIM_Config::elasticSearch() );
    foreach( $indices as $index ){
        $res = $esClient->call('DELETE', $index['name'] );
        print_r( "$res\n" );
    }
}

function makeIndices( $indices ){
    $esClient = new BIM_DAO_ElasticSearch( BIM_Config::elasticSearch() );
    foreach( $indices as $indexConf ){
        $res = $esClient->call('PUT', $indexConf['name'], $indexConf['mappings'] );
        print_r( "$res\n" );
    }
}

