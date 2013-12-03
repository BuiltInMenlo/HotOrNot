<?php

class ApiProletariat {
	
	private $db_conn;

  	public function __construct() {	
		$this->db_conn = mysql_connect('localhost', 'hotornot_usr', 'dope911t') or die("Could not connect to database.");
		mysql_select_db('hotornot-dev') or die("Could not select database.");
	}
	
	public function __destruct() {	
		$this->closeDBConn();
	}
	
	public function getDBConn() {
		return ($this->db_conn);
	}
	
	public function closeDBConn() {
		if ($this->db_conn) {
			mysql_close($this->db_conn);
			$this->db_conn = null;
		}
	}
	
	
	public static function getStatusCodeMessage($status) {
		$codes = array(
			100 => 'Continue',
			101 => 'Switching Protocols',
			200 => 'OK',
			201 => 'Created',
			202 => 'Accepted',
			203 => 'Non-Authoritative Information',
			204 => 'No Content',
			205 => 'Reset Content',
			206 => 'Partial Content',
			300 => 'Multiple Choices',
			301 => 'Moved Permanently',
			302 => 'Found',
			303 => 'See Other',
			304 => 'Not Modified',
			305 => 'Use Proxy',
			306 => '(Unused)',
			307 => 'Temporary Redirect',
			400 => 'Bad Request',
			401 => 'Unauthorized',
			402 => 'Payment Required',
			403 => 'Forbidden',
			404 => 'Not Found',
			405 => 'Method Not Allowed',
			406 => 'Not Acceptable',
			407 => 'Proxy Authentication Required',
			408 => 'Request Timeout',
			409 => 'Conflict',
			410 => 'Gone',
			411 => 'Length Required',
			412 => 'Precondition Failed',
			413 => 'Request Entity Too Large',
			414 => 'Request-URI Too Long',
			415 => 'Unsupported Media Type',
			416 => 'Requested Range Not Satisfiable',
			417 => 'Expectation Failed',
			500 => 'Internal Server Error',
			501 => 'Not Implemented',
			502 => 'Bad Gateway',
			503 => 'Service Unavailable',
			504 => 'Gateway Timeout',
			505 => 'HTTP Version Not Supported');

		return ((isset($codes[$status])) ? $codes[$status] : '');
	}
	
	public static function sendResponse($status=200, $body='', $content_type='text/json') {			
		$status_header = "HTTP/1.1 ". $status ." ". ResponsePleb::getStatusCodeMessage($status);
		
		header($status_header);
		header("Content-type: ". $content_type);
		
		echo ($body);
	}
	
	
	
	/** 
	 * Helper function to send an Urban Airship push
	 * @param $msg The message body of the push (string)
	 * @return null
	**/
	public static function sendPush($msg) {
		// curl urban airship's api
		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL, 'https://go.urbanairship.com/api/push/');
		//curl_setopt($ch, CURLOPT_USERPWD, "qJAZs8c4RLquTcWKuL-gug:mbNYNOkaQ7CZJDypDsyjlQ"); // dev
		curl_setopt($ch, CURLOPT_USERPWD, "MB38FktJS8242wzKOOvEFQ:2c_IIFqWQKCpW9rhYifZVw"); // live
		curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		curl_setopt($ch, CURLOPT_POST, 1);
		curl_setopt($ch, CURLOPT_POSTFIELDS, $msg);
	 	$res = curl_exec($ch);
		$err_no = curl_errno($ch);
		$err_msg = curl_error($ch);
		$header = curl_getinfo($ch);
		curl_close($ch);
		
		// curl urban airship's api
		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL, 'https://go.urbanairship.com/api/push/');
		curl_setopt($ch, CURLOPT_USERPWD, "qJAZs8c4RLquTcWKuL-gug:mbNYNOkaQ7CZJDypDsyjlQ"); // dev
		//curl_setopt($ch, CURLOPT_USERPWD, "MB38FktJS8242wzKOOvEFQ:2c_IIFqWQKCpW9rhYifZVw"); // live
		curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		curl_setopt($ch, CURLOPT_POST, 1);
		curl_setopt($ch, CURLOPT_POSTFIELDS, $msg);
	 	$res = curl_exec($ch);
		$err_no = curl_errno($ch);
		$err_msg = curl_error($ch);
		$header = curl_getinfo($ch);
		curl_close($ch);
	}
	
	
	/** 
	 * Flags the challenge for abuse / inappropriate content
	 * @param $user_id The user's ID who is claiming abuse (integer)
	 * @param $challenge The ID of the challenge to flag (integer)
	 * @return An associative object (array)
	**/
	public static function sendEmail ($to, $subject, $body) {
		$from = "picchallenge@builtinmenlo.com";
		
		$headers_arr = array();
		$headers_arr[] = "MIME-Version: 1.0";
		$headers_arr[] = "Content-type: text/plain; charset=iso-8859-1";
		$headers_arr[] = "Content-Transfer-Encoding: 8bit";
		$headers_arr[] = "From: {$from}";
		$headers_arr[] = "Reply-To: {$from}";
		$headers_arr[] = "Subject: {$subject}";
		$headers_arr[] = "X-Mailer: PHP/". phpversion();

		if (mail($to, $subject, $body, implode("\r\n", $headers_arr))) 
		   $mail_res = true;

		else
		   $mail_res = false;  
		
		// return
		ApiProletariat::sendResponse(200, json_encode(array(
			'result' => $mail_res
		)));
		return (true);
	}
	
	
	
	/**
	 * Helper function to send an email to a facebook user
	 * @param $username The facebook username to send to (string)
	 * @param $msg The message body (string)
	 * @return Whether or not the email was sent (boolean)
	**/
	public static function fbEmail ($username, $msg) {
		// core message
		$to = $username ." <". $username ."@facebook.com>";
		$subject = "Welcome to PicChallengeMe!";
		$from = "PicChallenge <picchallenge@builtinmenlo.com>";
		
		// mail headers
		$headers_arr = array();
		$headers_arr[] = "MIME-Version: 1.0";
		$headers_arr[] = "Content-type: text/plain; charset=iso-8859-1";
		$headers_arr[] = "Content-Transfer-Encoding: 8bit";
		$headers_arr[] = "From: ". $from;
		$headers_arr[] = "Reply-To: ". $from;
		$headers_arr[] = "Subject: ". $subject;
		$headers_arr[] = "X-Mailer: PHP/". phpversion();
		
		// send & return
		return (mail($to, $subject, $msg, implode("\r\n", $headers_arr)));
	}
}