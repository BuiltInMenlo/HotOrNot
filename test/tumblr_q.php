<?php
require_once 'vendor/autoload.php';

// b93effd2-8f09-11e1-9324-003048bc	H:sh3.civismtp.org:6251332	2013-06-06 11:00:00	Agg_Source_Instagram	agg	getEventPics	0	*/30 * * * *
$job = (object) array(
	'class' => 'BIM_Jobs_Growth',
	'method' => 'doRoutines',
    'params' => '{"personaName":"p.ocamb@yahoo.com", "routine":"loginAndBrowseSelfies","class":"BIM_Growth_Tumblr_Routines"}'
);
// centrichleialoha@yahoo.com,aqCwj9xass,rqmabeevl.tumblr.com

$q = new BIM_Jobs_Growth();
$q->doRoutines( $job );

//$q = new BIM_JobQueue_Gearman();
//$q->doBgJob( $job, 'tumblr_invite' );
