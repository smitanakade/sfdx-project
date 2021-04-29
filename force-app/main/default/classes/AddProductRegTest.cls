/**
 * This class contains unit tests for validating the behavior of AddProductReg Apex class
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
private class AddProductRegTest {

    static testMethod void testAddProductReg() {
       
       Registration__c testRegistration = eNettTestUtility.createRegistration('ACME Travel');
        
       AddProductReg.AddProductActionRequest req = new AddProductReg.AddProductActionRequest();
       req.regId = testRegistration.id;
       req.productName = 'VANs;eNett EFT';
       
       AddProductReg.AddProductToReg(new LIST<AddProductReg.AddProductActionRequest>{req});
       
       testRegistration = [Select Product__c from Registration__c Where id = : testRegistration.id ];
      
       //Assert testRegistration Product has VANs
       System.assert((testRegistration.Product__c).contains('VANs'));
       
       
        
    }
}