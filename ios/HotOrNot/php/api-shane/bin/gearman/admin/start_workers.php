<?php
require_once 'vendor/autoload.php';
/**

PHP script for managing PHP based Gearman workers

Copyright (c) 2010, Brian Moon
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice,
   this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
 * Neither the name of Brian Moon nor the names of its contributors may be
   used to endorse or promote products derived from this software without
   specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

**/


/**
 * Implements the worker portions of the pecl/gearman library
 *
 * @author	  Brian Moon <brian@moonspot.net>
 * @copyright   1997-Present Brian Moon
 * @package	 GearmanManager
 *
 */

declare(ticks = 1);

/**
 * Implements the worker portions of the pecl/gearman library
 */
class GearmanPeclManager extends GearmanManager {

	/**
	 * Starts a worker for the PECL library
	 *
	 * @param   array   $worker_list	List of worker functions to add
	 * @return  void
	 *
	 */
	protected function start_lib_worker($worker) {

		$this->load_worker_functions();

		$thisWorker = new GearmanWorker();

		$thisWorker->addOptions(GEARMAN_WORKER_NON_BLOCKING);

		$thisWorker->setTimeout(5000);

		$servers = isset( $worker["servers"] ) ? $worker["servers"] : $this->servers;
		$servers = join(',', $servers);
		$this->log("Adding servers $servers", GearmanManager::LOG_LEVEL_WORKER_INFO);
		$thisWorker->addServers( $servers );

		foreach($worker['jobs'] as $w => $data){
			$this->log("Adding job $w", GearmanManager::LOG_LEVEL_WORKER_INFO);
			// $thisWorker->addFunction($w, array($this, "do_job"), $conf);
			$jobConf = isset($data['config']) ? $data['config'] : array();
			$thisWorker->addFunction($w, $w, $jobConf);
		}

		$start = time();

		while(!$this->stop_work){

			if(@$thisWorker->work() ||
			   $thisWorker->returnCode() == GEARMAN_IO_WAIT ||
			   $thisWorker->returnCode() == GEARMAN_NO_JOBS) {

				if ($thisWorker->returnCode() == GEARMAN_SUCCESS) continue;

				if (!@$thisWorker->wait()){
					if ($thisWorker->returnCode() == GEARMAN_NO_ACTIVE_FDS){
						sleep(5);
					}
				}

			}

			/**
			 * Check the running time of the current child. If it has
			 * been too long, stop working.
			 */
			if($this->max_run_time > 0 && time() - $start > $this->max_run_time) {
				$this->log("Been running too long, exiting", GearmanManager::LOG_LEVEL_WORKER_INFO);
				$this->stop_work = true;
			}

		}

		$thisWorker->unregisterAll();


	}

	/**
	 * Wrapper function handler for all registered functions
	 * This allows us to do some nice logging when jobs are started/finished
	 */
	public function do_job($job) {

		static $objects;

		if($objects===null) $objects = array();

		$w = $job->workload();

		$h = $job->handle();

		$f = $job->functionName();

		if(empty($objects[$f]) && !function_exists($f) && !class_exists($f)){

			@include $this->worker_dir."/$f.php";

			if(class_exists($f) && method_exists($f, "run")){

				$this->log("Creating a $f object", GearmanManager::LOG_LEVEL_WORKER_INFO);
				$objects[$f] = new $f();

			} elseif(!function_exists($f)) {

				$this->log("Function $f not found");
				return;
			}

		}

		$this->log("($h) Starting Job: $f", GearmanManager::LOG_LEVEL_WORKER_INFO);

		$this->log("($h) Workload: $w", GearmanManager::LOG_LEVEL_DEBUG);

		$log = array();

		/**
		 * Run the real function here
		 */
		if(isset($objects[$f])){
			$result = $objects[$f]->run($job, $log);
		} else {
			$result = $f($job, $log);
		}

		if(!empty($log)){
			foreach($log as $l){

				if(!is_scalar($l)){
					$l = explode("\n", trim(print_r($l, true)));
				} elseif(strlen($l) > 256){
					$l = substr($l, 0, 256)."...(truncated)";
				}

				if(is_array($l)){
					foreach($l as $ln){
						$this->log("($h) $ln", GearmanManager::LOG_LEVEL_WORKER_INFO);
					}
				} else {
					$this->log("($h) $l", GearmanManager::LOG_LEVEL_WORKER_INFO);
				}

			}
		}

		$result_log = $result;

		if(!is_scalar($result_log)){
			$result_log = explode("\n", trim(print_r($result_log, true)));
		} elseif(strlen($result_log) > 256){
			$result_log = substr($result_log, 0, 256)."...(truncated)";
		}

		if(is_array($result_log)){
			foreach($result_log as $ln){
				$this->log("($h) $ln", GearmanManager::LOG_LEVEL_DEBUG);
			}
		} else {
			$this->log("($h) $result_log", GearmanManager::LOG_LEVEL_DEBUG);
		}

		/**
		 * Workaround for PECL bug #17114
		 * http://pecl.php.net/bugs/bug.php?id=17114
		 */
		$type = gettype($result);
		settype($result, $type);

		return $result;

	}

