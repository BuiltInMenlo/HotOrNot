<?php

class BIM_Controller_Search extends BIM_Controller_Base {
    
    public function getUsersLikeUsername(){
        $input = (object) ($_POST ? $_POST : $_GET);
		if (!empty($input->username)){
            $search = new BIM_App_Search;
		    return $search->getUsersLikeUsername($input->username);
		}
    }
    
    public function getSubjectsLikeSubject(){
        $input = (object) ($_POST ? $_POST : $_GET);
        if (!empty($input->subjectName)){
            $search = new BIM_App_Search;
            return $search->getSubjectsLikeSubject($input->subjectName);
        }
    }
    
    public function getDefaultUsers(){
        $input = (object) ($_POST ? $_POST : $_GET);
        if (!empty($input->usernames)){
            $search = new BIM_App_Search;
		    return $search->getDefaultUsers($input->usernames);
		}
    }
    
    public function getSnappedUsers(){
        $input = (object) ($_POST ? $_POST : $_GET);
		if (!empty($input->userID)){
            $input->userID = $this->resolveUserId( $input->userID );
		    $search = new BIM_App_Search;
		    return $search->getSnappedUsers($input->userID);
		}
    }
}

