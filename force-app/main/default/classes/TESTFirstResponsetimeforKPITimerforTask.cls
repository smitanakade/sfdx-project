@isTest 
private class TESTFirstResponsetimeforKPITimerforTask{
    static testMethod void TestFirstResponsetimeforTask() {
    
     Account account = new Account(Name = 'Account Test', Legal_Name__c = 'Account Test', Client_Status__c = 'Prospect', IntegratorModifiedDate__c = system.now(), IsApi__c = true);
     insert account;
     Contact contact = new Contact(FirstName = 'Test', LastName = 'Test', Account = [select id from Account where Account.Name = 'Account Test'], IsApi__c = true);
     insert contact;
     Stop_Status__c ss = new Stop_Status__c(Name = 'Pending');
     insert ss; 
     
     BusinessHours LondonHours = [select Id from BusinessHours where Name = 'London' ];
     Id LondonHoursid = LondonHours.Id;
        
     Case c = new Case (Account = [select id from Account where Name = 'Account Test'], Contact = [select id from Contact where FirstName = 'Test' and LastName = 'Test'], Status = 'Open', Origin = 'Call', Type = 'Problem', Product__c = 'VANs', Category__c = 'VANs', Description__c = 'Query', Subject = 'New problem to solve for helpdesk', Priority = 'Critical', Hidden_Refresh_area__c = 1, Hidden_CC_Address__c = 'benchen70@gmail.com; internalservice@enett.com ', BusinessHoursId = LondonHoursid );
        
     insert c; 
     Id ticketId = c.Id;
     system.Debug('he ticketid is ' + ticketId); 
     
     Task t = new Task (WhatId = ticketId, Subject = 'Email', OwnerId = '00590000000riL4', Type = 'Email', Status = 'Completed', Priority = 'Normal');
     System.Debug('this what Id umber for ticket is now ' + t.whatId);
     insert t;
     
     }
     }