@isTest(SeeAllData=true)
private class TESTCheckExistingDeliveryTicketsFour {
    static testMethod void runTestCheckExistingDeliveryTicketsFour () {
    
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator (no expiry)']; 
        UserRole r = [SELECT Id FROM UserRole WHERE Name = 'Global Service Desk Level 2'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Australia/Sydney', UserName='z@testorg.com', UserRoleId = r.Id);
      
        System.runAs(u){

            Datetime dt = DateTime.parse('10/10/2014 12:00 AM');
            Date dtDate = dt.Date();
            Date contractenddate = date.valueOf('2014-01-01');
            
            Delivery_Category_Benchmarks__c deliverybenchmark = new Delivery_Category_Benchmarks__c(Name = 'Desktop - Low', Delivery_Category__c  = 'Desktop - Low Touch Self Sufficient', Days__c = 20);
            insert deliverybenchmark;
            Delivery_Category_Benchmarks__c deliverybenchmark1 = new Delivery_Category_Benchmarks__c(Name = 'API - Remote', Delivery_Category__c  = 'API - API Integration Remote', Days__c = 35);
            insert deliverybenchmark1;
            Delivery_Category_Benchmarks__c deliverybenchmark2 = new Delivery_Category_Benchmarks__c(Name = 'Desktop - High', Delivery_Category__c  = 'Desktop - High Touch Training / Consultation', Days__c = 45);
            insert deliverybenchmark2;
            Delivery_Category_Benchmarks__c deliverybenchmark3 = new Delivery_Category_Benchmarks__c(Name = 'API - Complex', Delivery_Category__c  = 'API - Complex Large Business Onsite', Days__c = 70);
            insert deliverybenchmark3;
     
     
    // third  account - DD NOT completed
            Account testaccount = new Account(Name = 'Account Test', Legal_Name__c = 'Account Test', Client_Status__c = 'Prospect', IsApi__c = true, Due_Diligence_Completed__c = null);//, Client_internal_classification__c = 1000.00);
            insert testaccount;
            id testaccountid = testaccount.id;
            Contact contactperson = new Contact(FirstName = 'Firsttest', LastName = 'Lastest', AccountId = testaccount.id , IsApi__c = true);
            insert contactperson ;
            id contactpersonId = contactperson.Id;
            
    // opportunity - Delivery type API - then completed DD
            
            Opportunity Opp1 = new Opportunity(Name= 'Test Opp1', AccountId = testaccount.id , Product__c = 'VANs', Type = 'New',  CloseDate = contractenddate, StageName = '1. Prospect', CurrencyIsoCode = 'USD', Primary_Implementation_Contact__c =contactperson.Id, Delivery_Type__c = 'Delivery - API');//, attainable_ttv_monthly__c = 1, GDV_Change_Justification__c = '');
            insert Opp1;
            
          //  Opp1.attainable_ttv_monthly__c = 2;
           // Opp1.GDV_Change_Justification__c = 'reason alive';
            //update Opp1;
    
            Case DeliveryTicket1 = new Case(AccountId = testaccount.id, Subject = Opp1.name, Related_Delivery_Opportunity__c = Opp1.id, ContactId = contactperson.Id , Status = 'Active', Delivery_Phase__c = '0 - Pre-Implementation Kick-off', RecordTypeId = '01290000000iE8V', Delivery_Category__c = deliverybenchmark1.Delivery_Category__c, Delivery_Category_Benchmark_Days__c = deliverybenchmark1.Days__c, Delivery_Type__c = Opp1.Delivery_Type__c);
            insert DeliveryTicket1;
            
            testaccount.Due_Diligence_Completed__c = date.valueOf('2014-01-01');
            
            
            DeliveryTicket1.API_Delivery_Category__c = deliverybenchmark3.Delivery_Category__c;
            update DeliveryTicket1;
            
            DeliveryTicket1.Phase_3_Notes__c = 'Morgan Freeman';
            update DeliveryTicket1;
            
            DeliveryTicket1.Phase_3_Notes__c = 'Not  Freeman';
            update DeliveryTicket1;
            
            DeliveryTicket1.Status = 'Pending';
            update  DeliveryTicket1;
            
    //this below tests the ticket deletion
            try{
                Delete DeliveryTicket1;
            }
            catch(System.DmlException ex){
                }
            }
        }
}