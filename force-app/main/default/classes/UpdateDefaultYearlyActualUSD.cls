global class UpdateDefaultYearlyActualUSD implements Database.Batchable<sObject>, Database.Stateful {
	
    //instance member to retain state across transactions, keep track of how many records have been processed
    global Integer recordsProcessed = 0;
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('SELECT ID, Children_Yearly_Actual_USD__c FROM Account');
    }
    
    global void execute(Database.BatchableContext bc, List<Account> scope){
        List<Account> accountsToBeUpdated = new List<Account>();
        for (Account account : scope){
            if (account.Children_Yearly_Actual_USD__c == NULL){
                account.Children_Yearly_Actual_USD__c = 0;
            }
            // add accounts to list to be updated
            accountsToBeUpdated.add(account);
            // increment the instance member counter
            recordsProcessed = recordsProcessed + 1;
        }
        update accountsToBeUpdated;
    }
    
    global void finish(Database.BatchableContext bc){
        System.debug(recordsProcessed + ' records have been processed.');
        String emailBody = recordsProcessed + ' records have been processed.';
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                            FROM AsyncApexJob WHERE Id =: bc.getJobId()];  
    }
}