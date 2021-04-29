/**
* This is a batch that ran each day and check when the last a transaction came from ePP.
It will send an email alert to the dev team if it has been more than 1 day since the last transaction created (synced from ePP).

@author : Jasmine Nguyen

@version : 1.0

@created on : 11/09/2018
**/
global class GDVAlertBatch implements Schedulable{
    @TestVisible Integer isEmailSent;
    global void execute (SchedulableContext sc){
        //Retrieve the latest date when a transaction created (synced from ePP)
        //PDS-467 22/1/2019 Jasmine Use LastModifiedDate instead of CreatedDate for accurate alert
        List<TransactionalData__c> records = [SELECT Id, LastModifiedDate  FROM TransactionalData__c ORDER BY LastModifiedDate DESC LIMIT 1];
        for (TransactionalData__c td : records){
            //If it has been more than a day since the last transaction modified, email users in the group
            //SF-5332 3/11/2018 Jasmine - Convert CreatedDate to local time for accurate comparison, otherwise alert will be sent even though data does come through
            if (td.LastModifiedDate.date() < date.today()){
                //Get users from 'Salesforce Alert' group
                List<Group> selectedGroup = [SELECT Id,DeveloperName FROM Group WHERE DeveloperName LIKE '%Salesforce_Alert%' LIMIT 1];
                List<GroupMember> groupMember = [SELECT GroupId,Id,UserOrGroupId FROM GroupMember WHERE GroupId =: selectedGroup];
                List<Id> userIdList = new List<Id>();
                for (GroupMember gm : groupMember){
                    userIdList.add(gm.UserOrGroupId);
                }
                List<User> users = [SELECT Id, ProfileId, Email FROM User WHERE Id IN: userIdList];
                List<String> emailList = new List<String>();
                for (User u : users){
                    emailList.add(u.Email);
                }
                String Subject = 'GDV Syncing Alert!';
                String Content = 'Uh oh, it has been more than a day since GDV values were synced. Please investigate.';
                //Send emails to users
                EmailUtils.sendMail(emailList, Subject, Content);
                isEmailSent = Limits.getEmailInvocations();
            }
        }
    }
}