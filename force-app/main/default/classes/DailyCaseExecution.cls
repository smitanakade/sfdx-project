/*

Author: Paul Swarnapandian
Date: 7/05/15
Description:  This is used to update the flag so that an email is sent for updating the 
Estimated Completion Date. The workflow to send email and create task is 
Delivery: Task and Email on Estimated Completion Date for Active Cases and
Delivery: Task and Email on Estimated Completion Date for Dormant Cases
*/
global class DailyCaseExecution implements Schedulable {

global void execute(SchedulableContext sc) {
        /*List<Task> caseTask = new List<Task>();
        Task estCompletionDateTask;*/
        Date todayDate = System.today();
        
        List<Case> needsUpdate = [SELECT Notify_Estimated_Completion_Date__c FROM Case WHERE Estimated_Completion_Date__c < TODAY 
                                  AND Status IN ('Active', 'Dormant') AND Notify_Estimated_Completion_Date__c = FALSE AND RecordTypeId NOT IN ('01290000000hwKc', 
                                  '01290000000iCRi', '01290000000i3QX', '01290000000iE8h', '01290000000huwY')];
        //System.debug('The size is ' + needsUpdate.size());
        for (Case thisCase : needsUpdate) {
            //Updates the flag on the case
            thisCase.Notify_Estimated_Completion_Date__c = TRUE;  
            }
        
        UPDATE needsUpdate; //Updates Case
        //insert caseTask; // Creates the task
    
    }

}