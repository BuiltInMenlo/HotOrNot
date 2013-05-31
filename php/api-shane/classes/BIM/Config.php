<?php 

class BIM_Config{
    
    static protected $data = array();
    
    public static function queueFuncs(){
        return array(
            'BIM_Controller_Votes' => array(
                'upvoteChallenge' => array( 'queue' => true ),
            )
        );
    }
    
    public static function staticFuncs(){
        return array(
            'BIM_Controller_Discover' => array(
                'getTopChallengesByVotes' => array( 
                    'redirect' => true,
                	'url' => "http://54.243.163.24/getTopChallengesByVotes.js",
                	"path" => '/var/www/discover.getassembly.com/getTopChallengesByVotes.js.gz'
                ),
            ),
        	'BIM_Controller_Votes' => array(
                'getChallengesByDate' => array( 
                    'redirect' => true,
                	'url' => "http://54.243.163.24/getChallengesByDate.js",
                	"path" => '/var/www/discover.getassembly.com/getChallengesByDate.js.gz'
                ),
                'getChallengesByActivity' => array( 
                    'redirect' => true,
                	'url' => "http://54.243.163.24/getChallengesByActivity.js",
                	"path" => '/var/www/discover.getassembly.com/getChallengesByActivity.js.gz'
                ),
            )
        );
    }
    
    public static function instagram(){
        return (object) array(
            'api' => (object) array(
                'client_id' => '63a3a9e66f22406799e904ccb91c3ab4',
                'client_secret' => 'e09ed527c6cc43c897c80e59d7e9c137',
                'access_token_url' => 'https://api.instagram.com/oauth/access_token',
                'redirect_url' => "http://54.243.163.24/instagram_oauth.php"
        
            ),
            'harvestSelfies' => (object) array(
                'secsInPast' => 3600 * 24,
                'maxItems' => 10000,
                'tags' => array(
                    'selfie', 'me', 'self', 'selfpic', 'bff', 'myface', 'rateme', 'duckface'
                )
            )
        );
    }
    
    public static function tumblr(){
        return (object) array(
            'api' => (object) array(
                'consumerKey' => 'TXB9fZ1LMYthFd8ZPTjV0qRKesFsKo6GIDPG3deOTmtAxxSO6L',
                'consumerSecret' => 'oPos1EyfSnNDgfo7KLmH0I4PhMUNhHCGHLQZA2VJw4dEwUfzuh',
            ),
            'harvestSelfies' => (object) array(
                'secsInPast' => 3600 * 24,
                'maxItems' => 10000,
                'tags' => array(
                    'selfie', 'me', 'self', 'selfpic', 'bff', 'myface', 'rateme', 'duckface'
                )
            )
        );
    }
    
    public static function gearman(){
        return (object) array(
            'servers' => array(  
                array(
                    'host' => '127.0.0.1',
                    'port' => 4730
                ),
            ),
        );
    }
    
    public static function db(){
        return (object) array(
        	'locatorClassName' => 'BIM_Data_Locator_Simple',
        	'locatorClassPath' => 'BIM/Data/Locator/Simple.php',
        	'nodes' => array(
        		(object) array(
        			'writer' => (object) array(
        				'host' => '127.0.0.1',
        				'user' => 'root',
        				'pass' => '',
        				'dbname' => 'hotornot-dev'
        			),
        			'reader' => (object) array(
        				'host' => '127.0.0.1',
        				'user' => 'root',
        				'pass' => '',
        				'dbname' => 'hotornot-dev'
        			),
        		),
        	),
        );
    }
}
