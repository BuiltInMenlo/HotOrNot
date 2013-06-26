<?php 
ini_set('memory_limit', '2G' );
require_once('vendor/autoload.php');

$query = array(
    "from" => 0,
    "size" => 1000,
    "sort" => array(
    	"_id" => "descending"
    )
);

$conf = require 'config/elastic_search.php';
$search = new BIM_API_ElasticSearch( $conf );

$res = $search->call( 'POST','geo/timezone/_search', $query );
$res = json_decode( $res );

while( isset($res->hits->hits) && is_array( $res->hits->hits ) && $res->hits->hits ){
    foreach( $res->hits->hits as $geo ){
        $tz_id = $geo->_source->tz_id;
        try{
            $obj = @new DateTimeZone($tz_id);
        } catch( Exception $e ){
            print_r("removing $tz_id\n");
            $search->call('DELETE',"geo/timezone/$geo->_id");
        }
    }
    $query["from"] += $query['size'];
    $res = $search->call( 'POST','geo/timezone/_search', $query );
    $res = json_decode( $res );
}
