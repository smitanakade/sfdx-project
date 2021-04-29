@isTest
private class TEST_Trigger_PopulateLeadDetails {
    
    @isTest static void test_PopulateLeadDetails() {
    	
    	
    	insert new ReferrerCodes__c(Name = 'Agoda', ReferrerCode__c = 'Agoda');
    	insert new ReferrerCodes__c(Name = 'Travelport', ReferrerCode__c = 'Travelport');

        /***********************************************
            Test the Insert behaviour with Notes
        ***********************************************/

        // Setup a Lead with notes
        Lead theLead_Notes = new Lead(  Company = 'TestCompany1',
                                    LastName = 'TestLast1',
                                    FirstName = 'TestFirst1',
                                    Brand_Name__c = 'Test Brand1',
                                    LeadSource = 'Other',
                                    Country__c = 'Australia',
                                    Referrer_Name__c = 'Agoda',
                                    Lead_Notes__c = 'A Note'
                                );

        // Insert our Lead
        insert theLead_Notes;
        System.assert(theLead_Notes.Id != null, 'Lead not inserted.');


        /***********************************************
            Test the Insert behaviour without Notes
        ***********************************************/

        // Setup our Lead
        Lead theLead = new Lead(    Company = 'ZZZZCompany',
                                    LastName = 'ZZZZCompany',
                                    FirstName = 'TestFirst1',
                                    Brand_Name__c = 'Test Brand2',
                                    LeadSource = 'Other',
                                    Country__c = 'Australia',
                                    Referrer_Name__c = 'Agoda'
                                );

        // Insert our Lead
        insert theLead;
        System.assert(theLead.Id != null, 'Lead not inserted.');

        // Requery the Lead
        Lead chkLead = [Select  Id, 
                                Country__c, 
                                Region__c, 
                                Referrer_Name__c, 
                                Referrer_Code__c, 
                                Lead_Notes__c, 
                                Lead_Notes_History__c 
                        from Lead where Id = :theLead.Id];

        // Validate our Insert fields
        System.AssertNotEquals(null, chkLead.Referrer_Code__c, 'Lead Referrer Code not assigned.');


        /***********************************************
            Test the Update behaviour
        ***********************************************/

        // Save or initial values
        string oldReferrerCode = chkLead.Referrer_Code__c;
        string oldNotesHistory = chkLead.Lead_Notes_History__c;

        // Set the values for update
        chkLead.Country__c = 'United States';
        chkLead.Referrer_Name__c = 'Travelport';
        chkLead.Lead_Notes__c = 'Notes';

        // Update the Lead
        update chkLead;

        // Requery Lead and Validate fields
        Lead chkLeadAfter = [Select     Id, 
                                Country__c, 
                                Region__c, 
                                Referrer_Name__c, 
                                Referrer_Code__c, 
                                Lead_Notes__c, 
                                Lead_Notes_History__c 
                        from Lead where Id = :theLead.Id];

        System.Assert(chkLeadAfter.Referrer_Code__c <> null && chkLeadAfter.Referrer_Code__c <> oldReferrerCode, 'Lead ReferrerCode not updated on update of Lead.');
        System.AssertEquals(null, chkLeadAfter.Lead_Notes__c, 'Lead notes not cleared.');
        System.Assert(chkLeadAfter.Lead_Notes_History__c <> null && chkLeadAfter.Lead_Notes_History__c <> oldNotesHistory, 'Lead Notes History not updated on update of Lead.');


        /***********************************************
            Run another test for Update behaviour with 
            notes appended.
            Added for test coverage.
        ***********************************************/

        chkLeadAfter.Lead_Notes__c = 'MoreNotes';
        update chkLeadAfter;
    }
    
}