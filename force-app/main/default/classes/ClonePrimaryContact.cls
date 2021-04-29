global class ClonePrimaryContact {

    @InvocableMethod (label='Clone Primary Contact to Another Account')
    global static void CloneContact (LIST<ActionRequest> requests) {
        Contact c2;
        LIST<Contact> newContacts = new LIST<Contact>();
        for (ActionRequest request : requests) {
            for (Contact c : database.query(SOQLUtils.getCreatableFieldsSOQL('Contact', 'AccountId = \'' + request.sourceAccountId + '\' AND Job_Role__c INCLUDES (\'Primary\') LIMIT 1'))) {
                c2 = c.clone(false, true, false, false);
                c2.accountid = request.targetAccountId;
                newContacts.add(c2);
            }
        }
        if (!newContacts.isEmpty()) insert newContacts;
    }
    
    global class ActionRequest {
        @InvocableVariable(required=true)
        public ID sourceAccountId;

        @InvocableVariable(required=true)
        public ID targetAccountId;
    }

}