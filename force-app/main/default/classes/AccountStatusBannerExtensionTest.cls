/**
 * This class contains unit tests for validating the behavior of AccountStatusBannerExtension Apex class
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
 * Date   : 28/12/2017 
 */
@isTest (SeeAllData = true)
private class AccountStatusBannerExtensionTest {

    static testMethod void testAccountStatusBannerExtension() {
        Account testAccount = eNettTestUtility.createAccount('Test Account');
        testAccount.DD_Status__c = 'DD Approved';
        testAccount.Account_Type__c = 'Affiliate';
        testAccount.Account_Status__c = 'Deactivated';
        //testAccount.Reference_Registration__c = 'DD Approved';
        testAccount.Registration_Status__c = 'Complete';
        testAccount.product_contracts_active__c = true;
        testAccount.CMPA_received__c = true;
        update testAccount;
        
        eNettTestUtility.createOpportunity('TestOpp',testAccount.id); 
        
        Apexpages.currentPage().getParameters().put('id',testAccount.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(testAccount);
        AccountStatusBannerExtension testAccountControllerExtension = new AccountStatusBannerExtension(sc);
        
        //Assert RenderRegColumn = false
        System.assertEquals(testAccountControllerExtension.RenderRegColumn,false);
    }
}