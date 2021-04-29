/**
 * This class contains unit tests for validating the behavior of AddProduct Apex class
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
@isTest
private class AddProductTest {

    static testMethod void myUnitTest() {
        
        Account testAccount = eNettTestUtility.createAccount('Test Account');
        testAccount.enett_Products__c = 'VANs;req.productNames';
        update testAccount;
        
        AddProduct.AddProductActionRequest req = new AddProduct.AddProductActionRequest();
        req.accountId = testAccount.id;
        req.productNames = 'VANs;req.productNames';
        
        LIST<AddProduct.AddProductActionRequest> reqList = new LIST<AddProduct.AddProductActionRequest>();
        reqList.add(req);
        
        AddProduct.AddProductToAccount(reqList);
        
        testAccount = [Select enett_Products__c From Account Where id =:testAccount.id];
        
        //Assert testAccount enett_Products__c contains VANs
        System.assert(testAccount.enett_Products__c.contains('VANs'));
        
    }
}