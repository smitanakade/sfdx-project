/*
 * This is the trigger handler class for AttachmentTrigger
 * Ticket: SF-5145
 * Author: Ronnie Yang
 */ 

public with sharing class AttachmentTriggerHandler{
    private static EvidenceCountCalculator calculator;
    private static Set<Id> verificationsToUpdate;
    private static Set<Id> riskAssessementsToUpdate;
    public void onBeforeDelete(Map<Id, Attachment> attachmentMap){
        getEvidenceParents(attachmentMap.values());
    }
    public void onAfterInsert(Map<Id, Attachment> attachmentMap){ 
        convertAttachmentToFile(attachmentMap);
        //don't need to refresh evidence count here as it will happen on ContentDocumentLinkTrigger 
    }
    public void onAfterDelete(Map<Id, Attachment> attachmentMap){
        refreshEvidenceCount();
    }
    public void onAfterUndelete(Map<Id, Attachment> attachmentMap){
        getEvidenceParents(attachmentMap.values());
        refreshEvidenceCount();
    }
    /*
 	 * The total number of attachments + files under a verification or risk assessment record is important in regards to progressing DD.
 	 * This method finds all the parent object Ids related to the updated attachments
 	 * Ticket: SF-5145
 	 * Author: Ronnie Yang
 	 */ 
    private void getEvidenceParents(List<Attachment> attachments){
        calculator = new EvidenceCountCalculator(attachments);
        verificationsToUpdate = calculator.findVerificaitonIds();
        riskAssessementsToUpdate = calculator.findRiskAssessmentIds();
    }
    /* This method gets the total count of attachments + files on the parent object
     * And updates those counts
  	 * Ticket: SF-5145
 	 * Author: Ronnie Yang
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


    /*
	 * Unfortunately even with the setting enabled in general settings
	 * In certain scenarios like email-to-case, the system will still insert attachment instead of files
	 * This will convert the attachment to files in that instance
	 * Ticket: SF-5145
 	 * Author: Ronnie Yang
	 */
    private void convertAttachmentToFile(Map<Id, Attachment> attachmentMap){
        List<ContentVersion> newFileVersions = new List<ContentVersion>();
        for (Attachment a: attachmentMap.values()){
            //SF-5391 Ronnie -- Client Agreement can't be converted due to the limited access public site guest user has on Salesforce Files object
            if(a.name != 'Client Agreement.pdf' && !a.name.contains('Banking_Details') ){
                //ref: https://github.com/douglascayers/sfdc-convert-attachments-to-chatter-files/blob/master/src/classes/ConvertAttachmentsToFilesService.cls
                ContentVersion newFileVersion = new ContentVersion(
                    //data fields
                    VersionData = a.Body,
                    Title = a.Name,
                    Description = a.Description,
                    PathOnClient = '/' + a.Name,
                    FirstPublishLocationId = a.ParentId,
                    SharingPrivacy = (a.IsPrivate ? 'P' : 'N'),
                    //audit fields
                    OwnerId = a.OwnerId,
                    CreatedById = a.OwnerId,
                    CreatedDate = a.CreatedDate,
                    LastModifiedById = a.LastModifiedById,
                    LastModifiedDate = a.LastModifiedDate,
                    Original_Record_Id__c = a.Id,
                    Original_Record_Owner_Id__c = a.OwnerId,
                    Original_Record_Parent_Id__c = a.ParentId
                );
                newFileVersions.add(newFileVersion);
            }
        }
        if(newFileVersions.size() > 0){
            try{
                System.debug(newFileVersions);
                insert newFileVersions;
                delete [select id from attachment where id in: attachmentMap.keySet()];
            }catch (Exception e){
                System.debug('####ERROR ENCOUNTERED WHILE CONVERTING NEW ATTACHMENT TO FILE: ' + e.getMessage());
                throw e;
            }
        }
    }
}