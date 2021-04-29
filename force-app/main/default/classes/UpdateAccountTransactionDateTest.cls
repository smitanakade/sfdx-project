@isTest
public class UpdateAccountTransactionDateTest {
    @isTest static void LastTransactionNull() {
        
      Account acc = eNettTestUtility.createAccount('testAccount1');
      
      TransactionalData__c tran=new TransactionalData__C();
      
      tran.Name='testTran1';
      tran.ECN__C= acc.ECN__c;
      tran.LinkedAccount__c=acc.Id;
      tran.ReportDate__c=date.newInstance(2014, 08, 22);
      tran.DaySettledValue__c = 20000;
      insert tran;
      
      tran.ReportDate__c=date.newInstance(2014, 08, 25);
      update tran;
      
    }
}