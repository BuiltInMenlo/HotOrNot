<?php

class BIM_DAO_Mysql_Growth_Reports extends BIM_DAO_Mysql_Growth{
	
	public function getTotalsByPersonaAndNetwork(  $persona = '' ){
	    $where = '';
        $params = array();
	    if( $persona ){
    	  $where = ' where name = ? ';
    	  $params[] = $persona;
    	  $params[] = $persona;
	    }
		$sql = "
    	  select
              name as persona, 
              network, 
              MONTHNAME( from_unixtime(time) ) as month,      
              DAYOFMONTH( from_unixtime(time) ) as day,
              YEAR( from_unixtime(time) ) as year,
              count(*) as total     
          from      
    	      growth.contact_log
    	  $where
          group by name, day      
    
          union     
          
          select     
              name as persona,     
              network,     
              MONTHNAME( from_unixtime(time) ) as month,
              DAYOFMONTH( from_unixtime(time) ) as day,
              YEAR( from_unixtime(time) ) as year,
              count(*) as total
          from
    	      growth.webstagram_contact_log
    	  $where
          group by name, day;
    
          ";
		$stmt = $this->prepareAndExecute($sql, $params);
		$counts = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
        return $counts;		
	}
	
	public function getPersonaNames(){
	    $sql = "select name from growth.persona where enabled != 0";
		$stmt = $this->prepareAndExecute($sql);
		return $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
	}
}