@isTest
private class TEST_Trigger_ReferrerHistoryTracking {
    
    @isTest static void TEST_Trigger_ReferrerHistoryTracking() {

        /***********************************************
            Insert an Account
        ***********************************************/
        
        Account testAccount = new Account(
                                    Name = 'Account Test', 
                                    Legal_Name__c = 'Account Test', 
                                    Client_Status__c = 'Prospect', 
                                    Region__c = 'APAC',
                                    Customer_Sector__c = 'Agent',                                   
                                    //Client_internal_classification__c = 12000000,
                                    Referrer_Name__c = 'Mastercard',
                                    IsApi__c = true); 
        insert testAccount;

        System.assert(testAccount.Id != null, 'Account not inserted.');


        /**************************************************************************************
            Update the Referrer providing NO justification
            We should get an exception
        **************************************************************************************/

        Account theAcct = 
            [Select Id, Referrer_Name__c, Referrer_Change_Justification__c, Referrer_Change_History__c 
                from Account where id = :testAccount.Id LIMIT 1];

        theAcct.Referrer_Name__c = 'Agoda';

        /*try
        {
            update theAcct;
            System.Assert(true == false, 'An exception should have been thrown by the trigger but was not.'); 
        }
        catch(DmlException e)
        {
            System.Assert(e.getMessage().contains('Please enter or modify the Referrer Change Justification'), e.getMessage());
            System.Debug('********** We received the ERROR we expected.');
        } */


        /**************************************************************************************
            Now set the justification. Record should save successfully.
        **************************************************************************************/

        theAcct.Referrer_Change_Justification__c = 'The Origninal Justification';

        update theAcct;

        Account theAcctUpd = 
            [Select Id, Referrer_Name__c, Referrer_Change_Justification__c, Referrer_Change_History__c 
                from Account where id = :testAccount.Id LIMIT 1];

        System.Debug('********** ReferrerName = ' + theAcctUpd.Referrer_Name__c);
        System.Debug('********** ReferrerChangeJust = ' + theAcctUpd.Referrer_Change_Justification__c);
        System.Debug('********** ReferrerChangeJustHist = ' + theAcctUpd.Referrer_Change_History__c);


        /**************************************************************************************
            Update again for full code coverage.
        **************************************************************************************/


        theAcctUpd.Referrer_Name__c = 'Mastercard';
        theAcctUpd.Referrer_Change_Justification__c = 'The subsequent Justification';

        update theAcctUpd;

        Account theAcctUpd2 = 
            [Select Id, Referrer_Name__c, Referrer_Change_Justification__c, Referrer_Change_History__c 
                from Account where id = :testAccount.Id LIMIT 1];

        System.Debug('********** ReferrerName = ' + theAcctUpd2.Referrer_Name__c);
        System.Debug('********** ReferrerChangeJust = ' + theAcctUpd2.Referrer_Change_Justification__c);
        System.Debug('********** ReferrerChangeJustHist = ' + theAcctUpd2.Referrer_Change_History__c);
        
    }
}