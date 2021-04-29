@isTest
public class TestCreateData{
    
   
    Case serviceTicket;
    Case delTicket;
    Account acc;
    Contact contact;
    
    
    public Account createAccount(){
    
        acc = new Account(Name = 'Account Test', Legal_Name__c = 'Account Test', 
        Client_Status__c = 'Prospect', IntegratorModifiedDate__c = system.now(), IsApi__c = true, Due_Diligence_Completed__c = System.today()-56);
        insert acc;
        
        System.debug('The account in test data is ' + acc.Id);
        
        return acc;
    }
    
    //Creates Contact but requires the account Id to be passed.
    public Contact createContact(String accId ){
    
        contact = new Contact(FirstName = 'Firsttest', LastName = 'Lastest', AccountId = accId , IsApi__c = true);
        insert contact ; 
        System.debug('The contact in test data is ' + contact.Id);
        return contact;
    }
    
    //Creates case based on the Contact Id. The owner of the case is New Ticket Queue 
    public Case createServiceTicket(String contactId ){
    
        String queueId = [select Id from Group where Name = 'New Ticket Queue' and Type = 'Queue'].Id;
        serviceTicket = new Case (Subject = 'Test Subject', Origin = 'Email', Type = 'Task', RecordTypeId = '01290000000hwKc', Status = 'New', ContactId = contactId, OwnerId = queueId);
        insert serviceTicket;
        
        System.debug('The ticket id in test data is ' + serviceTicket.Id);

        return serviceTicket;
    }
    
    //Creates phone case based on the Contact Id. The owner of the case is New Ticket Queue 
    public Case createPhoneServiceTicket(String contactId ){
    
        String queueId = [select Id from Group where Name = 'New Ticket Queue' and Type = 'Queue'].Id;
        Case phoneServiceTicket = new Case (Subject = 'Test Subject', Origin = 'Phone', RecordTypeId = '01290000000hwKc', Type = 'Task', Status = 'Open', ContactId = contactId, OwnerId = queueId);
        insert phoneServiceTicket ;
        
        System.debug('The ticket id in test data is ' + phoneServiceTicket.Id);

        return phoneServiceTicket;
    }
    
    //Creates a Stefinini User
    public String createStefaniniUser(){
    
        String stefId = [select Id from User where UserRoleId = :[select id from UserRole where name='Global Service Desk Level 1'].Id LIMIT 1].Id;
        return stefId;
    }
    
    // This is used to close the service ticket
    public Case closeServiceTicket(Case testCase){
    
        testCase.Final_Solution__c = 'Updated the final solution';
        testCase.Product__c = 'VANs';
        testCase.Status = 'Closed';
        update testCase;
        return testCase;
    }
    
    // This is used to create a solution 
    public Solution createSolution(){
    
        Solution solBank = new Solution ( Status = 'Final', SolutionName = 'This is a test solution');
        insert solBank;
        return solBank;
    }
    
    public Case reopenCase(Case testCase){
    
        testCase.Status = 'Closed';
        update testCase;
        return testCase;
    }
    
    static testMethod void testUpdate(){   
    
    }
    
    
}