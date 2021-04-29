@isTest
private class TestTriggerUpdateAccountTransactionDate {
    static testMethod void runTest() {
        
      Account acc=new Account();
      acc.Name='TestAccount';
      acc.ECN__C='429999';
      insert acc;
      
      TransactionalData__c tran=new TransactionalData__C();
      
      tran.Name='Test Tran';
      tran.ECN__C='429999';
      tran.LinkedAccount__c=acc.Id;
      tran.ReportDate__c=date.newInstance(2014, 08, 22);
      
      insert tran;
      
      tran.ReportDate__c=date.newInstance(2014, 08, 25);
      update tran;
      
    }
}