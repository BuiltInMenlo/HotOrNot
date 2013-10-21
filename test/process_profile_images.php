<?php
require_once 'vendor/autoload.php';

BIM_App_Challenges::checkVolleyImagesFromLastXSeconds();

/*
$volleyId = 16879;
$volley = new BIM_Model_Volley($volleyId);
$a = new BIM_App_Challenges();
$a->missingImage($volley->creator->img);
if( $volley->challengers ){
    foreach( $volley->challengers as $challenger ){
        $a->missingImage( $challenger->img );
    }
}
*/

//BIM_App_Challenges::checkVolleyImages();

//$imgPrefix = 'https://d1fqnfrnudpaz6.cloudfront.net/0da5ba0d733ad78a53c964bac6aec6806339935e23f1be1fd85ed7ce875bbb01_1382355163';
//$a = new BIM_App_Challenges();
//echo $a->missingImage($imgPrefix);

// b93effd2-8f09-11e1-9324-003048bc	H:sh3.civismtp.org:6251332	2013-06-06 11:00:00	Agg_Source_Instagram	agg	getEventPics	0	*/30 * * * *

/*
$job = (object) array(
	'class' => 'BIM_Jobs_Challenges',
	'method' => 'processVolleyImages',
	'data' => (object) array( 'volley_id' => 37542 ),
);

print_r( $job );

$j = new BIM_Jobs_Challenges();
$j->processVolleyImages( $job );
*/

/*
$job = (object) array(
	'class' => 'BIM_Jobs_Users',
	'method' => 'processProfileImages',
	'data' => (object) array( 'user_id' => 13154 ),
);

print_r( $job );

$j = new BIM_Jobs_Users();
$j->processProfileImages( $job );
*/