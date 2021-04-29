global class AddProduct {

    @InvocableMethod (label='Add Products to Account')
    global static void AddProductToAccount (LIST<AddProductActionRequest> requests) {

        SET<Id> accIds = new SET<Id>();
        MAP<Id, Account> accMap = new MAP<Id, Account>();
        LIST<Account> accsUpdate = new LIST<Account>();
    
        for (AddProductActionRequest request : requests) {
            accIds.add(request.accountId);
        }
        
        for (Account a : [SELECT Id, enett_Products__c FROM Account WHERE Id IN: accIds]) {
            accMap.put(a.Id, a);
        }

        Account acc;
        SET<String> products;

        for (AddProductActionRequest request : requests) {
            acc = accMap.get(request.accountId);
            products = new Set<String>(acc.enett_Products__c.split(';'));
            
            for (String prd : request.productNames.split(';')) {
                products.add(prd);
            }
            
            //products.add(request.productName);
            acc.enett_Products__c = String.join(new List<String>(products), ';');
            accsUpdate.add(acc);
        }
        
        update accsUpdate;
    }
    
    global class AddProductActionRequest {
        @InvocableVariable(required=true)
        public ID accountId;

        @InvocableVariable(required=true)
        public String productNames;
    }
    
}