@isTest (seeAllData = true) public class PT_TaskValidationTest {
    @isTest static void DeliveryProcessTask1(){
        
        //Creat a case 
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('API Delivery Phase 0 Record Type').getRecordTypeId();
        Case testCase = new Case(Subject = 'testCase',
                                 RecordTypeId = recordTypeId);
        insert testCase;
        testCase.Delivery_Ticket__c = true;
        update testCase;
        
        //Test case: status changed from 'Not Completed' to 'Completed'
        Process_Task__c pt = new Process_Task__c(Subject__c = 'test',
                                                 Status__c = 'Not Started');
        insert pt;
        pt.Status__c = 'Completed';
        pt.Delivery_Ticket__c = testCase.Id;
        pt.Delivery_Task_Open__c = testCase.Id;
        update pt;
        
    }
    
    @isTest static void DeliveryProcessTask2(){
        //Creat a case 
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('API Delivery Phase 0 Record Type').getRecordTypeId();
        Case testCase = new Case(Subject = 'testCase',
                                 RecordTypeId = recordTypeId);
        insert testCase;
        testCase.Delivery_Ticket__c = true;
        update testCase;        
        
        //Test case: status changed from 'Completed' to new status that is not 'Completed' or 'Terminated'
        Process_Task__c pt2 = new Process_Task__c(Subject__c = 'test',
                                                  Status__c = 'Terminated');
        insert pt2;
        pt2.Status__c = 'Deferred';
        pt2.Delivery_Ticket__c = testCase.Id;
        pt2.Delivery_Task_Open__c = testCase.Id;
        update pt2;
    }
    
    @isTest static void OppProcessTask1(){
        //Create an opportunity
        Account testAcc = eNettTestUtility.createAccount('Test Account');
        Opportunity testOpp = eNettTestUtility.createOpportunity('Test Opp', testAcc.Id);
        
        //Test case: status changed from 'Not Completed' to 'Completed'
        Process_Task__c pt = new Process_Task__c(Subject__c = 'test',
                                                 Status__c = 'Not Started');
        insert pt;
        pt.Status__c = 'Completed';
        pt.Opportunity__c = testOpp.Id;
        pt.Opportunity_Task_Open__c= testOpp.Id;
        update pt;
    }
    
    @isTest static void OppProcessTask2(){
        //Create an opportunity
        Account testAcc = eNettTestUtility.createAccount('Test Account');
        Opportunity testOpp = eNettTestUtility.createOpportunity('Test Opp', testAcc.Id);
        
        //Test case: status changed from 'Not Completed' to 'Completed'
        Process_Task__c pt = new Process_Task__c(Subject__c = 'test',
                                                 Status__c = 'Terminated');
        insert pt;
        pt.Status__c = 'Deferred';
        pt.Opportunity__c = testOpp.Id;
        pt.Opportunity_Task_Open__c= testOpp.Id;
        update pt;
    }
    
    @isTest static void ContractProcessTask1(){
        //Create an opportunity
        Account testAcc = eNettTestUtility.createAccount('Test Account');
        Opportunity testOpp = eNettTestUtility.createOpportunity('Test Opp', testAcc.Id);
        eNett_Contract__c testContract = new eNett_Contract__c(Account_Name__c = testAcc.Id);
        insert testContract;
        //Test case: status changed from 'Not Completed' to 'Completed'
        Process_Task__c pt = new Process_Task__c(Subject__c = 'test',
                                                 Status__c = 'Not Started');
        insert pt;
        pt.Status__c = 'Completed';
        pt.eNett_Contract__c = testContract.Id;
        pt.eNett_Contract_Task_Open__c= testContract.Id;
        update pt;
    }
    
    @isTest static void ContractProcessTask2(){
        //Create an opportunity
        Account testAcc = eNettTestUtility.createAccount('Test Account');
        Opportunity testOpp = eNettTestUtility.createOpportunity('Test Opp', testAcc.Id);
        eNett_Contract__c testContract = new eNett_Contract__c(Account_Name__c = testAcc.Id);
        insert testContract;
        //Test case: status changed from 'Not Completed' to 'Completed'
        Process_Task__c pt = new Process_Task__c(Subject__c = 'test',
                                                 Status__c = 'Terminated');
        insert pt;
        pt.Status__c = 'Deferred';
        pt.eNett_Contract__c = testContract.Id;
        pt.eNett_Contract_Task_Open__c= testContract.Id;
        update pt;
    }
}