	/**
	 * Validates the PECL compatible worker files/functions
	 */
	protected function validate_lib_workers($worker_files) {

		$this->load_worker_functions();
				
		foreach($this->config['workers'] as $worker => $conf){
			foreach( $conf['jobs'] as $job => $data ){
				if( !function_exists( $job ) && (!class_exists( $job ) || !method_exists( $job, "run") ) ){
					$this->log("Function $job not found!");
					posix_kill($this->pid, SIGUSR2);
					exit();
				}
			}
		}
	}
	
	/**
	 * Shows the scripts help info with optional error message
	 */
	protected function show_help($msg = "") {
		if($msg){
			echo "ERROR:\n";
			echo "  ".wordwrap($msg, 72, "\n  ")."\n\n";
		}
		echo "Gearman worker manager script\n\n";
		echo "USAGE:\n";
		echo "  # ".basename(__FILE__)." -h | -c CONFIG [-v] [-d] [-v] [-p PID_FILE]\n\n";
		parent::show_help();
		exit();
	}
}

// ===========================================================
/**
 * Class that handles all the process management
 */
// ===========================================================
class GearmanManager {

	/**
	 * Log levels can be enabled from the command line with -v, -vv, -vvv
	 */
	const LOG_LEVEL_INFO = 1;
	const LOG_LEVEL_PROC_INFO = 2;
	const LOG_LEVEL_WORKER_INFO = 3;
	const LOG_LEVEL_DEBUG = 4;
	const LOG_LEVEL_CRAZY = 5;

	/**
	 * Holds the worker configuration
	 */
	protected $config = array();

	/**
	 * Boolean value that determines if the running code is the parent or a child
	 */
	protected $isparent = true;

	/**
	 * When true, workers will stop look for jobs and the parent process will
	 * kill off all running children
	 */
	protected $stop_work = false;

	/**
	 * The timestamp when the signal was received to stop working
	 */
	protected $stop_time = 0;

	/**
	 * Holds the resource for the log file
	 */
	protected $log_file_handle;

	/**
	 * Flag for logging to syslog
	 */
	protected $log_syslog = false;

	/**
	 * Verbosity level for the running script. Set via -v option
	 */
	protected $verbose = 0;

	/**
	 * The array of running child processes
	 */
	protected $children = array();

	/**
	 * The array of jobs that have workers running
	 */
	protected $jobs = array();

	/**
	 * The PID of the running process. Set for parent and child processes
	 */
	protected $pid = 0;

	/**
	 * PID file for the parent process
	 */
	protected $pid_file = "";

	/**
	 * PID of helper child
	 */
	protected $helper_pid = 0;

	/**
	 * If true, the worker code directory is checked for updates and workers
	 * are restarted automatically.
	 */
	protected $check_code = false;

	/**
	 * Holds the last timestamp of when the code was checked for updates
	 */
	protected $last_check_time = 0;

	/**
	 * When forking helper children, the parent waits for a signal from them
	 * to continue doing anything
	 */
	protected $wait_for_signal = false;

	/**
	 * Directory where worker functions are found
	 */
	protected $worker_locations = array();

	/**
	 * Number of workers that do all jobs
	 */
	protected $do_all_count = 0;

	/**
	 * Maximum time a worker will run
	 */
	protected $max_run_time = 3600;

	/**
	 * Servers that workers connect to
	 */
	protected $servers = array();

