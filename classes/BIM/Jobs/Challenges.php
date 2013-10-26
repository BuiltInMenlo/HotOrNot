<?php 

class BIM_Jobs_Challenges extends BIM_Jobs{
    
    public $challenges = null;
    public $voteJobs = null;
    
    public function __construct(){
        $this->voteJobs = new BIM_Jobs_Votes();
        $this->challenges = new BIM_App_Challenges();
    }
    
    /*
     * SUBMIT MATCHING CHALLENGE JOBS
     */
    public function queueSubmitMatchingChallengeJob( $userID,  $challengeID, $username ){
        $job = array(
        	'class' => 'BIM_Jobs_Challenges',
        	'method' => 'submitMatchingChallenge',
        	'data' => array( 'userID' => $userID, 'challengeID' => $challengeID, 'username' => $username ),
        );
        return $this->enqueueBackground( $job, __CLASS__ );
    }
	
    public function submitMatchingChallenge( $workload ){
        $this->challenges->submitMatchingChallenge( $workload->data->userID, $workload->data->challengeID, $workload->data->username );
        $this->queueStaticPagesJobs();
    }
    
    /*
     * CANCEL CHALLENGE JOBS
     */
    public function queueFlagChallengeJob( $userID,  $challengeID ){
        $job = array(
        	'class' => 'BIM_Jobs_Challenges',
        	'method' => 'flagChallenge',
        	'data' => array( 'userID' => $userID, 'challengeID' => $challengeID ),
        );
        return $this->enqueueBackground( $job, __CLASS__ );
    }
	
    public function flagChallenge( $workload ){
        $this->challenges->flagChallenge( $workload->data->userID, $workload->data->challengeID );
        $this->queueStaticPagesJobs();
    }
    
    /*
     * CANCEL CHALLENGE JOBS
     */
    public function queueCancelChallengeJob( $challengeID ){
        $job = array(
        	'class' => 'BIM_Jobs_Challenges',
        	'method' => 'cancelChallenge',
        	'data' => array( 'challengeID' => $challengeID ),
        );
        return $this->enqueueBackground( $job, __CLASS__ );
    }
	
    public function cancelChallenge( $workload ){
        $this->challenges->cancelChallenge( $workload->data->challengeID );
        $this->queueStaticPagesJobs();
    }
    
    /*
     * ACCEPT CHALLENGE JOBS
     */
    public function queueAcceptChallengeJob( $userID, $challengeID, $imgUrl ){
        $job = array(
        	'class' => 'BIM_Jobs_Challenges',
        	'method' => 'acceptChallenge',
        	'data' => array( 'challengeID' => $challengeID, 'userID' => $userID, 'imgUrl' => $imgUrl ),
        );
        return $this->enqueueBackground( $job, __CLASS__ );
    }
	
    public function acceptChallenge( $workload ){
        $this->challenges->acceptChallenge( $workload->data->challengeID, $workload->data->userID, $workload->data->imgUrl );
        $this->queueStaticPagesJobs();
    }
    
    /*
     * PROCESS IMAGE
     */
    public static function queueProcessImage( $imgUrl ){
        $job = array(
        	'class' => 'BIM_Jobs_Challenges',
        	'method' => 'processImage',
        	'data' => array( 'img_url' => $imgUrl ),
        );
        return self::queueBackground( $job, 'process_image' );
    }
	
    public function processImage( $workload ){
        BIM_Utils::processImage( $workload->data->img_url );
    }
    
    /*
     * PROCESS VOLLEY IMAGES
     */
    public static function queueProcessVolleyImages( $volleyId, $imgUrl = '' ){
        $job = array(
        	'class' => 'BIM_Jobs_Challenges',
        	'method' => 'processVolleyImages',
        	'data' => array( 'volley_id' => $volleyId ),
        );
        if( !empty( $imgUrl ) ){
            $job['data']['img_url'] = $imgUrl;
        }
        return self::queueBackground( $job, 'process_volley_images' );
    }
	
    public function processVolleyImages( $workload ){
        if( !empty( $workload->data->img_url ) ){
            // we were passed a specific image url
            // so we just process that and not the whole volley
            BIM_Model_Volley::processImage( $workload->data->img_url );
        } else {
            BIM_Model_Volley::processVolleyImages( array( $workload->data->volley_id ) );
        }
    }
    
    /*
     * SUBMIT CHALLENGE WITH USERNAME JOBS
     */
    public function queueSubmitChallengeWithUsernameJob( $userID, $subject, $imgUrl, $username, $isPrivate ){
        $job = array(
        	'class' => 'BIM_Jobs_Challenges',
        	'method' => 'submitChallengeWithUsername',
        	'data' => array( 'userID' => $userID, 'subject' => $subject, 'imgUrl' => $imgUrl, 'username' => $username, 'isPrivate' => $isPrivate ),
        );
        return $this->enqueueBackground( $job, __CLASS__ );
    }
	
    public function submitChallengeWithUsername( $workload ){
        $this->challenges->submitChallengeWithUsername( $workload->data->userID, $workload->data->subject, $workload->data->imgUrl, $workload->data->username, $workload->data->isPrivate );
        $this->queueStaticPagesJobs();
    }
    
    protected function queueStaticPagesJobs(){
    	$this->voteJobs->queueStaticChallengesByDate();
    	$this->voteJobs->queueStaticChallengesByActivity();
    	$this->voteJobs->queueStaticTopChallengesByVotes();
    }
    
    public static function queueAcceptChallengeAsDefaultUser( $volleyObject, $creator, $targetUser ){
        $job = array(
        	'class' => 'BIM_Jobs_Challenges',
        	'method' => 'acceptChallengeAsDefaultUser',
        	'params' => array( 
                'volleyObject' => $volleyObject,
                'creator' => $creator,
                'targetUser' => $targetUser,
            ),
        );
        return self::queueBackground( $job, __CLASS__ );
    }
    
    public function acceptChallengeAsDefaultUser( $workload ){
        $params = json_decode($workload->params);
        if( $params ){
            // now we need to instantiate the real php objects and not just the stdClass
            $volley = BIM_Model_Volley::get( $params->volleyObject->id );
            $target = BIM_Model_User::get( $params->targetUser->id );
            $creator = BIM_Model_User::get( $params->creator->id );
            $c = new BIM_App_Challenges();
            $c->doAcceptChallemgeAsDefaultUser( $volley, $creator, $target );
        }
    }
    
}
    