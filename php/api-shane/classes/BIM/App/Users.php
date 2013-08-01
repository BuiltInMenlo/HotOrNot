<?php

require_once 'BIM/App/Base.php';

class BIM_App_Users extends BIM_App_Base{

    /**
	 * Helper function to get the correct user avatar
	 * @param $user_obj A associative object of the user (array)
	 * @return A url to an image (string)
	**/
	public function avatarURLForUser($user_obj) {
		
		// no custom url
		if ($user_obj->img_url == "") {
			
			// has fb login
			if ($user_obj->fb_id != "")
				return ("https://graph.facebook.com/". $user_obj->fb_id ."/picture?type=square");
			
			// has nothing, default
			else
				return ("https://s3.amazonaws.com/hotornot-avatars/defaultAvatar.png");
		}
		
		// use custom
		return ($user_obj->img_url);
	}
		
	
	/**
	 * Helper function to retrieve a user's info
	 * @param $user_id The ID of the user to get (integer)
	 * @param $meta Any extra info to include (string)
	 * @return An associative object for a user (array)
	**/ 
	public function userObject($user_id, $meta="") {
		$this->dbConnect();
	    
		// get user row
		$query = 'SELECT * FROM `tblUsers` WHERE `id` = "'. $user_id .'";';
		$row = mysql_fetch_object(mysql_query($query));
		
		// get total votes
		$query = 'SELECT `id` FROM `tblChallengeVotes` WHERE `challenger_id` = '. $user_id .';';
		$votes = mysql_num_rows(mysql_query($query));
		
		// get total pokes
		$query = 'SELECT `id` FROM `tblUserPokes` WHERE `user_id` = '. $user_id .';';
		$pokes = mysql_num_rows(mysql_query($query));
		
		// get total pics
		$query = 'SELECT `id` FROM `tblChallenges` WHERE `creator_id` = '. $row->id .';';
		$pics = mysql_num_rows(mysql_query($query));
		
		$query = 'SELECT `id` FROM `tblChallenges` WHERE `challenger_id` = '. $row->id .' AND `challenger_img` != "";';
		$pics += mysql_num_rows(mysql_query($query));
		
		
		// find the avatar image
		$avatar_url = $this->avatarURLForUser($row);
		
		// return
		return(array(
			'id' => $row->id, 
			'username' => $row->username,
			'name' => $row->username, 
			'token' => $row->device_token, 
			'fb_id' => $row->fb_id, 
			'gender' => $row->gender, 
			'avatar_url' => $avatar_url,
			'bio' => $row->bio,
			'website' => $row->website,
			'paid' => $row->paid,
			'points' => $row->points, 
			'votes' => $votes,
		    'age' => $row->age,
			'pokes' => $pokes, 
			'pics' => $pics,
			'notifications' => $row->notifications, 
			'meta' => $meta,
		    'sms_code' => BIM_Utils::getSMSCodeForId($row->id ),
		    'friends' => BIM_App_Social::getFriends( (object) array( 'userID' => $row->id ) ),
		    'sms_verified' => BIM_User::isVerified( $user_id )
		));
	}
	
	/**
	 * Helper function to send an email to a facebook user
	 * @param $username The facebook username to send to (string)
	 * @param $msg The message body (string)
	 * @return Whether or not the email was sent (boolean)
	**/
	public function fbEmail ($username, $msg) {
		// core message
		$to = $username ." <". $username ."@facebook.com>";
		$subject = "Welcome to PicChallengeMe!";
		$from = "PicChallenge <picchallenge@builtinmenlo.com>";
		
		// mail headers
		$headers_arr = array();
		$headers_arr[] = "MIME-Version: 1.0";
		$headers_arr[] = "Content-type: text/plain; charset=iso-8859-1";
		$headers_arr[] = "Content-Transfer-Encoding: 8bit";
		$headers_arr[] = "From: ". $from;
		$headers_arr[] = "Reply-To: ". $from;
		$headers_arr[] = "Subject: ". $subject;
		$headers_arr[] = "X-Mailer: PHP/". phpversion();
		
		// send & return
		return (mail($to, $subject, $msg, implode("\r\n", $headers_arr)));
	}
	
