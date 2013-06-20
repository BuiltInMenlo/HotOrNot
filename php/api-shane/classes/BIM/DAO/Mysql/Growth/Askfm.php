<?php

class BIM_DAO_Mysql_Growth_Askfm extends BIM_DAO_Mysql_Growth{
	
	public function getQuestion( $questionId ){
		$sql = "
			select * 
			from growth.askfm_answer_log
			where qid = ?
		";
		$params = array($questionId);
		$stmt = $this->prepareAndExecute($sql, $params);
		$data = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
		return $data;
	}
    
	public function getLastContact( $userId ){
		$sql = "
			select last_contact 
			from growth.askfm_user_contact
			where user_id = ?
		";
		$params = array($userId);
		$stmt = $this->prepareAndExecute($sql, $params);
		$data = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
		if( $data ){
		    $data = $data[0]->last_contact;
		} else {
		    $data = 0;
		}
		return $data;
	}
	
	public function updateLastContact( $userId, $time ){
		$sql = "
			insert into growth.askfm_user_contact
			(user_id, last_contact) values (?,?)
			on duplicate key update last_contact = ?
		";
		$params = array( $userId, $time, $time );
		$this->prepareAndExecute($sql, $params);
	}

    public function logAnswerSuccess( $qId, $text, $answer, $userId, $username, $name ){
		$sql = "
			insert into growth.askfm_answer_log
			( `time`, `qid`, `qtext`, `qanswer`, `user_id`, `username`, `network`, `name` ) values (?,?,?,?,?,?,?,?)
		";
		$params = array( time(), $qId, $text, $answer, $userId, $username, 'askfm', $name );
		
		$this->prepareAndExecute( $sql, $params );
    }
	
    public function logSuccess( $id, $comment, $name ){
		$sql = "
			insert into growth.webstagram_contact_log
			( `time`, `url`, `type`, `comment`, `network`, `name` ) values (?,?,?,?,?,?)
		";
		$params = array( time(), $id, 'photo', $comment, 'askfm', $name );
		
		$this->prepareAndExecute( $sql, $params );
    }
    
	public function updateUserStats( $data ){
		$sql = "
			insert into growth.askfm_persona_stats_log
			(time,name,network,gifts,likes) values (?,?,?,?,?)
		";
		$params = array( time(), $data->name, $data->network, $data->gifts, $data->likes );
		$this->prepareAndExecute( $sql, $params );
	}
}
