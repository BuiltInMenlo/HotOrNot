<?php

class BIM_App_Votes extends BIM_App_Base{
    
	/**
	 * Helper function that returns a challenge based on ID
	 * @param $challenge_id The ID of the challenge to get (integer)
	 * @return An associative object for a challenge (array)
	**/
	public function getChallengeObj ($challenge_id) {
	    
	    $key = "challenge_$challenge_id";
	    
        /**
        * The following will initialize a Memcached client to utilize the Auto Discovery feature.
        * 
        * By configuring the client with the Dynamic client mode with single endpoint, the
        * client will periodically use the configuration endpoint to retrieve the current cache
        * cluster configuration. This allows scaling the cache cluster up or down in number of nodes
        * without requiring any changes to the PHP application. 
        */
        
        /* Configuration endpoint to use to initialize memcached client */
        $server_endpoint = "127.0.0.1";
        /* Port for connecting to the ElastiCache cluster */
        $server_port = 11211;
        
	    $m = new Memcached();
        // $m->setOption(Memcached::OPT_CLIENT_MODE, Memcached::STATIC_CLIENT_MODE);
        $m->addServer($server_endpoint, $server_port);
	    $challenge_arr = $m->get($key);
	    
	    if(!$challenge_arr){
			$challenge_arr = array();
			
			$this->dbConnect();
			
			// get challenge row
			$query = 'SELECT * FROM `tblChallenges` WHERE `id` = '. $challenge_id .';';
			$challenge_obj = mysql_fetch_object(mysql_query($query));
						
			// get subject title for this challenge
			$query = 'SELECT `title` FROM `tblChallengeSubjects` WHERE `id` = '. $challenge_obj->subject_id .';';
			$subject_obj = mysql_fetch_object(mysql_query($query));
			
			// get total number of comments
			$query = 'SELECT `id` FROM `tblComments` WHERE `challenge_id` = '. $challenge_id .' AND `status_id` = 1;';
			$comments = mysql_num_rows(mysql_query($query));
			
			// compose object
			$challenge_arr = array(
				'id' => $challenge_obj->id, 
				'status' => $challenge_obj->status_id, 
				'subject' => $subject_obj->title, 
				'comments' => $comments, 
				'has_viewed' => $challenge_obj->hasPreviewed, 
				'started' => $challenge_obj->started, 
				'added' => $challenge_obj->added, 
				'updated' => $challenge_obj->updated, 
				'creator' => $this->userForChallenge($challenge_obj->creator_id, $challenge_obj->id),
				'challenger' => $this->userForChallenge($challenge_obj->challenger_id, $challenge_obj->id),
			); 
			
			$m->set( $key, $challenge_arr );
	    }			
		// return
		return ($challenge_arr);
	}
	
	/**
	 * Helper function to user info for a challenge
	 * @param $user_id The creator or challenger ID (integer)
	 * @param $challenge_id The challenge's ID to get the user for (integer)
	 * @return An associative object for a user (array)
	**/
	public function userForChallenge($user_id, $challenge_id) {
		$this->dbConnect();
	    
		// prime the user
		$user_arr = array(
			'id' => $user_id, 
			'fb_id' => "",
			'username' => "",
			'avatar' => "", 
			'img' => "",
			'score' => 0				
		);
		
		// challenge object
		$query = 'SELECT `status_id`, `creator_id`, `challenger_id`, `creator_img`, `challenger_img` FROM `tblChallenges` WHERE `id` = '. $challenge_id .';';
		$challenge_obj = mysql_fetch_object(mysql_query($query));
		
		// user is the creator
		if ($user_id == $challenge_obj->creator_id) {
			$query = 'SELECT `fb_id`, `username`, `img_url` FROM `tblUsers` WHERE `id` = '. $user_id .';';
			$user_arr['img'] = $challenge_obj->creator_img;
						
		// user is the challenger
		} else {
			$query = 'SELECT `fb_id`, `username`, `img_url` FROM `tblUsers` WHERE `id` = '. $user_id .';';
			$user_arr['img'] = $challenge_obj->challenger_img;			
			
			// invited challenger
			if ($challenge_obj->status_id == "7")
				$query = 'SELECT `fb_id`, `username` FROM `tblInvitedUsers` WHERE `id` = '. $user_id .';';
		}
		
		// user object
		$user_obj = mysql_fetch_object(mysql_query($query));
		
		// votes for challenger
		$query = 'SELECT `challenger_id` FROM `tblChallengeVotes` WHERE `challenge_id` = '. $challenge_id .';';
	   	$score_result = mysql_query($query);
					
		while ($score_row = mysql_fetch_assoc($score_result)) {										
			if ($score_row['challenger_id'] == $user_id)
				$user_arr['score']++;
		}
		
		// user info
		if ($user_obj != null) {
			$user_arr['fb_id'] = $user_obj->fb_id;
			$user_arr['username'] = $user_obj->username;
			
			// find the avatar image
			if ($user_obj->img_url == "") {
				if ($user_obj->fb_id == "")
					$user_arr['avatar'] = "https://s3.amazonaws.com/hotornot-avatars/defaultAvatar.png";
				
				else
					$user_arr['avatar'] = "https://graph.facebook.com/". $user_obj->fb_id ."/picture?type=square";
		
			} else
				$user_arr['avatar'] = $user_obj->img_url;
		}
		
		return ($user_arr);
	}
	
