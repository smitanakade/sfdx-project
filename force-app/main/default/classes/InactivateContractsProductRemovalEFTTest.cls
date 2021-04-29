@isTest
public class InactivateContractsProductRemovalEFTTest {
    
    @isTest static void InactivateContractsProductRemovalEFTTest(){
        
    // Data setup
    List<Id> accIds = new List<Id>();
    Account acct = new Account (Name = 'testAccount');
    insert acct;
    accIds.add(acct.Id);
     
    eNett_Contract__c e = new eNett_Contract__c(Account_Name__c = acct.id,
                                               eNett_Product__c = 'eNett EFT');
    insert e;
    // Perform test
    Test.startTest();
    InactivateContractsProductRemoval_EFT.InactivateAccountContractsProductRemoval_EFT(accIds);    
    Test.stopTest();
        
    // Verify
    eNett_Contract__c e2 = [SELECT Id, Status__c FROM eNett_Contract__c WHERE Id = :e.Id ];
    System.assertEquals('Inactive',e2.Status__c);
    }
}