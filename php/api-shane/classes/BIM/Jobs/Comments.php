<?php 

class BIM_Jobs_Comments extends BIM_Jobs{
    
    public $comments = null;
    public $voteJobs = null;
    
    public function __construct(){
        $this->voteJobs = new BIM_Jobs_Votes();
        $this->comments = new BIM_App_Comments();
    }
    
    protected function queueStaticPagesJobs(){
    	$this->voteJobs->queueStaticChallengesByDate();
    	$this->voteJobs->queueStaticChallengesByActivity();
    	$this->voteJobs->queueStaticTopChallengesByVotes();
    }
    
    /*
     * SUBMIT COMMENT TO CHALLENGE JOBS
     */
    public function queueSubmitCommentForChallengeJob( $challengeID, $userID, $text ){
        $job = array(
        	'class' => 'BIM_Jobs_Challenges',
        	'method' => 'submitMatchingChallenge',
        	'data' => array( 'challengeID' => $challengeID, 'userID' => $userID, 'text' => $text ),
        );
        return $this->enqueueBackground( $job, __CLASS__ );
    }
	
    public function submitCommentForChallenge( $workload ){
        $this->comments->submitCommentForChallenge( $workload->data->challengeID, $workload->data->userID, $workload->data->text );
        $this->queueStaticPagesJobs();
    }
}