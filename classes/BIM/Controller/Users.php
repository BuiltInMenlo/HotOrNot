<?php

class BIM_Controller_Users extends BIM_Controller_Base {
    
    public function flagUser(){
        $input = (object) ($_POST ? $_POST : $_GET);
        if ( !empty( $input->userID ) && property_exists($input, 'approves' ) && !empty( $input->targetID ) ){
            $input->userID = $this->resolveUserId( $input->userID );
            $users = new BIM_App_Users();
		    BIM_Jobs_Users::queueFlagUser( $input->userID, $input->approves, $input->targetID );
    		return array(
    			'id' => $input->userID,
    			'mail' => true
    		);
		}
		return array();
    }
    
    public function updateUsernameAvatar(){
        $input = (object) ($_POST ? $_POST : $_GET);
        if (!empty($input->userID) && !empty($input->username) && !empty($input->imgURL) ){
    	    $existingUser = BIM_Model_User::getByUsername( $input->username );
            $userId = $this->resolveUserId( $input->userID );
    	    if (  ! $existingUser || ! $existingUser->isExtant() || $existingUser->id == $userId ) {
                $input->imgURL = $this->normalizeAvatarImgUrl($input->imgURL);
                $users = new BIM_App_Users();
			    return $users->updateUsernameAvatar($userId, $input->username, $input->imgURL);
    	    }
		}
		return false;
    }
    
    public function firstRunComplete(){
        $input = (object) ($_POST ? $_POST : $_GET);
    	$result = (object) array('result' => "fail");
        if (!empty($input->userID) && !empty($input->username) && !empty($input->imgURL) && !empty( $input->age ) && !empty( $input->password ) ){
            $input->email = $input->password;
            unset( $input->password );
            $existingUser = BIM_Model_User::getByUsername( $input->username );
            $userId = $this->resolveUserId( $input->userID );
            $result = self::usernameOrEmailExists($input);
            if ( !$result  || $existingUser->id == $userId ) {
                $input->imgURL = $this->normalizeAvatarImgUrl($input->imgURL);
                $device_token = empty($input->token) ? '' : $input->token;
                $users = new BIM_App_Users();
			    $result = $users->updateUsernameAvatarFirstRun($userId, $input->username, $input->imgURL, $input->age, $input->email, true, $device_token );
                self::friendTeamVolley($userId);
                //BIM_Jobs_Users::queueFirstRunComplete($userId);
            }
		}
		return $result;
    }
    
    public function checkNameAndEmail(){
        $result = null;
        $input = (object) ($_POST ? $_POST : $_GET);
        if ( !empty($input->userID) && !empty($input->username) && !empty( $input->password ) ){
            $input->email = $input->password;
            unset( $input->password );
            $result = self::usernameOrEmailExists($input);
    	    $existingUser = BIM_Model_User::getByUsername( $input->username );
            $userId = $this->resolveUserId( $input->userID );
            if ( !$result  || $existingUser->id == $userId ) {
                $users = new BIM_App_Users();
                $result = $users->updateUsernameAvatarFirstRun($userId, $input->username, '', -1, $input->email, false, BIM_Utils::getDeviceToken() );
                $result = (object) array('result' => 0 );
            }
        }
        return $result;
    }
    
    protected function usernameOrEmailExists( $input ){
        $result = BIM_Model_User::usernameOrEmailExists($input);
        if( $result ){
            if( !empty($result->email) && !empty($result->username) ){
    	        $result = (object) array('result' => 3 );
            } else if( !empty($result->email) ){
    	        $result = (object) array('result' => 2 );
            } else if( !empty($result->username) ){
    	        $result = (object) array('result' => 1 );
            } else {
    	        $result = null;
            }
        }
        return $result;
    }    
    
