<?php 

class BIM_Config{
    
    static protected $defaultNetwork = 'instagram';

    static protected $lastInviteMsgFetch = 0;
    static protected $inviteMsgs = array();
    
    static protected $bootConfLive = array();
    static protected $bootConfDev = array();
    
    static protected $lastTagFetch = 0;
    static protected $authenticTags = array();
    static protected $adTags = array();
    static protected $otherTags = array();
    
    static protected $lastQuoteFetch = 0;
    static protected $authenticQuotes = array();
    static protected $adQuotes = array();
    static protected $otherQuotes = array();
    
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
    
    public static function otherTags( $network = '' ){
        if( !$network ){
            $network = self::$defaultNetwork;
        }
        if( !isset(self::$otherTags[ $network ]) || ( time() - self::$lastTagFetch >= 300 ) ){
            self::getTags();
            if( !isset( self::$otherTags[ $network ] ) ){
                self::$otherTags[ $network ] = self::$otherTags[ self::$defaultNetwork ];
            }
            self::$lastTagFetch = time();
        }
        return self::$otherTags[ $network ];
        
    }
    
    protected static function getTags(){
        $dao = new BIM_DAO_Mysql_Growth( self::db() );
        $tagArray = $dao->getTags();
        foreach( $tagArray as $tagData ){
            if( $tagData->type == 'ad' ){
                self::$adTags[ $tagData->network ] = json_decode( $tagData->tags );
            } else if( $tagData->type == 'authentic' ){
                self::$authenticTags[ $tagData->network ] = json_decode( $tagData->tags );
            } else {
                self::$otherTags[ $tagData->network ] = json_decode( $tagData->tags );
            }
        }
    }
    
