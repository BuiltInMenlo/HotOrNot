<?php

class Users {
	//private $db_conn;

  	function __construct() {
		include_once './_inc/ApiProletariat.inc.php';
		include_once './_inc/ChallengePleb.inc.php';
		include_once './_inc/ResponsePleb.inc.php';
		include_once './_inc/UserPleb.inc.php';
		
		//$this->db_conn = mysql_connect('localhost', 'hotornot_usr', 'dope911t') or die("Could not connect to database.");
		//mysql_select_db('hotornot-dev') or die("Could not select database.");
	}

	function __destruct() {	
		/*if ($this->db_conn) {
			mysql_close($this->db_conn);
			$this->db_conn = null;
		}*/
	}
	
	
	/**
	 * Adds a new user or returns one if it already exists
	 * @param $device_token The Urban Airship token generated on device (string)
	 * @return An associative object representing a user (array)
	**/
	function submitNewUser($device_token) {
		
		// check for user
		$query = 'SELECT * FROM `tblUsers` WHERE `device_token` = "'. $device_token .'";';
		$result = mysql_query($query);
		
		// found the user
		if (mysql_num_rows($result) > 0) {
			$row = mysql_fetch_object($result);
			$user_id = $row->id;
			
			// update last login
			$query = 'UPDATE `tblUsers` SET `last_login` = CURRENT_TIMESTAMP WHERE `id` = '. $user_id .';';
			$result = mysql_query($query);				
		
		// not found
		} else {
			
			// default names
			$defaultName_arr = array(
				"snap4snap",
				"picchampX",
				"swagluver",
				"coolswagger",
				"yoloswag",
				"tumblrSwag",
				"instachallenger",
				"hotbitchswaglove",
				"lovepeaceswaghot",
				"hotswaglover",
				"snapforsnapper",
				"snaphard",
				"snaphardyo",
				"yosnaper",
				"yoosnapyoo"
			);
			
			$rnd_ind = mt_rand(0, count($defaultName_arr) - 1);
			
			// add new user			
			$query = 'INSERT INTO `tblUsers` (';
			$query .= '`id`, `username`, `device_token`, `fb_id`, `gender`, `bio`, `website`, `paid`, `points`, `notifications`, `last_login`, `added`) ';
			$query .= 'VALUES (NULL, "", "'. $device_token .'", "", "N", "", "", "N", "0", "Y", CURRENT_TIMESTAMP, NOW());';
			$result = mysql_query($query);
			$user_id = mysql_insert_id();
			
			$username = $defaultName_arr[$rnd_ind] . $user_id;
			
			// create a default username 
			$query = 'UPDATE `tblUsers` SET `username` = "'. $username .'" WHERE `id` = '. $user_id .';';
			$result = mysql_query($query);
			
			// starting users & snaps
			$snap_arr = array(
				array(// @jason #bestFriend
					'user_id' => "2393", 
					'subject_id' => "9", 
					'img_prefix' => "https://hotornot-challenges.s3.amazonaws.com/fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc_0000000000"),
				array(// @tyler #snapAtMe
					'user_id' => "2394", 
					'subject_id' => "753", 
					'img_prefix' => "https://hotornot-challenges.s3.amazonaws.com/fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffb_0000000002"), 
				array(// @psy #me
					'user_id' => "2392", 
					'subject_id' => "28", 
					'img_prefix' => "https://hotornot-challenges.s3.amazonaws.com/ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff_0000000001") 
			);
			
			// loop thru user/snap array
			foreach ($snap_arr as $key => $val) {
				
				// add initial challenges
				$query = 'INSERT INTO `tblChallenges` (';
				$query .= '`id`, `status_id`, `subject_id`, `creator_id`, `creator_img`, `challenger_id`, `challenger_img`, `hasPreviewed`, `votes`, `started`, `added`) ';
				$query .= 'VALUES (NULL, "2", "'. $val['subject_id'] .'", "'. $val['user_id'] .'", "'. $val['img_prefix'] .'", "'. $user_id .'", "", "N", "0", NOW(), NOW());';
				$result = mysql_query($query);
				$challenge_id = mysql_insert_id();
			}		
		}
		
		// return
		$user_arr = UserPleb::userObject($user_id);
		ApiProletariat::sendResponse(200, json_encode($user_arr));
		return (true);
	}
	
	/**
	 * Updates a user's name and avatar image
	 * @param $user_id The user's id (integer)
	 * @param $username The new username (string)
	 * @param $img_url The url to the avatar (string)
	 * @return An associative object representing a user (array)
	**/
	function updateUsernameAvatar($user_id, $username, $img_url) {
		
		$query = 'UPDATE `tblUsers` SET `username` = "'. $username .'", `img_url` = "'. $img_url .'", `last_login` = CURRENT_TIMESTAMP WHERE `id` = '. $user_id .';';
		$result = mysql_query($query);
		
		// return
		$user_arr = UserPleb::userObject($user_id);
		ApiProletariat::sendResponse(200, json_encode($user_arr));
		return (true);	
	}
	
