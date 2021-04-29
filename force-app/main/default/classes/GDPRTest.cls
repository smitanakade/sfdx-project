/**
 * Test class for GDPR webservices
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
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 *
 * author : Surajsingh Thakur
 * Date   : 14/01/2019
 */
@isTest
public class GDPRTest{
    
    //Postive test for the 'GDPRMaskECN' webservice
    @isTest static void testGDPRHttpPostPostive() {
        
        Account acc = new Account(Name = 'Test Account',
                                  ECN__c = '123456');
        insert acc;
        
        RestRequest req = new RestRequest(); // Creating test HttpRequest
        RestResponse res = new RestResponse(); // Creating test HttpResponse
        
        req.requestURI = '/services/apexrest/GDPRMaskECN/';  //Setting the endpoint for the HttpRequest
        req.httpMethod = 'POST'; //HTTP Request Type
        req.addParameter('ECN', '123456'); //Setting ECN paramter in the request
        
        RestContext.request = req;
        RestContext.response= res;
        res.addHeader('Content-Type','application/json'); //Setting content type for response
        
        Test.startTest();
            GDPR.doPost(); // Calling the GDPR 'GDPRMaskECN' endpoint
            
            //Asserting a record is created in GDPR_Data_Subject__c object for the incoming ECN
            List<GDPR_Masking__c> testRecords = [Select ECN__c from GDPR_Masking__c Where ECN__c = '123456'];
            System.assertEquals(1,testRecords.size());
        Test.StopTest();   
    }
    
    
    //Negative test for the 'GDPRMaskECN' webservice
    @isTest static void testGDPRHttpPostNegative() {
        
        RestRequest req = new RestRequest(); // Creating test HttpRequest
        RestResponse res = new RestResponse(); // Creating test HttpResponse
        
        req.requestURI = '/services/apexrest/GDPRMaskECN/';  //Setting the endpoint for the HttpRequest
        req.httpMethod = 'POST'; //HTTP Request Type
        req.addParameter('ECN', '123456789'); //Setting ECN which is greater than 6 digits in the request
        
        RestContext.request = req;
        RestContext.response= res;
        res.addHeader('Content-Type','application/json'); //Setting content type for response
        
        Test.startTest();
            GDPR.doPost(); // Calling the GDPR 'GDPRMaskECN' endpoint
            
            //Asserting a record is NOT created in GDPR_Data_Subject__c object for the incoming ECN
            List<GDPR_Masking__c> testRecords = [Select ECN__c from GDPR_Masking__c Where ECN__c = '123456'];
            System.assertEquals(0,testRecords.size());
        Test.StopTest();   
    }
}