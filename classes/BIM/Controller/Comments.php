<?php

class BIM_Controller_Comments extends BIM_Controller_Base {
    
    public function deleteComment(){
        return true; // needs a user id check
        $input = (object) ($_POST ? $_POST : $_GET);
		if (isset($input->commentID)){
		    $comments = new BIM_App_Comments();
			return $comments->deleteComment($input->commentID);
		}
    }
    
    public function flagComment(){
        return true; // needs a user id check
        $input = (object) ($_POST ? $_POST : $_GET);
        if (isset($input->commentID)){
		    $comments = new BIM_App_Comments();
            return $comments->flagComment($input->commentID);
		}
    }
    
    public function getCommentsForChallenge(){
        $input = (object) ($_POST ? $_POST : $_GET);
        if (isset($input->challengeID)){
		    $comments = new BIM_App_Comments();
            return $comments->getCommentsForChallenge($input->challengeID);
    	}
    }
    
    public function submitCommentForChallenge(){
        $uv = null;
        $input = (object) ($_POST ? $_POST : $_GET);
		if (isset($input->challengeID) && isset($input->userID) && isset($input->text)){
		    $input->userID = $this->resolveUserId($input->userID);
		    $comments = new BIM_App_Comments();
		    $uv = $comments->submitCommentForChallenge( $input->challengeID, $input->userID, $input->text );
		}
		return $uv;
    }
    
    protected function queueStaticPagesJobs(){
        $voteJobs = new BIM_Jobs_Votes();
	    $voteJobs->queueStaticChallengesByDate();
    	$voteJobs->queueStaticChallengesByActivity();
    	$voteJobs->queueStaticTopChallengesByVotes();
    }
}
