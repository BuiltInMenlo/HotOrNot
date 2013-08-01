<?php 

class BIM_Cache_Memcache {

	protected $cacheObj = null;

	public function __construct( $config ){
		$this->cacheObj = new Memcached();
	    foreach( $config->servers as $server ){
			$this->cacheObj->addServer( $server->host, $server->port );
		}
	}
	
    public function set( $key, &$data, $exp = 0 ){
        $return = false;
        if( $this->cacheObj ){
            $return = @$this->cacheObj->set( $key, $data, $exp );
        }
        return $return;
    }
    
    public function delete( $key ){
        $return = false;
        if( $this->cacheObj ){
            $return = @$this->cacheObj->delete( $key );
        }
        return $return;
    }
    
    public function get( $key ){
        $return = false;
        if( $this->cacheObj ){
            $return = @$this->cacheObj->get( $key );
        }
        return $return;
    }
    
    public function getMulti( $keys ){
        $return = false;
        if( $this->cacheObj ){
            $cas = null;
            $return = $this->cacheObj->getMulti( $keys );
        }
        return $return;
    }
}
