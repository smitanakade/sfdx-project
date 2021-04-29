global class DeleteOldTransactionData implements Schedulable {

    global void execute(SchedulableContext sc) {
        LIST<TransactionalData__c> trs = [SELECT Id FROM TransactionalData__c WHERE Flag_for_delete__c = true LIMIT 10000];
        delete trs;
    }

}