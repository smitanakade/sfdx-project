/**
 * This class contains unit tests for validating the AccountReassign Apex class
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
@isTest (SeeAllData = true)
private class AccountReassignTest {

    static testMethod void testAssignSalesmanager() {
        
    Account testAccount = eNettTestUtility.createAccount('Test Account');
        testAccount.Do_Not_Contact__c = true;
        testAccount.CountryCode2__c = 'AU';
        update testAccount;
            
        AccountReassign.InputParameters inputParam = new AccountReassign.InputParameters();
        inputParam.accId = testAccount.id;
        inputParam.registrationType = 'External Registration';
        
        AccountReassign.AssignSalesmanager(new List<AccountReassign.InputParameters>{inputParam});
        
        testAccount = [select OwnerId from Account where Id = :testAccount.id];
        
        //Assert the reassigned owner is the one configured in generic_lookups__c.getInstance('APAC_AU_NZ_Sales')
        System.assertEquals(testAccount.OwnerId, generic_lookups__c.getInstance('APAC_AU_NZ_Sales').value__c);
    }
}