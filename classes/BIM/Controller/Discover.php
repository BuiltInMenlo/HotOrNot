<?php

class BIM_Controller_Discover extends BIM_Controller_Base {
    
    public function getTopChallengesByVotes(){
        $discover = new BIM_App_Discover();
		return $discover->getManagedVolleys();
    }
}