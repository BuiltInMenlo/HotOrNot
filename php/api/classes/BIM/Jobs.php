<?php 

class BIM_Jobs{
    
    /**
       this function will return true or false depending 
       if the job was queued, which will allow for directly 
       calling the code that would otherwise be executed
       by a worker  if possible.
       
     * @param any $job
     * @param string $name
     * @param string $key
     */
    
    public function enqueueBackground( $job, $name = 'any_job', $key = null ){
        return self::queueBackground( $job, $name, $key );
    }
    
    public static function queueBackground( $job, $name = 'any_job', $key = null ){
        $queued = false;
        $queue = BIM_Resource::getQueue();
        if( $queue ){
            try{
                $queue->doBgJob( $job, $name, $key );
                $queued = true;
            } catch( Exception $e ){
                $queued = false;
            }
        }
        return $queued;
    }
}