<?php 
require_once 'vendor/autoload.php';

//SandaWarnerzf7409@hotmail.com,qipoqyjky
//$filename = '/home/shane/dev/hotornot/php/api-shane/test/personas_tumblr.txt';
//BIM_Growth_Tumblr_Routines::loadPersonas( $filename );

//$filename = '/home/shane/dev/hotornot-dev/php/api-shane/test/personas_tumblr.txt';
//BIM_Growth_Tumblr_Routines::checkPersonas( $filename );

$filename = '/home/shane/dev/hotornot/php/api-shane/test/personas.txt';
//BIM_Growth_Instagram_Routines::loadPersonas($filename);

//BIM_Growth_Webstagram_Routines::checkPersonas( $filename );

BIM_Growth_Webstagram_Routines::checkPersonasInFile( $filename );

//$file = '/home/shane/dev/hotornot/php/api-shane/test/webstagram_personas.txt';
//BIM_Growth_Webstagram_Routines::enablePersonas($file);

//$filename = '/home/shane/dev/hotornot/php/api-shane/test/askfm_personas.txt';
//BIM_Growth_Askfm_Routines::loadPersonas($filename);
