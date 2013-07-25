<?php

return array(
	"servers" => '127.0.0.1:4730', // this can also be an array of strings of format host:post

	"workers" => array(
		array(
			"count" => 5, // number of workers
			"jobs" => array(
				"insta_invite" => array(
					'config' => array(
						'class_prefix_constraint' => 'BIM_Jobs_' // only allow classes under the BIM_Jobs class hierarchy be executed by this (these) worker(s)
		            ), 
		        ),
		    ),
		),
        array(
			"count" => 1, // number of workers
			"jobs" => array(
				"friend_notification" => array(
					'config' => array(
						'class_prefix_constraint' => 'BIM_Jobs_' // only allow classes under the BIM_Jobs class hierarchy be executed by this (these) worker(s)
		            ), 
		        ),
		    ),
		),
        array(
			"count" => 1, // number of workers
			"jobs" => array(
				"find_friends" => array(
					'config' => array(
						'class_prefix_constraint' => 'BIM_Jobs_' // only allow classes under the BIM_Jobs class hierarchy be executed by this (these) worker(s)
		            ), 
		        ),
		    ),
		),
        array(
			"count" => 1, // number of workers
			"jobs" => array(
				"match_push" => array(
					'config' => array(
						'class_prefix_constraint' => 'BIM_Jobs_' // only allow classes under the BIM_Jobs class hierarchy be executed by this (these) worker(s)
		            ), 
		        ),
		    ),
		),
        array(
			"count" => 1, // number of workers
			"jobs" => array(
				"update_user_stats" => array(
					'config' => array(
						'class_prefix_constraint' => 'BIM_Jobs_' // only allow classes under the BIM_Jobs class hierarchy be executed by this (these) worker(s)
		            ), 
		        ),
		    ),
		),
        array(
			"count" => 1, // number of workers
			"jobs" => array(
				"askfm" => array(
					'config' => array(
						'class_prefix_constraint' => 'BIM_Jobs_' // only allow classes under the BIM_Jobs class hierarchy be executed by this (these) worker(s)
		            ), 
		        ),
		    ),
		),
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
		array(
			"count" => 1, // number of workers
			"jobs" => array(
				"webstagram" => array(
					'config' => array(
						'class_prefix_constraint' => 'BIM_Jobs_' // only allow classes under the BIM_Jobs class hierarchy be executed by this (these) worker(s)
		            ), 
		        ),
		    ),
		),
		array(
			"count" => 1, // number of workers
			"jobs" => array(
		        /*
				"harvest_selfies" => array(
					'config' => array(
						'class_prefix_constraint' => 'BIM_Growth_' // only allow classes under the BIM_Jobs class hierarchy be executed by this (these) worker(s)
		            ), 
		        ),
		        */
				"growth" => array(
					'config' => array(
						'class_prefix_constraint' => 'BIM_Jobs_' // only allow classes under the BIM_Jobs class hierarchy be executed by this (these) worker(s)
		            ), 
		        ),
		    ),
		),
    ),

	"log" => "/tmp/gearman_worker_log",
	"worker_locations" => array( 	// this can also be a single string that represents a single worker location
		"/home/shane/dev/hotornot-dev/php/api-shane/bin/gearman/workers/worker.php",
	),
	// 'include_paths' => array( "/home/shane/dev/hotornot-dev/php/api-shane/classes","/home/shane/dev/hotornot-dev/php/api-shane/ui/application/classes","/var/www/discover.getassembly.com/hotornot/api-shane/ui/application","/home/shane/dev/hotornot-dev/php/api-shane/lib" ),
);
