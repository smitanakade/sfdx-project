public with sharing class CaseControllerExtension {

    public boolean hasMessages(){
    	return ApexPages.getMessages().size() > 0;
    }
    
    public CaseControllerExtension(ApexPages.StandardController stdController) {
        
        Case theCase = [Select Origin, Priority From Case where Id = :stdController.getRecord().Id];
        if ((theCase.Origin == 'EMail' || theCase.Origin == 'Fax' ) && theCase.Priority == '-- None --' ) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The Customer Service Prioity cannot be "-- None --", please change this to a valid option.'));      
        }            
    }
}