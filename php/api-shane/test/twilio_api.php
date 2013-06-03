<?php
require_once 'vendor/autoload.php';

$persona = (object) array(
    'sms' => (object) array(
        'userId' => 45,
        'numbers' => '14152549391'
    ),
);

$persona = new BIM_Growth_Persona( $persona );
$routines = new BIM_Growth_SMS_Routines( $persona );

try{
    print_r( $routines->smsInvites() );
} catch( Exception $e ){
    print_r( $e );
}
