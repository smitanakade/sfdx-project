global class LeadSubRegionProcessor implements 
Database.Batchable<sObject>, Database.Stateful {
    // instance member to retain state across transactions
    global Integer recordsProcessed = 0;
    
    // get all leads
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Name, Country__c FROM Lead WHERE IsConverted = FALSE');
    }
    
    //Country related information such as region is assigned when Country is updated
    //As we don't actually want to change the country, we are adding 1 to the Country string and then removing it.
    global void execute(Database.BatchableContext bc, List<Lead> leads){
        for (Lead l: leads){
            l.Country__c = l.Country__c + '1';
            recordsProcessed++;
        }
        update leads;
        
        for (Lead l: leads){
            l.Country__c = l.Country__c.removeEnd('1');
        }
        update leads;
    }    
    
    global void finish(Database.BatchableContext bc){
        System.debug(recordsProcessed+ ' Processed');
    }    
}