public class PopUpDialog_DDApprovalExts {

    public class approve extends PopUpDialogController.contExt {
        private Due_Diligence_Approval__c ddAppr {get; set;}
        Id userId;
        Boolean rightToApprove;
        
       
        public approve(Id recId) {
            ddAppr = PopUpDialog_DDApprovalExts.loadDDApproval(recId);
            DD_Config__c ddConfig = DD_Config__c.getInstance(UserInfo.getUserId());
            rightToApprove = ddConfig.Can_Approve_High_Risk_DD__c;
        }    
            
        public override String runValidation() {
            return null;
        }
   
        public override String showConfirmMsg() {
            return null;
        }
    
    }

    public static Due_Diligence_Approval__c loadDDApproval(Id recId) {
        Due_Diligence_Approval__c ddA;
        ddA = [SELECT Id, Submitted_By__c, Risk_Rating__c
               FROM Due_Diligence_Approval__c
               WHERE Id = :recId];
        return ddA;
    }

}