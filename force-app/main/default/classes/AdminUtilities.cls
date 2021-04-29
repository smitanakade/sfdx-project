global class AdminUtilities {

/********************************************************************************************
 	This class will contain various methods that perform generic application tasks.
********************************************************************************************/

	public static void CreateTestUsers() {

	/****************************************************************************************
	 	This script creates test users as defined.
		A new section should be created for each test user.
	****************************************************************************************/

		//
		// Set up generic variables
		//
		String theEmail 	= 'salesforcebackup@enett.com';
		String theFirstName = 'Test';
		Boolean theActive 	= true;
	    String theEmailEnc 	= 'UTF-8';
	    String theLanguage 	= 'en_US';
	    String theLocale 	= 'en_US';
	    String theTimezone 	= 'America/Los_Angeles';
		UserRole salesUserRole 		= [select id from UserRole where Name = 'Corporate' LIMIT 1];
		UserRole serviceUserRole 	= [select id from UserRole where Name = 'Service Desk Administrator' LIMIT 1];
		UserRole lvl1UserRole		= [select id from UserRole where Name = 'Global Service Desk Level 1' LIMIT 1];
		List<String> theProfileId 	= new List<String>{};
		List<String> theProfileName = new List<String>{};
		List<String> theRoleId 		= new List<String>{};
		List<String> theAlias 		= new List<String>{};


		//
		// REPEAT ADDITIONAL PROFILES HERE .......
		// REPEAT ADDITIONAL PROFILES HERE .......
		//


		//	
		// 'eNett Sales & Support'
		//		
        Profile ourProfile = [select id, Name from Profile where Name = 'eNett Sales & Support' LIMIT 1];
		theProfileId.add(ourProfile.Id);
		theProfileName.add(ourProfile.Name);
		theRoleId.add(salesUserRole.Id);
		theAlias.add('TestS&S');


		//	
		// 'eNett Sales Service and Delivery'
		//		
        ourProfile = [select id, Name from Profile where Name = 'eNett Sales Service and Delivery' LIMIT 1];
		theProfileId.add(ourProfile.Id);
		theProfileName.add(ourProfile.Name);
		theRoleId.add(salesUserRole.Id);
		theAlias.add('TestSS&D');


		//	
		// 'eNett Sales Service and Delivery Administrator'
		//	
        ourProfile = [select id, Name from Profile where Name = 'eNett Sales Service and Delivery Administrator' LIMIT 1];
		theProfileId.add(ourProfile.Id);
		theProfileName.add(ourProfile.Name);
		theRoleId.add(salesUserRole.Id);
		theAlias.add('TestSSDA');



		//
		// 'eNett Service Desk User'
		//	
        ourProfile = [select id, Name from Profile where Name = 'eNett Service Desk User' LIMIT 1];
		theProfileId.add(ourProfile.Id);
		theProfileName.add(ourProfile.Name);
		theRoleId.add(serviceUserRole.Id);
		theAlias.add('TestSDU');


		//	
		// 'Stefanini Service Desk User'
		//	
        ourProfile = [select id, Name from Profile where Name = 'Stefanini Service Desk User' LIMIT 1];
		theProfileId.add(ourProfile.Id);
		theProfileName.add(ourProfile.Name);
		theRoleId.add(lvl1UserRole.Id);
		theAlias.add('TestSSDU');


		//
		// Loop through our Profiles and create a user for each
		//
		for (Integer i = 0; i < theProfileId.size(); i++) {

		    User theUser = new User(	Alias = theAlias[i],
		                               	Email = theEmail,
		                               	EmailEncodingKey = theEmailEnc,
		                               	FirstName = theFirstName,
		                               	LastName = theProfileName[i],
		                               	UserRoleId = theRoleId[i],
		                               	LanguageLocaleKey = theLanguage,
		                               	LocaleSidKey = theLocale,
		                               	ProfileId = theProfileId[i],
		                               	TimeZoneSidKey = theTimezone,
		                               	CommunityNickname = theAlias[i],
		                               	IsActive = theActive,
		                               	Username = theProfileName[i].replaceAll( '\\s+', '') + '@enett.com.test');
			try
		      	{
		        	insert theUser;  // insert the user record
		       	}
		    catch(Exception e)
		    {
		        System.debug(e);  
		    }
		}
	}
}