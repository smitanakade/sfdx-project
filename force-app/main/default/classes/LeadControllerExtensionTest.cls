@isTest
public class LeadControllerExtensionTest {
	
    @isTest static void testRun(){
        //Data Setup
        Lead testLead = eNettTestUtility.createLead('test');
        testLead.LeadSource = 'eNett Campaign';
        update testLead;
        
        //Perform Test
        test.startTest();
        ApexPages.currentPage().getParameters().put('id', testLead.Id);
        LeadControllerExtension leadCtrl = new LeadControllerExtension(new ApexPages.StandardController(testLead));
        test.stopTest();
        
        //Verify Test
        Lead theLead = [SELECT Id FROM Lead WHERE Id = :testLead.Id];
        List<CampaignMember> testCampaigns = [Select Id from CampaignMember where LeadId = :theLead.Id];
        Boolean messageFound = false;
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        for (ApexPages.Message message : pageMessages){
            if (message.getSummary() == 'Please link this Lead to a Campaign.'){
                messageFound = true;
            }
        }
        System.assert(messageFound);
    }
}