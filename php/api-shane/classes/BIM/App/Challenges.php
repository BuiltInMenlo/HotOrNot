<?php
/*
Challenges
    action 1 - ( submitMatchingChallenge ),
    action 2 - ( getChallengesForUser ),
    action 3 - ( getAllChallengesForUser ),
    action 4 - ( acceptChallenge ),
    action 7 - ( submitChallengeWithUsername ),
    action 8 - ( getPrivateChallengesForUser ),
    action 9 - ( submitChallengeWithChallenger ),
    action 11 - ( flagChallenge ),
    action 12 - ( getChallengesForUserBeforeDate ),
    action 13 - ( getPrivateChallengesForUserBeforeDate ),
    action 14 - ( submitChallengeWithUsernames ),

 * 
 */

class BIM_App_Challenges extends BIM_App_Base{
    
    /**
     * 
     * return a list of awaiting verification objects
     * 
     * @param unknown_type $volleyId
     * @param unknown_type $userId
    **/
    public function getVerifyList ($userId) {
        $dao = BIM_DAO_Mysql_Volleys( BIM_Config::db() );
        $ids = $dao->getVerificationVolleyIds( $userId );
        return BIM_Model_Volley::getMulti( $ids );
    }
    
    /** 
     * Helper function to build a list of challenges between two users
     * @param $user_id The ID of the 1st user to get challenges (integer)
     * @param $opponent_id The ID of 2nd the user to get challenges (integer)
     * @param $last_date The timestamp to start at (integer)
     * @return An associative obj of challenge IDs paired w/ timestamp (array)
    **/
    public function challengesWithOpponent($userId, $opponentId, $lastDate = "9999-99-99 99:99:99", $private ) {
        return BIM_Model_Volley::withOpponent($userId, $opponentId, $lastDate, $private);
    }
    
    /**
     * Checks to see if a user ID is a default
     * @param $challenge_id The ID of the challenge
     * @return An associative object for a challenge (array)
    **/
    public function acceptChallengeAsDefaultUser($volleyObject, $creator, $targetUser) {
        $defaultUserID_arr = array( 2390, 2391, 2392, 2393, 2394, 2804, 2805, 2811, 2815, 2818, 2819, 2824 );
        if ( in_array($targetUser->id, $defaultUserID_arr) ) {
            $time = time() + mt_rand(30, 120);
            $this->createTimedAccept( $volleyObject, $creator, $targetUser, $time );
        }
    }
    
    public function doAcceptChallemgeAsDefaultUser( $volleyObject, $creator, $targetUser ){
        $imgUrl = "https://hotornot-challenges.s3.amazonaws.com/". $targetUser->device_token ."_000000000". mt_rand(0, 2);
        $volleyObject->accept( $targetUser->id, $imgUrl );
        if ($creator->notifications == "Y"){
            $this->doAcceptNotification($volleyObject, $creator, $targetUser);
        }
    }
    
    public function doAcceptNotification( $volleyObject, $creator, $targetUser, $delay = 0 ){
        $msg = "$targetUser->username has accepted your $volleyObject->subject snap!";
        $push = array(
            "device_tokens" =>  array( $creator->device_token ), 
            "type" => "3", 
            "aps" =>  array(
                "alert" =>  $msg,
                "sound" =>  "push_01.caf"
            )
        );
        
        if( $delay ){
            $pushTime = time() + $delay;
            $this->createTimedPush($push, $pushTime);
        } else {
            BIM_Push_UrbanAirship_Iphone::sendPush( $push );
        }
    }
    
    public function createTimedAccept( $volleyObject, $creator, $targetUser, $time ){
        $time = new DateTime("@$time");
        $time = $time->format('Y-m-d H:i:s');
        
        $job = (object) array(
            'nextRunTime' => $time,
            'class' => 'BIM_Jobs_Challenges',
            'method' => 'acceptChallengeAsDefaultUser',
            'name' => 'acceptchallengeasdefaultuser',
            'params' => array( 
                'volleyObject' => $volleyObject,
                'creator' => $creator,
                'targetUser' => $targetUser,
            ),
            'is_temp' => true,
        );
        
        $j = new BIM_Jobs_Gearman();
        $j->createJbb($job);
    }
    
    public function createTimedPush( $push, $time ){
        $time = new DateTime("@$time");
        $time = $time->format('Y-m-d H:i:s');
        
        $job = (object) array(
            'nextRunTime' => $time,
            'class' => 'BIM_Jobs_Challenges',
            'method' => 'doPush',
            'name' => 'push',
            'params' => $push,
            'is_temp' => true,
        );
        
        $j = new BIM_Jobs_Gearman();
        $j->createJbb($job);
    }
    
