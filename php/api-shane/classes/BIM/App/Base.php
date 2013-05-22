<?php 

class BIM_App_Base{
    
	protected $db_conn;
	
	public function dbConnect(){
	    if( !$this->db_conn ){
    		$this->db_conn = mysql_connect('localhost', 'hotornot_usr', 'dope911t') or die("Could not connect to database.");
    		mysql_select_db('hotornot-dev') or die("Could not select database.");
	    }
	}

	public function __destruct() {	
		if ($this->db_conn) {
			mysql_close($this->db_conn);
			$this->db_conn = null;
		}
	}
}