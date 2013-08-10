<?php

class BIM_Controller_Users extends BIM_Controller_Base {
    
    public function test(){
        $users = new BIM_App_Users();
        return $users->test();
    }
    
    public function flagUser(){
        $input = $_POST ? $_POST : $_GET;
        if (isset($input['userID'])){
            $users = new BIM_App_Users();
		    return $users->flagUser($input['userID']);
		}
		return array();
    }
    
    public function updateUsernameAvatar(){
        $input = $_POST ? $_POST : $_GET;
        if (isset($input['userID']) && isset($input['username']) && isset($input['imgURL'])){
            $users = new BIM_App_Users();
			return $users->updateUsernameAvatar($input['userID'], $input['username'], $input['imgURL']);
		}
		return array();
    }
    
    public function getUserFromName(){
        $input = $_POST ? $_POST : $_GET;
        if (isset($input['username'])){
            $users = new BIM_App_Users();
		    return $users->getUserFromName($input['username']);
		}
		return array();
    }
    
    public function updateName(){
        $input = $_POST ? $_POST : $_GET;
        if (isset($input['userID']) && isset($input['username'])){
            $users = new BIM_App_Users();
		    return $users->updateName($input['userID'], $input['username']);
		}
		return array();
    }
    
    public function pokeUser(){
        $input = $_POST ? $_POST : $_GET;
        if (isset($input['pokerID']) && isset($input['pokeeID'])){
            $users = new BIM_App_Users();
		    return $users->pokeUser($input['pokerID'], $input['pokeeID']);
		}
		return array();
    }
    
    public function getUser(){
        $input = $_POST ? $_POST : $_GET;
        if (isset($input['userID'])){
            $users = new BIM_App_Users();
            return $users->getUserObj($input['userID']);
        }
		return array();
    }
    
    public function updateNotifications(){
        $input = $_POST ? $_POST : $_GET;
        if (isset($input['userID']) && isset($input['isNotifications'])){
            $users = new BIM_App_Users();
		    return $users->updateNotifications($input['userID'], $input['isNotifications']);
		}
		return array();
    }
    
    public function updatePaid(){
        $input = $_POST ? $_POST : $_GET;
        if (isset($input['userID']) && isset($input['isPaid'])){
            $users = new BIM_App_Users();
		    return $users->updatePaid($input['userID'], $input['isPaid']);
        }
		return array();
    }
    
    public function updateFB(){
        $input = $_POST ? $_POST : $_GET;
        if (isset($input['userID']) && isset($input['username']) && isset($input['fbID']) && isset($input['gender'])){
            $users = new BIM_App_Users();
		    return $users->updateFB($input['userID'], $input['username'], $input['fbID'], $input['gender']);
		}
		return array();
    }
    
    public function submitNewUser(){
        $input = $_POST ? $_POST : $_GET;
        if (isset($input['token'])){
            $users = new BIM_App_Users();
    	    return $users->submitNewUser($input['token']);
    	}
		return array();
    }
    
    public function matchFriends(){
        $input = $_POST ? $_POST : $_GET;
        $friends = array();
		if ( isset( $input['userID'] ) && isset( $input['phone'] ) ){
		    $hashedList = explode('|', $input['phone'] );
		    $params = (object) array(
		        'id' => $input['userID'],
		        'hashed_list' => $hashedList,
		    );
		    $users = new BIM_App_Users();
			$friends = $users->matchFriends( $params );
			
		}
		return $friends;
    }
    
    public function twilioCallback(){
        $input = $_POST ? $_POST : $_GET;
        $users = new BIM_App_Users();
        $linked = $users->linkMobileNumber( (object) $_POST );
        if( $linked ){
            $to = $input['From']; // we switch the meaning of to and from so we can send an sms back
            $from = $input['To']; // we switch the meaning of to and from so we can send an sms back
            echo "<?xml version='1.0' encoding='UTF-8'?><Response><Sms from='$from' to='$to'>Volley On!</Sms></Response>";
            exit();
        }
    }
    
    public function inviteInsta(){
        $input = $_POST ? $_POST : $_GET;
		if ( !empty( $input['instau'] ) && !empty( $input['instap'] ) && !empty( $input['userID'] ) ){
		    $params = (object) array(
		        'username' => $input['instau'],
		        'password' => $input['instap'],
		        'volley_user_id' => $input['userID'], 
		    );
		    $users = new BIM_App_Users();
			$users->inviteInsta( $params );
		}
		return true;
    }
    
    public function inviteTumblr(){
        $input = $_POST ? $_POST : $_GET;
		if ( !empty( $input['u'] ) && !empty( $input['p'] ) && !empty( $input['userID'] ) ){
		    $params = (object) array(
		        'username' => $input['u'],
		        'password' => $input['p'],
		        'volley_user_id' => $input['userID'],
		    );
		    $users = new BIM_App_Users();
			$users->inviteTumblr( $params );
		}
		return true;
    }
    
    public function verifyEmail(){
        $v = false;
        $input = $_POST ? $_POST : $_GET;
		if ( !empty( $input['userID'] ) && !empty( $input['email'] ) ){
		    $params = (object) array(
		        'user_id' => $input['userID'],
		        'email' => $input['email'] ,
		    );
            $users = new BIM_App_Users();
		    $v = $users->verifyEmail( $params );
		}
		return $v;
    }
    
    public function ffEmail(){
        $input = $_POST ? $_POST : $_GET;
	    $friends = array();
		if ( !empty( $input['userID'] ) && !empty( $input['emailList'] ) ){
		    $emailList = explode('|', $input['emailList'] );
		    $params = (object) array(
		        'id' => $input['userID'],
		        'email_list' => $emailList,
		    );
            $users = new BIM_App_Users();
		    $friends = $users->matchFriendsEmail( $params );
		}
		return $friends;
    }
    
    public function verifyPhone(){
        $v = false;
        $input = $_POST ? $_POST : $_GET;
        if ( !empty( $input['code'] ) && !empty( $input['phone'] ) ){
            $userId = BIM_Utils::getIdForSMSCode($input['code']);
		    $params = (object) array(
		        'user_id' => $userId,
		        'phone' => $input['phone'] ,
		    );
            $users = new BIM_App_Users();
		    $v = $users->verifyPhone( $params );
		}
		return $v;
    }
}
