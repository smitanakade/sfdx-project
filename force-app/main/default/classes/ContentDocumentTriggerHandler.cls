/*
 * This is the trigger handler class for ContentDocumentTrigger
 * Ticket: SF-5145
 * Author: Ronnie Yang
 */ 
public with sharing class ContentDocumentTriggerHandler{
    private static EvidenceCountCalculator calculator;
    private static Set<Id> verificationsToUpdate;
    private static Set<Id> riskAssessementsToUpdate;
    public void onBeforeDelete(Map<Id, ContentDocument> fileMap){
        getEvidenceParents(fileMap.values());
    }
    public void onAfterDelete(Map<Id, ContentDocument> fileMap){
        refreshEvidenceCount();
    }
    public void onUndelete(Map<Id, ContentDocument> fileMap){
        getEvidenceParents(fileMap.values());
        refreshEvidenceCount();
    }
    /*
 	 * The total number of attachments + files under a verification or risk assessment record is important in regards to progressing DD.
 	 * This method finds all the parent object Ids related to the updated attachments
 	 * Ticket: SF-5145
 	 * Author: Ronnie Yang
 	 */ 
    private void getEvidenceParents(List<ContentDocument> files){
        calculator = new EvidenceCountCalculator(files);
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
}