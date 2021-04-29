global class AccountSubRegionProcessor implements 
Database.Batchable<sObject>, Database.Stateful {
    // instance member to retain state across transactions
    global Integer recordsProcessed = 0;
    
    // get all accounts
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Name, Country__c FROM Account');
    }
    
    //Country related information such as region is assigned when Country is updated
    //As we don't actually want to change the country, we are adding 1 to the Country string and then removing it.
    global void execute(Database.BatchableContext bc, List<Account> accs){
        for (Account a: accs){
            a.Country__c = a.Country__c + '1';
            recordsProcessed++;
        }
        update accs;
        
        for (Account a: accs){
            a.Country__c = a.Country__c.removeEnd('1');
        }
        update accs;
    }    
    
    global void finish(Database.BatchableContext bc){
        System.debug(recordsProcessed+ ' Processed');
    }    
}