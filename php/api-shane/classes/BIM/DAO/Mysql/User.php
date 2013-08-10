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
    
    public function getTotalVotes( $userId ){
        $count = 0;
		$sql = "SELECT count(*) as count FROM `hotornot-dev`.`tblChallengeVotes` WHERE `challenger_id` = ?";
		$params = array( $userId );
		$stmt = $this->prepareAndExecute($sql,$params);
        $data = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
        if( $data ){
            $count = $data[0]->count;
        }
        return $count;
    }
    
    public function getTotalPokes( $userId ){
        $count = 0;
		$sql = "SELECT count(*) as count FROM `hotornot-dev`.`tblUserPokes` WHERE `user_id` = ?";
		$params = array( $userId );
		$stmt = $this->prepareAndExecute($sql,$params);
        $data = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
        if( $data ){
            $count = $data[0]->count;
        }
        return $count;
    }
    
    public function getTotalChallenges( $userId ){
        $count = 0;
        $sql = "
			select count(*) as count
			from `hotornot-dev`.tblChallenges as tc
				join `hotornot-dev`.tblChallengeParticipants as tcp
				on tc.id = tcp.challenge_id
			where tc.creator_id = ? OR tcp.user_id = ?
        ";
        $params = array( $userId, $userId );
		$stmt = $this->prepareAndExecute($sql,$params);
        $data = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
        if( $data ){
            $count = $data[0]->count;
        }
        return $count;
    }
    
    public function getIdByUsername( $username ){
        $id = null;
        $sql = "select id from `hotornot-dev`.tblUsers where username = ?";
        $params = array( $username );
        $stmt = $this->prepareAndExecute( $sql, $params );
        $data = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
        if( $data ){
            $id = $data[0]->id;
        }
        return $id;
    }
    
    public function getDataByUsername( $username ){
        $sql = "select * from `hotornot-dev`.tblUsers where username = ?";
        $params = array( $username );
        $stmt = $this->prepareAndExecute( $sql, $params );
        $data = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
        if( ! isset($data[0]) ){
            $data = new stdClass();
        } else {
            $data = $data[0];
        }
        return $data;
    }
    
    public function getIdByToken( $token ){
        $id = null;
        $sql = "select id from `hotornot-dev`.tblUsers where device_token = ?";
        $params = array( $token );
        $stmt = $this->prepareAndExecute( $sql, $params );
        $data = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
        if( $data ){
            $id = $data[0]->id;
        }
        return $id;
    }
    
    public function getDataByToken( $token ){
        $sql = "select * from `hotornot-dev`.tblUsers where device_token = ?";
        $params = array( $token );
        $stmt = $this->prepareAndExecute( $sql, $params );
        $data = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
        if( ! isset($data[0]) ){
            $data = new stdClass();
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
        if( $exclude ){
            $placeHolders = join('',array_fill(0, count( $exclude ), '?') );
            $sql = "$sql where id not in ($placeHolders)";
        }
        $stmt = $this->prepareAndExecute( $sql, $exclude );
        $data = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
        if( $data ){
            $len = count( $data );
            $idx = mt_rand(1, $len) - 1;
            $id = $data[ $idx ]->id;
        }
        return $id;
    }
}
