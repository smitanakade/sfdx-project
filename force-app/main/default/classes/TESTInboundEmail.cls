@isTest
private class TESTInboundEmail {

    static testMethod void TESTInsertTrigger() {
        Test.startTest();
        //Must Pass basic null checks
        
        System.Debug('**** Starting TestInsertTrigger ****');
        Inbound_email__c firstNullInsert = new Inbound_email__c();
        insert firstNullInsert;
        system.assertNotEquals( null, firstNullInsert.Id);

        Inbound_Email__c newEmail = new Inbound_Email__c( Subject__c = 'NoSubjectThreadId', From__c = 'inoundemail@test.com', Headers__c = 'TEST\nOF\nHEADERS', Received_Date__c = DateTime.Now());
        insert newEmail;
        system.assertNotEquals( null, newEmail.Id);
        
        newEmail = [select case__c from Inbound_Email__c where Id = :newEmail.Id];
        system.AssertEquals( null, newEmail.case__c);
        
        Case newCase = new Case(Priority = 'Not None');
        insert newCase;
        Case testCase = [select Id, Ticket_Thread_ID__c from Case where Id = :newCase.Id];
        System.Debug('**** Finding case:' + testCase);
        Inbound_Email__c newValidInsert = new Inbound_Email__c( Subject__c = 'The test of a new reference ' + testCase.Ticket_Thread_ID__c, From__c = 'inoundemail@test.com', Headers__c = 'TEST\nOF\nHEADERS', Received_Date__c = DateTime.Now());
        insert newValidInsert;
        
        newValidInsert = [select Id, case__c from Inbound_Email__c where Id = :newValidInsert.Id];
        system.assertEquals(testCase.Id, newValidInsert.case__c);
        
        Test.stopTest();
    }
    
    
    static testMethod void TESTEmailUtilities(){
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
        Messaging.InboundEmailResult result = EmailUtilities.processInboundEmail( email );
        System.assert(result.success == true);
        Test.stopTest();
    } 
 
    static testMethod void testValidMethod() {
        Test.startTest();
  
        // create a new email 
        Case newCase = new Case(Priority = 'Not None');
        insert newCase;
        Case testCase = [select Id, Ticket_Thread_ID__c from Case where Id = :newCase.Id];
        System.Debug('**** Finding case:' + testCase);

        // create a new email 
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        email.subject = 'Subject asdas asdasd ' + testCase.Ticket_Thread_ID__c;
        email.plainTextBody = 'Test email';
        email.htmlBody = '<b>Plain Text</b>';
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
        Messaging.InboundEmailResult result = EmailUtilities.processInboundEmail( email );
        System.assert(result.success == true);
        Test.stopTest();
    }   
    
    static testMethod void TEST_BUSINESS_PROCESS() {
        Test.startTest();
  
        // create a new email 
        Case newCase = new Case( Priority = 'Not None');
        insert newCase;
        Case testCase = [select Id, Ticket_Thread_ID__c from Case where Id = :newCase.Id];
        System.Debug('**** Finding case:' + testCase);

        // create a new email 
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        email.subject = 'Subject asdas asdasd ' + testCase.Ticket_Thread_ID__c;
        email.plainTextBody = 'Test email';
        email.htmlBody = '<b>Plain Text</b>';
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
        Messaging.InboundEmailResult result = EmailUtilities.processInboundEmail( email );
        System.assert(result.success == true);
        
        Inbound_Email__c newValidInsert = [select Id, case__c from Inbound_Email__c order by Received_Date__c desc limit 1];
        newValidInsert.case__c = testCase.id;
        update newValidInsert;
        
        Test.stopTest();
    } 
    
    static testMethod void TEST_ASSIGN_INBOUNDEMAIL_TO_CASE() {
        Test.startTest();
  
        // create a new Inbound email record with a Case Ref ID
        //1) Get the ID from Case
        Case newCase = new Case( Priority = 'Not None');
        insert newCase;
        Case testCase = [select Id, Ticket_Thread_ID__c from Case where Id = :newCase.Id];
        System.Debug('**** Finding case:' + testCase);
        System.Debug('**** Finding case Thread_ID:' + testCase.Ticket_Thread_ID__c);
        // create a new Inbound email
        String emailFromName = 'Someone';
        String emailFromAddress ='someaddress@email.com';
        String htmlBody= '<b>Plain Text</b>';
        String eamilToAddress= 'one@email.com';
        String Subject='Subject asdas asdasd ' + testCase.Ticket_Thread_ID__c;
         
        Inbound_Email__c inBoundEmail = eNettTestUtility.createInboundEmail(emailFromName, emailFromAddress, htmlBody, eamilToAddress,Subject);         
          
        Inbound_Email__c newValidInsert = [select Id, Case__c from Inbound_Email__c Where ID = :inBoundEmail.ID ];
        System.Debug('**** From Select ID:' + newValidInsert.Id);
        System.Debug('**** From Select case:' + newValidInsert.case__c);
        System.Debug('**** From Actual case:' + testCase.ID);
        System.assertEquals(newValidInsert.case__c, testCase.ID);
        
        Test.stopTest();
    } 
}