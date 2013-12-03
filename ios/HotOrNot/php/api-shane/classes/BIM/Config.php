<?php 

class BIM_Config{
    
    static protected $defaultNetwork = 'instagram';

    static protected $lastTagFetch = 0;
    static protected $authenticTags = array();
    static protected $adTags = array();
    
    static protected $lastQuoteFetch = 0;
    static protected $authenticQuotes = array();
    static protected $adQuotes = array();
    
    public static function __callstatic( $name, $params ){
        $callable = array('BIM_Config_Dynamic', $name);
        return call_user_func($callable,$params);
    }
    
    public static function adTags( $network = '' ){
        if( !$network ){
            $network = self::$defaultNetwork;
        }
        if( !isset(self::$adTags[ $network ]) || ( time() - self::$lastTagFetch >= 300 ) ){
            self::getTags();
            if( !isset( self::$adTags[ $network ] ) ){
                self::$adTags[ $network ] = self::$adTags[ self::$defaultNetwork ];
            }
            self::$lastTagFetch = time();
        }
        return self::$adTags[ $network ];
        
    }
    
    protected static function getTags(){
        $dao = new BIM_DAO_Mysql_Growth( self::db() );
        $tagArray = $dao->getTags();
        foreach( $tagArray as $tagData ){
            if( $tagData->type == 'ad' ){
                self::$adTags[ $tagData->network ] = json_decode( $tagData->tags );
            } else {
                self::$authenticTags[ $tagData->network ] = json_decode( $tagData->tags );
            }
        }
    }
    
    public static function saveTags( $data ){
        if( !isset( $data->type ) || !preg_match('/authentic|ad/', $data->type) ){
            $data->type = 'authentic';
        }
        if( !isset( $data->network ) ){
            $data->network = self::$defaultNetwork;
        }
        $data->tags = explode(',', $data->tags );
        $data->tags = json_encode($data->tags);
        
        $dao = new BIM_DAO_Mysql_Growth( self::db() );
        $dao->saveTags( $data );
    }
    
    public static function authenticTags( $network = '' ){
        if( !$network ){
            $network = self::$defaultNetwork;
        }
        if( !isset(self::$authenticTags[ $network ]) || ( time() - self::$lastTagFetch >= 300 ) ){
            self::getTags();
            if( !isset( self::$authenticTags[ $network ] ) ){
                self::$authenticTags[ $network ] = self::$authenticTags[ self::$defaultNetwork ];
            }
            self::$lastTagFetch = time();
        }
        return self::$authenticTags[ $network ];
    }
    
    
    
    /*  Quote funcs  */
    public static function saveQuotes( $data ){
        if( !isset( $data->type ) || !preg_match('/authentic|ad/', $data->type) ){
            $data->type = 'authentic';
        }
        if( !isset( $data->network ) ){
            $data->network = self::$defaultNetwork;
        }
        $data->quotes = explode(',', $data->quotes );
        $data->quotes = json_encode($data->quotes);
        
        $dao = new BIM_DAO_Mysql_Growth( self::db() );
        $dao->saveQuotes( $data );
    }
    
    protected static function getQuotes(){
        $dao = new BIM_DAO_Mysql_Growth( self::db() );
        $quoteArray = $dao->getQuotes();
        foreach( $quoteArray as $quoteData ){
            if( $quoteData->type == 'ad' ){
                self::$adQuotes[ $quoteData->network ] = json_decode( $quoteData->quotes );
            } else {
                self::$authenticQuotes[ $quoteData->network ] = json_decode( $quoteData->quotes );
            }
        }
    }
    
    public static function authenticQuotes( $network = '' ){
        if( !$network ){
            $network = self::$defaultNetwork;
        }
        if( !isset(self::$authenticQuotes[ $network ]) || ( time() - self::$lastQuoteFetch >= 300 ) ){
            self::getQuotes();
            if( !isset( self::$authenticQuotes[ $network ] ) ){
                self::$authenticQuotes[ $network ] = self::$authenticQuotes[ self::$defaultNetwork ];
            }
            self::$lastQuoteFetch = time();
        }
        return self::$authenticQuotes[ $network ];
    }
    
    public static function adQuotes( $network = '' ){
        if( !$network ){
            $network = self::$defaultNetwork;
        }
        if( !isset(self::$adQuotes[ $network ]) || ( time() - self::$lastQuoteFetch >= 300 ) ){
            self::getQuotes();
            if( !isset( self::$adQuotes[ $network ] ) ){
                self::$adQuotes[ $network ] = self::$adQuotes[ self::$defaultNetwork ];
            }
            self::$lastQuoteFetch = time();
        }
        return self::$adQuotes[ $network ];
        
    }
}
