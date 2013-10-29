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
    
    public function add( $userId, $targetIds, $hashTagId, $hashTag, $imgUrl, $isPrivate, $expires, $isVerify = false, $status = 2 ){
        if( !is_array($targetIds) ) $targetIds = array();
        $isVerify = (int) $isVerify;
        // add the new challenge
        $sql = '
            INSERT INTO `hotornot-dev`.tblChallenges 
                ( status_id, subject_id, subject, creator_id, creator_img, hasPreviewed, votes, updated, started, added, is_private, expires, is_verify )
            VALUES 
                (?, ?, ?, ?, ?, "N", "0", NOW(), NOW(), NOW(), ?, ?, ? )
        ';
        $params = array($status, $hashTagId, $hashTag, $userId, $imgUrl, $isPrivate, $expires, $isVerify);
        $this->prepareAndExecute( $sql, $params );
        $volleyId = $this->lastInsertId;
        
        if( !$isVerify ){
            $sql = 'UPDATE `hotornot-dev`.tblUsers SET total_challenges = total_challenges + 1 WHERE id = ? ';
            $params = array( $userId );
            $this->prepareAndExecute($sql, $params);
        }
        
        if( $volleyId && $targetIds ){
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
        $stmt = $this->prepareAndExecute( $sql, $params );
        $data = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
        if( $data ){
            $id = $data[0]->id;
        }
        return $id;
    }
    
    public function getMulti( $ids ){
        
        //$ids = array_splice($ids, 254);
        
		// $IdPlaceholders = trim( str_repeat('?,', count($ids) ), ',' );
        
        $ids = join(',', $ids);
                
        $sql = "
            SELECT 
                tc.*, 
                tcp.user_id AS challenger_id,
                tcp.img AS challenger_img,
                tcp.joined as joined
            FROM `hotornot-dev`.tblChallenges AS tc 
                LEFT JOIN `hotornot-dev`.tblChallengeParticipants AS tcp
                ON tc.id = tcp.challenge_id 
            WHERE tc.id IN ( $ids )
            ORDER BY tcp.joined";
        
        $stmt = $this->prepareAndExecute( $sql );
        
        //$params = array( $ids );
        //$stmt = $this->prepareAndExecute( $sql, $params );

        $data = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
    }
    
    public function get( $ids ){
        $returnArray = true;
        if( !is_array($ids)){
            $ids = array( $ids );
            $returnArray = false;
        }
        
        $placeHolders = trim(join('',array_fill(0, count( $ids ), '?,') ),',');
        
        $sql = "
        	SELECT 
        		tc.*, 
        		tcp.user_id AS challenger_id, 
        		tcp.img AS challenger_img,
        		tcp.joined as joined,
        		tcp.likes as likes,
        		tcp.subject as reply
        	FROM `hotornot-dev`.tblChallenges AS tc 
        		LEFT JOIN `hotornot-dev`.tblChallengeParticipants AS tcp
        		ON tc.id = tcp.challenge_id 
        	WHERE tc.id in ( $placeHolders )
        	ORDER BY tc.id, tcp.joined, tcp.user_id
        ";
        
        $stmt = $this->prepareAndExecute( $sql, $ids );
        $data = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
        
        $volleys = array();
        if( $data ){
            foreach( $data as $row ){
                if( empty( $volleys[ $row->id ] ) ){
                    if( !empty( $row->challenger_id ) ){
                        $row->challengers = array( ( object ) array( 'challenger_id' => $row->challenger_id, 'challenger_img' => $row->challenger_img,  'joined' => $row->joined, 'likes' => $row->likes, 'subject' => $row->reply ) );
                    } else {
                        $row->challengers = array();
                    }
                    unset( $row->challenger_id );
                    unset( $row->challenger_img );
                    unset( $row->joined );
                    unset( $row->likes );
                    $volleys[ $row->id ] = $row;
                } else {
                    $volley = $volleys[ $row->id ];
                    $volley->challengers[] = ( object ) array( 'challenger_id' => $row->challenger_id, 'challenger_img' => $row->challenger_img, 'joined' => $row->joined, 'likes' => $row->likes, 'subject' => $row->reply );
                }
            }
        }
        
        if( !$returnArray ){
            if( !empty( $volleys ) ){
                $volleys = current($volleys);
            } else {
                $volleys = (object) array();
            }
        } else {
            if( !empty($volleys) ){
                $volleys = array_values($volleys);
            } else {
                $volleys = array();
            }
        }
        
        return $volleys;
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
    
    public function setSubject($volleyId) {
        $subject = null;
        $sql = 'UPDATE `hotornot-dev`.tblChallenges as c 
        		join `hotornot-dev`.tblChallengeSubjects as s
        		on c.subject_id = s.id
        		set c.subject = s.title 
        		where c.id = ?';
        
        $params = array( $volleyId );
        $stmt = $this->prepareAndExecute($sql, $params);
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
    public function getLikes( $volleyId, $userId ) {
        $sql = "
        	select count(*) as count
        	from `hotornot-dev`.tblChallengeVotes 
        	where challenge_id = ?
        	AND challenger_id = ?
        ";
        $params = array( $volleyId, $userId );
        $stmt = $this->prepareAndExecute( $sql, $params );
        return $stmt->fetchColumn( 0 );
    }
    
    public function setLikes( $volleyId, $userId, $count, $isCreator = false ) {
        $sql = "
        	update `hotornot-dev`.tblChallengeParticipants
        	set likes = ?
        	where challenge_id = ?
        		AND user_id = ?
        ";
        $params = array( $count, $volleyId, $userId );
        $this->prepareAndExecute( $sql, $params );
        
        if( $isCreator ){
            // we need to update the creator row as well
            // if this is the creator
            // we can join here if we think we need to at some point
            $sql = "
            	update `hotornot-dev`.tblChallenges
            	set creator_likes = ?
            	where id = ?
            		AND creator_id = ?
            ";
            $params = array( $count, $volleyId, $userId );
            $this->prepareAndExecute( $sql, $params );
        }
    }
    
    public function join( $volleyId, $userId, $imgUrl, $hashTag = '' ){
        $sql = '
        	INSERT IGNORE INTO `hotornot-dev`.tblChallengeParticipants 
        	(challenge_id, user_id, img, joined, likes, subject ) 
        	VALUES 
        	(?, ?, ?, ?, ?, ?)
        ';
        $params = array( $volleyId, $userId, $imgUrl, time(), 0, $hashTag );
        $this->prepareAndExecute($sql, $params);

        if( $this->rowCount ){
            $sql = '
            	UPDATE `hotornot-dev`.tblChallenges 
            	SET status_id = 4, updated = NOW(), started = NOW() 
            	WHERE id = ?
            ';
            $params = array( $volleyId );
            $this->prepareAndExecute($sql, $params);
            
            $sql = '
            	UPDATE `hotornot-dev`.tblUsers 
            	SET total_challenges = total_challenges + 1 
            	WHERE id = ?
            ';
            $params = array( $userId );
            $this->prepareAndExecute($sql, $params);
        }
    }
    
    public function accept( $volleyId, $userId, $imgUrl ){
        $sql = 'UPDATE `hotornot-dev`.tblChallengeParticipants SET img = ?, joined = ? where challenge_id = ? and user_id = ? ';
        $params = array( $imgUrl, time(), $volleyId, $userId );
        $this->prepareAndExecute($sql, $params);
        
        $sql = 'UPDATE `hotornot-dev`.tblChallenges SET status_id = 4, updated = NOW(), started = NOW() WHERE id = ? ';
        $params = array( $volleyId );
        $this->prepareAndExecute($sql, $params);
    }

    /**
     * 
     * first we try to update the tblChallenges table for the creator img
     * if that is successfull then we
     * 	increment the total counts on the challenge
     *  set the updated date on the challenge
     * 	increment the users like count
     * 
     * if the like is not successful then we try to update the participant table
     * if that is successfull then we
     * 	increment the total counts on the challenge
     *  set the updated date on the challenge
     * 	increment the users like count
     * 
     * @param int $volleyId
     * @param int $userId
     * @param int $targetId
     * @param string $imgUrl
     */
    
    public function upVote( $volleyId, $userId, $targetId, $imgUrl ){
		$query = "
            INSERT IGNORE INTO `hotornot-dev`.`tblChallengeVotes` 
            (`challenge_id`, `user_id`, `challenger_id`, `added`) 
            VALUES ( ?, ?, ?, NOW() )
		";
		$params = array( $volleyId, $userId, $targetId );
        $stmt = $this->prepareAndExecute($query, $params);
		
        // first we try to update the creator likes
        $sql = '
        	UPDATE `hotornot-dev`.tblChallenges 
        	SET creator_likes = creator_likes + 1
        	where id = ? and creator_img = ?
        ';
        $params = array( $volleyId, $imgUrl );
        $this->prepareAndExecute($sql, $params);
        
        // if we did n ot update the creator likes
        // then we try to update the likes in the participants table
        // 
        if( !$this->rowCount ){
            $sql = '
            	UPDATE `hotornot-dev`.tblChallengeParticipants 
            	SET likes = likes + 1 
            	where user_id = ? 
            		  and challenge_id = ?
            		  and img = ?';
            
            $params = array( $targetId, $volleyId, $imgUrl );
            $this->prepareAndExecute($sql, $params);
        }
        
        // if we see that either table was updated, we proceed with the final updates
        if( $this->rowCount ){
            $sql = '
            	UPDATE `hotornot-dev`.tblChallenges 
            	SET votes = votes + 1, 
    	    		updated = now()
            	where id = ?
            ';
            $params = array( $volleyId );
            $this->prepareAndExecute($sql, $params);
            
            
            $sql = '
            	UPDATE `hotornot-dev`.tblUsers 
            	SET total_votes = total_votes + 1 
            	where id = ?';
            $params = array( $targetId );
            $this->prepareAndExecute($sql, $params);
        }
    }
    
    public function acceptFbInviteToVolley( $volleyId, $userId, $inviteId ){
        $query = "UPDATE `hotornot-dev`.tblChallengeParticipants SET user_id = ?  WHERE challenge_id = ? and user_id = ?";
        $params = array( $userId, $volleyId, $inviteId );
        $this->prepareAndExecute($query, $params);
    }
    
    public function updateStatus( $volleyId, $status ){
        $sql = 'UPDATE `hotornot-dev`.tblChallenges SET status_id = ? WHERE id = ?';
        $params = array( $status, $volleyId );
        $this->prepareAndExecute($sql, $params);
    }
    
    public function updateImage( $volleyId, $url ){
        $sql = '
        	UPDATE `hotornot-dev`.tblChallenges 
        	SET creator_img = ?, updated = now() 
        	WHERE id = ?
        ';
        $params = array( $url, $volleyId );
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
    
    public function getAllIdsForUser( $userId, $returnArray = false ){
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
        if( $returnArray ){
            return $stmt->fetchAll( PDO::FETCH_COLUMN, 0 );
        } else {
            return $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
        }
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
            	LEFT JOIN `hotornot-dev`.tblChallengeParticipants as tcp
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
        $teamVolleyId = BIM_Config::app()->team_volley_id;
        
        $sql = "
			SELECT tc.id 
			FROM `hotornot-dev`.tblChallenges as tc 
				LEFT JOIN `hotornot-dev`.tblFlaggedUserApprovals as u 
				ON tc.id = u.challenge_id AND u.user_id = ? 
				
			WHERE tc.status_id in ( 9,10 ) 
				AND tc.is_verify = 1 
				AND u.user_id is null
				AND tc.creator_id != ?
				AND tc.creator_id != $teamVolleyId
				AND tc.creator_img != ''
				AND tc.creator_img not like '%defaultAvatar%'
				
			GROUP BY tc.id
			ORDER BY tc.updated DESC, tc.id DESC 
			LIMIT 100
        ";
        
        $params = array( $userId, $userId );
        $stmt = $this->prepareAndExecute( $sql, $params );
        return $stmt->fetchAll( PDO::FETCH_COLUMN, 0 );
    }
    
    /*
881, 2454, 2, 2383, 2379, 2456, 882, 2457, 2394, 3932, 1

SELECT tc.id, tc.updated
FROM `hotornot-dev`.`tblChallenges` as tc 
WHERE
    tc.is_verify != 1
    AND tc.status_id IN (1,2,4)
    AND tc.`creator_id` IN ( 881, 2454, 2, 2383, 2379, 2456, 882, 2457, 2394, 3932, 1 )

UNION

SELECT tc.id, tc.updated
FROM `hotornot-dev`.`tblChallenges` as tc 
    LEFT JOIN `hotornot-dev`.tblChallengeParticipants as tcp
    ON tc.id = tcp.challenge_id
WHERE
    tc.is_verify != 1
    AND tc.status_id IN (1,2,4)
    AND tcp.`user_id` IN ( 881, 2454, 2, 2383, 2379, 2456, 882, 2457, 2394, 3932, 1 )
GROUP BY tc.id
ORDER BY updated DESC LIMIT 25



SELECT tc.id 
FROM `hotornot-dev`.`tblChallenges` as tc 
    JOIN `hotornot-dev`.tblChallengeParticipants as tcp 
    ON tc.id = tcp.challenge_id 
WHERE is_verify != 1 
       AND (
            ( 
                tc.status_id IN (1,2,4) 
                    AND 
                (tc.`creator_id` IN ( 881, 2454, 2, 2383, 2379, 2456, 882, 2457, 2394, 3932, 1, 881 ) OR tcp.`user_id` IN ( 881, 2454, 2, 2383, 2379, 2456, 882, 2457, 2394, 3932, 1, 881 ) ) 
            ) 
            OR 
            ( 
                tc.status_id = 2 AND tcp.user_id = 881 
            ) 
        ) 
        ORDER BY tc.`updated` DESC 
        LIMIT 64 
     * 
     */
    public function getVolleysWithFriends( $userId, $friendIds ){
	    
	    $fIdct = count( $friendIds );
		$fIdPlaceholders = trim( str_repeat('?,', $fIdct ), ',' );
		
		$query = "
            SELECT tc.id as id, tc.updated as updated
            FROM `hotornot-dev`.`tblChallenges` as tc 
            WHERE
                tc.is_verify != 1
                AND tc.status_id IN (1,2,4)
                AND tc.`creator_id` IN ( $fIdPlaceholders )
                
            UNION
            
            SELECT tc.id as id, tc.updated as updated
            FROM `hotornot-dev`.`tblChallenges` as tc 
                LEFT JOIN `hotornot-dev`.tblChallengeParticipants as tcp
                ON tc.id = tcp.challenge_id
            WHERE
                tc.is_verify != 1
                AND tc.status_id IN (1,2,4)
                AND tcp.`user_id` IN ( $fIdPlaceholders )
            GROUP BY tc.id, tc.updated
            ORDER BY updated DESC, id DESC LIMIT 25		
		";
		
		$dao = new BIM_DAO_Mysql_User( BIM_Config::db() );
        
        $params = $friendIds;
        foreach( $friendIds as $friendId ){
            $params[] = $friendId;
        }
        $stmt = $dao->prepareAndExecute( $query, $params );
        return $stmt->fetchAll( PDO::FETCH_COLUMN, 0 );
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
				AND tc.is_verify != 1
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
    
    public function getVolleysForUserId( $userId, $private = false ){
		// get latest 10 challenges for user
	    $privateSql = ' AND tc.`is_private` != "Y" ';
	    if( $private ){
	        $privateSql = ' AND tc.`is_private` = "Y" ';
	    }
		
        $query = "
			SELECT tc.id 
			FROM `hotornot-dev`.`tblChallenges` as tc
            	LEFT JOIN `hotornot-dev`.tblChallengeParticipants as tcp
            	ON tc.id = tcp.challenge_id
			WHERE ( tc.status_id IN (1,2,4) ) 
				$privateSql
				AND (tc.`creator_id` = ? OR tcp.`user_id` = ? )
				AND tc.is_verify != 1 
			GROUP BY id
			ORDER BY tc.`updated`
			";
				
		$params = array( $userId, $userId );
        $stmt = $this->prepareAndExecute( $query, $params );
        $ids = $stmt->fetchAll( PDO::FETCH_COLUMN, 0 );
        return array_unique($ids);        
    }
    
    public function getVolleysForProfile( $userId, $private ){
		// get latest 10 challenges for user
	    $privateSql = ' AND tc.`is_private` != "Y" ';
	    if( $private ){
	        $privateSql = ' AND tc.`is_private` = "Y" ';
	    }
		
        $query = "
			SELECT tc.id 
			FROM `hotornot-dev`.`tblChallenges` as tc
			WHERE ( tc.status_id IN (1,2,4) ) 
				$privateSql
				AND tc.`creator_id` = ?
				AND is_verify != 1
			ORDER BY tc.`updated` DESC LIMIT 10";
				
		$params = array( $userId );
        $stmt = $this->prepareAndExecute( $query, $params );
        $ids = $stmt->fetchAll( PDO::FETCH_COLUMN, 0 );
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
				AND updated > (select now() - INTERVAL 3 MONTH)
			ORDER BY tc.`updated` DESC
			LIMIT 25
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
				AND `status_id` IN (1,4)
				AND is_verify != 1
			ORDER BY `updated` 
			DESC LIMIT 100;'; 
        $stmt = $this->prepareAndExecute( $query );
        $ids = $stmt->fetchAll( PDO::FETCH_OBJ );
        foreach( $ids as &$id ){
            $id = $id->id;
        }
        $ids = array_unique($ids);
        return $ids;
    }
    
    public function getChallengesByCreationTime(){
		$query = '
			SELECT id 
			FROM `hotornot-dev`.`tblChallenges` 
			WHERE is_verify != 1
			ORDER BY `added` DESC 
			LIMIT 100;'; 
        $stmt = $this->prepareAndExecute( $query );
        $ids = $stmt->fetchAll( PDO::FETCH_COLUMN, 0 );
        return $ids;
    }
    
    public function getChallengesByActivity(){
		// get vote rows for challenges
		$query = '
			SELECT tc.id 
			FROM `hotornot-dev`.tblChallenges as tc
				JOIN `hotornot-dev`.tblChallengeVotes as tcv
				ON tc.id = tcv.challenge_id 
			WHERE is_verify != 1
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
        	ORDER BY `votes` DESC LIMIT 50
		';
		$params = array( "%$subjectName%" );
        $stmt = $this->prepareAndExecute( $query, $params );
        return $stmt->fetchAll( PDO::FETCH_OBJ );
    }
    
    public function getTopVolleysByVotes( $timeInPast = null ){
        $startDate = $timeInPast ? (time() - $timeInPast) : (time() - ( 86400 * 90 ));
        $startDate = new DateTime( "@$startDate" );
        $startDate = $startDate->format('Y-m-d H:i:s');
        $query = '
        	SELECT id, subject_id, sum(votes) as votes
        	FROM `hotornot-dev`.tblChallenges as c
        		join `hotornot-dev`.tblChallengeParticipants as p
        		on c.id = p.challenge_id
        	WHERE status_id = 4 
        		AND added > ? 
				AND is_verify != 1
				AND img != "" 
				AND img is not null 				
			GROUP BY subject_id
        	ORDER BY votes DESC LIMIT 64
        ';
		$params = array( $startDate );
        $stmt = $this->prepareAndExecute( $query, $params );
        return $stmt->fetchAll( PDO::FETCH_COLUMN, 0 );
    }
    
    public function getVolleyIdsByUpdatedTime( $date ){
        $sql = "select id from `hotornot-dev`.tblChallenges where updated >= ? and is_verify != 1";
        $params = array( $date );
        $stmt = $this->prepareAndExecute( $sql, $params );
        return $stmt->fetchAll( PDO::FETCH_COLUMN, 0 );
    }
    
    public function getVolleyIds( $noVerifyVolleys = false ){
        $sql = "select id from `hotornot-dev`.tblChallenges";
        if( $noVerifyVolleys ){
            $sql = " $sql where is_verify != 1 ";
        }
        $sql = " $sql order by id desc ";
        $stmt = $this->prepareAndExecute( $sql );
        return $stmt->fetchAll( PDO::FETCH_COLUMN, 0 );
    }
    
    public function getAllVerificationVolleyIds(){
        $sql = "select id from `hotornot-dev`.tblChallenges where is_verify = 1";
        $stmt = $this->prepareAndExecute( $sql );
        return $stmt->fetchAll( PDO::FETCH_COLUMN, 0 );
    }
    
    public function getFlagCounts( $volleyId ){
        $sql = "
        	select sum(flag) as count from `hotornot-dev`.tblFlaggedUserApprovals where challenge_id = ? and flag < 0
        	union all
        	select sum(flag) as count from `hotornot-dev`.tblFlaggedUserApprovals where challenge_id = ? and flag > 0
        ";
        $params = array( $volleyId, $volleyId );
        $stmt = $this->prepareAndExecute( $sql, $params );
        $data = $stmt->fetchAll( PDO::FETCH_COLUMN, 0 );
        return $data;
    }
    
    public function deleteVolleys( $ids ){
        $placeHolders = join(',',array_fill(0, count( $ids ), '?') );
        $sql = "delete from `hotornot-dev`.tblChallengeParticipants where challenge_id IN ( $placeHolders )";
        $stmt = $this->prepareAndExecute( $sql, $ids );
        
        $sql = "delete from `hotornot-dev`.tblChallenges where id IN ( $placeHolders )";
        $stmt = $this->prepareAndExecute( $sql, $ids );
    }
    
    public function updateExploreIds( $volleyData ){
        // the call below is to support legacy
        $this->_updateExploreIdsLegacy($volleyData);
        
        $sql = "update `hotornot-dev`.tblChallenges set is_explore = 0";
        $stmt = $this->prepareAndExecute( $sql );
        
        if( !empty( $volleyData ) ){
            $placeHolders = join(',',array_fill(0, count( $volleyData ), '?') );
            $params = array();
            $valueSql = array();
            foreach( $volleyData as $volley ){
                $params[] = $volley->id;
            }
            $sql = "
            	update `hotornot-dev`.tblChallenges 
            	set is_explore = 1
            	where id in ( $placeHolders )
            ";
            $stmt = $this->prepareAndExecute( $sql, $params );
        }
        return $volleyData;
    }
    
    private function _updateExploreIdsLegacy( $volleyData ){
        $sql = "delete from `hotornot-dev`.explore_ids";
        $stmt = $this->prepareAndExecute( $sql );
        if( !empty( $volleyData ) ){
            $params = array();
            $valueSql = array();
            foreach( $volleyData as $volley ){
                $valueSql[] = " ( ?,? ) ";
                $params[] = $volley->id;
                $params[] = $volley->updated;
            }
            $valueSql = join(',', $valueSql );
            $sql = "
            	INSERT IGNORE INTO `hotornot-dev`.explore_ids
            	(id,updated)
            	VALUES $valueSql
            ";
            
            $stmt = $this->prepareAndExecute( $sql, $params );
        }
        return $volleyData;
    }
    
    public function getExploreIds(){
        $sql = "select id from `hotornot-dev`.tblChallenges where is_explore = 1 order by updated desc";
        $stmt = $this->prepareAndExecute( $sql );
        $ids = $stmt->fetchAll( PDO::FETCH_COLUMN, 0 );
        return $ids;
    }
    
    public function getIdsByCreatorImage( $imgUrl ){
        $sql = "
        	select id 
        	from `hotornot-dev`.tblChallenges
        	where creator_img = ?
        ";
        $params = array( $imgUrl );
        $stmt = $this->prepareAndExecute( $sql, $params );
        return $stmt->fetchAll( PDO::FETCH_COLUMN, 0 );
    }
    
    public function deleteByImage( $imgUrl ){
        $sql = "
        	delete from `hotornot-dev`.tblChallengeParticipants
        	where challenge_id in (
            	select id 
            	from `hotornot-dev`.tblChallenges
            	where creator_img = ?
        	)
        ";
        $params = array( $imgUrl );
        $this->prepareAndExecute( $sql, $params );
        
        $sql = "
        	delete from `hotornot-dev`.tblChallenges
        	where creator_img = ?
        ";
        $params = array( $imgUrl );
        $this->prepareAndExecute( $sql, $params );
    }
    
    public function getIdsByParticipantImage( $imgUrl ){
        $sql = "
        	select challenge_id 
        	from `hotornot-dev`.tblChallengeParticipants
        	where img = ?
        ";
        $params = array( $imgUrl );
        $stmt = $this->prepareAndExecute( $sql, $params );
        $ids = $stmt->fetchAll( PDO::FETCH_COLUMN, 0 );
        return $ids;
    }
    
    public function deleteParticipantByImage( $imgUrl ){
        $sql = "
        	delete from `hotornot-dev`.tblChallengeParticipants
        	where img = ?
        ";
        $params = array( $imgUrl );
        $this->prepareAndExecute( $sql, $params );
    }
}
