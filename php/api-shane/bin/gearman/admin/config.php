<?php

return array(
	"servers" => '127.0.0.1:4730', // this can also be an array of strings of format host:post

	"workers" => array(
		// worker 1
		array(
			"count" => 1, // number of workers
			"jobs" => array(
				"static_pages" => array(
					'config' => array(
						'class_prefix_constraint' => 'BIM_Jobs_' // only allow classes under the BIM_Jobs class hierarchy be executed by this (these) worker(s)
		            ), 
		        ),
		    ),
		),
		array(
			"count" => 1, // number of workers
			"jobs" => array(
				"upvote" => array(
					'config' => array(
						'class_prefix_constraint' => 'BIM_Jobs_' // only allow classes under the BIM_Jobs class hierarchy be executed by this (these) worker(s)
		            ), 
		        ),
		    ),
		),
	),

	"log" => "syslog",
	"worker_locations" => array( 	// this can also be a single string that represents a single worker location
		"/var/www/discover.getassembly.com/hotornot/api-shane/bin/gearman/workers/worker.php",
	),
	'include_paths' => array( "/var/www/discover.getassembly.com/hotornot/api-shane/classes","/var/www/discover.getassembly.com/hotornot/api-shane/ui/application/classes","/var/www/discover.getassembly.com/hotornot/api-shane/ui/application","/var/www/discover.getassembly.com/hotornot/api-shane/lib" ),
);
