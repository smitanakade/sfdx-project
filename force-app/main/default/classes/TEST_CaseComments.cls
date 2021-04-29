@istest
public with sharing class TEST_CaseComments {
    public static testMethod void testCaseCommentsDelete() {

		Profile p = [SELECT Id FROM Profile WHERE Name='Stefanini Service Desk User']; 
		User u = new User(Alias = 'CC', Email='casecomment@enett.com', EmailEncodingKey='UTF-8', LastName='Comment', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='casecomment@enett.com'); 

		System.runAs(u) {

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


	        casecomment ccom = new casecomment ();
	        ccom.commentBody = 'This is a Case Comment.';
	        ccom.parentid = c.id;
	        insert ccom;
	        

	        try {
	        	ccom.CommentBody = 'Changed the Description 1';
	        	update ccom;
	        }
	        catch (Exception e) {
	            Boolean exceptionThrown = e.getMessage().contains('Editing Ticket Comments is not permitted.')? true : false;
	            System.assertEquals(exceptionThrown, true);
	        }
	 

	        try {
	        	delete ccom;
	        }
	        catch (Exception e) {            
	            Boolean exceptionThrown = e.getMessage().contains('Deletion of Ticket Comments is not permitted.')? true : false;
	            System.assertEquals(exceptionThrown, true);
	        }   

		}
    }

}