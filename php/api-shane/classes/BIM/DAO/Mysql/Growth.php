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
	
    public function logSuccess( $post, $comment, $network ){
		$sql = "
			insert into growth.contact_log
			( `time`, `url`, `type`, `comment`, `network` ) values (?,?,?,?,?)
		";
		
		$params = array( time(), $post->post_url, $post->type, $comment, $network  );
		$this->prepareAndExecute( $sql, $params );
    }
}
