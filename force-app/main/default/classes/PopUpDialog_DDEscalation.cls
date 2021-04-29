public class PopUpDialog_DDEscalation {

    public class resolve extends PopUpDialogController.contExt {

        private Due_Diligence_Escalation__c ddEsc {get; set;}
        Id userId;
       
        public resolve(Id recId) {
            ddEsc = PopUpDialog_DDEscalation.loadDDEscalation(recId);
            userId = UserInfo.getUserId();
        }    
        
        public override String showConfirmMsg() {
            return 'Please enter the Escalation Resolution:';
        }

        public override String runProcess() {
            String return_URL = null;
            if (userTextInput == '')
                throw new applicationException('Escalation Resolution cannot be blank.');
            ddEsc.Resolved__c = true;
            ddEsc.Resolution__c = userTextInput;
            update ddEsc;
            if (ddEsc.Registration__c != null) {
                return_URL = ddEsc.Registration__c; 
            }
            return return_URL;
        }
        
        public override String runValidation() {
            if (ddEsc.Submitted_By__c == userId) { 
                return 'You cannot work on a Due Diligence Escalation that has been submitted by you.'; 
            } else if (ddEsc.OwnerId != userId) { 
                return 'Please reassign ownership to yourself to resolve the Due Diligence Escalation.';
            } else if (ddEsc.Resolved__c) {
                return 'This escalation record has already been resolved.';
            }
            return null;
        }
        
        public override Boolean showInputTextField() {
            return true;
        }

    }

    public static Due_Diligence_Escalation__c loadDDEscalation(Id recId) {
        Due_Diligence_Escalation__c ddE;
        ddE = [SELECT Id, Resolved__c, Submitted_By__c, OwnerId, Registration__c
               FROM Due_Diligence_Escalation__c
               WHERE Id = :recId];
        return ddE;
    }

    public class applicationException extends Exception {}
    
}