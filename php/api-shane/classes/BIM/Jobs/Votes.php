<?php 

class BIM_Jobs_Votes extends BIM_Jobs{
    
    public function queueUpvoteJob( $challengeID, $userID, $creator ){
        $job = array(
        	'class' => 'BIM_Jobs_Votes',
        	'method' => 'upvoteChallenge',
        	'data' => array( 'challengeID' => $challengeID, 'userID' => $userID, 'creator' => $creator ),
        );
        return $this->enqueueBackground( $job, 'upvote' );
    }
	
    public function upvoteChallenge( $workload ){
	    require_once 'BIM/App/Votes.php';
	    $votes = new BIM_App_Votes();
        $votes->upvoteChallenge( $workload->data->challengeID, $workload->data->userID, $workload->data->creator );
		$this->queueStaticChallengesByDate();
		$this->queueStaticChallengesByActivity();
		$this->queueStaticTopChallengesByVotes();
    }

	public function queueStaticChallengesByDate(){
        $job = array(
        	'class' => 'BIM_Jobs_Votes',
        	'method' => 'staticChallengesByDate',
        	'data' => array(),
        );
        return $this->enqueueBackground( $job, 'static_pages', __FUNCTION__ );
    }
    
	public function staticChallengesByDate( $workload ){
	    require_once 'BIM/App/Votes.php';
	    $votes = new BIM_App_Votes();
	    $data = gzencode( json_encode( $votes->getChallengesByDate() ), 9 );
	    $staticConf = BIM_Config::staticFuncs();
	    $path = $staticConf[ 'BIM_Controller_Votes' ][ 'getChallengesByDate' ]['path'];
	    file_put_contents( $path, $data );
	}
    
	public function queueStaticTopChallengesByVotes(){
        $job = array(
        	'class' => 'BIM_Jobs_Votes',
        	'method' => 'staticTopChallengesByVotes',
        	'data' => array(),
        );
        return $this->enqueueBackground( $job, 'static_pages', __FUNCTION__ );
    }
    
	public function staticTopChallengesByVotes( $workload ){
	    require_once 'BIM/App/Discover.php';
	    $discover = new BIM_App_Discover();
	    $data = gzencode( json_encode( $discover->getTopChallengesByVotes() ), 9 );
	    $staticConf = BIM_Config::staticFuncs();
	    $path = $staticConf[ 'BIM_Controller_Discover' ][ 'getTopChallengesByVotes' ]['path'];
	    file_put_contents( $path, $data );
	}
	
	public function queueStaticChallengesByActivity(){
        $job = array(
        	'class' => 'BIM_Jobs_Votes',
        	'method' => 'staticChallengesByActivity',
        	'data' => array(),
        );
        return $this->enqueueBackground( $job, 'static_pages', __FUNCTION__ );
    }
    
	public function staticChallengesByActivity( $workload ){
	    require_once 'BIM/App/Votes.php';
	    $votes = new BIM_App_Votes();
	    $data = gzencode( json_encode( $votes->getChallengesByActivity() ), 9 );
	    $staticConf = BIM_Config::staticFuncs();
	    $path = $staticConf[ 'BIM_Controller_Votes' ][ 'getChallengesByActivity' ]['path'];
	    file_put_contents( $path, $data );
	}
}