	/**
	 * List of functions available for work
	 */
	protected $functions = array();
	
	/**
	 * the options passed  from the command line
	 */
	protected $opts = array();

	/**
	 * Creates the manager and gets things going
	 *
	 */
	public function __construct() {

		if(!function_exists("posix_kill")){
			$this->show_help("The function posix_kill was not found. Please ensure POSIX functions are installed");
		}

		if(!function_exists("pcntl_fork")){
			$this->show_help("The function pcntl_fork was not found. Please ensure Process Control functions are installed");
		}

		$this->pid = getmypid();

		/**
		 * Parse command line options. Loads the config file as well
		 */
		$this->getopt();

		$this->do_command();
		
		/**
		 * Kill the helper if it is running
		 */
		if(isset($this->helper_pid)){
			posix_kill($this->helper_pid, SIGKILL);
		}

		$this->log("Exiting");

	}

	protected function do_command(  ){
		$cmd = $this->opts['k'];
 		echo("executing $cmd\n");
		$this->$cmd();
	}

	protected function get_parent_pid(){
		$parent_pid = 0;
		if( file_exists( $this->pid_file ) && is_file( $this->pid_file ) ){
			$parent_pid = file_get_contents( $this->pid_file );
			if( $parent_pid <= 0 ){
				exit("bad parent pid! less than or equal to 0!\n");
			}
		} else {
			exit("parent pid file ".$this->pid_file." not found!\n");
		}
		return $parent_pid;
	}
	/**
	 * if not graceful, then we send sigterm 5 times to kill everything
	 * if graceful we sgnal with 15
	 */
	protected function stop(){
		$this->pid_file;
		$total_sigs = 1;
		if( $this->opts['g'] ){
			$total_sigs = 1;
		}
		$ppid = $this->get_parent_pid();
		for( $n = 0; $n < $total_sigs; $n++ ){
			posix_kill($ppid,SIGTERM);
		}
	}
	
	protected function restart(){
		$this->stop();
		$this->start();
	}
	
	protected function reload(){
		$ppid = $this->get_parent_pid();
		if( $ppid ){
			posix_kill($ppid, SIGHUP);
		}
	}
	
	/**
	 
		if(isset($this->opts["d"])){
			$pid = pcntl_fork();
			if( $pid > 0 ){ exit(); }
			
			/**
			// detach from the controlling terminal
        	$sid = posix_setsid();
        	
			if ($sid < 0){exit("cannot detach from controlling terminal!");}
			
			$pid = pcntl_fork();
			if($pid>0){ exit(); }
			
			//chdir('/');
			
			// Close open file descriptors
			fclose(STDIN);
			fclose(STDOUT);
			fclose(STDERR);
						
			// Reopen stderr, stdout, stdin to /dev/null
			$STDIN = fopen('/dev/null', 'rb');
			$STDOUT = fopen('&STDIN', 'wb');
			$STDERR = fopen('&STDIN', 'wb');

  			$this->pid = getmypid();
		}

sub gd_daemonize
{
  my $self = shift;
  print "Starting $self->{gd_progname} server\n";
  return if $self->{gd_foreground};
  my $pid;
  POSIX::_exit(0) if $pid = fork;
  die "Could not fork: $!" unless defined $pid;
 
  ## Detach ourselves from the terminal
  croak("Cannot detach from controlling terminal")
      unless POSIX::setsid();
 
  ## Prevent possibility of acquiring a controlling terminal
  $SIG{'HUP'} = 'IGNORE';
 
  POSIX::_exit(0) if $pid = fork;
  die "Could not fork: $!" unless defined $pid;
 
  chdir "/";
 
  ## Clear file creation mask
  umask 0;
 
  ## Close open file descriptors
  close(STDIN);
  close(STDOUT);
  close(STDERR);
 
  ## Reopen stderr, stdout, stdin to /dev/null
  open(STDIN,  "+>/dev/null");
  open(STDOUT, "+>&STDIN");
  open(STDERR, "+>&STDIN");
 
}
	 */
	protected function daemonize(){
		/**
		 * If we want to daemonize, fork here and exit
		 */
		if(isset($this->opts["d"])){
			$pid = pcntl_fork();
			if($pid>0){
				$this->isparent = false;
				exit();
			}

			$this->pid = getmypid();
		}
	}
	
