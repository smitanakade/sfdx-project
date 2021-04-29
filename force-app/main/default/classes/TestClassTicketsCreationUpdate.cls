@isTest 
private class TestClassTicketsCreationUpdate {
    static testMethod void TestClassTicketsTrigger() {
    

        Account account = new Account(Name = 'Account Test', Legal_Name__c = 'Account Test', Client_Status__c = 'Prospect', IntegratorModifiedDate__c = system.now(), IsApi__c = true);
        insert account;
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Test', Account = [select id from Account where Account.Name = 'Account Test'], IsApi__c = true);
        insert contact;
        Stop_Status__c ss = new Stop_Status__c(Name = 'Pending');
        insert ss; 
        
        Case c = new Case (Account = [select id from Account where Name = 'Account Test'], Contact = [select id from Contact where FirstName = 'Test' and LastName = 'Test'], Status = 'Open', Origin = 'Call', Type = 'Problem', Product__c = 'VANs', Category__c = 'VANs', Description__c = 'Query', Subject = 'New problem to solve for helpdesk', Priority = 'Critical', Hidden_Refresh_area__c = 1, Hidden_CC_Address__c = 'benchen70@gmail.com; internalservice@enett.com');
        
        insert c; 
        
        Solution s = new Solution(SolutionName = 'Test Solution', SolutionNote = 'Thank you very much. We hope to use this Test Solution Details');
        
        insert s;
        
        CaseSolution cs = new CaseSolution(CaseId = c.id, SolutionId = s.id);
        
        insert cs;
        
        Decimal z = c.Hidden_Refresh_area__c;
        c.Hidden_Refresh_area__c = z + 1;
        c.Status = 'Pending';
        c.Hidden_CC_Address__c = 'benchen70@gmail.com; benchen70@outlook.com; internalservice@enett.com';
        update c;
        
        Decimal y = c.Hidden_Refresh_area__c;
        c.Hidden_Refresh_area__c = y + 1;
        c.Status = 'Open';
        c.Hidden_CC_Address__c = 'benchen70@gmail.com; benchen70@outlook.com; rod.crociani@hotmail.com; internalservice@enett.com';
        update c;
        
        
        Decimal x = c.Hidden_Refresh_area__c;
        c.Hidden_Refresh_area__c = x + 1;
        c.Status = 'Pending';
        c.Hidden_CC_Address__c = 'benchen70@gmail.com; benchen70@outlook.com; rod.crociani@hotmail.com; canyoucatchme1@gmail.com; internalservice@enett.com';
        update c;
        
        }
    }