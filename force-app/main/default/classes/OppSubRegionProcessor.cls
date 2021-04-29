global class OppSubRegionProcessor implements 
Database.Batchable<sObject>, Database.Stateful {
    // instance member to retain state across transactions
    global Integer recordsProcessed = 0;
    
    // get all opportunities
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Name, Country__c FROM Opportunity ORDER BY AccountId');
    }
    
    //Country related information such as region is assigned when Country is updated
    //As we don't actually want to change the country, we are adding 1 to the Country string and then removing it.
    global void execute(Database.BatchableContext bc, List<Opportunity> opps){
        for (Opportunity o: opps){
            o.Country__c = o.Country__c + '1';
            recordsProcessed++;
        }
        update opps;
        
        for (Opportunity o: opps){
            o.Country__c = o.Country__c.removeEnd('1');
        }
        update opps;
    }    
    
    global void finish(Database.BatchableContext bc){
        System.debug(recordsProcessed+ ' Processed');
    }    
}