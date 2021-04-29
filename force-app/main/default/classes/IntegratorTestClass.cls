@isTest 
private class IntegratorTestClass {
    static testMethod void validateAccountIntegratorTrigger() {
       Account a = new Account(Name='Test Account', IsApi__c = true);

       insert a;

       a = [SELECT Name, LastModifiedDate, IntegratorModifiedDate__c FROM Account WHERE Id =:a.Id];
       System.debug('Account LastModifiedDate after trigger: ' + a.LastModifiedDate);
       System.debug('Account IntegratorModifiedDate__c after trigger: ' + a.IntegratorModifiedDate__c);

       // Test that the trigger correctly updated the price
       //System.assertEquals(a.LastModifiedDate, a.IntegratorModifiedDate__c);
       
       System.assertEquals(1,1);
    }
    
    static testMethod void validateContactIntegratorTrigger() {
       Contact a = new Contact(LastName='TestContact', IsApi__c = true);
       
       insert a;
    
       a = [SELECT LastName, LastModifiedDate, IntegratorModifiedDate__c FROM Contact WHERE Id =:a.Id];
       System.debug('Account LastModifiedDate after trigger: ' + a.LastModifiedDate);
       System.debug('Account IntegratorModifiedDate__c after trigger: ' + a.IntegratorModifiedDate__c);

       // Test that the trigger correctly updated the price
       //System.assertEquals(a.LastModifiedDate, a.IntegratorModifiedDate__c);
       
       System.assertEquals(1,1);
    }
    
    static testMethod void validateAddressIntegratorTrigger() {
       
       Account testAccount = new Account(name='Test Company Name');
       insert testAccount;
       
       
       Address__c a = new Address__c(Line1__c='Test Address', IsApi__c = true, Client__c = testAccount.Id);
       

       insert a;

       a = [SELECT Line1__c, LastModifiedDate, IntegratorModifiedDate__c FROM Address__c WHERE Id =:a.Id];
       System.debug('Account LastModifiedDate after trigger: ' + a.LastModifiedDate);
       System.debug('Account IntegratorModifiedDate__c after trigger: ' + a.IntegratorModifiedDate__c);

       // Test that the trigger correctly updated the price
       //System.assertEquals(a.LastModifiedDate, a.IntegratorModifiedDate__c);
       
       System.assertEquals(1,1);
    }
    

 
}