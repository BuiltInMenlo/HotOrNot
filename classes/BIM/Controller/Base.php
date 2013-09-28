<?php 

class BIM_Controller_Base{
    
    protected $actionMethods = null;
    public $user = null;
    
    public function __construct(){
        $this->staticFuncs = BIM_Config::staticFuncs();
        $this->queueFuncs = BIM_Config::queueFuncs();
        $this->init();
    }
    
    public function init(){}
    
    protected function useQueue( $params ){
        $class = $params[0];
        $method = $params[1];
        
        return isset( $this->queueFuncs[ $class ][ $method ]['queue'] ) 
                && $this->queueFuncs[ $class ][ $method ]['queue'] ;
    }
    
    protected function isStatic( $params ){
        $class = $params[0];
        $method = $params[1];
        
        return isset( $this->staticFuncs[ $class ][ $method ]['redirect'] ) 
                        && $this->staticFuncs[ $class ][ $method ]['redirect'] 
                        && isset( $this->staticFuncs[ $class ][ $method ]['url'] );
    }
    
    public function resolveUserId( $userId ){
        $userId = !empty( $this->user ) ? $this->user->id : $userId;
        return $userId;
    }
    
    public function getInput(){
        if( empty( $this->input ) ){
             $this->input = (object) ( $_POST ? $_POST : $_GET );
        }
        return $this->input;
    }
    
    public function normalizeVolleyImgUrl( $imgUrl ){
        return str_replace( 'hotornot-challenges.s3.amazonaws.com', 'd1fqnfrnudpaz6.cloudfront.net', $imgUrl );
    }

    public function normalizeAvatarImgUrl( $imgUrl ){
        if( preg_match('@^http.*?http@', $imgUrl ) ){
            file_put_contents('/tmp/piclog', $imgUrl."\n", FILE_APPEND);
            $imgUrl = preg_replace( '@^(?:https*://.*?)+(https*://.+?\.jpg).+?\.jpg$@', '$1', $imgUrl );
        }        
        if( strstr($imgUrl,'s3.amazonaws.com/hotornot-avatars') ){
            return str_replace( 's3.amazonaws.com/hotornot-avatars', 'd3j8du2hyvd35p.cloudfront.net', $imgUrl );
        } else {
            return str_replace( 'hotornot-avatars.s3.amazonaws.com', 'd3j8du2hyvd35p.cloudfront.net', $imgUrl );
        }
    }
}