<?php
require_once('vendor/autoload.php');

$file = $argv[1];
processTimezones( $file );

// #code	coordinates	TZ			comments
function processTimezones( $file ){
    $fh = fopen($file, "rb");
    $config = require 'config/elastic_search.php';
    $search = new BIM_API_ElasticSearch( $config );
    
    while( $line = fgets( $fh) ){
        if( preg_match('/^#/', $line ) ){
            continue;
        }
        $line = preg_replace('/^\s*(.*?)\s*$/', '$1', $line);
        $data = preg_split('/\t/',$line);
        $countryCode = $data[0];
        $latlon = $data[1];
        $tz_id = $data[2];
        $comment = isset( $data[3] ) ? $data[3] : '';
        
        // check if we can handle the time zone
        try{
            $dtz = @new DateTimeZone($tz_id);
        } catch( Exception $e ){
            print_r("cannot handle timezone $tz_id\n");
            continue;
        }
        
        list( $lat, $lon ) = convertCoords( $latlon );
        $action = (object) array( 
        	"index" =>
                (object) array(
                	'_index' => 'geo',
                	'_type' => 'timezone',
                	'_id' => $latlon
                )
        );
        $obj = (object) array(
            'code' => $countryCode,
            'tz_id' => $tz_id,
            'coords' => (object) array(
                'lat' => $lat,
                'lon' => $lon,
            ),
            'comment' => $comment,
        );
        
        $search->call('PUT', "geo/timezone/$latlon", $obj);
        //$action = json_encode( $action );
        //$obj = json_encode( $obj );
        //print("$action\n");
        //print("$obj\n");
    }
    fclose( $fh );
}

function convertCoords( $latlon ){
    preg_match('/^((?:\+|\-)\d+)((?:\+|\-)\d+)$/', $latlon, $matches);
    
    $lat = $matches[1];
    $lon = $matches[2];
    
    $lat = convertLat($lat);
    $lon = convertLong($lon);
    
    return array( $lat, $lon );
}

function convertLat( $lat ){
    $matches = array();
    preg_match('/^(\+|\-)(\d{2})(\d{2})(\d*)$/', $lat, $matches );
    $dec = degMinSecToDecimal($matches);
    return (float) $dec;
}

function convertLong( $long ){
    $matches = array();
    preg_match('/^(\+|\-)(\d{3})(\d{2})(\d*)$/', $long, $matches );
    $dec = degMinSecToDecimal($matches);
    return (float) $dec;
}

function degMinSecToDecimal( $data ){
    $sign = $data[1];
    $deg = (int) $data[2];
    $min = (int) $data[3];
    $sec = (int) $data[4];
    
    $totalSec = ($min * 60) + $sec;
    $frac = $totalSec / 3600;
    $dec = $deg + $frac;
    return "$sign$dec";
}
