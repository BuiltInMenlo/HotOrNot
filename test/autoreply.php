<?php
require_once 'vendor/autoload.php';

// b93effd2-8f09-11e1-9324-003048bc	H:sh3.civismtp.org:6251332	2013-06-06 11:00:00	Agg_Source_Instagram	agg	getEventPics	0	*/30 * * * *
$params = json_encode( (object) array(
    'volleyObject' => (object) array('id' => 6820),
    'targetUser' => (object) array('id' => 881),
    'creator' => (object) array('id' => 882),
) );

$job = (object) array(
	'class' => 'BIM_Jobs_Challenges',
	'method' => 'acceptChallengeAsDefaultUser',
    'params' => $params
);

$q = new BIM_Jobs_Challenges();
$q->acceptChallengeAsDefaultUser( $job );

//$q = new BIM_JobQueue_Gearman();
//$q->doBgJob( $job, 'update_user_stats' );
