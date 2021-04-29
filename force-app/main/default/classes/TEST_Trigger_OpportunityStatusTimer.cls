@isTest
private class TEST_Trigger_OpportunityStatusTimer {
    
    @isTest static void TEST_Trigger_OpportunityStatusTimer() {

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


        /*********************************************************************************
            Create an Opportunity with Status = "1. Prospect"
        *********************************************************************************/

        Opportunity Opp1 = new Opportunity(
                                    Name= 'Test Opp',
                                    AccountId = testAccount.Id ,
                                    Product__c = 'VANs',
                                    Type = 'New',
                                    CloseDate = date.valueOf('2014-01-01'),
                                    StageName = '1. Prospect',
                                    CurrencyIsoCode = 'USD',
                                    Delivery_Type__c = null);
        /*insert Opp1;

        // WF Sets to Stage 7 when the Account is DD Completed ?
        List<Opportunity> chkOpp = 
            [Select Id, StageName from Opportunity where id = :opp1.Id];


        List<Opportunity_Status_Timer__c> oppTimer0 = 
            [Select Id, Prior_Status__c, Name, Elapsed_Time_Days__c, Elapsed_Time_Hours__c from Opportunity_Status_Timer__c 
                where RelatedOpportunity__c = :opp1.Id];
        */

        /*------------------------------------------------
          Change the Opp Stage to "1. Prospect"
        ------------------------------------------------*/
        /*
        Opp1.StageName = '1. Prospect';
        Update Opp1;

        List<Opportunity_Status_Timer__c> oppTimer1 = 
            [Select Id, Prior_Status__c, Name, Elapsed_Time_Days__c, Elapsed_Time_Hours__c from Opportunity_Status_Timer__c 
             where RelatedOpportunity__c = :opp1.Id];
        */

 
        /*------------------------------------------------
          Change the Opp Stage to "2. Meeting Held"
        ------------------------------------------------*/
//        Opp1.StageName = '2. Sales Qualified';
//        Update Opp1;
//        List<Opportunity_Status_Timer__c> oppTimer2 = 
//            [Select Id, Prior_Status__c, Name, Elapsed_Time_Days__c, Elapsed_Time_Hours__c from Opportunity_Status_Timer__c 
//             where RelatedOpportunity__c = :opp1.Id];


        /*------------------------------------------------
           Change the Opp Stage to "1. Sales Qualified"
        ------------------------------------------------*/
//        Opp1.StageName = '1. Prospect';
//        Update Opp1;
//        List<Opportunity_Status_Timer__c> oppTimer3 = 
//            [Select Id, Prior_Status__c, Name, Elapsed_Time_Days__c, Elapsed_Time_Hours__c from Opportunity_Status_Timer__c 
//             where RelatedOpportunity__c = :opp1.Id];

        /*------------------------------------------------
          Change the Opp Stage to "3. Sales Qualified"
        ------------------------------------------------*/
//        Opp1.StageName = '3. Sales Qualified';
//        Update Opp1;
//        List<Opportunity_Status_Timer__c> oppTimer4 = 
//            [Select Id, Prior_Status__c, Name, Elapsed_Time_Days__c, Elapsed_Time_Hours__c from Opportunity_Status_Timer__c 
//             where RelatedOpportunity__c = :opp1.Id];       

    }
}