<?php

class BIM_Controller_Votes extends BIM_Controller_Base {
    public $votes = null;
    public $jobs = null;
    
    public function init(){
        $this->jobs = new BIM_Jobs_Votes();
        $this->votes = new BIM_App_Votes;
    }
    
    public function test(){
		return $this->votes->test();
    }
    
    public function getChallengesForSubjectID(){
		if (isset($_POST['subjectID'])){
			return $this->votes->getChallengesForSubjectID($_POST['subjectID']);
		}
		return array();
    }
    
    public function getChallengeForChallengeID(){
		if (isset($_POST['challengeID'])){
			return $this->votes->getChallengeForChallengeID($_POST['challengeID']);
		}
		return array();
    }
    
    public function getVotersForChallenge(){
        $input = $_POST ? $_POST : $_GET;
        if (isset($input['challengeID'])){
			return $this->votes->getVotersForChallenge($input['challengeID']);
		}
		return array();
    }
    
    public function getChallengesWithChallenger(){
        $input = $_POST ? $_POST : $_GET;
        if ( !empty( $input['userID'] ) && !empty( $input['challengerID'] ) ){
		    $isPrivate = !empty( $input['isPrivate'] ) ? $input['isPrivate'] : 'N';
		    $votes = new BIM_App_Votes();
            return $votes->getChallengesWithChallenger($input['userID'], $input['challengerID'], $isPrivate );
		}
		return array();
    }
    
    public function getChallengesForSubjectName(){
		if (isset($_POST['subjectName'])){
		    $isPrivate = !empty( $_POST['isPrivate'] ) ? $_POST['isPrivate'] : 'N';
		    $votes = new BIM_App_Votes();
		    return $votes->getChallengesForSubjectName($_POST['subjectName'], $isPrivate);
		}
		return array();
    }
    
    public function getChallengesForUsername(){
        $input = $_POST ? $_POST : $_GET;
		if (isset($input['username'])){
		    $votes = new BIM_App_Votes();
			return $votes->getChallengesForUsername($input['username']);
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
        $input = $_POST ? $_POST : $_GET;
        $uv = null;
		if ( isset( $input['challengeID'] ) && isset( $input['userID'] ) && isset( $input['challengerID'] ) ){
		    $votes = new BIM_App_Votes();
		    $uv = $votes->upvoteChallenge( $input['challengeID'], $input['userID'], $input['challengerID'] );
		}
		return $uv;
    }
    
    public function getChallengesByDate(){
		$thisFunc = array( __CLASS__, __FUNCTION__ );
        if( $this->isStatic( $thisFunc ) ){
	        $url = $this->staticFuncs[__CLASS__][__FUNCTION__]['url'];
		    header("Location: $url", TRUE, 302 );
		    exit();
	    } else {
			$data = $this->votes->getChallengesByDate();
		    return $data;
	    }
    }
    
    public function getChallengesByActivity(){
		$thisFunc = array( __CLASS__, __FUNCTION__ );
        if( $this->isStatic( $thisFunc ) ){
	        $url = $this->staticFuncs[__CLASS__][__FUNCTION__]['url'];
		    header("Location: $url", TRUE, 302 );
		    exit();
	    } else {
			$data = $this->votes->getChallengesByActivity();
		    return $data;
	    }
    }
    
    public function getChallengesWithFriends(){
        $input = (object) ( $_POST ? $_POST : $_GET );
        if( !empty( $input->userID ) ){
            $votes = new BIM_App_Votes();
            return $votes->getChallengesWithFriends( $input );
        }
    }
}