@isTest
public class TestServiceEmailToCase{

    static testMethod void stefaniniCreateUser(){
        FutureCalls.forceFutureCalls = true;
        User saUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        
        User testUser = null;
        Case serviceCase = null;
        Account testaccount = null;

        system.runAs(saUser){
            system.debug('Creating the Stefanini user to resolve http://www.salesforce.com/us/developer/docs/apexcode/Content/apex_bulk_sharing_understanding.htm ');
            string profileId =  [select id from profile where name='Stefanini Service Desk User'].Id; 
            string roleId = [select id from UserRole where name='Global Service Desk Level 1'].Id;   
            testUser = new User(LastName = 'Test', Alias = 'standt', Email='testuser@enett.com',  
                                          UserName='tu@enett.com',ProfileId = profileId, UserRoleId = roleId,
                                          emailencodingkey = 'UTF-8', languagelocalekey = 'en_US', localesidkey = 'en_US', timezonesidkey = 'America/Los_Angeles');
            insert testUser;
            system.assertNotEquals(null, testUser.Id,' Could not insert a new Stefanini user :' + testUser);
    
            RecordType accRT = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND NAME ='Customer'];
            system.assertNotEquals(null, accRT,' Could not find a Customer Record Type');
            system.assertNotEquals(null, accRT.Id,' Could not find a Customer Record Type - Id field is null');
    
            testaccount = new Account(Name = 'Account Test', Legal_Name__c = 'Account Test', Client_Status__c = 'Prospect', Due_Diligence_Completed__c = System.today()-56, RecordTypeId = accRT.Id, OwnerId = testUser.Id );
            insert testaccount;
            system.assertNotEquals(null, testaccount.Id,' Could not insert an Account:' + testaccount);
            system.assertEquals('Test', [select Owner.Name from Account where id = :testAccount.Id].Owner.Name);
            
            UserRecordAccess access = [SELECT RecordId, HasEditAccess, HasTransferAccess, MaxAccessLevel FROM UserRecordAccess where RecordId = :testAccount.Id and UserId = :testUser.Id];
            system.Assert(access.HasTransferAccess, 'Cannot take ownership of the case record:' + access); 
            system.Assert(access.HasEditAccess, 'Cannot edit the case record:' + access); 
    
            Contact contactperson = new Contact(FirstName = 'Firsttest', LastName = 'Lastest', AccountId = testaccount.id );
            insert contactperson ; 
            system.assertNotEquals(null, contactperson.Id,' Could not insert a Contact: ' + contactperson);
            
            system.debug('Start of Service Ticket Testing');
            RecordType caseRT = [SELECT Id,Name FROM RecordType WHERE SobjectType='Case' AND NAME ='Enett Service Cloud Record Type'];
            system.assertNotEquals(null, caseRT,' Could not find a Enett Service Cloud Record Type');
            system.assertNotEquals(null, caseRT.Id,' Could not find a Enett Service Cloud Record Type - Id field is null');
            
            system.debug('Assigning Ticket to Service New Ticket Queue');
            Group queue = [select Id, Name from Group where Name = 'New Ticket Queue' and Type = 'Queue'];
            serviceCase = new Case (Subject = 'Test Subject', Origin = 'Email', Type = 'Bug', Priority = 'Not None', Status = 'New', ContactId = contactperson.Id, OwnerId = queue.Id, RecordTYpeId = caseRT.Id);
            insert serviceCase;
            system.assertNotEquals(null, serviceCase,' Could not insert a Case: ' + serviceCase);
            system.assertNotEquals(null, serviceCase.Id,' Could not insert a Case: ' + serviceCase);
            system.debug('Service case is now inserted:' + serviceCase);
        }
    }
    
 	static testMethod void stefaniniUpdateOwner(){
        FutureCalls.forceFutureCalls = true;
        User saUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        
        User testUser = null;
        Case serviceCase = null;
        Account testaccount = null;

        system.runAs(saUser){
            system.debug('Creating the Stefanini user to resolve http://www.salesforce.com/us/developer/docs/apexcode/Content/apex_bulk_sharing_understanding.htm ');
            string profileId =  [select id from profile where name='Stefanini Service Desk User'].Id; 
            string roleId = [select id from UserRole where name='Global Service Desk Level 1'].Id;   
            testUser = new User(LastName = 'Test', Alias = 'standt', Email='testuser@enett.com',  
                                          UserName='tu@enett.com',ProfileId = profileId, UserRoleId = roleId,
                                          emailencodingkey = 'UTF-8', languagelocalekey = 'en_US', localesidkey = 'en_US', timezonesidkey = 'America/Los_Angeles');
            insert testUser;
            system.assertNotEquals(null, testUser.Id,' Could not insert a new Stefanini user :' + testUser);
    
            RecordType accRT = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND NAME ='Customer'];
            system.assertNotEquals(null, accRT,' Could not find a Customer Record Type');
            system.assertNotEquals(null, accRT.Id,' Could not find a Customer Record Type - Id field is null');
    
            testaccount = new Account(Name = 'Account Test', Legal_Name__c = 'Account Test', Client_Status__c = 'Prospect', Due_Diligence_Completed__c = System.today()-56, RecordTypeId = accRT.Id, OwnerId = testUser.Id );
            insert testaccount;
            system.assertNotEquals(null, testaccount.Id,' Could not insert an Account:' + testaccount);
            system.assertEquals('Test', [select Owner.Name from Account where id = :testAccount.Id].Owner.Name);
            
            UserRecordAccess access = [SELECT RecordId, HasEditAccess, HasTransferAccess, MaxAccessLevel FROM UserRecordAccess where RecordId = :testAccount.Id and UserId = :testUser.Id];
            system.Assert(access.HasTransferAccess, 'Cannot take ownership of the case record:' + access); 
            system.Assert(access.HasEditAccess, 'Cannot edit the case record:' + access); 
    
            Contact contactperson = new Contact(FirstName = 'Firsttest', LastName = 'Lastest', AccountId = testaccount.id );
            insert contactperson ; 
            system.assertNotEquals(null, contactperson.Id,' Could not insert a Contact: ' + contactperson);
            
            system.debug('Start of Service Ticket Testing');
            RecordType caseRT = [SELECT Id,Name FROM RecordType WHERE SobjectType='Case' AND NAME ='Enett Service Cloud Record Type'];
            system.assertNotEquals(null, caseRT,' Could not find a Enett Service Cloud Record Type');
            system.assertNotEquals(null, caseRT.Id,' Could not find a Enett Service Cloud Record Type - Id field is null');
            
            system.debug('Assigning Ticket to Service New Ticket Queue');
            Group queue = [select Id, Name from Group where Name = 'New Ticket Queue' and Type = 'Queue'];
            serviceCase = new Case (Subject = 'Test Subject', Origin = 'Email', Type = 'Bug', Priority = 'Not None', Status = 'New', ContactId = contactperson.Id, OwnerId = queue.Id, RecordTYpeId = caseRT.Id);
            insert serviceCase;
            system.assertNotEquals(null, serviceCase,' Could not insert a Case: ' + serviceCase);
            system.assertNotEquals(null, serviceCase.Id,' Could not insert a Case: ' + serviceCase);
            system.debug('Service case is now inserted:' + serviceCase);
        }    
         system.runAs(testUser){
            system.debug('Running as a new Stefanini User :' + testUser);
            system.debug('Service case:' + serviceCase);
            serviceCase.OwnerId = testUser.Id;
            serviceCase.Status = 'Pending';
            update serviceCase;
            system.debug('Service case owner updated to Stefanini user:' + serviceCase);
            
            system.debug('Checking the case status and KPI');
            serviceCase = [Select Status, KPI_Met__c,  First_Ownership__c, OwnerId, Assignee_Service_Level__c from Case where Case.Id = :serviceCase.Id];
            system.debug('The Case Status is ' + serviceCase.Status + ' and KPI is ' + serviceCase.KPI_Met__c );
            system.debug('The First Owner is  ' + serviceCase.First_Ownership__c );
            system.assertEquals('Open', serviceCase.Status, 'Error: The Case status has not changed to open');
            system.assertEquals(TRUE, serviceCase.KPI_Met__c, 'Error: The KPI has not been met');
            system.assertEquals('Service Desk Level 1', serviceCase.Assignee_Service_Level__c,'Error: Case is not assigned to Service Desk Level 1');
            system.assert(!String.isEmpty(serviceCase.First_Ownership__c), 'Error: The first ownership is not entered.');       
            
            system.debug('Escalating Ticket to Service Desk 1');
            Group queue = [select Id, Name from Group where Name = 'Global Service Desk Level 1' and Type = 'Queue'];
            system.debug('Update the case owner to Queue:' + queue);
            serviceCase.OwnerId = queue.Id;
            update serviceCase ;
        }
 	}

	static testMethod void stefaniniUpdateCase(){
        FutureCalls.forceFutureCalls = true;
        User saUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        
        User testUser = null;
        Case serviceCase = null;
        Account testaccount = null;

        system.runAs(saUser){
            system.debug('Creating the Stefanini user to resolve http://www.salesforce.com/us/developer/docs/apexcode/Content/apex_bulk_sharing_understanding.htm ');
            string profileId =  [select id from profile where name='Stefanini Service Desk User'].Id; 
            string roleId = [select id from UserRole where name='Global Service Desk Level 1'].Id;   
            testUser = new User(LastName = 'Test', Alias = 'standt', Email='testuser@enett.com',  
                                          UserName='tu@enett.com',ProfileId = profileId, UserRoleId = roleId,
                                          emailencodingkey = 'UTF-8', languagelocalekey = 'en_US', localesidkey = 'en_US', timezonesidkey = 'America/Los_Angeles');
            insert testUser;
            system.assertNotEquals(null, testUser.Id,' Could not insert a new Stefanini user :' + testUser);
    
            RecordType accRT = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND NAME ='Customer'];
            system.assertNotEquals(null, accRT,' Could not find a Customer Record Type');
            system.assertNotEquals(null, accRT.Id,' Could not find a Customer Record Type - Id field is null');
    
            testaccount = new Account(Name = 'Account Test', Legal_Name__c = 'Account Test', Client_Status__c = 'Prospect', Due_Diligence_Completed__c = System.today()-56, RecordTypeId = accRT.Id, OwnerId = testUser.Id );
            insert testaccount;
            system.assertNotEquals(null, testaccount.Id,' Could not insert an Account:' + testaccount);
            system.assertEquals('Test', [select Owner.Name from Account where id = :testAccount.Id].Owner.Name);
            
            UserRecordAccess access = [SELECT RecordId, HasEditAccess, HasTransferAccess, MaxAccessLevel FROM UserRecordAccess where RecordId = :testAccount.Id and UserId = :testUser.Id];
            system.Assert(access.HasTransferAccess, 'Cannot take ownership of the case record:' + access); 
            system.Assert(access.HasEditAccess, 'Cannot edit the case record:' + access); 
    
            Contact contactperson = new Contact(FirstName = 'Firsttest', LastName = 'Lastest', AccountId = testaccount.id );
            insert contactperson ; 
            system.assertNotEquals(null, contactperson.Id,' Could not insert a Contact: ' + contactperson);
            
            system.debug('Start of Service Ticket Testing');
            RecordType caseRT = [SELECT Id,Name FROM RecordType WHERE SobjectType='Case' AND NAME ='Enett Service Cloud Record Type'];
            system.assertNotEquals(null, caseRT,' Could not find a Enett Service Cloud Record Type');
            system.assertNotEquals(null, caseRT.Id,' Could not find a Enett Service Cloud Record Type - Id field is null');
            
            system.debug('Assigning Ticket to Service New Ticket Queue');
            Group queue = [select Id, Name from Group where Name = 'New Ticket Queue' and Type = 'Queue'];
            serviceCase = new Case (Subject = 'Test Subject', Origin = 'Email', Type = 'Bug', Priority = 'Not None', Status = 'New', ContactId = contactperson.Id, OwnerId = queue.Id, RecordTYpeId = caseRT.Id);
            insert serviceCase;
            system.assertNotEquals(null, serviceCase,' Could not insert a Case: ' + serviceCase);
            system.assertNotEquals(null, serviceCase.Id,' Could not insert a Case: ' + serviceCase);
            system.debug('Service case is now inserted:' + serviceCase);

            system.debug('Assigning to members eNett Sales Service and Delivery Administrator profile Level 2');
            profileId = [select id from Profile where name= 'eNett Sales Service and Delivery Administrator' LIMIT 1].Id;
            roleId = [select id from UserRole where name='Global Service Desk Level 2'].Id;   
            testUser = new User(LastName = 'NewLvl2User', Alias = 'NewLvl2', Email='newlevel2@enett.com',  
                                          UserName='leveltwo@enett.com', ProfileId = profileId, UserRoleId = roleId,
                                          emailencodingkey = 'UTF-8', languagelocalekey = 'en_US', localesidkey = 'en_US', timezonesidkey = 'America/Los_Angeles');
    
    
            insert testUser;
            system.assertNotEquals(null, testUser.Id,' Could not insert a new Level 2 user :' + testUser);
            system.debug('Running as Service Desk Level 2 User :' + testUser);
    
            serviceCase.OwnerId = testUser.Id;
            update serviceCase;
            system.Debug('Service case owner updated to Global Service Desk Level 2 User:' + serviceCase);       
            system.assertEquals(testUser.Id , serviceCase.OwnerId, 'Error: The Case has not been assigned to Global Service Desk Level 2');
        }   
        system.runAs(testUser){  
            serviceCase.Description = 'eNett Sales Service and Delivery Administrator';
            serviceCase.Product__c = 'feeNett';
            serviceCase.status = 'In Progress';
            update serviceCase;
                    
            system.debug('Escalating Ticket to Global Service Desk Level 3 Delivery');
            Group queue = [select Id, Name from Group where Name = 'Global Service Desk Level 3 Delivery' and Type = 'Queue'];
            system.debug('Update the case owner to Queue:' + queue);
            serviceCase.OwnerId = queue.Id;
            update serviceCase;
        }
	}
	
	
	static testMethod void stefaniniUpdateService3(){
        FutureCalls.forceFutureCalls = true;
        User saUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        
        User testUser = null;
        Case serviceCase = null;
        Account testaccount = null;

        system.runAs(saUser){
            system.debug('Creating the Stefanini user to resolve http://www.salesforce.com/us/developer/docs/apexcode/Content/apex_bulk_sharing_understanding.htm ');
            string profileId =  [select id from profile where name='Stefanini Service Desk User'].Id; 
            string roleId = [select id from UserRole where name='Global Service Desk Level 1'].Id;   
            testUser = new User(LastName = 'Test', Alias = 'standt', Email='testuser@enett.com',  
                                          UserName='tu@enett.com',ProfileId = profileId, UserRoleId = roleId,
                                          emailencodingkey = 'UTF-8', languagelocalekey = 'en_US', localesidkey = 'en_US', timezonesidkey = 'America/Los_Angeles');
            insert testUser;
            system.assertNotEquals(null, testUser.Id,' Could not insert a new Stefanini user :' + testUser);
    
            RecordType accRT = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND NAME ='Customer'];
            system.assertNotEquals(null, accRT,' Could not find a Customer Record Type');
            system.assertNotEquals(null, accRT.Id,' Could not find a Customer Record Type - Id field is null');
    
            testaccount = new Account(Name = 'Account Test', Legal_Name__c = 'Account Test', Client_Status__c = 'Prospect', Due_Diligence_Completed__c = System.today()-56, RecordTypeId = accRT.Id, OwnerId = testUser.Id );
            insert testaccount;
            system.assertNotEquals(null, testaccount.Id,' Could not insert an Account:' + testaccount);
            system.assertEquals('Test', [select Owner.Name from Account where id = :testAccount.Id].Owner.Name);
            
            UserRecordAccess access = [SELECT RecordId, HasEditAccess, HasTransferAccess, MaxAccessLevel FROM UserRecordAccess where RecordId = :testAccount.Id and UserId = :testUser.Id];
            system.Assert(access.HasTransferAccess, 'Cannot take ownership of the case record:' + access); 
            system.Assert(access.HasEditAccess, 'Cannot edit the case record:' + access); 
    
            Contact contactperson = new Contact(FirstName = 'Firsttest', LastName = 'Lastest', AccountId = testaccount.id );
            insert contactperson ; 
            system.assertNotEquals(null, contactperson.Id,' Could not insert a Contact: ' + contactperson);
            
            system.debug('Start of Service Ticket Testing');
            RecordType caseRT = [SELECT Id,Name FROM RecordType WHERE SobjectType='Case' AND NAME ='Enett Service Cloud Record Type'];
            system.assertNotEquals(null, caseRT,' Could not find a Enett Service Cloud Record Type');
            system.assertNotEquals(null, caseRT.Id,' Could not find a Enett Service Cloud Record Type - Id field is null');
            
            system.debug('Assigning Ticket to Service New Ticket Queue');
            Group queue = [select Id, Name from Group where Name = 'New Ticket Queue' and Type = 'Queue'];
            serviceCase = new Case (Subject = 'Test Subject', Origin = 'Email', Type = 'Bug', Priority = 'Not None', Status = 'New', ContactId = contactperson.Id, OwnerId = queue.Id, RecordTYpeId = caseRT.Id);
            insert serviceCase;
            system.assertNotEquals(null, serviceCase,' Could not insert a Case: ' + serviceCase);
            system.assertNotEquals(null, serviceCase.Id,' Could not insert a Case: ' + serviceCase);
            system.debug('Service case is now inserted:' + serviceCase);

            system.debug('Assigning to members eNett Sales Service and Delivery Administrator profile Level 2');
            profileId = [select id from Profile where name= 'eNett Sales Service and Delivery Administrator' LIMIT 1].Id;
            roleId = [select id from UserRole where name='Global Service Desk Level 2'].Id;   
            testUser = new User(LastName = 'NewLvl2User', Alias = 'NewLvl2', Email='newlevel2@enett.com',  
                                          UserName='leveltwo@enett.com', ProfileId = profileId, UserRoleId = roleId,
                                          emailencodingkey = 'UTF-8', languagelocalekey = 'en_US', localesidkey = 'en_US', timezonesidkey = 'America/Los_Angeles');
    
    
            insert testUser;
            system.assertNotEquals(null, testUser.Id,' Could not insert a new Level 2 user :' + testUser);
            system.debug('Running as Service Desk Level 2 User :' + testUser);
    
            serviceCase.OwnerId = testUser.Id;
            update serviceCase;
            system.Debug('Service case owner updated to Global Service Desk Level 2 User:' + serviceCase);       
            system.assertEquals(testUser.Id , serviceCase.OwnerId, 'Error: The Case has not been assigned to Global Service Desk Level 2');

            system.debug('Assigning to members Global Service Desk Level 3 Delivery profile Level 3');
            profileId = [select id from Profile where name= 'eNett Sales Service and Delivery Administrator' LIMIT 1].Id;
            roleId = [select id from UserRole where name='Global Service Desk Level 3 Delivery'].Id;   
            testUser = new User(LastName = 'NewLvl3User', Alias = 'NewLvl3', Email='newlevel3@enett.com',  
                                          UserName='levelthree@enett.com', ProfileId = profileId, UserRoleId = roleId,
                                          emailencodingkey = 'UTF-8', languagelocalekey = 'en_US', localesidkey = 'en_US', timezonesidkey = 'America/Los_Angeles');
    
    
            insert testUser;
            system.assertNotEquals(null, testUser.Id,' Could not insert a new Level 3 user :' + testUser);
            system.debug('Running as Service Desk Level 3 User :' + testUser);
    
            serviceCase.OwnerId = testUser.Id;
            serviceCase.status = 'In Progress';
            update serviceCase;
            system.Debug('Service case owner updated to Global Service Desk Level 3 User:' + serviceCase);       
            system.assertEquals(testUser.Id , serviceCase.OwnerId, 'Error: The Case has not been assigned to Global Service Desk Level 3');
       }
       system.runAs(testUser){
            serviceCase.Description = 'Assigning to Service Level 3 - Finance';
            update serviceCase;
                    
            system.debug('Escalating Ticket to Global Service Desk Level 3 Finance');
            Group queue = [select Id, Name from Group where Name = 'Global Service Desk Level 3 Finance' and Type = 'Queue'];
            system.debug('Update the case owner to Queue:' + queue);
            serviceCase.OwnerId = queue.Id;
            update serviceCase;
       }
	}
	
	static testMethod void stefaniniUpdateService2(){
        FutureCalls.forceFutureCalls = true;
        User saUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        
        User testUser = null;
        Case serviceCase = null;
        Account testaccount = null;

        system.runAs(saUser){
            system.debug('Creating the Stefanini user to resolve http://www.salesforce.com/us/developer/docs/apexcode/Content/apex_bulk_sharing_understanding.htm ');
            string profileId =  [select id from profile where name='Stefanini Service Desk User'].Id; 
            string roleId = [select id from UserRole where name='Global Service Desk Level 1'].Id;   
            testUser = new User(LastName = 'Test', Alias = 'standt', Email='testuser@enett.com',  
                                          UserName='tu@enett.com',ProfileId = profileId, UserRoleId = roleId,
                                          emailencodingkey = 'UTF-8', languagelocalekey = 'en_US', localesidkey = 'en_US', timezonesidkey = 'America/Los_Angeles');
            insert testUser;
            system.assertNotEquals(null, testUser.Id,' Could not insert a new Stefanini user :' + testUser);
    
            RecordType accRT = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND NAME ='Customer'];
            system.assertNotEquals(null, accRT,' Could not find a Customer Record Type');
            system.assertNotEquals(null, accRT.Id,' Could not find a Customer Record Type - Id field is null');
    
            testaccount = new Account(Name = 'Account Test', Legal_Name__c = 'Account Test', Client_Status__c = 'Prospect', Due_Diligence_Completed__c = System.today()-56, RecordTypeId = accRT.Id, OwnerId = testUser.Id );
            insert testaccount;
            system.assertNotEquals(null, testaccount.Id,' Could not insert an Account:' + testaccount);
            system.assertEquals('Test', [select Owner.Name from Account where id = :testAccount.Id].Owner.Name);
            
            UserRecordAccess access = [SELECT RecordId, HasEditAccess, HasTransferAccess, MaxAccessLevel FROM UserRecordAccess where RecordId = :testAccount.Id and UserId = :testUser.Id];
            system.Assert(access.HasTransferAccess, 'Cannot take ownership of the case record:' + access); 
            system.Assert(access.HasEditAccess, 'Cannot edit the case record:' + access); 
    
            Contact contactperson = new Contact(FirstName = 'Firsttest', LastName = 'Lastest', AccountId = testaccount.id, Email = 'test@gmail.com' );
            insert contactperson ; 
            system.assertNotEquals(null, contactperson.Id,' Could not insert a Contact: ' + contactperson);
            
            system.debug('Start of Service Ticket Testing');
            RecordType caseRT = [SELECT Id,Name FROM RecordType WHERE SobjectType='Case' AND NAME ='Enett Service Cloud Record Type'];
            system.assertNotEquals(null, caseRT,' Could not find a Enett Service Cloud Record Type');
            system.assertNotEquals(null, caseRT.Id,' Could not find a Enett Service Cloud Record Type - Id field is null');
            
            system.debug('Assigning Ticket to Service New Ticket Queue');
            Group queue = [select Id, Name from Group where Name = 'New Ticket Queue' and Type = 'Queue'];
            serviceCase = new Case (Subject = 'Test Subject', Origin = 'Email', Type = 'Bug', Priority = 'Not None', Status = 'New', ContactId = contactperson.Id, OwnerId = queue.Id, RecordTYpeId = caseRT.Id);
            insert serviceCase;
            system.assertNotEquals(null, serviceCase,' Could not insert a Case: ' + serviceCase);
            system.assertNotEquals(null, serviceCase.Id,' Could not insert a Case: ' + serviceCase);
            system.debug('Service case is now inserted:' + serviceCase);

            system.debug('Assigning to members eNett Sales Service and Delivery Administrator profile Level 2');
            profileId = [select id from Profile where name= 'eNett Sales Service and Delivery Administrator' LIMIT 1].Id;
            roleId = [select id from UserRole where name='Global Service Desk Level 2'].Id;   
            testUser = new User(LastName = 'NewLvl2User', Alias = 'NewLvl2', Email='newlevel2@enett.com',  
                                          UserName='leveltwo@enett.com', ProfileId = profileId, UserRoleId = roleId,
                                          emailencodingkey = 'UTF-8', languagelocalekey = 'en_US', localesidkey = 'en_US', timezonesidkey = 'America/Los_Angeles');
    
    
            insert testUser;
            system.assertNotEquals(null, testUser.Id,' Could not insert a new Level 2 user :' + testUser);
            system.debug('Running as Service Desk Level 2 User :' + testUser);
    
            serviceCase.OwnerId = testUser.Id;
            update serviceCase;
            system.Debug('Service case owner updated to Global Service Desk Level 2 User:' + serviceCase);       
            system.assertEquals(testUser.Id , serviceCase.OwnerId, 'Error: The Case has not been assigned to Global Service Desk Level 2');

            system.debug('Assigning to members Global Service Desk Level 3 Finance profile Level 3');
            profileId = [select id from Profile where name= 'eNett Sales Service and Delivery Administrator' LIMIT 1].Id;
            roleId = [select id from UserRole where name='Global Service Desk Level 3 Finance'].Id;   
            testUser = new User(LastName = 'NewLvlFUser', Alias = 'NewLvlF', Email='newlevel3F@enett.com',  
                                          UserName='levelthreeF@enett.com', ProfileId = profileId, UserRoleId = roleId,
                                          emailencodingkey = 'UTF-8', languagelocalekey = 'en_US', localesidkey = 'en_US', timezonesidkey = 'America/Los_Angeles');
    
    
            insert testUser;
            system.assertNotEquals(null, testUser.Id,' Could not insert a new Level 3 user :' + testUser);
            system.debug('Running as Service Desk Level 3 User :' + testUser);
    
            serviceCase.OwnerId = testUser.Id;
            serviceCase.status = 'In Progress';
            update serviceCase;
            system.Debug('Service case owner updated to Global Service Desk Level 3 User:' + serviceCase);       
            system.assertEquals(testUser.Id , serviceCase.OwnerId, 'Error: The Case has not been assigned to Global Service Desk Level 3');
       }
       system.runAs(testUser){
            serviceCase.Description = 'Assigning to Service Desk Level 3 - IT';
            update serviceCase;
                    
            system.debug('Escalating Ticket to Global Service Desk Level 3 IT');
            Group queue = [select Id, Name from Group where Name = 'Global Service Desk Level 3 IT' and Type = 'Queue'];
            system.debug('Update the case owner to Queue:' + queue);
            serviceCase.OwnerId = queue.Id;
            update serviceCase;
       }
       system.runAs(saUser){
            system.debug('Assigning to members Global Service Desk Level 3 IT profile Level 3');
            string profileId = [select id from Profile where name= 'eNett Sales Service and Delivery Administrator' LIMIT 1].Id;
            string roleId = [select id from UserRole where name='Global Service Desk Level 3 IT'].Id;   
            testUser = new User(LastName = 'NewLvlIUser', Alias = 'NewLvlI', Email='newlevel3I@enett.com',  
                                          UserName='levelthreeI@enett.com', ProfileId = profileId, UserRoleId = roleId,
                                          emailencodingkey = 'UTF-8', languagelocalekey = 'en_US', localesidkey = 'en_US', timezonesidkey = 'America/Los_Angeles');
    
    
            insert testUser;
            system.assertNotEquals(null, testUser.Id,' Could not insert a new Level 3 user :' + testUser);
            system.debug('Running as Service Desk Level 3 User :' + testUser);
    
            serviceCase.OwnerId = testUser.Id;
            update serviceCase;
            system.Debug('Service case owner updated to Global Service Desk Level 3 User:' + serviceCase);       
            system.assertEquals(testUser.Id , serviceCase.OwnerId, 'Error: The Case has not been assigned to Global Service Desk Level 3');
       }
       system.runAs(testUser){
            serviceCase.Final_Solution__c = 'Updated the final solution';
            serviceCase.Product__c = 'VANs';
            serviceCase.Status = 'Closed';
            update serviceCase;
       }
    }

}