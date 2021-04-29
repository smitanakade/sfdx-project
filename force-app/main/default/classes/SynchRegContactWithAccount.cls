public class SynchRegContactWithAccount {

    // Note: the requirements have changed for the umpteenth time, so all the contact synching code & process flows are now a rather convoluted mess.
    // This will need to be cleaned up at some point although this can't be done until the desired behaviour has been clarified.
    @InvocableMethod
    public static void SynchContactWithAccount (LIST<ID> regIds) {

        MAP<Id, Id> regToAccIdmap = new MAP<Id, Id>();      
        MAP<Id, LIST<Contact>> accIdContactsMap = new MAP<Id, LIST<Contact>>();
        MAP<Id, Boolean> accActiveMap = new MAP<Id, Boolean>();
        LIST<Id> accIds = new LIST<Id>();
        SET<Registration__c> regsWithAccount = new SET<Registration__c>();
        LIST<Contact> contactUpdates = new LIST<Contact>();
        LIST<Contact> newContacts = new LIST<Contact>();
        
        // Create set of all related Account Ids
        for (Registration__c r : [SELECT Id, Salutation__c, First_Name__c, Last_Name__c, Job_Role__c, Account__c, Email__c, Phone__c FROM Registration__c WHERE Id IN :regIds]) {
            If (r.Account__c != null) {
                accIds.add(r.Account__c);
                regsWithAccount.add(r);
            }
        }
        
        //PDS-6401 - Rework the logic to extract Contacts as below commented code throws Governance limit in subquery object extract.
        //        1) Get only the Active Contacts
        //        2) loop through list of contacts and add it to a list and then add it back accIdContactsMap
        
        // Create map of account ids and related contacts        
        for (Account a : [SELECT Id, Account_Status__c, (SELECT Id, FirstName, LastName, Job_Role__c, Phone, Email FROM Contacts WHERE Status__c = 'Active' ORDER BY CreatedDate DESC) FROM Account WHERE Id IN :accIds]) {
            LIST<Contact> accountContacts = new LIST<Contact>();
            
            for (Contact c : a.Contacts){
                accountContacts.add(c);
            }

            if (accountContacts.Size() != 0)
            {
             accIdContactsMap.put(a.Id, accountContacts);             
             if (a.Account_Status__c != null && a.Account_Status__c == 'Active') {
                    accActiveMap.put(a.Id, true);                 
                } 
             else {
                    accActiveMap.put(a.Id, false);                                        
                }
            }
        }
                
        
        // 
        Boolean matchingContact;
        Boolean matchingPrimaryFound;
        Boolean primaryFound;
        String jobRole;
        for (Registration__c reg : regsWithAccount) {
            matchingContact = false;
            matchingPrimaryFound = false;

            // Patch for SF-3495 - Changes need refactoring since convoluted!
            for (Contact c : accIdContactsMap.get(reg.Account__c)) {
                if (c.Job_Role__c != null && c.Job_Role__c.contains('Primary')) primaryFound = true;
                if (c.FirstName == reg.First_Name__c && c.LastName == reg.Last_Name__c) {
                    if (c.Job_Role__c != null && c.Job_Role__c.contains('Primary')) {
                        matchingPrimaryFound = true;
                    }                   
                }
            }
                        
            for (Contact c : accIdContactsMap.get(reg.Account__c)) {
                if (c.FirstName == reg.First_Name__c && c.LastName == reg.Last_Name__c) {
                    jobRole = (c.Job_Role__c == null) ? '' : c.Job_Role__c;
                    if (jobRole.contains('Primary') || !matchingPrimaryFound) {
                        if (!jobRole.contains('Primary') || c.Email != reg.Email__c || c.Phone != reg.Phone__c) {
                            if (!(accActiveMap.get(reg.Account__c) && primaryFound)) {
                                if (!jobRole.contains('Primary')) {
                                    c.Job_Role__c = (c.Job_Role__c == null) ? 'Primary' : c.Job_Role__c + '; Primary';
                                }
                                c.Email = reg.Email__c;
                                c.Phone = reg.Phone__c;
                                c.Title__c = reg.Job_Role__c;
                                c.Primary_Email_Address__c = reg.Email__c;
                                contactUpdates.add(c);
                            }
                        }
                    }
                    matchingContact = true;
                }               
            }
            if (!matchingContact) {
                if (!(accActiveMap.get(reg.Account__c) && primaryFound)) {
                    newContacts.add(new Contact(Salutation = reg.Salutation__c,
                                            FirstName = reg.First_Name__c,
                                            LastName = reg.Last_Name__c,
                                            Email = reg.Email__c,
                                            Primary_Email_Address__c = reg.Email__c,
                                            Phone = reg.Phone__c,
                                            Job_Role__c = 'Primary;',
                                            AccountId = reg.Account__c,
                                            Title__c = reg.Job_Role__c));
                }
            }
        }
        
        update contactUpdates;
        insert newContacts;
    }
    
}