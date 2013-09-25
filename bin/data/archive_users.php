<?php 
require_once 'vendor/autoload.php';

$dao = new BIM_DAO_Mysql( BIM_Config::db() );
$sql = "select id from `hotornot-dev`.tblUsers where username like '%lovepeaceswaghot1%'";
$stmt = $dao->prepareAndExecute( $sql );
$ids = $stmt->fetchAll( PDO::FETCH_COLUMN, 0 );
BIM_Model_User::archiveUser($ids);
