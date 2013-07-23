<?php

class BIM_DAO_Mysql_Volleys extends BIM_DAO_Mysql{
	public function getUnjoined( ){
	    $sql = "
	    	select * 
	    	from `hotornot-dev`.tblChallenges 
	    	where started < DATE( FROM_UNIXTIME( ? ) )
	    		and expires = -1
	    		and status_id in (1,2)
	    ";
	    $time = time() - (86400 * 7);
	    $params = array( $time );
		$stmt = $this->prepareAndExecute( $sql, $params );
		return $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
	}
	
	public function reVolley( $volley, $user ){
	    $sql = "
	    	update `hotornot-dev`.tblChallenges
	    	set status_id = 2, 
	    		challenger_id = ?,
	    		started = now(),
				updated = now()
	    	where id = ?
	    ";
	    $time = time() - (86400 * 7);
	    $params = array( $user->id, $volley->id );
		$this->prepareAndExecute( $sql, $params );
	}
}
