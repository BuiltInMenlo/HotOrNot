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
    
    public function getVolleyQuote( $authentic = true ){
        if( $authentic ){
            $quotes = $this->authenticQuotes;
        } else {
            $quotes = $this->adQuotes;
        }
        
        $ct = count( $quotes ) - 1;
        $idx = mt_rand(0, $ct);
        return $quotes[ $idx ];
    }
    
    protected function loadData( $name ){
        $this->dao = new BIM_DAO_Mysql_Persona( BIM_Config::db() );
        $data = $this->dao->getData( $name );
        if( $data ){
            foreach( $data as $row ){
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
                unset( $row->network );
                unset( $row->extra );
            }
        }
    }
    
    public function getTags(){
        if( isset( $this->type ) && $this->type == 'ad' ){
            return BIM_Config::adTags();
        } else {
            return BIM_Config::authenticTags();
        }
    }
}
