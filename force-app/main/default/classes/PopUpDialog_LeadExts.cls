public class PopUpDialog_LeadExts {
    
    public class convertLeadToAccount extends PopUpDialogController.contExt {
        
        private Lead ld {get; set;}
        private Registration__c reg {get; set;}
        
        public convertLeadToAccount(Id recId) {
            ld = PopUpDialog_LeadExts.loadLead(recId);
            if (ld.Reference_Registration__c != null) {
                reg = [SELECT Id, Registration_Type__c FROM Registration__c WHERE Id = :ld.Reference_Registration__c LIMIT 1][0];
            }
        }    
        
        public override String runProcess() {
            String return_URL = null;
            //SF-5024 Retrieve the 'Account Approval Queue'
            Group accountApprovalQueue = [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Account_Approval_Queue' LIMIT 1];
            //SF-5024 Retrieve the 'AML Queue'
            Group AMLQueue = [SELECT Id, Name FROM Group WHERE Type ='Queue' AND DeveloperName = 'AML_Queue' LIMIT 1];
            //SF-5024 If lead's product contains VANs then assign to 'Approval Queue'  
            if (ld.Reference_Registration__c == null && ld.rTDevName__c != 'Channel_Agreement' && ld.rTDevName__c != 'Referrer' && ld.eNett_Products__c.contains('VANs')) {
                reg = new Registration__c(Lead__c = ld.Id,
                                          Registered_Company_Name__c = ld.Company,
                                          Registration_Status__c = 'New',
                                          Account_Type__c = ld.Account_Type__c,
                                          Agreement_Type__c = 'Undefined',
                                          Registration_Type__c = 'Internal Registration',
                                          Trading_Name__c = ld.Trading_As__c,
                                          Account_Country__c = ld.Country__c,
                                          //SF-5024 Assigning Internal regos to 'Approval Queue'
                                          ownerId = accountApprovalQueue.Id
                                         );
                //SF-5024 DML Exception handling
                try{
                    insert reg;
                } catch (DmlException e){
                    System.debug('The following exception has occured: ' + e.getMessage());
                }
                
                ld.Reference_Registration__c = reg.Id;
                //SF-5024 Exception handling
                try{
                    update ld;
                } catch (DmlException e){
                    System.debug('The following exception has occured: ' + e.getMessage());
                }
                //SF-5024 If lead's product does not contain VANs and lead does not have a rego then create a rego and assign directly to AML Queue
            } else if (ld.Reference_Registration__c == null && ld.rTDevName__c != 'Channel_Agreement' && ld.rTDevName__c != 'Referrer'){
                reg = new Registration__c(Lead__c = ld.Id,
                                          Registered_Company_Name__c = ld.Company,
                                          Registration_Status__c = 'New',
                                          Account_Type__c = ld.Account_Type__c,
                                          Agreement_Type__c = 'Undefined',
                                          Registration_Type__c = 'Internal Registration',
                                          Trading_Name__c = ld.Trading_As__c,
                                          Account_Country__c = ld.Country__c,
                                          //SF-5024 Assigning Internal regos to 'Approval Queue'
                                          ownerId = AMLQueue.Id
                                         );
                //SF-5024 DML Exception handling
                try {
                    insert reg;
                    ld.Reference_Registration__c = reg.Id;
                    update ld;
                }
                catch (DMLException e){
                    System.debug('The following exception has occured: ' + e.getMessage());
                }
                
            } else if (ld.Reference_Registration__c != null && reg.Registration_Type__c == 'External Registration') {
                ld.Contract_Type__c = 'Undefined';
                ld.Registration_Type__c = 'Internal Registration';
                //SF-5024 DML Exception handling
                try {
                    update ld;
                } catch (DMLException e){
                    System.debug('The following exception has occured: ' + e.getMessage());
                }
                reg.Agreement_Type__c = 'Undefined';
                reg.Registration_Type__c = 'Internal Registration';
                reg.ownerId = Generic_Lookups__c.getValues('AML Queue').Value__c;
                //SF-5024 DML Exception Handling
                try {
                   update reg; 
                } catch (DMLException e){
                   System.debug('The following exception has occured: ' + e.getMessage());
                }
            }
            
            LIST<String> errMsgs = LeadUtility.ConvertLead(new LIST<Id>{ld.Id});
            if (!errMsgs.isEmpty()) {
                throw new applicationException('An unexpected error occured during lead conversion.');
            }
            return_URL = LeadUtility.GetAccountID(ld.Id); //reg.id;           
            return return_URL;
        }
        
        public override String showConfirmMsg() {
            if (ld.Reference_Registration__c != null && reg.Registration_Type__c == 'External Registration') {
                return 'An existing \'External\' registration record already exists for this Lead. Would you like to change the Registration type to \'Internal Registration\'?';
            } else if (ld.Reference_Registration__c != null && reg.Registration_Type__c != 'External Registration') {
                return 'You are about to convert the lead. Are you sure?';
            } else {
                return 'You are about to convert this Lead to an Account. Are you sure?';
            }
        }
        
    }    
    
    /* Obsolete code (SF-3443) - Cleanup before deployment
public class sendRegToClient extends PopUpDialogController.contExt {

private Lead ld {get; set;}
private Registration__c reg {get; set;}

public sendRegToClient(Id recId) {
ld = PopUpDialog_LeadExts.loadLead(recId);
LIST<Registration__c> regs = [SELECT Id FROM Registration__c WHERE Lead__c = :ld.Id AND Registration_Type__c = 'External Registration' LIMIT 1];
if (!regs.isEmpty()) reg = regs[0];
}

public override String runValidation() {
if (string.isBlank(ld.Email)) {
return 'Please enter an email address before using this button.';
}
return null;
}

public override String runProcess() {
String return_URL = null;
if (reg == null) {
reg = new Registration__c(Lead__c = ld.Id,
Registered_Company_Name__c = ld.Company,
Registration_Status__c = 'In Progress',
Account_Type__c = ld.Account_Type__c,
Registration_Type__c = 'External Registration',
Email__c = ld.Email,
Send_Reg_To_Client__c = true,
Agreement_Type__c = 'Undefined',
Salutation__c = ld.Salutation,
First_Name__c = ld.FirstName,
Last_Name__c = ld.LastName,
Phone__c = ld.Phone,
Country__c = ld.Country__c,
Account_Country__c = ld.Country__c,
Job_Role__c = ld.Job_Title__c,
//Sector__c = ld.Customer_Sector__c,
//Sector_Type__c = ld.Customer_Sector_Type__c,                                          
Trading_Name__c = ld.Trading_As__c);
insert reg;
return_URL = reg.id;

ld.Registration_Type__c = 'External Registration';
ld.Reference_Registration__c = reg.id;
ld.Contract_Type__c = 'Undefined';
update ld;

//LIST<String> errMsgs = LeadUtility.ConvertLead(new LIST<Id>{ld.Id});
//if (!errMsgs.isEmpty()) {
//    throw new applicationException('An unexpected error occured during lead conversion.');
//}
} else {
reg.Send_Reg_To_Client__c = true;
update reg;
}
return return_URL;
}

public override String showConfirmMsg() {
if (reg == null) {
return 'You are about to create an external registration. An email will be sent to the client with a link to complete their registration online.  Press Continue to proceed or Cancel to abort.';
} else {
return 'You are about to email the client a link to their registration.  Press Continue to proceed or Cancel to abort.';
}
}

}*/
    
    public class applicationException extends Exception {}
    
    public static Lead loadLead(Id recId) {
        Lead ld;
        ld = [SELECT Id, Salutation, FirstName, LastName, Phone, Email, Country__c, Job_Title__c, Company, Account_Type__c, Reference_Registration__c, rTDevName__c, Trading_As__c, eNett_Products__c
              FROM Lead
              WHERE Id = :recId];
        return ld;
    }
    
}