<?php

class BIM_DAO_Mysql_Growth extends BIM_DAO_Mysql{
	
	public function getLastContact( $blogUrl ){
		$sql = "
			select last_contact 
			from growth.tumblr_blog_contact
			where blog_id = ?
		";
		$params = array($blogUrl);
		$stmt = $this->prepareAndExecute($sql, $params);
		$data = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
		if( $data ){
		    $data = $data[0]->last_contact;
		} else {
		    $data = 0;
		}
		return $data;
	}
	
	public function updateLastContact( $blogUrl, $time ){
		$sql = "
			insert into growth.tumblr_blog_contact
			(blog_id, last_contact) values (?,?)
			on duplicate key update last_contact = ?
		";
		$params = array($blogUrl, $time, $time);
		$this->prepareAndExecute($sql, $params);
	}
	
    public function logSuccess( $post, $comment, $network, $name ){
		$sql = "
			insert into growth.contact_log
			( `time`, `url`, `type`, `comment`, `network`, `name` ) 
			values (?,?,?,?,?,?)
		";
		
		$params = array( time(), $post->post_url, $post->type, $comment, $network, $name );
		$this->prepareAndExecute( $sql, $params );
    }
    
	public function getTags( $network = '', $type = '' ){
		$sql = "select * from growth.tags";
		$sqlParams = array();
		$params = array();
		if( $network ){
		    $sqlParams[] = " network = ? ";
		    $params[] = $network;
		}
		
		if( $type ){
		    $sqlParams[] = " type = ? ";
		    $params[] = $type;
		}
		$sqlParams = join(' AND ', $sqlParams );
		
		if( $sqlParams ){
		    $sql .= " WHERE $sqlParams";
		}
		
		$stmt = $this->prepareAndExecute($sql, $params);
		$data = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
		return $data;
	}
	
	public function saveTags( $data ){
		$sql = "
			insert into growth.tags
			(network, type, tags) values (?,?,?)
			on duplicate key update tags = ?
		";
		$params = array( $data->network, $data->type, $data->tags, $data->tags );
		$this->prepareAndExecute( $sql, $params );
	}
	
	
	public function getQuotes(){
		$sql = "select * from growth.quotes";
		$stmt = $this->prepareAndExecute($sql);
		$data = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
		return $data;
	}
	
	public function saveQuotes( $data ){
		$sql = "
			insert into growth.quotes
			(network, type, quotes) values (?,?,?)
			on duplicate key update quotes = ?
		";
		$params = array( $data->network, $data->type, $data->quotes, $data->quotes );
		$this->prepareAndExecute( $sql, $params );
	}
	
	public function saveInviteMsgs( $data ){
	    foreach( $data as $type => $message ){
    	    $sql = "
    			insert into `hotornot-dev`.invite_messages
    			(type, message) values (?,?)
    			on duplicate key update message = ?
    		";
    		$params = array( $type, $message, $message );
    		$this->prepareAndExecute( $sql, $params );
	    }
	}
	
	public function getInviteMsgs(){
		$sql = "select * from `hotornot-dev`.invite_messages";
		$stmt = $this->prepareAndExecute($sql);
		$data = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
		return $data;
	}
		
	public function updateUserStats( $data ){
		$sql = "
			insert into growth.persona_stats_log
			(time,name,network,followers,following,likes) values (?,?,?,?,?,?)
		";
		$params = array( time(), $data->name, $data->network, $data->followers, $data->following, $data->likes );
		$this->prepareAndExecute( $sql, $params );
	}
	
	public function matchNumbers( $numbers ){
	    $placeHolders = join( ',', array_fill(0, count( $numbers ), '?') );
	    $sql = "select * from hotornot-dev.mobile_numbers where number IN( $placeHolders )";
		return $this->prepareAndExecute( $sql, $numbers )->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
	}
	
	public function getTrackingUrl( $network ){
	    $link = null;
	    if( $network ){
	        $sql = "select link from growth.tracking_links where network = ?";
    		$stmt = $this->prepareAndExecute($sql);
    		$data = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
    		if( $data ){
        		$link = $data[0]->link;
    		}
	    }
	    return $link;
	}
}
