<?php 
require_once 'BIM/JobQueue/Gearman.php';
require_once 'BIM/Config.php';
class BIM_Resource{
    
    protected static $queue = null;
    
    public static function getQueue(){
        if( !self::$queue ){
            self::$queue = new BIM_JobQueue_Gearman( BIM_Config::gearman() );
        }
        return self::$queue;
    }
}