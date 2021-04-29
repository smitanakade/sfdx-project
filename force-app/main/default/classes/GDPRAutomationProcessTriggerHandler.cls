/*
 *  This is Trigger Handler class of trigger GDPRAutomationProcessTrigger.apxt
 *  This class contains the methods to invoke from trigger class GDPRAutomationProcessTrigger.apxt 
 *  @author  : Kishore Potla
 *  @version : 1.0
 *  @update  : 
*/

public class GDPRAutomationProcessTriggerHandler {
    
    public static List<Contact> primaryContacts = new List<Contact>();
    public static List<Contact> nonPrimaryContactsDeleteList = new List<Contact>();
    public static List<Contact> nonPrimaryContactsMaskList = new List<Contact>();
    
    public static void processGDPR(List<String> ECNList, Id recId){
        System.debug('**** GDPR: Processing ECN : '+ECNList);
        GDPR_Masking__C gdprRec = [SELECT Id, GDPR_Status__C, Comments__C, Masked_Ids__c, Deleted_Ids__c from GDPR_Masking__C where id =: recId];
        //At initial, setting GDPR_status to 'Fail'. At last if the process get success, will update the Success status to database.
        gdprRec.GDPR_status__c = 'Fail'; 
        
        List<Account> accList = [SELECT Id, (SELECT Id, Email, Primary_Email_Address__c, Secondary_Email_Address__c,
                                             Financial_Email_Address__c, User_Email_Address__c, Alternative_Email_Adress__c FROM Contacts)
                                 FROM Account WHERE ECN__c IN: ECNList];
        
        Set<String> emailList = new Set<String>();
        for (Account a : accList){
            for (Contact c : a.Contacts){
                if (c.Email != NULL){
                    emailList.add(c.Email);
                }
                if (c.Primary_Email_Address__c != NULL){
                    emailList.add(c.Primary_Email_Address__c);
                }
                if (c.Secondary_Email_Address__c != NULL){
                    emailList.add(c.Secondary_Email_Address__c);
                }
                if (c.Financial_Email_Address__c != NULL){
                    emailList.add(c.Financial_Email_Address__c);
                }
                if (c.User_Email_Address__c != NULL){
                    emailList.add(c.User_Email_Address__c);
                }
                if (c.Alternative_Email_Adress__c != NULL){
                    emailList.add(c.Alternative_Email_Adress__c);
                }
            }
        }
        //Remove already masked email id from Set.
        emailList.remove('XXXX@XXXX.XXXX');
        emailList.remove('xxxx@xxxx.xxxx');
        emailList.remove('aXXX@enett.com');
        emailList.remove('axxx@enett.com');
        
        String searchEmail = String.join((Iterable<String>)emailList, ' OR ');
        System.debug('**** GDPR: Email id list for search string : '+searchEmail);
          
        List<List<SObject>> searchList = new List<List<SObject>>();
        if (searchEmail.length() > 0){
              searchList = [FIND :searchEmail IN ALL FIELDS
                            RETURNING Contact(Id, ECN_ID__c, Account.ECN__c, Status__c, Birthdate, Department, Email, Fax, HomePhone, MobilePhone, Firstname, Lastname, OtherAddress, OtherPhone, Phone, 
                                              Alternative_Email_Adress__c, Alternative_Mobile__c, MailingStreet, MailingPostalCode, MailingState, MailingCity, MailingCountry, 
                                              User_Email_Address__c, Alternative_Phone__c, FEmail__c, Financial_Email_Address__c, Full_Name__c, Job_Role__c, Name_and_email__c, 
                                              Primary_Email_Address__c, Salutation, Secondary_Email_Address__c, SEmail__c, UEmail__c
                                              where Account.ECN__c in :ECNList),
                            
                                       Case(Id, AccountECN__C, Account.ECN__c where Account.ECN__c in :ECNList),
                                       CaseComment(id, parent.AccountECN__C where  parent.AccountECN__C in :ECNList),
                                       Action__c(Id, Related_To__r.Account.ECN__c WHERE Related_To__r.account.ECN__c in :ECNList),
                                       Inbound_Email__c (Id, case__r.Account.ECN__c where case__r.Account.ECN__c in :ECNList)];
        
        
        Map<Id, Contact> nonPrimaryContacts = new Map<Id,Contact>();
        List<Case> cases = new List<Case>();
        List<CaseComment> caseComments = new List<CaseComment>();
        List<Lead> leads = new List<Lead>();
        List<Action__c> actions = new List<Action__c>();
        List<Inbound_Email__c> inboundEmails = new List<Inbound_Email__c>(); 
        
        for (List<SObject> lo : searchList){
            for (SObject o : lo){
                Schema.DescribeSObjectResult dsr = o.getSObjectType().getDescribe();
                
                // PROCESS CONTACTS
                if (dsr.getSObjectType() == Schema.Contact.getSObjectType()){
                    Contact c = (Contact)o;
                   
                    //If contact is primary => mask details
                    if (String.isNotEmpty(c.Job_Role__c) && c.Job_Role__c.contains('Primary')){
                        maskContact(c);
                        primaryContacts.add(c);
                    } else {
                        //If contact is non-primary => delete
                        nonPrimaryContacts.put(c.id, c); 
                    }
                } // PROCESS CASES
                else if (dsr.getSObjectType() == Schema.Case.getSObjectType()){
                    Case ticket = (Case)o;
                    cases.add(ticket);
                } // PROCESS CASE COMMENTS
                else if (dsr.getSObjectType() == Schema.CaseComment.getSObjectType()){
                    CaseComment caseComment = (CaseComment)o;
                    caseComments.add(caseComment);
                }// PROCESS ACTIONS
                else if (dsr.getSObjectType() == Schema.Action__c.getSObjectType()){
                    Action__c action = (Action__c)o;
                    actions.add(action);
                }// PROCESS INBOUND EMAILS
                else if (dsr.getSObjectType() == Schema.Inbound_Email__c.getSObjectType()){ 
                    Inbound_Email__c ie = (Inbound_Email__c)o;
                    inboundEmails.add(ie);
                }
            }
        }
        
        // SOSL will ignore the converted leads, Hence Leads are handled by SOQL 
        leads = [SELECT Id FROM Lead WHERE ConvertedAccount.ECN__C in :ECNList AND IsConverted = true];
        
      /*  System.debug('GDPR :: Update List :: \nPrimary/Non-Primary Contacts : '+primaryContacts+'\n GDPR :: Delete List :: \nLeads : '+leads+'\n Non Primary Contacts : '+nonPrimaryContactsDeleteList+'\n Cases : '+cases+
                     '\n CaseComments : '+caseComments+'\n Actions : '+actions+'\n Inbound Emails : '+inboundEmails); */
    
        
        // Update or Delete GDPR data
        List<String> errMesgList = new List<String>();
        Set<id> deletedIds = new Set<id>();
        Set<id> maskedIds = new Set<id>();
        try{
            Savepoint sp = Database.setSavepoint();
            
            System.debug('**** GDPR: Deleting Leads : '+leads);
            errMesgList.addAll(logDeleteResultErrors(Database.delete(leads, false), Schema.Lead.getSObjectType()));
            System.debug('**** GDPR: Deleting Actions : '+actions);
            errMesgList.addAll(logDeleteResultErrors(Database.delete(actions, false), Schema.Action__c.getSObjectType()));
            System.debug('**** GDPR: Deleting CaseComments : '+caseComments);
            errMesgList.addAll(logDeleteResultErrors(Database.delete(caseComments, false), Schema.CaseComment.getSObjectType()));
            System.debug('**** GDPR: Deleting Cases/Tickets : '+cases);
            errMesgList.addAll(logDeleteResultErrors(Database.delete(cases, false), Schema.Case.getSObjectType()));
            
            //Process Contacts (Processing Contacts after Cases, because contacts can't be deleted if they have associated cases.)
            processNonPrimaryContacts(nonPrimaryContacts);
            System.debug('**** GDPR: Masking Contacts : '+primaryContacts);
            System.debug('**** GDPR: Deleting Contacts : '+nonPrimaryContactsDeleteList);
            errMesgList.addAll(logSaveResultErrors(Database.update(primaryContacts, false), Schema.Contact.getSObjectType()));
            errMesgList.addAll(logDeleteResultErrors(Database.delete(nonPrimaryContactsDeleteList, false), Schema.Contact.getSObjectType()));
            
            System.debug('**** GDPR: Deleting Inbound Emails : '+inboundEmails);
            errMesgList.addAll(logDeleteResultErrors(Database.delete(inboundEmails, false), Schema.Inbound_Email__c.getSObjectType()));
            
            //If any errors, send email alert
            if(errMesgList.size() > 0){
                gdprRec.GDPR_status__c = 'Fail';
                gdprRec.Comments__C = 'GDPR: Exception in processing ECN - ' + String.join(ECNList,',') + '\n' + String.join(errMesgList,'\n\n');
                Database.rollback(sp);
                System.debug('GDPR: Exception in processing ECN - '+String.join(ECNList,',')+'\n'+String.join(errMesgList,'\n\n'));
                EmailUtils.sendAlertEmail('GDPR: Exception in processing ECN - '+String.join(ECNList,','), 'GDPR_Masking__C record id : '+gdprRec.Id+'\n'+String.join(errMesgList,'\n\n'));
            }else{
                gdprRec.GDPR_status__c = 'Success';
                
                //For Spanning backup report purpose capture Deleted/Masked record ids
                maskedIds.addAll((new Map<Id,SObject>(primaryContacts)).keySet());
                deletedIds.addAll((new Map<Id,SObject>(nonPrimaryContactsDeleteList)).keySet());
                deletedIds.addAll((new Map<Id,SObject>(leads)).keySet());
                deletedIds.addAll((new Map<Id,SObject>(actions)).keySet());
                deletedIds.addAll((new Map<Id,SObject>(caseComments)).keySet());
                deletedIds.addAll((new Map<Id,SObject>(cases)).keySet());
                deletedIds.addAll((new Map<Id,SObject>(inboundEmails)).keySet());
                
                gdprRec.Masked_Ids__c = String.join(new List<Id>(maskedIds),',');
                gdprRec.Deleted_Ids__c = String.join(new List<Id>(deletedIds),',');
            }
        }catch(Exception e){
            System.debug('#####Exception in GDPRAutomationProcessTriggerHandler : '+e.getMessage());
            EmailUtils.sendAlertEmail('Exception in GDPR process handler - ECN : '+String.join(ECNList,','), e.getMessage() );
        }
        }else{
            gdprRec.GDPR_status__c = 'No Action';
            gdprRec.Comments__C = 'No Contacts available for Processing ECN' + ECNList;
            System.debug('**** GDPR: No contact email ids found for Processing ECN : '+ECNList);
        }
      update gdprRec;
    }
    
