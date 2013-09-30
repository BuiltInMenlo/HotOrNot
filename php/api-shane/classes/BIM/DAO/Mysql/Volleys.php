<?php

class BIM_DAO_Mysql_Volleys extends BIM_DAO_Mysql{
	public function getUnjoined( ){
	    $sql = "
	    	select * 
	    	from `hotornot-dev`.tblChallenges 
	    	where started > '2013-07-16'
	    		and expires = -1
	    		and status_id in (1,2)
	    		and is_private = 'N'
	    	order by added desc
	    ";
	    $time = time() - (86400 * 2);
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
	    $params = array( $user->id, $volley->id );
		$this->prepareAndExecute( $sql, $params );
	}
}