	/**
	 * Updates a user's Facebook credentials
	 * @param $user_id The ID for the user (integer)
	 * @param $username The facebook username (string)
	 * @param $fb_id The user's facebook ID (string)
	 * @param $gender The gender according to facebook (string) 
	 * @return An associative object representing a user (array)
	**/
	function updateFB($user_id, $username, $fb_id, $gender) {
		
		// get user info
		$query = 'SELECT `last_login`, `added` FROM `tblUsers` WHERE `id` = '. $user_id .';';
		$user_obj = mysql_fetch_object(mysql_query($query));
		
		// declare mail result
		$mail_result = -1;
		
		// first time logged in, send email
		if (strtotime($user_obj->last_login) == strtotime($user_obj->added)) {
			$mail_result = $this->fbEmail($username, "Lorem ipsum sit dolar amat!!");
			$query = 'UPDATE `tblUsers` SET `username` = "'. $username .'", `fb_id` = "'. $fb_id .'", `gender` = "'. $gender .'" WHERE `id` ='. $user_id .';';
			
		} else
			$query = 'UPDATE `tblUsers` SET `fb_id` = "'. $fb_id .'", `gender` = "'. $gender .'" WHERE `id` = '. $user_id .';';
		
		$result = mysql_query($query);
		
		
		// check to see if is an invited user
		$query = 'SELECT `id` FROM `tblInvitedUsers` WHERE `fb_id` = "'. $fb_id .'";';
		$invite_result = mysql_query($query);
		if (mysql_num_rows($invite_result) > 0) {
			$invite_id = mysql_fetch_object($invite_result)->id;
			
			// get any pending challenges for this invited user
			$query = 'SELECT `id` FROM `tblChallenges` WHERE `status_id` = 7 AND `challenger_id` = '. $invite_id .';';
			$invite_result = mysql_query($query);
		
			// loop thru the challenges
			while ($challenge_row = mysql_fetch_array($invite_result, MYSQL_BOTH)) {
				
				// update challenge w/ new user id and status
				$query = 'UPDATE `tblChallenges` SET `status_id` = 2, `challenger_id` = "'. $user_id .'" WHERE `id` = '. $challenge_row['id'] .';';
				$result = mysql_query($query);
			}
		}
		
		// return
		$user_arr = UserPleb::userObject($user_id, $mail_result);
		ApiProletariat::sendResponse(200, json_encode($user_arr));
		return (true);
	}
	
	/**
	 * Updates a user's name
	 * @param $user_id The ID for the user (integer)
	 * @param $username The desired username (string)
	 * @return An associative object representing a user (array)
	**/
	function updateName($user_id, $username) {
		
		// check for an already taken name			
		$query = 'SELECT `id` FROM `tblUsers` WHERE `username` = "'. $username .'" AND `id` != '. $user_id .';';
		$user_result = mysql_query($query);
		
		// not found
		if (mysql_num_rows($user_result) == 0) {
			
			// update the user's name
			$query = 'UPDATE `tblUsers` SET `username` = "'. $username .'" WHERE `id` = '. $user_id .';';
			$result = mysql_query($query);
			
			// get user info				
			$user_arr = UserPleb::userObject($user_id);
		
		// couldn't update	
		} else
			$user_arr = array('result' => "fail");
		
		
		// return
		ApiProletariat::sendResponse(200, json_encode($user_arr));
		return (true);
	}
	
	/**
	 * Updates a user's account to (non)premium
	 * @param $user_id The ID for the user (integer)
	 * @param $isPaid Y/N whether or not it's a premium account (string) 
	 * @return An associative object representing a user (array)
	**/
	function updatePaid($user_id, $isPaid) {
		
		// update user
		$query = 'UPDATE `tblUsers` SET `paid` = "'. $isPaid .'" WHERE `id` = '. $user_id .';';
		$result = mysql_query($query);
				   
		// return
		$user_arr = UserPleb::userObject($user_id);			
		ApiProletariat::sendResponse(200, json_encode($user_arr));
		return (true);
	}
	
	/**
	 * Gets a user
	 * @param $user_id The ID for the user (integer)
	 * @return An associative object representing a user (array)
	**/
	function getUser($user_id) {
		
		// get user & return
		$user_arr = UserPleb::userObject($user_id);			
		ApiProletariat::sendResponse(200, json_encode($user_arr));
		return (true);
	}
	
	/**
	 * Gets a user by username
	 * @param $username The name for the user (string)
	 * @return An associative object representing a user (array)
	**/
	function getUserFromName($username) {
		
		$query = 'SELECT `id` FROM `tblUsers` WHERE `username` = "'. $username .'";';
		$user_id = mysql_fetch_object(mysql_query($query))->id;
		
		// get user & return
		$user_arr = UserPleb::userObject($user_id);			
		ApiProletariat::sendResponse(200, json_encode($user_arr));
		return (true);
	}
	
