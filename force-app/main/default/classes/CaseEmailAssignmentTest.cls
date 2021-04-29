/**
 * This class contains unit tests for validating the behavior of CaseEmailAssignment Apex class
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
 * author : Surajsingh Thakur
 * Date   : 02/01/2018 
 */
@isTest
private class CaseEmailAssignmentTest {

    static testMethod void testCaseEmailAssignment() {
        Test.startTest();
  
        // create a new email 
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        email.subject = 'Subject asdas asdasd ';
        email.plainTextBody = 'Test email';
        email.fromname = 'FirstName LastName';
        email.toAddresses = new String[] {'someaddress@email.com'};
        email.ccAddresses = new String[] {'one@email.com','two@email.com'};

        String csv = 'this is just a test';
  
        // add an attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf(csv);
        attachment.fileName = 'data.csv';
        attachment.mimeTypeSubType = 'text/plain';
  
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
  
        Messaging.InboundEmail.TextAttachment tattachment = new Messaging.InboundEmail.TextAttachment();
        tattachment.body = csv;
        tattachment.fileName = 'data.csv';
        tattachment.mimeTypeSubType = 'text/plain';
  
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { tattachment };
  
        // call the email service class and test it with the data in the testMethod
        //Messaging.InboundEmailResult result = EmailUtilities.processInboundEmail( email );
        CaseEmailAssignment caseEmail = new CaseEmailAssignment();
        Messaging.InboundEmailResult result = caseEmail.handleInboundEmail(email, NULL);
        System.assert(result.success == true);
        Test.stopTest();
        
    }
}