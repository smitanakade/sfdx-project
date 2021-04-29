global class UpdateEFTSettlemenApprovalEmail implements Database.Batchable<sObject>, Database.Stateful {
	
    //instance member to retain state across transactions, keep track of how many records have been processed
    global Integer recordsProcessed = 0;
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('SELECT ID, EFT_Settlement_Approval_Email__c FROM EFT_Settlement_Approval__c');
    }
    
    global void execute(Database.BatchableContext bc, List<EFT_Settlement_Approval__c> scope){
        for (EFT_Settlement_Approval__c esa : scope){
            // populate the email field
            esa.EFT_Settlement_Approval_Email__c = 'APACCS@enett.com';
            // increment the instance member counter
            recordsProcessed = recordsProcessed + 1;
        }
        update scope;
    }
    
    global void finish(Database.BatchableContext bc){
        System.debug(recordsProcessed + ' records have been processed.');
    }
}