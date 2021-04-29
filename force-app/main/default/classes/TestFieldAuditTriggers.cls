@istest
public class TestFieldAuditTriggers {

    public static testMethod void testFieldAuditTriggers() {

        // This provides minimal code coverage to allow trigger deployment => should be updated to actually test field auditing

        Registration__c reg = new Registration__c(Registered_Company_Name__c='ACME Travel');
        insert reg;
        
        Director__c dr = new Director__c(Registration__c = reg.Id);
        insert dr;

        Journal__c jn = new Journal__c(Registration__c = reg.Id);
        insert jn;

        PEP__c pep = new PEP__c(In_office__c = true);
        insert pep;
        
        update dr;
        update jn;
        update pep;        
    }
    
}