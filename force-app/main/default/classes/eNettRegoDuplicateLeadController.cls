global with sharing class eNettRegoDuplicateLeadController {

    @RemoteAction
    global static void sendResumeEmail(String theEmail) {

   		Registration__c regToUpdate =
        	[SELECT Resume_Application__c FROM Registration__c
         	 WHERE Email__c= :theEmail LIMIT 1];

    	regToUpdate.Resume_Application__c = true;
    	update regToUpdate;
    }

}