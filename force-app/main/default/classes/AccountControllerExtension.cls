public with sharing class AccountControllerExtension {

    public boolean hasMessages(){
        return ApexPages.getMessages().size() > 0;
    }
    
    public boolean isSalesProfile(){
        string profileName = [Select Id,Name from Profile where Id=:UserInfo.getProfileId() LIMIT 1].Name;
        return profileName.toUpperCase().contains('SALES');
    }
    
    public AccountControllerExtension(ApexPages.StandardController stdController) {

        Account theAccount = [Select Country__c, Do_Not_Contact__c from Account where Id = :stdController.getRecord().Id];

// *** SF-1366 Removed reference to Category 1 Country
//        if (theAccount <> null) {
//            CountryMappings__c theCountry = [SELECT Id, Category_1_Country__c from CountryMappings__c WHERE Name = :theAccount.Country__c LIMIT 1];
//            if (!theCountry.Category_1_Country__c)
//                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The Country associated with this Account is not a Category 1 Country and therefore registration cannot be processed.'));
//        }
//        else {
//                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'A Category 1 Country must be associated with this Account otherwise registration cannot be processed.'));
//        }
        if (theAccount == null)
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'A Country should be associated with this Account.'));
        
        if (theAccount.Do_Not_Contact__c == true) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Please DO NOT CONTACT this client. Email aml@enett.com for further information.'));
            }    

    }
}