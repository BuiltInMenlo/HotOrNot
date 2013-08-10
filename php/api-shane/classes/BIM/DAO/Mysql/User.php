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
    
    public function updateLastLogin( $userId ){
		$query = 'UPDATE `hotornot-dev`.tblUsers SET last_login = CURRENT_TIMESTAMP WHERE id = ?';
		$params = array( $userId );
        $stmt = $this->prepareAndExecute( $query, $params );
    }
    
    public function updateUsernameAvatar( $userId, $username, $imgUrl ){
        $query = '
        	UPDATE `hotornot-dev`.tblUsers 
        	SET username = ?, 
        		img_url = ?, 
        		last_login = CURRENT_TIMESTAMP 
        	WHERE id = ?';
        $params = array( $username, $imgUrl, $userId );
        $stmt = $this->prepareAndExecute( $query );
    }
    
    public function updateUsername( $userId, $username ){
        $query = '
        	UPDATE `hotornot-dev`.tblUsers 
        	SET username = ?
        	WHERE id = ?';
        $params = array( $username, $userId );
        $stmt = $this->prepareAndExecute( $query );
    }
    
    public function updatePaid( $userId, $isPaid ){
        $query = '
        	UPDATE `hotornot-dev`.tblUsers 
        	SET paid = ?
        	WHERE id = ?';
        $params = array( $isPaid, $userId );
        $stmt = $this->prepareAndExecute( $query );
    }
    
    public function updateNotifications( $userId, $isNotifications ){
        $query = '
        	UPDATE `hotornot-dev`.tblUsers 
        	SET notifications = ?
        	WHERE id = ?';
        $params = array( $isNotifications, $userId );
        $stmt = $this->prepareAndExecute( $query );
    }
    
    public function updateFBUsername( $userId, $fbId, $username, $gender ){
		$query = "
			UPDATE `hotornot-dev`.tblUsers 
			SET username = ?,
				fb_id = ?,
				gender = ? 
			 WHERE id = ?
		";
        $params = array( $username, $fbId, $gender, $userId );
        $stmt = $this->prepareAndExecute( $query );
    }
    
    public function updateFB( $userId, $fbId, $gender ){
		$query = "
			UPDATE `hotornot-dev`.tblUsers 
			SET fb_id = ?,
				gender = ? 
			 WHERE id = ?
		";
        $params = array( $fbId, $gender, $userId );
        $stmt = $this->prepareAndExecute( $query );
    }
    
    public function poke( $pokerId, $pokeeId ){
		$query = 'INSERT IGNORE INTO tblUserPokes (user_id, poker_id, added) VALUES ( ?, ?, NOW() )';
		$params = array( $pokeeId, $pokerId );
        $stmt = $this->prepareAndExecute($query, $params);
        return $this->lastInsertId;
    }
    
    public function create( $username, $deviceToken ){
		// add new user			
		$query = "
			INSERT INTO `hotornot-dev`.tblUsers 
			( username, device_token, fb_id, gender, bio, website, paid, points, notifications, last_login, added) 
			VALUES ( ?, ?, '', 'N', '', '', 'N', '0', 'Y', CURRENT_TIMESTAMP, NOW() )
		";
		
        $params = array( $username, $deviceToken );
        $stmt = $this->prepareAndExecute($query, $params);
        
		return $this->lastInsertId;
    }
    
    public function getFbInviteId( $fbId ){
        $id = null;
		$query = "SELECT `id` FROM `tblInvitedUsers` WHERE `fb_id` = ?";
		$params = array( $fbId );
        $stmt = $this->prepareAndExecute($sql, $params);
        $data = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
        if( $data ){
            $id = $data[0]->id;
        }
        return $id;
    }
    
    public function getFbInvitesToVolley( $userId ){
		// get any pending challenges for this invited user
		$query = "
			SELECT tc.`id` 
			FROM tblChallenges as tc
				JOIN tblChallengeParticipants as tcp
				ON tc.id = tcp.challenge_id
			WHERE tc.`status_id` = 7 
				AND tcp.user_id = ?;
		";
		$params = array( $userId );
        $stmt = $this->prepareAndExecute($query, $params);
        $ids = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
        foreach( $ids as &$id ){
            $id = $id->id;
        }
        return $ids;		
    }
}
