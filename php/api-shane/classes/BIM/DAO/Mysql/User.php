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
	
	public function getRandomUserId( $exclude = array() ){
	    if( !is_array( $exclude ) ){
	        $exclude = array( $exclude );
	    }
	    $id = null;
	    $sql = "select id from `hotornot-dev`.tblUsers";
		$stmt = $this->prepareAndExecute( $sql );
		$data = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
		if( $data ){
		    $len = count( $data );
		    for($n = 0; $n < 10; $n++ ){
    		    $idx = mt_rand(1, $len) - 1;
    		    $id = $data[ $idx ]->id;
		        // make sure id does not match the exclude ids
    		    if( !in_array( $id, $exclude ) ){
    		        break;
    		    } else {
    		        $id = null;
    		    }
		    }
		}
		return $id;
	}
}
