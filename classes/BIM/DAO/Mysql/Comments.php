<?php

class BIM_DAO_Mysql_Comments extends BIM_DAO_Mysql{
    
    public function add( $volleyId, $userId, $text ){
		// add vote record
		$sql = '
			INSERT INTO `hotornot-dev`.tblComments 
					(challenge_id, user_id, text, status_id, added) 
			VALUES  ( ?, ?, ?, 1, NOW())';
        $params = array( $volleyId, $userId, $text );
        $this->prepareAndExecute( $sql, $params );
        $commentId = $this->lastInsertId;
        return $commentId;
    }
    
    public function getIdsForVolley( $volleyId ){
        $sql = "SELECT distinct(id) as id from `hotornot-dev`.tblComments where challenge_id = ? and status_id not in (3)";
        $params = array( $volleyId );
        $stmt = $this->prepareAndExecute( $sql, $params );
        $ids = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
        foreach( $ids as &$id ){
            $id = $id->id;
        }
        return $ids;
    }
    
    public function get( $id ){
        $sql = '
        	SELECT *
        	FROM `hotornot-dev`.tblComments AS tc 
        	WHERE tc.id = ?
    	';
        $params = array( $id );
        $stmt = $this->prepareAndExecute( $sql, $params );
        $data = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
        $comment = $data ? $data[0] : null;
        return $comment;
    }
    
    public function delete( $commentId ){
		$query = 'UPDATE `hotornot-dev`.`tblComments` SET `status_id` = 3 WHERE `id` = ?';
        $params = array( $commentId );
        $this->prepareAndExecute($sql, $params);
    }
    
    public function flag( $commentId ){
		$query = 'UPDATE `hotornot-dev`.`tblComments` SET `status_id` = 2 WHERE `id` = ?';
        $params = array( $commentId );
        $this->prepareAndExecute($query, $params);
    }
    
}
