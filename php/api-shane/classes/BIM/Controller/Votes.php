<?php

require_once 'BIM/App/Votes.php';
require_once 'BIM/Jobs/Votes.php';
require_once 'BIM/Controller/Base.php';

class BIM_Controller_Votes extends BIM_Controller_Base {
    public $votes = null;
    public $jobs = null;
    
    public function init(){
        $this->jobs = new BIM_Jobs_Votes();
        $this->votes = $votes = new BIM_App_Votes;
    }
    
    public function handleReq(){
        
        // action was specified
        $action = isset($_POST['action']) ? $_POST['action'] : null;
        if( !$action ){
        	$action = isset($_GET['action']) ? $_GET['action'] : null;
        }
        
        if ( $action ) {
        	switch ( $action ) {
        		case "0":
        			return $this->test();
        		
        		// get list of challenges by votes
        		case "1":
        			return $this->getChallengesByActivity();
        		
        		// get challenges for a subject
        		case "2":
    				return $this->getChallengesForSubjectID();
        			
        		// get specific challenge				
        		case "3":
    				return $this->getChallengeForChallengeID();
        			
        		// get a list of challenges by date
        		case "4":
        		    return $this->getChallengesByDate();
        		// get the voters for a challenge
        		case "5":
    				return $this->getVotersForChallenge();
        		// upvote a challenge	
        		case "6":
        		    return $this->upvoteChallenge();
        		// get a list of challenges between two users
        		case "7":
    				return $this->getChallengesWithChallenger();
        			
        		// challenges by a subject name
        		case "8":
    				return $this->getChallengesForSubjectName();
        		case "9":
    				return $this->getChallengesForUsername();
        	}
        }
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
		if (isset($_POST['challengeID'])){
			return $this->votes->getVotersForChallenge($_POST['challengeID']);
		}
		return array();
    }
    
    public function getChallengesWithChallenger(){
		if (isset($_POST['userID']) && isset($_POST['challengerID'])){
			return $this->votes->getChallengesWithChallenger($_POST['userID'], $_POST['challengerID']);
		}
		return array();
    }
    
    public function getChallengesForSubjectName(){
		if (isset($_POST['subjectName'])){
			return $this->votes->getChallengesForSubjectName($_POST['subjectName']);
		}
		return array();
    }
    
    public function getChallengesForUsername(){
		if (isset($_POST['username'])){
			return $this->votes->getChallengesForUsername($_POST['username']);
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
		if ( isset( $_POST['challengeID'] ) && isset( $_POST['userID'] ) && isset( $_POST['creator'] ) ){
		    $thisFunc = array( __CLASS__, __FUNCTION__ );
	        if( $this->useQueue( $thisFunc ) ){
    			$uv = $this->jobs->queueUpvoteJob( $_POST['challengeID'], $_POST['userID'], $_POST['creator'] );
	        }
	        if( !$uv ){
    		    $uv = $this->votes->upvoteChallenge( $_POST['challengeID'], $_POST['userID'], $_POST['creator'] );
    			//$this->jobs->queueStaticChallengesByDate();
    			//$this->jobs->queueStaticChallengesByActivity();
    			//$this->jobs->queueStaticTopChallengesByVotes();
	        }
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
}
