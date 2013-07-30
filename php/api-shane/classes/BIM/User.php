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
    
    public static function isVerified( $userId ){
        $dao = new BIM_DAO_ElasticSearch_ContactLists( BIM_Config::elasticSearch() );
        $res = $dao->getPhoneList( (object) array('id' => $userId ) );
        $res = json_decode($res);
        $verified = (!empty( $res->_source->hashed_number ) && $res->_source->hashed_number );
        return $verified;
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
	
	public static function getByUsername( $name ){
        $dao = new BIM_DAO_Mysql_User( BIM_Config::db() );
        $params = $dao->getDataByUsername( $name );
        $me = null;
        if( $params ){
            $me = new self();
            foreach( $params as $prop => $value ){
                $me->$prop = $value;
            }
        }
        return $me;
	}
}
