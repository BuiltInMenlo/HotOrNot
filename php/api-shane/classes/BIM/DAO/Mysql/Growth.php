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
    
	public function getTags(){
		$sql = "select * from growth.tags";
		$stmt = $this->prepareAndExecute($sql);
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
}
