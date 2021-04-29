global class InactivateContracts {

    @InvocableMethod
    public static void InactivateAccountContracts (List<Id> accIds) {

        List<eNett_Contract__c> contractUpdateList = new LIST<eNett_Contract__c>();
        
        for (eNett_Contract__c e : [SELECT Id, Status__c FROM eNett_Contract__c WHERE Account_Name__c IN :accIds AND Status__c <> 'Inactive']) {
            e.Status__c = 'Inactive';
            e.Contract_Termination_Reason__c = 'Contract deactivated due to Due Dilligence Declined.';
            e.Contract_Stage__c = '9. Agreement not reached';
            contractUpdateList.add(e);
        }

        database.update(contractUpdateList, false);

    }
}