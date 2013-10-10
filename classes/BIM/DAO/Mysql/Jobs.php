<?php

class BIM_DAO_Mysql_Jobs extends BIM_DAO_Mysql{
	
	public function cancelTimedPushes( $userId, $volleyId  ){
	    $volleyId = mysql_escape_string($volleyId);
	    $userId = mysql_escape_string($userId);
	    
	    $id = join('_', array(v,$userId,$volleyId) );
		$sql = "
			update queue.gearman_jobs
			set disabled = 1
			where id like '$id%'
		";
		
		$this->prepareAndExecute($sql);
	}
    
	public function getJobs(){
		$sql = "
			select * 
			from queue.gearman_jobs
			where next_run_time <= now()
				and disabled = 0
		";
		$stmt = $this->prepareAndExecute($sql);
		
		$jobs = new stdClass();
		$jobs->data = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
		
		return $jobs;
	}

	public function updateNextRunTime( $job ){

		$handle = $job->handle;
		$next_run_time = BIM_Cron_Parser::getNextRunDate($job->schedule)->format('Y-m-d H:i:s');
		$id = $job->id;
		
		$sql = "
			update queue.gearman_jobs
			set handle = ?,
			next_run_time = ? 
			where id = ?
		";
		
		$params = array($handle,$next_run_time,$id);
		$this->prepareAndExecute($sql, $params);
	}
	
	public function enableJob( $pesonaName ){
		$sql = "
			update queue.gearman_jobs
			set disabled = 0
			where params like ?
		";
		$params = array( "%\"$pesonaName\"%" );
		$this->prepareAndExecute($sql, $params);
	}
	
	public function disableJob( $pesonaName ){
		$sql = "
			update queue.gearman_jobs
			set disabled = 1
			where params like ?
		";
		$params = array( "%\"$pesonaName\"%" );
		$this->prepareAndExecute($sql, $params);
	}
	
	public function disableJobById( $id ){
		$sql = "
			update queue.gearman_jobs
			set disabled = 1
			where id = ?
		";
		$params = array( $id );
		$this->prepareAndExecute($sql, $params);
	}
	
	/**
INSERT INTO `gearman_jobs` (`id`, `handle`, `next_run_time`, `class`, `name`, `method`, `disabled`, `schedule`, `params`)
VALUES
	('905cfabc-d2cc-11e2-b0a5-386077cdb2f6', 'H:ip-10-154-141-76:11142', '2013-07-16 10:50:00', 'BIM_Jobs_Growth', 'webstagram', 'doRoutines', 1, '* 10-13 * * *', '{\"personaName\":\"idabmack7\", \"routine\":\"browseTags\",\"class\":\"BIM_Growth_Webstagram_Routines\"}');
	 */
	public function create( $job ){
	    
	    $id = !empty( $job->id ) ? $job->id : uniqid( true );
	    $nextRunTime = !empty( $job->nextRunTime ) ? $job->nextRunTime : 0;
	    $class = !empty( $job->class ) ? $job->class : 'BIM_Jobs_Growth';
	    $name = !empty( $job->name ) ? $job->name : '';
	    $method = !empty( $job->method ) ? $job->method : '';
	    $disabled = !empty( $job->disabled ) ? $job->disabled : 0;
	    $schedule = !empty( $job->schedule ) ? $job->schedule : '';
	    $params = !empty( $job->params ) ? json_encode( $job->params ) : '';
	    $isTemp = !empty( $job->is_temp ) ? $job->is_temp : 0;
	    
        $sql = "INSERT IGNORE INTO 
     	queue.`gearman_jobs` (`id`, `handle`, `next_run_time`, `class`, `name`, `method`, `disabled`, `schedule`, `params`, `is_temp`)
    		VALUES
    		(?, '', ?, ?, ?, ?, ?, ?, ?, ?)
    	";
        
		$params = array( $id, $nextRunTime, $class, $name, $method, $disabled, $schedule, $params, $isTemp );

 		$this->prepareAndExecute($sql, $params);
	}
}
