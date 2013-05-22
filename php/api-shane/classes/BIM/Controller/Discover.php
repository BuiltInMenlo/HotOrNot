<?php

require_once 'BIM/App/Discover.php';
require_once 'BIM/Controller/Base.php';

class BIM_Controller_Discover extends BIM_Controller_Base {
    
    public function handleReq(){

        $this->discover = $discover = new BIM_App_Discover;
        ////$discover->test();
        
        
        // action was specified
        if (isset($_POST['action'])) {
        	
        	// depending on action, call function
        	switch ($_POST['action']) {
        		case "0":
        			return $discover->test();
        		
        		// get list of top challenges
        		case "1":
        			return $this->getTopChallengesByVotes();
        		
        		// get list of top challenges
        		case "2":
        			if (isset($_POST['lat']) && isset($_POST['long']))
        				return $discover->getTopChallengesByLocation($_POST['lat'], $_POST['long']);
        			break;			
        	}
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