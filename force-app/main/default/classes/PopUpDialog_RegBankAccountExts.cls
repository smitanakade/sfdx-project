public class PopUpDialog_RegBankAccountExts {

    public class deactivate extends PopUpDialogController.contExt {

        private Registration_Bank_Account__c rBA {get; set;}

        public deactivate(Id recId) {
            rBA = PopUpDialog_RegBankAccountExts.loadRegBankAccount(recId);
        }       
        
        public override String runProcess() {
            rBA.Active__c = false;
            update rBA;
            return null;
        }
  
        public override String showConfirmMsg() {
            return 'You are about to deactivate the Registration Bank Account for this Registration. Are you sure you want to continue?';
        }

    }
    
    public static Registration_Bank_Account__c loadRegBankAccount(Id recId) {
        Registration_Bank_Account__c regBA;
        regBA = new Registration_Bank_Account__c(id = recId);
        return regBA;
    }

}