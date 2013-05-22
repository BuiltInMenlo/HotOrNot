<?php
require_once 'BIM/JobQueue.php';

class BIM_JobQueue_Gearman extends BIM_JobQueue{

	public static function queueStaticPagesJob(){
        $job = array(
        	'class' => 'BIM_App_Votes',
        	'method' => 'createStaticChallengesByDate',
        	'data' => array(),
        );
        
        require_once 'BIM/JobQueue/Gearman.php';
        $q = new BIM_JobQueue_Gearman();
        $q->doBgJob( $job, 'static_pages' );
	}
    
	public function jobStatus( $handle ){
		$gearman = $this->getJobQueue( );
		$stat = $gearman->jobStatus( $handle );
		return $stat;
	}

	public function doBgJob( $data, $name = 'any_job',  $uniqueKey = null ){
		$gmclient = $this->getJobQueue();
		$string = json_encode( $data );
		if( !$name ) $name = 'any_job';
		$handle = $gmclient->doBackground($name, $string, $uniqueKey );
		switch($gmclient->returnCode()) {
			case GEARMAN_WORK_FAIL:
				throw new Exception( "job $name failed! - \n".print_r( array( $data, $string ) , true ) );
			break;
		}
		return $handle;
	}
	
	public function getJobQueue(){
		if(!$this->queue){
	        /* create our object */
	        $gmclient = new GearmanClient();
			foreach( $this->servers as $server ){
	            $gmclient->addServer( $server['host'], $server['port'] );
	        }
	        $this->queue = $gmclient;
		}
		return $this->queue;
	}

	/**
	 * 
	 * The generic job consumer function for a gearman job
	 * 
	 * @param GearmanJob (PECL) $job
	 * @param Array $config - contains some data that can be declared in the config for the worker start script at
	 * 
	 * 	bin/gearman/admin/start_workers.php
	 * 
	 */
	public static function consume( $job, &$config ){
	    $workload = json_decode( $job->workload() );
	    
		$class = $workload->class;
		$method = $workload->method;
		
		// get the class name prefix constraint
		// default is the classname has to start with TH_
		$ptrn = '/^BIM_/';
		if( isset( $config['class_prefix_constraint'] ) && $config['class_prefix_constraint'] ){
			$ptrn = '/^'.$config['class_prefix_constraint'].'/';
		}
		#prevent arbitrary code execution
		if( preg_match( $ptrn, $class ) ){
			if( !class_exists($class) ){
				// transform the class name
				$class_path = preg_replace('/_/','/',$class).'.php';
				// include the class
				require_once $class_path;
			}
			// if the class and method exist
			// execute the job
			
			if( class_exists( $class ) ){
				$obj = new $class();
				if( method_exists( $obj, $method ) ){
					$call_data = array( $obj, $method );
					
					$jobId = uniqid();
					$logFile = '/tmp/job_log';
					
					$time = time();
					$date = new DateTime( "@$time" );
					$date->setTimezone( new DateTimeZone( date_default_timezone_get() ) );
					$date = $date->format('Y-m-d H:i:s T');
				    file_put_contents( $logFile,"$jobId : 0 - begin $class $method $time $date\n", FILE_APPEND );
				    
				    call_user_func( $call_data, $workload );
					
					$time = time();
					$date = new DateTime( "@$time" );
					$date->setTimezone( new DateTimeZone( date_default_timezone_get() ) );
					$date = $date->format('Y-m-d H:i:s T');
					file_put_contents( $logFile,"$jobId : 1 - end $class $method $time $date\n", FILE_APPEND );
					
				} else {
					syslog(LOG_WARNING,"############ method $method() does not exist in class $class. ############");
				}
			} else {
				syslog(LOG_WARNING,"############ class $class is not loaded. ############");
			}
		}
	}
}
