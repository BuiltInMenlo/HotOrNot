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
        $this->adQuotes = BIM_Config::adQuotes('askfm');
        $this->authenticQuotes = BIM_Config::authenticQuotes('askfm');
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
    
    public function getVolleyQuote( $network = '' ){
        if( isset( $this->type ) && $this->type == 'ad' ){
            $quotes = BIM_Config::adQuotes( $network );
        } else {
            $quotes = BIM_Config::authenticQuotes( $network );
        }
        
        $ct = count( $quotes ) - 1;
        $idx = mt_rand(0, $ct);
        $quote = $quotes[ $idx ];
        if( mt_rand(1,100) >= 50 ){
            $quote .= " ".$this->getTrackingUrl( $network );
        }
        return $quote;
    }
    
    public function getTrackingUrl( $network = '' ){
        if( !$network ){
            $network = 'instagram';
        }
        $networkSymbol = 'b';
        
        if( $network == 'tumblr' ){
            $networkSymbol = 'a';
        } else if( $network == 'askfm' ){
            $networkSymbol = 'c';
        }
        $url = "http://getvolleyapp.com/$networkSymbol/$this->name";
        return $url;
    }
    
    public function getVolleyAnswer( $network = '' ){
        if( isset( $this->type ) && $this->type == 'ad' ){
            $quotes = BIM_Config::adTags( $network );
        } else {
            $quotes = BIM_Config::authenticTags( $network );
        }
        
        $ct = count( $quotes ) - 1;
        $idx = mt_rand(0, $ct);
        $quote = $quotes[ $idx ];
        if( mt_rand(1,100) >= 50 ){
            $quote .= " ".$this->getTrackingUrl( $network );
        }
        return $quote;
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
    
    public function numQuestionsToGet( ){
        return mt_rand(1, 10);
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
    
    public function trackInboundClick( $networkId, $referer = '', $ua = '' ){
        $dao = new BIM_DAO_Mysql_Persona( BIM_Config::db() );
        $dao->trackInboundClick($this->name, $networkId, $referer, $ua );
        return true;
    }
    
    public function isExtant(){
        return isset( $this->name ) && $this->name;
    }
    
    public function getAskfmSearchName(){
        $names = array(
            "Breann",
            "Leonie",
            "Reanna",
            "Brittany",
            "Aide",
            "Carolynn",
            "Lorene",
            "Bridgette",
            "Lissette",
            "Simone",
            "Maudie",
            "Waylon",
            "Michaela",
            "Kareen",
            "Kerry",
            "Maragret",
            "Daria",
            "Augustine",
            "Rowena",
            "Kari",
            "Maryetta",
            "Albert",
            "Blondell",
            "Laquita",
            "Andy",
            "Michel",
            "Alix",
            "Melony",
            "Naoma",
            "Kandra",
            "Herschel",
            "Marc",
            "Lanelle",
            "Barbara",
            "Maegan",
            "Shanae",
            "Sixta",
            "Aleida",
            "Garland",
            "Erick",
            "Imogene",
            "Gertude",
            "Eryn",
            "Margaretta",
            "Domingo",
            "Hoa",
            "Shanel",
            "Sophie",
            "Yetta",
            "Alishia",
        );

        $idx = mt_rand(0, count( $names ) - 1);
        return $names[ $idx ];
    }
    
    public function create(){
        $dao = new BIM_DAO_Mysql_Persona( BIM_Config::db() );
        if( !empty( $this->username ) && !empty( $this->password ) ){
            $data = (object) array(
                'username' => $this->username,
                'password' => $this->password,
                'network' => $this->network,
            );
            
            if( !empty($this->extra) ){
                $data->extra = json_encode($this->extra);
            }
            
            $dao->create($data);
            return new self( $data->username );
        }
    }
    
}
