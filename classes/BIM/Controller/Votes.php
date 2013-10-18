<?php

class BIM_Controller_Votes extends BIM_Controller_Base {
    
    public function getChallengesForSubjectID(){
        $input = (object) ($_POST ? $_POST : $_GET);
        if (isset($input->subjectID)){
		    $votes = new BIM_App_Votes();
		    return $votes->getChallengesForSubjectID($input->subjectID);
		}
		return array();
    }
    
    public function getChallengeForChallengeID(){
        $input = (object) ($_POST ? $_POST : $_GET);
        if (isset($input->challengeID)){
		    $votes = new BIM_App_Votes();
		    return $votes->getChallengeForChallengeID($input->challengeID);
		}
		return array();
    }
    
    public function getVotersForChallenge(){
        $input = (object) ($_POST ? $_POST : $_GET);
        if (isset($input->challengeID)){
		    $votes = new BIM_App_Votes();
            return $votes->getVotersForChallenge($input->challengeID);
		}
		return array();
    }
    
    public function getChallengesWithChallenger(){
        $input = (object) ($_POST ? $_POST : $_GET);
        if ( !empty( $input->userID ) && !empty( $input->challengerID ) ){
            $userId = $this->resolveUserId($input->userID);
		    $isPrivate = !empty( $input->isPrivate ) ? true : false;
		    $votes = new BIM_App_Votes();
            return $votes->getChallengesWithChallenger($userId, $input->challengerID, $isPrivate );
		}
		return array();
    }
    
    public function getChallengesForSubjectName(){
        $input = (object) ($_POST ? $_POST : $_GET);
        if (isset($input->subjectName)){
		    $isPrivate = ( !empty( $input->isPrivate ) && ($input->isPrivate == 'Y') ) ? true:false;
		    $votes = new BIM_App_Votes();
		    return $votes->getChallengesForSubjectName($input->subjectName, $isPrivate);
		}
		return array();
    }
    
    public function getChallengesForProfile(){
        $input = (object) ($_POST ? $_POST : $_GET);
		if (isset($input->username)){
		    $user = BIM_Model_User::getByUsername( $input->username );
		    if( $user && $user->isExtant() ){
    		    $votes = new BIM_App_Votes();
    			return $votes->getChallengesForProfile($input->username);
		    }
		}
		return array();
    }
    
    public function getChallengesForUsername(){
        $input = (object) ($_POST ? $_POST : $_GET);
        if( !empty($input->p)){
            //return $this->getChallengesForProfile();
		    $votes = new BIM_App_Votes();
            return $votes->getChallengesForUsername($input->username);
        } else 
        
        if (isset($input->username)){
		    $votes = new BIM_App_Votes();
			return $votes->getChallengesForUsername($input->username);
		}
		return array();
    }
    /**
            if( !empty($input->p)){
                $user = BIM_Model_User::getByUsername( $input->username );
                // here we filter out the volley pics that do ot belong ot the user
                // $volleys = $this->getChallengesForProfile();
                foreach( $volleys as $volley ){
                    if( $volley->creator->id != $user->id && !empty( $volley->challengers ) ){
                        foreach($volley->challengers as $idx => $challenger ){
                            if( $challenger->id != $user->id ){
                                unset( $volley->challengers[ $idx ] );
                            }
                        }
                    }
                }
            }
     * 
     * this functions submits a single vote for a challenge pic
     * this function can possibly by async in that it will queue the work
     * rather than do it itself. This is all controlled in the config.
     * 
     * the function first tries to queue the work
     * if it cannot queue the work then it runs the
     * function as if the queue were not there
     * 
     */
    public function upvoteChallenge(){
        $uv = null;
        $input = (object) ($_POST ? $_POST : $_GET);
		if ( !empty( $input->challengeID ) && !empty( $input->userID ) && !empty( $input->challengerID ) && !empty( $input->imgURL ) ){
            $userId = $this->resolveUserId($input->userID);
		    $votes = new BIM_App_Votes();
		    $uv = $votes->upvoteChallenge( $input->challengeID, $userId, $input->challengerID, $input->imgURL );
		}
		return $uv;
    }
    
    public function getChallengesByDate(){
        $votes = new BIM_App_Votes();
        $data = $votes->getChallengesByDate();
	    return $data;
    }
    
    public function getChallengesByActivity(){
        $votes = new BIM_App_Votes();
		$data = $votes->getChallengesByActivity();
	    return $data;
    }
    
    public function getChallengesWithFriends(){
        $input = (object) ($_POST ? $_POST : $_GET);
        if( !empty( $input->userID ) ){
            $input->userID = $this->resolveUserId($input->userID);
            $votes = new BIM_App_Votes();
            $volleys = $votes->getChallengesWithFriends( $input );
            $stickyVolleys = BIM_Model_Volley::getSticky();
            foreach( $stickyVolleys as $volley ){
                array_unshift( $volleys, $volley );
            }
            return $volleys;
        }
    }
}