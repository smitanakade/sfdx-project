public with sharing class eNettContractControllerExtension {
    
    public eNettContractControllerExtension(ApexPages.StandardController stdController) {
        
        eNett_Contract__c theContract = [Select Contract_Type__c, Account_Name__c From eNett_Contract__c where Id = :stdController.getRecord().Id];
        if (String.isBlank(theContract.Contract_Type__c)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'This Contract will not proceed without a valid Contract Type. Registration is responsible for populating this field.')); }

        Account theAccount = [Select T_C_Accepted_Date__c From Account where Id = :theContract.Account_Name__c];
        if ( theContract.Contract_Type__c == 'Standard T&Cs' && theAccount.T_C_Accepted_Date__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'This Contract will not proceed without a valid T & C Accepted Date on the Account. This field will be automatically set by the Registration system.')); }            
    }
}