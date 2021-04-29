/*
 * This is the trigger handler class for ContentDocumentLinkTrigger
 * Ticket: SF-5145
 * Author: Ronnie Yang
 */ 
public with sharing class ContentDocumentLinkTriggerHandler{
    private static EvidenceCountCalculator calculator;
    private static Set<Id> verificationsToUpdate;
    private static Set<Id> riskAssessementsToUpdate;
    public void onBeforeInsert(List<ContentDocumentLink> links){
        reassign(links);
        getEvidenceParents(links);
    }
    public void onAfterInsert(Map<Id, ContentDocumentLink> linkMap){ 
        refreshEvidenceCount();
        synchronizeAttachmentWithJIRAIssue(linkMap);
    }

    /*
 	 * Replacing old SynchronizeAttachmentWithJIRAIssue trigger
 	 * Ticket: SF-5145
 	 * Author: Ronnie Yang
 	 */ 
    private void synchronizeAttachmentWithJIRAIssue(Map<Id, ContentDocumentLink> linkMap){
        if (Jira.IntegrationEnabled && JIRA.currentUserIsNotJiraAgent() && !System.isBatch() && !System.isFuture()){
            Set<Id> caseIds = new set<Id>();
            Set<Id> syncedCaseIds = new Set<Id>();
            for(ContentDocumentLink c: linkMap.values()){
                if(c.LinkedEntityId.getSObjectType() == Case.SObjectType)
                    caseIds.add(c.LinkedEntityId);
            }   
            
            Map<Id, Case> caseMap = new Map<id, Case>([SELECT Id, JIRA_Status__c, Service_Ticket__c FROM Case WHERE Id IN :caseIds]);
            
            for(ContentDocumentLink c : linkMap.values()){
                if(c.LinkedEntityId.getSObjectType() == Case.SObjectType){
                    String objectType ='Case';
                    Id objectId = c.LinkedEntityId;
                    // Calls the actual callout to synchronize with the JIRA issue.
                    
                    if ((caseMap.get(objectId).JIRA_Status__c != 'Waiting for Response') && 
                        (caseMap.get(objectId).JIRA_Status__c != 'Resolved') && 
                        (caseMap.get(objectId).JIRA_Status__c != 'Cancelled') &&
                        caseMap.get(objectId).Service_Ticket__c &&
                        !syncedCaseIds.contains(objectId)) {
                            JIRAConnectorWebserviceCalloutSync.synchronizeWithJIRAIssue(JIRA.baseUrl, JIRA.systemId, 'Case', objectId);
                            syncedCaseIds.add(objectId);                        
                        }
                }
            }
        }
    }
    /*
	 * When an email has a parent (a parent case most commonly) and has a new file, the attachment should be attached under parent object (case) instead
	 * If it is an attachment, it will now be automatically converted into a file by AttachmentTriggerHandler
	 * SF-5145 replacing the old emailAttachmentReassigner trigger
	 * ---
	 * If a file is being attached to a record, makes the default sharing setting to "set by record"
     * Ticket: SF-5304
	 */
    private void reassign(List<ContentDocumentLink> links){
        Set<Id> linkedEmailIds = new Set<Id>();
        List<ContentDocumentLink> linksToReassign = new list<ContentDocumentLink>();
        for( ContentDocumentLink c : links ) {
            if( c.LinkedEntityId != null ){
                //find contentdocumentlinks that have email as a parent
                if(c.LinkedEntityId.getSObjectType() == EmailMessage.sObjectType){
                    linkedEmailIds.add(c.LinkedEntityId);
					linksToReassign.add(c);
                }
                //adjust access
                if(c.LinkedEntityId.getSObjectType() != User.sObjectType)
                    c.ShareType = 'I';
            }
        }
        Map<Id, EmailMessage> emailMessageMap = new Map<Id, EmailMessage>([SELECT ParentId
                                                                          FROM EmailMessage
                                                                          WHERE Id IN: linkedEmailIds]);
        //do the reassignment
        for(ContentDocumentLink c : linksToReassign){
            c.LinkedEntityId = emailMessageMap.get(c.LinkedEntityId).ParentId;
        }
        
    }
    /*
 	 * The total number of attachments + files under a verification or risk assessment record is important in regards to progressing DD.
 	 * This method finds all the parent object Ids related to the updated attachments
 	 * Ticket: SF-5145
 	 * Author: Ronnie Yang
 	 */ 
    private void getEvidenceParents(List<ContentDocumentLink> links){
        calculator = new EvidenceCountCalculator(links);
        verificationsToUpdate = calculator.findVerificaitonIds();
        riskAssessementsToUpdate = calculator.findRiskAssessmentIds();
    }
    /* When an attachment is deleted or undeleted (inserting not applicable because now they will be converted to files)
	 *  The total attachment counts will change for Verificaiton and Risk Assessements
	 *  This method updates that count integer
	 */
    private void refreshEvidenceCount(){
        if(verificationsToUpdate.size()>0){
            List<Verification__c> verifications = calculator.processVerifications(verificationsToUpdate);
            SavePoint sp = Database.setSavepoint();
            try{
                Database.DMLOptions dmo = new Database.DMLOptions();
                //allowing partial processing
                dmo.optAllOrNone = false;
                
                List<Database.SaveResult> saveResults = Database.update(verifications, dmo);
                for(Integer i = 0; i < saveResults.size(); i++){
                    Database.SaveResult saveResult = saveResults[i];
                    if(!saveResult.isSuccess()){
                        for(Database.Error err: saveResult.getErrors()){
                            System.debug('####ERROR WHILE PROCESSING RISK ASSESSMENT: ' + err.getMessage());
                        }
                    }
                }
            }catch (Exception e){
                //rollback if something else is wrong
                Database.rollback(sp);
                System.debug('####ERROR ENCOUNTERED: ' + e.getMessage());
                throw e;
            }
        }
        if(riskAssessementsToUpdate.size()>0){
            List<Risk_Rating_Evidence__c> riskAssessments = calculator.processRiskAssessments(riskAssessementsToUpdate);
            if(riskAssessments.size() > 0){
                SavePoint sp = Database.setSavepoint();
                try{
                    Database.DMLOptions dmo = new Database.DMLOptions();
                    //allowing partial processing
                    dmo.optAllOrNone = false;
                    
                    List<Database.SaveResult> saveResults = Database.update(riskAssessments, dmo);
                    for(Integer i = 0; i < saveResults.size(); i++){
                        Database.SaveResult saveResult = saveResults[i];
                        if(!saveResult.isSuccess()){
                            for(Database.Error err: saveResult.getErrors()){
                                System.debug('####ERROR WHILE PROCESSING VERIFICATION: ' + err.getMessage());
                            }
                        }
                    }
                }catch (Exception e){
                    //rollback if something else is wrong
                    Database.rollback(sp);
                    System.debug('####ERROR ENCOUNTERED: ' + e.getMessage());
                    throw e;
                }
            }
        }
        
    }  
}