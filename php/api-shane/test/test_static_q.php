<?php
set_include_path(get_include_path().':/var/www/discover.getassembly.com/hotornot/api-shane/classes');

$job = array(
	'class' => 'BIM_Jobs_Votes',
	'method' => 'staticChallengesByDate',
	'data' => array(),
);

require_once 'BIM/JobQueue/Gearman.php';
$q = new BIM_JobQueue_Gearman();
$q->doBgJob( $job, 'static_pages' );