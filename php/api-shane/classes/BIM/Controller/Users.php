<?php

require_once 'BIM/App/Users.php';
require_once 'BIM/Controller/Base.php';

class BIM_Controller_Users extends BIM_Controller_Base {
    
    public function handleReq(){

        $users = new BIM_App_Users;
        ////$users->test();
        
        // action was specified
        if (isset($_POST['action'])) {
        	
        	// depending on action, call function
        	switch ($_POST['action']) {	
        		case "0":
        			return $users->test();
        		
        		// add a new user
        		case "1":
        			if (isset($_POST['token']))
        				return $users->submitNewUser($_POST['token']);
        			break;
        		
        		// update user's facebook creds
        		case "2":
        			if (isset($_POST['userID']) && isset($_POST['username']) && isset($_POST['fbID']) && isset($_POST['gender']))
        				return $users->updateFB($_POST['userID'], $_POST['username'], $_POST['fbID'], $_POST['gender']);
        			break;
        		
        		// update user's account type
        		case "3":
        			if (isset($_POST['userID']) && isset($_POST['isPaid']))
        				return $users->updatePaid($_POST['userID'], $_POST['isPaid']);
        			break;
        		
        		// update a user's push notification prefs
        		case "4":
        			if (isset($_POST['userID']) && isset($_POST['isNotifications']))
        				return $users->updateNotifications($_POST['userID'], $_POST['isNotifications']);
        			break;
        		
        		// get a user's info
        		case "5":
        			if (isset($_POST['userID']))
        				return $users->getUser($_POST['userID']);
        			break;
        		
        		// poke a user
        		case "6":
        			if (isset($_POST['pokerID']) && isset($_POST['pokeeID']))
        				return $users->pokeUser($_POST['pokerID'], $_POST['pokeeID']);
        			break;
        		
        		// change a user's name
        		case "7":
        			if (isset($_POST['userID']) && isset($_POST['username']))
        				return $users->updateName($_POST['userID'], $_POST['username']);
        			break;
        			
        		// get a user's info
        		case "8":
        			if (isset($_POST['username']))
        				return $users->getUserFromName($_POST['username']);
        			break;
        			
        		// updates a user's name and avatar image
        		case "9":
        			if (isset($_POST['userID']) && isset($_POST['username']) && isset($_POST['imgURL']))
        				return $users->updateUsernameAvatar($_POST['userID'], $_POST['username'], $_POST['imgURL']);
        			break;
        			
        		// flag a user
        		case "10":
        			if (isset($_POST['userID']))
        				return $users->flagUser($_POST['userID']);
        			break;
        			
        		default:
        		    return array();
        	}
        } else {
            return array();
        }
    }
}
