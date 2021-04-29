@isTest 
private class TestClassDeliveryOpportunityAndTicket {
    static testMethod void TestClassDelivery() {
    
        Datetime dt = DateTime.parse('10/10/2014 12:00 AM');
        
        
        Account testaccount = new Account(Name = 'Account Test', Legal_Name__c = 'Account Test', Client_Status__c = 'Prospect', IntegratorModifiedDate__c = system.now(), IsApi__c = true, Due_Diligence_Completed__c = dt);
        insert testaccount;
        id testaccountid = testaccount.id;
        Contact contactperson = new Contact(FirstName = 'Firsttest', LastName = 'Lastest', AccountId = testaccountid , IsApi__c = true);
        insert contactperson ;
        id contactpersonId = contactperson.Id;
        Stop_Status__c ss = new Stop_Status__c(Name = 'Pending');
        insert ss; 
        
        Datetime ddt = testaccount.Due_Diligence_Completed__c;
        Date DueDiligenceDate = ddt.date();

        Opportunity Opp = new Opportunity(Name= 'Test Opp', AccountId = testaccountid , Product__c = 'VANs', Type = 'New', CloseDate = date.valueOf('2014-01-01'), StageName = '1. Prospect', CurrencyIsoCode = 'USD', Primary_Implementation_Contact__c =contactpersonId, Delivery_Type__c = null);
        /*insert Opp;

        Case DeliveryTicket = new Case(Subject = Opp.name, Related_Delivery_Opportunity__c = Opp.id, ContactId = contactperson.Id , Status = 'Active', Priority = 'Not None', RecordTypeId = '01290000000iE8h' );
        insert DeliveryTicket;
        
        Opp.Delivery_Type__c = 'Delivery - Desktop';
        //update Opp;
        
        String unassigneddesktopnotes = 'Notes here';
        DeliveryTicket.Unassigned_Delivery_Notes__c = unassigneddesktopnotes ;
        update DeliveryTicket;
        
        String unassigneddesktopnotes2 = 'Another set of notes';
        DeliveryTicket.Unassigned_Delivery_Notes__c = unassigneddesktopnotes2 ;
        update DeliveryTicket;*/
   }     
 }