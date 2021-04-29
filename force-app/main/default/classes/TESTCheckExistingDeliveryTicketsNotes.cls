@isTest
private class TESTCheckExistingDeliveryTicketsNotes  {
    static testMethod void runTestCheckExistingDeliveryTicketsPhaseNotes () {
        User saUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        Datetime dt = DateTime.parse('10/10/2014 12:00 AM');
        Date dtDate = dt.Date();
        Date contractenddate = date.valueOf('2014-01-01');
    
        Delivery_Category_Benchmarks__c deliverybenchmark = new Delivery_Category_Benchmarks__c(Name = 'API - Remote', Delivery_Category__c  = 'API - API Integration Remote', Days__c = 35);
        insert deliverybenchmark;

// First account
        Account testaccount = new Account(Name = 'Account Test', Legal_Name__c = 'Account Test', Client_Status__c = 'Prospect', IsApi__c = true, Due_Diligence_Completed__c = null);//, Client_internal_classification__c = 1000.00);
        insert testaccount;
        id testaccountid = testaccount.id;
        Contact contactperson = new Contact(FirstName = 'Firsttest', LastName = 'Lastest', AccountId = testaccount.id , IsApi__c = true);
        insert contactperson ;
        id contactpersonId = contactperson.Id;
        
//first opportunity - Delivery type API
        
        Opportunity Opp1 = new Opportunity(Name= 'Test Opp1', AccountId = testaccount.id , Product__c = 'VANs', Type = 'New', CloseDate = contractenddate, StageName = '1. Prospect', CurrencyIsoCode = 'USD', Primary_Implementation_Contact__c =contactperson.Id, Delivery_Type__c = 'Delivery - API');
        /*insert Opp1;
        Case DeliveryTicket1 = new Case(AccountId = testaccount.id, Subject = Opp1.Name, Related_Delivery_Opportunity__c = Opp1.id, ContactId = contactperson.Id, Delivery_Phase__c = '0 - Pre-Implementation Kick-off', RecordTypeId = '01290000000iE8V', API_Delivery_Category__c = deliverybenchmark.Delivery_Category__c, Delivery_Category_Benchmark_Days__c = deliverybenchmark.Days__c, Delivery_Type__c = Opp1.Delivery_Type__c);
        insert DeliveryTicket1;
        
        DeliveryTicket1.Unassigned_Delivery_Notes__c = 'New Notes for Unassigned';
        update DeliveryTicket1;
        
        DeliveryTicket1.Unassigned_Delivery_Notes__c = 'More Notes for Unassigned';
        update DeliveryTicket1;
        
        DeliveryTicket1.Phase_0_Notes__c = 'New Notes for Phase 0';
        update DeliveryTicket1;
        
        DeliveryTicket1.Phase_0_Notes__c = 'More Notes for Phase 0';
        update DeliveryTicket1;

        DeliveryTicket1.Phase_1_Notes__c = 'New Notes for Phase 1';
        update DeliveryTicket1;
        
        DeliveryTicket1.Phase_1_Notes__c = 'More Notes for Phase 1';
        update DeliveryTicket1;

        DeliveryTicket1.Phase_2_Notes__c = 'New Notes for Phase 2';
        update DeliveryTicket1;
        
        DeliveryTicket1.Phase_2_Notes__c = 'More Notes for Phase 2';
        update DeliveryTicket1;

        DeliveryTicket1.Phase_3_Notes__c = 'New Notes for Phase 3';
        update DeliveryTicket1;
        
        DeliveryTicket1.Phase_3_Notes__c = 'More Notes for Phase 3';
        update DeliveryTicket1;

        DeliveryTicket1.Phase_4_Notes__c = 'New Notes for Phase 4';
        update DeliveryTicket1;
        
        DeliveryTicket1.Phase_4_Notes__c = 'More Notes for Phase 4';
        update DeliveryTicket1;

        DeliveryTicket1.Phase_5_Notes__c = 'New Notes for Phase 5';
        update DeliveryTicket1;
        
        DeliveryTicket1.Phase_5_Notes__c = 'More Notes for Phase 5';
        update DeliveryTicket1;
        
        DeliveryTicket1.Estimated_Completion_Date__c = Date.Today();
        update DeliveryTicket1;
        
        DeliveryTicket1.Estimated_Completion_Date__c = Date.Today().AddDays(60);
        DeliveryTicket1.Justification_of_Change_to_Date__c = 'Justification one';
        update DeliveryTicket1;
        
        DeliveryTicket1.Justification_of_Change_to_Date__c = 'Justification More';
        update DeliveryTicket1;            */
    }
}