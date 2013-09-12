<?php

class BIM_DAO_Mysql extends BIM_DAO{

    public $lastInsertId = null;
    public $rowCount = null;
    public static $profile = null;
    
    /**
     * retrieves config data for connecting to a data source.
     * 
     * This function will retrieve a writer handle or reader handle as
     * declared in the config instance that is returned from the 
     * findNode() call on a BIM_Data_Locator instance
     * 
     * If a writer is ever used for a id then we will always return the
     * same writer params for that id on future getReader() and getWriter() calls
     * this is how we beat replication lag by ensuring that we read from wherever we have written.
     * 
     * We probably need to add a way to get a reader explicitly at some point
     * 
     * @param string|int $id
     * @param boolean $getWriter
     * @return BIM_Config
     * 
     * @throws BIM_Model_Exception
     */
    protected function getConnectionParams( $getWriter = false,  $shardKey = null ){
        $connParams = null;
        
        // now get our node
        $node = $this->findNode( $shardKey );
        
        // check to see if we have used a writer for this id and retrieve it if we have.
        if( isset( $this->connParams[ $shardKey ] ) ){
            $connParams = $this->connParams[ $shardKey ];
        } else if( $getWriter ){
            $connParams = $node->writer;
            // set the writer handle so that we always
            // get the writer handle on future calls, 
            // even if we are asking for a reader.
            $this->connParams[ $shardKey ] = $connParams;
        } else {
            // we randomly choose a reader so that we 
            // spread the load amongst our reader boxes
            $connParams = $node->reader;
        }

        return $connParams;
    }

    /**
     * 
     * get the locator class from the config
     * set the the config on the locator class
     * call findNode and pass the id
     * 
     * @param int|string $id
     */
    protected function findNode( $id ){
        $class_name = $this->conf->locatorClassName;
        if( !class_exists($class_name) && preg_match( '/^BIM_/', $class_name ) ){
            require_once $this->conf->locatorClassPath;
        }
        $val = call_user_func( array( $class_name, 'findNode') , $id, $this->conf );
        return $val;
    }
    
    /**
     * getConnection retrieves a cached db connection for the passed connParams
     * if no connection is cached, we connect to the db and cache the handle
     *
     * @param string $id
     * @return object $connection
     */
    protected function getConnection( $connParams ){
        $connKey = self::getConnKey( $connParams );
        $connection = BIM_Data_ConnectionManager::get( $connKey );
        if( !$connection ){
            $connection = $this->connect($connParams);
            if( !$connection ){
                throw new Exception("could not connect to db for ".$connParams->user."@".$connParams->host);
            }
            BIM_Data_ConnectionManager::set( $connKey, $connection );
        } 
        return $connection;        
    }
    
    protected function connect( $params ){
        $host = isset( $params->host ) && $params->host ? $params->host : 'localhost';
        $dbname = isset( $params->dbname ) && $params->dbname ? $params->dbname : '';
        $user = isset( $params->user ) && $params->user ? $params->user : '';
        $pass = isset( $params->pass ) && $params->pass ? $params->pass : '';
        $port = isset( $params->port ) && $params->port ? $params->port : '';

        $conn = new PDO("mysql:host=$host;dbname=$dbname;port=$port", $user, $pass);
        
        if( $params->dbname ){
            $sql = 'use '.$params->dbname;
        }
        $conn->query($sql);
        
        return $conn;
    }
    
    /**
     * 
     * creates a unique based on db connection parameteers
     * the key is used by the connection manager for storing connections 
     * so we can be sure to reuse them
     * 
     * @param stdClass $params
     */
    protected static function getConnKey( $params ){
        $host = isset( $params->host ) && $params->host ? $params->host : 'localhost';
        $dbname = isset( $params->dbname ) && $params->dbname ? $params->dbname : '';
        $user = isset( $params->user ) && $params->user ? $params->user : '';
        $port = isset( $params->port ) && $params->port ? $params->port : '';
        $connKey = join('_',
            array( 
                $host,
                $port,
                $dbname,
                $user,
                )
        );
        return $connKey;
    }
    
    /**
     * 
     * first we get the connection params from the BIM_DAO_Mysql_ConnectionManager
     * 
     * 
     * @param string ref $sql - the sql to be executed
     * @param array ref $params - the params for the prepared sql statement
     * @param boolean $getWriter - a boolean value that indicates if we shoud return the writer or reader handle for the db
     * @param string $shardKey - the key we are using for doing a lookup across shards / nodes if necessary
     */
    public function prepareAndExecute( &$sql, &$params = array(), $getWriter = false, $shardKey = '' ){
        if( BIM_Utils::isProfiling() ){
            $start = microtime(1);
        }
        $connParams = $this->getConnectionParams( $getWriter, $shardKey );
        $conn = $this->getConnection( $connParams );
        $stmt = $conn->prepare( $sql );
        $stmt->execute( $params );
        if( !preg_match('/^(?:00|01|IM)/', $stmt->errorCode() ) ){
            //$call = debug_backtrace();
            //print_r( array( get_class( $this ), $stmt->errorCode(), $stmt->errorInfo(), $sql, $params ) );
	    //exit;
            // do some error handling
        }
        $this->lastInsertId = $conn->lastInsertId();
        $this->rowCount = $stmt->rowCount();
        
        if( BIM_Utils::isProfiling() ){
            $end = microtime(1);
            if( empty( self::$profile ) ){
                self::$profile = array();
            }
            if( empty( self::$profile[ $sql ] ) ){
                self::$profile[ $sql ] = array();
                self::$profile[ $sql ]['total'] = 0;
                self::$profile[ $sql ]['time'] = 0;
            }
            self::$profile[ $sql ]['total']++;
            self::$profile[ $sql ]['time'] += ($end - $start);

            $bt = debug_backtrace();
            $callTree = join( ' => ', array( $bt[2]['class'].':'.$bt[2]['function'], $bt[1]['class'].':'.$bt[1]['function'] ) );
            if( !isset( self::$profile[ $sql ][$callTree] ) ){
                self::$profile[ $sql ][$callTree] = 0;
            }
            self::$profile[ $sql ][$callTree]++;
            
        }
        return $stmt;
    }

}
