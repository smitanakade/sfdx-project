@isTest
private class TestPermissions {

        /* Enumerate the Profiles and all Roles and confirm that 
        
        1/.  They can create, update, delete an account 
        2/.  They can do the same for a Contact, Lead, Opportunity, Task
        
        3/.  That they cannto "see" an account with RecordType = 'Test'
        4/.  They cannot see any any of the equivalent records ( case. etc)
        */
    
    /*static testMethod void canSeeSalesAccounts() {
          
          List<string> ProfileList = new List<string>{'eNett Sales Service and Delivery','eNett Sales Service and Delivery (Manage Public List Views Enabled)','eNett Sales & Support' };
          List<Profile> Profiles = [select id, Name from Profile where UserType = 'Standard' and UserLicense.Name = 'Salesforce' and Name in :ProfileList] ;
          
          // Create the users to be used in this test.
          integer counter = 0;
          for(Profile p : Profiles){

                string profileName = p.Name.deleteWhitespace();
                counter++;
                User theUser = new User(alias = string.valueOf(counter),
                                        email = profileName + '@testorg.com',
                                        emailencodingkey = 'UTF-8',
                                        lastname = profileName, 
                                        languagelocalekey = 'en_US',
                                        localesidkey = 'en_US',
                                        profileid = p.Id,
                                        timezonesidkey = 'America/Los_Angeles',
                                        username = profileName + '@testorg.com');

                insert theUser;
                system.assertNotEquals(null, theUser.Id);
         
                system.runas(theUser){
                    Account theAccount = new Account( name = p.Name, ownerid = theUser.id);
                    for (Database.SaveResult sr : database.insert( new list<sobject>{ theAccount }, true)){
                        system.Assert( sr.isSuccess());
                    }
                    system.AssertNotEquals(null,theAccount.Id);
                    theAccount.Name = p.Name + '-changed';
                    /*for (Database.SaveResult sr : database.update( new list<sobject>{ theAccount }, true)){
                        system.Assert( sr.isSuccess());
                    }
                    for (Database.DeleteResult dr : database.delete( new list<sobject>{ theAccount }, true)){
                        system.Assert( dr.isSuccess());
                    }
                }
       }        
    }*/
    
    
    /*static testMethod void canSeeServiceAndLegalAccounts() {
          
          List<string> ProfileList = new List<string>{'eNett Service Desk User','Stefanini Service Desk User','eNett Legal'};
          List<Profile> Profiles = [select id, Name from Profile where UserType = 'Standard' and UserLicense.Name = 'Salesforce' and Name in :ProfileList] ;
          
          // Create the users to be used in this test.
          integer counter = 0;
          for(Profile p : Profiles){
                string profileName = p.Name.deleteWhitespace();
                counter++;
                User theUser = new User(alias = string.valueOf(counter),
                                        email = profileName + '@testorg.com',
                                        emailencodingkey = 'UTF-8',
                                        lastname = profileName, 
                                        languagelocalekey = 'en_US',
                                        localesidkey = 'en_US',
                                        profileid = p.Id,
                                        timezonesidkey = 'America/Los_Angeles',
                                        username = profileName + '@testorg.com');

                insert theUser;
                system.assertNotEquals(null, theUser.Id);
         
                system.runas(theUser){
                    Account theAccount = new Account( name = p.Name, ownerid = theUser.id);

                    for (Database.SaveResult sr : database.insert( new list<sobject>{ theAccount }, true)){
                        system.Assert( sr.isSuccess());
                    }
                    
                    system.AssertNotEquals(null,theAccount.Id);
                    
                    theAccount.Name = p.Name + '-changed';
                    /*for (Database.SaveResult sr : database.update( new list<sobject>{ theAccount }, true)){
                        system.Assert( sr.isSuccess());
                    }
                    
                    for (Database.DeleteResult dr : database.delete( new list<sobject>{ theAccount }, true)){
                        system.Assert( dr.isSuccess());
                    }
                    
                }
                
       }        
    }*/
    
