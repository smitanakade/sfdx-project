/**
 * This class contains unit tests for validating the behavior of CalculateBusinessHours Apex class
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
 
@isTest
private class CalculateBusinessHoursTest {

    static testMethod void testCalculateBusinessHours() {
       CalculateBusinessHours calHours = new CalculateBusinessHours();
       
       CalculateBusinessHours.getBHId('APAC'); 
       
       CalculateBusinessHours.calculateElapsedBusinessHours(datetime.newInstance(2017, 12, 29, 12, 30, 0), datetime.newInstance(2018, 01, 29, 12, 30, 0));
       
       BusinessHours bh = [SELECT id, isDefault, Name FROM BusinessHours WHERE isActive = true Limit 1];
       
       CalculateBusinessHours.calculateElapsedBusinessHours(datetime.newInstance(2017, 12, 29, 12, 30, 0), datetime.newInstance(2018, 01, 29, 12, 30, 0), bh.id);
       
       CalculateBusinessHours.calculateElapsedBusinessHours('APAC', datetime.newInstance(2017, 12, 29, 12, 30, 0), datetime.newInstance(2018, 01, 29, 12, 30, 0));
       
       CalculateBusinessHours.calculateElapsedBusinessHours('APAC', datetime.newInstance(2017, 12, 29, 12, 30, 0), datetime.newInstance(2018, 01, 29, 12, 30, 0), 2);
       
       Registration__c testRegistration = eNettTestUtility.createRegistration('Test Registration');
       testRegistration.DD_Status__c = 'In Progress';
       CalculateBusinessHours.updateDDBusinessHours();
       
       testRegistration.DD_Status__c = 'Awaiting Client';
       update testRegistration;
       CalculateBusinessHours.updateDDBusinessHours();
       
       /*testRegistration.DD_Status__c = 'Awaiting Approval';
       update testRegistration;
       CalculateBusinessHours.updateDDBusinessHours();
       
       testRegistration.DD_Status__c = 'Referred';
       update testRegistration;
       CalculateBusinessHours.updateDDBusinessHours();*/
       
       testRegistration.DD_Status__c = 'Approval In Progress';
       update testRegistration;
       CalculateBusinessHours.updateDDBusinessHours();
       
       testRegistration.DD_Status__c = 'Needs More Time';
       update testRegistration;
       CalculateBusinessHours.updateDDBusinessHours();
       
       testRegistration.DD_Status__c = 'Non Responsive';
       update testRegistration;
       CalculateBusinessHours.updateDDBusinessHours();
       
       testRegistration.DD_Status__c = 'On Hold';
       update testRegistration;
       CalculateBusinessHours.updateDDBusinessHours();
       
       //Assert BH_OnHold__c field of Registration record is  NULL
       System.assertEquals(testRegistration.BH_OnHold__c,NULL);       
    }
}