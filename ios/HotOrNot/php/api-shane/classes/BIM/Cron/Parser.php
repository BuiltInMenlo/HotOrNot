<?php

/**
 * Cron schedule parser 
 */
class BIM_Cron_Parser
{
    /**
     * @var array Cron parts
     */
    private static $cronParts;

    /**
     * Check if a date/time unit value satisfies a crontab unit
     *
     * @param DateTime $nextRun Current next run date
     * @param string $unit Date/time unit type (e.g. Y, m, d, H, i)
     * @param string $schedule Cron schedule variable
     *
     * @return bool Returns TRUE if the unit satisfies the constraint
     */
    public static function unitSatisfiesCron(DateTime $nextRun, $unit, $schedule)
    {
    	$satisfies = false;

        $unitValue = (int)$nextRun->format($unit);

        if ($schedule == '*') {
            $satisfies = true;
        } else {
        	$elements = explode( ',', $schedule );
			foreach( $elements as $element ){
		        if (strpos($element, '-')) {
		            list($first, $last) = explode('-', $element);
		            $satisfies = ($unitValue >= $first && $unitValue <= $last);
		        } else if (strpos($element, '*/') !== false) {
		            list($delimiter, $interval) = explode('*/', $element);
		            $satisfies = ($unitValue % (int)$interval == 0);
		        } else {
		            $satisfies = ($unitValue == (int)$element);
		        }
				if( $satisfies ){
					break;
				}
			}
		}
		
    	return $satisfies;
    }
	
	/**
	 * this function will turn the time schedule notation into a 
	 * human readable sring in the emglish language
	 * 
	 * @param object $schedule
	 * @return 
	 */
	public static function toEnglish( $schedule ){
		
	}

    /**
     * Get the date in which the cron will run next
     *
     * @param string|DateTime (optional) $fromTime Set the relative start time
     * @param string $currentTime (optional) Optionally set the current date
     *      time for testing purposes
     *
     * @return DateTime
     */
    public static function getNextRunDate($schedule, $fromTime = 'now', $currentTime = 'now'){
    	self::setSchedule( $schedule );
        $nextRun = ($fromTime instanceof DateTime) ? $fromTime : new DateTime($fromTime);
        $nextRun->setTime($nextRun->format('H'), $nextRun->format('i'), 0);
        $currentDate = ($currentTime instanceof DateTime) ? $currentTime : new DateTime($currentTime);
        $i = 0;

        // Set a hard limit to bail on an impossible date
        while (++$i && $i < 100000) {

            // Adjust the month until it matches.  Reset day to 1 and reset time.
            if (!self::unitSatisfiesCron($nextRun, 'm', self::getSchedule('month'))) {
                $nextRun->add(new DateInterval('P1M'));
                $nextRun->setDate($nextRun->format('Y'), $nextRun->format('m'), 1);
                $nextRun->setTime(0, 0, 0);
                continue;
            }

            // Adjust the day of the month by incrementing the day until it matches. Reset time.
            if (!self::unitSatisfiesCron($nextRun, 'd', self::getSchedule('day_of_month'))) {
                $nextRun->add(new DateInterval('P1D'));
                $nextRun->setTime(0, 0, 0);
                continue;
            }

            // Adjust the day of week by incrementing the day until it matches.  Resest time.
            if (!self::unitSatisfiesCron($nextRun, 'N', self::getSchedule('day_of_week'))) {
                $nextRun->add(new DateInterval('P1D'));
                $nextRun->setTime(0, 0, 0);
                continue;
            }

            // Adjust the hour until it matches the set hour.  Set seconds and minutes to 0
            if (!self::unitSatisfiesCron($nextRun, 'H', self::getSchedule('hour'))) {
                $nextRun->add(new DateInterval('PT1H'));
                $nextRun->setTime($nextRun->format('H'), 0, 0);
                continue;
            }

            // Adjust the minutes until it matches a set minute
            if (!self::unitSatisfiesCron($nextRun, 'i', self::getSchedule('minute'))) {
                $nextRun->add(new DateInterval('PT1M'));
                continue;
            }

            // If the suggested next run time is not after the current time, then keep iterating
            if (is_string($fromTime) && $currentDate >= $nextRun) {
                $nextRun->add(new DateInterval('PT1M'));
                continue;
            }

            break;
        }

        return $nextRun;
    }

    
    public static function isValidSchedule( $schedule ){
    	$valid = false;
        $cronParts = preg_split('/\s+/', $schedule);
        if (count($cronParts) == 5) {
        	$valid = true;
        }
        return $valid;
    }

    public static function setSchedule( $schedule ){
    	$schedule = trim($schedule);
    	if( self::isValidSchedule( $schedule ) ){
        	self::$cronParts = preg_split('/\s+/', $schedule);
    	} else {
            throw new InvalidArgumentException($schedule . ' is not a valid cron schedule string');
        }
    }
    
    /**
     * Get all or part of the cron schedule string
     *
     * @param string $part Specify the part to retrieve or NULL to get the full
     *      cron schedule string.  $part can be the PHP date() part of a date
     *      formatted string or one of the following values:
     *      NULL, 'minute', 'hour', 'month', 'day_of_week', 'day_of_month'
     *
     * @return string
     */
    public static function getSchedule($part = null)
    {
        switch ($part) {
            case 'minute': case 'i':
                return self::$cronParts[0];
            case 'hour': case 'H':
                return self::$cronParts[1];
            case 'day_of_month': case 'd':
                return self::$cronParts[2];
            case 'month': case 'm':
                return self::$cronParts[3];
            case 'day_of_week': case 'N':
                return self::$cronParts[4];
            default:
                return implode(' ', self::$cronParts);
        }
    }
}
