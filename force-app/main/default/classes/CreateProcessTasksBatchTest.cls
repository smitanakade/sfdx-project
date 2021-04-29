@isTest public class CreateProcessTasksBatchTest {
    @testSetup static void SetUpData(){
        Account testAcc = eNettTestUtility.createAccount('TestAccount');
        testAcc.eNett_products__c = 'VANs';
        Test.setCreatedDate(testAcc.Id, DateTime.newInstance(2018, 09, 25));
        update testAcc;
        Process_Task__c testOppPT = new Process_Task__c (Subject__c = 'Opportunity - Qualify Opportunity',
                                                         Account__c = testAcc.Id);
        insert testOppPT;
        
        Account testAcc2 = new Account (Name = 'TestAccount2', ECN__c ='100000',eNett_products__c = 'VANs');
        insert testAcc2;
        Test.setCreatedDate(testAcc.Id, DateTime.newInstance(2018, 09, 25));
        update testAcc2;
        
        Process_Task__c testOppPT2 = new Process_Task__c (Subject__c = 'Opportunity - Qualify Opportunity',
                                                          Account__c = testAcc2.Id);
        insert testOppPT2;
        Process_Task__c testAPPT = new Process_Task__c (Subject__c = 'Approve Account',
                                                        Account__c = testAcc2.Id);
        insert testAPPT;
    }
    
    @isTest static void testTaskNotExist(){
        Test.startTest();
        CreateProcessTasksBatch cptb = new CreateProcessTasksBatch();
        Id batchJobId = Database.executeBatch(cptb);
        Test.stopTest();
        
        Account assertAcc = [SELECT ID, Account_Type__c, eNett_Products__c, (SELECT Subject__c FROM Process_Tasks__r ORDER BY Subject__c) FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        System.debug('#####assertAcc ' + assertAcc);
        List<Process_Task__c> assertTask = [SELECT ID, Subject__c FROM Process_Task__c WHERE Account__c =: assertAcc.Id AND Subject__c = 'Approve Account'];
        System.assertEquals(1, assertTask.size());
    }
    
    @isTest static void testTaskExists(){
        Test.startTest();
        CreateProcessTasksBatch cptb = new CreateProcessTasksBatch();
        Id batchJobId = Database.executeBatch(cptb);
        Test.stopTest();
        
        Account assertAcc2 = [SELECT ID, Account_Type__c, eNett_Products__c, (SELECT Subject__c FROM Process_Tasks__r ORDER BY Subject__c) FROM Account WHERE Name = 'TestAccount2' LIMIT 1];
        List<Process_Task__c> assertTask = [SELECT ID, Subject__c FROM Process_Task__c WHERE Account__c =: assertAcc2.Id AND Subject__c = 'Approve Account'];
        System.assertEquals(1, assertTask.size());
    }
}