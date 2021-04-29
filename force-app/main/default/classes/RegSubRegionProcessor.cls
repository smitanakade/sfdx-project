global class RegSubRegionProcessor implements 
Database.Batchable<sObject>, Database.Stateful {
    // instance member to retain state across transactions
    global Integer recordsProcessed = 0;
    
    // get all registrations
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Name, Country__c FROM Registration__c Where Sub_Region__c = NULL');
    }
    
    //Country related information such as region is assigned when Country is updated
    //As we don't actually want to change the country, we are adding 1 to the Country string and then removing it.
    global void execute(Database.BatchableContext bc, List<Registration__c> regs){
        //because country__c is a stricted picklist on registration
        //we have to modify it to a valid country twice to make sure the update is carried out
        Map<Id, String> countryMap = new Map<Id, String>();
        //first change
        for (Registration__c r: regs){
            countryMap.put(r.Id, r.Country__c);
            r.Country__c = 'Australia';
        }
        update regs;
        
        //second change
        for (Registration__c r: regs){
            r.Country__c = 'New Zealand';
        }
        update regs;
        
        //revert changes
        for (Registration__c r: regs){
            r.Country__c = countryMap.get(r.Id);
            recordsProcessed++;
        }
        update regs;
    }    
    
    global void finish(Database.BatchableContext bc){
        System.debug(recordsProcessed+ ' Processed');
    }    
}