    /**
     * Inserts a new challenge and attempts to match on a waiting challenge with the same subject
     * @param $user_id The ID of the user submitting the challenge (integer)
     * @param $subject The subject for the challenge
     * @param $img_url The URL to the image for the challenge
     * @return An associative object for a challenge (array)
    **/
    public function submitMatchingChallenge($userId, $hashTag, $imgUrl, $expires) {
        $volley = BIM_Model_Volley::getRandomAvailableByHashTag( $hashTag, $userId );
        if ( $volley ) {
            $creator = BIM_User::get( $volley->creator->id );
            $targetUser = BIM_User::get( $userId );
            if( $targetUsr->isExtant() ){
                $volley->accept( $userId, $imgUrl );
                $this->doAcceptNotification($volley, $creator, $targetUser);
            }
        } else {
            $volley = BIM_Model_Volley::create($userId, $hashTag, $imgUrl, -1, 'N', $expires);
        }
        return $volley;
    }
    
    /**
     * Submits a new challenge to a specific user
     * @param $user_id The user submitting the challenge (integer)
     * @param $subject The challenge's subject (string)
     * @param $img_url The URL to the challenge's image (string)
     * @param $challenger_id The ID of the user to target (integer)
     * @return An associative object for a challenge (array)
    **/
    public function submitChallengeWithChallenger($userId, $hashTag, $imgUrl, $targetIds, $isPrivate, $expires) {
        $volley = null;
        $creator = BIM_User::get( $userId );
        if ( $creator->isExtant() ) {
            if( ! is_array( $targetIds ) ){
                $targetIds = array( $targetIds );
            }
            
            $validTargetIds = array();
            $validTargets = array();
            foreach( $targetIds as $target ){
                if( !is_object( $target ) ){
                    $target = BIM_User::get( $target );
                }
                if( $target->isExtant() ){
                    $validTargetIds[] = $target->id;
                    $validTargets[] = $target;
                }
            }
            $volley = BIM_Model_Volley::create($creator->id, $hashTag, $imgUrl, $validTargetIds, $isPrivate, $expires);
            if( $volley ){
                foreach( $validTargets as $targetUser ){
                    $this->acceptChallengeAsDefaultUser( $volley, $creator, $targetUser );
                    if ($targetUser->notifications == "Y"){
                        $this->doNotification( $creator, $targetUser, $volley->id, $hashTag, $expires, $isPrivate );
                    }
                }
            }
        }
        return $volley;
    }
    
    protected static function reminderTime(){
        return 180;
    }
    
    /**
     * Submits a new challenge to a specific user
     * @param $user_id The user submitting the challenge (integer)
     * @param $subject The challenge's subject (string)
     * @param $img_url The URL to the challenge's image (string)
     * @param $username array | string the username(s) of the user to target (string)
     * @return An associative object for a challenge (array)
    **/
    public function submitChallengeWithUsername($userId, $hashTag, $imgUrl, $usernames, $isPrivate, $expires ) {
        if( ! is_array( $usernames ) ){
            $usernames = array( $usernames );
        }
        foreach( $usernames as &$uname ){
            $uname = BIM_User::getByUsername( $uname );
        }
        return $this->submitChallengeWithChallenger($userId, $hashTag, $imgUrl, $usernames, $isPrivate, $expires);
    }
    
    public function doNotification( $creator, $target, $volleyId, $hashTag, $expires, $isPrivate = 'N' ){
        $private = $isPrivate == 'Y' ? ' private' : '';
        $expiresTxt = '';
        if($expires == 86400){
            $expiresTxt = ' that will expire in 24 hours';
        } else if( $expires == 600 ){
            $expiresTxt = ' that will expire in 10 mins';
        }
        $msg = "@$creator->username has sent you a$private Volley$expiresTxt. $hashTag";
        $push = array(
            "device_tokens" =>  array( $target->device_token ), 
            "type" => "1", 
            "challenge" => $volleyId,
            "aps" =>  array(
                "alert" =>  $msg,
                "sound" =>  "push_01.caf"
            )
        );
        BIM_Push_UrbanAirship_Iphone::sendPush( $push );
        // create the reminder push
        if( $expires > 0 ){
            $msg = "@$creator->username has sent you a$private Volley that will expire in 2 mins! $hashTag";
            $push['aps']['alert'] = $msg;
            $time = $expires - self::reminderTime();
            BIM_Push_UrbanAirship_Iphone::createTimedPush($push, $time);
        }
    }
    
    /** 
     * Gets all the challenges for a user
     * @param $user_id The ID of the user (integer)
     * @return The list of challenges (array)
    **/
    public function getAllChallengesForUser($userId) {
        return BIM_Model_Volley::getAllForUser( $userId );
    }
    
    /** 
     * Gets all the public challenges for a user
     * @param $user_id The ID of the user (integer)
     * @return The list of challenges (array)
    **/
    public function getChallenges($userId, $private = false ) {
        return BIM_Model_Volley::getVolleys($userId, $private);
    }
    
