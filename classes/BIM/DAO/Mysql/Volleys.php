<?php

class BIM_DAO_Mysql_Volleys extends BIM_DAO_Mysql{
    
    public function hasApproved( $volleyId, $userId ){
        $sql = "select flag from `hotornot-dev`.tblFlaggedUserApprovals where user_id = ? and challenge_id = ?";
        $params = array( $userId, $volleyId );
        $stmt = $this->prepareAndExecute( $sql, $params );
        $data = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
        return $data ? true : false;
    }
    
    public function getVerifyVolleyIdForUser( $userId ){
        $sql = "
            select id
            from `hotornot-dev`.tblChallenges
            where is_verify = 1
            	and creator_id = ?
        ";
        $params = array( $userId );
        $stmt = $this->prepareAndExecute( $sql, $params );
        return $stmt->fetchColumn();
    }
    
    public function getUnjoined( ){
        $sql = "
            select * 
            from `hotornot-dev`.tblChallenges 
            where started < DATE( FROM_UNIXTIME( ? ) )
                and expires = -1
                and is_verify != 1
                and status_id in (1,2)
            order by added desc
        ";
        $time = time() - (86400 * 14);
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
    
    public function add( $userId, $targetIds, $hashTagId, $imgUrl, $isPrivate, $expires, $isVerify = false ){
        $isVerify = (int) $isVerify;
        // add the new challenge
        $sql = '
            INSERT INTO `hotornot-dev`.tblChallenges 
                ( status_id, subject_id, creator_id, creator_img, hasPreviewed, votes, updated, started, added, is_private, expires, is_verify )
            VALUES 
                ("2", ?, ?, ?, "N", "0", NOW(), NOW(), NOW(), ?, ?, ? )
        ';
        $params = array($hashTagId, $userId, $imgUrl, $isPrivate, $expires, $isVerify);
        $this->prepareAndExecute( $sql, $params );
        $volleyId = $this->lastInsertId;
        
        if( $volleyId ){
            // now we create the insert statement for all of the users in this volley
            $params = array();
            $insertSql = array();
            foreach( $targetIds as $targetId ){
                $insertSql[] = '(?,?,?)';
                $params[] = $volleyId;
                $params[] = $targetId;
                $params[] = time();
            }
            $insertSql = join( ',' , $insertSql );
            
            $sql = "
                INSERT IGNORE INTO `hotornot-dev`.tblChallengeParticipants
                    ( challenge_id, user_id, joined )
                VALUES 
                	$insertSql;
            ";
            $this->prepareAndExecute( $sql, $params );
        }
        
        return $volleyId;
    }
    
    public function addHashTag( $subject, $userId ){
        $sql = 'INSERT INTO `hotornot-dev`.tblChallengeSubjects (title, creator_id, added ) VALUES ( ?, ?, now() )';
        $params = array( $subject, $userId );
        $this->prepareAndExecute( $sql, $params );
        return $this->lastInsertId;
    }
    
    public function getHashTagId( $hashTag ){
        $id = null;
        $sql = 'SELECT id FROM `hotornot-dev`.tblChallengeSubjects WHERE title = ?';
        $params = array( $hashTag );
        $this->prepareAndExecute( $sql, $params );
        $data = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
        if( $data ){
            $id = $data[0]->id;
        }
        return $id;
    }
    
    public function get( $id ){
        $volley = null;
        
        $sql = '
        	SELECT 
        		tc.*, 
        		tcp.user_id AS challenger_id, 
        		tcp.img AS challenger_img,
        		tcp.joined as joined
        	FROM `hotornot-dev`.tblChallenges AS tc 
        		JOIN `hotornot-dev`.tblChallengeParticipants AS tcp
        		ON tc.id = tcp.challenge_id 
        	WHERE tc.id = ?
        	ORDER BY challenge_id';
        
        $params = array( $id );
        
        
        $stmt = $this->prepareAndExecute( $sql, $params );
        $data = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
        if( $data ){
            $volley = array_shift( $data );
            $volley->challengers = array( ( object ) array( 'challenger_id' => $volley->challenger_id, 'challenger_img' => $volley->challenger_img,  'joined' => $volley->joined ) );
            unset( $volley->challenger_id );
            unset( $volley->challenger_img );
            unset( $volley->joined );
            foreach( $data as $row ){
                $volley->challengers[] = ( object ) array( 'challenger_id' => $row->challenger_id, 'challenger_img' => $row->challenger_img, 'joined' => $row->joined );
            }
        }
        return $volley;
    }
    
    /**
     * Helper function to get the subject for a challenge
     * @param $subject_id The ID of the subject (integer)
     * @return Name of the subject (string)
    **/
    public function getSubject($subjectId) {
        $subject = null;
        $sql = 'SELECT title FROM `hotornot-dev`.tblChallengeSubjects WHERE id = ?';
        $params = array( $subjectId );
        $stmt = $this->prepareAndExecute($sql, $params);
        $data = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
        if( $data ){
            $subject = $data[0]->title;
        }
        return $subject;
    }
    
    public function getHashTag($tagId) {
        return $this->getSubject($tagId);
    }
    
    /**
     * Helper function to get the total # of comments for a challenge
     * @param $challenge_id The ID of the challenge (integer)
     * @return Total # of comments (integer)
    **/
    public function commentCount( $volleyId ){
        $count = null;
        $sql = 'SELECT count(*) as count FROM `hotornot-dev`.tblComments WHERE challenge_id = ?';
        $params = array( $volleyId );
        $stmt = $this->prepareAndExecute( $sql, $params );
        $data = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
        if( $data ){
            $count = $data[0]->count;
        }
        return (int) $count;
    }
    
    /**
     * Helper function to user info for a challenge
     * @param $user_id The creator or challenger ID (integer)
     * @param $challenge_id The challenge's ID to get the user for (integer)
     * @return An associative object for a user (array)
    **/
    public function getLikes( $volleyId ) {
        $sql = 'select challenger_id as uid, count(*) as count from `hotornot-dev`.tblChallengeVotes where challenge_id = ? group by uid';
        $params = array( $volleyId );
        $stmt = $this->prepareAndExecute( $sql, $params );
        return $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
    }
    
    public function join( $volleyId, $userId, $imgUrl ){
        $sql = 'INSERT IGNORE INTO `hotornot-dev`.tblChallengeParticipants (challenge_id, user_id, img, joined ) VALUES (?, ?, ?, ?)';
        $params = array( $volleyId, $userId, $imgUrl, time() );
        $this->prepareAndExecute($sql, $params);
        
        $sql = 'UPDATE `hotornot-dev`.tblChallenges SET status_id = 4, updated = NOW(), started = NOW() WHERE id = ? ';
        $params = array( $volleyId );
        $this->prepareAndExecute($sql, $params);
    }
    
    public function accept( $volleyId, $userId, $imgUrl ){
        $sql = 'UPDATE `hotornot-dev`.tblChallengeParticipants SET img = ?, joined = ? where challenge_id = ? and user_id = ? ';
        $params = array( $imgUrl, time(), $volleyId, $userId );
        $this->prepareAndExecute($sql, $params);
        
        $sql = 'UPDATE `hotornot-dev`.tblChallenges SET status_id = 4, updated = NOW(), started = NOW() WHERE id = ? ';
        $params = array( $volleyId );
        $this->prepareAndExecute($sql, $params);
    }
    
    public function upVote( $volleyId, $userId, $targetId ){
		$query = "
            INSERT IGNORE INTO `hotornot-dev`.`tblChallengeVotes` 
            (`challenge_id`, `user_id`, `challenger_id`, `added`) 
            VALUES ( ?, ?, ?, NOW() )
		";
		$params = array( $volleyId, $userId, $targetId );
        $stmt = $this->prepareAndExecute($query, $params);
		
        if( $this->lastInsertId ){
            $sql = 'UPDATE `hotornot-dev`.tblChallenges SET votes = votes + 1 where id = ?';
            $params = array( $volleyId );
            $stmt = $this->prepareAndExecute($sql, $params);
        }
    }
    
    public function acceptFbInviteToVolley( $volleyId, $userId, $inviteId ){
        $query = "UPDATE tblChallengeParticipants SET user_id = ?  WHERE challenge_id = ? and user_id = ?";
        $params = array( $userId, $volleyId, $inviteId );
        $this->prepareAndExecute($sql, $params);
    }
    
    public function updateStatus( $volleyId, $status ){
        $sql = 'UPDATE `hotornot-dev`.tblChallenges SET status_id = ? WHERE id = ?';
        $params = array( $status, $volleyId );
        $this->prepareAndExecute($sql, $params);
    }
    
    public function cancel( $volleyId ){
        $sql = 'UPDATE `hotornot-dev`.tblChallenges SET status_id = 3 WHERE id = ?';
        $params = array( $volleyId );
        $this->prepareAndExecute($sql, $params);
    }
    
    public function setPreviewed( $volleyId ){
        $sql = 'UPDATE `hotornot-dev`.tblChallenges SET hasPreviewed = "Y" WHERE id = ?';
        $params = array( $volleyId );
        $this->prepareAndExecute($sql, $params);
    }
    
    public function flag( $volleyId, $userId ){
        $sql = 'UPDATE `hotornot-dev`.tblChallenges SET status_id = 6 WHERE id = ?';
        $params = array( $volleyId );
        $this->prepareAndExecute($sql, $params);
        
        $sql = 'INSERT INTO `hotornot-dev`.tblFlaggedChallenges ( challenge_id, user_id, added) VALUES ( ?, ? NOW() )';
        $params = array( $volleyId, $userId );
        $this->prepareAndExecute($sql, $params);
    }
    
    public function getRandomAvailableByHashTag( $hashTag, $userId = null ){
        $v = null;
        $params = array( $hashTag );
        if( $userId ){
            $params[] = $userId;
            $userSql = 'AND tc.creator_id != ?';
        }
        
        $sql = "
            SELECT tc.id, tc.creator_id
            FROM `hotornot-dev`.tblChallenges as tc
                JOIN `hotornot-dev`.tblChallengeSubjects as tcs
                ON tc.subject_id = tcs.id
            WHERE tc.status_id = 1  and is_verify != 1
                AND tcs.title = ? 
                $userSql
            ORDER BY RAND()
            LIMIT 1
        ";
        $stmt = $this->prepareAndExecute( $sql, $params );
        $data = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
        if( $data ){
            $v = $data[0];
        }
        
        return $v;
    }
    
    public function getAllIdsForUser( $userId ){
        $sql = '
        	SELECT tc.id 
        	FROM `hotornot-dev`.tblChallenges as tc
            	JOIN `hotornot-dev`.tblChallengeParticipants as tcp
            	ON tc.id = tcp.challenge_id
        	WHERE (tc.status_id NOT IN (2,3,6,8) )  and is_verify != 1
        		AND (tc.creator_id = ? OR tcp.user_id = ? ) 
        	ORDER BY tc.updated DESC
        ';
        $params = array( $userId, $userId );
        $stmt = $this->prepareAndExecute( $sql, $params );
        return $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
    }
    
    public function getOpponents( $userId, $private ){
        $privateSql = ' AND tc.is_private != "Y" ';
        if( $private ){
            $privateSql = ' AND tc.is_private = "Y" ';
        }
        $sql = "
        	SELECT tc.creator_id, tcp.user_id as challenger_id 
            FROM `hotornot-dev`.tblChallenges as tc
            	JOIN  `hotornot-dev`.tblChallengeParticipants as tcp
            	ON tc.id = tcp.challenge_id
            WHERE ( tc.status_id NOT IN (3,6,8) $privateSql  and is_verify != 1 ) 
              AND (tc.creator_id = ? OR tcp.user_id = ? ) 
            ORDER BY tc.updated DESC
        ";
        
        $params = array( $userId, $userId );
        $stmt = $this->prepareAndExecute( $sql, $params );
        return $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
    }
    
    public function withOpponent( $userId, $opponentId, $lastDate = "9999-99-99 99:99:99", $private ){
        $privateSql = ' AND tc.is_private != "Y" ';
        if( $private ){
            $privateSql = ' AND tc.is_private = "Y" ';
        }
        
        if( $lastDate === null ){
            $lastDate = "9999-99-99 99:99:99";
        }
        
        // get challenges where both users are included
        $sql = "
        	SELECT tc.id, tc.creator_id, tcp.user_id as challenger_id, tc.updated 
            FROM `hotornot-dev`.tblChallenges as tc
            	JOIN `hotornot-dev`.tblChallengeParticipants as tcp
            	ON tc.id = tcp.challenge_id
            WHERE ( tc.status_id NOT IN (3,6,8) $privateSql and is_verify != 1 )
                AND ( (tc.creator_id = ? OR tcp.user_id = ?) AND (tc.creator_id = ? OR tcp.user_id = ? ) ) 
                AND tc.updated < ? 
            ORDER BY tc.updated DESC
        ";
        
        $params = array( $userId, $userId, $opponentId, $opponentId, $lastDate );
        $stmt = $this->prepareAndExecute( $sql, $params );
        return $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
    }
    
    public function getIds( $userId, $private ){
        $pSql = "AND tc.is_private = 'N'";
        if( $private ){
            $pSql = "AND tc.is_private = 'Y'";
        }
        
        $sql = "
            SELECT tc.id 
            FROM `hotornot-dev`.tblChallenges as tc
            	JOIN `hotornot-dev`.tblChallengeParticipants as tcp
            	ON tc.id = tcp.challenge_id
            WHERE tc.status_id in ( 1,2,4 ) and is_verify != 1
                AND (tc.creator_id = ?  OR tcp.user_id = ? )
                $pSql
            ORDER BY tc.updated DESC
        ";
        
        $params = array( $userId, $userId );
        $stmt = $this->prepareAndExecute( $sql, $params );
        $ids = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
        
        if( $ids ){
            foreach( $ids as &$id ){
                $id = $id->id;
            }
        }
        return $ids;
    }
    /**
     * @param unknown_type $userId
     */
    public function getVerificationVolleyIds( $userId ){
        
        $sql = "
            SELECT tc.id
            FROM `hotornot-dev`.tblChallenges as tc
                JOIN `hotornot-dev`.tblChallengeParticipants as tcp
                ON tc.id = tcp.challenge_id
            	LEFT JOIN `hotornot-dev`.tblFlaggedUserApprovals as u
               	ON tcp.challenge_id = u.challenge_id  
            WHERE tc.status_id in ( 1,2,4 )    
                AND is_verify = 1  
                AND tcp.user_id = ?  
                AND u.challenge_id is null
            ORDER BY tc.updated DESC;
        ";
        
        $params = array( $userId );
        $stmt = $this->prepareAndExecute( $sql, $params );
        return $stmt->fetchAll( PDO::FETCH_COLUMN, 0 );
    }
    
    public function getVolleysWithFriends( $userId, $friendIds ){
	    
	    $fIdct = count( $friendIds );
		$fIdPlaceholders = trim( str_repeat('?,', $fIdct ), ',' );
		
        $query = "
        	SELECT tc.id
        	FROM `hotornot-dev`.`tblChallenges` as tc 
            	JOIN `hotornot-dev`.tblChallengeParticipants as tcp
            	ON tc.id = tcp.challenge_id
        	WHERE (tc.status_id IN (1,4) 
        		AND (tc.`creator_id` IN ( $fIdPlaceholders ) OR tcp.`user_id` IN ( $fIdPlaceholders ) ) )
        		OR ( tc.status_id = 2 AND tcp.user_id = ? )
        	ORDER BY tc.`updated` DESC LIMIT 50
        ";
        
		$dao = new BIM_DAO_Mysql_User( BIM_Config::db() );
        
        $params = $friendIds;
        foreach( $friendIds as $friendId ){
            $params[] = $friendId;
        }
        $params[] = $userId;

        $stmt = $dao->prepareAndExecute( $query, $params );
        $ids = $stmt->fetchAll( PDO::FETCH_OBJ );
        foreach( $ids as &$id ){
            $id = $id->id;
        }
        return array_unique($ids);
    }
    
    /**
     * userId is the friend with which we want the volleys
     * Enter description here ...
     * @param unknown_type $userId
     */
    public function getVolleysWithAFriend( $userId, $friendId, $private  ){
	    $privateSql = ' AND `is_private` != "Y" ';
	    if( $private ){
	        $privateSql = ' AND `is_private` = "Y" ';
	    }
	    // get challenges with these two users
		$query = "
			SELECT tc.`id` 
			FROM `hotornot-dev`.`tblChallenges` as tc
            	JOIN `hotornot-dev`.tblChallengeParticipants as tcp
            	ON tc.id = tcp.challenge_id
			WHERE (`status_id` IN (1,2,4) ) 
				$privateSql
				AND ( (tc.`creator_id` = ? AND tcp.user_id = ? ) 
					OR (tc.`creator_id` = ? AND tcp.user_id = ? ) )
			ORDER BY tc.`updated` DESC LIMIT 50";
				
		$params = array( $userId, $friendId, $friendId, $userId );
        $stmt = $this->prepareAndExecute( $query, $params );
        $ids = $stmt->fetchAll( PDO::FETCH_OBJ );
        foreach( $ids as &$id ){
            $id = $id->id;
        }
        $ids = array_unique($ids);
        return $ids;        
    }
    
    public function getVolleysForUserId( $userId, $private ){
		// get latest 10 challenges for user
	    $privateSql = ' AND tc.`is_private` != "Y" ';
	    if( $private ){
	        $privateSql = ' AND tc.`is_private` = "Y" ';
	    }
		
        $query = "
			SELECT tc.id 
			FROM `hotornot-dev`.`tblChallenges` as tc
            	JOIN `hotornot-dev`.tblChallengeParticipants as tcp
            	ON tc.id = tcp.challenge_id
			WHERE ( tc.status_id IN (1,4) ) 
				$privateSql
				AND (tc.`creator_id` = ? OR tcp.`user_id` = ? ) 
			ORDER BY tc.`updated` DESC LIMIT 50;";
				
		$params = array( $userId, $userId );
        $stmt = $this->prepareAndExecute( $query, $params );
        $ids = $stmt->fetchAll( PDO::FETCH_OBJ );
        foreach( $ids as &$id ){
            $id = $id->id;
        }
        $ids = array_unique($ids);
        return $ids;        
    }
    
    public function getVolleysForHashTag( $hashTag, $private = false  ){
	    $privateSql = ' AND `is_private` != "Y" ';
	    if( $private ){
	        $privateSql = ' AND `is_private` = "Y" ';
	    }
	    
		// get challenges based on subject
		$query = "
			SELECT tc.id 
			FROM `hotornot-dev`.tblChallenges as tc
            	JOIN `hotornot-dev`.tblChallengeSubjects as tcs
            	ON tc.subject_id = tcs.id	
			WHERE (tc.`status_id` = 1 OR tc.`status_id` = 4) 
		        $privateSql 
				AND tcs.title = ?
			ORDER BY tc.`updated` DESC
			LIMIT 100
		";
		$params = array( $hashTag );
        $stmt = $this->prepareAndExecute( $query, $params );
        $ids = $stmt->fetchAll( PDO::FETCH_OBJ );
        foreach( $ids as &$id ){
            $id = $id->id;
        }
        $ids = array_unique($ids);
        return $ids;        
    }
    
    public function getVolleysForHashTagId( $hashTagId, $private = false  ){
	    $privateSql = ' AND `is_private` != "Y" ';
	    if( $private ){
	        $privateSql = ' AND `is_private` = "Y" ';
	    }
	    
		// get challenges based on subject
		$query = "
			SELECT tc.id 
			FROM `hotornot-dev`.tblChallenges as tc
            	JOIN `hotornot-dev`.tblChallengeSubjects as tcs
            	ON tc.subject_id = tcs.id	
			WHERE tc.`status_id` in (1, 4) 
		        $privateSql 
				AND tcs.id = ?
			ORDER BY tc.`updated` DESC
			LIMIT 100
		";
		$params = array( $hashTagId );
        $stmt = $this->prepareAndExecute( $query, $params );
        $ids = $stmt->fetchAll( PDO::FETCH_OBJ );
        foreach( $ids as &$id ){
            $id = $id->id;
        }
        $ids = array_unique($ids);
        return $ids;        
    }
    
    public function getChallengesByDate(){
		$query = '
			SELECT id 
			FROM `hotornot-dev`.`tblChallenges` 
			WHERE `is_private` != "Y" 
				AND (`status_id` = 1 OR `status_id` = 4) 
			ORDER BY `updated` 
			DESC LIMIT 250;'; 
        $stmt = $this->prepareAndExecute( $query );
        $ids = $stmt->fetchAll( PDO::FETCH_OBJ );
        foreach( $ids as &$id ){
            $id = $id->id;
        }
        $ids = array_unique($ids);
        return $ids;
    }
    
    public function getChallengesByActivity(){
		// get vote rows for challenges
		$query = '
			SELECT tc.id 
			FROM `hotornot-dev`.tblChallenges as tc
				JOIN `hotornot-dev`.tblChallengeVotes as tcv
				ON tc.id = tcv.challenge_id 
			WHERE tc.status_id in (1,4)
			LIMIT 100
		';
        $stmt = $this->prepareAndExecute( $query );
        $ids = $stmt->fetchAll( PDO::FETCH_OBJ );
        foreach( $ids as &$id ){
            $id = $id->id;
        }
        $ids = array_unique($ids);
        return $ids;
		
    }
    
    public function getVoterCounts( $volleyId ){
		$query = "
			select user_id as id, count(*) as count 
			from `hotornot-dev`.tblChallengeVotes 
			where challenge_id = ? 
			group by user_id;";
		
		$params = array( $volleyId );
        $stmt = $this->prepareAndExecute( $query, $params );
        $ids = $stmt->fetchAll( PDO::FETCH_OBJ );
        return $ids;
    }
    
    public function getTopHashTags( $subjectName ){
		$query = '
			SELECT tc.subject_id as id, tc.title, count(*) as score
			from `hotornot-dev`.tblChallenges as tc
				JOIN `hotornot-dev`.tblChallengeSubjects as tcs
				ON tc.subject_id = tcs.id
			WHERE tcs.title LIKE ?
			GROUP BY subject_id
		';
		$params = array( "%$subjectName%" );
        $stmt = $this->prepareAndExecute( $query, $params );
        return $stmt->fetchAll( PDO::FETCH_OBJ );
    }
    
    public function getTopVolleysByVotes(){
        $startDate = time() - ( 86400 * 90 );
        $startDate = new DateTime( "@$startDate" );
        $startDate = $startDate->format('Y-m-d H:i:s');
        $query = '
        	SELECT `id` 
        	FROM `hotornot-dev`.tblChallenges
        	WHERE `status_id` = 4 
        		AND `started` > ? 
        	ORDER BY `votes` DESC LIMIT 256
        ';
		$params = array( $startDate );
        $stmt = $this->prepareAndExecute( $query, $params );
        $ids = $stmt->fetchAll( PDO::FETCH_OBJ );
        foreach( $ids as &$id ){
            $id = $id->id;
        }
        return $ids;
    }
}
