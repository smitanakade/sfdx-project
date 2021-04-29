@isTest
private class TEST_Trigger_PreventContactDuplicates {
      
    @isTest static void test_method_one() {

        List<Contact> CT = new List<Contact>();

        // Insert Account
        Account testAccount = TEST_DataFactory.createAccount();
        insert testAccount;
        System.assert(testAccount.Id != null, 'Account not inserted.');

        // Insert Contacts of various types
        /*Contact testContact_1 = TEST_DataFactory.createContact(testAccount.Id, 'Primary');
        insert testContact_1;
        System.assert(testContact_1.Id != null, 'Contact_1 not inserted.');
        System.assert(testContact_1.Job_Role__c == 'Primary', 'Type of Contact_1 should be Primary but is ' + testContact_1.Job_Role__c);

        Contact testContact_2 = TEST_DataFactory.createContact(testAccount.Id, 'Secondary');
        insert testContact_2;
        System.assert(testContact_2.Id != null, 'Contact_2 not inserted.');
        System.assert(testContact_2.Job_Role__c == 'Secondary', 'Type of Contact_2 should be Secondary but is ' + testContact_2.Job_Role__c);

        Contact testContact_3 = TEST_DataFactory.createContact(testAccount.Id, 'Financial');
        insert testContact_3;
        System.assert(testContact_3.Id != null, 'Contact_3 not inserted.');
        System.assert(testContact_3.Job_Role__c == 'Financial', 'Type of Contact_3 should be Financial but is ' + testContact_2.Job_Role__c);

        // Insert Contact with same Types as previous and the inital ones should be cleared.
        Contact testContact_4 = TEST_DataFactory.createContact(testAccount.Id, 'Primary');
        insert testContact_4;
        System.assert(testContact_4.Id != null, 'Contact_4 not inserted.');
        System.assert(testContact_4.Job_Role__c == 'Primary', 'Type of Contact_4 should be Primary but is ' + testContact_4.Job_Role__c);
        */
    }
    
}