    /*static testMethod void canSeeSystemAdminAccounts() {
          
          List<string> ProfileList = new List<string>{'eNett Sales Demo Administrator','eNett Sales Service and Delivery Administrator','System Administrator (no expiry)'};
          List<Profile> Profiles = [select id, Name from Profile where UserType = 'Standard' and UserLicense.Name = 'Salesforce' and Name in :ProfileList] ;
          
          // Create the users to be used in this test.
          integer counter = 0;
          for(Profile p : Profiles){
                string profileName = p.Name.deleteWhitespace();
                counter++;
                User theUser = new User(alias = string.valueOf(counter),
                                        email = profileName + '@testorg.com',
                                        emailencodingkey = 'UTF-8',
                                        lastname = profileName, 
                                        languagelocalekey = 'en_US',
                                        localesidkey = 'en_US',
                                        profileid = p.Id,
                                        timezonesidkey = 'America/Los_Angeles',
                                        username = profileName + '@testorg.com');

                insert theUser;
                system.assertNotEquals(null, theUser.Id);
         
                system.runas(theUser){
                    Account theAccount = new Account( name = p.Name, ownerid = theUser.id);

                    /*for (Database.SaveResult sr : database.insert( new list<sobject>{ theAccount }, true)){
                        system.Assert( sr.isSuccess());
                    }
                    
                    system.AssertNotEquals(null,theAccount.Id);
                    
                    theAccount.Name = p.Name + '-changed';
                    for (Database.SaveResult sr : database.update( new list<sobject>{ theAccount }, true)){
                        system.Assert( sr.isSuccess());
                    }
                    
                    for (Database.DeleteResult dr : database.delete( new list<sobject>{ theAccount }, true)){
                        system.Assert( dr.isSuccess());
                    }
                    
                }
                
       }        
    }*/
         
    
    
    /*
    static testMethod void cantSeeTestAccounts() {
          Datetime DT  = [Select id , CreatedDate from Organization ][0].CreatedDate; 
          List<Profile>  Profiles = [select id , Name from Profile where UserType = 'Standard' and UserLicense.Name = 'Salesforce' and CreatedDate > :DT 
                                        and Name not in ('eNett Export','System Administrator (no expiry)','Administrator','ServiceUser')] ;
          // Create the users to be used in this test.
          integer counter = 0;
          List<string> failedList = new List<string>();

          RecordType rt = [select id from RecordType where sobjectType = 'Account' and DeveloperName = 'Test_Account' limit 1];
          Account theAccount = new Account( name = 'test name', recordTypeId = rt.Id );
          for (Database.SaveResult sr : database.insert( new list<sobject>{ theAccount }, true)){
                system.Assert( sr.isSuccess());
          }
          system.AssertNotEquals(null,theAccount.Id);

          for(Profile p : Profiles){
                string profileName = p.Name.deleteWhitespace();
                counter++;
                User theUser = new User(alias = string.valueOf(counter),
                                        email = profileName + '@testorg.com',
                                        emailencodingkey = 'UTF-8',
                                        lastname = profileName, 
                                        languagelocalekey = 'en_US',
                                        localesidkey = 'en_US',
                                        profileid = p.Id,
                                        timezonesidkey = 'America/Los_Angeles',
                                        username = profileName + '@testorg.com');

                insert theUser;
                system.assertNotEquals(null, theUser.Id);

                system.runas(theUser){
                    try
                    {
                        Account testAccount = [select id from Account where id = :theAccount.Id];
                        failedList.add( p.Name );                   
                    }
                    catch(System.QueryException ex)
                    {
                    }
                    catch(Exception e)
                    {
                        system.assert(false, 'Exception ocurred that we were not expecting ' + e);
                    }
                }
       }
       system.assertEquals(0, failedList.size(), 'The following profiles have the ability to view Test Accounts: ' + failedList);       
    }
    */
}