<?php

class BIM_DAO {
	protected $dbh = null;
	protected $conf = null;
	protected $connParams = null;
	
	public function __construct( $conf ){
		if( is_object($conf) ){
			$this->conf = $conf;
		} else {
			throw new Exception("no conf passed to constructor for ".get_class( $this ) );
		}
	}
}