	protected function write_pid(){
		$fp = @fopen($this->opts["p"], "w");
		if($fp){
			fwrite($fp, $this->pid);
			fclose($fp);
		} else {
			$this->show_help("Unable to write PID to ".$this->opts[p].'!' );
		}
		$this->pid_file = $this->opts["p"];
	}
	
	protected function start(){
		
		// daemonize if we needto
		$this->daemonize();

		// write the pid
		$this->write_pid();
		/**
		 * Register signal listeners
		 */
		$this->register_ticks();
		
		/**
		 * Validate workers in the helper process
		 */
		$this->fork_me("validate_workers");

		$this->log("Started with pid $this->pid", GearmanManager::LOG_LEVEL_PROC_INFO);

		/**
		 * Start the initial workers and set up a running environment
		 */
		$this->bootstrap();


		// now start watching the workers
		$this->watch();
		
		$this->cleanup();
	}
	
	protected function cleanup(){
		unlink( $this->pid_file );
	}
	
	public function watch(){
		/**
		 * Main processing loop for the parent process
		 */
		while(!$this->stop_work || count($this->children)) {

			$status = null;

			/**
			 * Check for exited children
			 */
			$exited = pcntl_wait( $status, WNOHANG );

			/**
			 * We run other children, make sure this is a worker
			 */
			if(isset($this->children[$exited])){
				/**
				 * If they have exited, remove them from the children array
				 * If we are not stopping work, start another in its place
				 */
				if($exited) {
					$worker = $this->children[$exited];
					unset($this->children[$exited]);
					$child_pid_file = $this->pid_file.".$exited";
					if( file_exists( $child_pid_file ) ){
						unlink( $child_pid_file );
					}
					$this->log("Child $exited exited ($worker)", GearmanManager::LOG_LEVEL_PROC_INFO);
					if(!$this->stop_work){
						$this->start_worker($worker);
					}
				}
			}


			if($this->stop_work && time() - $this->stop_time > 60){
				$this->log("Children have not exited, killing.", GearmanManager::LOG_LEVEL_PROC_INFO);
				$this->stop_children(SIGKILL);
			}

			/**
			 * php will eat up your cpu if you don't have this
			 */
			usleep(50000);

		}
	}
	
	/**
	 * Handles anything we need to do when we are shutting down
	 *
	 */
	public function __destruct() {
		if($this->isparent){
			if(!empty($this->pid_file) && file_exists($this->pid_file)){
				unlink($this->pid_file);
			}
		}
	}

	/**
	 * Parses the command line options
	 *
	 */
	protected function getopt() {

		// $opts = getopt("ac:dD:h:Hl:o:P:v::w:x:");
		$opts = getopt("hc:dp:v::k:g");
		
		if(isset($opts["h"])){
			$this->show_help();
		}
		
		if(!isset($opts["g"])){
			$opts["g"] = false;
		} else {
			$opts["g"] = true;
		}
		
		if( !isset($opts["k"]) || !preg_match( '/^(?:start|stop|reload|restart)$/i', $opts["k"] ) ){
			$opts["k"] = 'start';
		}
		
		if( !isset( $opts['d'] ) ){
			$opts['d'] = false;
		} else {
			$opts['d'] = true;
		}

		if(!isset($opts["p"])){
			$this->show_help("please provide a pid (-p) file!");
		} else {
			$this->pid_file = $opts['p'];
		}

		if(isset($opts["v"])){
			switch($opts["v"]){
				case false:
					$this->verbose = GearmanManager::LOG_LEVEL_INFO;
					break;
				case "v":
					$this->verbose = GearmanManager::LOG_LEVEL_PROC_INFO;
					break;
				case "vv":
					$this->verbose = GearmanManager::LOG_LEVEL_WORKER_INFO;
					break;
				case "vvv":
					$this->verbose = GearmanManager::LOG_LEVEL_DEBUG;
					break;
				default:
				case "vvvv":
					$this->verbose = GearmanManager::LOG_LEVEL_CRAZY;
					break;
			}
		}

		if(isset($opts["c"]) && !file_exists($opts["c"])){
			$this->show_help("Config file $opts[c] not found.");
		}

		/**
		 * parse the config file
		 */
		if(isset($opts["c"])){
			$this->parse_config($opts["c"]);
		} else {
			$this->show_help("Please provide the path to the config file");
		}
		
		$this->opts = $opts;

	}


