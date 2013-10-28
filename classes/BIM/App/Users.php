<?php

require_once 'BIM/App/Base.php';

class BIM_App_Users extends BIM_App_Base{

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
	public function submitNewUser() {
	    $user = BIM_Model_User::getByToken( BIM_Utils::getAdvertisingId() );
		if ( $user && $user->isExtant() ) {
		    $user->updateLastLogin();
		    if( empty( $user->adid ) ){
		        $user->setAdvertisingId( BIM_Utils::getAdvertisingId() );
		    }
		} else {
		    // historically, we were passing the device token at this point 
		    // but it has been removed so we pass null to the create function
			$user = BIM_Model_User::create( BIM_Utils::getAdvertisingId() );
		}
        return $user;
	}
	
	/**
	 * Updates a user's name and avatar image
	 * @param $user_id The user's id (integer)
	 * @param $username The new username (string)
	 * @param $img_url The url to the avatar (string)
	 * @return An associative object representing a user (array)
	**/
	public function updateUsernameAvatar($userId, $username, $imgUrl, $birthdate = null, $email = null, $createVerifyVolley = true ) {
        $user = BIM_Model_User::get($userId);
        $user->updateUsernameAvatar( $username, $imgUrl, $birthdate, $email  );
        if( $createVerifyVolley ){
            BIM_Model_Volley::addVerifVolley($userId, $imgUrl); // will create a verify volley if one does not yet exist
        }
        return $user;
	}
	
	/**
	 * Updates a user's name and avatar image
	 * @param $user_id The user's id (integer)
	 * @param $username The new username (string)
	 * @param $img_url The url to the avatar (string)
	 * @return An associative object representing a user (array)
	**/
	public function updateUsernameAvatarFirstRun( $userId, $username, $imgUrl, $birthdate = null, $email = null, $createVerifyVolley = true, $deviceToken = '' ) {
        $user = BIM_Model_User::get($userId);
        $user->updateUsernameAvatarFirstRun( $username, $imgUrl, $birthdate, $email, $deviceToken  );
        if( $createVerifyVolley ){
            BIM_Model_Volley::addVerifVolley($userId, $imgUrl); // will create a verify volley if one does not yet exist
        }
        return BIM_Model_User::get( $userId );
	}
	
	/**
	 * Updates a user's Facebook credentials
	 * @param $user_id The ID for the user (integer)
	 * @param $username The facebook username (string)
	 * @param $fb_id The user's facebook ID (string)
	 * @param $gender The gender according to facebook (string) 
	 * @return An associative object representing a user (array)
	**/
	public function updateFB($userId, $username, $fbId, $gender) {
		
        $user = BIM_Model_User::get( $userId );		
		
		if (strtotime($user->last_login) == strtotime($user->added)) {
		    // first time logged in, send email
		    $this->fbEmail($username, "Lorem ipsum sit dolar amat!!");
			$user->updateFBUsername( $fbId, $username, $gender );
		} else {
			$user->updateFB( $fbId, $gender );
		}
		
		// check to see if is an invited user
		$inviteId = $user->getFBInviteId( $fbId );
		
		if ( $inviteId ) {
		    $user->acceptFbInviteToVolley( $inviteId );
		}
		
        return BIM_Model_User::get($userId);
	}
	
	/**
	 * Updates a user's name
	 * @param $user_id The ID for the user (integer)
	 * @param $username The desired username (string)
	 * @return An associative object representing a user (array)
	**/
	public function updateName($userId, $username) {
		$user = (object) array('result' => "fail");
	    $existingUser = BIM_Model_User::getByUsername($username);
		if ( !$existingUser || !$existingUser->isExtant() || $existingUser->id == $userId ) {
            $user = BIM_Model_User::get($userId);
            $user->updateUsername( $username );
		}
        return $user;
	}
	
	/**
	 * Updates a user's account to (non)premium
	 * @param $user_id The ID for the user (integer)
	 * @param $isPaid Y/N whether or not it's a premium account (string) 
	 * @return An associative object representing a user (array)
	**/
	public function updatePaid( $userId, $isPaid ) {
	    $user = BIM_Model_User::get($userId);
		if ( $user->isExtant() ) {
            $user->updatePaid( $isPaid );
		}
        return $user;
	}
	
