<?php
require_once 'vendor/autoload.php';

//$dao = new BIM_DAO_Mysql( BIM_Config_Dynamic::db() );

//$sql = "select * from `hotornot-dev`.tblChallenges where id = 881; select foo; -- where id ";

//$stmt = $dao->prepareAndExecute($sql);
//print_r( $stmt->fetchAll() );

$sql = "
	(select 'username' as property, username as value from `hotornot-dev`.tblUsers where username = ? limit 1)
	union all
	(select 'email' as property, email as value from `hotornot-dev`.tblUsers where email = ? limit 1)
";
$params = array( 'shane4s', 'shane@fgf.fgg' );

$dao = new BIM_DAO_Mysql( BIM_Config::db() );
$stmt = $dao->prepareAndExecute( $sql, $params );
$data = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );

print_r( array( $sql, $params, $data ) );

$result = (object) array();
foreach( $data as $row ){
    $prop = $row->property;
    $result->$prop = $row->value;
}
