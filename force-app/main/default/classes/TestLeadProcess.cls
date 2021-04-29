@isTest
private class TestLeadProcess {

    static testMethod void LeadConversion() {
      List<Lead> leads = new List<Lead>();

      leads.add(new Lead( LastName='Mallard',FirstName='Jay',Company='Wingo Ducks',Phone='(707) 555-0328'));
      leads.add(new Lead( LastName='Platypus',FirstName='Ogden',Company='Denio Water Co.',Phone='(775) 555-1245'));
      
      LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
      List<Database.LeadConvert> leadsToConvert = new List<Database.LeadConvert>();
      
      List<Task> tasks = new List<Task>();
      List<Event> events = new List<Event>();

      for( Database.SaveResult saveResult : database.insert(leads, false)){
            system.assert(saveResult.isSuccess(), 'Failed to Save Lead: ' + saveResult);
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.ConvertedStatus = convertStatus.MasterLabel;
            lc.LeadId = saveResult.Id;
            lc.DoNotCreateOpportunity = true;
            leadsToConvert.add( lc );
         
      } 
      
      for( Database.SaveResult saveResult : database.insert(tasks, false)){
        system.assert(saveResult.isSuccess());
      }

      for( Database.SaveResult saveResult : database.insert(events, false)){
        system.debug( '******' + saveResult);
        system.assert(saveResult.isSuccess());
      }

      List<Id> accountIds = new List<Id>();
      /*for(Database.LeadConvertResult lcResult : Database.convertLead(leadsToConvert)){
         System.Assert(lcResult.isSuccess());

         //We should have an account id
         System.AssertNotEquals(null, lcResult.AccountId); 
         accountIds.add(lcResult.AccountId);

         //we should have a contact
         System.AssertNotEquals(null, lcResult.ContactId);
         
         //we WILL NEVER have an Opportunity as we created this with an Account trigger
         System.AssertEquals(null, lcResult.OpportunityId);
      }
      
      //We should have created the same number of opportunities
      List<Opportunity> opps = [Select Id, AccountId from Opportunity where AccountId in : accountIds];
      system.AssertEquals(leads.size(), opps.size());*/
    }
}