@isTest
private class TESTSolution {
    static testMethod void runTestSolution() {
    
        Account account = new Account(Name = 'Account Test 3', Legal_Name__c = 'Account Test3', Trading_As__c = 'Account Test 3', ECN__c = '000001', Client_Status__c = 'Prospect', IsApi__c = true);
        insert account;
        Contact contact = new Contact(FirstName = 'Testa', LastName = 'Testaw', Account = [select id from Account where Account.Name = 'Account Test 3'], IsApi__c = true);
        insert contact;
        Stop_Status__c ss = new Stop_Status__c(Name = 'Pending');
        insert ss;        
        
        Case c=new Case(Contact = [select id from contact Where FirstName = 'Testa' and LastName = 'Testaw'], Status = 'Open',  Subject = 'New problem to solve for helpdesk', Priority = 'Critical', Product__c = 'VANs', Category__c = 'Sales', Description__c = 'Campaign', Hidden_Refresh_area__c = 1, Hidden_CC_Address__c = 'benchen70@gmail.com;internalservice@enett.com');

        insert c;
           
        Solution s = new Solution(SolutionName = 'Test Solution', SolutionNote = 'Thank you very much. We hope to use this Test Solution Details');
        
        insert s;
        
        CaseSolution cs = new CaseSolution(CaseId = c.id, SolutionId = s.id);
        
        insert cs;
        
        Decimal z = c.Hidden_Refresh_area__c;
        c.Hidden_Refresh_area__c = z + 1.0;
        c.Status = 'Pending';
        c.Hidden_CC_Address__c = 'benchen70@gmail.com; benchen70@outlook.com; internalservice@enett.com';
        update c;
        
        Decimal y = c.Hidden_Refresh_area__c;
        c.Hidden_Refresh_area__c = y + 1.0;
        c.Status = 'Open';
        c.Hidden_CC_Address__c = 'benchen70@gmail.com; benchen70@outlook.com; rod.crociani@hotmail.com; internalservice@enett.com';
        update c;
        
        
        Decimal x = c.Hidden_Refresh_area__c;
        c.Hidden_Refresh_area__c = x + 1.0;
        c.Hidden_CC_Address__c = 'benchen70@gmail.com; benchen70@outlook.com; rod.crociani@hotmail.com; canyoucatchme1@gmail.com; internalservice@enett.com; internalservice@enett.com';
        update c;
        

        
        }
        
}