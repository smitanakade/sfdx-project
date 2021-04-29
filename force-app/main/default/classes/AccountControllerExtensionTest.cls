/**
 * This class contains unit tests for validating the AccountControllerExtension Apex class
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
 * Date   : 27/12/2017 
 */
@isTest
private class AccountControllerExtensionTest {

    static testMethod void testAccountController() {
        
        User testUser = eNettTestUtility.createUser('eNett Sales & Support');
        
        System.runAs(testUser) {
        
        Account testAccount = eNettTestUtility.createAccount('Test Account');
        testAccount.Do_Not_Contact__c = true;
        update testAccount;
       
       
        ApexPages.StandardController sc = new ApexPages.StandardController(testAccount);
        AccountControllerExtension testAccountControllerExtension = new AccountControllerExtension(sc);
        
        //Assert Page meesage of 'Please DO NOT CONTACT this client' has been thrown
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages.size());
        System.assertEquals('Please DO NOT CONTACT this client. Email aml@enett.com for further information.', pageMessages[0].getDetail());
        
        //Assert hasMessages method returns true
        System.assert(testAccountControllerExtension.hasMessages() == true);
        
        //Assert isSalesProfile method is returns true
        System.assert(testAccountControllerExtension.isSalesProfile() == true);
        
        }
       
    }
}