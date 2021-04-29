@isTest
public class TESTtaskupdateticketANDTicketupdateOpp  {
    static testMethod void runTESTtaskupdateticketANDTicketupdateOpp() {
        
        Datetime dt = DateTime.parse('10/10/2014 12:00 AM');

        Account testaccount = new Account(Name = 'Account Test', Legal_Name__c = 'Account Test', Client_Status__c = 'Prospect', IntegratorModifiedDate__c = system.now(), IsApi__c = true, Due_Diligence_Completed__c = dt);
        insert testaccount;
        
        Contact contactperson = new Contact(FirstName = 'Firsttest', LastName = 'Lastest', AccountId = testaccount.id , IsApi__c = true);
        insert contactperson ;
        
        Datetime ddt = testaccount.Due_Diligence_Completed__c;
        Date DueDiligenceDate = ddt.date();

        Opportunity Opp1 = new Opportunity(Name= 'Test Opp', AccountId = testaccount.id , Product__c = 'VANs', Type = 'New', CloseDate = date.valueOf('2014-01-01'), StageName = '1. Prospect', CurrencyIsoCode = 'USD', Primary_Implementation_Contact__c =contactperson.Id, Delivery_Type__c = null);
        /*insert Opp1;
        
        Case DeliveryTicket = new Case(AccountId = testaccount.id, Subject = Opp1.name, Related_Delivery_Opportunity__c = Opp1.id, ContactId = contactperson.Id , Status = 'Active', Priority = 'Not None');
        insert DeliveryTicket;
        
        Case_Field_Update__c fieldUpdateRecord = new Case_Field_Update__c(Name = '01290000000iEI4AAM', Field_Name__c = 'Pre_Kick_off_Questionnaire_Sent__c', Task_recordtype_name__c = 'API_Delivery_Introductory_Email');
        insert fieldUpdateRecord;
        
        Opp1.Delivery_Type__c = 'Delivery - Desktop';
        //update Opp1;
        
        Opp1.Delivery_Type__c = 'Delivery - API';
        //update Opp1;
        
        
        Task t1 = new Task(WhatId = DeliveryTicket.id, Subject = 'API Delivery - Send Pre Kick-off Questionnaire', Status = 'In Progress', Related_Account__c = testaccount.Name, Delivery_Phase__c = DeliveryTicket.Delivery_Phase__c, Delivery_Type__c = DeliveryTicket.Delivery_Type__c );
        insert t1;
        //System.AssertEquals('01290000000iEI4AAM', t1.RecordTypeId);
        System.AssertEquals(t1.Delivery_Phase__c,DeliveryTicket.Delivery_Phase__c);
        System.AssertEquals(t1.Related_Account__c,testaccount.Name);
        System.AssertEquals(t1.Delivery_Type__c , DeliveryTicket.Delivery_Type__c);
        
        
        DeliveryTicket.Enter_NDA_Developer_License_Signed_Date__c = Date.parse('22/01/2015');
        update DeliveryTicket;
        
        Opp1.Delivery_NDA_Signed_Date__c = Date.parse('22/01/2015');
        System.AssertEquals(DeliveryTicket.Enter_NDA_Developer_License_Signed_Date__c, Opp1.Delivery_NDA_Signed_Date__c);
        
        Id testtask1RecordTypeId = t1.RecordTypeId;
        //System.AssertEquals(testtask1RecordTypeId, '01290000000iEI4AAM');
        
        t1.Estimated_Effort_Minutes__c = 5;
        t1.Status = 'Completed';*/
        //update t1;
                
        }
}