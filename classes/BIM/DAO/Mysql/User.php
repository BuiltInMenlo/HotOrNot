<?php

class BIM_DAO_Mysql_User extends BIM_DAO_Mysql{
    
    public function getRandomIds( $total = 1, $exclude = array() ){
        $sql = "SELECT id FROM `hotornot-dev`.`tblUsers` ";
        if( $exclude ){
            $placeHolders = join('',array_fill(0, count( $exclude ), '?') );
            $sql = "$sql where id not in ($placeHolders)";
        }
        $total = (int) $total;
        $sql = "$sql ORDER BY RAND() limit $total";
        
		$stmt = $this->prepareAndExecute($sql,$exclude);
        return $stmt->fetchAll( PDO::FETCH_COLUMN, 0 );
    }
    
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
    
    /**
     * 
     * @param unknown_type $volleyId - the verify volley id
     * @param unknown_type $targetId - the creator iof the volley
     * @param unknown_type $userId - a participant in the vollry
     * @param unknown_type $count - the number of flag ticks to give to the target
     */
    public function flag( $volleyId, $targetId, $userId, $count ){
        // give the target the appropriate nu,ber of flags
        $count = (int) $count;
		$sql = "update `hotornot-dev`.tblUsers set abuse_ct = abuse_ct + ? where id = ?";
		$params = array( $count, $targetId );
		$stmt = $this->prepareAndExecute($sql,$params);
		
        // update the users participant record that they have voted
		$sql = "
			INSERT IGNORE INTO `hotornot-dev`.tblFlaggedUserApprovals
			 (flag, user_id, challenge_id, added)
			 VALUES (?,?,?,?)
		";
		$params = array( $count, $userId, $volleyId, time() );
		$stmt = $this->prepareAndExecute($sql,$params);
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
        $date = new DateTime();
        $date = $date->format( 'Y-m-d H:i:s' );
		$query = 'UPDATE `hotornot-dev`.tblUsers SET last_login = ? WHERE id = ?';
		$params = array( $date, $userId );
        $stmt = $this->prepareAndExecute( $query, $params );
        return $date;
    }
    
    public function updateUsernameAvatar( $userId, $username, $imgUrl, $birthdate ){
        $sql = '';
        $params = array( $username, $imgUrl, $userId );
        if( $birthdate ){
            $birthdate = new DateTime( $birthdate );
            $birthdate = $birthdate->format('U');
            $sql = ' age = ?,';
            $params = array( $username, $imgUrl, $birthdate, $userId );
        }
        
        $query = "
        	UPDATE `hotornot-dev`.tblUsers 
        	SET username = ?, 
        		img_url = ?, 
        		$sql
        		last_login = CURRENT_TIMESTAMP
        	WHERE id = ?
        ";
        $stmt = $this->prepareAndExecute( $query, $params );
    }
    
    public function updateUsername( $userId, $username ){
        $query = '
        	UPDATE `hotornot-dev`.tblUsers 
        	SET username = ?
        	WHERE id = ?';
        $params = array( $username, $userId );
        $stmt = $this->prepareAndExecute( $query, $params );
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
		$query = 'INSERT IGNORE INTO `hotornot-dev`.tblUserPokes (user_id, poker_id, added) VALUES ( ?, ?, NOW() )';
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
		$query = "SELECT `id` FROM `hotornot-dev`.`tblInvitedUsers` WHERE `fb_id` = ?";
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
			from `hotornot-dev`.tblChallenges as tc
				JOIN `hotornot-dev`.tblChallengeParticipants as tcp
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
    
    public function getUsersWithSimilarName( $username ){
		$query = 'SELECT id from `hotornot-dev`.tblUsers WHERE username LIKE ?';
		$params = array( "%$username%" );
        $stmt = $this->prepareAndExecute($query, $params);
        $ids = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
        foreach( $ids as &$id ){
            $id = $id->id;
        }
        return $ids;		
    }
    
    public function getOpponentsWithSnaps( $userId ){
        $sql = "
        	select tc.creator_id, tcp.user_id, max(tcp.img) as img
        	from `hotornot-dev`.tblChallengeParticipants as tcp
        		join `hotornot-dev`.tblChallenges as tc
        		on tc.id = tcp.challenge_id
        	where (tc.creator_id = ? OR tcp.user_id = ?)
        		AND tcp.img != ''
        		AND tcp.img is not null
        	group by creator_id, user_id, img
        ";
		$params = array( $userId, $userId );
        $stmt = $this->prepareAndExecute($sql, $params);
        return $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
    }
    
	public function setAgeRange( $userId, $ageRange ){
	    $sql = 'update `hotornot-dev`.tblUsers set age = ? where id = ? ';
	    $params = array( $ageRange, $userId );
	    $this->prepareAndExecute( $sql, $params );
	}
}
