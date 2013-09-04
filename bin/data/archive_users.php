<?php 
require_once 'vendor/autoload.php';

$users = array( 9721,9722 );
BIM_Model_User::archive( $users );
