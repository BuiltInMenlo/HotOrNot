<?php

class Discover {
	
	private $db_conn;
	
  	function __construct() {
		include_once './_inc/ApiProletariat.inc.php';
		include_once './_inc/ChallengePleb.inc.php';
		include_once './_inc/ResponsePleb.inc.php';
		
		$this->db_conn = mysql_connect('localhost', 'hotornot_usr', 'dope911t') or die("Could not connect to database.");
		mysql_select_db('hotornot-dev') or die("Could not select database.");
	}
	
	function __destruct() {	
		if ($this->db_conn) {
			mysql_close($this->db_conn);
			$this->db_conn = null;
		}
	}
	
	
	/**
	 * Gets the challenges by total votes
	 * @return An associative array containing user info (array)
	**/
	function getTopChallengesByVotes() {
		
		$now_date = date('Y-m-d H:i:s', time());
		$start_date = date('Y-m-d H:i:s', strtotime($now_date .' - 30 days'));
		
		printf($now_date);
		printf($start_date);
		
		// get the challenge rows
		$query = 'SELECT `id` FROM `tblChallenges` WHERE `status_id` = 4 AND `started` > "'. $start_date .'" ORDER BY `votes` DESC LIMIT 16;';
		$result = mysql_query($query);
		
		printf($query);
		
		// loop thru challenge rows
		$challenge_arr = array();
		while ($row = mysql_fetch_assoc($result)) {
					
			// push challenge into array
			array_push($challenge_arr, ChallengePleb::getChallengeObj($row['id']));
		}
		
		if (count($challenge_arr) % 2 == 1)
			array_pop($challenge_arr);
		
		// return
		ApiProletariat::sendResponse(200, json_encode($challenge_arr));
		return (true);
	}
	
	/**
	 * Gets the challenges by location
	 * @param $lat The latitude coordinate (string)
	 * @param $long The longitude coordinate (string)
	 * @return An associative array containing challenges (array)
	**/
	function getTopChallengesByLocation($lat, $long) {
		
		// return
		$this->sendResponse(200, json_encode(array()));
		return (true);
	}
	
	
	/**
	 * Debugging function
	**/
	function test() {
		$this->sendResponse(200, json_encode(array(
			'result' => true
		)));
		return (true);	
	}
}

$discover = new Discover;
////$discover->test();


// action was specified
if (isset($_POST['action'])) {
	
	// depending on action, call function
	switch ($_POST['action']) {
		case "0":
			$discover->test();
			break;
		
		// get list of top challenges
		case "1":
			$discover->getTopChallengesByVotes();
			break;
		
		// get list of top challenges
		case "2":
			if (isset($_POST['lat']) && isset($_POST['long']))
				$discover->getTopChallengesByLocation($_POST['lat'], $_POST['long']);
			break;			
   	}
}
?>