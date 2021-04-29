/**
 * This class contains unit tests for validating the behavior of ClonePrimaryContact Apex class
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 *
 * author : Surajsingh Thakur
 * Date   : 02/01/2018 
 */
 
@isTest
private class ClonePrimaryContactTest {

    static testMethod void testClonePrimaryContact() {
        
       Account testSourceAccount = eNettTestUtility.createAccount('Source Account'); 
       
       Account testTargetAccount = new Account(Name = 'Target Account', Legal_Name__c = 'Target Account', Trading_As__c = 'Target Account', ECN__c = '000002', Client_Status__c = 'Prospect', IsApi__c = true);
       insert testTargetAccount;
       
       Contact testSourceContact = eNettTestUtility.createContact(testSourceAccount.id);
       testSourceContact.Job_Role__c = 'Primary';
       testSourceContact.Primary_Email_Address__c = 'primary@contact.com';
       update testSourceContact;
       
       
       ClonePrimaryContact.ActionRequest req = new ClonePrimaryContact.ActionRequest();
       req.sourceAccountId = testSourceAccount.id;
       req.targetAccountId = testTargetAccount.id;
       
       ClonePrimaryContact.CloneContact(new List<ClonePrimaryContact.ActionRequest>{req});
       
       System.assert(([Select id From Contact Where accountid = :testTargetAccount.id]).size()>0);
        
    }
}