	/**
	 * Adds a new user or returns one if it already exists
	 * @param $device_token The Urban Airship token generated on device (string)
	 * @return An associative object representing a user (array)
	**/
	public function submitNewUser($device_token) {
		$this->dbConnect();
	    
		// check for user
		$query = 'SELECT * FROM `tblUsers` WHERE `device_token` = "'. $device_token .'";';
		$result = mysql_query($query);
		
		// found the user
		if (mysql_num_rows($result) > 0) {
			$row = mysql_fetch_object($result);
			$user_id = $row->id;
			
			// update last login
			$query = 'UPDATE `tblUsers` SET `last_login` = CURRENT_TIMESTAMP WHERE `id` = '. $user_id .';';
			$result = mysql_query($query);				
		
		// not found
		} else {
			
			// default names
			$defaultName_arr = array(
				"snap4snap",
				"picchampX",
				"swagluver",
				"coolswagger",
				"yoloswag",
				"tumblrSwag",
				"instachallenger",
				"hotbitchswaglove",
				"lovepeaceswaghot",
				"hotswaglover",
				"snapforsnapper",
				"snaphard",
				"snaphardyo",
				"yosnaper",
				"yoosnapyoo"
			);
			
			$rnd_ind = mt_rand(0, count($defaultName_arr) - 1);
			
			// add new user			
			$query = 'INSERT INTO `tblUsers` (';
			$query .= '`id`, `username`, `device_token`, `fb_id`, `gender`, `bio`, `website`, `paid`, `points`, `notifications`, `last_login`, `added`) ';
			$query .= 'VALUES (NULL, "", "'. $device_token .'", "", "N", "", "", "N", "0", "Y", CURRENT_TIMESTAMP, NOW());';
			$result = mysql_query($query);
			$user_id = mysql_insert_id();
			
			$username = $defaultName_arr[$rnd_ind] . $user_id;
			
			// create a default username 
			$query = 'UPDATE `tblUsers` SET `username` = "'. $username .'" WHERE `id` = '. $user_id .';';
			$result = mysql_query($query);
			
			// starting users & snaps
            $snap_arr = array(
            	array(// @Team Volley #welcomeVolley
            		'user_id' => "2394", 
            		'subject_id' => "1367", 
            		'img_prefix' => "https://hotornot-challenges.s3.amazonaws.com/fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffb_0000000000"),
            	
            	array(// @Team Volley #teamVolleyRules
            		'user_id' => "2394", 
            		'subject_id' => "1368", 
            		'img_prefix' => "https://hotornot-challenges.s3.amazonaws.com/fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffb_0000000001"),
            		
            	array(// @Team Volley #teamVolley
            		'user_id' => "2394", 
            		'subject_id' => "1369", 
            		'img_prefix' => "https://hotornot-challenges.s3.amazonaws.com/fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffb_0000000002"),
            		
            	array(// @Team Volley #teamVolleygirls
            		'user_id' => "2394", 
            		'subject_id' => "1370", 
            		'img_prefix' => "https://hotornot-challenges.s3.amazonaws.com/fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffb_0000000003")
            );
            $snap_arr = array( $snap_arr[ array_rand( $snap_arr ) ] );
			/*
            $snap_arr = array(
				array(// @jason #bestFriend
					'user_id' => "2393", 
					'subject_id' => "9", 
					'img_prefix' => "https://hotornot-challenges.s3.amazonaws.com/fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc_0000000000"),
				array(// @tyler #snapAtMe
					'user_id' => "2394", 
					'subject_id' => "753", 
					'img_prefix' => "https://hotornot-challenges.s3.amazonaws.com/fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffb_0000000002"), 
				array(// @psy #me
					'user_id' => "2392", 
					'subject_id' => "28", 
					'img_prefix' => "https://hotornot-challenges.s3.amazonaws.com/ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff_0000000001") 
			);
			*/
            
			// loop thru user/snap array
			foreach ($snap_arr as $key => $val) {
				
				// add initial challenges
				$query = 'INSERT INTO `tblChallenges` (';
				$query .= '`id`, `status_id`, `subject_id`, `creator_id`, `creator_img`, `challenger_id`, `challenger_img`, `hasPreviewed`, `votes`, `started`, `added`) ';
				$query .= 'VALUES (NULL, "2", "'. $val['subject_id'] .'", "'. $val['user_id'] .'", "'. $val['img_prefix'] .'", "'. $user_id .'", "", "N", "0", NOW(), NOW());';
				$result = mysql_query($query);
				$challenge_id = mysql_insert_id();
			}		
		}
		
		// return
		$user_arr = $this->userObject($user_id);
		return $user_arr;
	}
	
