global without sharing class LeadUtility extends CalculateBusinessDays{

    @InvocableMethod
    webService static LIST<String> ConvertLead(LIST<Id> leadIds) {

        MAP<Id, Lead> leads = new MAP<Id, Lead>([SELECT Id, Name, Optal_Segment__c, Relationship_Channel__c, Email, Account_Type__c, LeadSource, Lead_Source_Details__c, Referrer_Code__c, Referrer_Name__c, Potential_GDV__c, Country__c, OwnerId, eNett_Products__c
                                                 FROM Lead WHERE Id IN :leadIds]);
        LIST<String> errMsgs = new LIST<String>();
        
        //Surajsingh Thakur : SCS-1 : Salesforce changes for AML 07/02/2019 
        List<Account> updateAccounts = new List<Account>();
        
        LIST<Lead> LeadsOwnedByQueue = new LIST<Lead>();
        for (Lead l : [SELECT Id FROM Lead WHERE Id IN :leadIds AND Owner.Type = 'Queue']) {
            l.OwnerId = '00590000000riL4';
            LeadsOwnedByQueue.add(l);
        }
        update LeadsOwnedByQueue;

        if (!leads.isEmpty()) {
            //SF-5388  commented out to reduce no. of SOQL queries
            //LeadStatus lS = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            List<Database.LeadConvert> MassLeadconvert = new List<Database.LeadConvert>();
            MAP<Id, Id> leadAccountIdMap = new MAP<Id, Id>();
            
            for (id leadId: leadIds) {
                Database.LeadConvert Leadconvert = new Database.LeadConvert();
                Leadconvert.setLeadId(leadId);
                Leadconvert.setConvertedStatus('Converted');
                Leadconvert.setDoNotCreateOpportunity(TRUE);
                MassLeadconvert.add(Leadconvert);
            }

            // Convert leads to Accounts and Contacts   
            List<Database.LeadConvertResult> lcrs = Database.convertLead(MassLeadconvert);

            List<Id> accIds = new List<Id>();
            for (database.LeadConvertResult lcr : lcrs) {
             accIds.add(lcr.accountid);   
            }   
            Map<Id,Account> mapAccounts = new Map<Id,Account>([SELECT Id, Optal_Segment__c, Relationship_Channel__c, Name, Owner.Email, Account_Type__c FROM Account WHERE Id IN :accIds]);
            
            Lead l;
            List<Contact> contUpdates = new List<Contact>();
            //SF-5024 Create a list of approval tasks
            List<Process_Task__c> ptList = new List<Process_Task__c>();
            //SF-5024 Retrieve the 'Account Approval Queue'  --- SF-5388  commented out to reduce no. of SOQL queries
            //Group apQueue = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Account_Approval_Queue'];
            //SF-5024 Retrieve the 'VANs Account Approval Record Type'
            RecordType recId = [SELECT Id FROM RecordType WHERE DeveloperName = 'VANs_Account_Approval_Record_Type'];
            LIST<Database.Error> errs;

            for (database.LeadConvertResult lcr : lcrs) {
                
                if (lcr.isSuccess()) {

                    l = leads.get(lcr.leadId);
                    
                    //Surajsingh Thakur : SCS-1 : Salesforce changes for AML 07/02/2019 
                    //Initializing a seperate Account record and update the Optal_Segment_Type__c field.
                    //Could not use the SF Lead mapping as it threw errors for mismatch of existing fields between Lead and Account
                    Account toUpdateAccount = mapAccounts.get(lcr.accountId);
                    toUpdateAccount.Optal_Segment__c = l.Optal_Segment__c;
                    
                    //Surajsingh Thakur : PDS-1340 : Optal Request - F2F Confirmation (Lead) 10/05/2019
                    System.debug('#####l.LeadSource = '+l.LeadSource);
                    if(l.Relationship_Channel__c!=NULL && l.Relationship_Channel__c!='' && l.LeadSource!='eNett Online Registration'){
                        toUpdateAccount.Relationship_Channel__c = l.Relationship_Channel__c;
                    }
                    
                    else if(l.LeadSource == 'eNett Online Registration'){
                        toUpdateAccount.Relationship_Channel__c = 'External Registration';    
                    }
                    
                    updateAccounts.add(toUpdateAccount); 
                    
                    leadAccountIdMap.put(lcr.leadId, lcr.accountId);
                    //SF-5024 If lead has VANs product only then create an approval task on the account and assign it to 'Account Approval Queue'
                    if (l.Account_Type__c != 'Referrer' && l.Account_Type__c != 'Channel Agreement' && l.eNett_Products__c.contains('VANs') ) {
                        contUpdates.add(new Contact(Id = lcr.contactId, Job_Role__c = 'Primary;Secondary;Financial', Email = leads.get(lcr.leadId).Email,
                                                    Primary_Email_Address__c = leads.get(lcr.leadId).Email, Secondary_Email_Address__c = leads.get(lcr.leadId).Email, Financial_Email_Address__c = leads.get(lcr.leadId).Email));
                        //SF-5024 Get the account name
                        Account acc = mapAccounts.get(lcr.accountId);
                        //SF-5024 Create a process task
                        Process_Task__c accPT = new Process_Task__c (Subject__c = 'Approve Account',
                                                                     Related_Account_Type__c = acc.Account_Type__c,
                                                                     RecordTypeId = recId.Id,
                                                                     Account__c = lcr.accountid,
                                                                     //Account Approval Queue
                                                                     OwnerId = '00G900000039My5',
                                                                     Assigned_Date__c = Date.today(),
                                                                     Related_Account__c = acc.Name,
                                                                     Due_Date__c = CalculateBusinessDays.AddBusinessDays(Date.today(), 2),
                                                                     Account_Owner_Email__c = acc.Owner.Email
                                                                    );
                        ptList.add(accPT);
                    //SF-5024 If lead has EFT or both VANs and EFT then do not create process task    
                    } //else if (l.Account_Type__c != 'Referrer' && l.Account_Type__c != 'Channel Agreement' && l.eNett_Products__c != 'VANs'){
                       //contUpdates.add(new Contact(Id = lcr.contactId, Job_Role__c = 'Primary;Secondary;Financial', Email = leads.get(lcr.leadId).Email,
                                                    //Primary_Email_Address__c = leads.get(lcr.leadId).Email, Secondary_Email_Address__c = leads.get(lcr.leadId).Email, Financial_Email_Address__c = leads.get(lcr.leadId).Email));
                    //}
                } else {
                    errs = lcr.getErrors();
                    for (Database.Error err : errs) {
                        errMsgs.add(err.getMessage());
                    }
                }
                
            }
            
            // Update contacts and accounts
            // SF-5219,5223,5225 20/09/2018 - Jasmine: Added try/catch block to handle DMLException
            try {
                    update contUpdates;
                if(updateAccounts.size()>0){
                    update updateAccounts;
                    System.debug('#####updateAccounts = '+updateAccounts);
                }
            } catch (DMLException e){
                System.Debug('DMLException Message: ' + e.getMessage());
                System.Debug('DMLException Number of DML: ' + e.getNumDml());
            } 
            
            //SF-5024 Insert the process tasks
            insert ptList;
            
            /*
            // Add converted Accounts to Channel Related List
            LIST<Channel__c> ccUpdates = new LIST<Channel__c>();
            for (Channel__c cc : [SELECT Id, Lead__c FROM Channel__c WHERE Lead__c IN :leadAccountIdMap.keySet()]) {
                cc.Account__c = leadAccountIdMap.get(cc.Lead__c);
                ccUpdates.add(cc);
            }
            update ccUpdates;*/

        }

        return errMsgs;            
    }
    
    
    webService static ID GetAccountID(Id leadId) {
         LIST<Lead> l = [SELECT ConvertedAccountId FROM Lead WHERE IsConverted = True AND Id = :leadId LIMIT 1];
         if (!l.isEmpty()) {
             return l[0].ConvertedAccountId;
         } else {
             return null;
         }
    }
    
    public class applicationException extends Exception {}

}