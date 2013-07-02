<?php
require_once('vendor/autoload.php');

/*
 * get all events
 * and for each event
 * we decode the json
 * prepare the evnt for indexing
 * add the event the same way we do for aggergation
 */

ini_set('memory_limit', '2G' );

echo( ini_get('memory_limit')."\n" );

require_once 'Outpic/DAO/Mysql/Event.php';
require_once 'Agg/Source/Eventful.php';
require_once 'BIM/Search/ElasticSearch.php';

// get db object
$conf = require 'config/db.php';
$db = new Outpic_DAO_Mysql_Event( $conf );

// get agg object
$agg = new BIM_Growth_Source_Eventful();

// get search object
$searchConf = require 'config/elastic_search.php';
$search = new BIM_Search_ElasticSearch( $searchConf );

$regionData = $agg->getRegions();
$regions = array();
foreach( $regionData as $region ){
    $regions[ $region->outpic_region ] = $region;
}

// get all events
$sql = "select id from gojo.eventful_events";
$stmt = $db->prepareAndExecute( $sql );
$events = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );

$n = -1;
//$events = array((object) array( "id" => 'E0-001-047642368-3'));
foreach( $events as $id ){
    $n++;
    if( !($n % 10) ){
        //usleep( .01 * 1000000 );
    }
    // get the event
    $sql = "select * from gojo.eventful_events where id = ?";
    $params = array( $id->id );
    $stmt = $db->prepareAndExecute( $sql, $params );
    $event = $stmt->fetch( PDO::FETCH_OBJ );
    $ev = json_decode( $event->data );
    
    if( preg_match('/SAN\_FRAN|MONTRAEL/', $ev->outpic_region) ){
        print_r($ev->id."\n");
        continue;
    }
    
    // set some data and index the event
    $ev->tz_id = $regions[ $ev->outpic_region ]->time_zone;
    $agg->indexEvent( $ev );
    $search->refresh();
    
    // now get the event from the index
    $event = $search->getEventByAlias( $id->id );
    
    if( !$event ){
        print_r( array($event, $id) );
        exit();
    }
    
    // get all of the photos in mysql
    $sql = "select * from gojo.eventful_instagram_stream where event_id = ?";
    $stmt = $db->prepareAndExecute( $sql, $params );
    $photos = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
    
    //if( $photos ){
        //print_r( array( $event->id, count( $photos ) ) );
    //}
    
    foreach( $photos as $photoData ){
        $photo = json_decode( $photoData->data );
        if( !$photo ){
            throw new Exception("cannot decode a photo");
        }
        $agg->indexInstagramPic( $event, $photo );
        $search->refresh();
    }
}

