<?php
require_once 'vendor/autoload.php';

// b93effd2-8f09-11e1-9324-003048bc	H:sh3.civismtp.org:6251332	2013-06-06 11:00:00	Agg_Source_Instagram	agg	getEventPics	0	*/30 * * * *

$job = (object) array(
	'class' => 'BIM_Jobs_Challenges',
	'method' => 'processVolleyImages',
	'data' => (object) array( 'volley_id' => 37542 ),
);

print_r( $job );

$j = new BIM_Jobs_Challenges();
$j->processVolleyImages( $job );

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