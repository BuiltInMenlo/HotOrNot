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
		    $isPrivate = !empty( $input->isPrivate ) ? true : false;
		    $votes = new BIM_App_Votes();
            return $votes->getChallengesWithChallenger($input->userID, $input->challengerID, $isPrivate );
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
    
    public function getChallengesForUsername(){
        $input = (object) ($_POST ? $_POST : $_GET);
		if (isset($input->username)){
		    $votes = new BIM_App_Votes();
			return $votes->getChallengesForUsername($input->username);
		}
		return array();
    }
    /**
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
		if ( !empty( $input->challengeID ) && !empty( $input->userID ) && !empty( $input->challengerID ) ){
		    $votes = new BIM_App_Votes();
		    $uv = $votes->upvoteChallenge( $input->challengeID, $input->userID, $input->challengerID );
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
            $votes = new BIM_App_Votes();
            return $votes->getChallengesWithFriends( $input );
        }
    }
}