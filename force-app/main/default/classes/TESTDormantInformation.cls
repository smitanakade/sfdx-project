@isTest
private class TESTDormantInformation {
    static testMethod void runTESTDormantInformation () {

        Datetime dt = DateTime.parse('10/10/2014 12:00 AM');
        Date dormantenddate = Date.Today().addDays(2); 

        Account testaccount = new Account(Name = 'Account Test', Legal_Name__c = 'Account Test', Client_Status__c = 'Prospect', IntegratorModifiedDate__c = system.now(), IsApi__c = true, Due_Diligence_Completed__c = dt);
        insert testaccount;
        
        Contact contactperson = new Contact(FirstName = 'Firsttest', LastName = 'Lastest', AccountId = testaccount.id , IsApi__c = true);
        insert contactperson ;
        
        Datetime ddt = testaccount.Due_Diligence_Completed__c;
        Date DueDiligenceDate = ddt.date();
        
        Opportunity Opp1 = new Opportunity(Name= 'Test Opp', AccountId = testaccount.id , Product__c = 'VANs', Type = 'New', CloseDate = date.valueOf('2014-01-01'), StageName = '1. Prospect', CurrencyIsoCode = 'USD', Primary_Implementation_Contact__c =contactperson.Id, Delivery_Type__c = null, Current_Dormant_Start_Date__c = null, Current_Dormant_reason__c = '');
        /*insert Opp1;
         
        Case DeliveryTicket = new Case(AccountId = testaccount.id, Subject = Opp1.name, Related_Delivery_Opportunity__c = Opp1.id, ContactId = contactperson.Id , Status = 'Active', Priority = 'Not None');
        insert DeliveryTicket; 
        
        Delivery_Dormant_History__c firstinstancedormant = New Delivery_Dormant_History__c(Related_Delivery_Ticket__c = DeliveryTicket.id, Dormant_Start_Date__c = Date.today(), Dormant_End_Date__c= null, Dormant_Reason__c = 'reason notes');
        insert firstinstancedormant;
        System.Debug('the dormant end date here is ' + firstinstancedormant.Dormant_End_Date__c);
                
        
        firstinstancedormant.Dormant_End_Date__c = dormantenddate;
        update firstinstancedormant;
        System.Debug('the updated dormant end date here is ' + firstinstancedormant.Dormant_End_Date__c);
        */

        }
}