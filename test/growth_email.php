<?php
require_once 'vendor/autoload.php';

$persona = (object) array(
    'email' => (object) array(
        'userId' => 45,
        'addresses' => 'shane@shanehill.com'
    ),
);

$persona = new BIM_Growth_Persona( $persona );
$routines = new BIM_Growth_Email_Routines( $persona );

try{
    print_r( $routines->emailInvites() );
} catch( Exception $e ){
    print_r( $e );
}

