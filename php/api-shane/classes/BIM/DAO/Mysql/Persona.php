<?php

class BIM_DAO_Mysql_Persona extends BIM_DAO_Mysql{
	public function getData( $name ){
		$sql = "
			select * 
			from growth.persona
			where name = ?
		";
		$params = array( $name );
		$stmt = $this->prepareAndExecute( $sql, $params );
		
		return $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
	}
	
	public function trackInboundClick( $name, $networkId, $referer = '' ){
	    $sql = "insert into growth.inbound_persona_clicks (name, networkId, referer) values (?, ?, ?)";
		$params = array( $name, $networkId, $referer );
		$stmt = $this->prepareAndExecute( $sql, $params );
	}
}
