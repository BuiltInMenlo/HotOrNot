<?php 

class BIM_User{
    
    public function __construct( $params = null ){
        $this->dao = new BIM_DAO_Mysql_User( BIM_Config::db() );
        
        if( !is_object($params) ){
            $params = $this->dao->getData( $params );
        }
        
        if( $params ){
            foreach( $params as $prop => $value ){
                $this->$prop = $value;
            }
        }
        
    }
    
    public function isExtant(){
        return ( isset( $this->id ) && $this->id ); 
    }
    
}
