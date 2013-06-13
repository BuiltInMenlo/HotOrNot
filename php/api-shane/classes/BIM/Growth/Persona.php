<?php 

class BIM_Growth_Persona{
    protected $authenticQuotes = array();
    protected $adQuotes = array();
    
    public function __construct( $params = null ){
        if( is_object($params) ){
            foreach( $params as $prop => $value ){
                $this->$prop = $value;
            }
        } else {
            $this->loadData( $params );
        }
        $this->adQuotes = BIM_Config::adQuotes();
        $this->authenticQuotes = BIM_Config::authenticQuotes();
    }
    
    public function getTumblrBlogName(){
        $blogName = '';
        if( isset( $this->tumblr->blogName ) ){
            $blogName = $this->tumblr->blogName;
        } else {
            $blogName = $this->tumblr->name.'.tumblr.com';
        }
        return $blogName;
    }
    
    public function getVolleyQuote( ){
        if( isset( $this->type ) && $this->type == 'ad' ){
            $quotes = $this->adQuotes;
        } else {
            $quotes = $this->authenticQuotes;
        }
        
        $ct = count( $quotes ) - 1;
        $idx = mt_rand(0, $ct);
        return $quotes[ $idx ];
    }
    
    protected function loadData( $name ){
        $this->dao = new BIM_DAO_Mysql_Persona( BIM_Config::db() );
        $data = $this->dao->getData( $name );
        if( $data ){
            $type = 'authentic';
            foreach( $data as $row ){
                if( isset( $row->type ) ){
                    $type = $row->type;
                }
                $network = $row->network;
                $this->$network = $row;
                if( $row->extra ){
                    $extra = json_decode( $row->extra );
                    if( $extra ){
                        foreach( $extra as $prop => $value ){
                            $this->$network->$prop = $value;
                        }
                    }
                }
                unset( $row->type );
                unset( $row->network );
                unset( $row->extra );
            }
            $this->name = $name;
            $this->type = $type;
        }
    }
    
    public function getTags(){
        if( isset( $this->type ) && $this->type == 'ad' ){
            $tags = BIM_Config::adTags();
        } else {
            $tags = BIM_Config::authenticTags();
        }
        shuffle($tags);
        $tags = array_slice( $tags, 0, $this->numTagsToRetrieveInsta() );
        return $tags;
    }
    
    public function numTagsToRetrieveInsta( ){
        if( $this->type == 'ad' ){
            return 1;
        } else {
            return 1;
        }
    }
    
    public function getLoginWaitTime( ){
        if( $this->type == 'ad' ){
            return mt_rand(180, 300);
        } else {
            return mt_rand(180, 300);
        }
    }
    
    public function getTagIdWaitTime( ){
        if( $this->type == 'ad' ){
            return mt_rand(4, 6);
        } else {
            return mt_rand(4, 6);
        }
    }
    
    public function getBrowseTagsCommentWait( ){
        if( $this->type == 'ad' ){
            return mt_rand(15, 30);
        } else {
            return mt_rand(15, 30);
        }
    }
    
    public function getBrowseTagsTagWait( ){
        if( $this->type == 'ad' ){
            return mt_rand(120, 420);
        } else {
            return mt_rand(120, 420);
        }
    }
    
    // idsPerTagInsta
    public function idsPerTagInsta( ){
        if( $this->type == 'ad' ){
            return 5;
        } else {
            return 5;
        }
    }
    
}
