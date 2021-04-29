@isTest
public class ContactTriggerHandlerTest {
    //SF-5316 3/11/2018 Jasmine - Since afterInsert method has been disabled in SF-5316, this test method
    //will be disabled to prevent itself from failing during deployment
    /*private static testMethod void updateContactInfoOnRelatedRecordsTestInsert(){
        Account testAcc = eNettTestUtility.createAccount('Test Account');
        Registration__c testReg = eNettTestUtility.createRegistration('Test Company', testAcc.Id);
        Contact testContact = eNettTestUtility.createContact(testAcc.Id); 
        testAcc = [SELECT Id, Primary_Contact_Email_Address__c, Primary_Contact_First_Name__c,
                   Primary_Contact_Last_Name__c, Primary_Contact_Id__c, Primary_Contact_Phone__c,
                   Primary_Contact_Title__c, Secondary_Contact_First_Name__c, Secondary_Contact_Last_Name__c,
                   Secondary_Contact_Email__c, Financial_Contact_First_Name__c, Financial_Contact_Last_Name__c,
                   Financial_Contact_Email__c
                   FROM Account WHERE Id=: testAcc.Id];
        testReg = [SELECT Id, Account__c, First_Name__c, Last_Name__c, Job_Role__c, Email__c, Phone__c, Salutation__c
                   FROM Registration__c WHERE Account__c=: testAcc.Id];
        //check contact info on account
        System.assertEquals(testContact.Primary_Email_Address__c, testAcc.Primary_Contact_Email_Address__c);
        System.assertEquals(testContact.FirstName, testAcc.Primary_Contact_First_Name__c);
        System.assertEquals(testContact.LastName, testAcc.Primary_Contact_Last_Name__c);
        System.assertEquals(testContact.Id, testAcc.Primary_Contact_Id__c);
        System.assertEquals(testContact.Phone, testAcc.Primary_Contact_Phone__c);
        System.assertEquals(testContact.Salutation, testAcc.Primary_Contact_Title__c);
        System.assertEquals(testContact.FirstName, testAcc.Secondary_Contact_First_Name__c);
        System.assertEquals(testContact.LastName, testAcc.Secondary_Contact_Last_Name__c);
        System.assertEquals(testContact.Secondary_Email_Address__c, testAcc.Secondary_Contact_Email__c);
        System.assertEquals(testContact.FirstName, testAcc.Financial_Contact_First_Name__c);
        System.assertEquals(testContact.LastName, testAcc.Financial_Contact_Last_Name__c);
        System.assertEquals(testContact.Financial_Email_Address__c, testAcc.Financial_Contact_Email__c);
        //check contact info on rego
        System.assertEquals(testContact.FirstName, testReg.First_Name__c);
        System.assertEquals(testContact.LastName, testReg.Last_Name__c);
        System.assertEquals(testContact.Title__c, testReg.Job_Role__c);
        System.assertEquals(testContact.Primary_Email_Address__c, testReg.Email__c);
        System.assertEquals(testContact.Phone, testReg.Phone__c);
        System.assertEquals(testContact.Salutation, testReg.Salutation__c);  
    }*/
    private static testMethod void updateContactInfoOnRelatedRecordsTestUpdate(){
        Account testAcc = eNettTestUtility.createAccount('Test Account');
        Registration__c testReg = eNettTestUtility.createRegistration('Test Company', testAcc.Id);
        Contact testContact = eNettTestUtility.createContact(testAcc.Id); 
        testContact.FirstName = 'Updated FirstName';
        testContact.LastName = 'Updated LastName';
        testContact.Primary_Email_Address__c = 'updatedprimary@email.com';
        testContact.Secondary_Email_Address__c = 'updatedsecondary@email.com';
        testContact.Financial_Email_Address__c = 'updatedfinancial@email.com';
        testContact.Salutation = 'Mr';
        testContact.Title__c = 'boss';
        update testContact;
        testAcc = [SELECT Id, Primary_Contact_Email_Address__c, Primary_Contact_First_Name__c,
                   Primary_Contact_Last_Name__c, Primary_Contact_Id__c, Primary_Contact_Phone__c,
                   Primary_Contact_Title__c, Secondary_Contact_First_Name__c, Secondary_Contact_Last_Name__c,
                   Secondary_Contact_Email__c, Financial_Contact_First_Name__c, Financial_Contact_Last_Name__c,
                   Financial_Contact_Email__c
                   FROM Account WHERE Id=: testAcc.Id];
        testReg = [SELECT Id, Account__c, First_Name__c, Last_Name__c, Job_Title__c, Email__c, Phone__c, Salutation__c
                   FROM Registration__c WHERE Account__c=: testAcc.Id];
        //check contact info on account
        System.assertEquals(testContact.Primary_Email_Address__c, testAcc.Primary_Contact_Email_Address__c);
        System.assertEquals(testContact.FirstName, testAcc.Primary_Contact_First_Name__c);
        System.assertEquals(testContact.LastName, testAcc.Primary_Contact_Last_Name__c);
        System.assertEquals(testContact.Id, testAcc.Primary_Contact_Id__c);
        System.assertEquals(testContact.Phone, testAcc.Primary_Contact_Phone__c);
        System.assertEquals(testContact.Salutation, testAcc.Primary_Contact_Title__c);
        System.assertEquals(testContact.FirstName, testAcc.Secondary_Contact_First_Name__c);
        System.assertEquals(testContact.LastName, testAcc.Secondary_Contact_Last_Name__c);
        System.assertEquals(testContact.Secondary_Email_Address__c, testAcc.Secondary_Contact_Email__c);
        System.assertEquals(testContact.FirstName, testAcc.Financial_Contact_First_Name__c);
        System.assertEquals(testContact.LastName, testAcc.Financial_Contact_Last_Name__c);
        System.assertEquals(testContact.Financial_Email_Address__c, testAcc.Financial_Contact_Email__c);
        //check contact info on rego
        System.assertEquals(testContact.FirstName, testReg.First_Name__c);
        System.assertEquals(testContact.LastName, testReg.Last_Name__c);
        System.assertEquals(testContact.Title__c, testReg.Job_Title__c);
        System.assertEquals(testContact.Primary_Email_Address__c, testReg.Email__c);
        System.assertEquals(testContact.Phone, testReg.Phone__c);
        System.assertEquals(testContact.Salutation, testReg.Salutation__c);
    }
    
