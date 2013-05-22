<?php
require_once 'BIM/DAO/Mysql.php';
require_once 'BIM/Cron/Parser.php';

class BIM_DAO_Mysql_Jobs extends BIM_DAO_Mysql{
	
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
	
}
