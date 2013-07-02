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
    
	public function getAvatarUrl() {
		
		// no custom url
		if ($this->img_url == "") {
			
			// has fb login
			if ($this->fb_id != "")
				return ("https://graph.facebook.com/". $this->fb_id ."/picture?type=square");
			
			// has nothing, default
			else
				return ("https://s3.amazonaws.com/hotornot-avatars/defaultAvatar.png");
		}
		
		// use custom
		return ($this->img_url);
	}
}
