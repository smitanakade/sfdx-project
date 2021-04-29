@isTest
private class TESTemailCCfield {
    static testMethod void runTest() {
        
        /*Account account = new Account (Name  = 'ABC', Legal_Name__c = 'ABC', Client_Status__c = 'Approved', Region__c = 'APAC', Country_name__c = 'Australia', eNett_Products__c = 'VANs', Client_internal_classification__c = '1.0'); 
        insert account;
        Contact person = new contact(FirstName = 'Benjamin', LastName = 'Chen', Account = 'ABC', Email = 'canyoucatchme1@gmail.com');
        insert person;*/
        
        //Case c=new Case(Status = 'New', Origin = 'Email', Type = 'Problem', ContactId = '00390000011Hnvn', AccountId = '0019000000z2hZT' , BusinessHoursid = '01m90000000Cl8e', Product__c = 'VANs', Category__c = 'VANs', Description__c = 'Query', Subject = 'New problem to solve for helpdesk', Priority = 'Normal');
        
        Account account = new Account(Name = 'Account Test 3', Legal_Name__c = 'Account Test3', Client_Status__c = 'Prospect', IsApi__c = true);
        insert account;
        Contact cont = new Contact(FirstName = 'Benjamin', LastName = 'Chen', Account = [select id from Account where Account.Name = 'Account Test 3'], IsApi__c = true);
        insert cont;

        Stop_Status__c stopstatus = new Stop_Status__c(Name = 'Pending');
        insert stopstatus;  
        
        Case c=new Case(Contact = [select id from contact Order by createddate Desc LIMIT 1], Status = 'New', Origin = 'Email',  Subject = 'New problem to solve for helpdesk', Priority = 'Critical', Product__c = 'VANs', Category__c = 'Sales', Description__c = 'Campaign', Hidden_CC_Address__c = 'service@enett.com', Hidden_Refresh_area__c = 1, RecordTypeId = '01290000000hwKc');
        
        insert c;
        
        Solution sol = new Solution(SolutionName = 'Thank you for your ticket', SolutionNote = 'Good bye');
        insert sol;
        

        c.Hidden_CC_Address__c = 'service@enett.com; benchen70@outlook.com';
        Decimal y = c.Hidden_Refresh_area__c;
        c.Hidden_Refresh_area__c = y + 1;
        c.Status = 'Pending';
        upsert c;
        
        CaseSolution cs = new CaseSolution(CaseId = c.id, SolutionId = sol.id);
        insert cs;
        
        c.Hidden_CC_Address__c = 'benchen70@gmail.com; benchen70@outlook.com; service@enett.com';
        Decimal x = c.Hidden_Refresh_area__c;
        c.Hidden_Refresh_area__c = x + 1;
        c.Status = 'Open';
        c.KPI_Timer_Minutes__c = null;

        upsert c;
        
        Task newtask = new task(Type = 'Email', WhatId = c.Id, Status = 'Completed', Subject = 'ABC');
        insert newtask;
        
        c.Hidden_CC_Address__c = 'benchen70@gmail.com; benchen70@outlook.com; rod.crociani@hotmail.com; service@enett.com';
        Decimal v = c.Hidden_Refresh_area__c;
        c.Hidden_Refresh_area__c = v + 1;
        c.Status = 'Pending';
        upsert c;
        
        c.Hidden_CC_Address__c = 'benchen70@gmail.com; benchen70@outlook.com; rod.crociani@hotmail.com; service@enett.com; internalservice@enett.com';
        Decimal w = c.Hidden_Refresh_area__c;
        c.Hidden_Refresh_area__c = w + 1;
        c.Status = 'Open';
        upsert c;
        
        c.Hidden_CC_Address__c = 'benchen70@gmail.com; benchen70@outlook.com; rod.crociani@hotmail.com; canyoucatchme1@gmail.com; service@enett.com; b@gmail.com';
        Decimal u = c.Hidden_Refresh_area__c;
        c.Hidden_Refresh_area__c = u + 1;
        c.Status = 'Pending';
        upsert c;
        
        c.Hidden_CC_Address__c = 'benchen70@gmail.com; benchen70@outlook.com; rod.crociani@hotmail.com; canyoucatchme1@gmail.com; a@gmail.com; service@enett.com; c@gmail.com';
        Decimal t = c.Hidden_Refresh_area__c;
        c.Hidden_Refresh_area__c = t + 1;
        c.Status = 'Open';
        upsert c;
        
        c.Hidden_CC_Address__c = 'benchen70@gmail.com; benchen70@outlook.com; rod.crociani@hotmail.com; canyoucatchme1@gmail.com; a@gmail.com; internalservice@enett.com; service@enett.com; d@gmail.com';
        Decimal s = c.Hidden_Refresh_area__c;
        c.Hidden_Refresh_area__c = s + 1;
        c.Status = 'Pending';
        upsert c;
        
        c.Hidden_CC_Address__c = 'benchen70@gmail.com; benchen70@outlook.com; rod.crociani@hotmail.com; canyoucatchme1@gmail.com; a@gmail.com; b@gmail.com; c@gmail.com; service@enett.com; e@gmail.com';
        Decimal r = c.Hidden_Refresh_area__c;
        c.Hidden_Refresh_area__c = r + 1;
        c.Status = 'Open';
        upsert c;
        
        c.Hidden_CC_Address__c = 'benchen70@gmail.com; benchen70@outlook.com; rod.crociani@hotmail.com; canyoucatchme1@gmail.com; a@gmail.com; b@gmail.com; c@gmail.com; d@gmail.com; service@enett.com; f@gmail.com';
        Decimal q = c.Hidden_Refresh_area__c;
        c.Hidden_Refresh_area__c = q + 1;
        c.Final_Solution__c = 'Thank you';
        c.Status = 'Pending';
       
        upsert c;

        
        
       
        }
}