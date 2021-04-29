/* This is the handler class for ContactTrigger
 */
public class ContactTriggerHandler{    
    public void onAfterDelete(List<Contact> contacts){
        updateContactInfoOnRelatedRecords(contacts, true);
    }
    public void onAfterInsert(List<Contact> contacts){
        preventContactDuplicates(contacts, false);
        //SF-5316 31/10/2018 Jasmine - No need to update contact on insert because lead mappings already collect needed data.
        //LeadUtility cls already does the update and if it triggers this trigger governor limit will be exceeded.
        //updateContactInfoOnRelatedRecords(contacts, false);
    }
    public void onAfterUpdate(List<Contact> contacts){
        preventContactDuplicates(contacts, true);
        updateContactInfoOnRelatedRecords(contacts, false);
    }
    public void onUndelete(List<Contact> contacts){
        updateContactInfoOnRelatedRecords(contacts, false);
    }
    /* Originally an individual trigger
     * Transferred into this handler class
	 */ 
    private void preventContactDuplicates(List<Contact> contacts, Boolean isUpdate){
        if (!checkRecursive.runOnce() && isUpdate) {
            return;
        }   
        Set<ID> AccountIDs = new Set<ID>();
        // Grab related Accounts
        for(Contact c : contacts) {
            AccountIDs.add(c.AccountId);
        }
        
        // Select Contacts with type of 'Primary','Secondary' or 'Financial' for relevant accounts
        List<Contact> AccountContacts = [
            SELECT Id, Job_Role__c, AccountID 
            FROM Contact 
            WHERE AccountId in :AccountIDs
            AND Job_Role__c INCLUDES ('Primary','Secondary','Financial') ];
        
        // Iterate Accounts/Contacts/Types and compare, removing any duplicates
        SET<Id> updateIds = new SET<Id>();
        
        if(!AccountContacts.isEmpty()) {
            for(Contact c : contacts) {
                if (String.isNotEmpty(c.Job_Role__c)) {
                    for(String selectedType : c.Job_Role__c.split(';')) {
                        // Iterate through the other Account Contacts, removing instances Type of our new/updated Contact
                        Integer j = 0;
                        while (j < AccountContacts.size()) {
                            //If it's our current contact = ignore!
                            if (AccountContacts.get(j).AccountID == c.AccountId && AccountContacts.get(j).Job_Role__c.contains(selectedType) && AccountContacts.get(j).Id != c.Id) {
                                if (selectedType == 'Primary' || selectedType == 'Secondary' || selectedType == 'Financial') {
                                    AccountContacts.get(j).Job_Role__c = AccountContacts.get(j).Job_Role__c.remove(selectedType + ';');
                                    AccountContacts.get(j).Job_Role__c = AccountContacts.get(j).Job_Role__c.remove(selectedType);
                                }
                                if (selectedType == 'Primary') AccountContacts.get(j).Primary_Email_Address__c = null;
                                if (selectedType == 'Secondary') AccountContacts.get(j).Secondary_Email_Address__c = null;
                                if (selectedType == 'Financial') AccountContacts.get(j).Financial_Email_Address__c = null;                            
                                updateIds.add(AccountContacts.get(j).Id);
                            }
                            j++;
                        }
                    }
                }
            }
        }
        
        List<Contact> modifiedAccountContacts = new List<Contact>();
        for (Contact c : AccountContacts) {
            if (updateIds.contains(c.Id))
                modifiedAccountContacts.add(c);
        }
        
        if (!modifiedAccountContacts.isEmpty()) update modifiedAccountContacts;
    }
    /*
* After Insert, After Update, After Delete, After UnDelete*
* We have primary, secondary and financial contact info under account 
* We have primary contact info under rego
* The purpose of this is when we change the contact info, this will update the account and rego as well
* Ticket: SF-5132
* Author: Ronnie Yang
*/
    private void updateContactInfoOnRelatedRecords(List<Contact> contacts, Boolean isDelete){
        //get a list of accounts to update based on the contacts list
        //feels like there's a cleaner way
        List<Id> accIds = new List<Id>();
        List<Id> regoIds = new List<Id>();
        //get accounts that own the contacts
        for(Contact c : contacts){
            accIds.add(c.AccountId);
        }
        Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id, Reference_Registration__c, Primary_Contact_Email_Address__c, Primary_Contact_First_Name__c,
                                                        Primary_Contact_Last_Name__c, Primary_Contact_Id__c, Primary_Contact_Phone__c,
                                                        Primary_Contact_Title__c, Secondary_Contact_First_Name__c, Secondary_Contact_Last_Name__c,
                                                        Secondary_Contact_Email__c, Financial_Contact_First_Name__c, Financial_Contact_Last_Name__c,
                                                        Financial_Contact_Email__c
                                                        FROM Account
                                                        WHERE Id IN: accIds]);
        //get the reference rego based on the accounts
        for(Account a: accMap.values()){
            regoIds.add(a.Reference_Registration__c);
        }
        Map<Id, Registration__c> regoMap = new Map<Id, Registration__c>([SELECT Id, First_Name__c, Last_Name__c, Job_Title__c, Email__c, Phone__c, Salutation__c
                                                                         FROM Registration__c
                                                                         WHERE Id IN: regoIds]);
        //start updating
       
        List<Account> accsToUpdateList = new List<Account>();
        Map<Id, Account> accsToUpdateMap = new Map<Id, Account>(); 
        List<Registration__c> regosToUpdate = new List<Registration__c>();
        for(Contact c: contacts){
            //no point updating if the contact has no applicable roles
            //no point updating if the contact is not linked to an account
            if(c.Job_Role__c != NULL && c.AccountId != NULL){
                //find the contact's parent account and its reference rego
                //Kishore Potla - PDS-3406: error in current system while updating list of contacts of same account 
                Account parent;
                if(accsToUpdateMap.containsKey(c.AccountId)){
                    parent = accsToUpdateMap.get(c.AccountId);
                }else{
                    parent = accMap.get(c.AccountId);
                }               
                Registration__c referenceReg = regoMap.get(parent.Reference_Registration__c);
                // Because you can't delete a primary contact so isDelete condition is not applied here like the secondary/financial part
                if(c.Job_Role__c.contains('Primary')){
                    if(referenceReg != NULL){
                        //update reg
                        referenceReg.First_Name__c = c.FirstName;
                        referenceReg.Last_Name__c = c.LastName;
                        referenceReg.Job_Title__c = c.Title__c;
                        referenceReg.Email__c = c.Primary_Email_Address__c;
                        referenceReg.Phone__c = c.Phone;
                        referenceReg.Salutation__c = c.Salutation;
                        regosToUpdate.add(referenceReg);
                    }
                    //update account
                    parent.Primary_Contact_Email_Address__c = c.Primary_Email_Address__c;
                    parent.Primary_Contact_First_Name__c = c.FirstName;
                    parent.Primary_Contact_Last_Name__c = c.LastName;
                    parent.Primary_Contact_Id__c = c.Id;
                    parent.Primary_Contact_Phone__c = c.Phone;
                    parent.Primary_Contact_Title__c = c.Salutation;
                }
                if(c.Job_Role__c.contains('Secondary')){
                    parent.Secondary_Contact_First_Name__c = isDelete ? '' : c.FirstName;
                    parent.Secondary_Contact_Last_Name__c = isDelete ? '' : c.LastName;
                    parent.Secondary_Contact_Email__c = isDelete ? '' : c.Secondary_Email_Address__c;
                }
                if(c.Job_Role__c.contains('Financial')){
                    parent.Financial_Contact_First_Name__c = isDelete ? '' : c.FirstName;
                    parent.Financial_Contact_Last_Name__c = isDelete ? '' : c.LastName;
                    parent.Financial_Contact_Email__c = isDelete ? '' : c.Financial_Email_Address__c;
                }
                accsToUpdateMap.put(parent.id, parent);
            }
        }
        accsToUpdateList = accsToUpdateMap.values();
        //to avoid null pointer
        if(accsToUpdateList.size() > 0){
            SavePoint sp = Database.setSavepoint();
            try{
                Database.DMLOptions dmo = new Database.DMLOptions();
                //allowing partial processing
                dmo.optAllOrNone = false;
                
                List<Database.SaveResult> saveResults = Database.update(new List<Account>(accsToUpdateList), dmo);
                for(Integer i = 0; i < saveResults.size(); i++){
                    Database.SaveResult saveResult = saveResults[i];
                    if(!saveResult.isSuccess()){
                        for(Database.Error err: saveResult.getErrors()){
                            System.debug('####ERROR WHILE PROCESSING ACCOUNT: ' + err.getMessage());
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
        if(regosToUpdate.size() > 0){
            SavePoint sp = Database.setSavepoint();
            try{
                Database.DMLOptions dmo = new Database.DMLOptions();
                //allowing partial processing
                dmo.optAllOrNone = false;
                
                List<Database.SaveResult> saveResults = Database.update(regosToUpdate, dmo);
                for(Integer i = 0; i < saveResults.size(); i++){
                    Database.SaveResult saveResult = saveResults[i];
                    if(!saveResult.isSuccess()){
                        for(Database.Error err: saveResult.getErrors()){
                            System.debug('####ERROR WHILE PROCESSING ACCOUNT: ' + err.getMessage());
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