    public static void processNonPrimaryContacts(Map<Id, Contact> nonPrimaryContacts){
        //Process Non-primary contacts.
        //If a Non-primary Contact has associated Case(s), mask that contact. Otherwise delete it.
        Contact maskNonPriContact = new Contact();
        List<Contact> nonPrimaryContactList = [SELECT Id, (SELECT Id from Cases) FROM Contact WHERE Id in :nonPrimaryContacts.keySet()];
        for(Contact c: nonPrimaryContactList){
            if(c.cases.size()>0){
                maskNonPriContact = nonPrimaryContacts.get(c.Id); 
                maskContact(maskNonPriContact);
                nonPrimaryContactsMaskList.add(maskNonPriContact);
            }else{
                nonPrimaryContactsDeleteList.add(c);
            }
        }
        //Add nonPrimaryContactsMaskList list to primaryContacts list, to update in SF
        primaryContacts.addAll(nonPrimaryContactsMaskList);
    }
    
    public static void maskContact(Contact c){
        c.Status__c = 'Left Account';
        c.Birthdate = NULL;
        c.Department= c.Department == NULL ? '' : 'XXXX';
        c.Email = c.Email == NULL ? '' : 'aXXX@enett.com';
        c.Fax = c.Fax == NULL ? '' : 'XXXXXXXXXX';
        c.HomePhone = c.HomePhone == NULL ? '' : 'XXXXXXXX';
        c.MobilePhone = c.MobilePhone == NULL ? '' : 'XXXXXXXXXX';
        c.FirstName = c.FirstName == NULL ? '' : 'XXXX';
        c.LastName = c.Lastname == NULL ? '' : 'XXXX';
        c.MailingStreet = c.MailingStreet == NULL ? '' : 'XXXX';
        c.MailingPostalCode = c.MailingPostalCode == NULL ? '' : 'XXXX';
        c.MailingState =  c.MailingState == NULL ? '' : 'XXXX';
        c.MailingCity = c.MailingCity == NULL ? '' : 'XXXX';
        c.MailingCountry = c.MailingCountry == NULL ? '' : 'XXXX';
        c.OtherPhone = c.OtherPhone == NULL ? '' : 'XXXXXXXX';
        c.Phone = c.Phone == NULL ? '' : 'XXXXXXXX';
        c.Alternative_Email_Adress__c = c.Alternative_Email_Adress__c == NULL ? '' : 'aXXX@enett.com';
        c.Alternative_Mobile__c = c.Alternative_Mobile__c == NULL ? '' : 'XXXXXXXXXX';
        c.Alternative_Phone__c = c.Alternative_Phone__c == NULL ? '' : 'XXXXXXXX';
        c.FEmail__c = c.FEmail__c == NULL ? '' : 'aXXX@enett.com';
        c.Financial_Email_Address__c = c.Financial_Email_Address__c == NULL ? '' : 'aXXX@enett.com';
        c.Primary_Email_Address__c = c.Primary_Email_Address__c == NULL ? '' : 'aXXX@enett.com';
        c.Secondary_Email_Address__c = c.Secondary_Email_Address__c == NULL ? '' : 'aXXX@enett.com';
        c.User_Email_Address__c = c.User_Email_Address__c == NULL ? '' : 'aXXX@enett.com';
        c.Salutation = c.Salutation == NULL ? '' : 'XXXX';
        c.SEmail__c = c.SEmail__c == NULL ? '' : 'aXXX@enett.com';
        c.UEmail__c = c.UEmail__c == NULL ? '' : 'aXXX@enett.com';    
    }
    
    public static List<String> logSaveResultErrors(Database.SaveResult[] saveResult, Schema.SObjectType sObjectName){
        List<String> errList = new List<String>();
        for (Database.SaveResult sr : saveResult) {
            if (sr.isSuccess()) {
              //  System.debug('GDPR ::' + sObjectName + ' Update Success.. ID: '+sr.getId());
            } else {
               System.debug('GDPR Error :: while updating the '+sObjectName+'...');
               for(Database.Error err : sr.getErrors()) {
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    errList.add(err.getMessage());
                }
            }
        }
        return errList;
    }
    
    public static List<String> logDeleteResultErrors(Database.DeleteResult[] deleteResult, Schema.SObjectType sObjectName){
        List<String> errList = new List<String>();
        for (Database.DeleteResult dr : deleteResult) {
            if (dr.isSuccess()) {
               // System.debug('GDPR ::' + sObjectName + ' Delete Success.. ID: '+dr.getId());
            } else {
               System.debug('GDPR Error :: while Deleting the '+sObjectName+'...');
               for(Database.Error err : dr.getErrors()) {
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    errList.add(err.getMessage());
                }
            }
        }
        return errList;
    }
}