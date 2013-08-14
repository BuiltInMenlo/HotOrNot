<?php
require_once 'vendor/autoload.php';

// b93effd2-8f09-11e1-9324-003048bc	H:sh3.civismtp.org:6251332	2013-06-06 11:00:00	Agg_Source_Instagram	agg	getEventPics	0	*/30 * * * *
/**
$job = (object) array(
	'class' => 'BIM_Jobs_Growth',
	'method' => 'doRoutines',
    'params' => '{"personaName":"exty86", "routine":"loginAndAuthorizeApp","class":"BIM_Growth_Instagram_Routines"}'
);

//$q = new BIM_Jobs_Growth();
//$q->doRoutines( $job );

$q = new BIM_JobQueue_Gearman();
$q->doBgJob( $job, 'growth' );

*/

$params = (object) array(
    'username' => 'shanehill00',
    'password' => 'i8ngot6',
    'volley_user_id' => 881, 
);

$job = (object) array(
	'class' => 'BIM_Jobs_Instagram',
	'method' => 'doRoutines',
    'data' => $params
);

$q = new BIM_Jobs_Instagram();
$q->linkInBio( $job );

//$q = new BIM_JobQueue_Gearman();
//$q->doBgJob( $job, 'growth' );
