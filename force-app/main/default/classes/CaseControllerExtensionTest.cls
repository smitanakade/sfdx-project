@isTest public class CaseControllerExtensionTest {
    @isTest static void testRun(){
        //Data Setup
        Case testCase = eNettTestUtility.createCase();
        testCase.Origin = 'EMail';
        testCase.Priority = '-- None --';
        update testCase;
        
        //Perform Test
        test.startTest();
        ApexPages.currentPage().getParameters().put('id', testCase.Id);
        CaseControllerExtension testCtrl = new CaseControllerExtension(new ApexPages.StandardController(testCase));
        testCtrl.hasMessages();
        test.stopTest();
        
        //Verify Test
        Case theCase = [SELECT Id FROM Case WHERE Id =: testCase.Id];
        Boolean hasMessages = false;
        ApexPages.Message[] messages = ApexPages.getMessages();
        for (ApexPages.Message message : messages){
            if (message.getSummary() == 'The Customer Service Prioity cannot be "-- None --", please change this to a valid option.'){
                hasMessages = true;
            }
        }
        System.assert(hasMessages);
    }
}