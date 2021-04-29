/**
 * This class contains unit tests for validating the behavior of AutoCreateDelivery Apex class
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
 * Date   : 29/12/2017 
 */
 
@isTest (SeeAllData = true)
private class AutoCreateDeliveryTest {

    static testMethod void testAutoCreateDelivery() {
        
        Account testAccount = eNettTestUtility.createAccount('Test Account');
        
        Opportunity testOpportunity = eNettTestUtility.createOpportunity('Test Opportunity', testAccount.id);
        testOpportunity.Delivery_type__c = 'Delivery - API';
        update testOpportunity;
        
        AutoCreateDelivery.AutoCreateDeliveryTicket(new List<ID>{testAccount.id});
        
        //Assert new case record is created
        System.assert(([Select Related_Delivery_Opportunity__c From Case Where Related_Delivery_Opportunity__c = : testOpportunity.id]).size()>0);
        
    }
}