public class PopUpDialog_AccountExts {
    
    /*
    @author :Unknown, Arun Sivanesan
    
    @version : 2.0
    
    @update : Ticket PDS-5324
    
    @DateLastChanged : 23/10/2019
    
    */
    
    
    public static Id serviceL2RoleId {get; private set;}
    /*PDS-5324 - Changed ProfileID to set */
    public static Set<Id> amlProfileIds {get; private set;}
    public static Set<Id> systemAdminProfileIds {get; private set;}
    /*PDS-5324 - Created a list item to add list of AML Profile names */
    public static List<string> AMLProfileNames = new List<string>();
    
    static {
        /*PDS-5324 -Start- Added list of AML Prolie Names */
        AMLProfileNames.add('AML User');
        AMLProfileNames.add('Optal AML CDD');
        /*PDS-5324 -End- Added list of AML Prolie Names */
        
        for (UserRole ur : [SELECT Id FROM UserRole WHERE DeveloperName LIKE '%Service%Level_2%' LIMIT 1]) {
            serviceL2RoleId = ur.id;
        }
        /*PDS-5324 -Start - Extracted list of AML ProfileID's and added to Set */
        amlProfileIds = new Set<Id>();
        for (Profile pr : [SELECT Id FROM Profile WHERE Name IN : AMLProfileNames]) {
            amlProfileIds.add(pr.id);
        }
        /*PDS-5324 -End - Extracted list of AML ProfileID's and added to Set */
                
        systemAdminProfileIds = new Set<Id>();
        for (Profile pr : [SELECT Id FROM Profile WHERE Name LIKE '%System%Admin%']) {
            systemAdminProfileIds.add(pr.id);
        }
        
        
    }
    
    public class removeProduct extends PopUpDialogController.contExt {
        
        private Account acc {get; set;}
        private String usrRole {get; set;}
        private String usrProfile {get; set;}        
        private SET<String> validProducts {get; set;}
        private Boolean ApacRegion;
        
        public removeProduct(Id accId) {
            
            usrRole = UserInfo.getUserRoleId();
            usrProfile = UserInfo.getProfileId();
            acc = [SELECT Id, eNett_products__c, account_status__c, Country__c, ECN__c FROM Account WHERE Id = :accId];
            ApacRegion = (acc.Country__c == 'New Zealand' || acc.Country__c == 'Australia') ? true : false;
            
            validProducts = new SET<String>();
            
            if (acc.eNett_products__c != null) {
                for (String prd : acc.eNett_products__c.split(';')) {
                    if (prd == 'VANs' || prd == 'eNett EFT') {
                        validProducts.add(prd);
                    }
                }
            }
            
        }    
        
        public override String runValidation() {
            if (ApacRegion) {
                if (validProducts.size() <= 1) {
                    return 'This button can only be used if the account has both VANs and eNett EFT products.';
                }
            } else {
                return 'This button does not apply for this region.';
            }
            
            if (acc.account_status__c=='Active' && usrRole != serviceL2RoleId && !systemAdminProfileIds.contains(usrProfile)) {
                return 'Only Service Desk Level 2 Users can use this button for Active accounts.';                
            }         /*PDS-5324 -Checking if user profile exists in Set */
                else if (acc.account_status__c=='Not Active' && !amlProfileIds.contains(usrProfile) && !systemAdminProfileIds.contains(usrProfile)) {
                return 'Only users with AML profile can use this button for Not Active accounts.';            
            }
            
            return null;
        }
        
        public override String runProcess() {
            if (picklistSelection == 'VANs') {
                acc.Remove_VANs__c = true;
            } else if (picklistSelection == 'eNett EFT') {
                acc.Remove_eNett_EFT__c  = true;
            }
            update acc;
            return null;
        }
        
        public override String showConfirmMsg() {
            if (!String.isBlank(acc.ECN__c))
                return 'Warning: Removing a product will deactivate the contract, any open opportunities and deliveries related to that product. Please ensure you have completed the business processes required outside Salesforce prior to removing the product in Salesforce. <br><br>Select a product to remove:';
            return 'Select a product to remove:';
        }
        
