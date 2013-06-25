<?php

class BIM_DAO_Mysql_Config extends BIM_DAO_Mysql{
	
	public function getBootConf( $type = 'live' ){
		$sql = "select * from `hotornot-dev`.boot_conf where type = ?";
		$params = array($type);
		return $this->prepareAndExecute($sql,$params)->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
	}
	
	public function saveBootConf( $data, $type ){
		$sql = "
			insert into `hotornot-dev`.boot_conf
			(data, type) values (?,?)
			on duplicate key update data = ?
		";
		$params = array( $data, $type, $data );
		$this->prepareAndExecute( $sql, $params );
	}
}
