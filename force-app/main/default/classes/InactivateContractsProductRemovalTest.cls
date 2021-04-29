@isTest
public class InactivateContractsProductRemovalTest {
    
    @isTest static void InactiveContractTest(){
        
        // Data setup
        // List<eNett_Contract__c> testContractUpdateList = new List<eNett_Contract__c>();
        List<Id> accIds = new List<Id>();
        for (Integer i = 0; i< 5; i++){
            Account acct = new Account(Name = 'testAcct' + i);
            insert acct;
            accIds.add(acct.Id);
            eNett_Contract__c e = new eNett_Contract__c(Account_Name__c = acct.Id,
                                                        Status__c = 'Activated');
            insert e;
        }
        
        
        // Perform test
        Test.startTest();
        InactivateContractsProductRemoval.InactivateAccountContractsProductRemoval(accIds);
        Test.stopTest();
        
        // Verify 
    LIST<eNett_Contract__c> contracts = [SELECT Account_Name__c, Status__c, Contract_Termination_Reason__c, Contract_Stage__c 
                              FROM eNett_Contract__c WHERE Account_Name__c IN :accIds];
    for (Integer j =0; j < contracts.size(); j++){
       System.assertEquals('Inactive', contracts[j].Status__c);
       System.assertEquals('Contract deactivated due to product Removal.', contracts[j].Contract_Termination_Reason__c);
       System.assertEquals('9. Agreement not reached', contracts[j].Contract_Stage__c);       
    }
}
}