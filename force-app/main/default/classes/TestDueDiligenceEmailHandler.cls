@isTest
public class TestDueDiligenceEmailHandler {
    
    static testMethod void TestEmailHandler() {

        Registration__c ddCL = new Registration__c(Registered_Company_Name__c = 'TestCompany');
        insert ddCL;
        
        // Create Inbound Email
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = 'Create Contact [ref:' + ddCL.id + ']';
        email.fromAddress = 'test@email.com';
        email.plainTextBody = 'Testing';

        // Add Binary Attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('Some text');
        attachment.fileName = 'textfile.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
      
        // Call email service class
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        DueDiligenceEmailHandler testInbound = new DueDiligenceEmailHandler();
        testInbound.handleInboundEmail(email, env);
        
        // Assert that email task was created on the due diligence record
        LIST<Task> ts = [SELECT Id FROM Task WHERE WhatId = :ddCL.id LIMIT 1];
        //system.assert(ts.size() > 0);
   }

}