<?php

class BIM_DAO_Mysql_Growth_Webstagram extends BIM_DAO_Mysql_Growth{
	
	public function getLastContact( $userId ){
		$sql = "
			select last_contact 
			from growth.webstagram_user_contact
			where user_id = ?
		";
		$params = array($userId);
		$stmt = $this->prepareAndExecute($sql, $params);
		$data = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
		if( $data ){
		    $data = $data[0]->last_contact;
		} else {
		    $data = 0;
		}
		return $data;
	}
	
	public function updateLastContact( $userId, $time ){
		$sql = "
			insert into growth.webstagram_user_contact
			(user_id, last_contact) values (?,?)
			on duplicate key update last_contact = ?
		";
		$params = array( $userId, $time, $time );
		$this->prepareAndExecute($sql, $params);
	}
	
    public function logSuccess( $id, $comment, $name ){
		$sql = "
			insert into growth.webstagram_contact_log
			( `time`, `url`, `type`, `comment`, `network`, `name` ) values (?,?,?,?,?,?)
		";
		
		$params = array( time(), $id, 'photo', $comment, 'webstagram', $name );
		$this->prepareAndExecute( $sql, $params );
    }
}