	/**
	 * Gets a user
	 * @param $user_id The ID for the user (integer)
	 * @return An associative object representing a user (array)
	**/
	public function getUserObj($user_id) {
		$user = BIM_Model_User::get($user_id);
		return $user;
	}
	
	/**
	 * Gets a user by username
	 * @param $username The name for the user (string)
	 * @return An associative object representing a user (array)
	**/
	public function getUserFromName($username) {
        return BIM_Model_User::getByUsername($username);
	}
	
	/**
	 * Updates a user's push notification prefs
	 * @param $user_id The ID for the user (integer)
	 * @param $isNotifications Y/N whether or not to allow pushes (string) 
	 * @return An associative object representing a user (array)
	**/
	public function updateNotifications($userId, $isNotifications) {
	    $user = BIM_Model_User::get($userId);
		if ( $user->isExtant() ) {
            $user->updateNotifications( $isNotifications );
		}
        return $user;
	}
	
	/**
	 * Pokes a user
	 * @param $poker_id The ID for the user doing the poking (integer)
	 * @param $pokee_id The ID for the user getting poked (integer)
	 * @return An associative object representing a user (array)
	**/
	public function pokeUser($pokerId, $targetId) {
	    $poker = BIM_Model_User::get( $targetId );
	    $pokeId = $poker->poke( $targetId );
	    $target = BIM_Model_User::get( $targetId );
		if ($pokeId && $target->canPush() ){
		    BIM_Push::pokePush($pokerId, $targetId);
		}
		return array(
			'id' => $pokeId
		);
	}
	
	/** 
	 * Flags the challenge for abuse / inappropriate content
	 * @param $user_id The user's ID who is claiming abuse (integer)
	 * @param $approves integer for inc / dec the abuse count
	 * @param $targetId - integer the id opf the allegedly abusive user
	 * 
	 * @return An associative object (array)
	**/
	public function flagUser ( $userId, $approves, $targetId ) {
    	$target = BIM_Model_User::get( $targetId );
    	$user = BIM_Model_User::get( $userId );
	    if( $target->isExtant() && $userId != $targetId ){
    	    $verifyVolley = BIM_Model_Volley::getVerifyVolley( $targetId );
    	    $approves = ($approves ? -1 : 1);
    	    $c = BIM_Config::app();
    	    if( $user->isSuperUser() ){
    	        $approves = ($approves * 10000);
    	    }
    	    // make sure the flagged user cannot 
    	    // upvote or downvote themselves
    	    $purge = false;
    	    if( $verifyVolley->isNotExtant() && $approves > 0 ){
    	        $purge = true;
                $verifyVolley = BIM_Model_Volley::createVerifyVolley( $targetId, 10 );
        	    $target->flag( $verifyVolley->id, $userId, $approves );
                BIM_Push::sendFlaggedPush($targetId);
                $this->sendFlaggedEmail($userId);
    	    } else if( $verifyVolley->isExtant() && !$verifyVolley->hasApproved($userId) ){
    	        $purge = true;
        	    $target->flag( $verifyVolley->id, $userId, $approves );
        	    if( $approves < 0 ){
        	        BIM_Push::sendApprovePush($targetId);
        	    } else if( $approves > 0 ){
                    BIM_Push::sendFlaggedPush($targetId);
        	    }
    	    }
    	    if( $purge ){
        	    $target->purgeFromCache();
        	    $user->purgeFromCache();
        	    $verifyVolley->purgeFromCache();
    	    }
	    }
	}
	
	protected function sendFlaggedEmail( $userId ){
		// send email
	    $user = BIM_Model_User::get( $userId );
        $to = "bim.picchallenge@gmail.com";
		$subject = "Flagged User";
		$body = "User ID: #". $userId ."\nUsername: #". $user->username;
		$from = "picchallenge@builtinmenlo.com";
		
		$headers = implode("\r\n", 
    		array(
        		"MIME-Version: 1.0",
        		"Content-type: text/plain, charset=iso-8859-1",
        		"Content-Transfer-Encoding: 8bit",
        		"From: {$from}",
        		"Reply-To: {$from}",
        		"Subject: {$subject}",
        		"X-Mailer: PHP/". phpversion(),
            )
        );
        
		mail($to, $subject, $body, $headers );
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
	    $friendMatches = $this->findfriends($list, true);
	    
	    $fParams = (object) array(
	        'userID' => $params->id,
	    );
	    $friendList = BIM_App_Social::getFriends($fParams, true);
	    
	    // filtering out users with which we are already friends
	    $friendIds = array_keys( $friendList );
	    $friendIds[] = $params->id;
	    $matchIds = array_keys( $friendMatches );
        $matches = array_diff($matchIds, $friendIds);
        
        foreach( $matches as &$user ){
            $user = $friendMatches[ $user ];
        }
        
        return array_values($matches);
	}
	
