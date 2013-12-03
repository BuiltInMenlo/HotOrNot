<?php 
class BIM_Growth_Reports{
    
    protected $report = null;
    
    /*
     * update the 
     * 		totals, 
     * 		totalsByMonth, 
     * 		totalsByDay
     * 
     * 		network totals
     * 		network totals by month
     * 		network total by day
     * 
     * 		persona totals, 
     * 		persona totals By Month, 
     * 		persona totals By Day
     * 
     * 		persona network totals,
     * 		persona network totals By Month, 
     * 		persona network totals By Day
     */
    public function getReportData( $persona ){
        $dao = new BIM_DAO_Mysql_Growth_Reports( BIM_Config::db());
        $logs = $dao->getTotalsByPersonaAndNetwork( $persona );
        foreach( $logs as $log ){
            $this->updateTotals($log);
            $this->updatePersonaTotals($log);
        }
        //print_r($this->report->personaTotals);
        return( $this->report );
    }
        
    public function updatePersonaTotals( $log ){
        $persona = $log->persona;
        if( !isset( $this->report->personaTotals->$persona ) ){
            $this->report->personaTotals->$persona = new stdClass();
        }
        $totals = $this->report->personaTotals->$persona;
        $this->updateCounts($totals, $log);
    }
    
    public function updateTotals( $log ){
        if( !isset( $this->report->totals ) ){
            $this->report->totals = new stdClass();
        }
        $totals = $this->report->totals;
        $this->updateCounts($totals, $log);
    }
    
    protected function updateCounts( $totals, $log ){
        if( !isset( $totals->total ) ){
            $totals->total = 0;
        }
        $totals->total += $log->total;

        $network = $log->network;
        if( !isset( $totals->byNetwork->$network->total ) ){
            $totals->byNetwork->$network->total = 0;
        }
        $totals->byNetwork->$network->total += $log->total;
        
        $month = "{$log->month} {$log->year}";
        if( !isset( $totals->byMonth->$month->total ) ){
            $totals->byMonth->$month->total = 0;
            $totals->byMonth->$month->byNetwork->$network = 0;
        }
        $totals->byMonth->$month->total += $log->total;
        $totals->byMonth->$month->byNetwork->$network += $log->total;
        
        $day = "{$log->month} {$log->day}, {$log->year}";
        if( !isset( $totals->byDay->$day->total ) ){
            $totals->byDay->$day->total = 0;
            $totals->byDay->$day->byNetwork->$network = 0;
        }
        $totals->byDay->$day->total += $log->total;
        $totals->byDay->$day->byNetwork->$network += $log->total;
    }
    
    public function getPersonaNames(){
        $dao = new BIM_DAO_Mysql_Growth_Reports( BIM_Config::db());
        return array_map( function( $el ){ return $el->name; },  $dao->getPersonaNames());
    }
    
    public function getSocialStats( $network = '', $personaName = '' ){
        $stats = $this->getSocialStatsGeneral( $network = '', $personaName = '' );        
        $askfmStats = $this->getSocialStatsForAskfm( $personaName );
        
        foreach( $askfmStats as $persona => $networkStats ){
            foreach( $networkStats as $network => $networkData ){
                $stats->$persona->$network = $networkData;
            }
        }
        
        return $stats;        
    }
    
    public function getSocialStatsGeneral( $network = '', $personaName = '' ){
        $dao = new BIM_DAO_Mysql_Growth_Reports( BIM_Config::db());
        // the data returned here is sorted by time asc
        $ss = $dao->getSocialStats( $network, $personaName );
        $stats = ( object ) array();
        foreach( $ss as $socialStats ){
            $persona = $socialStats->persona;
            $network = $socialStats->network;
            if(!isset( $stats->$persona->$network ) ){
                 $stats->$persona->$network = array($socialStats);
            }
            $latest = end( $stats->$persona->$network );

            $socialStats->followers_diff = $socialStats->followers - $latest->followers;
            $socialStats->following_diff = $socialStats->following - $latest->following;
            $socialStats->likes_diff = $socialStats->likes - $latest->likes;
            if( $latest !== $socialStats ){
                array_push( $stats->$persona->$network, $socialStats );
            }
        }
        return $stats;        
    }
    
    public function getSocialStatsForAskfm( $persona = '' ){
        $dao = new BIM_DAO_Mysql_Growth_Reports( BIM_Config::db());
        // the data returned here is sorted by time asc
        $ss = $dao->getSocialStatsForAskfm( $persona );
        $stats = (object) array();
        foreach( $ss as $socialStats ){
            $persona = $socialStats->persona;
            $network = $socialStats->network;
            if(!isset( $stats->$persona->$network ) ){
                $stats->$persona->$network = array($socialStats);
            }
            $latest = end( $stats->$persona->$network );

            $socialStats->gifts_diff = $socialStats->gifts - $latest->gifts;
            $socialStats->likes_diff = $socialStats->likes - $latest->likes;
            if( $latest !== $socialStats ){
                array_push( $stats->$persona->$network, $socialStats );
            }
        }
        return $stats;
    }
}