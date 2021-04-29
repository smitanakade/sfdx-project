/**
* This is a controller class class for the VF page - PostRefersh. 
It holds the business logic to create 'Account Approval' process task for when added VANs product.
@ticket: SF-01010
@author : Jasmine Nguyen
@version : 1.0
**/
global class AccountApprovalTask{
    @InvocableMethod (label = 'Create Account Approval Task') 
    global static void createAccountApprovalTask(List<Id> accIds){
        Group apQueue = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Account_Approval_Queue'];
        RecordType recId = [SELECT Id FROM RecordType WHERE DeveloperName = 'VANs_Account_Approval_Record_Type'];
        List<Account> accList = [SELECT Id, Name, Owner.Email, Account_Type__c FROM Account WHERE Id IN: accIds];
        List<Process_Task__c> ptList = new List<Process_Task__c>();
        for (Account acc : accList){
            Process_Task__c accPT = new Process_Task__c (Subject__c = 'Approve Account',
                                                         Related_Account_Type__c = acc.Account_Type__c,
                                                         RecordTypeId = recId.Id,
                                                         Account__c = acc.Id,
                                                         OwnerId = apQueue.Id,
                                                         Assigned_Date__c = Date.today(),
                                                         Due_Date__c = CalculateBusinessDays.AddBusinessDays(Date.today(), 2),
                                                         Related_Account__c = acc.Name,
                                                         Account_Owner_Email__c = acc.Owner.Email);
            ptList.add(accPT);
        }
        try{
            insert ptList; 
        } catch (DMLException e){
            System.debug('The following exception has occured: ' + e.getMessage());
        }
    }
}