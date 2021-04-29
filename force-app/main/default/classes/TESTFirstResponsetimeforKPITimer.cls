@isTest
private class TESTFirstResponsetimeforKPITimer {
    static testMethod void runTestFirstResponsetimeforKPITimerforTicket() {
    
    Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator (no expiry)']; 
    
      Account account = new Account(Name = 'Account Test 3', Legal_Name__c = 'Account Test3', Client_Status__c = 'Prospect', IsApi__c = true);
      insert account;
      Contact contact = new Contact(FirstName = 'Testa', LastName = 'Testaw', Account = [select id from Account where Account.Name = 'Account Test 3'], IsApi__c = true);
      insert contact;
      Stop_Status__c ss = new Stop_Status__c(Name = 'Pending');
      insert ss;
      
        Case cnew=new Case(Contact = [select id from contact Order by createddate Desc LIMIT 1], Origin = 'Email', Status = 'New',  Subject = 'New problem to solve for helpdesk', Priority = 'Critical', Product__c = 'VANs', Category__c = 'Sales', Description__c = 'Campaign', Hidden_Refresh_area__c = 1, Hidden_CC_Address__c = 'benchen70@gmail.com;b@gmail.com;c@gmail.com;d@gmail.com;internalservice@enett.com;f@gmail.com;g@gmail.com;h@gmail.com;j@gmail.com;k@gmail.com');

        insert cnew;

        Task tnew = new Task(Subject = 'Call - Connected', WhatId = cnew.Id, Status = 'Not Started', Type = 'Task', Priority = 'Normal', OwnerId = '00590000000riL4', RecordTypeId = '01290000000hwz1');
        //insert tnew;
        //tnew.Estimated_Effort_Minutes__c = 4;
        //tnew.status = 'Completed';
		//update tnew;
		        
        cnew.Final_Solution__c = 'Thank you very much. This is now resolved.';
        cnew.Status = 'Closed';
        update cnew;
      
}
}