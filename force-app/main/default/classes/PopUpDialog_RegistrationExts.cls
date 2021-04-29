public class PopUpDialog_RegistrationExts {

    /*
    @author :Unknown, Arun Sivanesan
    
    @version : 2.0
    
    @update : Ticket PDS-5324
    
    @DateLastChanged : 23/10/2019
    
    */
    
    public static final Map<String, Id> rtMap;
    public static final Set<String> mandatoryFields;
    public static final Map<String, Schema.SObjectField> fieldMap;
    /*PDS-5324 - Changed ProfileID to set */
    public static Set<Id> amlProfileIds {get; private set;}
    /*PDS-5324 - Created a list item to add list of AML Profile names */
    public static List<string> AMLProfileNames = new List<string>();
    
    static {
        /*PDS-5324 -Start- Added list of AML Prolie Names */
        AMLProfileNames.add('AML User');
        AMLProfileNames.add('Optal AML CDD');
        /*PDS-5324 -End- Added list of AML Prolie Names */
        
        recTypesReg__c rT = recTypesReg__c.getInstance();
        rtMap = new Map<String, Id>{'On Hold' => rt.DD_On_Hold__c,
                                    'Awaiting Client' => rt.DD_Awaiting_Client__c,
                                    'Non Responsive'  => rt.DD_Non_Responsive__c,
                                    'Needs More Time' => rt.DD_Needs_More_Time__c};

        mandatoryFields = new Set<String>
            {'Trading_Name__c', 'Business_Type__c', 'Product__c',
             'Business_Tax_Number__c', 'Business_Number__c', 'Established_Year__c', 'Estimated_Annual_Transaction_Value__c',
             'Address_Line_1__c', 'City__c', 'State_Province__c', 'Postcode__c',
             'Country__c', 'RegBusiness_Country__c',
             'RegBusiness_Address_Line_1__c', 'RegBusiness_City__c', 'RegBusiness_State_Province__c', 'RegBusiness_Postcode__c',
             'First_Name__c', 'Last_Name__c', 'Email__c', 'Phone__c', 'Job_Title__c', 'Salutation__c',
             'CEO_CFO__c', 'CEO_CFO_Job_Role__c', 'CEO_CFO_First_Name__c', 'CEO_CFO_Last_Name__c', 'CEO_CFO_Date_of_Birth__c'};
             
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get('Registration__c');
        fieldMap = leadSchema.getDescribe().fields.getMap();
        
        /*PDS-5324 -Start - Extracted list of AML ProfileID's and added to Set */
        amlProfileIds = new Set<Id>();
        for (Profile pr : [SELECT Id FROM Profile WHERE Name IN : AMLProfileNames]) {
            amlProfileIds.add(pr.id);
        }
        /*PDS-5324 -End - Extracted list of AML ProfileID's and added to Set */       
    }

    public class sendRegToClient extends PopUpDialogController.contExt {

        private Registration__c reg {get; set;}

        public sendRegToClient(Id regId) {
            reg = PopUpDialog_RegistrationExts.loadRegistration(regId);
        }
        
        public override String runValidation() {
            if (string.isBlank(reg.Email__c)) {
                return 'Please enter an email address in the contact section before using this button.';
            }
            return null;
        }

        public override String runProcess() {
            reg.Registration_Type__c = 'External Registration';
            reg.Send_Reg_To_Client__c = true;
            update reg;
            return null;
        }
 
        public override String showConfirmMsg() {
            return 'Press continue to set the Registration type to External Registration and send an email to the client, otherwise press Cancel.';
        }

    }

    public class onHold extends PopUpDialogController.contExt {

        private Registration__c reg {get; set;}

        public onHold(Id regId) {
            reg = PopUpDialog_RegistrationExts.loadRegistration(regId);
        }
        
        public override String runValidation() {
            return null;
        }

        public override String runProcess() {
        
            // If already in Time-Out status => find existing time out record and set end date
            DD_Time_Out__c ddTO;
            if (rTMap.containskey(reg.DD_Status__c)) {
                LIST<DD_Time_Out__c> ddTOs = [SELECT Id, Time_Out_Type__c FROM DD_Time_Out__c ORDER BY CreatedDate Desc LIMIT 1];
                if (!ddTOs.isEmpty()) {
                    ddTO = ddTOs[0];
                    if (ddTO.Time_Out_Type__c == reg.DD_Status__c) {
                        ddTO.End_Date__c = Date.today();
                        update ddTo;
                    }
                }
            }

            // Update Reg
            reg.recordTypeId = rtMap.get(picklistSelection);
            reg.ownerId = UserInfo.getUserId();
            reg.DD_Status__c = picklistSelection;
            update reg;

            // Create new DD Time Out record
            DD_Time_Out__c ddTO2;
            ddTO2 = new DD_Time_Out__c();
            ddTO2.Start_Date__c = Date.today();
            ddTO2.Time_Out_Type__c = picklistSelection;
            ddTO2.Registration__c = reg.Id;
            if (picklistSelection == 'On Hold') {  // Note: this needs to happen after the reg update which will trigger the KPI refresh
                ddTO2.BH_Start_Value__c = reg.BH_OnHold__c == null ? 0 : reg.BH_OnHold__c;
            } else if (picklistSelection == 'Awaiting Client') {
                ddTO2.BH_Start_Value__c = reg.BH_AwaitingClient__c == null ? 0 : reg.BH_AwaitingClient__c;
            } else if (picklistSelection == 'Needs More Time') {
                ddTO2.BH_Start_Value__c = reg.BH_NeedsMoreTime__c == null ? 0 : reg.BH_NeedsMoreTime__c;
            } else if (picklistSelection == 'Non Responsive') {
                ddTO2.BH_Start_Value__c = reg.BH_NonResponsive__c == null ? 0 : reg.BH_NonResponsive__c;
            }

            if (reg.Account__c != null && reg.Account__r.Reference_Registration__c != null)
                ddTo2.DD_Revision__c = reg.Account__r.Reference_Registration__r.DD_Revision__c;
            insert ddTo2;
            
            // Update Account DD Status            
            if (reg.Account__c != null) {
                Account acc = new Account(id = reg.Account__c);
                acc.dd_status__c = picklistSelection;
                update acc;
            }
            return null;
        }
 
        public override String showConfirmMsg() {
            return 'Please select an On Hold type:';
        }

        public override List<SelectOption> getPicklistOptions() {
            List<SelectOption> options = new List<SelectOption>();
            for (String s : rtMap.keyset()) {
                options.add(new SelectOption(s, s));
            }
            return options;
        }

    }
   
    public class completeRegistration extends PopUpDialogController.contExt {

        private String agreementType {get; set;}
        private String regType {get; set;}
        private Registration__c reg {get; set;}
        private final Set<String> validAgreementTypes = new Set<String> {'Affiliate', 'Undefined', 'Standard T&Cs', 'Service Provider'};
        private Boolean allowedProfile = false;
       
        public completeRegistration(Id regId) {
            reg = PopUpDialog_RegistrationExts.loadRegistration(regId);
            agreementType = reg.Agreement_Type__c;
            regType = reg.Registration_Type__c;
            
            /*PDS-5324 -Check AML Names in List object created before */
            for (Profile pr : [SELECT Name FROM Profile WHERE Id =:UserInfo.getProfileId() AND (Name IN : AMLProfileNames  OR Name LIKE '%System%Admin%') LIMIT 1]) {
                allowedProfile = true;
            }            
        }    
            
        public override String runProcess() {
            LIST<String> leadConvertErrMsgs = new LIST<String>();
            
            if (agreementType == 'Affiliate') {
                reg.Registration_Status__c = 'Complete';
                update reg;
            } else if (agreementType == 'Undefined' || agreementType == 'Standard T&Cs' || agreementType == 'Service Provider') {
                if (regType == 'External Registration' && agreementType != 'Service Provider') {
                    if (reg.Account__c == null) {
                        Lead ld = new Lead();
                        ld.id = reg.Lead__c;
                        ld.Registration_Type__c = 'Internal Registration';
                        ld.Contract_Type__c = 'Undefined';
                            
                        update ld;
                                            
                        // Convert the lead to an Account and Contact.
                        leadConvertErrMsgs = LeadUtility.ConvertLead(new LIST<Id>{reg.Lead__c});
                    }
                    
                    reg.Registration_Status__c = 'Complete'; 
                    update reg;

                } else {
                    reg.Registration_Status__c = 'Complete'; 
                    if (reg.product__c != null && reg.product__c.contains('eNett EFT') && !reg.product__c.contains('VANs'))
                        reg.Send_TC_to_Client__c = true;
                    update reg; 

                    // Convert the lead to an Account and Contact.
                    //leadConvertErrMsgs = LeadUtility.ConvertLead(new LIST<Id>{reg.Lead__c});
                }
                if (!leadConvertErrMsgs.isEmpty()) {
                    throw new applicationException('Lead conversion error');
                }
            }
            return null;
        }

        public override String runValidation() {        
            String validationMsg = null;
            String mandatoryValidationResult = runMandatoryFieldValidation();
                    
            if (reg.product__c != null && reg.product__c.contains('VANs') && !allowedProfile) {
                return 'Only AML Users can use this button if the VANs product is selected.';
            } else if (Reg.VAN_Bank_Account_Validation_Error__c) {
                validationMsg = 'Before completing registration, you must have an active Funding account.';
            } else if (Reg.EFT_Bank_Account_Validation_Error__c) {
                validationMsg = 'Before completing registration, you must have an active Billing, Payable and Receivable account.';
            } else if (Reg.Beneficial_Owner_Validation_Error__c) {
                validationMsg = 'At least one Beneficial Owner is required for this business type.';
            } else if (Reg.Director_Validation_Error__c) {
                validationMsg = 'At least one Director is required for this business type.';
            } else if ((agreementType == 'Standard T&Cs' || agreementType == 'Undefined') && String.isBlank(Reg.Email__c)) {
                validationMsg = 'Please enter an email address before continuing.';
            } else if (string.isBlank(agreementType)) {
                validationMsg = 'Please enter the Agreement Type before continuing.';
            } else if (!validAgreementTypes.contains(agreementType)) {
                validationMsg = 'Please enter a valid Agreement Type before continuing.';
            } else if (mandatoryValidationResult != null) {
                validationMsg = mandatoryValidationResult;
            }
          
            return validationMsg;
        }
        
        public String runMandatoryFieldValidation() {
            String validationMessage = null;
            Map<String, Object> populatedFieldMap = reg.getPopulatedFieldsAsMap();
            
            Set<String> blankFields = new Set<String>();

            for (String fieldAPIname: mandatoryFields) {
                if (!populatedFieldMap.containskey(fieldAPIname) && fieldMap.containskey(fieldAPIname)) {
                    blankFields.add(fieldMap.get(fieldAPIname).getDescribe().getLabel());
                }
            }
            
            if (!blankFields.isEmpty()) {
                validationMessage = 'The following mandatory fields cannot be blank: <ul>';
                for (String flabel : blankFields) {
                    validationMessage += '<li>' + flabel + '</li>';
                }
                validationMessage += '</ul>'; 
            }
    
            return validationMessage;
        }
        
        public override String showConfirmMsg() {
            String confirmMsg = null;
            if (agreementType == 'Affiliate') {
                confirmMsg = 'You are about to set the Registration Status to \'Complete\'. \n\nAre you sure you want to continue?\n\n';
                } else {
                    //confirmMsg = 'You are about to set the Registration Status to \'Complete\'. \n\nThis will also convert the associated Lead to a prospect Account and allow for the Due Diligence process to commence. \n\nAre you sure you want to continue?\n\n';
                    confirmMsg = 'You are about to set the Registration Status to \'Complete\'. \n\nAre you sure you want to continue?\n\n';
                }

            return confirmMsg;
        }

    }

    public class startDD extends PopUpDialogController.contExt {

        private Registration__c reg {get; set;}
        private Boolean allowedProfile = false;

        public startDD(Id regId) {
            reg = PopUpDialog_RegistrationExts.loadRegistration(regId);
            
            /*PDS-5324 -Check AML profile Names in List object created before */
            for (Profile pr : [SELECT Name FROM Profile WHERE Id =:UserInfo.getProfileId() AND (Name IN : AMLProfileNames OR Name LIKE '%System%Admin%') LIMIT 1]) {
                allowedProfile = true;
            }
        }
        
        public override String runProcess() {
            reg.DD_Status__c = 'In Progress';
            update reg;
            return null;
        }

        public override String runValidation() {
            if (reg.product__c != null && reg.product__c.contains('VANs') && !allowedProfile) {
                return 'Only AML Users can use this button if the VANs product is selected.';
            } else if (Reg.DD_Status__c != 'New') {
                return 'Please review the current status of the Due Diligence. You can only set to \'In Progress\' from \'New\'.';
            } else {
                return null;
            }
        }
   
        public override String showConfirmMsg() {
            return 'This will set the Status to \'In Progress\' and initiate KPI timers. Are you sure you want to continue?';
        }

    }

    public class escalate extends PopUpDialogController.contExt {

        private Registration__c reg {get; set;}
       
        public escalate(Id regId) {
            reg = PopUpDialog_RegistrationExts.loadRegistration(regId);
        }    
            
        public override String runProcess() {
            if (!String.isblank(userTextInput)) {
                reg.DD_Status__c = 'Referred';
                reg.Refer_Reason__c = userTextInput;
                reg.Escalated_To__c = null;
                update reg;
            } else {
                throw new applicationException('No refer reason provided.');
            }
            return null;
        }

        public override String runValidation() {        
            String validationMsg = null;
            if (reg.DD_Status__c == 'Referred') {
                validationMsg = 'The Due Diligence has already been referred.';
            } else if (reg.DD_Status__c != 'In Progress') {
                validationMsg = 'The Due Diligence can only be set to Referred if it is In Progress.';
            }
            return validationMsg;
        }
   
        public override String showConfirmMsg() {
            return 'Please enter the Referral Reason';
        }
        
        public override Boolean showInputTextField() {
            return true;
        }

    }
    
    public class decline extends PopUpDialogController.contExt {

        private Registration__c reg {get; set;}
       
        public decline(Id regId) {
            reg = PopUpDialog_RegistrationExts.loadRegistration(regId);
        }    
            
        public override String runProcess() {
            reg.DD_Status__c = 'DD Declined';
            reg.declined_reason__c = picklistSelection;
            update reg;
            return null;
        }

        public override String runValidation() {        
            if (reg.DD_Status__c != 'In Progress') {
                return 'The Due Diligence can only be set to Declined if it is In Progress.';
            } else {
                return null;
            }
        }
   
        public override String showConfirmMsg() {
            return 'You are about to decline this Due Diligence. Please select a decline reason:';
        }
        
        public override List<SelectOption> getPicklistOptions() {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('Risk', 'Risk'));
            options.add(new SelectOption('DD Not Met', 'DD Not Met'));
            options.add(new SelectOption('DD Not Provided', 'DD Not Provided'));
            options.add(new SelectOption('Not Interested', 'Not Interested'));
            options.add(new SelectOption('Competitor', 'Competitor'));
            options.add(new SelectOption('Language', 'Language'));
            options.add(new SelectOption('Not Travel', 'Not Travel'));          
            return options;
        }        

    }
    
    public class completeDD extends PopUpDialogController.contExt {

        private Registration__c reg {get; set;}
       
        public completeDD(Id regId) {
            reg = PopUpDialog_RegistrationExts.loadRegistration(regId);
        }    
            
        public override String runProcess() {
            if (reg.Risk_Rating_Review_Required__c) {
                reg.DD_Status__c = 'Referred'; 
            } else {
                reg.DD_Status__c = 'Awaiting Approval'; 
            }
            update reg;
            return null;
        }

        public override String runValidation() {
        
            String mandatoryValidationResult = runMandatoryFieldValidation();

            if (reg.DD_Status__c != 'In Progress') {
                return 'The Due Diligence can only be set to Completed if it is In Progress.';
            } else if (reg.DD_Checkboxes_incomplete__c) {
                return 'Please complete the Due Diligence Checklist section before you can Complete the Due Diligence.';
            } else if (reg.Principal_Signatory_Validation_Error1__c) {
                return 'A verification record with Evidence type of Principal Signatory and document type of photo ID is required.';
            } else if (reg.Principal_Signatory_Validation_Error2__c) {
                return 'Please attach a supporting document against each verification record on the registration.';
            } else if (mandatoryValidationResult != null) {
                return mandatoryValidationResult;
            } else {
                return null;
            }
        }
        

        public String runMandatoryFieldValidation() {
            String validationMessage = null;
            Map<String, Object> populatedFieldMap = reg.getPopulatedFieldsAsMap();
            Set<String> blankFields = new Set<String>();

            for (String fieldAPIname: mandatoryFields) {
                if (!populatedFieldMap.containskey(fieldAPIname) && fieldMap.containskey(fieldAPIname)) {
                    blankFields.add(fieldMap.get(fieldAPIname).getDescribe().getLabel());
                }
            }
            
            if (!blankFields.isEmpty()) {
                validationMessage = 'The following mandatory fields cannot be blank: <ul>';
                for (String flabel : blankFields) {
                    validationMessage += '<li>' + flabel + '</li>';
                }
                validationMessage += '</ul>'; 
            }
    
            return validationMessage;
        }        
   
        public override String showConfirmMsg() {
            String confirmMsg = null;
            if (reg.Risk_Rating_Review_Required__c) {
                confirmMsg = 'The risk rating for this account is High, to change the risk rating, the application must be referred. Would you like to refer this application?';
            } else {
                confirmMsg = 'Are you sure you wish to complete the Due Diligence?';
            }

            return confirmMsg;
        }

    }    

    public class reject extends PopUpDialogController.contExt {

        private Registration__c reg {get; set;}
        private Boolean allowedProfile = false;        
        
        public reject(Id regId) {
            reg = PopUpDialog_RegistrationExts.loadRegistration(regId);
            
            /*PDS-5324 -Check AML Profile Names in List object created before */
            for (Profile pr : [SELECT Name FROM Profile WHERE Id =:UserInfo.getProfileId() AND (Name IN : AMLProfileNames OR Name LIKE '%System%Admin%') LIMIT 1]) {
                allowedProfile = true;
            }
            for (PermissionSetAssignment pSA : [SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId= :UserInfo.getUserId() AND PermissionSet.Name = 'EFT_Due_Diligence' LIMIT 1]) {
                allowedProfile = true;
            }
        }

        public override String runValidation() {
            if (!allowedProfile) {
                return 'Only AML Users can use this button.';
            } else if (reg.Registration_Status__c != 'New' && reg.Registration_Status__c != 'In Progress') {
                return 'This button can only be used for new registrations.';
            }
            return null;
        }

        public override String runProcess() {
            if (picklistSelection == 'None') throw new applicationException('You must select a reason to reject the registration.');
            reg.Registration_Status__c = picklistSelection;
            update reg;
            return null;
        }
    
        public override String showConfirmMsg() {
            return 'You are about to reject this registration. Please select a rejection reason';
        }

        public override List<SelectOption> getPicklistOptions() {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('None','--None--')); 
            options.add(new SelectOption('Rejected - Non-responsive','Non-responsive'));
            options.add(new SelectOption('Rejected - Spam/test application','Spam/test application'));
            options.add(new SelectOption('Rejected - Application N/A','Application N/A'));
            return options;
        }
    }

    public class applicationException extends Exception {}

    public static Registration__c loadRegistration(Id regId) {
        Registration__c reg;
        reg = [SELECT Id, Account__c, Agreement_Type__c, Email__c, Lead__c, Sector__c, VAN_Bank_Account_Validation_Error__c, EFT_Bank_Account_Validation_Error__c,
               Account__r.Reference_Registration__r.DD_Revision__c, Product__c, Registration_Status__c,
               Beneficial_Owner_Validation_Error__c, Director_Validation_Error__c, Registration_Type__c, DD_Status__c, Declined_Reason__c,
               DD_Checkboxes_incomplete__c, Principal_Signatory_Validation_Error1__c, Principal_Signatory_Validation_Error2__c, Risk_Rating_Review_Required__c,
               Trading_Name__c, Business_Type__c, Purpose_of_VAN_Account__c,
               Address_Line_1__c, Address_Line_2__c, City__c, State_Province__c, Postcode__c, Country__c, RegBusiness_Country__c,           
               RegBusiness_Address_Line_1__c, RegBusiness_Address_Line_2__c, RegBusiness_City__c, RegBusiness_State_Province__c, RegBusiness_Postcode__c,
               Business_Tax_Number__c, Business_Number__c, Established_Year__c,
               First_Name__c, Last_Name__c, Job_Role__c, Job_Title__c, Salutation__c, Estimated_Annual_Transaction_Value__c,
               Phone__c, CEO_CFO__c, CEO_CFO_Job_Role__c, CEO_CFO_First_Name__c, CEO_CFO_Last_Name__c, CEO_CFO_Date_of_Birth__c, 
               BH_OnHold__c, BH_AwaitingClient__c, BH_NeedsMoreTime__c, BH_NonResponsive__c
               FROM Registration__c
               WHERE Id = :regId];
        return reg;
    }

}