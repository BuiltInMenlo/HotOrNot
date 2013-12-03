<?php

require_once 'BIM/App/Votes.php';
require_once 'BIM/Jobs/Votes.php';
require_once 'BIM/Controller/Base.php';

class BIM_Controller_Votes extends BIM_Controller_Base {
    public $votes = null;
    public $jobs = null;
    
    public function __construct(){
        parent::__construct();
        $this->jobs = new BIM_Jobs_Votes();
    }
    
    public function handleReq(){
        $this->votes = $votes = new BIM_App_Votes;
        
        // action was specified
        $action = isset($_POST['action']) ? $_POST['action'] : null;
        if( !$action ){
        	$action = isset($_GET['action']) ? $_GET['action'] : null;
        }
        
        if ( $action ) {
        	switch ( $action ) {
        		case "0":
        			return $votes->test();
        			break;
        		
        		// get list of challenges by votes
        		case "1":
        			return $this->getChallengesByActivity();
        		
        		// get challenges for a subject
        		case "2":
        			if (isset($_POST['subjectID']))
        				return $votes->getChallengesForSubjectID($_POST['subjectID']);
        			break;
        			
        		// get specific challenge				
        		case "3":
        			if (isset($_POST['challengeID']))
        				return $votes->getChallengeForChallengeID($_POST['challengeID']);
        			break;
        			
        		// get a list of challenges by date
        		case "4":
        		    return $this->getChallengesByDate();
        		// get the voters for a challenge
        		case "5":
        			if (isset($_POST['challengeID']))
        				return $votes->getVotersForChallenge($_POST['challengeID']);
        			break;
        			
        		// upvote a challenge	
        		case "6":
		            //if ( isset( $_POST['challengeID'] ) && isset( $_POST['userID'] ) && isset( $_POST['creator'] ) )
        		        //return $this->votes->upvoteChallenge( $_POST['challengeID'], $_POST['userID'], $_POST['creator'] );
        		    return $this->upvoteChallenge();
                    break;
        		// get a list of challenges between two users
        		case "7":
        			if (isset($_POST['userID']) && isset($_POST['challengerID']))
        				return $votes->getChallengesWithChallenger($_POST['userID'], $_POST['challengerID']);
        			break;
        			
        		// challenges by a subject name
        		case "8":
        			if (isset($_POST['subjectName']))
        				return $votes->getChallengesForSubjectName($_POST['subjectName']);
        			break;
        		
        		case "9":
        			if (isset($_POST['username']))
        				return $votes->getChallengesForUsername($_POST['username']);
        			break;
        	}
        }
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
