<?php
require_once 'vendor/autoload.php';

$emailData = (object) array(
	'to_email' => 'shane@shanehill.com',
	'to_name' => 'leyla',
	'from_email' => 'test@shanehill.com',
	'from_name' => 'Foogery',
	'subject' => 'email test',
	'html' => 'test',
);

/*
$c = (object) array(
    'host' => 'civismtp.uas.coop',
    'port' => 20095,
    'username' => 'civismtp',
    'password' => 'p0nd$cum'
);
*/

$e = new BIM_Email_Swift();
$e->sendEmail( $emailData );
