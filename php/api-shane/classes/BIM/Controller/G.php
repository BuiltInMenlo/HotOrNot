<?php

class BIM_Controller_G extends BIM_Controller_Base {
    
    public function handleReq(){
        $this->growth = $growth = new BIM_App_G;
        
        $input = null;
        if ( isset( $_POST['action'] ) ) {
            $input = $_POST;
        } else if( isset( $_GET['action'] ) ){
            $input = $_GET;
        }
        
        if ( $input ) {
            if( $input['action'] == 0 ){
                return $growth->volleyUserPhotoComment( $input );
            } else if( $input['action'] == 1 ){
                return $growth->emailInvites( $input );
            } else if( $input['action'] == 2 ){
                return $growth->smsInvites( $input );
            }
        }
    }
}
