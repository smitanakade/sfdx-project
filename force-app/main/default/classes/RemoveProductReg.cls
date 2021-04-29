global class RemoveProductReg {

    @InvocableMethod (label='Remove Product Registration')
    global static void RemoveProductFromReg (LIST<RemoveProductActionRequest> requests) {

        SET<Id> regIds = new SET<Id>();
        MAP<Id, Registration__c> regMap = new MAP<Id, Registration__c>();
        LIST<Registration__c> regsUpdate = new LIST<Registration__c>();
    
        for (RemoveProductActionRequest request : requests) {
            regIds.add(request.RegId);
        }
        
        for (Registration__c a : [SELECT Id, product__c FROM Registration__c WHERE Id IN: regIds]) {
            regMap.put(a.Id, a);
        }

        Registration__c reg;
        LIST<String> products;

        for (RemoveProductActionRequest request : requests) {
            reg = regMap.get(request.RegId);
            products = new LIST<String>();
            for (String p : reg.product__c.split(';')) {
                if (p != request.productName) {
                    products.add(p);
                }
            }
            reg.product__c = String.join(products, ';');
            regsUpdate.add(reg);
        }
        
        update regsUpdate;
    }
    
    global class RemoveProductActionRequest {
        @InvocableVariable(required=true)
        public ID RegId;

        @InvocableVariable(required=true)
        public String productName;
    }
    
}