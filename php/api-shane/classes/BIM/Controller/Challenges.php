<?php

class BIM_Controller_Challenges extends BIM_Controller_Base {
    
    public $challenges = null;
    public $jobs = null;
    public $voteJobs = null;
    
    public function __construct(){
        parent::__construct();
        $this->jobs = new BIM_Jobs_Challenges();
        $this->voteJobs = new BIM_Jobs_Votes();
        $this->challenges = $challenges = new BIM_App_Challenges;
    }
    
    public function test(){
		return $this->challenges->test();
    }
    
    public function getChallengesForUserBeforeDate(){
		if (isset($_POST['userID']) && isset($_POST['prevIDs']) && isset($_POST['datetime'])){
			return $this->challenges->getChallengesForUserBeforeDate($_POST['userID'], $_POST['prevIDs'], $_POST['datetime']);
		}
    }    
    
    public function submitChallengeWithChallenger(){
		if (isset($_POST['userID']) && isset($_POST['subject']) && isset($_POST['imgURL']) && isset($_POST['challengerID'])){
		    $isPrivate = isset( $_POST['isPrivate'] ) ? $_POST['isPrivate'] : 'N';
			return $this->challenges->submitChallengeWithChallenger($_POST['userID'], $_POST['subject'], $_POST['imgURL'], $_POST['challengerID'], $isPrivate );
		}
    }
    
    public function updatePreviewed(){
		if (isset($_POST['challengeID'])){
			return $this->challenges->updatePreviewed($_POST['challengeID']);
		}
    }
    
    public function getPreviewForSubject(){
		if (isset($_POST['subjectName'])){
			return $this->challenges->getPreviewForSubject($_POST['subjectName']);
		}
    }
    
    public function getAllChallengesForUser(){
        $input = (object) ($_POST ? $_POST : $_GET);
		if ( isset( $input->userID ) ){
			return $this->challenges->getAllChallengesForUser( $input->userID );
		}
    }

    public function getChallengesForUser(){
        $input = (object) ( $_POST ? $_POST : $_GET );
        if ( !empty( $input->userID ) ){
            return $this->challenges->getChallengesForUser( $input->userID );
        }
    }
    
    public function getPrivateChallengesForUser(){
		if (isset($_POST['userID']))
			return $this->challenges->getChallengesForUser($_POST['userID'], TRUE); // true means get private challenge only
    }
    
    public function getPrivateChallengesForUserBeforeDate(){
		if (isset($_POST['userID']) && isset($_POST['prevIDs']) && isset($_POST['datetime']))
			return $this->challenges->getChallengesForUserBeforeDate($_POST['userID'], $_POST['prevIDs'], $_POST['datetime'], TRUE); // true means get private challenges only
    }
    
    public function submitMatchingChallenge(){
        $uv = null;
		if (isset($_POST['userID']) && isset($_POST['subject']) && isset($_POST['imgURL'])){
		    $thisFunc = array( __CLASS__, __FUNCTION__ );
	        if( $this->useQueue( $thisFunc ) ){
    			$uv = $this->jobs->queueSubmitMatchingChallengeJob( $_POST['userID'], $_POST['subject'], $_POST['imgURL'] );
	        }
	        if( !$uv ){
    		    $uv = $this->challenges->submitMatchingChallenge( $_POST['userID'], $_POST['subject'], $_POST['imgURL'] );
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
    
    public function submitChallengeWithUsernames(){
        $uv = null;
        if (isset($_POST['userID']) && isset($_POST['subject']) && isset($_POST['imgURL']) && isset($_POST['usernames'])){
            $usernames = explode('|', $_POST['usernames'] );
            foreach( $usernames as $username ){
                $uv = null;
                $isPrivate = isset( $_POST['isPrivate'] ) ? $_POST['isPrivate'] : 'N' ;
    		    $func = array( __CLASS__, 'submitChallengeWithUsername' );
    	        if( $this->useQueue( $func ) ){
        			$uv = $this->jobs->queueSubmitChallengeWithUsernameJob( $_POST['userID'], $_POST['subject'], $_POST['imgURL'], $username, $isPrivate );
    	        }
    	        if( !$uv ){
    	            $uv = $this->challenges->submitChallengeWithUsername( $_POST['userID'], $_POST['subject'], $_POST['imgURL'], $username, $isPrivate );
        		    $this->queueStaticPagesJobs();
    	        }
            }
		}
		return $uv;
    }
    
    public function submitChallengeWithUsername(){
        $input = $_POST ? $_POST : $_GET;
        $uv = null;
        if (isset($input['userID']) && isset($input['subject']) && isset($input['imgURL']) && isset($input['username'])){
		    $isPrivate = isset( $input['isPrivate'] ) ? $input['isPrivate'] : 'N' ;
		    $thisFunc = array( __CLASS__, __FUNCTION__ );
	        if( $this->useQueue( $thisFunc ) ){
    			$uv = $this->jobs->queueSubmitChallengeWithUsernameJob( $input['userID'], $input['subject'], $input['imgURL'], $input['username'], $isPrivate );
	        }
	        if( !$uv ){
	            $uv = $this->challenges->submitChallengeWithUsername( $input['userID'], $input['subject'], $input['imgURL'], $input['username'], $isPrivate );
    		    $this->queueStaticPagesJobs();
	        }
		}
		return $uv;
    }
    
    protected function queueStaticPagesJobs(){
    	return;
	    $this->voteJobs->queueStaticChallengesByDate();
        $this->voteJobs->queueStaticChallengesByActivity();
        $this->voteJobs->queueStaticTopChallengesByVotes();
    }
}
