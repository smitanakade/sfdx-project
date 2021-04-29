global class RemoveProduct {

    @InvocableMethod (label='Remove Product Account')
    global static void RemoveProductFromAccount (LIST<RemoveProductActionRequest> requests) {

        SET<Id> accIds = new SET<Id>();
        MAP<Id, Account> accMap = new MAP<Id, Account>();
        LIST<Account> accsUpdate = new LIST<Account>();
    
        for (RemoveProductActionRequest request : requests) {
            accIds.add(request.accountId);
        }
        
        for (Account a : [SELECT Id, enett_Products__c FROM Account WHERE Id IN: accIds]) {
            accMap.put(a.Id, a);
        }

        Account acc;
        LIST<String> products;

        for (RemoveProductActionRequest request : requests) {
            acc = accMap.get(request.accountId);
            products = new LIST<String>();
            for (String p : acc.enett_Products__c.split(';')) {
                if (p != request.productName) {
                    products.add(p);
                }
            }
            acc.enett_Products__c = String.join(products, ';');
            accsUpdate.add(acc);
        }
        
        update accsUpdate;
    }
    
    global class RemoveProductActionRequest {
        @InvocableVariable(required=true)
        public ID accountId;

        @InvocableVariable(required=true)
        public String productName;
    }
    
}