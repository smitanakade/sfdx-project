@isTest
public class TEST_ProcessTasks {
    

    @testSetup 
    static void setupCommonData(){

        System.debug('>>>>>>>>>> Creating Data');

        Account testAccount = TEST_DataFactory.createAccount();
        insert testAccount;
        System.assert(testAccount.Id != null, 'Account not inserted.');

        //Check if a contract was created
//      String contractId = [select Id from eNEtt_Contract__c where Account_Name__c = :testAccount.Id].Id;
//      System.assert(contractId != null, 'Contract not inserted.');

        Contact testContact = TEST_DataFactory.createContact(testAccount.Id);
        insert testContact;
    }

    /**********************************************************************************************
        Test Deal Arrangement Task.
    **********************************************************************************************/

    private static void createDATask(integer intAmnt ){


        Account a = [SELECT Id FROM Account WHERE Name = 'Account Test'];
        System.debug('>>>>>>>>>> Account = ' + a);


        //Check if an Opportunity was created
        String OpportunityId = [select Id from Opportunity where AccountId = :a.Id LIMIT 1].Id;
        System.assert(OpportunityId != null, 'Opportunity not inserted.');

        //Find the QO Task
        Process_Task__c QOTask = [select Id from Process_Task__c where Opportunity__c = :OpportunityId LIMIT 1];
        System.assert(QOTask.Id != null, 'QO Task not inserted.');

        // Complete the Qualify Opp Task
        QOTask.Registration_Type__c = 'AML Internal Registration';
        QOTask.Contract_Type__c ='Custom';
        QOTask.Attainable_TTV_Monthly__c = 1000;
        QOTask.Status__c = 'In Progress';
        update QOTask;

        QOTask.Status__c = 'Completed';
        update QOTask;

        //Check if a contract was created
        String contractId = [select Id from eNEtt_Contract__c where Account_Name__c = :a.Id].Id;
        System.assert(contractId != null, 'Contract not inserted.');

        //Find the Deal Arrangement Task
        Process_Task__c DATask = [select Id from Process_Task__c where eNett_Contract__c = :contractId and Subject__c = 'Contract - Deal Arrangement' LIMIT 1];
        System.assert(DATask.Id != null, 'DA Task not inserted.');

        DATask.Rebate_Type__c = 'Flat';
        DATask.Incentive_Type__c = '% of Interchange';
        DATask.Interchange_Amount__c = intAmnt;
        DATask.Agreement_Term_Years__c = 2;
        DATask.Chargeback_Processing_Fee__c = 2;
        DATask.Subscription_Fee__c = 2;
        DATask.Status__c = 'Completed';
        update DATask;


        // Delete to give some coverage to PT_noDeleteTask.trigger
        delete DATask;

    }

    /**********************************************************************************************
        Complete Deal Arrangement Tasks at different Levels.
    **********************************************************************************************/

    static testmethod void TEST_Trigger_TaskAfter_DA1() {
      //createDATask(2);
    }

    //@isTest static void TEST_Trigger_TaskAfter_DA2() {
    //  createDATask(30);
    //}

    //@isTest static void TEST_Trigger_TaskAfter_DA3() {
    //  createDATask(45);
    //}

    //@isTest static void TEST_Trigger_TaskAfter_DA4() {
    //  createDATask(55);
    //}
    
}