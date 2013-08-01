<?php
require_once 'vendor/autoload.php';

$job = array(
	'class' => 'BIM_Jobs_Votes',
	'method' => 'staticChallengesByDate',
	'data' => array(),
);

$q = new BIM_JobQueue_Gearman();
$q->doBgJob( $job, 'static_pages' );