        public override List<SelectOption> getPicklistOptions() {
            List<SelectOption> options = new List<SelectOption>();
            for (String prd : validProducts) {
                options.add(new SelectOption(prd,prd));
            }
            return options;
        }
        
    }
    
    public class addProduct extends PopUpDialogController.contExt {
        
        private Account acc {get; set;}
        private String usrRole {get; set;}
        private String usrProfile {get; set;}
        private SET<String> validProducts {get; set;}        
        private Boolean ApacRegion;       
        
        public addProduct(Id accId) {
            
            usrRole = UserInfo.getUserRoleId();
            usrProfile = UserInfo.getProfileId();
            acc = [SELECT Id, eNett_products__c, account_status__c, Country__c, Owner.isActive FROM Account WHERE Id = :accId];            
            ApacRegion = (acc.Country__c == 'New Zealand' || acc.Country__c == 'Australia') ? true : false;
            
            validProducts = new SET<String>();
            
            if (acc.eNett_products__c != null) {
                for (String prd : acc.eNett_products__c.split(';')) {
                    if (prd == 'VANs' || prd == 'eNett EFT') {
                        validProducts.add(prd);
                    }
                }
            }           
        }    
        
        public override String runValidation() {
            if (!acc.Owner.isActive) return 'The account owner is inactive.  Please reassign the account to a valid user before proceeding.';
            if (ApacRegion) {
                if (validProducts.size() == 2) {
                    return 'There are no additional products that can be added.';
                }
            } else {
                if (validProducts.contains('VANs')) {
                    return 'This button does not apply for this region.';
                }
            }
            
            if (acc.account_status__c=='Active' && validProducts.contains('VANs') && usrRole != serviceL2RoleId && !systemAdminProfileIds.contains(usrProfile))
                return 'Only Customer Support Level 2 can add the EFT product for an active VANs account';
            
            if (acc.account_status__c=='Active' && validProducts.contains('eNett EFT') && !amlProfileIds.contains(usrProfile) && !systemAdminProfileIds.contains(usrProfile))
                return 'Only users with AML profile can add VANs to an active EFT account';
                
            /*PDS-5324 -Checking if user profile exists in Set */
            if (acc.account_status__c=='Not Active' && !amlProfileIds.contains(usrProfile) && !systemAdminProfileIds.contains(usrProfile))
                return 'Only users with AML profile can use this button for Not Active accounts.';   
                
            /*PDS-5324 -Checking if user profile exists in Set */
            if (usrRole != serviceL2RoleId && !amlProfileIds.contains(usrProfile) && !systemAdminProfileIds.contains(usrProfile))
                return 'Only AML and Service Desk Level 2 Users can use this button.';
            
            return null;
        }
        
        public override String runProcess() {
            if (picklistSelection == 'VANs') {
                acc.Add_VANs__c = true;
            } else if (picklistSelection == 'eNett EFT') {
                acc.Add_eNett_EFT__c  = true;
            }
            update acc;
            return null;
        }
        
        public override String showConfirmMsg() {
            return 'Select a product to add:';
        }
        
        public override List<SelectOption> getPicklistOptions() {
            List<SelectOption> options = new List<SelectOption>();
            if (!validProducts.contains('VANs')) options.add(new SelectOption('VANs','VANs'));
            if (ApacRegion && !validProducts.contains('eNett EFT')) options.add(new SelectOption('eNett EFT','eNett EFT'));
            return options;
        }
        
    }
    
    public class createAdditionalECNAccount extends PopUpDialogController.contExt {
        
        private Account acc {get; set;}
        private String usrProfile {get; set;}
        private String usrRole {get; set;}  
        
        public createAdditionalECNAccount(Id accId) {
            usrProfile = UserInfo.getProfileId();
            usrRole = UserInfo.getUserRoleId(); 
            //Surajsingh Thakur : 05/02/2019 :SCS-4 : Additional Account creation business rule update - Added field DD_Completed_Date__c in the query
            acc = [SELECT Id, Name, products_Include_Vans__c, re_DD_Due_ECN__c, ECN__c, DD_Status__c, Country__c, DD_Completed_Date__c  FROM Account WHERE Id = :accId];
        }
        
