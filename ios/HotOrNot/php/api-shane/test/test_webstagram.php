<?php
require_once 'vendor/autoload.php';

try{
    $routines = new BIM_Growth_Webstagram_Routines( 'Ariannaxoxoluver' );
    $routines->disablePersona( "test" );
} catch( Exception $e ){
    print_r( $e );
}