	public function matchFriendsEmail( $params ){
	    $list = $this->addEmailList($params);
	    return $this->findfriendsEmail($list);
	}
	
	public function findfriends( $list, $assoc = false ){
	    $dao = new BIM_DAO_ElasticSearch_ContactLists( BIM_Config::elasticSearch() );
	    $hits = $dao->findFriends( $list, $assoc );
	    $hits = json_decode($hits);
        $matches = array();
	    if( isset( $hits->hits->hits ) && is_array($hits->hits->hits) ){
	        $hits = &$hits->hits->hits;
	        foreach( $hits as $hit ){
	            $hit = $hit->fields->_source;
                $user = BIM_Model_User::get( $hit->id );
                if( $user->isExtant() ){
                    $hit->username = $user->username;
                    if( $assoc ){
                        $matches[ $hit->id ] = $hit;
                    } else {
                        $matches[] = $hit;
                    }
                }
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
	    if( isset( $list->id ) && $list->id ){
            if(! isset( $list->hashed_number ) ) $list->hashed_number = '';
            if(! isset( $list->hashed_list ) ) $list->hashed_list = array();
            
            if( $list->hashed_list ){
                BIM_Utils::hashList( $list->hashed_list );
            }
            if( $list->hashed_number ){
                $list->hashed_number = BIM_Utils::blowfishEncrypt($list->hashed_number);
            }
            
            $user = BIM_Model_User::get( $list->id );
            if( $user->isExtant() ){
                $list->avatar_url = $user->getAvatarUrl();
                $list->username = $user->username;
                // if we do not add the list
                // then this means the list already existed
                // so we update the list with the data we have been passed
	            $dao = new BIM_DAO_ElasticSearch_ContactLists( BIM_Config::elasticSearch() );
                $added = $dao->addPhoneList( $list );
        	    if( !$added ){
        	        $dao->updatePhoneList( $list );
            	    $list = $dao->getPhoneList( $list );
            	    $list = json_decode( $list );
            	    if( isset( $list->exists ) && $list->exists ){
            	        $list = $list->_source;
            	        if( !empty($list->hashed_number) ){
            	            $dao = new BIM_DAO_Mysql_User( BIM_Config::db() );
            	            $dao->setSmsVerified($list->id, 1);
            	        }
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
    	    
            if( $list->email_list ){
                BIM_Utils::hashList( $list->email_list );
            }
            if( $list->email ){
                $list->email = BIM_Utils::blowfishEncrypt($list->email);
            }
            
            $user = BIM_Model_User::get( $list->id );
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
	        $user = BIM_Model_User::get( $userId );
    	    if( $user->isExtant() ){
    	        $list = (object) array(
    	            'hashed_number' => $params->From,
    	            'hashed_list' => array(),
    	            'id' => $user->id,
    	            'avatar_url' => $user->getAvatarUrl(),
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
            BIM_Push::emailVerifyPush($params->user_id);
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
            BIM_Push::emailVerifyPush($params->user_id);
            $verified = true;
	    }
	    return $verified;
	}
	
    public function setAge( $userId, $ageRange ){
        $user = BIM_Model_User::get( $userId );
        if( $user->isExtant() ){
            $user->setAgeRange( $ageRange );
        }
        return BIM_Model_User::get( $userId );
    }
    
    public function firstRunComplete( $userId ){
        $user = BIM_Model_User::get( $userId );
        if( $user->isExtant() ){
            $approves = 0;
            if( ! $user->hasSelfie() ){
                $user->updateAbuseCount( 5 );
            } 
            
            /*
            if( ! $user->ageOK() ){
                // suspend them if not in correct age range
                $user->updateAbuseCount( 10000 );
            }
            */
        }
        return BIM_Model_User::get( $userId );
    }
}

