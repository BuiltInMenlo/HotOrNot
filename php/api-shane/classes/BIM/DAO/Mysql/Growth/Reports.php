<?php


class BIM_DAO_Mysql_Growth_Reports extends BIM_DAO_Mysql_Growth{
	
	public function getTotalsByPersonaAndNetwork( ){
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
          group by name, day;
    
          ";
		$stmt = $this->prepareAndExecute($sql);
		$counts = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
        return $counts;		
	}
}