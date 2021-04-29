public with sharing class OpportunityControllerExtension {
    
    public OpportunityControllerExtension(ApexPages.StandardController stdController) {
        
    	String Message;
        Message = '';

        Opportunity theOpportunity = [Select LeadSource, CampaignId, Country__c From Opportunity where Id = :stdController.getRecord().Id];
        if ((theOpportunity.LeadSource == 'eNett Campaign' || theOpportunity.LeadSource == 'Partner Campaign' || theOpportunity.LeadSource == 'Industry Event') && string.IsBlank(theOpportunity.CampaignId)) {
			Message = 'Please link this Opportunity to a Campaign.';
        }            

// *** SF-1366 Removed reference to Category 1 Country
//		if (CountryMappings__c.getInstance(theOpportunity.Country__c).Category_1_Country__c == false) {
//			if (String.isBlank(Message)) {
//				Message = 'The Country associated with this Opportunity is not a Category 1 Country and therefore registration cannot be processed.'; }
//			else {
//				Message = 'This Opportunity is not linked to a Campaign and is not associated with a Category 1 Country.';
//			}
//        }

        if (String.isNotBlank(Message)) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Message));

    }
}