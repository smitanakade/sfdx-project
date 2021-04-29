@isTest
public class TestUpdateOnBehalfofAccount{
    
   
        
    static testMethod void testUpdate(){
    
        TestCreateData testData = new TestCreateData();
        
        Account acc = testData.createAccount();
        System.debug('The account id is ' + acc.Id);
        
        Contact contact = testData.createContact(acc.Id);
        System.debug('The contact id is ' + contact.Id);
        
        Case servicetkt = testData.createServiceTicket(contact.Id);
        servicetkt.RecordTypeId = '01290000000hwKc';
        servicetkt.On_Behalf_of_Contact__c = contact.Id;
        
        update servicetkt;
        
        System.debug('The On behalf of account is ' + servicetkt.On_Behalf_of_Account__c);
        System.debug('The case id is ' + servicetkt.Id);
    }
    
    
}