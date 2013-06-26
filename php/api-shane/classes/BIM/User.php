<?php 

class BIM_User{
    
    public function __construct( $params = null ){
        if( is_object($params) ){
            foreach( $params as $prop => $value ){
                $this->$prop = $value;
            }
        } else {
            $this->loadData( $params );
        }
    }
    
    protected function loadData( $id ){
        $this->dao = new BIM_DAO_Mysql_User( BIM_Config::db() );
        $data = $this->dao->getData( $id );
        if( $data ){
            foreach( $data as $prop => $value ){
                $this->$prop = $value;
            }
        }
    }
}
