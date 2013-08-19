<?php

class BIM_Controller_Users extends BIM_Controller_Base {
    
    public function flagUser(){
        $input = (object) ($_POST ? $_POST : $_GET);
        if ( !empty( $input->userID ) && property_exists($input, 'approves' ) && !empty( $input->targetID ) ){
            $users = new BIM_App_Users();
		    return $users->flagUser( $input->userID, $input->approves, $input->targetID );
		}
		return array();
    }
    
    public function updateUsernameAvatar(){
        $input = (object) ($_POST ? $_POST : $_GET);
        if (!empty($input->userID) && !empty($input->username) && !empty($input->imgURL) ){
            $userId = $this->resolveUserId( $input->userID );
            $birthdate = !empty( $input->age ) ? $input->age : null;
            if( !$birthdate || ($birthdate && BIM_Utils::ageOK( $birthdate ) ) ){
                $users = new BIM_App_Users();
                if( !empty( $input->firstRun ) ){
                    $users->firstRunComplete($userId);
                }
			    return $users->updateUsernameAvatar($userId, $input->username, $input->imgURL, $birthdate );
            }
		}
		return false;
    }
    
    public function firstRunComplete(){
        $input = (object) ($_POST ? $_POST : $_GET);
        if (!empty($input->userID) && !empty($input->username) && !empty($input->imgURL) && !empty( $input->age ) ){
            $userId = $this->resolveUserId( $input->userID );
            if( BIM_Utils::ageOK( $input->age ) ){
                $users = new BIM_App_Users();
                $users->firstRunComplete($userId);
			    return $users->updateUsernameAvatar($userId, $input->username, $input->imgURL, $input->age );
            }
		}
		return false;
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
            $users = new BIM_App_Users();
		    return $users->updateName($input->userID, $input->username);
		}
		return array();
    }
    
    public function pokeUser(){
        $input = (object) ($_POST ? $_POST : $_GET);
        if (isset($input->pokerID) && isset($input->pokeeID)){
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
            $users = new BIM_App_Users();
		    return $users->updateNotifications($input->userID, $input->isNotifications);
		}
		return array();
    }
    
    public function updatePaid(){
        $input = (object) ($_POST ? $_POST : $_GET);
        if (isset($input->userID) && isset($input->isPaid)){
            $users = new BIM_App_Users();
		    return $users->updatePaid($input->userID, $input->isPaid);
        }
		return array();
    }
    
    public function updateFB(){
        $input = (object) ($_POST ? $_POST : $_GET);
        if (isset($input->userID) && isset($input->username) && isset($input->fbID) && isset($input->gender)){
            $users = new BIM_App_Users();
		    return $users->updateFB($input->userID, $input->username, $input->fbID, $input->gender);
		}
		return array();
    }
    
    public function submitNewUser(){
        $input = (object) ($_POST ? $_POST : $_GET);
        if (isset($input->token)){
            $users = new BIM_App_Users();
    	    return $users->submitNewUser($input->token);
    	}
		return array();
    }
    
    public function matchFriends(){
        $input = (object) ($_POST ? $_POST : $_GET);
        $friends = array();
		if ( isset( $input->userID ) && isset( $input->phone ) ){
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
            $users = new BIM_App_Users();
            $users->setAge( $input->userID, $input->age );
            return true;
        }
        return false;
    }
}
