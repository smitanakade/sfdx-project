public class UpdateContactJobRole {

    @InvocableMethod
    public static void UpdateContactJobRoleFromReg (LIST<ID> regIds) {
    
        MAP<Id, Registration__c> accIdRegMap = new MAP<Id, Registration__c>();
        Registration__c reg;
        LIST<Contact> contUpdates = new LIST<Contact>();
        LIST<Contact> newContacts = new LIST<Contact>();
        //SET<Id> accsWithMatchingContacts = new SET<Id>();
        
        for (Registration__c r : [SELECT Id, Salutation__c, First_Name__c, Last_Name__c, Job_Role__c, Account__c, Email__c, Phone__c FROM Registration__c WHERE Id IN :regIds AND Agreement_Type__c = 'Affiliate']) {
            If (r.Account__c != null) {
                accIdRegMap.put(r.Account__c, r);
            }
        }
        
        /*
        for (Contact c : [SELECT Id, FirstName, LastName, AccountId FROM Contact WHERE AccountId IN :accIdRegMap.keySet()]) {           
            reg = accIdRegMap.get(c.AccountId);
            If (c.FirstName == reg.First_Name__c && c.LastName == reg.Last_Name__c) {
                if (c.Contact_Type__c != reg.Job_Role__c) {
                    c.Contact_Type__c = reg.Job_Role__c;
                    contUpdates.add(c);
                }
                accsWithMatchingContacts.add(c.AccountId);
            }   
        }
        */

        for (Id aId : accIdRegMap.keySet()) {
            //if (!accsWithMatchingContacts.contains(aId)) {
                reg = accIdRegMap.get(aId);
                newContacts.add(new Contact(Salutation = reg.Salutation__c,
                                            FirstName = reg.First_Name__c,
                                            LastName = reg.Last_Name__c,
                                            Email = reg.Email__c,
                                            Primary_Email_Address__c = reg.Email__c,
                                            Secondary_Email_Address__c = reg.Email__c,
                                            Financial_Email_Address__c = reg.Email__c,
                                            Phone = reg.Phone__c,
                                            Job_Role__c = 'Primary; Secondary; Financial',
                                            AccountId = reg.Account__c,
                                            Title__c = reg.Job_Role__c));
            //}
        }
        
        
        //update contUpdates;
        insert newContacts;
    }

}