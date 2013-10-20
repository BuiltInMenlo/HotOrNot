<?php 

class BIM_Cache {

	protected $cacheObj = null;
	protected static $cache = array();
	
	// profiling vars
	public static $profile = array();
	protected static $profileStart = 0;
	
	public function __construct( $config ){
		$this->cacheObj = new Memcached();
	    foreach( $config->memcached->servers as $server ){
			$this->cacheObj->addServer( $server->host, $server->port );
		}
	}
	
    public function set( $key, &$data, $exp = 0, $local = true ){
        $return = false;
        if( $this->cacheObj ){
            self::startProfiling();
            $return = $this->cacheObj->set( $key, $data, $exp );
            self::endProfiling(__FUNCTION__.' => '.$key);
            if( $local ){
                self::$cache[$key] = $data;
            }
        }
        return $return;
    }
    
    public function delete( $key, $local = true ){
        $return = false;
        if( $this->cacheObj ){
            self::startProfiling();
            $return = $this->cacheObj->delete( $key );
            self::endProfiling(__FUNCTION__.' => '.$key);
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
            self::startProfiling();
            $data = $this->cacheObj->get( $key );
            self::endProfiling(__FUNCTION__.' => '.$key);
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
            self::startProfiling();
            $data = $this->cacheObj->getMulti( $keys );
            self::endProfiling(__FUNCTION__);
            $return = array_merge( $return, $data );
            if($local){
                self::$cache = array_merge( self::$cache, $data );
            }
        }
        return $return;
    }
    
    public static function startProfiling(){
        if( BIM_Utils::isProfiling() ){
            self::$profileStart = microtime(1);
        }
    }
    
    public static function endProfiling($q){
        if( BIM_Utils::isProfiling() && !empty(self::$profileStart) ){
            $end = microtime(1);
            if( empty( self::$profile ) ){
                self::$profile = array();
            }
            if( empty( self::$profile[ $q ] ) ){
                self::$profile[ $q ] = array();
                self::$profile[ $q ]['total'] = 0;
                self::$profile[ $q ]['time'] = 0;
            }
            self::$profile[ $q ]['total']++;
            self::$profile[ $q ]['time'] += ($end - self::$profileStart);

            $bt = debug_backtrace();
            $callTree = join( ' => ', array( $bt[2]['class'].':'.$bt[2]['function'], $bt[1]['class'].':'.$bt[1]['function'] ) );
            if( !isset( self::$profile[ $q ][$callTree] ) ){
                self::$profile[ $q ][$callTree] = 0;
            }
            self::$profile[ $q ][$callTree]++;
        }
    }
}
