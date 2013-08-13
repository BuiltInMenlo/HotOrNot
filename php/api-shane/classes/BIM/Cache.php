<?php 

class BIM_Cache {

	protected $cacheObj = null;
	protected static $cache = array();
	
	public function __construct( $config ){
		$this->cacheObj = new Memcached();
	    foreach( $config->memcached->servers as $server ){
			$this->cacheObj->addServer( $server->host, $server->port );
		}
	}
	
    public function set( $key, &$data, $exp = 0 ){
        $return = false;
        if( $this->cacheObj ){
            $return = $this->cacheObj->set( $key, $data, $exp );
            self::$cache[$key] = $data;
        }
        return $return;
    }
    
    public function delete( $key ){
        $return = false;
        if( $this->cacheObj ){
            $return = $this->cacheObj->delete( $key );
            unset( self::$cache[ $key ] );
        }
        return $return;
    }
    
    public function get( $key ){
        $data = false;
        if( !empty( self::$cache[$key] ) ){
            $data = self::$cache[$key];
        }
        if( !$data && $this->cacheObj ){
            $data = $this->cacheObj->get( $key );
            self::$cache[$key] = $data;
        }
        return $data;
    }
    
    public function getMulti( $keys ){
        $return = array();
        $newKeys = array();
        foreach( $keys as $key ){
            if( !empty( self::$cache[$key] ) ){
                $return[] = self::$cache[$key];
            } else {
                $newKeys[] = $key;
            }
        }
        if( $newKeys && $this->cacheObj ){
            $data = $this->cacheObj->getMulti( $newKeys );
            $return = array_merge( $return, $data );
            self::$cache = array_merge( self::$cache, $data );
        }
        return $return;
    }
}