        public override String runValidation() {
           /*PDS-5324 -Checking if user profile exists in Set */
            if (!amlProfileIds.contains(usrProfile) && !systemAdminProfileIds.contains(usrProfile) && usrRole != serviceL2RoleId) {
                return 'Only AML or Service Level 2 users can create an additional account.';
            } 
            //Surajsingh Thakur : 05/02/2019 :SCS-4 : Additional Account creation business rule update - Start
            //Poppy Martono 25/02/2019: Commented 3 lines below to enable additional ECN for EFT
            //else if (!acc.products_Include_Vans__c) {
            //    return 'The account must include VANs to use this button.';
            //} 
            else if (acc.DD_Completed_Date__c!=NULL && ((System.today()).daysBetween(Date.valueOf(acc.DD_Completed_Date__c)) * -1 ) > Integer.valueOf(Generic_Lookups__c.getInstance('Re-DD Time Period').Value__c)) {
                
                return 'This account is due for re DD, you will not be able to create an additional ECN account until re DD has been completed.';
            } 
            //Surajsingh Thakur : 05/02/2019 :SCS-4 : Additional Account creation business rule update - End
            
            else if (string.isBlank(acc.ECN__c)) {
                return 'This account is not active yet, additional ECNs can only be created for Active accounts.';
            } else if (!string.isBlank(acc.DD_Status__c) && acc.DD_Status__c != 'DD Approved') {
                return 'DD is currently in progress for this account, you will not be able to create an additional ECN account until DD has been completed.';
            } else {
                return null;
            }
        }
        
        public override String runProcess() {
            String return_URL = null;
            if (userTextInput == '')
                throw new applicationException('Name cannot be blank.');
            else 
                userTextInput = EncodingUtil.urlEncode(userTextInput, 'UTF-8');
            //Dealing with special chars in account name
            String accName = EncodingUtil.urlEncode(acc.Name, 'UTF-8');
            recTypesAccount__c accRT = recTypesAccount__c.getOrgDefaults();
            ObjectReferenceIds__c objRef = ObjectReferenceIds__c.getOrgDefaults();
            return_URL = '/001/e?RecordType=' + accRT.Additional_ECN__c;
            return_URL += '&CF' + objRef.Account_Account_Type__c + '=/"Additional ECN/"'; 
            return_URL += '&CF' + objRef.Account_Creation_Type__c + '=/"Internal/"';
            return_URL += '&' + objRef.Account_Country__c + '=' + acc.Country__c; 
            return_URL += '&CF' + objRef.Account_Legal_Parent__c + '=' + accName;
            return_URL += '&CF' + objRef.Account_Legal_Parent__c + '_lkid=' + acc.Id;
            return_URL += '&CF' + objRef.Account_Commercial_Parent_Account__c + '=' + accName;
            return_URL += '&CF' + objRef.Account_Commercial_Parent_Account__c + '_lkid=' + acc.Id;           
            return_URL += '&acc2=' + accName + ' - ' + userTextInput; 
            return_URL += '&acc3=' + accName;
            return_URL += '&retURL=%2F' + acc.Id + '&nooverride=1';
            return return_URL;
            
        }
        
        public override String showConfirmMsg() {
            return 'Please enter a Name for the Additional ECN Account. This name will be appended to the Parent Account Name.';
        }
        
        public override Boolean showInputTextField() {
            return true;
        }      
        
    }
    
    public class deactivateAccount extends PopUpDialogController.contExt {
        
        private Account acc {get; set;}
        private String usrRole {get; set;}
        private String usrProfile {get; set;}         
        
        public deactivateAccount(Id accId) {
            usrRole = UserInfo.getUserRoleId();
            usrProfile = UserInfo.getProfileId();
            acc = [SELECT Id, account_status__c, (Select Status__c from contacts) FROM Account WHERE Id = :accId];
                                              
        }    
        
        public override String runProcess() {
            
            acc.account_status__c = 'Deactivated';
            acc.active__c = false;
            update acc;
            
            //Surajsingh Thakur : 17/06/2019 : PDS-2594 : SF User Account/User Profile Deactivation Feature - Start
            
            List<Contact> childContacts = acc.contacts;
            
            if(childContacts.size()>0){
                for(Contact childContact  : acc.contacts){
                    childContact.Status__c = 'Inactive';       
                }
                update childContacts;
            }
            
            
            //Surajsingh Thakur : 17/06/2019 : PDS-2594 : SF User Account/User Profile Deactivation Feature - End
             
            return null;
        }
        
