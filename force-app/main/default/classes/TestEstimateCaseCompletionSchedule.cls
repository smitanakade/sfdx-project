@istest
class TestEstimateCaseCompletionSchedule {
    static testmethod void test() {
        
        Test.startTest();
        
        Datetime dt = DateTime.parse('10/10/2014 12:00 AM');
        
        Account testaccount = new Account(Name = 'Account Test', Legal_Name__c = 'Account Test', 
        Client_Status__c = 'Prospect', IntegratorModifiedDate__c = system.now(), IsApi__c = true, Due_Diligence_Completed__c = dt, Client_Type_Description__c = 'Agent');
        //Client_internal_classification__c = 100000.00 );
        insert testaccount;
        
        Contact contactperson = new Contact(FirstName = 'Firsttest', LastName = 'Lastest', AccountId = testaccount.id, IsApi__c = true);
        insert contactperson ;
        
        Opportunity Opp = new Opportunity(Name= 'Test Opp', AccountId = testaccount.id, Product__c = 'VANs', 
        Type = 'New', CloseDate = date.valueOf('2014-01-01'), 
        StageName = '1. Prospect', CurrencyIsoCode = 'USD', Primary_Implementation_Contact__c = contactperson.Id, 
        Delivery_Type__c = 'Delivery - Desktop', Region__c= 'Americas');
        /*insert Opp;
        
        Case tkt = new Case (Subject = 'Delivery - ' + Opp.Name, Status = 'Active', AccountId = testaccount.id, 
        ContactId = contactperson.Id, RecordTypeId = '01290000000iE8c', Related_Delivery_Opportunity__c = Opp.Id, Estimated_Completion_Date__c = System.Today() + 1);
        insert tkt;
        
        try{
        Task task = new Task (Subject = 'Update the Estimated Completion Date', Status = 'Not Started', 
        Priority = 'High', Type = 'Task', WhatId = tkt.id, ActivityDate = System.Today()+2);
        insert task; 
        
        Date todayDate = System.today();
        
        List<Case> needsUpdate = [SELECT Notify_Estimated_Completion_Date__c FROM Case WHERE Estimated_Completion_Date__c < TODAY 
                                  AND Status IN ('Active', 'Dormant') AND Notify_Estimated_Completion_Date__c = FALSE AND RecordTypeId NOT IN ('01290000000hwKc', 
                                  '01290000000iCRi', '01290000000i3QX', '01290000000iE8h', '01290000000huwY')];
        //System.debug('The size is ' + needsUpdate.size());
        for (Case thisCase : needsUpdate) {
            thisCase.Notify_Estimated_Completion_Date__c = TRUE;                               
        }
        
        UPDATE needsUpdate;
        
        Date cronTime = System.today() + 1;
           
        String batchSchedule  = '0 0 0 ' + cronTime.day() + ' ' + cronTime.month() + ' ? ' + cronTime.year();
        
        //System.debug('The cron Time is ' + cronTime );
        //System.debug('The schedule is ' + batchSchedule);
        
        String jobId = System.schedule('testBasicScheduledApex', batchSchedule , new DailyCaseExecution());
        //String jobId = System.schedule('testBasicScheduledApex', (String) cronTime , new DailyCaseExecution());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        /*System.debug ('The expression is ' + ct.CronExpression);
        System.debug ('No of Times Triggerd is ' + ct.TimesTriggered);
        System.debug ('Next Execution ' + ct.NextFireTime );*/
        //System.debug ('The expression is ' + ct.CronExpression);
        /*}
        catch(Exception ex)
        {
        }*/
    }
}