	/**
	 * Updates a user's name and avatar image
	 * @param $user_id The user's id (integer)
	 * @param $username The new username (string)
	 * @param $img_url The url to the avatar (string)
	 * @return An associative object representing a user (array)
	**/
	public function updateUsernameAvatar($user_id, $username, $img_url) {
		$this->dbConnect();
	    
		$query = 'UPDATE `tblUsers` SET `username` = "'. $username .'", `img_url` = "'. $img_url .'", `last_login` = CURRENT_TIMESTAMP WHERE `id` = '. $user_id .';';
		$result = mysql_query($query);
		
		// return
		$user_arr = $this->userObject($user_id);
		return $user_arr;
	}
	
	/**
	 * Updates a user's Facebook credentials
	 * @param $user_id The ID for the user (integer)
	 * @param $username The facebook username (string)
	 * @param $fb_id The user's facebook ID (string)
	 * @param $gender The gender according to facebook (string) 
	 * @return An associative object representing a user (array)
	**/
	public function updateFB($user_id, $username, $fb_id, $gender) {
		
		// get user info
		$query = 'SELECT `last_login`, `added` FROM `tblUsers` WHERE `id` = '. $user_id .';';
		$user_obj = mysql_fetch_object(mysql_query($query));
		
		// declare mail result
		$mail_result = -1;
		
		// first time logged in, send email
		if (strtotime($user_obj->last_login) == strtotime($user_obj->added)) {
			$mail_result = $this->fbEmail($username, "Lorem ipsum sit dolar amat!!");
			$query = 'UPDATE `tblUsers` SET `username` = "'. $username .'", `fb_id` = "'. $fb_id .'", `gender` = "'. $gender .'" WHERE `id` ='. $user_id .';';
			
		} else
			$query = 'UPDATE `tblUsers` SET `fb_id` = "'. $fb_id .'", `gender` = "'. $gender .'" WHERE `id` = '. $user_id .';';
		
		$result = mysql_query($query);
		
		
		// check to see if is an invited user
		$query = 'SELECT `id` FROM `tblInvitedUsers` WHERE `fb_id` = "'. $fb_id .'";';
		$invite_result = mysql_query($query);
		if (mysql_num_rows($invite_result) > 0) {
			$invite_id = mysql_fetch_object($invite_result)->id;
			
			// get any pending challenges for this invited user
			$query = 'SELECT `id` FROM `tblChallenges` WHERE `status_id` = 7 AND `challenger_id` = '. $invite_id .';';
			$invite_result = mysql_query($query);
		
			// loop thru the challenges
			while ($challenge_row = mysql_fetch_array($invite_result, MYSQL_BOTH)) {
				
				// update challenge w/ new user id and status
				$query = 'UPDATE `tblChallenges` SET `status_id` = 2, `challenger_id` = "'. $user_id .'" WHERE `id` = '. $challenge_row['id'] .';';
				$result = mysql_query($query);
			}
		}
		
		// return
		$user_arr = $this->userObject($user_id, $mail_result);
		return $user_arr;
	}
	
	/**
	 * Updates a user's name
	 * @param $user_id The ID for the user (integer)
	 * @param $username The desired username (string)
	 * @return An associative object representing a user (array)
	**/
	public function updateName($user_id, $username) {
		$this->dbConnect();
	    
		// check for an already taken name			
		$query = 'SELECT `id` FROM `tblUsers` WHERE `username` = "'. $username .'" AND `id` != '. $user_id .';';
		$user_result = mysql_query($query);
		
		// not found
		if (mysql_num_rows($user_result) == 0) {
			
			// update the user's name
			$query = 'UPDATE `tblUsers` SET `username` = "'. $username .'" WHERE `id` = '. $user_id .';';
			$result = mysql_query($query);
			
			// get user info				
			$user_arr = $this->userObject($user_id);
		
		// couldn't update	
		} else
			$user_arr = array('result' => "fail");
		
		
		// return
		return $user_arr;
	}
	
