public class PopUpDialog_ProcessTaskExts {
    
    public class completeTask extends PopUpDialogController.contExt {
        
        private Process_Task__c pt {get; set;}
        
        public completeTask(Id recId) {
            pt = PopUpDialog_ProcessTaskExts.loadProcessTask(recId);
        }    
        
        public override String showConfirmMsg() {
            return 'Are you sure you wish to complete the task?'; // This should be null but VF page will need updating first to support this.
        }
        
        public override String runProcess() {
            String return_URL = null;
            pt.status__c = 'Completed';
            update pt;
            if (pt.Delivery_Ticket__c != null) {
                return_URL = pt.Delivery_Ticket__c;
            }
            return return_URL;
        }
        
        public override String runValidation() {
            if (pt.Estimated_Effort_Minutes__c == null || pt.Estimated_Effort_Minutes__c == 0) {
                return 'Please enter Estimated Effort Minutes for this task.';
            } else {
                return null;
            }
        }
        
    }
    
    public class completeInternalAccountContactTask extends PopUpDialogController.contExt {
        
        private Process_Task__c pt {get; set;}
        
        public completeInternalAccountContactTask(Id recId) {
            pt = PopUpDialog_ProcessTaskExts.loadProcessTask(recId);
        }    
        
        public override String showConfirmMsg() {
            return 'Are you sure you wish to complete the task?';
        }
        
        public override String runProcess() {
            String return_URL = null;
            pt.status__c = 'Completed';
            pt.AML_Contact_Creation__c = 'Completed';            
            update pt;
            if (pt.Account__c != null) return_URL = pt.Account__c;
            return return_URL;
        }
        
    }
    
    public class approveInternalTransactingAccount extends PopUpDialogController.contExt {
        
        private Process_Task__c pt {get; set;}
        
        public approveInternalTransactingAccount(Id recId) {
            pt = PopUpDialog_ProcessTaskExts.loadProcessTask(recId);
        }    
        
        public override String showConfirmMsg() {
            return 'You are about to approve the new Internal Account, press Continue or Cancel to abort.';
        }
        
        public override String runProcess() {
            String return_URL = null;
            pt.status__c = 'Completed';
            pt.Internal_Account_Approval__c = 'Approved';         
            update pt;
            if (pt.Account__c != null) return_URL = pt.Account__c;
            return return_URL;
        }
        
    }    
    
    public class completeOpportunityTask extends PopUpDialogController.contExt {
        
        private Process_Task__c pt {get; set;}
        
        public completeOpportunityTask(Id recId) {
            pt = PopUpDialog_ProcessTaskExts.loadProcessTask(recId);
        }    
        
        public override String runValidation() {
            if (pt.Contract_Type__c == 'Standard T&Cs' && !string.isblank(pt.Registration_Status__c) && pt.Registration_Status__c != 'Complete') {
                return 'The Registration data entry has not been completed. Please ensure Registration is complete prior to completing this task.';
            } else {
                return null;
            }
        }
        
        public override String showConfirmMsg() {
            if (pt.Contract_Type__c == 'Standard T&Cs' && !pt.Account__r.T_C_Completed__c) {
                return 'By proceeding with this action, this will automatically send an email to the Client with a link requesting them to select the Standard T&Cs contract acceptance checkbox. <br/><br/>Are you sure you want to proceed?';
            } else {
                return 'Are you sure you wish to complete the Opportunity Task?';
            }
        }
        
        public override String runProcess() {
            String return_URL = null;
            pt.status__c = 'Completed';
            update pt;
            if (pt.Opportunity__c!= null) {
                return_URL = pt.Opportunity__c;
            }
            return return_URL;
        }
    }  
    
    
    public class completeContractTask extends PopUpDialogController.contExt {
        
        private Process_Task__c pt {get; set;}
        
        public completeContractTask(Id recId) {
            pt = PopUpDialog_ProcessTaskExts.loadProcessTask(recId);
        }    
        
        public override String showConfirmMsg() {
            return 'Are you sure you wish to complete the Contract Task?';
        }
        
        public override String runProcess() {
            String return_URL = null;
            pt.status__c = 'Completed';
            update pt;
            if (pt.eNett_Contract__c != null) {
                return_URL = pt.eNett_Contract__c;
            }
            return return_URL;
        }
        
    }
    //SF-5269 11/10/2018 Jasmine - Create a method to approve 'Approve Account' task, this method only allows people who belong to 'Account Approval Queue' to approve this type of task
    public class approveApproveAccountTask extends PopUpDialogController.contExt {
        
