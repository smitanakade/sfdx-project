@isTest
public class RemoveProductTest {
    @isTest static void RemoveProductFromAccountTest(){
        
        // Data setup
        
        LIST<RemoveProduct.RemoveProductActionRequest> requests = new LIST<RemoveProduct.RemoveProductActionRequest>();
        // Request 1
        RemoveProduct.RemoveProductActionRequest request1 = new RemoveProduct.RemoveProductActionRequest();
        Account a1 = new Account(Name = 'testAccount1',
                                 eNett_Products__c = 'VANs');
        insert a1;
        request1.accountId = a1.Id;
        request1.productName = 'VANs';
        
        requests.add(request1);
        
        // Request 2
        RemoveProduct.RemoveProductActionRequest request2 = new RemoveProduct.RemoveProductActionRequest();        
        Account a2 = new Account(Name = 'testAccount2',
                                 eNett_Products__c = 'VANs; eNett EFT');
        insert a2;
        request2.accountId = a2.Id;
        request2.productName = 'VANs';        
        
        requests.add(request2);
        
        // Perform test
        Test.startTest();
        RemoveProduct.RemoveProductFromAccount(requests);
        Test.stopTest();
        
        // Verify
        Account checkAcct = [SELECT Id, eNett_Products__c FROM Account WHERE Id =: a1.Id];
        System.assertEquals(null, checkAcct.eNett_products__c);
        
        Account checkAcct2 = [SELECT Id, eNett_Products__c FROM Account WHERE Id =: a2.Id];
        System.assertEquals('eNett EFT', checkAcct2.eNett_products__c);
    }
}