    public static function friendTeamVolley( $userId ){
        // have @teamvolley friend the new user	
        $conf = BIM_Config::app();
        if( !empty( $conf->auto_subscribes ) ){
            foreach( $conf->auto_subscribes as $target ){
        		$friendRelation = (object) array( 
        			'target' => $target, 
        			'userID' => $userId,
        		);
        		BIM_App_Social::addFriend($friendRelation);
            }
        }
    }
    
    public function getUserFromName(){
        $input = (object) ($_POST ? $_POST : $_GET);
        if (isset($input->username)){
            $users = new BIM_App_Users();
		    return $users->getUserFromName($input->username);
		}
		return array();
    }
    
    public function updateName(){
        $input = (object) ($_POST ? $_POST : $_GET);
        if (isset($input->userID) && isset($input->username)){
            $input->userID = $this->resolveUserId( $input->userID );
            $users = new BIM_App_Users();
		    return $users->updateName($input->userID, $input->username);
		}
		return false;
    }
    
    public function pokeUser(){
        $input = (object) ($_POST ? $_POST : $_GET);
        if (isset($input->pokerID) && isset($input->pokeeID)){
            $input->pokerID = $this->resolveUserId( $input->pokerID );
            $users = new BIM_App_Users();
		    return $users->pokeUser($input->pokerID, $input->pokeeID);
		}
		return array();
    }
    
    public function getUser(){
        $input = (object) ($_POST ? $_POST : $_GET);
        if (isset($input->userID)){
            $users = new BIM_App_Users();
            return $users->getUserObj($input->userID);
        }
		return array();
    }
    
    public function updateNotifications(){
        $input = (object) ($_POST ? $_POST : $_GET);
        if (isset($input->userID) && isset($input->isNotifications)){
            $input->userID = $this->resolveUserId( $input->userID );
            $users = new BIM_App_Users();
		    return $users->updateNotifications($input->userID, $input->isNotifications);
		}
		return array();
    }
    
    public function updatePaid(){
        $input = (object) ($_POST ? $_POST : $_GET);
        if (isset($input->userID) && isset($input->isPaid)){
            $input->userID = $this->resolveUserId( $input->userID );
            $users = new BIM_App_Users();
		    return $users->updatePaid($input->userID, $input->isPaid);
        }
		return array();
    }
    
    public function updateFB(){
        $input = (object) ($_POST ? $_POST : $_GET);
        if (isset($input->userID) && isset($input->username) && isset($input->fbID) && isset($input->gender)){
            $input->userID = $this->resolveUserId( $input->userID );
            $users = new BIM_App_Users();
		    return $users->updateFB($input->userID, $input->username, $input->fbID, $input->gender);
		}
		return array();
    }
    
    public function submitNewUser(){
        $users = new BIM_App_Users();
	    return $users->submitNewUser();
    }
    
    public function matchFriends(){
        $input = (object) ($_POST ? $_POST : $_GET);
        $friends = array();
		if ( isset( $input->userID ) && isset( $input->phone ) ){
            $input->userID = $this->resolveUserId( $input->userID );
		    $hashedList = explode('|', $input->phone );
		    $params = (object) array(
		        'id' => $input->userID,
		    	'hashed_list' => $hashedList,
		    );
		    $users = new BIM_App_Users();
			$friends = $users->matchFriends( $params );
			
		}
		return $friends;
    }
    
    public function twilioCallback(){
        $input = (object) ($_POST ? $_POST : $_GET);
        $users = new BIM_App_Users();
        $linked = $users->linkMobileNumber( (object) $_POST );
        if( $linked ){
            $to = $input->From; // we switch the meaning of to and from so we can send an sms back
            $from = $input->To; // we switch the meaning of to and from so we can send an sms back
            echo "<?xml version='1.0' encoding='UTF-8'?><Response><Sms from='$from' to='$to'>Volley On!</Sms></Response>";
            exit();
        }
    }
    
