@isTest (seeAllData = true) public class CaseTriggerTest{
    
    @isTest static void testRun(){
        //Data Setup
        Account testAcc = new Account (Name = 'Test Account');
        insert testAcc;
        Opportunity testOpp = new Opportunity(Name = 'Test Opp',
                                              AccountId = testAcc.Id,
                                              StageName = '1. Prospect',
                                              CloseDate = date.valueOf('2014-01-01'));
        insert testOpp;
        //Perform Test
        Opportunity testOpp2 = [SELECT Id FROM Opportunity WHERE Name ='Test Opp' LIMIT 1];
        Case testCase1 = new Case(Related_Delivery_Opportunity__c = testOpp2.Id,
                                  Subject = 'Delivery - Test Opp',
                                  Delivery_Phase__c = '0 - Pre-Implementation Kick-off',
                                  Priority = 'Critical');
        insert testCase1;
        try{
            Case testCase2 = new Case(Related_Delivery_Opportunity__c = testOpp2.Id,
                                      Subject = 'Delivery - Test Opp',
                                      Delivery_Phase__c = '0 - Pre-Implementation Kick-off',
                                      Priority = 'Critical');
            insert testCase2;  
        } catch (DmlException e){
            String message = e.getMessage();
        }
        
    }  
}