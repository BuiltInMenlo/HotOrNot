<?php

class BIM_DAO_Mysql_User extends BIM_DAO_Mysql{
	public function getData( $id ){
		$sql = "select * from `hotornot-dev`.tblUsers where id = ?";
		$params = array( $id );
		$stmt = $this->prepareAndExecute( $sql, $params );
		$data = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
		if( ! isset($data[0]) ){
		    $data = (object) array();
		} else {
		    $data = $data[0];
		}
		return $data;
	}
}