	/**
	 * Parses the config file
	 *
	 * @param   string	$file	 The config file. Just pass so we don't have
	 *							  to keep it around in a var
	 */
	protected function parse_config($file) {

		$this->log("Loading configuration from $file");

		if(substr($file, -4) == ".php"){

			$gearman_config = require $file;

		} elseif(substr($file, -4) == ".ini"){

			$gearman_config = parse_ini_file($file, true);

		}

		if(empty($gearman_config)){
			$this->show_help("No configuration found in $file");
		}

		if( isset( $gearman_config['workers'] ) && $gearman_config['workers'] ){
			foreach($gearman_config['workers'] as $worker ){
				if( !isset( $worker['jobs'] ) || !$worker['jobs'] ){
					$this->show_help("no jobs are declared for one of the workers!");
				}
			}
		} else {
			$this->show_help("no workers are declared in the config!");
		}
		
		if( isset($gearman_config["check_code"] ) ){
			$this->check_code = $gearman_config["check_code"];
		} else {
			$this->check_code = false;
		}
		
		if(isset($gearman_config["log"])){
			if($gearman_config["log"] === 'syslog'){
				$this->log_syslog = true;
			} else {
				$this->log_file_handle = @fopen($gearman_config["log"], "a");
				if(!$this->log_file_handle){
					$this->show_help("Could not open log file $gearman_config[log]");
				}
			}
		}
		
		$locations = isset( $gearman_config["worker_locations"] ) ? $gearman_config["worker_locations"] : "./workers";
		foreach( $locations as $worker_location ){
			if(!file_exists($worker_location)){
				$this->show_help("Worker location $worker_location not found");
			}
		}
		$this->set_worker_locations($locations);

		$worker_files = $this->get_worker_files();
		if(empty($worker_files)){
			$this->log("No workers found");
			posix_kill($this->pid, SIGUSR1);
			exit();
		}
		
		if(isset($gearman_config["max_run_time"])){
			$this->max_run_time = (int)$gearman_config["max_run_time"];
		}
		
		if(isset($gearman_config["servers"])){
			if(!is_array($gearman_config["servers"])){
				$this->servers = array($gearman_config["servers"]);
			} else {
				$this->servers = $gearman_config["servers"];
			}
		} else {
			$this->servers = array("127.0.0.1");
		}
		
		if( isset( $gearman_config['include_paths'] ) ){
			$include_path = join(':',$gearman_config['include_paths'] );
			set_include_path( $include_path .":".get_include_path() );
		}
		
		set_error_handler(array($this,'catch_error') );
		set_exception_handler(array($this,'catch_exception') );
		
		$this->config = $gearman_config;

	}
	
	public function set_worker_locations( $locations ){
		if( !is_array( $locations ) ){
			$locations = array( $locations ); 
		}
		$this->worker_locations = $locations;
	}

	/**
	 * Forks the process and runs the given method. The parent then waits
	 * for the child process to signal back that it can continue
	 *
	 * @param   string  $method  Class method to run after forking
	 *
	 */
	protected function fork_me($method){
		$this->wait_for_signal = true;
		$pid = pcntl_fork();
		switch($pid) {
			case 0:
				$this->isparent = false;
				$this->$method();
				break;
			case -1:
				$this->log("Failed to fork");
				$this->stop_work = true;
				break;
			default:
				$this->helper_pid = $pid;
				while($this->wait_for_signal && !$this->stop_work) {
					usleep(5000);
				}
				break;
		}
	}
	
	protected function get_worker_files(){
		$worker_files = array();
		foreach( $this->worker_locations as $worker_dir ){
			if( is_dir( $worker_dir ) ){
				$worker_files = array_merge( $worker_files, glob( $worker_dir."/*.php" ) );
			} else if( is_file( $worker_dir ) ){
				$worker_files[] = $worker_dir;
			}
		}
		return $worker_files;
	}

	protected function load_worker_functions(){
		$worker_files = $this->get_worker_files();
		foreach($worker_files as $file){
		    include_once($file);
		}
	}

