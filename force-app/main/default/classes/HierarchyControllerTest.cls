@isTest public class HierarchyControllerTest {
    @isTest static void testRun(){
        //Data Setup
        Registration__c testReg = eNettTestUtility.createRegistration('testComp');
        Beneficial_Owner__c testBO = eNettTestUtility.createBeneficialOwner(testReg.Id);
        
        //Test Perform
        test.startTest();
        HierarchyController.loadBenHier(testReg.Id);
        test.stopTest();
        
        //Verify Test
        System.assertEquals(1, [SELECT Id FROM Beneficial_Owner__c WHERE Registration__c =: testReg.Id].size());
    }
}