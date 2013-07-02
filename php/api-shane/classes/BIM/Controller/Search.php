<?php

class BIM_Controller_Search extends BIM_Controller_Base {
    
    public function test(){
        $search = new BIM_App_Search;
        $search->test();
    }

    public function getUsersLikeUsername(){
        $input = $_POST ? $_POST : $_GET;
		if (isset($input['username'])){
            $search = new BIM_App_Search;
		    return $search->getUsersLikeUsername($input['username']);
		}
    }
    
    public function getSubjectsLikeSubject(){
        if (isset($_POST['subjectName'])){
            $search = new BIM_App_Search;
            return $search->getSubjectsLikeSubject($_POST['subjectName']);
        }
    }
    
    public function getDefaultUsers(){
		if (isset($_POST['usernames'])){
            $search = new BIM_App_Search;
		    return $search->getDefaultUsers($_POST['usernames']);
		}
    }
    
    public function getSnappedUsers(){
        $search = new BIM_App_Search;
		if (isset($_POST['userID'])){
			return $search->getSnappedUsers($_POST['userID']);
		}
    }
}