	/** 
	 * Helper function to send an Urban Airship push
	 * @param $msg The message body of the push (string)
	 * @return null
	**/
    public function sendPush($msg) {
        return;
	// curl urban airship's api
		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL, 'https://go.urbanairship.com/api/push/');
		//curl_setopt($ch, CURLOPT_USERPWD, "qJAZs8c4RLquTcWKuL-gug:mbNYNOkaQ7CZJDypDsyjlQ"); // dev
		curl_setopt($ch, CURLOPT_USERPWD, "MB38FktJS8242wzKOOvEFQ:2c_IIFqWQKCpW9rhYifZVw"); // live
		curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		curl_setopt($ch, CURLOPT_POST, 1);
		curl_setopt($ch, CURLOPT_POSTFIELDS, $msg);
	 	$res = curl_exec($ch);
		$err_no = curl_errno($ch);
		$err_msg = curl_error($ch);
		$header = curl_getinfo($ch);
		curl_close($ch);
		
		// curl urban airship's api
		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL, 'https://go.urbanairship.com/api/push/');
		curl_setopt($ch, CURLOPT_USERPWD, "qJAZs8c4RLquTcWKuL-gug:mbNYNOkaQ7CZJDypDsyjlQ"); // dev
		//curl_setopt($ch, CURLOPT_USERPWD, "MB38FktJS8242wzKOOvEFQ:2c_IIFqWQKCpW9rhYifZVw"); // live
		curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		curl_setopt($ch, CURLOPT_POST, 1);
		curl_setopt($ch, CURLOPT_POSTFIELDS, $msg);
	 	$res = curl_exec($ch);
		$err_no = curl_errno($ch);
		$err_msg = curl_error($ch);
		$header = curl_getinfo($ch);
		curl_close($ch);		
	}
	
	/** 
	 * Gets the list of challenges sorted by total votes
	 * @param $user_id The ID of the user (integer)
	 * @return The list of challenges (array)
	**/
	public function getChallengesByActivity() {
		$this->dbConnect();
	    $challenge_arr = array();			
		$id_arr = array();
		
		// get waiting or started challenges
		$query = 'SELECT `id` FROM `tblChallenges` WHERE `status_id` = 1 OR `status_id` = 4;';
		$result = mysql_query($query);
		
		// loop thru challenges, priming array
		while ($row = mysql_fetch_assoc($result))
			$id_arr[$row['id']] = 0;
		
		// get vote rows for challenges
		$query = 'SELECT `tblChallenges`.`id` FROM `tblChallenges` INNER JOIN `tblChallengeVotes` ON `tblChallenges`.`id` = `tblChallengeVotes`.`challenge_id` WHERE `tblChallenges`.`status_id` = 1 OR `tblChallenges`.`status_id` = 4;';
		$result = mysql_query($query);
		
		// loop thru votes, incrementing vote total array
		while ($row = mysql_fetch_assoc($result))
			$id_arr[$row['id']]++;
        
		// limit to 100, and sort
		$cnt = 0;
		arsort($id_arr);
		
		// loop thru each challenge id
		foreach ($id_arr as $key => $val) {
			if ($cnt == 100)
				break;
			
			// push challenge into array
			array_push($challenge_arr, $this->getChallengeObj($key));
			$cnt++;
		}
		
		
		// return
		return $challenge_arr;
	}
	
	/** 
	 * Gets the list of challenges sorted by date
	 * @return The list of challenges (array)
	**/
	public function getChallengesByDate() {
		$this->dbConnect();

		$challenge_arr = array();
		
		
		// get available challenge rows
		$query = 'SELECT * FROM `tblChallenges` WHERE `is_private` != "Y" AND (`status_id` = 1 OR `status_id` = 4) ORDER BY `updated` DESC LIMIT 250;'; 
		
		$result = mysql_query($query);
		
		// loop thru rows
		while ($row = mysql_fetch_assoc($result)) {
			
			// push challenge into array
			array_push($challenge_arr, $this->getChallengeObj($row['id']));
		}
			
		return ($challenge_arr);
	}
	
	/** 
	 * Gets the list of challenges for a subject
	 * @param $subject_id The ID of the subject (integer)
	 * @return The list of challenges (array)
	**/
	public function getChallengesForSubjectID($subject_id) {
		$this->dbConnect();
	    $challenge_arr = array();
		
		// get challenges based on subject
		$query = 'SELECT * FROM `tblChallenges` WHERE (`status_id` = 1 OR `status_id` = 4) AND `subject_id` = '. $subject_id .' ORDER BY `updated` DESC;';
		$result = mysql_query($query);
		
		// loop thru challenges
		while ($row = mysql_fetch_assoc($result))
			array_push($challenge_arr, $this->getChallengeObj($row['id']));				

		
		return $challenge_arr;
	}
	
	/** 
	 * Gets the list of challenges for a subject
	 * @param $subject_name The name of the subject (string)
	 * @return The list of challenges (array)
	**/
	public function getChallengesForSubjectName($subject_name, $private = 'N' ) {
		$this->dbConnect();
	    $challenge_arr = array();
	    
	    $privateSql = ' AND `is_private` != "Y" ';
	    if( $private == 'Y' ){
	        $privateSql = ' AND `is_private` = "Y" ';
	    }
	    
		// get the subject id
		$query = 'SELECT `id` FROM `tblChallengeSubjects` WHERE `title` = "'. $subject_name .'";';
		$subject_id = mysql_fetch_object(mysql_query($query))->id;
		
		// get challenges based on subject
		$query = "SELECT * FROM `tblChallenges` WHERE (`status_id` = 1 OR `status_id` = 4) $privateSql AND `subject_id` = $subject_id  ORDER BY `updated` DESC;";
		$result = mysql_query($query);
		
		// loop thru challenges
		while ($row = mysql_fetch_assoc($result))
			array_push($challenge_arr, $this->getChallengeObj($row['id']));				

		
		// return
		return $challenge_arr;
	}
	
	
	/** 
	 * Gets the latest list of 50 challenges for a user
	 * @param $username The username of the user (string)
	 * @return The list of challenges (array)
	**/
	public function getChallengesForUsername($username, $private = false ) {
		$this->dbConnect();
	    $challenge_arr = array();
		
		// get the user's id
		$query = 'SELECT `id` FROM `tblUsers` WHERE `username` = "'. $username .'";';
		$user_result = mysql_query($query);
		
		if (mysql_num_rows($user_result) == 0) {
		    return $challenge_arr;
		} else {
			$user_id = mysql_fetch_object($user_result)->id;
			
			// get latest 10 challenges for user
    	    $privateSql = ' AND `is_private` != "Y" ';
    	    if( $private ){
    	        $privateSql = ' AND `is_private` = "Y" ';
    	    }
			
	        $query = "
				SELECT id 
				FROM `tblChallenges` 
				WHERE ( status_id IN (1,4) ) 
					$privateSql
					AND (`creator_id` = $user_id OR `challenger_id` = $user_id ) 
				ORDER BY `updated` DESC LIMIT 50;";
			$challenge_result = mysql_query($query);
		
			// loop thru the rows
			while ($challenge_row = mysql_fetch_array($challenge_result, MYSQL_BOTH)) {
				// push challenge into list
				array_push( $challenge_arr, $this->getChallengeObj( $challenge_row['id'] ) );
			}
		
			// return
		    return $challenge_arr;
		}
	}
	
	public function getChallengesWithFriends($input) {
		$this->dbConnect();
	    $challenge_arr = array();
	    
        $friends = BIM_App_Social::getFriends($input);
        $friendIds = array_map(function($friend){return $friend->user->id;}, $friends);
	    
        // we add our own id here so we will include our challenges as well, not just our friends
        $friendIds[] = $input->userID;
        
	    $fIdct = count( $friendIds );
		$fIdPlaceholders = trim( str_repeat('?,', $fIdct ), ',' );
		
        $query = "
        	SELECT id, is_private, creator_id, challenger_id
        	FROM `hotornot-dev`.`tblChallenges` as tc 
        	WHERE tc.status_id IN (1,4) 
        		AND (tc.`creator_id` IN ( $fIdPlaceholders ) OR tc.`challenger_id` IN ( $fIdPlaceholders ) ) 
        	ORDER BY tc.`updated` DESC LIMIT 50
        ";
        
		$dao = new BIM_DAO_Mysql_User( BIM_Config::db() );
        
        $params = $friendIds;
        foreach( $friendIds as $friendId ){
            $params[] = $friendId;
        }
        
        $stmt = $dao->prepareAndExecute( $query, $params );

        // loop thru the rows
		while ( $challenge_row = $stmt->fetch( PDO::FETCH_ASSOC ) ) {
		    //print_r( $challenge_row );
			// push challenge into list
			
		    $isForUser = ( $challenge_row['creator_id'] == $input->userID || $challenge_row['challenger_id'] == $input->userID );
			if( $challenge_row['is_private'] == 'N' || $isForUser ){
    			array_push( $challenge_arr, $this->getChallengeObj( $challenge_row['id'] ) );
			}
		}
            
		// return
		return $challenge_arr;
	}
	
	/** 
	 * Gets a list of challenges between two users
	 * @param $user_id The ID of the first user (integer)
	 * @param $challenger_id The ID of the second user (integer)
	 * @return The list of challenges (array)
	**/
	public function getChallengesWithChallenger($user_id, $challenger_id, $private = 'N') {
		$this->dbConnect();
	    $challenge_arr = array();
		
	    $privateSql = ' AND `is_private` != "Y" ';
	    if( $private == 'Y' ){
	        $privateSql = ' AND `is_private` = "Y" ';
	    }
	    // get challenges with these two users
		$query = "
			SELECT `id` FROM `tblChallenges` 
			WHERE (`status_id` IN (1,2,4) ) 
				$privateSql
				AND ( (`creator_id` = $user_id AND `challenger_id` = $challenger_id ) 
					OR (`creator_id` = $challenger_id AND `challenger_id` = $user_id ) )
			ORDER BY `updated` DESC LIMIT 50";
		$result = mysql_query($query);
		
		// loop thru challenges
		while ($row = mysql_fetch_assoc($result))
			array_push($challenge_arr, $this->getChallengeObj($row['id']));	
			
		return $challenge_arr;
	}
	
	/** 
	 * Gets a challenge for an ID
	 * @param $subject_id The ID of the subject (integer)
	 * @return An associative object of a challenge (array)
	**/
	public function getChallengeForChallengeID($challenge_id) {
		$challenge_arr = array();
		
		// get challenge & return
		array_push($challenge_arr, $this->getChallengeObj($challenge_id));
		return $challenge_arr;
	}
	
	
	/** 
	 * Gets the voters for a particular challenge
	 * @param $challenge_id The ID of the challenge (integer)
	 * @return An associative object of the users (array)
	**/
	public function getVotersForChallenge($challenge_id) {
		$this->dbConnect();
	    
		$user_arr = array();
		
		// get user votes for the challenge
		$query = 'SELECT `user_id`, `challenger_id`, `added` FROM `tblChallengeVotes` WHERE `challenge_id` = '. $challenge_id .' LIMIT 100;';
		$challenge_result = mysql_query($query);
		
		// loop thru votes
		while ($challenge_row = mysql_fetch_assoc($challenge_result)) {
			
			// get user info
			$query = 'SELECT * FROM `tblUsers` WHERE `id` = '. $challenge_row['user_id'] .';';
			$user_obj = mysql_fetch_object(mysql_query($query));
			
			// get total challenges this user is involved in
			$query = 'SELECT `id` FROM `tblChallenges` WHERE `creator_id` = '. $user_obj->id .' OR `challenger_id` = '. $user_obj->id .';';
			$challenge_tot = mysql_num_rows(mysql_query($query));
			
			// calculate total upvotes for this user
			$query = 'SELECT `id` FROM `tblChallengeVotes` WHERE `challenger_id` = '. $user_obj->id .';';
			$votes = mysql_num_rows(mysql_query($query));
			
			// calculate total pokes for this user
			$query = 'SELECT `id` FROM `tblUserPokes` WHERE `user_id` = '. $user_obj->id .';';
			$pokes = mysql_num_rows(mysql_query($query));
			
			// find the avatar image
			if ($user_obj->img_url == "") {
				if ($user_obj->fb_id == "")
					$avatar_url = "https://s3.amazonaws.com/hotornot-avatars/defaultAvatar.png";
				
				else
					$avatar_url = "https://graph.facebook.com/". $user_obj->fb_id ."/picture?type=square";
		
			} else
				$avatar_url = $user_obj->img_url;
				
				
			// get the person voted for
			$query = 'SELECT `username` FROM `tblUsers` WHERE `id` = '. $challenge_row['challenger_id'] .';';
			$challenger_name = mysql_fetch_object(mysql_query($query))->username;
			
			// push user into array
			array_push($user_arr, array(
				'id' => $user_obj->id, 
				'fb_id' => $user_obj->fb_id, 
				'username' => $user_obj->username, 					
				'img_url' => $avatar_url,   
				'points' => $user_obj->points,
				'votes' => $votes,
				'pokes' => $pokes, 
				'challenges' => $challenge_tot, 
				'challenger_name' => $challenger_name,
				'added' => $challenge_row['added']
			));	
		}
		
		// return
		return $user_arr;
	}
	
	/** 
	 * Upvotes a challenge
	 * @param $challenge_id The ID of the challenge (integer)
	 * @param $user_id The ID of the user performing the upvote
	 * @param $isCreator Y/N whether or not the vote is for the challenge creator
	 * @return An associative object of the challenge (array)
	**/
	public function upvoteChallenge($challenge_id, $user_id, $isCreator) {
		$this->dbConnect();
		// get challenge info
	    $query = 'SELECT `creator_id`, `subject_id`, `challenger_id`, `votes` FROM `tblChallenges` WHERE `id` = '. $challenge_id .';';
		$challenge_obj = mysql_fetch_object(mysql_query($query));
		$creator_id = $challenge_obj->creator_id;
		$challenger_id = $challenge_obj->challenger_id;
		$vote_tot = $challenge_obj->votes;
		
		// assign vote
		if ($isCreator == "Y")
			$winningUser_id = $creator_id;
						
		else
			$winningUser_id = $challenger_id;
			
		// get any votes for this challenge by this user
		$query = 'SELECT `id` FROM `tblChallengeVotes` WHERE `challenge_id` = '. $challenge_id .' AND `user_id` = '. $user_id .';';
		$vote_result = mysql_query($query);
		
		// hasn't voted on this challenge
		if (true){// (mysql_num_rows($vote_result) == 0) {							    
		
			// add vote record
			$query = 'INSERT INTO `tblChallengeVotes` (';
			$query .= '`id`, `challenge_id`, `user_id`, `challenger_id`, `added`) VALUES (';
			$query .= 'NULL, "'. $challenge_id .'", "'. $user_id .'", "'. $winningUser_id .'", NOW());';				
			$result = mysql_query($query);
			$vote_id = mysql_insert_id();
			
			// increment vote total & update time
			$query = 'UPDATE `tblChallenges` SET `votes` = "'. ++$vote_tot .'", `updated` = NOW() WHERE `id` = '. $challenge_id .';';
			$result = mysql_query($query);
		
		// existing vote	
		} else
			$vote_id = mysql_fetch_object($vote_result)->id;
		// get subject name
		$query = 'SELECT `title` FROM `tblChallengeSubjects` WHERE `id` = '. $challenge_obj->subject_id .';';
		$sub_name = mysql_fetch_object(mysql_query($query))->title;

		// get all votes for this challenge
		$query = 'SELECT `challenger_id` FROM `tblChallengeVotes` WHERE `challenge_id` = '. $challenge_id .';';
		$result = mysql_query($query);
		
		// calculate the scores
		$score_arr = array('creator' => 0, 'challenger' => 0);			
		while ($row = mysql_fetch_assoc($result)) {
			if ($row['challenger_id'] == $creator_id)
				$score_arr['creator']++;
				
			else
				$score_arr['challenger']++;
		}
		
		// send push to creator if votes equal a certain amount
		if($winningUser_id == $creator_id && $score_arr['creator'] % 5 == 0) {
			$query = 'SELECT `device_token` FROM `tblUsers` WHERE `id` = '. $winningUser_id .';';
			$device_token = mysql_fetch_object(mysql_query($query))->device_token;
			
			$this->sendPush('{"device_tokens": ["'. $device_token .'"], "type":"1", "aps": {"alert": "Your '. $sub_name .' snap has received '. $score_arr['creator'] .' upvotes!", "sound": "push_01.caf"}}');
		}
		
		// send push to challenger if votes equal a certain amount
		if($winningUser_id == $challenger_id && $score_arr['challenger'] % 5 == 0) {
			$query = 'SELECT `device_token` FROM `tblUsers` WHERE `id` = '. $winningUser_id .';';
			$device_token = mysql_fetch_object(mysql_query($query))->device_token;
			
			$this->sendPush('{"device_tokens": ["'. $device_token .'"], "type":"1", "aps": {"alert": "Your '. $sub_name .' snap has received '. $score_arr['challenger'] .' upvotes!", "sound": "push_01.caf"}}');
		}
		return $this->getChallengeObj($challenge_id);
	}
	
	/**
	 * Debugging function
	**/
	public function test() {
		return array(
			'result' => true
		);
	}
}