    /** 
     * Gets the latest list of challenges for a user and the challengers
     * @param $user_id The ID of the user (integer)
     * @param $private - boolean inducating whether or not to get private messgaes or public mesages
     * @return The list of challenges (array)
    **/
    public function getChallengesForUser($user_id, $private = false ) {
        
        // get list of past opponents & loop thru
        $opponentID_arr = BIM_Model_Volley::getOpponents($user_id, $private);

        foreach($opponentID_arr as $key => $val){
            $opponentChallenges_arr[$user_id .'_'. $val][] = $this->challengesWithOpponent($user_id, $val, null, $private);
        }
        // loop thru each paired match & pull off most recent
        $challengeID_arr = array();
        foreach($opponentChallenges_arr as $key => $val){
            array_push($challengeID_arr, key($val[0]));
        }
        $challengeID_arr = array_unique($challengeID_arr);
        // sort by date asc, then reverse to go desc
        asort($challengeID_arr);
        $challengeID_arr = array_reverse($challengeID_arr, true);
        
        // loop thru the most resent challenge ID per creator/challenger match
        $cnt = 0;
        $challenge_arr = array();
        foreach ($challengeID_arr as $key => $val) {
            $co = BIM_Model_Volley::get( $val );
            if( $co->expires != 0 ){
                array_push( $challenge_arr, $co );
            }
            
            // stop at 10
            if (++$cnt == 10)
                break;
        }
            
        //print_r( array( $opponentID_arr, $opponentChallenges_arr, $challengeID_arr, $challenge_arr ) ); exit;
        
        
        // return
        return $challenge_arr;
    }
    
    
    /** 
     * Gets the next 10 challenges for a user prior to a date
     * @param $user_id The user's ID to get challenges for (integer)
     * @param $date the date/time to get challenges before (string)
     * @return The list of challenges (array)
    **/
    public function getChallengesForUserBeforeDate($user_id, $prevIDs, $date, $private = false) {
        $prevID_arr = explode('|', $prevIDs);

        $opponentID_arr = BIM_Model_Volley::getOpponents($user_id, $private);
        
        // loop thru prev id & remove from opponent array
        foreach($prevID_arr as $key => $val) {
            $ind = array_search($val, $opponentID_arr);
            
            // check against previous opponents
            if (is_numeric($ind))
                array_splice($opponentID_arr, $ind, 1);
        }

        // loop thru opponents & build paired array
        foreach($opponentID_arr as $key => $val) {
            
            // check against previous opponents
            if (count($this->challengesWithOpponent($user_id, $val, $date, $private ) ) > 0)
                $opponentChallenges_arr[$user_id .'_'. $val][] = $this->challengesWithOpponent($user_id, $val, $date, $private);
        }
        
        
        // loop thru each paired match & pull off most recent
        $challengeID_arr = array();
        foreach($opponentChallenges_arr as $key => $val) 
            array_push($challengeID_arr, key($val[0]));
            
        
        // sort by date asc, then reverse to go desc
        asort($challengeID_arr);
        $challengeID_arr = array_reverse($challengeID_arr, true);
        
        
        // loop thru the most resent challenge ID per creator/challenger match
        $cnt = 0;
        $challenge_arr = array();
        foreach ($challengeID_arr as $key => $val) {
            $co = BIM_Model_Volley::get( $val );
            if( $co->expires != 0 ){
                array_push( $challenge_arr, $co );
            }
            
            // stop at 10
            if (++$cnt == 10)
                break;
        }
        
        // return
        return $challenge_arr;
    }
    
    /**
     * Updates a challenge with a challenger
     * @param $user_id The user's ID who is accepting the challenge (integer)
     * @param $challenge_id the ID of the challenge being accepted (integer)
     * @param $img_url The URL to the challenger's image (string)
     * @return The ID of the challenge (integer)
    **/
    public function join($userId, $volleyId, $imgUrl ) {
        $volley = BIM_Model_Volley::get( $volleyId );
        if( $volley ){
            $OK = false;
            if( $volley->is_private == 'N' ){
                $volley->join( $userId, $imgUrl );
            }
        }
        return $volley;        
    }
    
    /**
     * Updates a challenge with a challenger
     * @param $user_id The user's ID who is accepting the challenge (integer)
     * @param $challenge_id the ID of the challenge being accepted (integer)
     * @param $img_url The URL to the challenger's image (string)
     * @return The ID of the challenge (integer)
    **/
    public function acceptChallenge($userId, $volleyId, $imgUrl ) {
        $volley = BIM_Model_Volley::get( $volleyId );
        if( $volley ){
            $OK = true;
            if( $volley->is_private == 'Y' ){
                $OK = false;
                foreach( $volley->challengers as $challenger ){
                    if( $challenger->id == $userId ){
                        $OK = true;
                        break;
                    }
                }
            }
            if( $OK ){
                $volley->accept($userId, $imgUrl);
            }
        }
        return $volley;        
    }
    
