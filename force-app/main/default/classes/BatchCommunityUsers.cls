/**
    Description : This batch class coverts all contacts with status = 'Active' and belonging to accounts
                  having both 'EFT' and 'VANS' products will be converted to community users.
    Jira        : SF-4733
    @author :     Surajsingh Thakur  
*/

global class BatchCommunityUsers implements Database.Batchable<sObject>, Database.Stateful {
    
    global integer count = 0;

    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        List<String> desiredProducts = new List<String>();
        desiredProducts.add('VANs');
        desiredProducts.add('eNett EFT');
        
        //Query all contacts ith status = 'Active' and belonging to accounts having both 'EFT' and 'VANS' products
        String query = 'Select Id, Job_Role__c, Account.OwnerId, Email, LastName, FirstName, Phone, MobilePhone, MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode, account.eNett_products__c From Contact Where account.eNett_products__c includes (\'VANs\',\'eNett EFT\') AND Status__c = \'Active\' AND Account.OwnerId!=NULL ';
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<Contact> communityContacts) {
        
        //Query Community Profile 'Customer Community Login User_VANS'
        Profile communityVANProfile = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User_VANS' Limit 1];
        System.debug('#####communityVANProfile = '+communityVANProfile);
        //Query Community Profile 'Customer Community Login User_EFT'
        Profile communityEFTProfile = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User_EFT' Limit 1];
        System.debug('#####communityEFTProfile = '+communityEFTProfile);
        Boolean sendUserEmail = false;
        Boolean allOrNone = false;
        
        List<User> newUsers = new List<User>();
        
        for (Contact contact : communityContacts) {
            String alias = contact.LastName;
            if (alias!=NULL && alias.length() > 8) {
                alias = alias.substring(0, 8);
            }
            String nickName = contact.Email;
            if (nickName!=NULL && nickName.length() > 40) {
                nickName = nickName.substring(0, 40);
            }
        
            User newUser = new User(
                    UserName = contact.Email,
                    LastName = contact.LastName,
                    FirstName = contact.FirstName,
                    Email = contact.Email,
                    phone = contact.Phone,
                    MobilePhone = contact.MobilePhone,
                    Street = contact.MailingStreet,
                    City = contact.MailingCity,
                    State = contact.MailingState,
                    Country = contact.MailingCountry,
                    PostalCode = contact.MailingPostalCode,
                    CommunityNickName = nickName,
                    Alias = alias,
        
                    /* link to the contact and to the account through the contact... */
                    ContactId = contact.Id,
                    
                    /* various user settings */
                    emailencodingkey = 'UTF-8',
                    languagelocalekey = 'en_US',
                    localesidkey = 'en_AU',
                    timezonesidkey = 'Australia/Sydney'
                    
            );
            
            //VAN customers will be assigned to VAN specific profile
            if((contact.account.eNett_products__c).contains('VANs')){
                newUser.ProfileId = communityVANProfile.id; 
            }
            
            //EFT customers will be assigned to EFT specific profile
            else if((contact.account.eNett_products__c).contains('eNett EFT')){
                newUser.ProfileId = communityEFTProfile.id;  
            }
        
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.EmailHeader.triggerUserEmail = sendUserEmail;
            newUser.setOptions(dmo);
            
            newUsers.add(newUser);
            count++;

        }
        
        //Insert new Community User
        if (!newUsers.isEmpty()) {
            try{
                Database.SaveResult[] results = Database.insert(newUsers, allOrNone);
            }
            catch(Exception e){
                System.debug('#####Exception = '+e.getMessage()+e.getLineNumber());
            }
        }
    }   
    
    
    global void finish(Database.BatchableContext BC) {
        }
}