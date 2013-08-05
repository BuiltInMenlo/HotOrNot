<?php

set_include_path(".:/usr/share/php:/usr/share/pear:/home/shane/dev/122/php/api-shane/classes:/home/shane/dev/122/php/api-shane/lib:/home/shane/dev/122/php/api-shane/lib/smtp_mailer_swift/lib/classes");

require_once 'vendor/autoload.php';

$conf = (object) array(
	'db' => BIM_Config::db(),
	'queue' => BIM_Config::gearman(),
);

//require_once 'BIM/Jobs/Gearman.php';
$jobs = new BIM_Jobs_Gearman( $conf );
$jobs->queueJobs();

