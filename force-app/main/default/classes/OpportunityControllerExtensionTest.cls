@isTest public class OpportunityControllerExtensionTest {
	
    @isTest static void testRun(){
        
        //Data Setup
        Account testAcc = eNettTestUtility.createAccount('testAcc');
        Opportunity testOpp = new Opportunity(Name = 'testOpp',
                                              AccountId = testAcc.Id,
                                              StageName = 'Prospect',
                                              CloseDate = date.valueOf('2014-01-01'));
        insert testOpp;
        testOpp.LeadSource = 'Partner Campaign';
        update testOpp;
        
        //Perform Test
        test.startTest();
        ApexPages.currentPage().getParameters().put('id', testOpp.Id);
        OpportunityControllerExtension testCtrl = new OpportunityControllerExtension(new ApexPages.StandardController(testOpp));
        test.stopTest();
        
        //Verify Test
       	Opportunity verifyOpp = [SELECT Id FROM Opportunity WHERE Id = :testOpp.Id];
        ApexPages.Message[]  pageMessages = ApexPages.getMessages();
        Boolean messageFound = false;
        for (ApexPages.Message message : pageMessages){
            if (message.getSummary() == 'Please link this Opportunity to a Campaign.'){
                messageFound = true;
            }
        }
        System.assert(messageFound);
    }
}