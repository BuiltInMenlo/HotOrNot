<?php

class BIM_Controller_Users extends BIM_Controller_Base {
    
    public function init(){
        $this->users = new BIM_App_Users;
    }
    
    public function test(){
		return $this->users->test();
    }
    
    public function flagUser(){
		if (isset($_POST['userID'])){
			return $this->users->flagUser($_POST['userID']);
		}
		return array();
    }
    
    public function updateUsernameAvatar(){
		if (isset($_POST['userID']) && isset($_POST['username']) && isset($_POST['imgURL'])){
			return $this->users->updateUsernameAvatar($_POST['userID'], $_POST['username'], $_POST['imgURL']);
		}
		return array();
    }
    
    public function getUserFromName(){
		if (isset($_POST['username'])){
			return $this->users->getUserFromName($_POST['username']);
		}
		return array();
    }
    
    public function updateName(){
		if (isset($_POST['userID']) && isset($_POST['username'])){
			return $this->users->updateName($_POST['userID'], $_POST['username']);
		}
		return array();
    }
    
    public function pokeUser(){
		if (isset($_POST['pokerID']) && isset($_POST['pokeeID'])){
			return $this->users->pokeUser($_POST['pokerID'], $_POST['pokeeID']);
		}
		return array();
    }
    
    public function getUser(){
        $input = $_POST ? $_POST : $_GET;
        if (isset($input['userID'])){
			return $this->users->getUserObj($input['userID']);
        }
		return array();
    }
    
    public function updateNotifications(){
		if (isset($_POST['userID']) && isset($_POST['isNotifications'])){
			return $this->users->updateNotifications($_POST['userID'], $_POST['isNotifications']);
		}
		return array();
    }
    
    public function updatePaid(){
		if (isset($_POST['userID']) && isset($_POST['isPaid'])){
			return $this->users->updatePaid($_POST['userID'], $_POST['isPaid']);
        }
		return array();
    }
    
    public function updateFB(){
		if (isset($_POST['userID']) && isset($_POST['username']) && isset($_POST['fbID']) && isset($_POST['gender'])){
			return $this->users->updateFB($_POST['userID'], $_POST['username'], $_POST['fbID'], $_POST['gender']);
		}
		return array();
    }
    
    public function submitNewUser(){
    	if (isset($_POST['token'])){
    		return $this->users->submitNewUser($_POST['token']);
    	}
		return array();
    }
    
    public function matchFriends(){
	    $friends = array();
		if ( isset( $_POST['userID'] ) && isset( $_POST['phone'] ) ){
		    $hashedList = explode('|', $_POST['phone'] );
		    $params = (object) array(
		        'id' => $_POST['userID'],
		        'hashed_list' => $hashedList,
		    );
			$friends = $this->users->matchFriends( $params );
		}
		return $friends;
    }
    
    public function twilioCallback(){
        $linked = $this->users->linkMobileNumber( (object) $_POST );
        if( $linked ){
            $to = $_POST['From']; // we switch the meanin of to and from so we can send an sms back
            $from = $_POST['To']; // we switch the meanin of to and from so we can send an sms back
            echo "<?xml version='1.0' encoding='UTF-8'?><Response><Sms from='$from' to='$to'>Volley On!</Sms></Response>";
            exit();
        }
    }
    
    public function inviteInsta(){
        return true;
		if ( isset( $_POST['instau'] ) && $_POST['instau'] && isset( $_POST['instap'] ) && $_POST['instap'] ){
		    $params = (object) array(
		        'username' => $_POST['instau'],
		        'password' => $_POST['instap'],
		    );
			$this->users->inviteInsta( $params );
		}
		return true;
    }
}
