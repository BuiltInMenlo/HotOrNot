<?php
require_once('vendor/autoload.php');

$indices = array(
    'contact_lists'
);

dropIndices($indices);

$indices = array(
    array(
    	'name' => 'contact_lists',
    	'mappings' => require '/home/shane/dev/hotornot-dev/php/api-shane/bin/data/elasticsearch/indices/contact_lists.php',
    )
);

makeIndices( $indices );


function dropIndices( $indices ){
    $esClient = new BIM_DAO_ElasticSearch( BIM_Config::elasticSearch() );
    foreach( $indices as $index ){
        $res = $esClient->call('DELETE', $index );
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

