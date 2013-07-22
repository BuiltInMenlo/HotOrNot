<?php
require_once 'vendor/autoload.php';

// b93effd2-8f09-11e1-9324-003048bc	H:sh3.civismtp.org:6251332	2013-06-06 11:00:00	Agg_Source_Instagram	agg	getEventPics	0	*/30 * * * *
$job = (object) array(
	'class' => 'BIM_Jobs_Growth',
	'method' => 'doRoutines',
    'params' => '{"personaName":"meebzxp@hotmail.com", "routine":"askQuestions","class":"BIM_Growth_Askfm_Routines"}'
);

//$url = 'https://www.google.com/';
//$url = 'https://64.27.28.124/werty.php';
//$url = 'https://54.243.163.24/werty.php';
//$q = new BIM_Growth();
//echo $q->testProxies($url);

$q = new BIM_Growth_Askfm_Routines( 'meebzxp@hotmail.com' );
$q->askQuestion('exty86');

//$q = new BIM_Jobs_Growth();
//$q->doRoutines( $job );

//$q = new BIM_JobQueue_Gearman();
//$q->doBgJob( $job, 'update_user_stats' );