	/**
	 * Updates a user's account to (non)premium
	 * @param $user_id The ID for the user (integer)
	 * @param $isPaid Y/N whether or not it's a premium account (string) 
	 * @return An associative object representing a user (array)
	**/
	public function updatePaid($user_id, $isPaid) {
		$this->dbConnect();
	    
		// update user
		$query = 'UPDATE `tblUsers` SET `paid` = "'. $isPaid .'" WHERE `id` = '. $user_id .';';
		$result = mysql_query($query);
				   
		// return
		$user_arr = $this->userObject($user_id);
		return $user_arr;
	}
	
	/**
	 * Gets a user
	 * @param $user_id The ID for the user (integer)
	 * @return An associative object representing a user (array)
	**/
	public function getUserObj($user_id) {
		
		// get user & return
		$user_arr = $this->userObject($user_id);			
		return $user_arr;
	}
	
	/**
	 * Gets a user by username
	 * @param $username The name for the user (string)
	 * @return An associative object representing a user (array)
	**/
	public function getUserFromName($username) {
		$this->dbConnect();
	    
		$query = 'SELECT `id` FROM `tblUsers` WHERE `username` = "'. $username .'";';
		$user_id = mysql_fetch_object(mysql_query($query))->id;
		
		// get user & return
		$user_arr = $this->userObject($user_id);			
		return $user_arr;
	}
	
	/**
	 * Updates a user's push notification prefs
	 * @param $user_id The ID for the user (integer)
	 * @param $isNotifications Y/N whether or not to allow pushes (string) 
	 * @return An associative object representing a user (array)
	**/
	public function updateNotifications($user_id, $isNotifications) {
		$this->dbConnect();
	    $user_arr = array();
		
		// update user
		$query = 'UPDATE `tblUsers` SET `notifications` = "'. $isNotifications .'" WHERE `id` = '. $user_id .';';
		$result = mysql_query($query);
		
		// return
		$user_arr = $this->userObject($user_id);			
		return $user_arr;
	}
	
	/**
	 * Pokes a user
	 * @param $poker_id The ID for the user doing the poking (integer)
	 * @param $pokee_id The ID for the user getting poked (integer)
	 * @return An associative object representing a user (array)
	**/
	public function pokeUser($poker_id, $pokee_id) {
		$this->dbConnect();
	    
		// add a record to the poke table
		$query = 'INSERT INTO `tblUserPokes` (';
		$query .= '`id`, `user_id`, `poker_id`, `added`) ';
		$query .= 'VALUES (NULL, "'. $pokee_id .'", "'. $poker_id .'", NOW());';
		$result = mysql_query($query);
		$poke_id = mysql_insert_id();
		
		// get the user who poked
		$query = 'SELECT `username` FROM `tblUsers` WHERE `id` = '. $poker_id .';';
		$poker_name = mysql_fetch_object(mysql_query($query))->username;
		
		// get the user who got poked
		$query = 'SELECT `device_token`, `notifications` FROM `tblUsers` WHERE `id` = '. $pokee_id .';';
		$pokee_obj = mysql_fetch_object(mysql_query($query));			
		
		// send push if allowed
		if ($pokee_obj->notifications == "Y"){
            $msg = "@$poker_name has poked you!";
			$push = array(
		    	"device_tokens" =>  array( $pokee_obj->device_token ), 
		    	"type" => "2", 
		    	"aps" =>  array(
		    		"alert" =>  $msg,
		    		"sound" =>  "push_01.caf"
		        )
		    );
    	    BIM_Push_UrbanAirship_Iphone::sendPush( $push );
		}
		return array(
			'id' => $poke_id
		);
	}
	
	/** 
	 * Flags the challenge for abuse / inappropriate content
	 * @param $user_id The user's ID who is claiming abuse (integer)
	 * @param $challenge The ID of the challenge to flag (integer)
	 * @return An associative object (array)
	**/
	public function flagUser ($user_id) {
		$this->dbConnect();
	    // get this user's name
		$query = 'SELECT `username` FROM `tblUsers` WHERE `id` = '. $user_id .';';
		$user_obj = mysql_fetch_object(mysql_query($query));
					
		// send email
		$to = "bim.picchallenge@gmail.com";
		$subject = "Flagged User";
		$body = "User ID: #". $user_id ."\nUsername: #". $user_obj->username;
		$from = "picchallenge@builtinmenlo.com";
		
		$headers_arr = array();
		$headers_arr[] = "MIME-Version: 1.0";
		$headers_arr[] = "Content-type: text/plain; charset=iso-8859-1";
		$headers_arr[] = "Content-Transfer-Encoding: 8bit";
		$headers_arr[] = "From: {$from}";
		$headers_arr[] = "Reply-To: {$from}";
		$headers_arr[] = "Subject: {$subject}";
		$headers_arr[] = "X-Mailer: PHP/". phpversion();

		if (mail($to, $subject, $body, implode("\r\n", $headers_arr))) 
		   $mail_res = true;

		else
		   $mail_res = false;  
		
		// return
		return array(
			'id' => $user_id,
			'mail' => $mail_res
		);
	}
	
