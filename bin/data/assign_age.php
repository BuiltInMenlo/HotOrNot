<?php 

require_once 'vendor/autoload.php';

$dao = new BIM_DAO_Mysql( BIM_Config::db());

$sql = "select id from `hotornot-dev`.tblUsers";
$stmt = $dao->prepareAndExecute( $sql );
$ids = $stmt->fetchAll( PDO::FETCH_COLUMN, 0);
foreach( $ids as $id ){
    $sql = "update `hotornot-dev`.tblUsers 
    			set age = UNIX_TIMESTAMP(DATE_SUB(now(),INTERVAL (FLOOR(13 + (RAND() * 4))) YEAR)) 
    		where id = ?
    		";
    $params = array( $id );
    $stmt = $dao->prepareAndExecute( $sql, $params );
    echo "updated $id\n";
}
