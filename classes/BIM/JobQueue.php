<?php
class BIM_JobQueue{
	protected $servers = array( array('host' => '127.0.0.1', 'port' => 4730 ) );
	protected $queue = null;
		
	public function __construct( $config = null ){
        if( isset( $config->servers )  ){
			$this->servers = $config->servers;
        }
	}
}
