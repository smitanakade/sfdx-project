public class PopUpDialog_JournalExts {

    public class deleteJournal extends PopUpDialogController.contExt {

        private Journal__c jnl {get; set;}
        
        public deleteJournal(Id recId) {
            jnl = loadLead(recId);
        }    
            
        public override String runProcess() {
            String return_URL = jnl.Registration__c;
            delete jnl;
            return return_URL;
        }
  
        public override String showConfirmMsg() {
            return 'You are about to delete this journal entry.  Are you sure?';
        }

        public override String runValidation() {
            if (jnl.Read_Only__c) {
                return 'Journal records can only be deleted during Due Diligence.';
             }
            return null;
        }

    }    
    
    public static Journal__c loadLead(Id recId) {
        Journal__c jnl;
        jnl = [SELECT Id, Read_Only__c, Registration__c FROM Journal__c WHERE Id = :recId];
        return jnl;
    }
    
}