	/**
	 * 
	 * This is the function that allows us to find friends
	 * 
	 * first we look to see if we have a contact list for this user
	 * if we do, then we update the current list by merging the hashed_list together
	 * if we do not, then we add a document to the contact_lists index
	 * 
	 * Then we execute a search with the passed hashed list and the hashed number of we have it 
	 * and process the results for return to the client
	 * this might also include a bit of user data from memcache.
	 * 
	 * @param stdClass $params with properties as follows
	 * 		hashed_number => the hasjed phone n umber of the volley user
	 * 		hashed_list => the list of hashed phone numbers from the volley user's contact list
	 * 		user_id - the id of the volley user
	 */
	
	public function matchFriends( $params ){
	    $list = $this->addPhoneList($params);
	    return $this->findfriends($list);
	}
	
	public function matchFriendsEmail( $params ){
	    $list = $this->addEmailList($params);
	    return $this->findfriendsEmail($list);
	}
	
	public function findfriends( $list ){
	    $dao = new BIM_DAO_ElasticSearch_ContactLists( BIM_Config::elasticSearch() );
	    $matches = $dao->findFriends( $list );
	    $matches = json_decode($matches);
	    if( isset( $matches->hits->hits ) && is_array($matches->hits->hits) ){
	        $matches = &$matches->hits->hits;
	        foreach( $matches as &$match ){
	            $match = $match->fields->_source;
                $user = self::getUser( $match->id );
                $match->username = $user->username;
	        }
	    }
	    return $matches;
	}
	
	public function findfriendsEmail( $list ){
	    $dao = new BIM_DAO_ElasticSearch_ContactLists( BIM_Config::elasticSearch() );
	    $matches = $dao->findFriendsEmail( $list );
	    $matches = json_decode($matches);
	    if( isset( $matches->hits->hits ) && is_array($matches->hits->hits) ){
	        $matches = &$matches->hits->hits;
	        foreach( $matches as &$match ){
	            $match = $match->fields->_source;
	        }
	    }
	    return $matches;
	}
	
	public function addPhoneList( $list ){
	    $dao = new BIM_DAO_ElasticSearch_ContactLists( BIM_Config::elasticSearch() );
	    
	    if( isset( $list->id ) && $list->id ){
            if(! isset( $list->hashed_number ) ) $list->hashed_number = '';
            if(! isset( $list->hashed_list ) ) $list->hashed_list = array();
    	    
            $user = new BIM_User( $list->id );
            if( $user->isExtant() ){
                $list->avatar_url = $user->getAvatarUrl();
                $list->username = $user->username;
                // if we do not add the list
                // then this means the list already existed
                // so we update the list with the data we have been passed
        	    $added = $dao->addPhoneList( $list );
        	    if( !$added ){
        	        $dao->updatePhoneList( $list );
            	    $list = $dao->getPhoneList( $list );
            	    $list = json_decode( $list );
            	    if( isset( $list->exists ) && $list->exists ){
            	        $list = $list->_source;
            	    }
        	    }
            }
	    }
	    
	    return $list;
	}
	
