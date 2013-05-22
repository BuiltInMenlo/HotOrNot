<?php
set_include_path(get_include_path().':/var/www/discover.getassembly.com/hotornot/api-shane/classes:/var/www/discover.getassembly.com/hotornot/api-shane/config');

$conf = (object) array(
	'db' => BIM_Config::db(),
	'queue' => BIM_Config::gearman(),
);

require_once 'BIM/Jobs/Gearman.php';
$jobs = new BIM_Jobs_Gearman( $conf );
$jobs->queueJobs();