	/**
	 * Forked method that validates the worker code and checks it if desired
	 *
	 */
	protected function validate_workers(){

		$parent_pid = $this->pid;
		$this->pid = getmypid();

		$this->log("Helper forked", GearmanManager::LOG_LEVEL_PROC_INFO);
		
		$worker_files = $this->get_worker_files();

		$this->log("Loading workers in ".print_r( $worker_files, 1 ) );

		if(empty($worker_files)){
			$this->log("No workers found");
			posix_kill($parent_pid, SIGUSR1);
			exit();
		}

		$this->validate_lib_workers($worker_files);

		/**
		 * Since we got here, all must be ok, send a CONTINUE
		 */
		posix_kill($parent_pid, SIGCONT);

		if($this->check_code){
			$this->log("Running loop to check for new code", self::LOG_LEVEL_DEBUG);
			$last_check_time = 0;
			while(1) {
				$max_time = 0;
				foreach($worker_files as $f){
					clearstatcache();
					$mtime = filemtime($f);
					$max_time = max($max_time, $mtime);
					$this->log("$f - $mtime $last_check_time", self::LOG_LEVEL_CRAZY);
					if($last_check_time!=0 && $mtime > $last_check_time){
						$this->log("New code found. Sending SIGHUP", self::LOG_LEVEL_PROC_INFO);
						posix_kill($parent_pid, SIGHUP);
						break;
					}
				}
				$last_check_time = $max_time;
				sleep(5);
			}
		} else {
			exit();
		}

	}

	/**
	 * Bootstap a set of workers and any vars that need to be set
	 *
	 */
	protected function bootstrap() {
		/**
		 * Next we loop the workers and ensure we have enough running
		 * for each worker
		 */
		foreach( $this->config['workers'] as $worker ) {
			for($n = 0; $n < $worker["count"]; $n++){
				$this->start_worker($worker);
			}
		}

		/**
		 * Set the last code check time to now since we just loaded all the code
		 */
		$this->last_check_time = time();

	}

	protected function start_worker($worker) {

		$pid = pcntl_fork();

		switch($pid) {

			case 0:
				$this->isparent = false;
				$this->register_ticks(false);
				$this->pid = getmypid();
				$this->start_lib_worker($worker);
				$this->log("Child exiting", GearmanManager::LOG_LEVEL_WORKER_INFO);
				exit();
				break;

			case -1:

				$this->log("Could not fork");
				$this->stop_work = true;
				$this->stop_children();
				break;

			default:

				// parent
				$this->log("Started child $pid ($worker)", GearmanManager::LOG_LEVEL_PROC_INFO);
				$this->children[$pid] = $worker;
				$child_pid_file = $this->pid_file.".$pid";
				error_log("writing pid file $child_pid_file\n");
				file_put_contents( $child_pid_file, $pid );
		}

	}



	/**
	 * Stops all running children
	 */
	protected function stop_children($signal=SIGTERM) {
		$this->log("Stopping children", GearmanManager::LOG_LEVEL_PROC_INFO);

		foreach($this->children as $pid=>$worker){
			$this->log("Stopping child $pid ($worker)", GearmanManager::LOG_LEVEL_PROC_INFO);
			posix_kill($pid, $signal);
			$child_pid_file = $this->pid_file.".$pid";
			if( file_exists( $child_pid_file ) && is_file( $child_pid_file ) ){
				unlink( $child_pid_file );
			}
		}

	}

	/**
	 * Registers the process signal listeners
	 */
	protected function register_ticks($parent=true) {

		if($parent){
			$this->log("Registering signals for parent", GearmanManager::LOG_LEVEL_DEBUG);
			pcntl_signal(SIGTERM, array($this, "signal"));
			pcntl_signal(SIGINT,  array($this, "signal"));
			pcntl_signal(SIGUSR1,  array($this, "signal"));
			pcntl_signal(SIGUSR2,  array($this, "signal"));
			pcntl_signal(SIGCONT,  array($this, "signal"));
			pcntl_signal(SIGHUP,  array($this, "signal"));
		} else {
			$this->log("Registering signals for child", GearmanManager::LOG_LEVEL_DEBUG);
			$res = pcntl_signal(SIGTERM, array($this, "signal"));
			if(!$res){
				exit();
			}
		}
	}

