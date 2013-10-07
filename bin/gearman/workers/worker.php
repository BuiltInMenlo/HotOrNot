<?php
require_once 'vendor/autoload.php';
/**
 * 
##### shell aliases for linux:

alias gshutdown='(echo shutdown ; sleep 0.1) | nc 127.0.0.1 4730'
alias gst='(echo status ; sleep 0.1) | nc 127.0.0.1 4730'
alias gw_shutdown='pkill -9 -f php;'
alias gwstart='nohup /usr/bin/php /var/www/discover.getassembly.com/hotornot/api-shane/bin/gearman/admin/start_workers.php -c /var/www/discover.getassembly.com/hotornot/api-shane/bin/gearman/admin/config.php -p /tmp/gearman_worker.pid -d -k start > /tmp/worker_start.log 2>&1 &'
alias gwstop='/usr/bin/php /var/www/discover.getassembly.com/hotornot/api-shane/bin/gearman/admin/start_workers.php -c /var/www/discover.getassembly.com/hotornot/api-shane/bin/gearman/admin/config.php -p /tmp/gearman_worker.pid -d -k stop > /tmp/worker_stop.log 2>&1'
 
 * 
 * This is a generic job executor.
 * 
 * The different functions all have call process().  the reason for having different names is so we can separate jobs from one another.
 * for example we might want a job exclusively for sending newsletter emails.  so we would create a function named something like email_newsletter
 * then, when we are queueing a job we queue to the email_newsletter job.
 * 
 * this way we know that no other jobs are going to get in the way of the workers that are processing email jobs
 * 
 */

/**
 * 
 * will execute any job under the BIM class heirarchy
 * @param GearmanJob (PECL) $job
 * @param Array $config - contains some data that can be declared in the config for the GearmanManager daemon manager class
 */
function any_job( $job, &$config ){ BIM_JobQueue_Gearman::consume($job, $config); }

// all the functions below call any_job()
function email( $job, &$config ){ any_job($job, $config); }
function static_pages( $job, &$config ){ any_job($job, $config); }
function upvote( $job, &$config ){ any_job($job, $config); }
function harvest_selfies( $job, &$config ){ any_job($job, $config); }
function growth( $job, &$config ){ any_job($job, $config); }
function webstagram( $job, &$config ){ any_job($job, $config); }
function askfm( $job, &$config ){ any_job($job, $config); }
function update_user_stats( $job, &$config ){ any_job($job, $config); }
function match_push( $job, &$config ){ any_job($job, $config); }
function push( $job, &$config ){ any_job($job, $config); }
function find_friends( $job, &$config ){ any_job($job, $config); }
function friend_notification( $job, &$config ){ any_job($job, $config); }
function insta_invite( $job, &$config ){ any_job($job, $config); }
function tumblr_invite( $job, &$config ){ any_job($job, $config); }
function tumblr( $job, &$config ){ any_job($job, $config); }
function smsinvites( $job, &$config ){ any_job($job, $config); }
function acceptchallengeasdefaultuser( $job, &$config ){ any_job($job, $config); }
function firstruncomplete( $job, &$config ){ any_job($job, $config); }
function flaguser( $job, &$config ){ any_job($job, $config); }
function purgeuservolleys( $job, &$config ){ any_job($job, $config); }
function process_volley_images( $job, &$config ){ any_job($job, $config); }
function process_profile_images( $job, &$config ){ any_job($job, $config); }
function createcampaign( $job, &$config ){ any_job($job, $config); }
function process_image( $job, &$config ){ any_job($job, $config); }
function process_user_image( $job, &$config ){ any_job($job, $config); }
