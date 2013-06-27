<?php

class BIM_DAO_Mysql_User extends BIM_DAO_Mysql{
	public function getData( $id ){
		$sql = "select * from `hotornot-dev`.tblUsers where id = ?";
		$params = array( $id );
		$stmt = $this->prepareAndExecute( $sql, $params );
		$data = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
		return $data[0];
	}
	
	public function getUserDataByCode( $code ){
		$sql = "select * from `hotornot-dev`.tblUsers where code = ?";
		$params = array( $code );
		$stmt = $this->prepareAndExecute( $sql, $params );
		$data = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
		return $data[0];
	}
}