	/**
	 * Handles signals
	 */
	public function signal($signo) {

		static $term_count = 0;

		if(!$this->isparent){

			$this->stop_work = true;

		} else {

			switch ($signo) {
				case SIGUSR1:
					$this->show_help("No worker files could be found");
					break;
				case SIGUSR2:
					$this->show_help("Error validating worker functions");
					break;
				case SIGCONT:
					$this->wait_for_signal = false;
					break;
				case SIGINT:
				case SIGTERM:
					$this->log("Shutting down...");
					$this->stop_work = true;
					$this->stop_time = time();
					$term_count++;
					if($term_count < 5){
						$this->stop_children();
					} else {
						$this->stop_children(SIGKILL);
					}
					break;
				case SIGHUP:
					$this->log("Restarting children", GearmanManager::LOG_LEVEL_PROC_INFO);
					$this->stop_children();
					break;
				default:
				// handle all other signals
			}
		}

	}

	/**
	 * Logs data to disk or stdout
	 */
	protected function log($message, $level=GearmanManager::LOG_LEVEL_INFO) {

		static $init = false;

		if($level > $this->verbose) return;

		if ($this->log_syslog) {
			$this->syslog($message, $level);
			return;
		}

		if(!$init){
			$init = true;

			if($this->log_file_handle){
				$ds = date("Y-m-d H:i:s");
				fwrite($this->log_file_handle, "Date				  PID   Type   Message\n");
			} else {
				//echo "PID   Type   Message\n";
			}

		}

		$label = "";

		switch($level) {
			case GearmanManager::LOG_LEVEL_INFO;
				$label = "INFO  ";
				break;
			case GearmanManager::LOG_LEVEL_PROC_INFO:
				$label = "PROC  ";
				break;
			case GearmanManager::LOG_LEVEL_WORKER_INFO:
				$label = "WORKER";
				break;
			case GearmanManager::LOG_LEVEL_DEBUG:
				$label = "DEBUG ";
				break;
			case GearmanManager::LOG_LEVEL_CRAZY:
				$label = "CRAZY ";
				break;
		}


		$log_pid = str_pad($this->pid, 5, " ", STR_PAD_LEFT);

		if($this->log_file_handle){
			$ds = date("Y-m-d H:i:s");
			$prefix = "[$ds] $log_pid $label";
			fwrite($this->log_file_handle, $prefix." ".str_replace("\n", "\n$prefix ", trim($message))."\n");
		} else {
			$prefix = "$log_pid $label";
			//echo $prefix." ".str_replace("\n", "\n$prefix ", trim($message))."\n";
		}

	}

	/**
	 * Logs data to syslog
	 */
	protected function syslog($message, $level) {
		switch($level) {
			case GearmanManager::LOG_LEVEL_INFO;
			case GearmanManager::LOG_LEVEL_PROC_INFO:
			case GearmanManager::LOG_LEVEL_WORKER_INFO:
			default:
				$priority = LOG_INFO;
				break;
			case GearmanManager::LOG_LEVEL_DEBUG:
				$priority = LOG_DEBUG;
				break;
		}

		if (!syslog($priority, $message)) {
			echo "Unable to write to syslog\n";
		}
	}

	/**
	 * Shows the scripts help info with optional error message
	 */
	protected function show_help($msg = "") {
		echo "OPTIONS:\n";
		echo "  -c </path/to/config> Worker configuration file\n";
		echo "  -d	Daemon, detach and run in the background\n";
		echo "  -h	Shows this help\n";
		echo "  -p  </path/to/pid/file> File to write process ID out to\n";
		echo "  -v	Increase verbosity level by one\n";
		echo "  -k	<start|stop|reload|restart>	The commnd to run.  one of start, stop, restart, reload.  start is the default\n";
		echo "\n";
	}

	function catch_error(  $errno , $errstr , $errfile = null , $errline = '',  $errcontext = null  ){
		//if( $errno != 2 ){
			$this->log( print_r(array( 'errno' => $errno , 'errstr'=>$errstr , 'errfile'=>$errfile, 'errline'=>$errline ),1), GearmanManager::LOG_LEVEL_CRAZY );
		//}
	}
	
	function catch_exception( $exception ){
		$this->log(print_r($exception ,1), GearmanManager::LOG_LEVEL_CRAZY );
	}

}

$mgr = new GearmanPeclManager();
