/**
* This batchable process loop through each account that has at least one contact and make sure the secondary/financial contact info is up to date.
@author : Ronnie Yang
@ticket : SF-5132
**/

global class AccountContactInfoProcessor implements Database.Batchable<sObject>, Database.Stateful {
    // instance member to retain state across transactions
    global Integer recordsProcessed = 0;
    
    // get all active accounts with contacts
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, (SELECT Id,FirstName, LastName, Job_Role__c, Primary_Email_Address__c, Secondary_Email_Address__c, Financial_Email_Address__c FROM Contacts) FROM Account WHERE Account_Status__c = \'Active\'');
    }
    
    //looping through all these active accounts and update the info on account
    global void execute(Database.BatchableContext bc, List<Account> accs){
        String p_firstName;
        String p_lastName;
        String p_email;
        String s_firstName;
        String s_lastName;
        String s_email;
        String f_firstName;
        String f_lastName;
        String f_email;
        for (Account a: accs){
            //as there can only be one primary, secondary or financial contact, we can loop through every contact and not worry about string being overwritten.
            for(Contact c: a.Contacts){
                if(c.Job_Role__c != null){
                    if (c.Job_Role__c.contains('Primary')){
                        p_firstName = !String.isEmpty(c.FirstName) ? c.FirstName : '';
                        p_lastName = c.LastName;
                        p_email = !String.isEmpty(c.Primary_Email_Address__c) ? c.Primary_Email_Address__c : '' ;
                    }
                    if (c.Job_Role__c.contains('Secondary')){
                        s_firstName = !String.isEmpty(c.FirstName) ? c.FirstName : '';
                        s_lastName = c.LastName;
                        s_email = !String.isEmpty(c.Secondary_Email_Address__c) ? c.Secondary_Email_Address__c : '';
                    }
                    if (c.Job_Role__c.contains('Financial')){
                        f_firstName = !String.isEmpty(c.FirstName) ? c.FirstName : '';
                        f_lastName = c.LastName;
                        f_email = !String.isEmpty(c.Financial_Email_Address__c) ? c.Financial_Email_Address__c : '';
                    }
                }
            }
            //update the contact values on account if it's applicable
            if(!String.isEmpty(p_lastName)){
                a.Primary_Contact_First_Name__c = p_firstName;
                a.Primary_Contact_Last_Name__c = p_lastName;
                a.Primary_Contact_Email_Address__c = p_email;
            }
            if(!String.isEmpty(s_lastName)){
                a.Secondary_Contact_First_Name__c = s_firstName;
                a.Secondary_Contact_Last_Name__c = s_lastName;
                a.Secondary_Contact_Email__c = s_email;
            }
            if(!String.isEmpty(f_lastName)){
                a.Financial_Contact_First_Name__c = f_firstName;
                a.Financial_Contact_Last_Name__c = f_lastName;
                a.Financial_Contact_Email__c = f_email;
            }
            System.debug(a);
        }
        update accs;
    }    
    
    global void finish(Database.BatchableContext bc){
        System.debug(recordsProcessed+ ' Processed');
    }    
}