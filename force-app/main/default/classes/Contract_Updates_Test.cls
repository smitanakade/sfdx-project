@isTest
private class Contract_Updates_Test {

    static testMethod void TestContracts() {
    
        Datetime dt = DateTime.parse('10/10/2014 12:00 AM');
        Account testaccount = new Account(  Name = 'Account Test', 
                                            Legal_Name__c = 'Account Test', 
                                            Client_Status__c = 'Prospect', 
                                            IntegratorModifiedDate__c = system.now(), 
                                            eNett_Products__c = 'VANs',
                                            IsApi__c = true, 
                                            DD_Completed_Date__c = dt,
                                            CurrencyIsoCode = 'AUD');
        insert testaccount;
        system.assertNotEquals(null, testaccount.Id);
        
        Contact contactperson = new Contact(FirstName = 'Firsttest', 
                                            LastName = 'Lastest', 
                                            AccountId = testaccount.id , 
                                            IsApi__c = true);
        insert contactperson ;
        system.assertNotEquals(null, contactperson.id);

        Database.SaveResult sr = database.insert(new eNEtt_Contract__c( Account_Name__c = testaccount.Id, VAN_Currencies__c = 'some random value'));
        system.assert( sr.isSuccess() );
        
        eNEtt_Contract__c contract = [select Account_Name__c, Opportunity_Name__c, CurrencyIsoCode, VAN_Currencies__c from eNEtt_Contract__c where Id = :sr.getId()];
        system.assertEquals(testaccount.Id, contract.Account_Name__c);
//        system.assertEquals(testaccount.CurrencyIsoCode, contract.CurrencyIsoCode);
        system.assertEquals(null, contract.Opportunity_Name__c);
//        system.assertEquals(null, contract.VAN_Currencies__c); 
        
        Opportunity Opp = new Opportunity(  Name= 'Test Opp', 
                                            AccountId = testaccount.id , 
                                            Product__c = 'VANs', 
                                            Type = 'New', 
                                            CloseDate = date.valueOf('2014-01-01'), 
                                            StageName = '1. Prospect', 
                                            Country__c = 'Australia',
                                            Primary_Implementation_Contact__c = contactperson.Id, 
                                            VAN_currencies_top_3__c = 'AUD;USD',
                                            Delivery_Type__c = null);
                                            
        //insert Opp; 
        
        //contract.Opportunity_Name__c = Opp.Id;
        //update contract;
        
        //contract = [select Account_Name__c, Opportunity_Name__c, CurrencyIsoCode, VAN_Currencies__c from eNEtt_Contract__c where Id = :sr.Id];
        //system.assertEquals(testaccount.Id, contract.Account_Name__c);
        //system.assertEquals(opp.Id, contract.Opportunity_Name__c);
        //No Custom Setting Present
//        system.assertEquals('AUD', contract.CurrencyIsoCode);
    }
}