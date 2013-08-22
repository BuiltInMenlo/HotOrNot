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
	
    public function set( $key, &$data, $exp = 0, $local = true ){
        $return = false;
        if( $this->cacheObj ){
            $return = $this->cacheObj->set( $key, $data, $exp );
            if( $local ){
                self::$cache[$key] = $data;
            }
        }
        return $return;
    }
    
    public function delete( $key, $local = true ){
        $return = false;
        if( $this->cacheObj ){
            $return = $this->cacheObj->delete( $key );
            if( $local ){
                unset( self::$cache[ $key ] );
            }
        }
        return $return;
    }
    
    public function get( $key, $local = true ){
        $data = false;
        //$d = debug_backtrace();
        //error_log( print_r( array($key, $d[2]['function'], $d[1]['function'] ), 1) );
        if( !empty( self::$cache[$key] ) && $local ){
            $data = self::$cache[$key];
        }
        if( !$data && $this->cacheObj ){
            $data = $this->cacheObj->get( $key );
            if( $local ){
                self::$cache[$key] = $data;
            }
        }
        return $data;
    }
    
    public function getMulti( $keys, $local = true ){
        $return = array();
        if( $local ){
            $newKeys = array();
            foreach( $keys as $key ){
                if( !empty( self::$cache[$key] ) ){
                    $return[] = self::$cache[$key];
                } else {
                    $newKeys[] = $key;
                }
            }
            $keys = &$newKeys;
        }
        if( $keys && $this->cacheObj ){
            $data = $this->cacheObj->getMulti( $keys );
            $return = array_merge( $return, $data );
            if($local){
                self::$cache = array_merge( self::$cache, $data );
            }
        }
        return $return;
    }
}
