global class UpdateActiveProductCheckboxesOnAccount {

    @InvocableMethod
    global static void UpdateActiveProductCheckboxesOnAccount (LIST<Id> accIds) {
        MAP<Id, Account> accUpdateMap = UpdateActiveProductCheckboxes(accIds);
        update accUpdateMap.values();        
    }
    
    public static Boolean getUpdatedProductContractsActiveCheckbox(Id accId) {
        MAP<Id, Account> accUpdateMap = UpdateActiveProductCheckboxes(new LIST<Id>{accId});
        Boolean prodContractsActive = accUpdateMap.containskey(accId) ? accUpdateMap.get(accId).product_contracts_active__c : false;
        return prodContractsActive;
    }
    
    private static MAP<Id, Account> UpdateActiveProductCheckboxes (LIST<Id> accIds) {
        MAP<Id, Account> accUpdateMap = new MAP<Id, Account>();
        
        for (Id accId : accIds) {
            accUpdateMap.put(accId, new Account(Id = accId, 
                                                active_VANs_contract__c = false, 
                                                active_EFT_contract__c = false,
                                                active_NA_contract__c = false,
                                                product_contracts_active__c = false)
                            );
        }

        Account acc;        
        for (eNett_Contract__c ct : [SELECT Id, eNett_Product__c, Account_Name__c FROM eNett_Contract__c 
                                     WHERE Account_Name__c IN: accIds AND Status__c = 'Active']) {
            acc = accUpdateMap.get(ct.Account_Name__c);
            if (ct.eNett_Product__c == 'VANs') acc.active_VANs_contract__c = true;
            if (ct.eNett_Product__c == 'eNett EFT') acc.active_EFT_contract__c = true;
            if (ct.eNett_Product__c == 'NA') acc.active_NA_contract__c = true;            
        }
       
        SET<String> regProducts;
        for (Account a :[SELECT Id, Reference_Registration__r.Product__c FROM Account WHERE Id IN :accIds]) {  //AND Reference_Registration__r.Product__c != null]) {
            acc = accUpdateMap.get(a.Id);
            regProducts = new Set<String>();
            if (a.Reference_Registration__c != null && a.Reference_Registration__r.Product__c != null) {                
                regProducts = new Set<String>(a.Reference_Registration__r.Product__c.split(';'));
                if (regProducts.contains('VANs') && regProducts.contains('eNett EFT') && acc.active_VANs_contract__c && acc.active_EFT_contract__c) {
                    acc.product_contracts_active__c = true;
                } else if (regProducts.contains('VANs') && !regProducts.contains('eNett EFT') && acc.active_VANs_contract__c) {
                    acc.product_contracts_active__c = true;
                } else if (!regProducts.contains('VANs') && regProducts.contains('eNett EFT') && acc.active_EFT_contract__c) {
                    acc.product_contracts_active__c = true;
                } else if (!regProducts.contains('VANs') && !regProducts.contains('eNett EFT') && regProducts.contains('NA') && acc.active_NA_contract__c) {
                    acc.product_contracts_active__c = true;
                }
            }
            
            // For Channel accounts only
            if (a.Reference_Registration__c == null && (acc.active_VANs_contract__c || acc.active_NA_contract__c))
                acc.product_contracts_active__c = true;
        }   
        
        return accUpdateMap;
    }
    
}