global class AddProductReg {

    @InvocableMethod (label='Add Product Registration')
    global static void AddProductToReg (LIST<AddProductActionRequest> requests) {

        SET<Id> regIds = new SET<Id>();
        MAP<Id, Registration__c> regMap = new MAP<Id, Registration__c>();
        LIST<Registration__c> regsUpdate = new LIST<Registration__c>();
    
        for (AddProductActionRequest request : requests) {
            regIds.add(request.regId);
        }
        
        for (Registration__c a : [SELECT Id, Product__c FROM Registration__c WHERE Id IN: regIds]) {
            regMap.put(a.Id, a);
        }

        Registration__c reg;
        SET<String> products;

        for (AddProductActionRequest request : requests) {
            reg = regMap.get(request.regId);
            products = new Set<String>(reg.Product__c.split(';'));
            products.add(request.productName);
            reg.Product__c = String.join(new List<String>(products), ';');
            regsUpdate.add(reg);
        }
        
        update regsUpdate;
    }
    
    global class AddProductActionRequest {
        @InvocableVariable(required=true)
        public ID regId;

        @InvocableVariable(required=true)
        public String productName;
    }
    
}