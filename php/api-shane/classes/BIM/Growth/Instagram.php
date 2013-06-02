<?php 

class BIM_Growth_Instagram extends BIM_Growth{
    
    protected $instagramApiClient = null; 
    
    public function getInstagramApiClient(){
        if( ! $this->instagramApiClient ){
            $this->instagramApiClient = new BIM_API_Instagram( $this->conf->api );
        }
        return $this->instagramApiClient;
    }
}