        public override String showConfirmMsg() {
            return 'You are about to deactivate this account. This action will automatically terminate all related open Opportunites, Deliveries and Contracts. Please follow existing deactivation process in Client to ensure that client is correctly deactivated in both Client and Salesforce. Are you sure you want to deactivate this account?';
        }
        
        public override String runValidation() {
            if (acc.account_status__c=='Active' && usrRole != serviceL2RoleId && !systemAdminProfileIds.contains(usrProfile)) {
                return 'Only Service Desk Level 2 Users can deactivate accounts.';
            } else if (acc.account_status__c != 'Active') {
                return 'You cannot deactivate an inactive account.';
            }
            return null;
        }
        
    }
    
    public class reDD extends PopUpDialogController.contExt {
        
        private Account acc {get; set;}
        private String usrRole {get; set;}
        private String usrProfile {get; set;}         
        
        public reDD(Id accId) {
            usrRole = UserInfo.getUserRoleId();
            usrProfile = UserInfo.getProfileId();        
            acc = [SELECT Id, DD_Status__c FROM Account WHERE Id = :accId]; 
            
        }       
        
        public override String runProcess() {
            if (userTextInput == '')
                throw new applicationException('The Re DD Reason cannot be blank.');
            
            acc.Manual_Re_DD_Checklist_Created__c = true;
            acc.DD_Type__c = 'Re DD Manual';
            acc.Re_DD_Reason__c = userTextInput;
            update acc;
            return null;
        }
        
        public override String runValidation() {
            String validationMsg = null;
            
            /*PDS-5324 -Checking if user profile exists in Set */
            if (!amlProfileIds.contains(usrProfile) && !systemAdminProfileIds.contains(usrProfile) && usrRole != serviceL2RoleId) {
                return 'Only AML or Service Level 2 users can Re DD Accounts.';
            } else if (acc.DD_Status__c != 'DD Approved' && acc.DD_Status__c != 'DD Declined') { 
                validationMsg = 'You can only Re DD Accounts that are DD Approved or DD Declined.';
            } else {
                LIST<Registration__c> regs = [SELECT Id FROM Registration__c 
                                              WHERE Account__c = :acc.id 
                                              AND DD_Status__c != 'DD Approved' AND DD_Status__c != 'DD Declined' LIMIT 1];
                If (!regs.isEmpty()) {
                    validationMsg = 'Cannot create a new Due Diligence as there is already a Due Diligence In Progress.';
                }
            }
            
            return validationMsg;
        }
        
        public override String showConfirmMsg() {
            return '<b>You are about to initiate the re DD process, are you sure?</b><br/><br/>Enter the Re DD Reason or press Cancel:';
        }
        
        public override Boolean showInputTextField() {
            return true;
        }
        
    }    
    
    //SCS-5 04/02/2019 Jasmine - Suspend an active account
    public class suspendAccount extends PopUpDialogController.contExt{
        private Account acc {get; set;}
        private String usrId {get; set;}
        private String usrRoleId {get; set;}
        private String roleDevName {get; set;}
        
        public override String showConfirmMsg() {
            return 'You are about to suspend this account, are you sure you want to do this?';
        }
        public suspendAccount(Id accId){
            usrId = UserInfo.getUserId();
            usrRoleId = UserInfo.getUserRoleId();
            if (usrRoleId != NULL){
                UserRole usrRole = [SELECT DeveloperName FROM UserRole WHERE Id =: usrRoleId];
                roleDevName = usrRole.DeveloperName;
                System.debug('#####roleDevName: ' + roleDevName);
            } 
            acc = [SELECT Id, Account_Status__c FROM Account WHERE Id =: accId];
        }
        
