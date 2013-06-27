<?php

require_once 'BIM/App/Users.php';
require_once 'BIM/Controller/Base.php';

class BIM_Controller_Users extends BIM_Controller_Base {
    
    public function handleReq(){

        $this->users = $users = new BIM_App_Users;
        ////$users->test();
        $input = null;
        if (isset($_POST['action'])) {
            $input = $_POST;
        } else if( isset($_GET['action'] ) ){
            $input = $_GET;
        }
        // action was specified
        if (isset($input['action'])) {
        	
        	// depending on action, call function
        	switch ($input['action']) {	
        		case "0":
        			return $users->test();
        		
        		// add a new user
        		case "1":
    				return $this->submitNewUser();
        		
        		// update user's facebook creds
        		case "2":
    				return $this->updateFB();
        		
        		// update user's account type
        		case "3":
    				return $this->updatePaid();
        		
        		// update a user's push notification prefs
        		case "4":
    				return $this->updateNotifications();
        		
        		// get a user's info
        		case "5":
    				return $this->getUser();
        				        		
        		// poke a user
        		case "6":
    				return $this->pokeUser();
        		
        		// change a user's name
        		case "7":
    				return $this->updateName();
        			
        		// get a user's info
        		case "8":
    				return $this->getUserFromName();
        			
        		// updates a user's name and avatar image
        		case "9":
    				return $this->updateUsernameAvatar();
        			
        		// flag a user
        		case "10":
    				return $this->flagUser();
    				
        		case "11":
        		    return $this->matchFriends( $input );
        			break;
        			
        		default:
        		    return array();
        	}
        } else {
            return array();
        }
    }
    
    public function flagUser(){
		if (isset($_POST['userID'])){
			return $this->users->flagUser($_POST['userID']);
		}
    }
    
    public function updateUsernameAvatar(){
		if (isset($_POST['userID']) && isset($_POST['username']) && isset($_POST['imgURL'])){
			return $this->users->updateUsernameAvatar($_POST['userID'], $_POST['username'], $_POST['imgURL']);
		}
    }
    
    public function getUserFromName(){
		if (isset($_POST['username'])){
			return $this->users->getUserFromName($_POST['username']);
		}
    }
    
    public function updateName(){
		if (isset($_POST['userID']) && isset($_POST['username'])){
			return $this->users->updateName($_POST['userID'], $_POST['username']);
		}
    }
    
    public function pokeUser(){
		if (isset($_POST['pokerID']) && isset($_POST['pokeeID'])){
			return $this->users->pokeUser($_POST['pokerID'], $_POST['pokeeID']);
		}
    }
    
    public function getUser(){
		if (isset($_POST['userID'])){
			return $this->users->getUser($_POST['userID']);
        }
    }
    
    public function updateNotifications(){
		if (isset($_POST['userID']) && isset($_POST['isNotifications'])){
			return $this->users->updateNotifications($_POST['userID'], $_POST['isNotifications']);
		}
    }
    
    public function updatePaid(){
		if (isset($_POST['userID']) && isset($_POST['isPaid'])){
			return $this->users->updatePaid($_POST['userID'], $_POST['isPaid']);
        }
    }
    
    public function updateFB(){
		if (isset($_POST['userID']) && isset($_POST['username']) && isset($_POST['fbID']) && isset($_POST['gender'])){
			return $this->users->updateFB($_POST['userID'], $_POST['username'], $_POST['fbID'], $_POST['gender']);
		}
    }
    
    public function submitNewUser(){
    	if (isset($_POST['token'])){
    		return $this->users->submitNewUser($_POST['token']);
    	}
    }
    
    public function matchFriends( $input ){
	    $friends = '[]';
		if ( isset( $input['userID'] ) && isset( $input['phone'] ) ){
		    $hashedList = explode('|', $input['phone'] );
		    $params = (object) array(
		        'user_id' => $input['userID'],
		        'hashed_list' => $hashedList,
		    );
			$friends = $this->users->matchFriends( $params );
		}
		return $friends;
    }
}
