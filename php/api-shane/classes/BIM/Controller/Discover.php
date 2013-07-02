<?php

class BIM_Controller_Discover extends BIM_Controller_Base {
    
    public function init(){
        $this->discover = new BIM_App_Discover;
    }
    
    public function test(){
        $this->discover->test();
    }
    
    public function getTopChallengesByLocation(){
		if (isset($_POST['lat']) && isset($_POST['long'])){
			return $this->discover->getTopChallengesByLocation($_POST['lat'], $_POST['long']);
		}
    }
    
    public function getTopChallengesByVotes(){
		$thisFunc = array( __CLASS__, __FUNCTION__ );
        if( $this->isStatic( $thisFunc ) ){
	        $url = $this->staticFuncs[__CLASS__][__FUNCTION__]['url'];
		    header("Location: $url", TRUE, 302 );
		    exit();
	    } else {
			$data = $this->discover->getTopChallengesByVotes();
		    return $data;
	    }
    }
}