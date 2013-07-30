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
    
    public function add( $userId, $targetId, $hashTagId, $imgUrl, $isPrivate, $expires ){
        // add the new challenge
        $sql = '
            INSERT INTO `hotornot-dev`.`tblChallenges` 
                ( `id`, `status_id`, `subject_id`, `creator_id`, `creator_img`, `challenger_id`, `challenger_img`, `hasPreviewed`, `votes`, `updated`, `started`, `added`, `is_private`, `expires`) 
            VALUES 
                (NULL, "2", ?, ?, ?, ?, "", "N", "0", NOW(), NOW(), NOW(), ?, ? )
        ';
        $params = array($hashTagId, $userId, $imgUrl, $targetId, $isPrivate, $expires);
        
        $this->prepareAndExecute( $sql, $params );
        return $this->lastInsertId;
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
        $sql = 'SELECT * FROM `hotornot-dev`.`tblChallenges` WHERE `id` = ?';
        $params = array( $id );
        $stmt = $this->prepareAndExecute( $sql, $params );
        $data = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
        if( $data ){
            $volley = $data[0];
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
        $sql = 'UPDATE `hotornot-dev`.`tblChallenges` SET `status_id` = 4, `challenger_img` = ?, `updated` = NOW(), `started` = NOW() WHERE `id` = ? ';
        $params = array( $imgUrl, $volleyId );
        $this->prepareAndExecute($sql, $params);
    }
    
    public function getRandomAvailableByHashTag( $hashTag, $userId = null ){
        $v = null;
        $params = array( $hashTag );
        if( $userId ){
            $params[] = $userId;
            $userSql = 'AND `creator_id` != ?';
        }
        
        $sql = "
            SELECT `id`, `creator_id`
            FROM `hotornot-dev`.`tblChallenges` as tc
                JOIN tblChallengeSubjects as tcs
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
}
