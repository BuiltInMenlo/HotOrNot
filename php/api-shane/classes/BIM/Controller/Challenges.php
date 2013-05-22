<?php
require_once 'BIM/Jobs/Votes.php';
require_once 'BIM/App/Challenges.php';
require_once 'BIM/Controller/Base.php';

class BIM_Controller_Challenges extends BIM_Controller_Base {
    
    public $challenges = null;
    public $jobs = null;
    public $voteJobs = null;
    
    public function __construct(){
        parent::__construct();
        $this->jobs = new BIM_Jobs_Challenges();
        $this->voteJobs = new BIM_Jobs_Votes();
    }
    
    public function handleReq(){

	
        $this->challenges = $challenges = new BIM_App_Challenges;
        ////$challenges->test();
        
        
        // there's an action specified
        if (isset($_POST['action'])) {
        	
        	// call function depending on action
        	switch ($_POST['action']) {	
        		case "0":
        			return $challenges->test();
        		
        		// submit an auto-matching challenge	
        		case "1":
    				return $this->submitMatchingChallenge();
        		
        		// get challenges for a user
        		case "2":
        			if (isset($_POST['userID']))
        				return $challenges->getChallengesForUser($_POST['userID']);
        			break;
        			
        		case "3":
        			if (isset($_POST['userID']))
        				return $challenges->getAllChallengesForUser($_POST['userID']);
        			break;
        		
        		// accept a challenge
        		case "4":
    				return $this->acceptChallenge();
        		
        		// legacy function for itunes subject lookup
        		case "5":
        			if (isset($_POST['subjectName']))
        				return $challenges->getPreviewForSubject($_POST['subjectName']);
        			break;
        		
        		// update a challenge as being viewed
        		case "6":
        			if (isset($_POST['challengeID']))
        				return $challenges->updatePreviewed($_POST['challengeID']);
        			break;
        		
        		// submit a new challenge to a user
        		case "7":
    				return $this->submitChallengeWithUsername();
        		
        		case "8":
        			break;
        		
        		// submit a challenge to a user
        		case "9":
        			if (isset($_POST['userID']) && isset($_POST['subject']) && isset($_POST['imgURL']) && isset($_POST['challengerID']))
        				return $challenges->submitChallengeWithChallenger($_POST['userID'], $_POST['subject'], $_POST['imgURL'], $_POST['challengerID']);
        			break;
        		
        		// update a challenge as being canceled
        		case "10":
    				return $this->cancelChallenge();
        		
        		// update a challenge as being inappropriate / abuse 
        		case "11":
    				return $this->flagChallenge();
        		
        		// get challenges for a user prior to a date
        		case "12":
        			if (isset($_POST['userID']) && isset($_POST['prevIDs']) && isset($_POST['datetime']))
        				return $challenges->getChallengesForUserBeforeDate($_POST['userID'], $_POST['prevIDs'], $_POST['datetime']);
        			break;
        	}
        }
    }

    public function submitMatchingChallenge(){
        $uv = null;
		if (isset($_POST['userID']) && isset($_POST['subject']) && isset($_POST['imgURL'])){
		    $thisFunc = array( __CLASS__, __FUNCTION__ );
	        if( $this->useQueue( $thisFunc ) ){
    			$uv = $this->jobs->queueSubmitMatchingChallengeJob( $_POST['userID'], $_POST['subject'], $_POST['imgURL'] );
	        }
	        if( !$uv ){
    		    $uv = $this->challenges->submitMatchingChallenge( $_POST['userID'], $_POST['challengeID'], $_POST['imgURL'] );
    		    $this->queueStaticPagesJobs();
   	        }
		}
		return $uv;
    }
    
    public function flagChallenge(){
        $uv = null;
		if ( isset($_POST['userID']) && isset($_POST['challengeID']) ){
		    $thisFunc = array( __CLASS__, __FUNCTION__ );
	        if( $this->useQueue( $thisFunc ) ){
    			$uv = $this->jobs->queueFlagChallengeJob( $_POST['userID'], $_POST['challengeID'] );
	        }
	        if( !$uv ){
    		    $uv = $this->challenges->flagChallenge( $_POST['userID'], $_POST['challengeID'] );
    		    $this->queueStaticPagesJobs();
   	        }
		}
		return $uv;
    }
    
    public function cancelChallenge(){
        $uv = null;
		if (isset($_POST['challengeID'])) {
		    $thisFunc = array( __CLASS__, __FUNCTION__ );
	        if( $this->useQueue( $thisFunc ) ){
    			$uv = $this->jobs->queueCancelChallengeJob( $_POST['challengeID'] );
	        }
	        if( !$uv ){
    		    $uv = $this->challenges->cancelChallenge( $_POST['challengeID'] );
    		    $this->queueStaticPagesJobs();
   	        }
		}
		return $uv;
    }
    
    public function acceptChallenge(){
        $uv = null;
		if (isset( $_POST['userID']) && isset($_POST['challengeID']) && isset($_POST['imgURL'])) {
		    $thisFunc = array( __CLASS__, __FUNCTION__ );
	        if( $this->useQueue( $thisFunc ) ){
    			$uv = $this->jobs->queueAcceptChallengeJob( $_POST['userID'], $_POST['challengeID'], $_POST['imgURL'] );
	        }
	        if( !$uv ){
    		    $uv = $this->challenges->acceptChallenge( $_POST['userID'], $_POST['challengeID'], $_POST['imgURL'] );
    		    $this->queueStaticPagesJobs();
   	        }
		}
		return $uv;
    }
    
    public function submitChallengeWithUsername(){
        $uv = null;
		if (isset($_POST['userID']) && isset($_POST['subject']) && isset($_POST['imgURL']) && isset($_POST['username'])){
		    $thisFunc = array( __CLASS__, __FUNCTION__ );
	        if( $this->useQueue( $thisFunc ) ){
    			$uv = $this->jobs->queueSubmitChallengeWithUsernameJob( $_POST['userID'], $_POST['subject'], $_POST['imgURL'], $_POST['username'] );
	        }
	        if( !$uv ){
    		    $uv = $this->challenges->submitChallengeWithUsername( $_POST['userID'], $_POST['subject'], $_POST['imgURL'], $_POST['username'] );
    		    $this->queueStaticPagesJobs();
	        }
		}
		return $uv;
    }
    
    protected function queueStaticPagesJobs(){
    	$this->voteJobs->queueStaticChallengesByDate();
    	$this->voteJobs->queueStaticChallengesByActivity();
    	$this->voteJobs->queueStaticTopChallengesByVotes();
    }
}
