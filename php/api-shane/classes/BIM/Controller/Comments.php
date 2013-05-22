<?php

require_once 'BIM/App/Comments.php';
require_once 'BIM/Jobs/Comments.php';
require_once 'BIM/Controller/Base.php';

class BIM_Controller_Comments extends BIM_Controller_Base {
    
    public $comments = null;
    public $jobs = null;
    public $voteJobs = null;
    
    public function __construct(){
        parent::__construct();
        $this->jobs = new BIM_Jobs_Comments();
        $this->voteJobs = new BIM_Jobs_Votes();
    }
    
    public function handleReq(){

        $this->comments = $comments = new BIM_App_Comments;
        ////$comments->test();
        
        // action was specified
        if (isset($_POST['action'])) {
        	switch ($_POST['action']) {
        		case "0":
        			return $comments->test();
        		
        		// get list of comments for challenge
        		case "1":
        			if (isset($_POST['challengeID']))
        				return $comments->getCommentsForChallenge($_POST['challengeID']);
        			break;
        		
        		// add a comment for a challenge
        		case "2":
    				return $this->submitCommentForChallenge();
        			
        		// add a comment for a subject
        		case "3":
        			if (isset($_POST['subjectID']) && isset($_POST['userID']) && isset($_POST['text']))
        				return $comments->submitCommentForSubject($_POST['subjectID'], $_POST['userID'], $_POST['text']);
        			break;
        			
        		// get a specific comment				
        		case "4":
        			if (isset($_POST['commentID']))
        				return $comments->getComment($_POST['commentID']);
        			break;
        			
        		// get a list of comments for a user
        		case "5":
        			if (isset($_POST['userID']))
        				return $comments->getCommentsForUser($_POST['userID']);
        			break;
        			
        		// get a list of comments for a subject
        		case "6":
        			if (isset($_POST['subjectID']))
        				return $comments->getCommentsForSubject($_POST['subjectID']);
        			break;
        			
        		// flags a comment
        		case "7":
        			if (isset($_POST['commentID']))
        				return $comments->flagComment($_POST['commentID']);
        			break;
        			
        		// removes a comment
        		case "8":
        			if (isset($_POST['commentID']))
        				return $comments->deleteComment($_POST['commentID']);
        			break;
        	}
        }
    }
    
    public function submitCommentForChallenge(){
        $uv = null;
		if (isset($_POST['challengeID']) && isset($_POST['userID']) && isset($_POST['text'])){
		    $thisFunc = array( __CLASS__, __FUNCTION__ );
	        if( $this->useQueue( $thisFunc ) ){
    			$uv = $this->jobs->queueSubmitCommentForChallengeJob( $_POST['challengeID'], $_POST['userID'], $_POST['text'] );
	        }
	        if( !$uv ){
    		    $uv = $this->challenges->submitCommentForChallenge( $_POST['challengeID'], $_POST['userID'], $_POST['text'] );
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
