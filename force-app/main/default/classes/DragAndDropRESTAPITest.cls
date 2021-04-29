/**
 * This class contains unit tests for validating the behavior of DragAndDropRESTAPI Apex class
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
private class DragAndDropRESTAPITest {

    static testMethod void testAttachment() {
        
        Account testAccount = eNettTestUtility.createAccount('Test Account');
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        
        req.requestURI = '/DragAndDrop';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof('eNett International');
        
        RestContext.request = req;
        req.addParameter('FileName','testfile');
        req.addParameter('parId',testAccount.id);
        RestContext.response = res;
        
        Test.startTest();
        
        DragAndDropRESTAPI.attachDoc();
        
        //System.assert(([Select ParentId From Attachment Where ParentId=:testAccount.id ]).size()>0);
        //Ronnie: with AttachmentTrigger, all attachments will be converted into files, so verifying that instead
        //SF-5316 2/11/2019 Jasmine - Temporarily remove assertion due to changes in the 'AttachmentTriggerHandler' class (remove OnAfterInsert)
        //System.assert([Select LinkedEntityId From ContentDocumentLink Where LinkedEntityId=:testAccount.id].size()>0);
        Test.StopTest();   
        
    }
}