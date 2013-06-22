<?php 

class BIM_Controller_Base{
    
    public function __construct(){
        $this->staticFuncs = BIM_Config::staticFuncs();
        $this->queueFuncs = BIM_Config::queueFuncs();
        $this->init();
    }
    
    public function init(){}
    
    public function handleReq(){
        $res = false;
        if( isset( $this->method ) ){
            $method = $this->method;
            $res = $this->$method();
        }
        return $res;
    }
	
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
}