        public override String runValidation(){
            String validationMsg = null;
            List<Id> validUserIds = new List<Id>();
            List<Id> validRoleIds = new List<Id>();
            Group grp = [SELECT Id, Name, RelatedId FROM Group WHERE DeveloperName LIKE '%Account_Suspension_Reactivation' LIMIT 1];
            List<GroupMember> members = [SELECT Id, UserOrGroupId FROM GroupMember WHERE GroupId =: grp.Id];
            System.debug('#####members: ' + members);
            for (GroupMember gm : members){
                if (String.valueOf(gm.UserOrGroupId).startsWith('005')){
                    validUserIds.add(gm.UserOrGroupId);
                    System.debug('#####validUserIds: ' + validUserIds);
                } else {
                    validRoleIds.add(gm.UserOrGroupId);
                    System.debug('#####validRoleIds: ' + validRoleIds);
                }    
            }
            Map<Id, Group> rolesInGroup = new Map<Id, Group>([SELECT Id, DeveloperName FROM Group WHERE Id IN: validRoleIds]);
            System.debug('#####rolesInGroup: ' + rolesInGroup);
            if (acc.Account_Status__c != 'Active'){
                validationMsg = 'Only active accounts can be suspended.';
            } else if (validUserIds.contains(usrId)){
                validationMsg = NULL;
            } else if (rolesInGroup.size() > 0 && roleDevName != NULL){
                if (!String.valueOf(rolesInGroup.values()).contains(roleDevName)){
                    validationMsg = 'You do not have permisson to suspend this account.';
                } 
            } else {
                validationMsg = 'You do not have permisson to suspend this account.';
            }
            return validationMsg;
        }
        
        public override String runProcess(){
            acc.Account_Status__c = 'Suspended';
            update acc;
            return null;
        }
        
    }
    
    //SCS-7 06/02/2019 Jasmine - Reactivate a suspended account
    public class reactivateAccount extends PopUpDialogController.contExt{
        private Account acc {get; set;}
        private String usrId {get; set;}
        private String usrRoleId {get; set;}
        private String roleDevName {get; set;}
        
        public override String showConfirmMsg() {
            return 'You are about to reactivate this account, are you sure you want to do this?';
        }
        
        public reactivateAccount (Id accId){
            usrId = UserInfo.getUserId();
            usrRoleId = UserInfo.getUserRoleId();
            if (usrRoleId != NULL){
                UserRole usrRole = [SELECT DeveloperName FROM UserRole WHERE Id =: usrRoleId];
                roleDevName = usrRole.DeveloperName;
                System.debug('#####roleDevName: ' + roleDevName);
            }
            acc = [SELECT Id, Account_Status__c FROM Account WHERE Id =: accId];
        }
        
        public override String runValidation(){
            String validationMsg = null;
            List<Id> validUserIds = new List<Id>();
            List<Id> validRoleIds = new List<Id>();
            Group grp = [SELECT Id, Name, RelatedId FROM Group WHERE DeveloperName LIKE '%Account_Suspension_Reactivation' LIMIT 1];
            List<GroupMember> members = [SELECT Id, UserOrGroupId FROM GroupMember WHERE GroupId =: grp.Id];
            
            for (GroupMember gm : members){
                if (String.valueOf(gm.UserOrGroupId).startsWith('005')){
                    validUserIds.add(gm.UserOrGroupId);
                    System.debug('#####validUserIds: ' + validUserIds);
                } else {
                    validRoleIds.add(gm.UserOrGroupId);
                    System.debug('#####validRoleIds: ' + validRoleIds);
                }    
            }
            Map<Id, Group> rolesInGroup = new Map<Id, Group>([SELECT Id, DeveloperName FROM Group WHERE Id IN: validRoleIds]);
            System.debug('#####rolesInGroup: ' + rolesInGroup);
            if (acc.Account_Status__c != 'Suspended'){
                validationMsg = 'Only suspended accounts can be reactivated.';
            } else if (validUserIds.contains(usrId)){
                validationMsg = NULL;
            } else if (rolesInGroup.size() > 0 && roleDevName != NULL){
                if (!String.valueOf(rolesInGroup.values()).contains(roleDevName)){
                    validationMsg = 'You do not have permisson to reactivate this account.';
                } 
            } else {
                validationMsg = 'You do not have permisson to suspend this account.';
            }
            return validationMsg;
        }
        
        public override String runProcess(){
            acc.Account_Status__c = 'Active';
            update acc;
            return null;
        }
    }
    
    public class applicationException extends Exception {}
}