    /**
     * Updates a challenge to being canceled
     * @param $challenge_id The challenge to update (integer)
     * @return The ID of the challenge (integer)
    **/
    public function cancelChallenge ($volleyId) {
        $volley = BIM_Model_Volley::get( $volleyId );
        $volley->cancel();
        return $volley;
    }
    
    /** 
     * Flags the challenge for abuse / inappropriate content
     * @param $user_id The user's ID who is claiming abuse (integer)
     * @param $challenge The ID of the challenge to flag (integer)
     * @return An associative object (array)
    **/
    public function flagChallenge ($userId, $volleyId) {
        $volley = BIM_Model_Volley::get($volleyId);
        $volley->flag( $userId );
        $this->sendFlagEmail($volleyId, $userId);
        return array(
            'id' => $volleyId,
            'mail' => true
        );
    }
    
    public function sendFlagEmail( $volleyId, $userId ){
        // send email
        $to = "bim.picchallenge@gmail.com";
        $subject = "Flagged Challenge";
        $body = "Challenge ID: #". $volleyId ."\nFlagged By User: #". $userId;
        $from = "picchallenge@builtinmenlo.com";
        
        $headers_arr = array();
        $headers_arr[] = "MIME-Version: 1.0";
        $headers_arr[] = "Content-type: text/plain; charset=iso-8859-1";
        $headers_arr[] = "Content-Transfer-Encoding: 8bit";
        $headers_arr[] = "From: {$from}";
        $headers_arr[] = "Reply-To: {$from}";
        $headers_arr[] = "Subject: {$subject}";
        $headers_arr[] = "X-Mailer: PHP/". phpversion();

        mail($to, $subject, $body, implode("\r\n", $headers_arr));
    }
            
    /** 
     * Updates a challenge that has been opened
     * @param $challenge_id The ID of the challenge
     * @return An associative array with the challenge's ID
    **/
    public function updatePreviewed ($volleyId) {
        $volley = BIM_Model_Volley::get($volleyId);
        $volley->setPreviewed();
        return $volley;
    }
    
    /**
     * Gets the iTunes info for a specific challenge subject
     * @param $subject_name The subject to look up (string)
     * @return An associative array
    **/
    public function getPreviewForSubject ($subject_name) {
        // return
        return array(
            'id' => 0, 
            'title' => $subject_name, 
            'preview_url' => "",
            'artist' => "",
            'song_name' => "",
            'img_url' => "",
            'itunes_url' => "",
            'linkshare_url' => ""
        );
    }

    /** 
     * Debugging function
    **/
    public function test() {
        return array(
            'result' => true
        );
    }
    
    /**
     * 
     * this function will look for old unjoined volleys and redirect them
     * 
     * get all challenges that have status = 1,2 and are > 2 weeks old and expires = -1 and that have a challenger
     * foreach challenge, we randomly select a user and fire a volley at them
     * the process of revolley will simply change the challenger_id column
     * we send a push to the new challenger
     * 
     */
    public static function processReVolleys(){
        $dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
        $unjoined = $dao->getUnjoined();
        foreach( $unjoined as $volley ){
            self::reVolley( $volley );
        }
    }
    
    public static function reVolley( $volley ){
        $conf = BIM_Config::db();
        
        $dao = new BIM_DAO_Mysql_User( $conf );
        $userId = $dao->getRandomUserId( array($volley->challenger_id, $volley->creator_id ) );
        if( $userId ){
            $subject = self::getSubject($volley->subject_id);
            $challenger = BIM_User::get( $userId );
            $creator = BIM_User::get( $volley->creator_id );
            
            $dao = new BIM_DAO_Mysql_Volleys( $conf );
            
            $dao->reVolley( $volley, $challenger );
            
            // send push if allowed
            if ($challenger->notifications == "Y"){
                 $private = $volley->is_private == 'Y' ? ' private' : '';
                 $msg = "@$creator->username has sent you a$private Volley. $subject";
                 
                $push = array(
                    //"device_tokens" =>  array( '66595a3b5265b15305212c4e06d1a996bf3094df806c8345bf3c32e1f0277035' ), 
                    "device_tokens" =>  array( $challenger->device_token ), 
                    "type" => "1", 
                    "challenge" => $volley->id, 
                    "aps" =>  array(
                        "alert" =>  $msg,
                        "sound" =>  "push_01.caf"
                    )
                );
                
                BIM_Push_UrbanAirship_Iphone::sendPush( $push );
            }
            echo "Volley $volley->id was re-vollied to $challenger->username : $challenger->id\n";
        }
    }
    
    public static function getSubject($tagId) {
        $dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
        return $dao->getHashTagId($tagId);
    }
}
