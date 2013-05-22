<?php

require_once 'BIM/App/Search.php';
require_once 'BIM/Controller/Base.php';

class BIM_Controller_Search extends BIM_Controller_Base {
    
    public function handleReq(){

        $search = new BIM_App_Search;
        ////$search->test();
        
        // action was specified
        if (isset($_POST['action'])) {
        	switch ($_POST['action']) {
        		case "0":
        			return $search->test();
        		
        		// get list of usernames containing a string
        		case "1":				
        			if (isset($_POST['username']))
        				return $search->getUsersLikeUsername($_POST['username']);
        			break;
        		
        		// get list of subjects containing a string
        		case "2":
        			if (isset($_POST['subjectName']))
        				return $search->getSubjectsLikeSubject($_POST['subjectName']);
        			break;
        		
        		// get list of users from defaults
        		case "3":
        			if (isset($_POST['usernames']))
        				return $search->getDefaultUsers($_POST['usernames']);
        			break;
        			
        		// get users someone has snapped with
        		case "4":
        			if (isset($_POST['userID']))
        				return $search->getSnappedUsers($_POST['userID']);
        			break;
        		
        	}
        }
    }
}