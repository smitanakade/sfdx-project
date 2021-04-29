public class CreatePrimaryContactsForAffiliates {

    @InvocableMethod
    public static void CreatePrimaryContactsForAffiliates(LIST<Id> regIds) {
    
        MAP<Id, Registration__c> accIdRegMap = new MAP<Id, Registration__c>();
        LIST<Contact> newContacts = new LIST<Contact>();

        for (Registration__c reg : [SELECT Id, Account__c, first_name__c, last_name__c, email__c, currency__c, job_role__c, phone__c, Salutation__c
                                    FROM Registration__c WHERE Id IN :regIds AND Account__c != null AND Agreement_Type__c = 'Affiliate']) {         
            accIdRegMap.put(reg.account__c, reg);       
        }
        
        // Filter out active accounts that already have primary contacts
        for (Account acc : [SELECT Id, Account_Status__c, (SELECT Id FROM Contacts WHERE Job_Role__c INCLUDES ('Primary')) FROM Account WHERE Id IN :accIdRegMap.keySet()]) {
            if (acc.Account_Status__c == 'Active' && acc.Contacts.size() > 0) 
                accIdRegMap.remove(acc.id);
        }
        
        // 
        for (Registration__c reg : accIdRegMap.values()) {           
            Contact cont = new Contact(Salutation = reg.Salutation__c,
                                       LastName = reg.last_name__c,
                                       AccountId = reg.account__c,
                                       CurrencyIsoCode = reg.currency__c,
                                       Email = reg.email__c,
                                       Financial_Email_Address__c = reg.email__c,
                                       FirstName = reg.first_name__c,
                                       Job_Role__c = 'Primary;Secondary;Financial',
                                       Phone = reg.phone__c,
                                       Primary_Email_Address__c = reg.email__c,
                                       Secondary_Email_Address__c = reg.email__c,
                                       Title = 'hello2' //reg.job_role__c
                                      );
            newContacts.add(cont);
        }

        insert newContacts;
    }

}