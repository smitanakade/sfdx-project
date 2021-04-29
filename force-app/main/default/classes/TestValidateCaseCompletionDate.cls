/*
Author: Paul Swarnapandian
Last Updated: 11/05/2015
Company: SMS M&T

*/

@isTest
public class TestValidateCaseCompletionDate {

    static testMethod void testUpdate(){
       setUpTestData();
    }
     public static void setUpTestData(){
        
        Datetime dt = DateTime.parse('10/10/2014 12:00 AM');
        Account testaccount = new Account(Name = 'Account Test', Legal_Name__c = 'Account Test', 
        Client_Status__c = 'Prospect', IntegratorModifiedDate__c = system.now(), IsApi__c = true, Due_Diligence_Completed__c = dt);//, Client_internal_classification__c = 100000.00 );
        insert testaccount;
        
        Contact contactperson = new Contact(FirstName = 'Firsttest', LastName = 'Lastest', AccountId = testaccount.id, IsApi__c = true);
        insert contactperson ;
        
        /*Opportunity Opp = new Opportunity(Name= 'Test Opp', AccountId = testaccount.id, Product__c = 'VANs', 
        Type = 'New', CloseDate = date.valueOf('2014-01-01'), 
        StageName = '1. Prospect', CurrencyIsoCode = 'USD', Primary_Implementation_Contact__c = contactperson.Id, 
        Delivery_Type__c = 'Delivery - Desktop', Region__c= 'Americas');
        insert Opp;
        
        Case tkt = new Case (Subject = 'Delivery - ' + Opp.Name, Status = 'Active', AccountId = testaccount.id, Priority = 'Not None',
        ContactId = contactperson.Id, Related_Delivery_Opportunity__c = Opp.Id, Estimated_Completion_Date__c = System.Today() - 1);
        insert tkt;
        
        Task task = new Task (Subject = 'Delivery Estimated Completion Date', Status = 'Not Started', 
        Priority = 'High', Type = 'Task', WhatId = tkt.id, ActivityDate = System.Today()+2);
        insert task;
        
        tkt.Estimated_Completion_Date__c = System.Today() + 1;
        tkt.Justification_of_Change_to_Date__c = 'Test Validate Case Completion Date';
        
        update tkt;
        
        task.Estimated_Effort_Minutes__c = 2;
        task.Status = 'Completed';
        System.debug('The id is ' + task.WhatId);
        System.debug('The Case id is ' + tkt.id);*/
        
        // This is to test the Desktop Training Seession Event Task
        /*Task trainingTask = new Task (Subject = 'Desktop Delivery - Create Desktop Training Session Event', Status = 'Not Started', 
        Priority = 'High', Type = 'Task', WhatId = tkt.id, ActivityDate = System.Today()+2);
        insert trainingTask ;
        trainingTask.status = 'Completed';
        
        // This is to test the Desktop Delivery - Confirm date of Funding Task
        Task fundingTask = new Task (Subject = 'Desktop Delivery - Confirm date of Funding Task', Status = 'Not Started', 
        Priority = 'High', Type = 'Task', WhatId = tkt.id, ActivityDate = System.Today()+2);
        insert fundingTask;
        fundingTask.status = 'Completed';
        
         // This is to test the API Delivery - Send Demo API ECN details Test Scenario and VANs Setting Quest
        Task demoAPITask = new Task (Subject = 'API Delivery - Send Demo API ECN details Test Scenario and VANs Setting Quest', Status = 'Not Started', 
        Priority = 'High', Type = 'Task', WhatId = tkt.id, ActivityDate = System.Today()+2);
        insert demoAPITask;
        demoAPITask.status = 'Completed';
        
         // This is to test the API Del Delivery Completed
        Task delCompletedTask = new Task (Subject = 'API Del Delivery Completed', Status = 'Not Started', 
        Priority = 'High', Type = 'Task', WhatId = tkt.id, ActivityDate = System.Today()+2);
        insert delCompletedTask;
        delCompletedTask.status = 'Completed';
        
        
        // This is to test the API Delivery - Reporting Training Session Task
        Task reportTask = new Task (Subject = 'API Del Delivery Completed', Status = 'Not Started', 
        Priority = 'High', Type = 'Task', WhatId = tkt.id, ActivityDate = System.Today()+2);
        insert reportTask;
        reportTask.status = 'Completed';
        

        // This is to test the API Delivery - UAT Testing Checkpoint Task
        Task uatTask = new Task (Subject = 'API Delivery - UAT Testing Checkpoint Task', Status = 'Not Started', 
        Priority = 'High', Type = 'Task', WhatId = tkt.id, ActivityDate = System.Today()+2);
        insert uatTask;
        uatTask.status = 'Completed';
        
        // This is to test the API Delivery - Enter all Milestone Projected Values
        Task milestoneTask = new Task (Subject = 'API Delivery - Enter all Milestone Projected Values', Status = 'Not Started', 
        Priority = 'High', Type = 'Task', WhatId = tkt.id, ActivityDate = System.Today()+2);
        insert milestoneTask;
        milestoneTask.status = 'Completed';*/
        
        // This is to test the API Delivery - Confirm Completion of All Stages of Delivery
        /*Task allStagesTask = new Task (Subject = 'API Delivery - Confirm Completion of All Stages of Delivery', Status = 'Not Started', 
        Priority = 'High', Type = 'Task', WhatId = tkt.id, ActivityDate = System.Today()+2);
        insert allStagesTask;
        allStagesTask.status = 'Completed';
        
        try{
        update task;*/
        /*update fundingTask;
        update trainingTask;
        update demoAPITask;
        update delCompletedTask;
        update reportTask;
        update uatTask;
        update milestoneTask;*/
        //update allStagesTask;
        //System.debug('The case date is ' + tkt.Estimated_Completion_Date__c);
        //}
        //catch (Exception e){
        //    System.debug ('The error is ' + e.getMessage());
        //}
        
    }
    

}