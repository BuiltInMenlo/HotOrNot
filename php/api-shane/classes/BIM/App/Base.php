<?php 

class BIM_App_Base{
    
	protected $db_conn;
	protected static $users = array();
	
	public function dbConnect(){
	    if( !$this->db_conn ){
    		$this->db_conn = mysql_connect('localhost', 'root', '') or die("Could not connect to database.");
    		mysql_select_db('hotornot-dev') or die("Could not select database.");
	    }
	}

	public function __destruct() {	
		if ($this->db_conn) {
			mysql_close($this->db_conn);
			$this->db_conn = null;
		}
	}
	
    public static function getUser( $userId ){
        if( empty( self::$users[$userId] ) ){
            $user = new BIM_User( $userId );
            if ( !$user || ! $user->isExtant() ){
                self::$users[$userId] = false;
            } else {
                self::$users[$userId] = $user;
            }
        }
        return self::$users[$userId];
    }
}