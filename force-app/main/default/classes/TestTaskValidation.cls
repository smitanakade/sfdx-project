/*
Author: Paul Swarnapandian
Last Updated: 11/05/2015
Company: SMS M&T

*/

@isTest
public class TestTaskValidation{

    static testMethod void testUpdate(){
       setUpTestData();
    }
     public static void setUpTestData(){
        
        Datetime dt = DateTime.parse('10/10/2014 12:00 AM');
        Account testaccount = new Account(Name = 'Account Test', Legal_Name__c = 'Account Test', eNett_Products__c = 'VANs',
        Client_Status__c = 'Prospect', IntegratorModifiedDate__c = system.now(), IsApi__c = true, DD_Completed_Date__c = dt);//, Client_internal_classification__c = 100000.00 );
        insert testaccount;
        
        Contact contactperson = new Contact(FirstName = 'Firsttest', LastName = 'Lastest', AccountId = testaccount.id, IsApi__c = true);
        insert contactperson ;
        
        /*Opportunity Opp = new Opportunity(Name= 'Test Opp', AccountId = testaccount.id, Product__c = 'VANs', 
        Type = 'New', CloseDate = date.valueOf('2014-01-01'), 
        StageName = '1. Prospect', CurrencyIsoCode = 'USD', Primary_Implementation_Contact__c = contactperson.Id, 
        Delivery_Type__c = 'Delivery - Desktop', Region__c= 'Americas');*/
        
        /*Opportunity Opp = [Select Id from Opportunity where AccountId = :testaccount.Id LIMIT 1];
        opp.Primary_Implementation_Contact__c = contactperson.Id;
        opp.Delivery_Type__c = 'Delivery - Desktop';
        opp.Region__c = 'Americas';
        opp.VAN_currencies_top_3__c = 'AUD';
//        opp.attainable_ttv_monthly__c = 0;
        opp.Is_a_third_party_integration__c = FALSE;
        update opp;
             
        Case tkt = new Case (Subject = 'Delivery - ' + Opp.Name, Status = 'Active', AccountId = testaccount.id, Priority = 'Not None',
        ContactId = contactperson.Id, Related_Delivery_Opportunity__c = Opp.Id, Estimated_Completion_Date__c = System.Today() + 5);
        insert tkt;
        
        //String tktId = '500O0000004R5nX';
        String tktId = tkt.Id ;
        Task task = new Task (Subject = 'API Delivery - Confirm Completion of All Stages of Delivery', 
        Status = 'In Progress', Priority = 'High', Type = 'Task', WhatId = tktId, 
        ActivityDate = System.Today()+2, Estimated_Effort_Minutes__c = 60);
        insert task;
        
        task.Status = 'Completed';
        System.debug('The id is ' + task.WhatId);
        //System.debug('The Case id is ' + tktId); 
        
       
        try{
        
            update task;
        }
        catch (Exception e){
            System.debug ('The error is ' + e.getMessage());
        }*/
        
    }
    

}