<?php
bootstrap();
$r = new BIM_Controller;
$r->handleReq();

function bootstrap(){
    $releaseId = '';
    $matches = array();
    preg_match( '@^/api/(.+?)/@', $_SERVER['SCRIPT_URL'], $matches );
    if( !empty($matches[1]) ){
        $releaseId = $matches[1];
        $incPath = ".:/usr/share/php:/usr/share/pear:/home/volley/deployed/$releaseId/classes:/home/volley/deployed/$releaseId/lib:/home/volley/deployed/$releaseId/lib/smtp_mailer_swift/lib/classes";
        set_include_path($incPath);
        define('RELEASE_ID_KEY_PREFIX',$releaseId);
    }
    require_once 'vendor/autoload.php';
}