    private static testMethod void updateContactInfoOnRelatedRecordsTestDelete(){
        Account testAcc = eNettTestUtility.createAccount('Test Account');
        Contact testContact = eNettTestUtility.createContact(testAcc.Id); 
        //bypassing the inability to delete primary contact
        eNettTestUtility.createContact(testAcc.Id); 
        testContact.Job_Role__c = 'Secondary; Financial';
        update testContact;
        delete testContact;
        testAcc = [SELECT Id, Secondary_Contact_First_Name__c, Secondary_Contact_Last_Name__c,
                   Secondary_Contact_Email__c, Financial_Contact_First_Name__c, Financial_Contact_Last_Name__c,
                   Financial_Contact_Email__c
                   FROM Account WHERE Id=: testAcc.Id];
        //check contact info on account -- primary info can't be deleted so not verifying rego
        System.assertEquals(NULL, testAcc.Secondary_Contact_First_Name__c);
        System.assertEquals(NULL, testAcc.Secondary_Contact_Last_Name__c);
        System.assertEquals(NULL, testAcc.Secondary_Contact_Email__c);
        System.assertEquals(NULL, testAcc.Financial_Contact_First_Name__c);
        System.assertEquals(NULL, testAcc.Financial_Contact_Last_Name__c);
        System.assertEquals(NULL, testAcc.Financial_Contact_Email__c);
        
        //test undelete
        undelete testContact;
        testAcc = [SELECT Id, Secondary_Contact_First_Name__c, Secondary_Contact_Last_Name__c,
                   Secondary_Contact_Email__c, Financial_Contact_First_Name__c, Financial_Contact_Last_Name__c,
                   Financial_Contact_Email__c
                   FROM Account WHERE Id=: testAcc.Id];
        //check contact info on account -- primary info can't be deleted so not verifying rego
        System.assertEquals(testContact.FirstName, testAcc.Secondary_Contact_First_Name__c);
        System.assertEquals(testContact.LastName, testAcc.Secondary_Contact_Last_Name__c);
        System.assertEquals(testContact.Secondary_Email_Address__c, testAcc.Secondary_Contact_Email__c);
        System.assertEquals(testContact.FirstName, testAcc.Financial_Contact_First_Name__c);
        System.assertEquals(testContact.LastName, testAcc.Financial_Contact_Last_Name__c);
        System.assertEquals(testContact.Financial_Email_Address__c, testAcc.Financial_Contact_Email__c);
    }
}