    public function inviteInsta(){
        $input = (object) ($_POST ? $_POST : $_GET);
		if ( !empty( $input->instau ) && !empty( $input->instap ) && !empty( $input->userID ) ){
            $input->userID = $this->resolveUserId( $input->userID );
		    $params = (object) array(
		        'username' => $input->instau,
		        'password' => $input->instap,
		        'volley_user_id' => $input->userID, 
		    );
		    $users = new BIM_App_Users();
			$users->inviteInsta( $params );
		}
		return true;
    }
    
    public function inviteTumblr(){
        $input = (object) ($_POST ? $_POST : $_GET);
		if ( !empty( $input->u ) && !empty( $input->p ) && !empty( $input->userID ) ){
            $input->userID = $this->resolveUserId( $input->userID );
		    $params = (object) array(
		        'username' => $input->u,
		        'password' => $input->p,
		        'volley_user_id' => $input->userID,
		    );
		    $users = new BIM_App_Users();
			$users->inviteTumblr( $params );
		}
		return true;
    }
    
    public function verifyEmail(){
        $v = false;
        $input = (object) ($_POST ? $_POST : $_GET);
		if ( !empty( $input->userID ) && !empty( $input->email ) ){
            $input->userID = $this->resolveUserId( $input->userID );
		    $params = (object) array(
		        'user_id' => $input->userID,
		        'email' => $input->email ,
		    );
            $users = new BIM_App_Users();
		    $v = $users->verifyEmail( $params );
		}
		return $v;
    }
    
    public function ffEmail(){
        $input = (object) ($_POST ? $_POST : $_GET);
	    $friends = array();
		if ( !empty( $input->userID ) && !empty( $input->emailList ) ){
            $input->userID = $this->resolveUserId( $input->userID );
		    $emailList = explode('|', $input->emailList );
		    $params = (object) array(
		        'id' => $input->userID,
		        'email_list' => $emailList,
		    );
            $users = new BIM_App_Users();
		    $friends = $users->matchFriendsEmail( $params );
		}
		return $friends;
    }
    
    public function verifyPhone(){
        $v = false;
        $input = (object) ($_POST ? $_POST : $_GET);
        if ( !empty( $input->code ) && !empty( $input->phone ) ){
            $userId = BIM_Utils::getIdForSMSCode($input->code);
		    $params = (object) array(
		        'user_id' => $userId,
		        'phone' => $input->phone,
		    );
            $users = new BIM_App_Users();
		    $v = $users->verifyPhone( $params );
		}
		return $v;
    }
    
    public function setAge( ){
        $input = ( object ) ($_POST ? $_POST : $_GET);
        if( !empty( $input->userID ) && property_exists( $input, 'age' ) ){
            $input->userID = $this->resolveUserId( $input->userID );
            $users = new BIM_App_Users();
            $users->setAge( $input->userID, $input->age );
            return true;
        }
        return false;
    }
    
    public function getSubscribees( ){
        $input = (object) ($_POST ? $_POST : $_GET);
        if( !empty( $input->userID ) ){
            // $input->userID = $this->resolveUserId( $input->userID );
            return BIM_App_Social::getFollowed( $input );
        }
        return array();
    }
    
    public function processImage(){
        $input = (object) ($_POST ? $_POST : $_GET);
        if( !empty( $input->imgURL ) ){
            BIM_Jobs_Users::queueProcessImage( $input->imgURL );
        }
        return true;
    }
    
    public function purge(){
        $input = (object) ($_POST ? $_POST : $_GET);
        $user = BIM_Utils::getSessionUser();
        if( $user && $user->isExtant() && !$user->isSuspended() ){
            BIM_Model_User::archiveUser($user->id);
        }
        return true;
    }
    
    public function purgeContent(){
        $input = (object) ($_POST ? $_POST : $_GET);
        $user = BIM_Utils::getSessionUser();
        if( $user && $user->isExtant() ){
            $user->purgeContent();
        }
        return true;
    }
}
