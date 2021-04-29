public class PopUpDialog_DirectorExts {

    public class deactivate extends PopUpDialogController.contExt {

        private Director__c dir {get; set;}

        public deactivate(Id recId) {
            dir = new Director__c(Id = recId);
        }       
        
        public override String runProcess() {
            dir.Active__c = false;
            update dir;
            return null;
        }
  
        public override String showConfirmMsg() {
            return 'You are about to deactivate the Director for this Registration. Are you sure you want to continue?';
        }

    }    
    
    public class newDirector extends PopUpDialogController.contExt {

        private Registration__c reg {get; set;}

        public newDirector(Id recId) {
            reg = [SELECT Id, Name, Business_Type__c FROM Registration__c WHERE Id = :recId];
        }

        public override String runValidation() {
            if (reg.Business_Type__c == 'Partnership' || reg.Business_Type__c == 'Sole Trader')
                return 'Cannot add a director to this business type';
            return null;
        }

        public override String runProcess() {
            String return_URL = null;
            ObjectReferenceIds__c objRef = ObjectReferenceIds__c.getOrgDefaults();
            return_URL = '/' + objRef.Director_Object_Prefix__c;
            return_URL += '/e?CF' + objRef.Director_Active_Registration__c + '=' + reg.Name;
            return_URL += '&CF' + objRef.Director_Active_Registration__c + '_lkid=' + reg.Id;
            return_URL += '&CF' + objRef.Director_Registration__c + '=' + reg.Name;
            return_URL += '&CF' + objRef.Director_Registration__c + '_lkid=' + reg.Id;
            return_URL += '&retURL=/%2F' + reg.Id+ '&nooverride=1';
            return return_URL;
        }
 
        public override String showConfirmMsg() {
            return 'You are about to create a new director. Are you sure you want to continue?';
        }

    }    

}