<?php
require_once 'vendor/autoload.php';

$dao = new BIM_DAO_Mysql( BIM_Config_Dynamic::db() );

$sql = "select * from `hotornot-dev`.tblChallenges where id = 881; select foo; -- where id ";

$stmt = $dao->prepareAndExecute($sql);
print_r( $stmt->fetchAll() );
