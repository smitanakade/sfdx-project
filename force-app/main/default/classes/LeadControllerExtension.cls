public class LeadControllerExtension {

    private final Lead lead;

    // Constructor initializes the private member variable lead by using the getRecord method
    // from the standard controller.
    public LeadControllerExtension(ApexPages.StandardController stdController) {
        this.lead = (Lead)stdController.getRecord();
        
        Lead theLead = [Select LeadSource From Lead Where Id = :ApexPages.currentPage().getParameters().get('id')];

        List<CampaignMember> campaigns = [Select Id from CampaignMember where LeadId = :theLead.Id];
                
        if ((theLead.LeadSource == 'eNett Campaign' || theLead.LeadSource == 'Partner Campaign' || theLead.LeadSource == 'Industry Event') && campaigns.Size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Please link this Lead to a Campaign.'));      
        }            
    }
}