	public function addEmailList( $list ){
	    $dao = new BIM_DAO_ElasticSearch_ContactLists( BIM_Config::elasticSearch() );
	    
	    if( isset( $list->id ) && $list->id ){
            if(! isset( $list->email ) ) $list->email = '';
            if(! isset( $list->email_list ) ) $list->email_list = array();
    	    
            $user = new BIM_User( $list->id );
            if( $user->isExtant() ){
                $list->avatar_url = $user->getAvatarUrl();
                $list->username = $user->username;
                // if we do not add the list
                // then this means the list already existed
                // so we update the list with the data we have been passed
        	    $added = $dao->addEmailList( $list );
        	    if( !$added ){
        	        $dao->updateEmailList( $list );
            	    $list = $dao->getEmailList( $list );
            	    $list = json_decode( $list );
            	    if( isset( $list->exists ) && $list->exists ){
            	        $list = $list->_source;
            	    }
        	    }
            }
	    }
	    
	    return $list;
	}
	
	
	/**
	 * 
	 * we receive an object structure similar to that of twili's callback structure
	 * and we link our volley user with the mobile number if possible
	 * and we also add a phone document to our contact_lists search index 
	 * 
           [AccountSid] => ACb76dc4d9482a77306bc7170a47f2ea47
            [Body] => 23ru3tyu25
            [ToZip] => 34109
            [FromState] => CA
            [ToCity] => NAPLES
            [SmsSid] => SM99ff3fe1a4c5e8f17d57abb813f587c0
            [ToState] => FL
            [To] => +12394313268
            [ToCountry] => US
            [FromCountry] => US
            [SmsMessageSid] => SM99ff3fe1a4c5e8f17d57abb813f587c0
            [ApiVersion] => 2010-04-01
            [FromCity] => SAN FRANCISCO
            [SmsStatus] => received
            [From] => +14152549391
            [FromZip] => 94930
	 * 
	 * 
	 * first we get the code sent with the message.  
	 * our code will always be prefixed with an upper case or lowercase 'c', 
	 * followed by some digits. followed by a unique string of 13 chars
	 * 
	 * for example: c1251cc4c72b4ee8
	 * 
	 * once we successfully have the code, we get the user associated with it
	 * 
	 * if we siccessfully retrieve the user
	 * 		we hash the number 
	 * 		add a contact list for the user, including the unhashed number
	 * 		mark the user as sms verified in the db
	 * 
	 * @param array $params
	 */
	public function linkMobileNumber( $params ){
	    $linked = false;
	    $c = BIM_Config::sms();
	    
	    $matches = array();
	    preg_match( $c->code_pattern, $params->Body, $matches );
	    $code = isset( $matches[1] ) ? $matches[1] : null;
	    
	    if( $code ){
	        $userId = BIM_Utils::getIdForSMSCode($code);
	        $user = new BIM_User( $userId );
    	    if( $user->isExtant() ){
    	        $avatarUrl = $this->avatarURLForUser( $user );
    	        $list = (object) array(
    	            'hashed_number' => BIM_Utils::hashMobileNumber( $params->From ),
    	            'hashed_list' => array(),
    	            'id' => $user->id,
    	            'avatar_url' => $avatarUrl,
    	            'username' => $user->username,
    	        );
    	        $linked = $this->addPhoneList( $list );
    	        if( $linked ){
    	            BIM_Jobs_Users::queueFindFriends($list);
    	        }
    	    }
	    }
	    return $linked;
	}
	
	public function inviteInsta( $params ){
        BIM_Jobs_Webstagram::queueInstaInvite($params);
        BIM_Jobs_Instagram::queueLinkInBio($params);
	}
	
	public function inviteTumblr( $params ){
	    BIM_Jobs_Tumblr::queueInvite($params);
	}
	
	public function verifyEmail( $params ){
	    $verified = false;
	    if( filter_var($params->email, FILTER_VALIDATE_EMAIL) ){
	        $list = (object) array(
	            'id' => $params->user_id,
	            'email' => $params->email
	        );
	        $this->addEmailList($list);
            BIM_Jobs_Growth::queueEmailVerifyPush($params);
            $verified = true;
	    }
	    return $verified;
	}
	
	public function verifyPhone( $params ){
	    $verified = false;
	    $phone = trim( $params->phone );
	    if( preg_match('@^\+{0,1}\d+$@', $phone ) ){
	        $list = (object) array(
	            'id' => $params->user_id,
	            'hashed_number' => $phone
	        );
	        $this->addPhoneList($list);
            BIM_Jobs_Growth::queueEmailVerifyPush($params);
            $verified = true;
	    }
	    return $verified;
	}
	
    public function setAge( $userId, $ageRange ){
        $user = new BIM_User( $userId );
        if( $user->isExtant() ){
            $user->setAgeRange( $ageRange );
        }
        return $this->userObject( $userId );
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

