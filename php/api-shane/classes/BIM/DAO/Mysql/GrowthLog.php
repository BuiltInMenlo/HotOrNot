<?php

class BIM_DAO_Mysql_Growth extends BIM_DAO_Mysql{
	
	public function logSuccess(){
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
	
	public function logError(){
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
	
}