    public static function saveTags( $data ){
        if( !isset( $data->type ) || !preg_match('/authentic|ad|other/', $data->type) ){
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
        if( !isset( $data->type ) || !preg_match('/authentic|ad|other/', $data->type) ){
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
            } else if( $quoteData->type == 'authentic' ){
                self::$authenticQuotes[ $quoteData->network ] = json_decode( $quoteData->quotes );
            } else {
                self::$otherQuotes[ $quoteData->network ] = json_decode( $quoteData->quotes );
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
    
    public static function otherQuotes( $network = '' ){
        if( !$network ){
            $network = self::$defaultNetwork;
        }
        if( !isset(self::$otherQuotes[ $network ]) || ( time() - self::$lastQuoteFetch >= 300 ) ){
            self::getQuotes();
            if( !isset( self::$otherQuotes[ $network ] ) ){
                self::$otherQuotes[ $network ] = self::$otherQuotes[ self::$defaultNetwork ];
            }
            self::$lastQuoteFetch = time();
        }
        return self::$otherQuotes[ $network ];
        
    }
    
    protected static function bootConfCacheKey( $type = 'live' ){
        return BIM_Utils::makeCacheKeys('volley_boot_conf', $type);
    }
    
    public static function getBootConf( $type = 'live' ){
        $bootConf = null;
        $cacheKey = self::bootConfCacheKey( $type );
        $cache = new BIM_Cache( BIM_Config::cache() );
        $data = $cache->get( $cacheKey );
        if( !$data ){
            $dao = new BIM_DAO_Mysql_Config( self::db() );
            $data = $dao->getBootConf( $type );
            $data =  $data[0]->data;
            $cache->set( $cacheKey, $data );
        }
        return $data;
    }
    
    public static function saveBootConf( $data, $type = 'live' ){
        $dao = new BIM_DAO_Mysql_Config( self::db() );
        $dao->saveBootConf( $data, $type );
        
        $cackeKey = self::bootConfCacheKey( $type );
        $cache = new BIM_Cache( BIM_Config::cache() );
        $cache->set( $cackeKey, $data );
    }
    
    public static function inviteMsgs(){
        if( empty( self::$inviteMsgs ) || ( time() - self::$lastInviteMsgFetch >= 300 ) ){
            self::getInviteMsgs();
            self::$lastInviteMsgFetch = time();
        }
        return self::$inviteMsgs;
        
    }
    
    public static function saveInviteMsgs( $data ){
        $dao = new BIM_DAO_Mysql_Growth( self::db() );
        $dao->saveInviteMsgs( $data );
    }
    
    protected static function getInviteMsgs(){
        $dao = new BIM_DAO_Mysql_Growth( self::db() );
        $msgArray = $dao->getInviteMsgs();
        foreach( $msgArray as $msgData ){
            self::$inviteMsgs[ $msgData->type ] = $msgData->message;
        }
    }
    
    public static function actionMethods(){
        return array(
            'BIM_Controller_Search' => array(
        		'0' => 'test',
        		'1' => 'getUsersLikeUsername',
        		'2' => 'getSubjectsLikeSubject',
        		'3' => 'getDefaultUsers',
        		'4' => 'getSnappedUsers',
            ),
            'BIM_Controller_Users' => array(
                '0' => 'test',
        		'1' => 'submitNewUser',
        		'2' => 'updateFB',
        		'3' => 'updatePaid',
        		'4' => 'updateNotifications',
        		'5' => 'getUser',
        		'6' => 'pokeUser',
        		'7' => 'updateName',
        		'8' => 'getUserFromName',
        		'9' => 'updateUsernameAvatar',
        		'10' => 'flagUser',
        		'11' => 'matchFriends',
        		'12' => 'inviteInsta',
            ),
            'BIM_Controller_Discover' => array(
        		'0' => 'test',
        		'1' => 'getTopChallengesByVotes',
        		'2' => 'getTopChallengesByLocation',
        	),
            'BIM_Controller_Comments' => array(
                '0' => 'test',
        		'1' => 'getCommentsForChallenge',
        		'2' => 'submitCommentForChallenge',
        		'3' => 'submitCommentForSubject',        			
        		'4' => 'getComment',
        		'5' => 'getCommentsForUser',
        		'6' => 'getCommentsForSubject',
        		'7' => 'flagComment',
        		'8' => 'deleteComment',
        	),
            'BIM_Controller_Challenges' => array(
        		'0' => 'test',
        		'1' => 'submitMatchingChallenge',
        		'2' => 'getChallengesForUser',        			
        		'3' => 'getAllChallengesForUser',
        		'4' => 'acceptChallenge',        		
        		'5' => 'getPreviewForSubject',        		
        		'6' => 'updatePreviewed',
        		'7' => 'submitChallengeWithUsername',
        		'8' => 'getPrivateChallengesForUser',
        		'9' => 'submitChallengeWithChallenger',
        		'10' => 'cancelChallenge',
        		'11' => 'flagChallenge',
        		'12' => 'getChallengesForUserBeforeDate',
    			'13' => 'getPrivateChallengesForUserBeforeDate',
    			'14' => 'submitChallengeWithUsernames',
        	),
    		'BIM_Controller_G' => array( 
        		'1' => 'smsInvites',
        		'2' => 'emailInvites',
        		'3' => 'trackClick',
        		'4' => 'volleyUserPhotoComment',
            ),        
    		'BIM_Controller_Votes' => array( 
        		'0' => 'test',
        		'1' => 'getChallengesByActivity',
        		'2' => 'getChallengesForSubjectID',
        		'3' => 'getChallengeForChallengeID',
        		'4' => 'getChallengesByDate',
        		'5' => 'getVotersForChallenge',
        		'6' => 'upvoteChallenge',
        		'7' => 'getChallengesWithChallenger',
        		'8' => 'getChallengesForSubjectName',
        		'9' => 'getChallengesForUsername',
        		'10' => 'getChallengesWithFriends',
            )
        );
    }
    
    public static function getProxy( $key = null ){
        $c = BIM_Config::proxies();
        $proxy = null;
        if( !empty( $c->useProxies ) ){
            
            if( $key ){
                $key = ( crc32( $key ) >> 16 ) & 0x7fff;
                mt_srand( $key );
            }
            
            $idx = mt_rand( 0, count( $c->proxies ) - 1 );
            
            list( $host, $port ) = explode(':',$c->proxies[ $idx ] );
            
            $proxy = (object) array( 
                'host' => $host,
                'port' => $port,
            );
        }
        return $proxy;
    }
}
