/*
 * This is a test class for AttachmentTriggerHandler
 * Ticket: SF-5145
 * Author: Ronnie Yang
 */
@isTest
public class AttachmentTriggerHandlerTest {
    private static testMethod void convertAttachmentToFileTest(){
        //create new case
        Case testCase = eNettTestUtility.createCase();
        //create new attachment under that case
        Attachment testAttachment = eNettTestUtility.createAttachment(testCase.Id);
        //assert attachment is deleted
        System.assertEquals(0, [SELECT Id 
                                FROM Attachment 
                                WHERE Id=: testAttachment.Id 
                                LIMIT 1].size());
        //assert there's contentversion inserted -- representing the version of the new file inserted
        ContentVersion newContentVersion = [SELECT Id, Title, VersionData, FirstPublishLocationId, ContentDocumentId
                                            FROM ContentVersion
                                            WHERE Original_Record_Id__c =: testAttachment.Id
                                            LIMIT 1];
        System.assertEquals(testAttachment.Name, newContentVersion.Title);
        System.assertEquals(testAttachment.Body.toString(), newContentVersion.VersionData.toString());
        System.assertEquals(testAttachment.ParentId, newContentVersion.FirstPublishLocationId);
        //assert there's contentdocument -- a document(file) can have many versions but each version can only be linked to one document
        ContentDocument newContentDocument = [SELECT Id, Title 
                                              FROM ContentDocument 
                                              WHERE Id =: newContentVersion.ContentDocumentId
                                              LIMIT 1];
        System.assertEquals(testAttachment.Name, newContentDocument.Title);
        //assert there's linkentity -- a document(file) can be linked to many records and a record can have many documents -- this is the junction object in the many-to-many relationship
        ContentDocumentLink newLinkEntity = [SELECT Id, LinkedEntityId, ContentDocumentId 
                                             FROM ContentDocumentLink 
                                             WHERE LinkedEntityId =: testCase.Id 
                                             AND ContentDocumentId =: newContentDocument.Id 
                                             LIMIT 1 ];
        System.assertNotEquals(null, newLinkEntity);
    }
    private static testMethod void refreshEvidenceCountOnInsertTest(){        
        //create new risk assessment
        Risk_Rating_Evidence__c testRiskAssessment = eNettTestUtility.createRiskAssessment(eNettTestUtility.createRegistration('Test Company',eNettTestUtility.createAccount('Test Account').Id).Id);
        //create new verificaiton
        Verification__c testVerification = eNettTestUtility.createVerification();
        
        //---verfiy count, checkbox and attachment status on Risk Assessment----
        //insert 1 attachment on Risk Assessment
        eNettTestUtility.createAttachment(testRiskAssessment.Id);
        //after insert
        testRiskAssessment = [SELECT Attachment_Count__c, File_Attached__c
                              FROM Risk_Rating_Evidence__c
                              WHERE Id =: testRiskAssessment.Id
                              LIMIT 1];
        System.assertEquals(1, testRiskAssessment.Attachment_Count__c);
        System.assertEquals(true, testRiskAssessment.File_Attached__c);
        
        //---verfiy count, checkbox and attachment status on Verification---
        //insert 1 attachment on Verification
        eNettTestUtility.createAttachment(testVerification.Id);
        testVerification = [SELECT Attachment_Status__c, Attachment_Count__c, Attachment__c
                            FROM Verification__c
                            WHERE Id =: testVerification.Id
                            LIMIT 1];
        //after insert
        System.assertEquals('Document Attached', testVerification.Attachment_Status__c);
        System.assertEquals(1, testVerification.Attachment_Count__c);
        System.assertEquals(true, testVerification.Attachment__c);
        //insert another attachment on Verification
        eNettTestUtility.createAttachment(testVerification.Id);
        testVerification = [SELECT Attachment_Status__c, Attachment_Count__c, Attachment__c
                            FROM Verification__c
                            WHERE Id =: testVerification.Id
                            LIMIT 1];
        //after insert
        System.assertEquals('Multiple Attachments', testVerification.Attachment_Status__c);
        System.assertEquals(2, testVerification.Attachment_Count__c);
        System.assertEquals(true, testVerification.Attachment__c);
    }
}