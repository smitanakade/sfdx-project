global class AutomaticReDDHandler implements Schedulable {
    
    global void execute(SchedulableContext SC) {
        LIST<Account> accsForUpdate = new LIST<Account>();

        for (Account a : [SELECT id 
                          FROM Account 
                          WHERE Automatic_DD_Checklist_Created__c = false 
                          AND X3_Months_to_Re_DD_Due__c <= TODAY 
                          AND Account_Status__c = 'Active' 
                          AND Reference_Registration__r.DD_Status__c = 'DD Approved'
                          LIMIT 50]) {
            a.Automatic_DD_Checklist_Created__c = true;
            accsForUpdate.add(a);
        }
    
        database.update(accsForUpdate, false);
    }

}