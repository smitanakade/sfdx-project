@isTest
private class TESTDeleteonNewTicket {
    
    /* Unit tests no longer relevant since functionality is now handled by Process Task object
    static testMethod void runCompletedDelivery() {
    
      Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator (no expiry)']; 
      
      User u = new User(Alias = 'bbbbb', Email='bbbbb@testorg.com', 
      EmailEncodingKey='UTF-8', LastName='aaaa', LanguageLocaleKey='en_US', 
      LocaleSidKey='en_US', ProfileId = p.Id, 
      TimeZoneSidKey='America/Los_Angeles', UserName='bbbbb@testorg.com');
      
      Account account = new Account(Name = 'Account Test 3', Legal_Name__c = 'Account Test3', Client_Status__c = 'Prospect', IsApi__c = true);
      insert account;
      Contact contact = new Contact(FirstName = 'Testa', LastName = 'Testaw', Account = [select id from Account where Account.Name = 'Account Test 3'], IsApi__c = true);
      insert contact;
      Stop_Status__c ss = new Stop_Status__c(Name = 'Pending');
      insert ss;
      
      Task T;
      System.runAs(u) {
            Case cnew=new Case(Contact = [select id from contact Order by createddate Desc LIMIT 1], Origin = 'Email', Status = 'New',  Subject = 'New problem to solve for helpdesk', Priority = 'Critical', Product__c = 'VANs', Category__c = 'Sales', Description__c = 'Campaign', Hidden_Refresh_area__c = 1, Hidden_CC_Address__c = 'benchen70@gmail.com;b@gmail.com;c@gmail.com;d@gmail.com;internalservice@enett.com;f@gmail.com;g@gmail.com;h@gmail.com;j@gmail.com;k@gmail.com');
            insert cnew;
            delete cnew;
        
            Case copen=new Case(Contact = [select id from contact Order by createddate Desc LIMIT 1], Status = 'Open',  Subject = 'Open problem to solve for helpdesk', Priority = 'Normal', Product__c = 'VANs', Category__c = 'Sales', Description__c = 'Campaign', Hidden_Refresh_area__c = 1, Hidden_CC_Address__c = 'benchen70@gmail.com;b@gmail.com;c@gmail.com;d@gmail.com;e@gmail.com;f@gmail.com;internalservice@enett.com;h@gmail.com;j@gmail.com;k@gmail.com');
            insert copen;
            try{
                delete copen;
                system.assert(true);
                undelete copen;
                system.assert(true);
            }catch(Exception e){
                system.assert(copen.id != null);
            }
            
            T = new Task( WhatId = copen.Id, Subject = 'Test' );
            insert t;
            
            t.Status = 'Completed';
            t.Subject = 'API Delivery Test';
            try{
                update t;
            }catch(Exception ex){
                system.assert(true);
            }
            
            t.Estimated_Effort_Minutes__c  = 1;
            update t;
            
            try{
                delete t;
            }catch(Exception ex){
                system.assert(true);  //we should not be able to delete as we are privilidged
            }
            
      }
    }
            
    static testMethod void runTraining() {
    
      Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator (no expiry)']; 
      
      User u = new User(Alias = 'bbbbb', Email='bbbbb@testorg.com', 
      EmailEncodingKey='UTF-8', LastName='aaaa', LanguageLocaleKey='en_US', 
      LocaleSidKey='en_US', ProfileId = p.Id, 
      TimeZoneSidKey='America/Los_Angeles', UserName='bbbbb@testorg.com');
      
      Account account = new Account(Name = 'Account Test 3', Legal_Name__c = 'Account Test3', Client_Status__c = 'Prospect', IsApi__c = true);
      insert account;
      Contact contact = new Contact(FirstName = 'Testa', LastName = 'Testaw', Account = [select id from Account where Account.Name = 'Account Test 3'], IsApi__c = true);
      insert contact;
      Stop_Status__c ss = new Stop_Status__c(Name = 'Pending');
      insert ss;
      
      Task T;
      System.runAs(u) {
            Case cnew=new Case(Contact = [select id from contact Order by createddate Desc LIMIT 1], Origin = 'Email', Status = 'New',  Subject = 'New problem to solve for helpdesk', Priority = 'Critical', Product__c = 'VANs', Category__c = 'Sales', Description__c = 'Campaign', Hidden_Refresh_area__c = 1, Hidden_CC_Address__c = 'benchen70@gmail.com;b@gmail.com;c@gmail.com;d@gmail.com;internalservice@enett.com;f@gmail.com;g@gmail.com;h@gmail.com;j@gmail.com;k@gmail.com');
            insert cnew;
            delete cnew;
        
            Case copen=new Case(Contact = [select id from contact Order by createddate Desc LIMIT 1], Status = 'Open',  Subject = 'Open problem to solve for helpdesk', Priority = 'Normal', Product__c = 'VANs', Category__c = 'Sales', Description__c = 'Campaign', Hidden_Refresh_area__c = 1, Hidden_CC_Address__c = 'benchen70@gmail.com;b@gmail.com;c@gmail.com;d@gmail.com;e@gmail.com;f@gmail.com;internalservice@enett.com;h@gmail.com;j@gmail.com;k@gmail.com');
            insert copen;
            try{
                delete copen;
                system.assert(true);
                undelete copen;
                system.assert(true);
            }catch(Exception e){
                system.assert(copen.id != null);
            }
            
            T = new Task( WhatId = copen.Id, Subject = 'Test' );
            insert t;
            
            t.Status = 'Completed';
            t.Subject = 'Desktop Delivery - Create Desktop Training Session Event';
            t.Estimated_Effort_Minutes__c  = 1;
            try{
                update t;
            }catch(Exception ex){
                system.assert(true);
            }
            
            t.Training_Date_and_Time__c = datetime.now();
            update t;
            
            try{
                delete t;
            }catch(Exception ex){
                system.assert(true);  //we should not be able to delete as we are privilidged
            }
            
      }
    }
            
            
    static testMethod void runFnding() {
    
      Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator (no expiry)']; 
      
      User u = new User(Alias = 'bbbbb', Email='bbbbb@testorg.com', 
      EmailEncodingKey='UTF-8', LastName='aaaa', LanguageLocaleKey='en_US', 
      LocaleSidKey='en_US', ProfileId = p.Id, 
      TimeZoneSidKey='America/Los_Angeles', UserName='bbbbb@testorg.com');
      
      Account account = new Account(Name = 'Account Test 3', Legal_Name__c = 'Account Test3', Client_Status__c = 'Prospect', IsApi__c = true);
      insert account;
      Contact contact = new Contact(FirstName = 'Testa', LastName = 'Testaw', Account = [select id from Account where Account.Name = 'Account Test 3'], IsApi__c = true);
      insert contact;
      Stop_Status__c ss = new Stop_Status__c(Name = 'Pending');
      insert ss;
      
      Task T;
      System.runAs(u) {
            Case cnew=new Case(Contact = [select id from contact Order by createddate Desc LIMIT 1], Origin = 'Email', Status = 'New',  Subject = 'New problem to solve for helpdesk', Priority = 'Critical', Product__c = 'VANs', Category__c = 'Sales', Description__c = 'Campaign', Hidden_Refresh_area__c = 1, Hidden_CC_Address__c = 'benchen70@gmail.com;b@gmail.com;c@gmail.com;d@gmail.com;internalservice@enett.com;f@gmail.com;g@gmail.com;h@gmail.com;j@gmail.com;k@gmail.com');
            insert cnew;
            delete cnew;
        
            Case copen=new Case(Contact = [select id from contact Order by createddate Desc LIMIT 1], Status = 'Open',  Subject = 'Open problem to solve for helpdesk', Priority = 'Normal', Product__c = 'VANs', Category__c = 'Sales', Description__c = 'Campaign', Hidden_Refresh_area__c = 1, Hidden_CC_Address__c = 'benchen70@gmail.com;b@gmail.com;c@gmail.com;d@gmail.com;e@gmail.com;f@gmail.com;internalservice@enett.com;h@gmail.com;j@gmail.com;k@gmail.com');
            insert copen;
            try{
                delete copen;
                system.assert(true);
                undelete copen;
                system.assert(true);
            }catch(Exception e){
                system.assert(copen.id != null);
            }
            
            T = new Task( WhatId = copen.Id, Subject = 'Test' );
            insert t;
            
            t.Status = 'Completed';
            t.Subject = 'Desktop Delivery - Confirm date of Funding Task';
            t.Estimated_Effort_Minutes__c  = 1;
            try{
                update t;
            }catch(Exception ex){
                system.assert(true);
            }
            t.Funding_Due_Date__c = date.today();
            update t;
            
            try{
                delete t;
            }catch(Exception ex){
                system.assert(true);  //we should not be able to delete as we are privilidged
            }
            
      }
    }


   static testMethod void runDemo() {
    
      Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator (no expiry)']; 
      
      User u = new User(Alias = 'bbbbb', Email='bbbbb@testorg.com', 
      EmailEncodingKey='UTF-8', LastName='aaaa', LanguageLocaleKey='en_US', 
      LocaleSidKey='en_US', ProfileId = p.Id, 
      TimeZoneSidKey='America/Los_Angeles', UserName='bbbbb@testorg.com');
      
      Account account = new Account(Name = 'Account Test 3', Legal_Name__c = 'Account Test3', Client_Status__c = 'Prospect', IsApi__c = true);
      insert account;
      Contact contact = new Contact(FirstName = 'Testa', LastName = 'Testaw', Account = [select id from Account where Account.Name = 'Account Test 3'], IsApi__c = true);
      insert contact;
      Stop_Status__c ss = new Stop_Status__c(Name = 'Pending');
      insert ss;
      
      Task T;
      System.runAs(u) {
            Case cnew=new Case(Contact = [select id from contact Order by createddate Desc LIMIT 1], Origin = 'Email', Status = 'New',  Subject = 'New problem to solve for helpdesk', Priority = 'Critical', Product__c = 'VANs', Category__c = 'Sales', Description__c = 'Campaign', Hidden_Refresh_area__c = 1, Hidden_CC_Address__c = 'benchen70@gmail.com;b@gmail.com;c@gmail.com;d@gmail.com;internalservice@enett.com;f@gmail.com;g@gmail.com;h@gmail.com;j@gmail.com;k@gmail.com');
            insert cnew;
            delete cnew;
        
            Case copen=new Case(Contact = [select id from contact Order by createddate Desc LIMIT 1], Status = 'Open',  Subject = 'Open problem to solve for helpdesk', Priority = 'Normal', Product__c = 'VANs', Category__c = 'Sales', Description__c = 'Campaign', Hidden_Refresh_area__c = 1, Hidden_CC_Address__c = 'benchen70@gmail.com;b@gmail.com;c@gmail.com;d@gmail.com;e@gmail.com;f@gmail.com;internalservice@enett.com;h@gmail.com;j@gmail.com;k@gmail.com');
            insert copen;
            try{
                delete copen;
                system.assert(true);
                undelete copen;
                system.assert(true);
            }catch(Exception e){
                system.assert(copen.id != null);
            }
            
            T = new Task( WhatId = copen.Id, Subject = 'Test' );
            insert t;
            
            t.Status = 'Completed';
            t.Subject = 'API Del Send DEMO ECN and API Credential';
            t.Estimated_Effort_Minutes__c  = 1;
            try{
                update t;
            }catch(Exception ex){
                system.assert(true);
            }
            t.Demo_ECN_and_API_Credentials__c = 'Test';
            update t;
            
            try{
                delete t;
            }catch(Exception ex){
                system.assert(true);  //we should not be able to delete as we are privilidged
            }
            
      }
    }
    */
}