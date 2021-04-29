@isTest
public class UpdateContactJobRoleTest {
    
    Testmethod static void testUpdateContactJobRoleFromReg(){
        
        // Data setup: create a new registration
        Account acc = eNettTestUtility.createAccount('testAccount');
        Registration__c reg = eNettTestUtility.createRegistration('compName');
        reg.Salutation__c = 'Mr';
        reg.First_Name__c = 'Firstname';
        reg.Last_Name__c = 'Lastname';
        reg.Email__c = 'email@gmail.com';
        reg.Phone__c = '0000';
        reg.Account__c = acc.Id;
        reg.Agreement_Type__c = 'Affiliate';
        reg.Job_Role__c = 'Primary; Secondary; Financial';
        update reg;
        
        // Perform test
        Test.startTest();
        UpdateContactJobRole.UpdateContactJobRoleFromReg(new List<ID>{reg.Id});
        Test.stopTest();
        
        // Verify
        List<Contact> contacts = [SELECT Salutation, FirstName, LastName, Email, Primary_Email_Address__c, Secondary_Email_Address__c, Financial_Email_Address__c,
                                  Phone, Job_Role__c, AccountId, Title__c FROM Contact WHERE AccountId =: reg.Id];
        If (contacts.size() > 0) {
            System.assertEquals('Mr', contacts[0].Salutation);
            System.assertEquals('Firstname', contacts[0].FirstName);
            System.assertEquals('Lastname', contacts[0].LastName);
            System.assertEquals('email@gmail.com', contacts[0].Email);
            System.assertEquals('0000', contacts[0].Phone);
            System.assertEquals('Primary; Secondary; Financial', contacts[0].Job_Role__c);
            System.assertEquals('Primary; Secondary; Financial', contacts[0].Title);
        }
    }
}