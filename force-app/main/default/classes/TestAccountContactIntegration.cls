@isTest
private class TestAccountContactIntegration {

    static testMethod void TestAccountInsertSetsValues() {
        // related to http://jira/browse/SF-961
        List<ReferrerCodes__c> upsertList = new List<ReferrerCodes__c>();
        upsertList.add(new ReferrerCodes__c(Name='Test',ReferrerCode__c='403525'));
//      upsertList.add(new ReferrerCodes__c(Name='Test1',ReferrerCode__c='403896'));
//      upsertList.add(new ReferrerCodes__c(Name='Test2',ReferrerCode__c='402005'));
//      upsertList.add(new ReferrerCodes__c(Name='Test3',ReferrerCode__c='400469'));
//      upsertList.add(new ReferrerCodes__c(Name='Test4',ReferrerCode__c='403894'));
        upsertList.add(new ReferrerCodes__c(Name='Test5',ReferrerCode__c='N/A'));
        upsert upsertList;
        
        //Privlidges User Account - Integration User is used to insert stuff so create a teprary Integration User account ( linked to Admin No Expiry Profile )
        Profile  adminProfile = [select id , Name from Profile where UserType = 'Standard' and UserLicense.Name = 'Salesforce' and Name = 'System Administrator (no expiry)'];
        string profileName = adminProfile.Name.deleteWhitespace();

        User theUser = new User(alias = 'TestUser',
                                email = profileName + '@testorg.com',
                                emailencodingkey = 'UTF-8',
                                lastname = profileName,
                                languagelocalekey = 'en_US',
                                localesidkey = 'en_US',
                                profileid = adminProfile.Id,
                                timezonesidkey = 'America/Los_Angeles',
                                username = profileName + '@testorg.com');

        insert theUser;
        system.assertNotEquals(null, theUser.Id);

        system.runas(theUser){
            for (ReferrerCodes__c rec : upsertList)
                if(rec.ReferrerCode__c != 'N/A'){
                    Account testAccount = new Account( Name = rec.Name, Referrer_Code__c = rec.ReferrerCode__c, IsApi__c = true );
                    insert testAccount;
                
                    system.assertNotEquals(null, testAccount.Id);
                    //system.assertEquals(rec.Name, [select Referrer_Name__c from Account where Id = :testAccount.Id].Referrer_Name__c, 'Referrer Name should match ' + rec);
            }
       }
    }
}