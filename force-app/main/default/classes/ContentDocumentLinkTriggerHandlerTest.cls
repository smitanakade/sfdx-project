/*
 * This is a test class for ContactTriggerHandler
 * Ticket: SF-5145
 * Author: Ronnie Yang
 */
@isTest
public class ContentDocumentLinkTriggerHandlerTest {
    private static testMethod void reassignEmailFileToParentTest(){
        //insert email message together withe file on a test case
        Case testCase = eNettTestUtility.createCase();
        ContentDocument testFile = eNettTestUtility.createFile(eNettTestUtility.createEmailMessage(testCase.Id).Id);
        //get the link
        ContentDocumentLink caseFileLink = [SELECT ContentDocumentId, LinkedEntityId
                                            FROM ContentDocumentLink
                                            WHERE LinkedEntityId =:testCase.Id
                                            LIMIT 1];
        //assert that the link is now on the test case
        System.assertEquals(testFile.Id, caseFileLink.ContentDocumentId);
    }
    private static testMethod void refreshEvidenceCountInsertTest(){
        //create new risk assessment
        Risk_Rating_Evidence__c testRiskAssessment = eNettTestUtility.createRiskAssessment(eNettTestUtility.createRegistration('Test Company',eNettTestUtility.createAccount('Test Account').Id).Id);
        //create new verificaiton
        Verification__c testVerification = eNettTestUtility.createVerification();
        
        //---verfiy count, checkbox and attachment status on Risk Assessment----
        //insert 1 file on Risk Assessment
		ContentDocument testFile = eNettTestUtility.createFile(testRiskAssessment.Id);
        //after insert
        testRiskAssessment = [SELECT Id, Attachment_Count__c, File_Attached__c
                              FROM Risk_Rating_Evidence__c
                              WHERE Id =: testRiskAssessment.Id
                              LIMIT 1];
        ContentDocumentLink linkage = [SELECT LinkedEntityId, ContentDocumentId
                                       FROM ContentDocumentLInk
                                       WHERE ContentDocumentId =: testFile.Id
                                      LIMIT 1];
        testRiskAssessment = [SELECT Id, Attachment_Count__c, File_Attached__c
                              FROM Risk_Rating_Evidence__c
                              WHERE Id =: testRiskAssessment.Id
                              LIMIT 1];
        System.assertEquals(1, testRiskAssessment.Attachment_Count__c);
        System.assertEquals(true, testRiskAssessment.File_Attached__c);
        //---verfiy count, checkbox and attachment status on Verification---
        //insert 1 file on Risk Assessment
        eNettTestUtility.createFile(testVerification.Id);
        testVerification = [SELECT Attachment_Status__c, Attachment_Count__c, Attachment__c
                            FROM Verification__c
                            WHERE Id =: testVerification.Id
                            LIMIT 1];
        //after insert
        System.assertEquals('Document Attached', testVerification.Attachment_Status__c);
        System.assertEquals(1, testVerification.Attachment_Count__c);
        System.assertEquals(true, testVerification.Attachment__c);
        //insert 1 file on Risk Assessment
        eNettTestUtility.createFile(testVerification.Id);
        testVerification = [SELECT Attachment_Status__c, Attachment_Count__c, Attachment__c
                            FROM Verification__c
                            WHERE Id =: testVerification.Id
                            LIMIT 1];
        //after insert
        System.assertEquals('Multiple Attachments', testVerification.Attachment_Status__c);
        System.assertEquals(2, testVerification.Attachment_Count__c);
        System.assertEquals(true, testVerification.Attachment__c);
    }
    private static testMethod void refreshEvidenceCountDeleteTest(){
        //create new risk assessment
        Risk_Rating_Evidence__c testRiskAssessment = eNettTestUtility.createRiskAssessment(eNettTestUtility.createRegistration('Test Company',eNettTestUtility.createAccount('Test Account').Id).Id);
        //create new verificaiton
        Verification__c testVerification = eNettTestUtility.createVerification();
        
        //---verfiy count, checkbox and attachment status on Risk Assessment----
        //insert 1 file on Risk Assessment
        ContentDocument testFile = eNettTestUtility.createFile(testRiskAssessment.Id);
        //after delete
        delete testFile;
        testRiskAssessment = [SELECT Attachment_Count__c, File_Attached__c
                              FROM Risk_Rating_Evidence__c
                              WHERE Id =: testRiskAssessment.Id
                              LIMIT 1];
        System.assertEquals(0, testRiskAssessment.Attachment_Count__c);
        System.assertEquals(false, testRiskAssessment.File_Attached__c);
        //after undelete
        undelete testFile;
        testRiskAssessment = [SELECT Attachment_Count__c, File_Attached__c
                              FROM Risk_Rating_Evidence__c
                              WHERE Id =: testRiskAssessment.Id
                              LIMIT 1];
        System.assertEquals(1, testRiskAssessment.Attachment_Count__c);
        System.assertEquals(true, testRiskAssessment.File_Attached__c);
        //---verfiy count, checkbox and attachment status on Verification---
        //insert 1 file on Verification
        testFile = eNettTestUtility.createFile(testVerification.Id);
        //after delete
        delete testFile;
        testVerification = [SELECT Attachment_Status__c, Attachment_Count__c, Attachment__c
                            FROM Verification__c
                            WHERE Id =: testVerification.Id
                            LIMIT 1];
        System.assertEquals('No Attachment', testVerification.Attachment_Status__c);
        System.assertEquals(0, testVerification.Attachment_Count__c);
        System.assertEquals(false, testVerification.Attachment__c);
        //after undelete
        undelete testFile;
      	testVerification = [SELECT Attachment_Status__c, Attachment_Count__c, Attachment__c
                            FROM Verification__c
                            WHERE Id =: testVerification.Id
                            LIMIT 1];
        System.assertEquals('Document Attached', testVerification.Attachment_Status__c);
        System.assertEquals(1, testVerification.Attachment_Count__c);
        System.assertEquals(true, testVerification.Attachment__c);
    }
}