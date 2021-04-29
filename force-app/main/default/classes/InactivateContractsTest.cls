@isTest
public class InactivateContractsTest {
    @isTest static void InactivateContractsTest(){
    
    // Data setup
    LIST <Id> accIds = new LIST<Id>();
    for (Integer i = 0; i < 5; i++){
        Account acct = new Account(Name = 'testAccount' + i);
        insert acct;
        accIds.add(acct.Id);
        eNett_Contract__c e = new eNett_Contract__c(Account_Name__c = acct.Id);
        insert e;
    }
        
    // Perform test
    Test.startTest();
    InactivateContracts.InactivateAccountContracts(accIds);
    Test.stopTest();
        
    // Verify
    LIST<eNett_Contract__c> contracts = [SELECT Account_Name__c, Status__c, Contract_Termination_Reason__c, Contract_Stage__c 
                                         FROM eNett_Contract__c WHERE Account_Name__c IN :accIds];
    for(Integer j = 0; j < contracts.size(); j++){
        System.assertEquals('Inactive', contracts[j].Status__c);
        System.assertEquals('Contract deactivated due to Due Dilligence Declined.', contracts[j].Contract_Termination_Reason__c);
        System.assertEquals('9. Agreement not reached', contracts[j].Contract_Stage__c);
    }
    }
}