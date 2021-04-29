global class AccountReassign {

    @InvocableMethod
    public static void AssignSalesmanager (LIST<InputParameters> requests) {

        // Filter to only reassign for external registrations
        LIST<Id> accIds = new LIST<Id>();
        for (InputParameters request : requests) {
            if (request.registrationType == 'External Registration') {
                accIds.add(request.accId);
            }
        }
        
        generic_lookups__c reassignmentOwner = null;
        List<Account> accUpdate = new LIST<Account>();

        if (!accIds.isEmpty()) {
            for (Account acc : [select Id, CountryCode2__c, Region__c, OwnerId from Account where Id in :accIds]) {
                reassignmentOwner = null;
                reassignmentOwner = (acc.CountryCode2__c == 'AU' || acc.CountryCode2__c == 'NZ') ? generic_lookups__c.getInstance('APAC_AU_NZ_Sales') : null;
                if (reassignmentOwner == null && acc.Region__c == 'Americas') reassignmentOwner = generic_lookups__c.getInstance('Americas_SalesManager');
                if (reassignmentOwner == null && acc.Region__c == 'EMEA') reassignmentOwner = generic_lookups__c.getInstance('EMEA_SalesManager');
                if (reassignmentOwner == null) reassignmentOwner = generic_lookups__c.getInstance('APAC_Other_SalesManager');
                acc.OwnerId = reassignmentOwner.value__c;
                accUpdate.add(acc);
                system.debug('The ' + acc.CountryCode2__c + ' / ' + acc.Region__c + ' account will be reassigned to ' + reassignmentOwner.value__c);
            }

            database.update(accUpdate, false);
            
            // Note: this step should be handled by the Account_After trigger except the recursion blocking prevents it from running.
            for (Account acc : accUpdate) {
                FutureCalls.ChangeOppTaskOwnership(acc.Id, acc.OwnerId);
            }
        }
    }
    
    global class InputParameters {
        @InvocableVariable(required=true)
        public Id accId;

        @InvocableVariable(required=true)
        public String registrationType;
    }
        
}