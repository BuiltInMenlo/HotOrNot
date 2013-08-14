<?php
require_once 'vendor/autoload.php';

$sql = "select * from growth.persona where network = 'tumblr'";

$db = new BIM_DAO_Mysql_Growth( BIM_Config::db() );

$stmt = $db->prepareAndExecute( $sql );

$personas = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );

foreach( $personas as $persona ){
    if( isset( $argv[1] ) && $argv[1] != $persona->name ){
        continue;
    }
        if( $persona->enabled ){
            $routines = new BIM_Growth_Tumblr_Routines( $persona->name );
            echo "trying to log in and browse for : $persona->name\n";
            //$routines->login();
            try{
                $routines->updateUserStats();
                $sleep = 1;
                echo "logged in and browsed for : $persona->name.  sleeping for $sleep secs.\n";
            } catch( Exception $e ){
                echo "exception for: $persona->name - ".$e->getMessage()."\n";
            }
            try{
                print_r( $routines->getUserInfo()->user->blogs[0]->url."\n\n" );
            } catch (Exception $e){
                echo "another exception for: $persona->name - ".$e->getMessage()."\n\n";
            }
        } else {
            echo "$persona->name is disabled\n\n";
        }
}

function updatePersonaBlogUrl( $blogUrl, $name ){
    $parts = parse_url($blogUrl);
    $blogId = $parts['host'];
    $str = '{"blogName": "'.$blogId.'"}';
    $sql = "update growth.persona set extra = ? where name = ?";
    $params = array( $str, $name );
    $db = new BIM_DAO_Mysql_Growth( BIM_Config::db() );
    echo "updating - " .$str. "\n\n";
    $db->prepareAndExecute( $sql, $params );
}

//$o->followUser( $user );
