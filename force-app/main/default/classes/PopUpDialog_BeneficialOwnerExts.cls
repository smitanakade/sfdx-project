public class PopUpDialog_BeneficialOwnerExts {

    public class deactivate extends PopUpDialogController.contExt {

        private Beneficial_Owner__c benOwner {get; set;}

        public deactivate(Id recId) {
            benOwner = new Beneficial_Owner__c(Id = recId);
        }       
        
        public override String runProcess() {
            benOwner.Active__c = false;
            update benOwner;
            return null;
        }
  
        public override String showConfirmMsg() {
            return 'You are about to deactivate the Beneficial Owner for this Registration. Are you sure you want to continue?';
        }

    }

}