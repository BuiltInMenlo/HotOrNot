<?php 

class BIM_Growth_Persona{
    public function __construct( $data = null ){
        foreach( $data as $prop => $value ){
            $this->$prop = $value;
        }
    }
}
