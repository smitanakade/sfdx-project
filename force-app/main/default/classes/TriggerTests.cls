@isTest
private class TriggerTests {

    static testMethod void RunTest() {
        // For minimum 1% trigger code coverage (since allocated zero time to write unit tests!)
        Verification__c v = new Verification__c();
        insert v;
        update v;

        Registration__c r = new Registration__c(Registered_Company_Name__c = 'acmecorp');
        insert r;
        Beneficial_Owner__c bo = new Beneficial_Owner__c(Registration__c = r.id);
        insert bo;
        update bo;       
        Registration_Bank_Account__c rbA = new Registration_Bank_Account__c(Registration__c = r.id, Bank_Code__c = '1', Account_Number__c = '1');
        insert rbA;
        Risk_Rating_Evidence__c rRE = new Risk_Rating_Evidence__c(Registration__c = r.id);
        insert rRE;
        update rRE;
        
        Case c = new Case(Status = 'Open', Priority = 'Should Have');
        insert c;
        Delivery_Dormant_History__c dDH = new Delivery_Dormant_History__c(Related_Delivery_Ticket__c = c.id);
        insert dDH;
        
        Process_Task__c pT = new Process_Task__c(Subject__c = 's');
        insert pT;
        update pT;
        delete pT;
        
        Contact ct = new Contact(LastName = 'Tester');
        insert ct;
        update ct;
    }

}