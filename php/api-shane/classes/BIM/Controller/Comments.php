<?php

class BIM_Controller_Comments extends BIM_Controller_Base {
    
    public $comments = null;
    public $jobs = null;
    public $voteJobs = null;
    
    public function init(){
        $this->jobs = new BIM_Jobs_Comments();
        $this->voteJobs = new BIM_Jobs_Votes();
        $this->comments = $comments = new BIM_App_Comments;
    }
    
    public function test(){
		return $this->comments->test();
    }
    
    public function deleteComment(){
		if (isset($_POST['commentID'])){
			return $this->comments->deleteComment($_POST['commentID']);
		}
    }
    
    public function flagComment(){
		if (isset($_POST['commentID'])){
			return $this->comments->flagComment($_POST['commentID']);
		}
    }
    
    public function getCommentsForChallenge(){
        $input = ( $_POST ? $_POST : $_GET );
        if (isset($input['challengeID'])){
    		return $this->comments->getCommentsForChallenge($input['challengeID']);
    	}
    }
    
    public function submitCommentForChallenge(){
        $input = ( $_POST ? $_POST : $_GET );
        $uv = null;
		if (isset($input['challengeID']) && isset($input['userID']) && isset($input['text'])){
		    $thisFunc = array( __CLASS__, __FUNCTION__ );
	        if( $this->useQueue( $thisFunc ) ){
    			$uv = $this->jobs->queueSubmitCommentForChallengeJob( $input['challengeID'], $input['userID'], $input['text'] );
	        }
	        if( !$uv ){
    		    $uv = $this->comments->submitCommentForChallenge( $input['challengeID'], $input['userID'], $input['text'] );
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
