<?php
/*
Discover
	action 1 - ( getTopChallengesByVotes ),
*/

require_once 'BIM/App/Base.php';

class BIM_App_Discover extends BIM_App_Base{
	
	/**
	 * Gets the challenges by total votes
	 * @return An associative array containing user info (array)
	**/
	public function getTopChallengesByVotes() {
	    return BIM_Model_Volley::getTopVolleysByVotes();
	}
	
	/**
	 * Debugging function
	**/
	public function test() {
		return array(
			'result' => true
		);
	}
}

