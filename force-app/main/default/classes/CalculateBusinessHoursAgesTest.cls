@istest
public class CalculateBusinessHoursAgesTest {
    public static testMethod void testBusinessHoursBucketer() {

        Account account = new Account(Name = 'eNett Service Desk TEST 1', Legal_Name__c = 'eNett Service Desk TEST 1', Trading_As__c = 'eNett Service Desk TEST 1', ECN__c = '000001', Client_Status__c = 'Prospect', IsApi__c = true);
        insert account;
        Contact contact = new Contact(FirstName = 'Enetts', LastName = 'Contacts', Account = [select id from Account where Account.Name = 'eNett Service Desk TEST 1'], IsApi__c = true);
        insert contact;        
        
        Stop_Status__c ss = new Stop_Status__c(Name = 'Pending');
        insert ss;
        

        
        Case c = new Case();
        c.Contact = [select id from contact where FirstName = 'Enetts' and LastName = 'Contacts'];
        c.Status = 'Open';
        c.Last_Status_Change__c = System.Now();
        c.Hidden_Refresh_area__c = 1;
        c.Hidden_CC_Address__c = 'benchen70@gmail.com; internalservice@enett.com';
        c.Priority = 'Critical';
        insert c;
        
        Solution sol = new Solution(SolutionName = 'Thank you for your ticket', SolutionNote = 'Good bye');
        insert sol;

        c.Status = 'Pending';
        Decimal z = c.Hidden_Refresh_area__c;
        c.Hidden_Refresh_area__c = z + 1;
        c.Hidden_CC_Address__c = 'benchen70@gmail.com; benchen70@outlook.com; internalservice@enett.com';
        update c;
        
        CaseSolution cs = new CaseSolution(CaseId = c.id, SolutionId = sol.id);
        insert cs;

        c.Status = 'Open';
        Decimal y = c.Hidden_Refresh_area__c;
        c.Hidden_Refresh_area__c = y + 1;
        c.Hidden_CC_Address__c = 'benchen70@gmail.com; benchen70@outlook.com; rod.crociani@hotmail.com; internalservice@enett.com';
        update c;

        System.assertNotEquals(c.Time_With_Customer__c,0);
        System.assertNotEquals(c.Time_With_Support__c,0);
        System.assertEquals(c.Case_Age_In_Business_Hours__c,null);
        

        c.Status = 'Pending';
        Decimal x = c.Hidden_Refresh_area__c;
        c.Hidden_Refresh_area__c = x + 1;
        c.Hidden_CC_Address__c = 'benchen70@gmail.com; benchen70@outlook.com; rod.crociani@hotmail.com; canyoucatchme1@gmail.com; internalservice@enett.com';
        update c;

        System.assertNotEquals(c.Time_With_Customer__c,0);
        System.assertNotEquals(c.Time_With_Support__c,0);
       

    }
}