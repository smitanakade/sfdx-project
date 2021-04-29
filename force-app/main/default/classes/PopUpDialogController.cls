public with sharing class PopUpDialogController {

    public Boolean processRanSuccessfully {get; set;}    
    public Boolean showContinueButton {get; set;}
    public Boolean showCancelButton {get; set;}    
    public Boolean showInputTextField {get; set;}
    public Boolean showPicklist {get; set;}
    public Boolean vFOnly {get; set;}
    public String returnUrl {get; set;}
    public String tabStyle {get; set;}
    public List<SelectOption> PicklistOptions{get; set;}
    public String userTextInput 
    {
        get; 
        set {
            userTextInput = value;
            cr.setUserTextInput(value);
        }
    }
    public String SelectedOption
    {
        get;
        set {
            SelectedOption = value;
            cr.picklistSelected(value);
        }
    }
    
    DialogControllerInterface cR;
    
    public PageReference Cancel() {
        PageReference page = new PageReference(this.returnUrl);
        page.setRedirect(true);
        return page;
    }

    public PopUpDialogController() {
        String recId = ApexPages.CurrentPage().getParameters().get('Id');
        String validationMsg = ApexPages.CurrentPage().getParameters().get('validation_msg');
        String controllerExt = ApexPages.CurrentPage().getParameters().get('controllerExt');
        String vFOnlyParameter = ApexPages.CurrentPage().getParameters().get('VFonly');
        this.tabStyle = ApexPages.CurrentPage().getParameters().get('tabStyle');        
        this.returnUrl = ApexPages.CurrentPage().getParameters().get('retURL');
        
        cR = getControllerExtension(controllerExt, recId);
        
        if (cR == null && validationMsg == null) {
            validationMsg = 'Button incorrectly configured';
        }
        
        if (vFOnlyParameter != null && vFOnlyParameter.toLowerCase() == 'true') {
            this.vFOnly = true;
        } else {
            this.vFOnly = false;
        }

        showPicklist = false;
        showInputTextField = false;
        
        if (cR != null) {
            picklistOptions = cR.getPicklistOptions();
            if (picklistOptions != null) {
                showPicklist = true;
            }
        
            if (validationMsg == null) {
                validationMsg = cR.runValidation();
            }
        
            if (cR.showInputTextField()) {
                showInputTextField = true;
            }
        }
        
        if (String.isBlank(validationMsg)) {
            String confirmMsg = cR.showConfirmMsg();
            if (confirmMsg == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Running Process'));
                showContinueButton = false;
                showCancelButton = false;
                showPicklist = false;
                showInputTextField = false;
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, confirmMsg));
                showContinueButton = true;
                showCancelButton = true;
            }            
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, validationMsg));
            showContinueButton = false;
            showCancelButton = true;
            showPicklist = false;
            showInputTextField = false;
        }
    }
    
    public Pagereference runProcess() {

        PageReference returnPageRef = null;
        processRanSuccessfully = true;

        Savepoint sp = Database.setSavepoint();
        try {
            String retURL = cR.runProcess();
            if (retURL != null) this.returnUrl = retURL;
            if (this.vFOnly) returnPageRef = new PageReference('/' + this.returnUrl);
        } catch(Exception e) {
            Database.rollback(sp);
            ApexPages.addMessages(e);
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() + e.getStackTraceString()));
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An unexpected error occured.  Please contact the system administration for help.'));
            processRanSuccessfully = false;
            showContinueButton = false;
            showCancelButton = true;
            showPicklist = false;
            showInputTextField = false;
        }
        
        if (!processRanSuccessfully) returnPageRef = null;
        if (returnPageRef != null) returnPageRef.setRedirect(true);
        return returnPageRef;
    }
    
    public interface DialogControllerInterface
    {
        String runProcess();
        String runValidation();
        String showConfirmMsg();
        List<SelectOption> getPicklistOptions();
        void picklistSelected(String selectedOption);
        void setUserTextInput(String usrInput);
        Boolean showInputTextField();        
    }
    
    public virtual class contExt implements DialogControllerInterface {

        protected String userTextInput {get; set;}
        protected String picklistSelection {get; set;}

        public virtual String runProcess() {
            return null;
        }

        public virtual String runValidation() {
            return null;
        }

        public virtual String showConfirmMsg() {
            return null;
        }
        
        public virtual List<SelectOption> getPicklistOptions() {
            return null;
        }

        public void picklistSelected(String selectedOption) {
            picklistSelection = selectedOption;
        }

        public void setUserTextInput(String usrInput) {
            userTextInput = usrInput;
        }
       
        public virtual Boolean showInputTextField() {
            return false;
        }        
    }

    private DialogControllerInterface getControllerExtension (String extName, Id recId) {
        DialogControllerInterface contExt = null;

        // Registration Extensions                
        if (extName == 'Registration_completeRegistration') {
            contExt = new PopUpDialog_RegistrationExts.completeRegistration(recId);
        } else if (extName == 'Registration_startDD') {
            contExt = new PopUpDialog_RegistrationExts.startDD(recId);
        } else if (extName == 'Registration_escalate') {
            contExt = new PopUpDialog_RegistrationExts.escalate(recId);
        } else if (extName == 'Registration_decline') {
            contExt = new PopUpDialog_RegistrationExts.decline(recId);
        } else if (extName == 'Registration_completeDD') {
            contExt = new PopUpDialog_RegistrationExts.completeDD(recId);
        } else if (extName == 'Registration_onHold') {
            contExt = new PopUpDialog_RegistrationExts.onHold(recId);
        } else if (extName == 'Registration_sendRegToClient') {
            contExt = new PopUpDialog_RegistrationExts.sendRegToClient(recId);
        } else if (extName == 'Registration_reject') {
            contExt = new PopUpDialog_RegistrationExts.reject(recId);
        }
        
        // Account Extensions
        if (extName == 'Account_addProduct') {
            contExt = new PopUpDialog_AccountExts.addProduct(recId);
        } else if (extName == 'Account_removeProduct') {
            contExt = new PopUpDialog_AccountExts.removeProduct(recId);
        } else if (extName == 'Account_createAdditionalECNAccount') {
            contExt = new PopUpDialog_AccountExts.createAdditionalECNAccount(recId);
        } else if (extName == 'Account_deactivate') {
            contExt = new PopUpDialog_AccountExts.deactivateAccount(recId);
        } else if (extName == 'Account_reDD') {
            contExt = new PopUpDialog_AccountExts.reDD(recId);
        } 
        //SCS-5 04/02/2019 Jasmine - Suspend an active account
         else if (extName == 'Account_suspend'){
            contExt = new PopUpDialog_AccountExts.suspendAccount(recId);
        }
        //SCS-7 06/02/2019 Jasmine - Reactivate a suspended account
         else if (extName == 'Account_reactivate'){
            contExt = new PopUpDialog_AccountExts.reactivateAccount(recId);
        }

        // Lead Extensions        
        if (extName == 'Lead_convertLeadToAccount') {
            contExt = new PopUpDialog_LeadExts.convertLeadToAccount(recId);
        }

        // Beneficial Owner Extensions        
        if (extName == 'BeneficialOwner_deactivate') {
            contExt = new PopUpDialog_BeneficialOwnerExts.deactivate(recId);
        }

        // Director Extensions        
        if (extName == 'Director_deactivate') {
            contExt = new PopUpDialog_DirectorExts.deactivate(recId);
        } else if (extName == 'Director_newDirector') {
            contExt = new PopUpDialog_DirectorExts.newDirector(recId);
        }

        // Due Diligence Approval Extensions
        if (extName == 'DDApproval_approve') {
            contExt = new PopUpDialog_DDApprovalExts.approve(recId);
        }
        
        // Process Task Extensions
        if (extName == 'ProcessTask_completeTask') {
            contExt = new PopUpDialog_ProcessTaskExts.completeTask(recId);
        } else if (extName == 'ProcessTask_completeOpportunityTask') {
            contExt = new PopUpDialog_ProcessTaskExts.completeOpportunityTask(recId);
        } else if (extName == 'ProcessTask_completeContractTask') {
            contExt = new PopUpDialog_ProcessTaskExts.completeContractTask(recId);
        } else if (extName == 'ProcessTask_completeInternalAccountContactTask') {
            contExt = new PopUpDialog_ProcessTaskExts.completeInternalAccountContactTask(recId);
        } else if (extName == 'ProcessTask_approveInternalTransactingAccount') {
            contExt = new PopUpDialog_ProcessTaskExts.approveInternalTransactingAccount(recId);
        //SF-5269 11/10/2018 Jasmine - Create new extension for method 'approveApproveAccountTask'
        } else if (extName == 'ProcessTask_approveApproveAccountTask') {
            contExt = new PopUpDialog_ProcessTaskExts.approveApproveAccountTask(recId);
        //SF-5424 Ronnie -- Decline Approval Task
        } else if (extName == 'ProcessTask_declineApproveAccountTask') {
            contExt = new PopUpDialog_ProcessTaskExts.declineApproveAccountTask(recId);
        }
        
        // Registration Bank Account Extensions
        if (extName == 'RegBankAccount_deactivate') {
            contExt = new PopUpDialog_RegBankAccountExts.deactivate(recId);
        }

        // Opportunity Extensions
        if (extName == 'Opportunity_terminateOpportunity') {
            contExt = new PopUpDialog_OpportunityExts.terminateOpportunity(recId);
        }

        // Case Extensions
        if (extName == 'Case_closeLost') {
            contExt = new PopUpDialog_CaseExts.closeLost(recId);
        } else if (extName == 'Case_terminate') {
            contExt = new PopUpDialog_CaseExts.terminate(recId);
        }

        // DD Escalation Extensions
        if (extName == 'DDEscalation_resolve') {
            contExt = new PopUpDialog_DDEscalation.resolve(recId);
        }

        // Journal Extensions
        if (extName == 'Journal_delete') {
            contExt = new PopUpDialog_JournalExts.deleteJournal(recId);
        }
       
        return contExt;
    }
     
}