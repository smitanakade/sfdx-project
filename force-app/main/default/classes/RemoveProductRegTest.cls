@isTest
public class RemoveProductRegTest {
    @isTest static void RemoveProductFromRegTest(){
        
        // Data setup
        LIST<RemoveProductReg.RemoveProductActionRequest> requests = new LIST<RemoveProductReg.RemoveProductActionRequest>();
        
        // Request 1
        RemoveProductReg.RemoveProductActionRequest request1 = new RemoveProductReg.RemoveProductActionRequest();
        Registration__c reg = eNettTestUtility.createRegistration('compName');
        request1.RegId = reg.Id;
        request1.productName = 'VANs';
        requests.add(request1);
        
        // Request 2
        RemoveProductReg.RemoveProductActionRequest request2 = new RemoveProductReg.RemoveProductActionRequest();
        Registration__c reg2 = eNettTestUtility.createRegistration('compName2');
        request2.RegId = reg2.Id;
        request2.productName = 'VANs';
        requests.add(request2);
        
        // Test perform
        Test.startTest();
        RemoveProductReg.RemoveProductFromReg(requests);
        Test.stopTest();
        
        // Verify
        Map<Id,Registration__c> regMap = new Map<Id,Registration__c>([SELECT Id,product__c FROM Registration__c WHERE Id = : reg.Id OR Id =: reg2.Id]);
        System.assertEquals('eNett EFT', regMap.get(reg.Id).product__c);
        System.assertEquals('eNett EFT', regMap.get(reg2.Id).product__c); 
    }
}