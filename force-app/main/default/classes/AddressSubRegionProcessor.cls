global class AddressSubRegionProcessor implements 
Database.Batchable<sObject>, Database.Stateful {
    // instance member to retain state across transactions
    global Integer recordsProcessed = 0;
    
    // get all addresses
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Name, Country__c FROM Address__c ORDER BY Client__c');
    }
    
    //Country related information such as region is assigned when Country is updated
    //As we don't actually want to change the country, we are adding 1 to the Country string and then removing it.
    global void execute(Database.BatchableContext bc, List<Address__c> adds){
        for (Address__c a: adds){
            a.Country__c = a.Country__c + '1';
            recordsProcessed++;
        }
        update adds;
        
        for (Address__c a: adds){
            a.Country__c = a.Country__c.removeEnd('1');
        }
        update adds;
    }    
    
    global void finish(Database.BatchableContext bc){
        System.debug(recordsProcessed+ ' Processed');
    }    
}