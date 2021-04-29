global class DateUtilities {



	private List<Boolean> businessDay = new Boolean[7];
	private List<Time> startHours = new Time [7];
	private List<Time> endHours = new Time [7];
	private Date knownSunday = date.newInstance(2013, 1, 6);

	// Constructor creates businessDay array
	public DateUtilities() {

	    BusinessHours bh =
	      	[Select
	        	SundayStartTime, MondayStartTime, TuesdayStartTime, WednesdayStartTime, ThursdayStartTime, FridayStartTime, SaturdayStartTime,
	        	SundayEndTime, MondayEndTime,TuesdayEndTime, WednesdayEndTime, ThursdayEndTime, FridayEndTime,SaturdayEndTime
	      	From BusinessHours 
	      	Where IsDefault=true];

	    businessDay[0] = (bh.SundayStartTime != null);
	    businessDay[1] = (bh.MondayStartTime != null);
	    businessDay[2] = (bh.TuesdayStartTime != null);
	    businessDay[3] = (bh.WednesdayStartTime != null);
	    businessDay[4] = (bh.ThursdayStartTime != null);
	    businessDay[5] = (bh.FridayStartTime != null);
	    businessDay[6] = (bh.SaturdayStartTime != null);
	 
	    startHours[0] = bh.SundayStartTime;
	    startHours[1] = bh.MondayStartTime;
	    startHours[2] = bh.TuesdayStartTime;
	    startHours[3] = bh.WednesdayStartTime;
	    startHours[4] = bh.ThursdayStartTime;
	    startHours[5] = bh.FridayStartTime;
	    startHours[6] = bh.SaturdayStartTime;

	    endHours[0] = bh.SundayEndTime;
	    endHours[1] = bh.MondayEndTime;
	    endHours[2] = bh.TuesdayEndTime;
	    endHours[3] = bh.WednesdayEndTime;
	    endHours[4] = bh.ThursdayEndTime;
	    endHours[5] = bh.FridayEndTime;
	    endHours[6] = bh.SaturdayEndTime;

	  	}

	  	// Calculate the Business Days between 2 DateTimes
	  	public static Map<String, Double> numBusinessDaysBetween(String businessHoursId, DateTime startDate, DateTime endDate) {

	        System.debug('Id = ' + businessHoursId);
	        System.debug('Start = ' + startDate);
	        System.debug('End = ' + endDate);

			Map<String, Double> theResults = new Map<String, Double>();

			Double millisecondsBetween = BusinessHours.diff(businessHoursId, startDate, endDate);
			theResults.put('millisecondsBetween', millisecondsBetween);

			Double secondsBeween = millisecondsBetween / 1000;
			theResults.put('secondsBeween', secondsBeween);

			Double minutesBetween = secondsBeween / 60;
			theResults.put('minutesBetween', minutesBetween);

			Double hoursBetween = minutesBetween / 60;
			theResults.put('hoursBetween', hoursBetween);

			Double daysBetween = hoursBetween / 8;
			theResults.put('daysBetween', daysBetween);
	        
	        System.debug('Millis = ' 	+ millisecondsBetween.format().remove(','));
	        System.debug('Secs = ' 		+ String.valueOf(secondsBeween));
	        System.debug('Mins = ' 		+ String.valueOf(minutesBetween));
	        System.debug('Hrs = ' 		+ String.valueOf(hoursBetween));
	        System.debug('Days = ' 		+ String.valueOf(daysBetween));

	    	return (theResults);
	   	}


  		// Check if today is a business day
  		public Boolean isBusinessDay(Date inputDate) {
    		// index i is index into the businessDay array based on inputDate
    		Integer i = Math.mod(Math.abs(this.knownSunday.daysBetween(inputDate)),7);
    		return (businessDay[i]);
   		}


	   // Gets next business day, skipping non business days
	   public Date nextBusinessDay(Datetime inputDatetime) {
	     	Integer i = Math.mod(Math.abs(this.knownSunday.daysBetween(inputDatetime.date())),7);
	     	Datetime returnDate = inputDatetime;

			if (i < 6){ 
				i++; 
				returnDate = returnDate.addDays(1);
			}	     	

		    while (!businessDay[Math.mod(i, 7)]) {
		    	i++;
	    	   	returnDate = returnDate.addDays(1);
	     	}
	     	return returnDate.date();
	   }


	   // Get the start time
	   public Time getStartTime(Date inputDate) {
	     	Integer i = Math.mod(Math.abs(this.knownSunday.daysBetween(inputDate)),7);
	     	return (startHours[i]);
	   }

}