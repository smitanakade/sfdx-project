public class PopUpDialog_OpportunityExts {

    public class terminateOpportunity extends PopUpDialogController.contExt {

        private Opportunity opp {get; set;}
        
        public terminateOpportunity(Id regId) {
            opp = PopUpDialog_OpportunityExts.loadOpportunity(regId);
        }    

        public override String runValidation() {
            if (opp.StageName == '7. Closed/Lost') return 'You cannot terminate this Opportunity since it has already been closed.';
            return null;
        }
            
        public override String runProcess() {
            if (picklistSelection == 'None') throw new applicationException('You must select a reason for terminating the opportunity.');
            opp.StageName = '7. Closed/Lost';
            opp.Won_Lost_Reason__c = picklistSelection;
            update opp;
            return null;
        }
        
        public override String showConfirmMsg() {
            return 'You are about to Close/Lose the Opportunity. Ensure there are no Delivery tickets associated with this Opportunity.  To proceed, select a termination reason and press Continue:';
        }
        
        public override List<SelectOption> getPicklistOptions() {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('None','--None--'));
            options.add(new SelectOption('Bankruptcy','Bankruptcy'));
            options.add(new SelectOption('Change of Contract','Change of Contract'));
            options.add(new SelectOption('Change of Delivery Type','Change of Delivery Type'));
            options.add(new SelectOption('Client does not want to pay API fee','Client does not want to pay API fee'));
            options.add(new SelectOption('Client not ready','Client not ready'));
            options.add(new SelectOption('Client unresponsive/Never transacted','Client unresponsive/Never transacted'));
            options.add(new SelectOption('Customer Requires Credit','Customer Requires Credit'));
            options.add(new SelectOption('Duplicate Opportunity','Duplicate Opportunity'));
            options.add(new SelectOption('Failed DD','Failed DD'));
            options.add(new SelectOption('Funding issues','Funding issues'));
            options.add(new SelectOption('High risk vs GDV','High risk vs GDV'));
            options.add(new SelectOption('Lost to competitor','Lost to competitor'));
            options.add(new SelectOption('Non Travel','Non Travel'));
            options.add(new SelectOption('No pilot customer','No pilot customer'));
            options.add(new SelectOption('No response - DD','No response - DD'));
            options.add(new SelectOption('No response - Sales','No response - Sales'));
            options.add(new SelectOption('Product deactivation','Product deactivation'));
            options.add(new SelectOption('Stopped Using eNett','Stopped Using eNett'));
            options.add(new SelectOption('VANs_dont_meet_clients_needs_or_expectations','VANs don\'t meet clients\' needs/expectations'));   
            
            return options;
        }        
  
    }    
    
    public static Opportunity loadOpportunity(Id recId) {
        Opportunity opp;
        opp = [SELECT Id, StageName
               FROM Opportunity
               WHERE Id = :recId];
        return opp;
    }
    
    public class applicationException extends Exception {}

}