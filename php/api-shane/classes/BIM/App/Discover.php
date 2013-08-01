<?php
/*
Discover
	action 1 - ( getTopChallengesByVotes ),
*/

require_once 'BIM/App/Base.php';

class BIM_App_Discover extends BIM_App_Base{
	
	/**
	 * Helper function that returns a challenge based on ID
	 * @param $challenge_id The ID of the challenge to get (integer)
	 * @return An associative object for a challenge (array)
	**/
	public function getChallengeObj ($volleyId) {
	    return new BIM_Model_Volley($volleyId);
	}
	
	/**
	 * Gets the challenges by total votes
	 * @return An associative array containing user info (array)
	**/
	public function getTopChallengesByVotes() {
		$this->dbConnect();
	    $challenge_arr = array();
		
		$now_date = date('Y-m-d H:i:s', time());
		$start_date = date('Y-m-d H:i:s', strtotime($now_date .' - 90 days'));
		
		// $this->sendResponse(200, json_encode(array('now_date' => $now_date, 'start_date' => $start_date, 'query' => 'SELECT `id` FROM `tblChallenges` WHERE `status_id` = 4 AND `started` > "'. $start_date .'" ORDER BY `votes` DESC LIMIT;')));
		// return (true);
		
		// get the challenge rows
		$query = 'SELECT `id` FROM `tblChallenges` WHERE `status_id` = 4 AND `started` > "'. $start_date .'" ORDER BY `votes` DESC LIMIT 256;';
		$result = mysql_query($query);
		
		// loop thru challenge rows
		while ($row = mysql_fetch_assoc($result)) {
					
			// push challenge into array
			$co = $this->getChallengeObj( $row['id'] );
			if( $co->expires != 0 ){
    			array_push( $challenge_arr, $co );
			}
		}
		
		if (count($challenge_arr) % 2 == 1)
			array_pop($challenge_arr);
		
		// return
		return $challenge_arr;
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