        private Process_Task__c pt {get; set;}
        private Boolean isUserValid {get; set;}
        
        List<Group> accountApprovalQueue = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName ='Account_Approval_Queue' LIMIT 1];
        
        Map<Id, GroupMember> queueMember = new Map<Id, GroupMember>([SELECT UserOrGroupId FROM GroupMember WHERE GroupId =: accountApprovalQueue]);
        
        String currentUserId = UserInfo.getUserId();
        
        public override String showConfirmMsg() {
            return 'You are about to approve a new account. Enter the reason for approval if necessary.';
        }
        
        public approveApproveAccountTask(Id recId) {
            pt = PopUpDialog_ProcessTaskExts.loadProcessTask(recId);
        }    
        
        public override String runValidation() {
            //SF-5370 19/11/2018 Jasmine - Fix the issue where users are unable to approve process tasks whenin the Account Approval Queue
            //String message = null;
            String message = 'You do not have permission to approve this kind of process tasks. Please contact the administrator for assistance.';
            for (GroupMember gm: queueMember.values()){
                if (gm.UserOrGroupId == currentUserId){
                    isUserValid = true;
                    message = null;
                }
                //SF-5370 19/11/2018 Jasmine - Fix the issue where users are unable to approve process tasks whenin the Account Approval Queue
                /*else{
isUserValid = false;
System.debug('#####isUserValid: ' + isUserValid);
message = 'You do not have permission to approve this kind of process tasks. Please contact the administrator for assistance.';
}*/
            }
            return message;
        }
        
        public override String runProcess() {
            String return_URL = null;
            pt.status__c = 'Completed';
            pt.Internal_Account_Approval__c = 'Approved';
            //SF-5424 added approval reasons
            pt.Account_Decline_Reason__c = 'Approved -- ' + userTextInput;
            update pt;
            return_URL = pt.Id;
            return return_URL;
        }
        
        //SF-5424 Ronnie -- allow users to input approval reasons
        public override Boolean showInputTextField() {
            return true;
        }      
        
    }  
    
    //SF-5424 based on approveApproveAccountTask
    public class declineApproveAccountTask extends PopUpDialogController.contExt {
        
        private Process_Task__c pt {get; set;}
        private Boolean isUserValid {get; set;}
        
        List<Group> accountApprovalQueue = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName ='Account_Approval_Queue' LIMIT 1];
        
        Map<Id, GroupMember> queueMember = new Map<Id, GroupMember>([SELECT UserOrGroupId FROM GroupMember WHERE GroupId =: accountApprovalQueue]);
        
        String currentUserId = UserInfo.getUserId();
        
        public override String showConfirmMsg() {
            return 'You are about to decline a new account. Enter the reason for decline.';
        }
        
        public declineApproveAccountTask(Id recId) {
            pt = PopUpDialog_ProcessTaskExts.loadProcessTask(recId);
        }    
        
        public override String runValidation() {
            String message = 'You do not have permission to approve this kind of process tasks. Please contact the administrator for assistance.';
            for (GroupMember gm: queueMember.values()){
                if (gm.UserOrGroupId == currentUserId){
                    isUserValid = true;
                    message = null;
                }
            }
            return message;
        }
        
        public override String runProcess() {
            String return_URL = null;
            if (userTextInput == '')
                throw new applicationException('Reason cannot be blank.');
            
            pt.status__c = 'Completed';
            pt.Internal_Account_Approval__c = 'Declined';
            pt.Account_Decline_Reason__c = 'Declined -- ' + userTextInput;
            update pt;
            return_URL = pt.Id;
            return return_URL;
        }
        
        public override Boolean showInputTextField() {
            return true;
        }      
        
    }  
    
    public static Process_Task__c loadProcessTask(Id recId) {
        Process_Task__c prTask;
        prTask = [SELECT Id, Account__c, Estimated_Effort_Minutes__c, Delivery_Ticket__c, Contract_Type__c, Opportunity__c, eNett_Contract__c, Record_Type__c, Registration_Status__c, Account__r.T_C_Completed__c
                  FROM Process_Task__c
                  WHERE Id = :recId];
        return prTask;
    }
    
    public class applicationException extends Exception {}
    
}