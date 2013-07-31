<?php

class BIM_DAO_Mysql_Volleys extends BIM_DAO_Mysql{
    public function getUnjoined( ){
        $sql = "
            select * 
            from `hotornot-dev`.tblChallenges 
            where started < DATE( FROM_UNIXTIME( ? ) )
                and expires = -1
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
    
    public function add( $userId, $targetIds, $hashTagId, $imgUrl, $isPrivate, $expires ){
        // add the new challenge
        $sql = '
            INSERT INTO `hotornot-dev`.`tblChallenges` 
                ( `status_id`, `subject_id`, `creator_id`, `creator_img`, `hasPreviewed`, `votes`, `updated`, `started`, `added`, `is_private`, `expires`)
            VALUES 
                ("2", ?, ?, ?, "N", "0", NOW(), NOW(), NOW(), ?, ? )
        ';
        $params = array($hashTagId, $userId, $imgUrl, $isPrivate, $expires);
        $this->prepareAndExecute( $sql, $params );
        $volleyId = $this->lastInsertId;
        
        if( $volleyId ){
            // now we create the insert statement for all of the users in this volley
            $params = array();
            $insertSql = array();
            foreach( $targetIds as $targetId ){
                $insertSql[] = '(?,?)';
                $params[] = $volleyId;
                $params[] = $targetId;
            }
            $insertSql = join( ',' , $insertSql );
            
            $sql = "
                INSERT INTO `hotornot-dev`.`tblChallengeParticipants`
                    ( challenge_id, user_id )
                VALUES 
                	$insertSql;
            ";
            $this->prepareAndExecute( $sql, $params );
        }
        
        return $volleyId;
    }
    
    public function addHashTag( $subject, $userId ){
        $sql = 'INSERT INTO `hotornot-dev`.`tblChallengeSubjects` (`title`, `creator_id`, `added` ) VALUES ( ?, ?, now() )';
        $params = array( $subject, $userId );
        $this->prepareAndExecute( $sql, $params );
        return $this->lastInsertId;
    }
    
    public function getHashTagId( $hashTag ){
        $id = null;
        $sql = 'SELECT `id` FROM `hotornot-dev`.`tblChallengeSubjects` WHERE `title` = ?';
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
        		tcp.img AS challenger_img 
        	FROM `hotornot-dev`.`tblChallenges` AS tc 
        		JOIN `hotornot-dev`.`tblChallengeParticipants` AS tcp
        		ON tc.id = tcp.challenge_id 
        	WHERE tc.`id` = ?';
        
        $params = array( $id );
        $stmt = $this->prepareAndExecute( $sql, $params );
        $data = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
        if( $data ){
            $volley = array_shift( $data );
            $volley->challengers = array( ( object ) array( 'challenger_id' => $volley->challenger_id, 'challenger_img' => $volley->challenger_img ) );
            unset( $volley->challenger_id );
            unset( $volley->challenger_img );
            foreach( $data as $row ){
                $volley->challengers[] = ( object ) array( 'challenger_id' => $row->challenger_id, 'challenger_img' => $row->challenger_img );
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
        $sql = 'SELECT `title` FROM `hotornot-dev`.`tblChallengeSubjects` WHERE `id` = ?';
        $params = array( $subjectId );
        $stmt = $this->prepareAndExecute($sql, $params);
        $data = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
        if( $data ){
            $subject = $data[0]->title;
        }
        return $subject;
    }
    
    /**
     * Helper function to get the total # of comments for a challenge
     * @param $challenge_id The ID of the challenge (integer)
     * @return Total # of comments (integer)
    **/
    public function commentCount( $volleyId ){
        $count = null;
        $sql = 'SELECT count(*) as count FROM `hotornot-dev`.`tblComments` WHERE `challenge_id` = ?';
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
    
    public function accept( $volleyId, $imgUrl ){
        $sql = 'UPDATE `hotornot-dev`.`tblChallenges` SET `status_id` = 4, `updated` = NOW(), `started` = NOW() WHERE `id` = ? ';
        $params = array( $volleyId );
        $this->prepareAndExecute($sql, $params);
        
        $sql = 'UPDATE `hotornot-dev`.`tblChallengeParticipants` SET img = ? where `challenge_id` = ? ';
        $params = array( $imgUrl, $volleyId );
        $this->prepareAndExecute($sql, $params);
    }
    
    public function cancel( $volleyId ){
        $sql = 'UPDATE `hotornot-dev`.`tblChallenges` SET `status_id` = 3 WHERE `id` = ?';
        $params = array( $volleyId );
        $this->prepareAndExecute($sql, $params);
    }
    
    public function setPreviewed( $volleyId ){
        $sql = 'UPDATE `tblChallenges` SET `hasPreviewed` = "Y" WHERE `id` = ?';
        $params = array( $volleyId );
        $this->prepareAndExecute($sql, $params);
    }
    
    public function flag( $volleyId, $userId ){
        $sql = 'UPDATE `tblChallenges` SET `status_id` = 6 WHERE `id` = ?';
        $params = array( $volleyId );
        $this->prepareAndExecute($sql, $params);
        
        $sql = 'INSERT INTO `tblFlaggedChallenges` ( challenge_id`, `user_id`, `added`) VALUES ( ?, ? NOW() )';
        $params = array( $volleyId, $userId );
        $this->prepareAndExecute($sql, $params);
    }
    
    public function getRandomAvailableByHashTag( $hashTag, $userId = null ){
        $v = null;
        $params = array( $hashTag );
        if( $userId ){
            $params[] = $userId;
            $userSql = 'AND tc.`creator_id` != ?';
        }
        
        $sql = "
            SELECT tc.`id`, tc.`creator_id`
            FROM `hotornot-dev`.`tblChallenges` as tc
                JOIN `hotornot-dev`.tblChallengeSubjects as tcs
                ON tc.subject_id = tcs.id
            WHERE tc.status_id = 1 
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
        	SELECT `id` 
        	FROM `hotornot-dev`.`tblChallenges` 
        	WHERE (`status_id` NOT IN (2,3,6,8) )
        		AND (`creator_id` = ? OR `challenger_id` = ? ) 
        	ORDER BY `updated` DESC
        ';
        $params = array( $userId, $userId );
        $stmt = $this->prepareAndExecute( $sql, $params );
        return $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
    }
    
    public function getOpponents( $userId, $private ){
        $privateSql = ' AND `is_private` != "Y" ';
        if( $private ){
            $privateSql = ' AND `is_private` = "Y" ';
        }
        $sql = "
        	SELECT `creator_id`, `challenger_id` 
            FROM `tblChallenges` 
            WHERE ( status_id NOT IN (3,6,8) $privateSql ) 
              AND (`creator_id` = ? OR `challenger_id` = ? ) 
            ORDER BY `updated` DESC";
        
        $params = array( $userId, $userId );
        $stmt = $this->prepareAndExecute( $sql, $params );
        return $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
    }
    
    public function withOpponent( $userId, $opponentId, $lastDate = "9999-99-99 99:99:99", $private ){
        $privateSql = ' AND `is_private` != "Y" ';
        if( $private ){
            $privateSql = ' AND `is_private` = "Y" ';
        }
        
        if( $lastDate === null ){
            $lastDate = "9999-99-99 99:99:99";
        }
        
        // get challenges where both users are included
        $sql = "
        	SELECT `id`, `creator_id`, `challenger_id`, `updated` 
            FROM `tblChallenges` 
            WHERE ( status_id NOT IN (3,6,8) $privateSql )
                AND ( (`creator_id` = ? OR `challenger_id` = ?) AND (`creator_id` = ? OR `challenger_id` = ? ) ) 
                AND `updated` < ? 
            ORDER BY `updated` DESC
        ";
        
        $params = array( $userId, $userId, $opponentId, $opponentId, $lastDate );
        $stmt = $this->prepareAndExecute( $sql, $params );
        return $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
    }
    
    public function getIds( $userId, $private ){
        $pSql = "AND is_private = 'N'";
        if( $private ){
            $pSql = "AND is_private = 'Y'";
        }
        
        $query = "
            SELECT `id` 
            FROM `tblChallenges` 
            WHERE `status_id` in ( 1,2,4 ) 
                AND (`creator_id` = ?  OR `challenger_id` = ? )
                $pSql
            ORDER BY `updated` DESC;
        ";
        
        $params = array( $userId, $userId );
        $stmt = $this->prepareAndExecute( $sql, $params );
        return $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
    }
}
