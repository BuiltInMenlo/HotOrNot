<?php
require_once 'BIM/Jobs.php';
require_once 'BIM/JobQueue/Gearman.php';
require_once 'BIM/DAO/Mysql/Jobs.php';

class BIM_Jobs_Gearman extends BIM_Jobs{
	
	protected $queueObj = null;
	protected $config = null;
	
	public function __construct( $config = array() ){
		$this->config = $config;
	}
	
	public function getJobQueue(){
		if(!$this->queueObj){
			$this->queueObj = new BIM_JobQueue_Gearman($this->config->queue);
		}
		return $this->queueObj;
	}

	public function queueJobs( ){
		$jobsDAO = new BIM_DAO_Mysql_Jobs( $this->config->db );
		$jobs = $jobsDAO->getJobs();
		$queue = $this->getJobQueue();
		foreach( $jobs->data as $job ){
			try{
				if( $this->canQueueJob( $job->handle ) ){
					$job->handle = $queue->doBgJob( $job, $job->name );
					$jobsDAO->updateNextRunTime( $job );
				}
			} catch( Exception $e ){
				error_log( print_r( $e, true ) );
			}
		}
	}

	public function canQueueJob( $handle ){
		$return = false;
		$scheduled = $this->isScheduled( $handle );
		if($scheduled) {
			$return = true;
		} 
		 return $return;
	}
	
	public function isScheduled( $handle ){
		$canQueue = false;
		if ( $handle ){
			$gearman = $this->getJobQueue( );
			$stat = $gearman->jobStatus( $handle );
			$known = $stat[0];
			$running = $stat[1];
			if( !$known ){
				$canQueue = true;
			} else if( $running ){
				error_log( print_r( array( "the job is currently running", time() ), 1 ) );
			} else {
				error_log( print_r( array( "the job is in the queue waiting to run", time() ), 1 ) );
			}
		} else {
			$canQueue = true;
		}
		return $canQueue;
	}
}