	/**
	 * Updates a user's push notification prefs
	 * @param $user_id The ID for the user (integer)
	 * @param $isNotifications Y/N whether or not to allow pushes (string) 
	 * @return An associative object representing a user (array)
	**/
	function updateNotifications($user_id, $isNotifications) {
		$user_arr = array();
		
		// update user
		$query = 'UPDATE `tblUsers` SET `notifications` = "'. $isNotifications .'" WHERE `id` = '. $user_id .';';
		$result = mysql_query($query);
		
		// return
		$user_arr = UserPleb::userObject($user_id);			
		ApiProletariat::sendResponse(200, json_encode($user_arr));
		return (true);
	}
	
	/**
	 * Pokes a user
	 * @param $poker_id The ID for the user doing the poking (integer)
	 * @param $pokee_id The ID for the user getting poked (integer)
	 * @return An associative object representing a user (array)
	**/
	function pokeUser($poker_id, $pokee_id) {
		
		// add a record to the poke table
		$query = 'INSERT INTO `tblUserPokes` (';
		$query .= '`id`, `user_id`, `poker_id`, `added`) ';
		$query .= 'VALUES (NULL, "'. $pokee_id .'", "'. $poker_id .'", NOW());';
		$result = mysql_query($query);
		$poke_id = mysql_insert_id();
		
		// get the user who poked
		$query = 'SELECT `username` FROM `tblUsers` WHERE `id` = '. $poker_id .';';
		$poker_name = mysql_fetch_object(mysql_query($query))->username;
		
		// get the user who got poked
		$query = 'SELECT `device_token`, `notifications` FROM `tblUsers` WHERE `id` = '. $pokee_id .';';
		$pokee_obj = mysql_fetch_object(mysql_query($query));			
		
		// send push if allowed
		if ($pokee_obj->notifications == "Y")
			$this->sendPush('{"device_tokens": ["'. $pokee_obj->device_token .'"], "type":"2", "aps": {"alert": "@'. $poker_name .' has poked you!", "sound": "push_01.caf"}}');
		
		// return
		ApiProletariat::sendResponse(200, json_encode(array(
			'id' => $poke_id
		)));
		return (true);
	}
	
	/** 
	 * Flags the challenge for abuse / inappropriate content
	 * @param $user_id The user's ID who is claiming abuse (integer)
	 * @param $challenge The ID of the challenge to flag (integer)
	 * @return An associative object (array)
	**/
	function flagUser ($user_id) {
		
		// get this user's name
		$query = 'SELECT `username` FROM `tblUsers` WHERE `id` = '. $user_id .';';
		$user_obj = mysql_fetch_object(mysql_query($query));
					
		// send email
		$mail_res = ApiProletariat::sendEmail("bim.picchallenge@gmail.com", "Flagged User", "User ID: #$user_id\nUsername: #". $user_obj->username);
		
		ApiProletariat::sendResponse(200, json_encode(array(
			'id' => $user_id,
			'result' => $mail_res['result']
		)));
		return (true);
	}
	
	
	/**
	 * Debugging function
	**/
	function test() {
		ApiProletariat::sendResponse(200, json_encode(array(
			'result' => true
		)));
		return (true);	
	}
}

$users = new Users;
////$users->test();

// action was specified
if (isset($_POST['action'])) {
	
	// depending on action, call function
	switch ($_POST['action']) {	
		case "0":
			$users->test();
			break;
		
		// add a new user
		case "1":
			if (isset($_POST['token']))
				$users->submitNewUser($_POST['token']);
			break;
		
		// update user's facebook creds
		case "2":
			if (isset($_POST['userID']) && isset($_POST['username']) && isset($_POST['fbID']) && isset($_POST['gender']))
				$users->updateFB($_POST['userID'], $_POST['username'], $_POST['fbID'], $_POST['gender']);
			break;
		
		// update user's account type
		case "3":
			if (isset($_POST['userID']) && isset($_POST['isPaid']))
				$users->updatePaid($_POST['userID'], $_POST['isPaid']);
			break;
		
		// update a user's push notification prefs
		case "4":
			if (isset($_POST['userID']) && isset($_POST['isNotifications']))
				$users->updateNotifications($_POST['userID'], $_POST['isNotifications']);
			break;
		
		// get a user's info
		case "5":
			if (isset($_POST['userID']))
				$users->getUser($_POST['userID']);
			break;
		
		// poke a user
		case "6":
			if (isset($_POST['pokerID']) && isset($_POST['pokeeID']))
				$users->pokeUser($_POST['pokerID'], $_POST['pokeeID']);
			break;
		
		// change a user's name
		case "7":
			if (isset($_POST['userID']) && isset($_POST['username']))
				$users->updateName($_POST['userID'], $_POST['username']);
			break;
			
		// get a user's info
		case "8":
			if (isset($_POST['username']))
				$users->getUserFromName($_POST['username']);
			break;
			
		// updates a user's name and avatar image
		case "9":
			if (isset($_POST['userID']) && isset($_POST['username']) && isset($_POST['imgURL']))
				$users->updateUsernameAvatar($_POST['userID'], $_POST['username'], $_POST['imgURL']);
			break;
			
		// flag a user
		case "10":
			if (isset($_POST['userID']))
				$users->flagUser($_POST['userID']);
			break;
   	}
}
?>