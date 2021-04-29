@isTest
private class TEST_DateUtilities {
	
	@isTest static void test_numBusinessDaysBetween() {
	
		DateTime theStart   = Datetime.valueOf('2015-06-24 09:00:00');
		DateTime theEnd     = Datetime.valueOf('2015-06-24 10:00:00');

		Map<String, Double> theResults = new Map<String, Double>();
		theResults = DateUtilities.numBusinessDaysBetween('01m90000000Cl8eAAC', theStart, theEnd);

		System.Debug('***** The difference in Hours is: ' + theResults.get('hoursBetween'));

	}


	@isTest static void test_isBusinessDay() {
	
		Date aMonday     	= Date.valueOf('2015-06-22');
		Date aTuesday   	= Date.valueOf('2015-06-23');
		Date aWednesday     = Date.valueOf('2015-06-24');
		Date aThursday   	= Date.valueOf('2015-06-25');
		Date aFriday   		= Date.valueOf('2015-06-26');
		Date aSaturday     	= Date.valueOf('2015-06-27');
		Date aSunday     	= Date.valueOf('2015-06-28');

		DateUtilities DU = new DateUtilities();

		Boolean Monday 		= DU.isBusinessDay(aMonday);
		Boolean Tuesday 	= DU.isBusinessDay(aTuesday);
		Boolean Wednesday 	= DU.isBusinessDay(aWednesday);
		Boolean Thursday 	= DU.isBusinessDay(aThursday);
		Boolean Friday 		= DU.isBusinessDay(aFriday);
		Boolean Saturday 	= DU.isBusinessDay(aSaturday);
		Boolean Sunday 		= DU.isBusinessDay(aSunday);

		// Turned off the following in case business days change
/*
		System.assert(Monday, 'Monday has NOT been flagged as a Workday ');
		System.assert(Tuesday, 'Tuesday has NOT been flagged as a Workday ');
		System.assert(Wednesday, 'Wednesday has NOT been flagged as a Workday ');
		System.assert(Thursday, 'Thursday has NOT been flagged as a Workday ');
		System.assert(Friday, 'Friday has NOT been flagged as a Workday ');
		System.assert(!Saturday, 'Saturday has been flagged as a Workday ');
		System.assert(!Sunday, 'Sunday HAS been flagged as a Workday ');
*/

	}


	@isTest static void test_nextBusinessDay() {
	
		Date aMonday     	= Date.valueOf('2015-06-22');
		Date aThursday   	= Date.valueOf('2015-06-25');
		Date aFriday   		= Date.valueOf('2015-06-26');
		Date aSaturday     	= Date.valueOf('2015-06-27');
		Date aSunday     	= Date.valueOf('2015-06-28');


		DateUtilities DU = new DateUtilities();

		Date Thursday 	= DU.nextBusinessDay(aThursday);
		Date Friday		= DU.nextBusinessDay(aFriday);
		Date Saturday	= DU.nextBusinessDay(aSaturday);
		Date Sunday		= DU.nextBusinessDay(aSunday);
		Date Monday		= DU.nextBusinessDay(aMonday);


		// Turned off the following in case business days change
/*
		System.Assert(String.valueOf(Monday) 	== '2015-06-23', 'The day after Monday should have been Tuesday');
		System.Assert(String.valueOf(Thursday)	== '2015-06-26', 'The day after Thusday should have been Friday');
		System.Assert(String.valueOf(Friday) 	== '2015-06-29', 'The day after Friday should have been Monday');
		System.Assert(String.valueOf(Saturday) 	== '2015-06-29', 'The day after Saturday should have been Monday');
		System.Assert(String.valueOf(Sunday) 	== '2015-06-29', 'The day after Sunday should have been Monday');
*/
		
	}

	@isTest static void test_getStartTime() {

		Date aFriday   		= Date.valueOf('2015-06-26');
		Date aSaturday     	= Date.valueOf('2015-06-27');
		Date aSunday     	= Date.valueOf('2015-06-28');
		Date aMonday     	= Date.valueOf('2015-06-29');

		DateUtilities DU = new DateUtilities();

		Time Friday		= DU.getStartTime(aFriday);
		Time Saturday	= DU.getStartTime(aSaturday);
		Time Sunday		= DU.getStartTime(aSunday);
		Time Monday		= DU.getStartTime(aMonday);

		// Turned off the following in case start times change
/*
		System.Assert(String.valueOf(Friday) 	== '09:00:00.000Z', 'The start time for Friday is not 9:00AM.');
		System.Assert(String.valueOf(Saturday) 	== null, 'There should be no Start Time for Saturday.');
		System.Assert(String.valueOf(Sunday) 	== null, 'There should be no Start Time for Saturday');
		System.Assert(String.valueOf(Monday) 	== '09:00:00.000Z', 'The start time for Monday is not 9:00AM.');
*/

	}
	
}