public class PopUpDialog_CaseExts {

    public class closeLost extends PopUpDialogController.contExt {

        private Case cs {get; set;}
        
        public closeLost(Id regId) {
            cs = PopUpDialog_CaseExts.loadCase(regId);
        }    

        public override String runValidation() {
            if (cs.status == 'Closed/Lost Delivery') return 'You cannot close the delivery since it has already been closed.';
            return null;
        }
            
        public override String runProcess() {
            if (picklistSelection == 'None') throw new applicationException('You must select a reason to close the delivery.');
            cs.status = 'Closed/Lost Delivery';
            cs.Closed_Lost_Terminated_Reason__c = picklistSelection;
            update cs;
            return null;
        }
        
        public override String showConfirmMsg() {
            //return 'You are about to close this delivery as lost. Please select a reason from the picklist and press continue:';
            //return 'You have chosen the Close/Lost button on this delivery ticket.  Please select a reason from the list provided below.  The related Opportunity status will be set to Closed/Lost and the Won/Lost Reason field to the reason selected.';
            return 'You have chosen the Close/Lost button.  Please select a reason from the list below.  The related Opportunity status will be set to Closed/Lost and the Won/Lost Reason field to the reason selected.';            
        }
        
        public override List<SelectOption> getPicklistOptions() {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('None','--None--'));
            options.add(new SelectOption('Other','Other'));
            options.add(new SelectOption('Client unresponsive/Never transacted','Client unresponsive/Never transacted'));
            options.add(new SelectOption('Client not ready','Client not ready'));
            options.add(new SelectOption('VANs does not meet clients needs/expectations','VANs does not meet clients needs/expectations'));
            options.add(new SelectOption('No pilot customer','No pilot customer'));
            options.add(new SelectOption('Client does not want to pay API fee','Client does not want to pay API fee'));
            
            return options;
        }        
  
    }    


    public class Terminate extends PopUpDialogController.contExt {

        private Case cs {get; set;}
        
        public Terminate(Id regId) {
            cs = PopUpDialog_CaseExts.loadCase(regId);
        }    
            
        public override String runProcess() {
            cs.status = 'Terminate';
            cs.Closed_Lost_Terminated_Reason__c = 'Change of Delivery Type';
            update cs;
            
            if (cs.Related_Delivery_Opportunity__c != null) {
                Opportunity nwOpp = duplicateOpportunity(cs.Related_Delivery_Opportunity__c);
                insert nwOpp;
            }
            return null;
        }
        
        public override String showConfirmMsg() {
            return 'You have chosen to terminate this delivery ticket.  This will set the related Opportunity status to \'Closed/Lost\' and the Won/Lost Reason to \'Change of Delivery Type\'.  A new Opportunity will also be created and the name appended with the text \'- Opp 2\'.';
        }

    }
    
    public static Opportunity duplicateOpportunity(Id oppId) {
        Opportunity opp;
        LIST<Opportunity> oppList = [SELECT Name, AccountId, Product__c, Region__c, Country__c, 
                                     OwnerId, StageName, Type, Primary_Implementation_Contact__c, 
                                     Secondary_Implemantation_Contact__c, attainable_ttv_monthly__c, 
                                     VAN_currencies_top_3__c, Hours_Man_Effort_To_Date__c, CloseDate, 
                                     Duration_minus_Dormant_Time__c, Implementation_Start_Date__c, CurrencyIsoCode 
                                     FROM Opportunity WHERE Id = :oppId LIMIT 1];

        if (oppList.isEmpty()) {
            return null;
        } else {
            opp = oppList[0];
        }

        Opportunity newOpp = new Opportunity (
            Name = opp.Name + ' - Opp 2',
            AccountId = opp.AccountId,
            Product__c = opp.Product__c,
            Region__c = opp.Region__c,
            Country__c = opp.Country__c,
            OwnerId = opp.OwnerId,
            StageName = opp.StageName,
            Type = opp.Type,
            Primary_Implementation_Contact__c = opp.Primary_Implementation_Contact__c,
            Secondary_Implemantation_Contact__c = opp.Secondary_Implemantation_Contact__c,
            CurrencyIsoCode = opp.CurrencyIsoCode,
            attainable_ttv_monthly__c = opp.attainable_ttv_monthly__c,
            VAN_currencies_top_3__c = opp.VAN_currencies_top_3__c,
            Terminated_Delivery_Effort_Man_Hours__c = opp.Hours_Man_Effort_To_Date__c,
            CloseDate = opp.CloseDate,
            Terminated_Delivery_Duration_Days__c = opp.Duration_minus_Dormant_Time__c,
            Implementation_Start_Date__c = opp.Implementation_Start_Date__c);
        return newOpp;
    }

    
    public static Case loadCase(Id recId) {
        Case cs;
        cs = [SELECT Id, status, Related_Delivery_Opportunity__c
               FROM Case
               WHERE Id = :recId];
        return cs;
    }
    
    public class applicationException extends Exception {}

}