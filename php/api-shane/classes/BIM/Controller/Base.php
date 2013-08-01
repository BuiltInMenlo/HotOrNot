<?php 

class BIM_Controller_Base{
    
    protected $actionMethods = null;
    
    public function __construct(){
        $this->staticFuncs = BIM_Config::staticFuncs();
        $this->queueFuncs = BIM_Config::queueFuncs();
        $this->actionMethods = BIM_Config::actionMethods();
        $this->init();
    }
    
    public function init(){}
    
    public function handleReq(){
        $input = (object) ( $_POST ? $_POST : $_GET );
        $class = get_class( $this );
        $action = !empty( $input->action ) && !empty( $this->actionMethods[ $class ][$input->action] ) ? $input->action : null;
        if ( $action ) {
            $method = $this->actionMethods[$class][$action] ;
            return $this->$method();
        }
        return array();
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