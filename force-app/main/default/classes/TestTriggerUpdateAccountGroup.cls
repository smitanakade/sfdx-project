@isTest
private class TestTriggerUpdateAccountGroup {
    static testMethod void runTest() {
        
      Account_Group__c accGrp=new Account_Group__C();
      accGrp.Name='TestGroup';
      insert accGrp; 
      
      Account acc=new Account();
      acc.Name='TestAccount';
      acc.Account_Group__C=accGrp.Id;
      insert acc;
      
      acc.Due_Diligence_Completed__c=date.newInstance(2014, 08, 20);
      acc.Last_Transaction__c=date.newInstance(2014, 08, 22);
      update acc;  
    }
}