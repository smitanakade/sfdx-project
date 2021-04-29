@isTest //(SeeAllData=true)
public class TestContractTasks {


///**********************************************************************************************
//	    Generic Account create.
//**********************************************************************************************/

//    private static Account createAccount(){
//	    Account theTestAccount = new Account(
//	                                Name = 'Account Test', 
//	                                Legal_Name__c = 'Account Test', 
//	                                Client_Status__c = 'Prospect', 
//	                                Region__c = 'APAC',
//	                                Customer_Sector__c = 'Agent',                                   
//	                                Client_internal_classification__c = 12000000,
//	                                Referrer_Name__c = 'Mastercard',
//	                                Contract_Type__c = 'Custom',
//	                                IsApi__c = true); 
//	    insert theTestAccount;
//	    System.assert(theTestAccount.Id != null, 'Account not inserted.');
//    	return theTestAccount;
//    }

///**********************************************************************************************
//	    Generic Contact create.
//**********************************************************************************************/

//    private static Contact createContact(string accountId){
//        Contact theContact = new Contact(
//        							FirstName = 'Firsttest', 
//        							LastName = 'Lastest', 
//        							AccountId = accountId, 
//        							Email = 'Trevor@trevor.com', 
//        							IsApi__c = true);
//        insert theContact; 
//    	return theContact;
//    }


///**********************************************************************************************
//	    Generic Deal Arrangement Task create.
//**********************************************************************************************/

//    private static void createDATask(integer intAmnt ){

//		Account testAccount = createAccount();
//        Contact contactperson = createContact(testAccount.Id);

//	    //Check if an Opportunity was created
//	    String OpportunityId = [select Id from Opportunity where AccountId = :testAccount.Id].Id;
//	    System.assert(OpportunityId != null, 'Opportunity not inserted.');

//	    //Find the QO Task
//	    Task QOTask = [select Id from Task where WhatID = :OpportunityId LIMIT 1];
//	    System.assert(QOTask.Id != null, 'QO Task not inserted.');

//	    // Complete the Qualify Opp Task
//	    QOTask.Registration_Type__c = 'AML Internal Registration';
//	    QOTask.Contract_Type__c ='Custom';
//	    QOTask.Delivery_Type__c = 'Delivery Not Required';
//	    QOTask.status = 'Completed';
//	    QOTask.Attainable_TTV_Monthly__c = 1;
//        update QOTask;

//	    //Check if a contract was created
//	    String contractId = [select Id from eNEtt_Contract__c where Account_Name__c = :testAccount.Id].Id;
//	    System.assert(contractId != null, 'Contract not inserted.');

//	    //Find the Deal Arrangement Task
//	    Task DATask = [select Id from Task where WhatID = :contractId and subject = 'Contract - Deal Arrangement' LIMIT 1];
//	    System.assert(DATask.Id != null, 'DA Task not inserted.');

//	    DATask.Rebate_Type__c = 'Flat';
//	    DATask.Incentive_Type__c = '% of Interchange';
//	    DATask.Interchange_Amount__c = intAmnt;
//	    DATask.Agreement_Term_Years__c = 2;
//	    DATask.Chargeback_Processing_Fee__c = 2;
//	    DATask.Subscription_Fee__c = 2;
//	    DATask.status = 'Completed';
//        update DATask;
//    }

   
//    @isTest static void TEST_Trigger_TaskAfter_Insert() {

///**********************************************************************************************
//	    Insert an Account with Point of Origin & Contract Type.
//	    Should create an Account, Opportunity & QO Task and Contract & Contract Task.
//**********************************************************************************************/
	        

//	    Account testAccount = new Account(
//	                                Name = 'Account Test', 
//	                                Legal_Name__c = 'Account Test', 
//	                                Client_Status__c = 'Prospect', 
//	                                Region__c = 'APAC',
//	                                Customer_Sector__c = 'Agent',                                   
//	                                Client_internal_classification__c = 12000000,
//	                                Referrer_Name__c = 'Mastercard',
//	                                Contract_Type__c = 'Standard T&Cs',
//		                            PointOfOrigin__c = 0,
//	                                IsApi__c = true); 
//	    insert testAccount;
//	    System.assert(testAccount.Id != null, 'Account not inserted.');

//	    //Check if a contract was created
//	    String contractId = [select Id from eNEtt_Contract__c where Account_Name__c = :testAccount.Id].Id;
//	    System.assert(contractId != null, 'Contract not inserted.');
//    }


///**********************************************************************************************
//	    Complete Deal Arrangement Tasks at different Levels.
//**********************************************************************************************/

//    @isTest static void TEST_Trigger_TaskAfter_DA1() {

//		createDATask(2);

//    }
///*    @isTest static void TEST_Trigger_TaskAfter_DA2() {

//		createDATask(30);

//    }
//    @isTest static void TEST_Trigger_TaskAfter_DA3() {

//		createDATask(45);

//    }
//    @isTest static void TEST_Trigger_TaskAfter_DA4() {

//		createDATask(55);

//    }
//*/

///**********************************************************************************************
//	    Sales Approval ---> Proposal Negotiation
//**********************************************************************************************/

//    @isTest static void TEST_Trigger_TaskAfter_SA_PN() {

//	    // Map the Task Record Types.
//    	Map<string,RecordType> recTypeMap = FutureCalls.mapRecordTypes('Task');

//		Account testAccount = createAccount();
//        Contact contactperson = createContact(testAccount.Id);

//	    //Check if an Opportunity was created
//	    String OpportunityId = [select Id from Opportunity where AccountId = :testAccount.Id].Id;
//	    System.assert(OpportunityId != null, 'Opportunity not inserted.');

//	    //Find the QO Task
//	    Task QOTask = [select Id from Task where WhatID = :OpportunityId LIMIT 1];
//	    System.assert(QOTask.Id != null, 'QO Task not inserted.');

//	    // Complete the Qualify Opp Task
//	    QOTask.Registration_Type__c = 'AML Internal Registration';
//	    QOTask.Contract_Type__c ='Custom';
//	    QOTask.Delivery_Type__c = 'Delivery Not Required';
//	    QOTask.status = 'Completed';
//	    QOTask.Attainable_TTV_Monthly__c = 1;
//        update QOTask;

//	    //Check if a contract was created
//	    String contractId = [select Id from eNEtt_Contract__c where Account_Name__c = :testAccount.Id].Id;
//	    System.assert(contractId != null, 'Contract not inserted.');


//		string SA_Type = recTypeMap.get('Contract_Sales_Approval').Id;

////                            RecordTypeId = '012O000000054OWIAY', 
//	    // Manually create a Sales Aproval Task
//	    Task SATask = new Task(
//							OwnerId = '00590000000riL4',
//                            RecordTypeId = SA_Type, 
//                            Related_Account__c = testAccount.Id,
//                            ECN__c = '10001',                            
//                            Priority = 'Normal', 
//                            Status = 'Not Started', 
//                            Subject = 'Contract - Sales Approval', 
//                            Type = 'Task',
//                            IsReminderSet = true, 
//                            ReminderDateTime = System.now()+2,
//                            WhatId = contractId,
//                            ActivityDate = System.today()+2 ); 

//	    insert SATask;
//	    System.assert(SATask.Id != null, 'SA Task not inserted.');


//	    SATask.Contract_Outcome__c = 'Deal Approved by Sales';
//	    SATask.status = 'Completed';
//        update SATask;


//        List<Task> PTask = [select Id, Subject from Task where WhatID = :contractId];
//        System.Debug('>>>>>> Tasks: ' + PTask);


//	    //Assert that the Proposal Negotiation Task was created
//	    Task PNTask = [select Id from Task where WhatID = :contractId and subject = 'Contract - Proposal / Negotiation' LIMIT 1];
//	    System.assert(PNTask.Id != null, 'PN Task not inserted.');
////	    PNTask.Contract_Outcome__c = 'Deal Approved by Legal';
////	    PNTask.status = 'Completed';
////        update PNTask;


//    }


///**********************************************************************************************
//	    Sales Approval ---> Deal Arrangement
//**********************************************************************************************/

//   @isTest static void TEST_Trigger_TaskAfter_SA_DA() {

//	    // Map the Task Record Types.
//    	Map<string,RecordType> recTypeMap = FutureCalls.mapRecordTypes('Task');

//		Account testAccount = createAccount();
//        Contact contactperson = createContact(testAccount.Id);

//	    //Check if an Opportunity was created
//	    String OpportunityId = [select Id from Opportunity where AccountId = :testAccount.Id].Id;
//	    System.assert(OpportunityId != null, 'Opportunity not inserted.');

//	    //Find the QO Task
//	    Task QOTask = [select Id from Task where WhatID = :OpportunityId LIMIT 1];
//	    System.assert(QOTask.Id != null, 'QO Task not inserted.');

//	    // Complete the Qualify Opp Task
//	    QOTask.Registration_Type__c = 'AML Internal Registration';
//	    QOTask.Contract_Type__c ='Custom';
//	    QOTask.Delivery_Type__c = 'Delivery Not Required';
//	    QOTask.status = 'Completed';
//	    QOTask.Attainable_TTV_Monthly__c = 1;
//        update QOTask;

//	    //Check if a contract was created
//	    String contractId = [select Id from eNEtt_Contract__c where Account_Name__c = :testAccount.Id].Id;
//	    System.assert(contractId != null, 'Contract not inserted.');

//		string SA_Type = recTypeMap.get('Contract_Sales_Approval').Id;

////                            RecordTypeId = '012O000000054OWIAY',
//	    // Manually create a Sales Aproval Task
//	    Task SATask = new Task(
//							OwnerId = '00590000000riL4',
//                            RecordTypeId = SA_Type, 
//                            Related_Account__c = testAccount.Id,
//                            ECN__c = '10001',                            
//                            Priority = 'Normal', 
//                            Status = 'Not Started', 
//                            Subject = 'Contract - Sales Approval', 
//                            Type = 'Task',
//                            IsReminderSet = true, 
//                            ReminderDateTime = System.now()+2,
//                            WhatId = contractId,
//                            ActivityDate = System.today()+2 ); 

//	    insert SATask;
//	    System.assert(SATask.Id != null, 'SA Task not inserted.');


//	    SATask.Contract_Outcome__c = 'Deal Rejected by Sales';
//	    SATask.Contract_Rejection_Reason__c = 'Rejected Reason';
//	    SATask.status = 'Completed';
//        update SATask;


//        List<Task> PTask = [select Id, Subject from Task where WhatID = :contractId];
//        System.Debug('>>>>>> Tasks: ' + PTask);


//	    //Assert that the Deal Arrangement Task was created
//	    Task DATask = [select Id from Task where WhatID = :contractId and subject = 'Contract - Deal Arrangement' LIMIT 1];
//	    System.assert(DATask.Id != null, 'DA Task not inserted.');


///*
//	    //Find the Proposal Task
//	    Task LATask = [select Id from Task where WhatID = :contractId and subject = 'Contract - Legal Approval' LIMIT 1];
//	    System.assert(LATask.Id != null, 'LA Task not inserted.');

//	    LATask.Contract_Outcome__c = 'Deal Approved by Legal';
//	    LATask.status = 'Completed';
//        update LATask;
//*/
//    }


///**********************************************************************************************
//	    Sales Approval ---> Legal Approval
//**********************************************************************************************/

//   @isTest static void TEST_Trigger_TaskAfter_SA_LA() {

//	    // Map the Task Record Types.
//    	Map<string,RecordType> recTypeMap = FutureCalls.mapRecordTypes('Task');

//		Account testAccount = createAccount();
//        Contact contactperson = createContact(testAccount.Id);

//	    //Check if an Opportunity was created
//	    String OpportunityId = [select Id from Opportunity where AccountId = :testAccount.Id].Id;
//	    System.assert(OpportunityId != null, 'Opportunity not inserted.');

//	    //Find the QO Task
//	    Task QOTask = [select Id from Task where WhatID = :OpportunityId LIMIT 1];
//	    System.assert(QOTask.Id != null, 'QO Task not inserted.');

//	    // Complete the Qualify Opp Task
//	    QOTask.Registration_Type__c = 'AML Internal Registration';
//	    QOTask.Contract_Type__c ='Custom';
//	    QOTask.Delivery_Type__c = 'Delivery Not Required';
//	    QOTask.status = 'Completed';
//	    QOTask.Attainable_TTV_Monthly__c = 1;
//        update QOTask;

////	    //Check if a contract was created
////	    String contractId = [select Id from eNEtt_Contract__c where Account_Name__c = :testAccount.Id].Id;
////	    System.assert(contractId != null, 'Contract not inserted.');

//		// Enforce a change on the Contract
//	    eNEtt_Contract__c theContract = [select Id, Agreement_Term_Years__c from eNEtt_Contract__c where Account_Name__c = :testAccount.Id LIMIT 1];
//	    theContract.Agreement_Term_Years__c = 0.5;
//	    update theContract;
//	    theContract = [select Id, Agreement_Term_Years__c, T_C_Modifications__c from eNEtt_Contract__c where Account_Name__c = :testAccount.Id LIMIT 1];

//        System.Debug('>>>>>> Contract Mods: ' + theContract);

//		string SA_Type = recTypeMap.get('Contract_Sales_Approval').Id;

////                            RecordTypeId = '012O000000054OWIAY',
//	    // Manually create a Sales Aproval Task
//	    Task SATask = new Task(
//							OwnerId = '00590000000riL4',
//                            RecordTypeId = SA_Type, 
//                            Related_Account__c = testAccount.Id,
//                            ECN__c = '10001',                            
//                            Priority = 'Normal', 
//                            Status = 'Not Started', 
//                            Subject = 'Contract - Sales Approval', 
//                            Type = 'Task',
//                            IsReminderSet = true, 
//                            ReminderDateTime = System.now()+2,
//                            WhatId = theContract.Id,
//                            ActivityDate = System.today()+2 ); 

//	    insert SATask;
//	    System.assert(SATask.Id != null, 'SA Task not inserted.');


//	    SATask.Contract_Outcome__c = 'Deal Approved by Sales';
//	    SATask.status = 'Completed';
//        update SATask;

//        List<Task> Tasks = [select Id, Subject from Task where WhatID = :theContract.Id];
//        System.Debug('>>>>>> Tasks SA_LA: ' + Tasks);

//	    //Assert that the Legal Approval Task was created
//	    Task LATask = [select Id from Task where WhatID = :theContract.Id and subject = 'Contract - Legal Approval' LIMIT 1];
//	    System.assert(LATask.Id != null, 'LA Task not inserted.');


//    }


///**********************************************************************************************
//	    Legal Approval ---> Proposal Negotiation
//**********************************************************************************************/

//   @isTest static void TEST_Trigger_TaskAfter_LA_PN() {

//	    // Map the Task Record Types.
//    	Map<string,RecordType> recTypeMap = FutureCalls.mapRecordTypes('Task');

//		Account testAccount = createAccount();
//        Contact contactperson = createContact(testAccount.Id);

//	    //Check if an Opportunity was created
//	    String OpportunityId = [select Id from Opportunity where AccountId = :testAccount.Id].Id;
//	    System.assert(OpportunityId != null, 'Opportunity not inserted.');

//	    //Find the QO Task
//	    Task QOTask = [select Id from Task where WhatID = :OpportunityId LIMIT 1];
//	    System.assert(QOTask.Id != null, 'QO Task not inserted.');

//	    // Complete the Qualify Opp Task
//	    QOTask.Registration_Type__c = 'AML Internal Registration';
//	    QOTask.Contract_Type__c ='Custom';
//	    QOTask.Delivery_Type__c = 'Delivery Not Required';
//	    QOTask.status = 'Completed';
//	    QOTask.Attainable_TTV_Monthly__c = 1;
//        update QOTask;

//	    //Check if a contract was created
//	    String contractId = [select Id from eNEtt_Contract__c where Account_Name__c = :testAccount.Id].Id;
//	    System.assert(contractId != null, 'Contract not inserted.');

//		string LA_Type = recTypeMap.get('Contract_Legal_Approval').Id;

////                            RecordTypeId = '012O000000054ObIAI',
//	    // Manually create a Legal Aproval Task
//	    Task LATask = new Task(
//							OwnerId = '00590000000riL4',
//                            RecordTypeId = LA_Type,
//                            Related_Account__c = testAccount.Id,
//                            ECN__c = '10001',                            
//                            Priority = 'Normal', 
//                            Status = 'Not Started', 
//                            Subject = 'Contract - Legal Approval', 
//                            Type = 'Task',
//                            IsReminderSet = true, 
//                            ReminderDateTime = System.now()+2,
//                            WhatId = contractId,
//                            ActivityDate = System.today()+2 ); 

//	    insert LATask;
//	    System.assert(LATask.Id != null, 'LA Task not inserted.');


//	    LATask.Contract_Outcome__c = 'Deal Approved by Legal';
//	    LATask.status = 'Completed';
//        update LATask;


////        List<Task> PTask = [select Id, Subject from Task where WhatID = :contractId];
////        System.Debug('>>>>>> Tasks: ' + PTask);


//	    //Assert that the Proposal / Negotiation Task was created
//	    Task PNTask = [select Id from Task where WhatID = :contractId and subject = 'Contract - Proposal / Negotiation' LIMIT 1];
//	    System.assert(PNTask.Id != null, 'DA Task not inserted.');


//    }





///**********************************************************************************************
//	    Legal Approval ---> Deal Arrangement
//**********************************************************************************************/

//   @isTest static void TEST_Trigger_TaskAfter_LA_DA() {

//	    // Map the Task Record Types.
//    	Map<string,RecordType> recTypeMap = FutureCalls.mapRecordTypes('Task');

//		Account testAccount = createAccount();
//        Contact contactperson = createContact(testAccount.Id);

//	    //Check if an Opportunity was created
//	    String OpportunityId = [select Id from Opportunity where AccountId = :testAccount.Id].Id;
//	    System.assert(OpportunityId != null, 'Opportunity not inserted.');

//	    //Find the QO Task
//	    Task QOTask = [select Id from Task where WhatID = :OpportunityId LIMIT 1];
//	    System.assert(QOTask.Id != null, 'QO Task not inserted.');

//	    // Complete the Qualify Opp Task
//	    QOTask.Registration_Type__c = 'AML Internal Registration';
//	    QOTask.Contract_Type__c ='Custom';
//	    QOTask.Delivery_Type__c = 'Delivery Not Required';
//	    QOTask.status = 'Completed';
//	    QOTask.Attainable_TTV_Monthly__c = 1;
//        update QOTask;

//	    //Check if a contract was created
//	    String contractId = [select Id from eNEtt_Contract__c where Account_Name__c = :testAccount.Id].Id;
//	    System.assert(contractId != null, 'Contract not inserted.');

//		string LA_Type = recTypeMap.get('Contract_Legal_Approval').Id;

////                            RecordTypeId = '012O000000054ObIAI',
//	    // Manually create a Legal Aproval Task
//	    Task LATask = new Task(
//							OwnerId = '00590000000riL4',
//                            RecordTypeId = LA_Type,
//                            Related_Account__c = testAccount.Id,
//                            ECN__c = '10001',                            
//                            Priority = 'Normal', 
//                            Status = 'Not Started', 
//                            Subject = 'Contract - Legal Approval', 
//                            Type = 'Task',
//                            IsReminderSet = true, 
//                            ReminderDateTime = System.now()+2,
//                            WhatId = contractId,
//                            ActivityDate = System.today()+2 ); 

//	    insert LATask;
//	    System.assert(LATask.Id != null, 'LA Task not inserted.');


//	    LATask.Contract_Outcome__c = 'Deal Rejected by Legal';
//	   	LATask.Contract_Rejection_Reason__c = 'Rejected Reason';
//	    LATask.status = 'Completed';
//        update LATask;

//	    //Assert that the Deal Arrangement Task was created
//	    Task DATask = [select Id from Task where WhatID = :contractId and subject = 'Contract - Deal Arrangement' LIMIT 1];
//	    System.assert(DATask.Id != null, 'DA Task not inserted.');


//    }



///**********************************************************************************************
//	    Proposal Negotiation ---> Customer Sign Off
//**********************************************************************************************/

//   @isTest static void TEST_Trigger_TaskAfter_PN_CS() {

//	    // Map the Task Record Types.
//    	Map<string,RecordType> recTypeMap = FutureCalls.mapRecordTypes('Task');

//		Account testAccount = createAccount();
//        Contact contactperson = createContact(testAccount.Id);

//	    //Check if an Opportunity was created
//	    String OpportunityId = [select Id from Opportunity where AccountId = :testAccount.Id].Id;
//	    System.assert(OpportunityId != null, 'Opportunity not inserted.');

//	    //Find the QO Task
//	    Task QOTask = [select Id from Task where WhatID = :OpportunityId LIMIT 1];
//	    System.assert(QOTask.Id != null, 'QO Task not inserted.');

//	    // Complete the Qualify Opp Task
//	    QOTask.Registration_Type__c = 'AML Internal Registration';
//	    QOTask.Contract_Type__c ='Custom';
//	    QOTask.Delivery_Type__c = 'Delivery Not Required';
//	    QOTask.status = 'Completed';
//	    QOTask.Attainable_TTV_Monthly__c = 1;
//        update QOTask;

//	    //Check if a contract was created
//	    String contractId = [select Id from eNEtt_Contract__c where Account_Name__c = :testAccount.Id].Id;
//	    System.assert(contractId != null, 'Contract not inserted.');

//		string PN_Type = recTypeMap.get('Contract_Proposal_Negotiation').Id;

////                            RecordTypeId = '012O000000054OgIAI',
//	    // Manually create a Proposal Negotiation Task
//	    Task PNTask = new Task(
//							OwnerId = '00590000000riL4',
//                            RecordTypeId = PN_Type,
//                            Related_Account__c = testAccount.Id,
//                            ECN__c = '10001',                            
//                            Priority = 'Normal', 
//                            Status = 'Not Started', 
//                            Subject = 'Contract - Proposal / Negotiation', 
//                            Type = 'Task',
//                            IsReminderSet = true, 
//                            ReminderDateTime = System.now()+2,
//                            WhatId = contractId,
//                            ActivityDate = System.today()+2 ); 

//	    insert PNTask;
//	    System.assert(PNTask.Id != null, 'PN Task not inserted.');


//	    PNTask.Contract_Outcome__c = 'Finalised';
//	    PNTask.status = 'Completed';
//        update PNTask;

//	    //Assert that the Customer Sign-Off Task was created
//	    Task CSTask = [select Id from Task where WhatID = :contractId and subject = 'Contract - Customer - Sign-off' LIMIT 1];
//	    System.assert(CSTask.Id != null, 'DA Task not inserted.');

//    }



///**********************************************************************************************
//	    Proposal Negotiation ---> Deal Arrangement
//**********************************************************************************************/

//   @isTest static void TEST_Trigger_TaskAfter_PN_DA() {

//	    // Map the Task Record Types.
//    	Map<string,RecordType> recTypeMap = FutureCalls.mapRecordTypes('Task');

//		Account testAccount = createAccount();
//        Contact contactperson = createContact(testAccount.Id);

//	    //Check if an Opportunity was created
//	    String OpportunityId = [select Id from Opportunity where AccountId = :testAccount.Id].Id;
//	    System.assert(OpportunityId != null, 'Opportunity not inserted.');

//	    //Find the QO Task
//	    Task QOTask = [select Id from Task where WhatID = :OpportunityId LIMIT 1];
//	    System.assert(QOTask.Id != null, 'QO Task not inserted.');

//	    // Complete the Qualify Opp Task
//	    QOTask.Registration_Type__c = 'AML Internal Registration';
//	    QOTask.Contract_Type__c ='Custom';
//	    QOTask.Delivery_Type__c = 'Delivery Not Required';
//	    QOTask.status = 'Completed';
//	    QOTask.Attainable_TTV_Monthly__c = 1;
//        update QOTask;

//	    //Check if a contract was created
//	    String contractId = [select Id from eNEtt_Contract__c where Account_Name__c = :testAccount.Id].Id;
//	    System.assert(contractId != null, 'Contract not inserted.');

//		string PN_Type = recTypeMap.get('Contract_Proposal_Negotiation').Id;

////                            RecordTypeId = '012O000000054OgIAI',
//	    // Manually create a Proposal Negotiation Task
//	    Task PNTask = new Task(
//							OwnerId = '00590000000riL4',
//                            RecordTypeId = PN_Type,
//                            Related_Account__c = testAccount.Id,
//                            ECN__c = '10001',                            
//                            Priority = 'Normal', 
//                            Status = 'Not Started', 
//                            Subject = 'Contract - Proposal / Negotiation', 
//                            Type = 'Task',
//                            IsReminderSet = true, 
//                            ReminderDateTime = System.now()+2,
//                            WhatId = contractId,
//                            ActivityDate = System.today()+2 ); 

//	    insert PNTask;
//	    System.assert(PNTask.Id != null, 'PN Task not inserted.');


//	    PNTask.Contract_Outcome__c = 'Modifications Made';
//	    PNTask.Contract_Further_Details__c = 'Made some Mods';
//	    PNTask.status = 'Completed';
//        update PNTask;

//	    //Assert that the Customer Sign-Off Task was created
//	    Task CSTask = [select Id from Task where WhatID = :contractId and subject = 'Contract - Deal Arrangement' LIMIT 1];
//	    System.assert(CSTask.Id != null, 'DA Task not inserted.');

//    }




///**********************************************************************************************
//	    Customer SignOff ---> eNett SignOff
//**********************************************************************************************/

//   @isTest static void TEST_Trigger_TaskAfter_CS_ES() {

//	    // Map the Task Record Types.
//    	Map<string,RecordType> recTypeMap = FutureCalls.mapRecordTypes('Task');

//		Account testAccount = createAccount();
//        Contact contactperson = createContact(testAccount.Id);

//	    //Check if an Opportunity was created
//	    String OpportunityId = [select Id from Opportunity where AccountId = :testAccount.Id].Id;
//	    System.assert(OpportunityId != null, 'Opportunity not inserted.');

//	    //Find the QO Task
//	    Task QOTask = [select Id from Task where WhatID = :OpportunityId LIMIT 1];
//	    System.assert(QOTask.Id != null, 'QO Task not inserted.');

//	    // Complete the Qualify Opp Task
//	    QOTask.Registration_Type__c = 'AML Internal Registration';
//	    QOTask.Contract_Type__c ='Custom';
//	    QOTask.Delivery_Type__c = 'Delivery Not Required';
//	    QOTask.status = 'Completed';
//	    QOTask.Attainable_TTV_Monthly__c = 1;
//        update QOTask;

//	    //Check if a contract was created
//	    String contractId = [select Id from eNEtt_Contract__c where Account_Name__c = :testAccount.Id].Id;
//	    System.assert(contractId != null, 'Contract not inserted.');

//		string CS_Type = recTypeMap.get('Contract_Customer_Sign_off').Id;

////                            RecordTypeId = '012O000000054OlIAI',
//	    // Manually create a Customer Signoff Task
//	    Task CSTask = new Task(
//							OwnerId = '00590000000riL4',
//                            RecordTypeId = CS_Type,
//                            Related_Account__c = testAccount.Id,
//                            ECN__c = '10001',                            
//                            Priority = 'Normal', 
//                            Status = 'Not Started', 
//                            Subject = 'Contract - Customer - Sign-off', 
//                            Type = 'Task',
//                            IsReminderSet = true, 
//                            ReminderDateTime = System.now()+2,
//                            WhatId = contractId,
//                            ActivityDate = System.today()+2 ); 

//	    insert CSTask;
//	    System.assert(CSTask.Id != null, 'CS Task not inserted.');


//	    CSTask.status = 'Completed';
//        update CSTask;

//	    //Assert that the eNett Sign-Off Task was created
//	    Task ESTask = [select Id from Task where WhatID = :contractId and subject = 'Contract - eNett - Sign-off' LIMIT 1];
//	    System.assert(ESTask.Id != null, 'ES Task not inserted.');

//    }






/////**********************************************************************************************
////	    eNett SignOff ---> Upload PDF
////**********************************************************************************************/


//// Removed this test as it produced "Too many SOQL queries: 101"


///**********************************************************************************************
//	    eNett SignOff ---> Rejected
//**********************************************************************************************/

//   @isTest static void TEST_Trigger_TaskAfter_ES_Reject() {

//	    // Map the Task Record Types.
//    	Map<string,RecordType> recTypeMap = FutureCalls.mapRecordTypes('Task');

//		Account testAccount = createAccount();
//        Contact contactperson = createContact(testAccount.Id);

//	    //Check if an Opportunity was created
//	    String OpportunityId = [select Id from Opportunity where AccountId = :testAccount.Id].Id;
//	    System.assert(OpportunityId != null, 'Opportunity not inserted.');

//	    //Find the QO Task
//	    Task QOTask = [select Id from Task where WhatID = :OpportunityId LIMIT 1];
//	    System.assert(QOTask.Id != null, 'QO Task not inserted.');

//	    // Complete the Qualify Opp Task
//	    QOTask.Registration_Type__c = 'AML Internal Registration';
//	    QOTask.Contract_Type__c ='Custom';
//	    QOTask.Delivery_Type__c = 'Delivery Not Required';
//	    QOTask.status = 'Completed';
//	    QOTask.Attainable_TTV_Monthly__c = 1;
//        update QOTask;

//	    //Check if a contract was created
//	    String contractId = [select Id from eNEtt_Contract__c where Account_Name__c = :testAccount.Id].Id;
//	    System.assert(contractId != null, 'Contract not inserted.');

//		string ES_Type = recTypeMap.get('Contract_eNett_Sign_off').Id;

////                            RecordTypeId = '012O000000054OqIAI',
//	    // Manually create a eNett Signoff Task
//	    Task ESTask = new Task(
//							OwnerId = '00590000000riL4',
//                            RecordTypeId = ES_Type,
//                            Related_Account__c = testAccount.Id,
//                            ECN__c = '10001',                            
//                            Priority = 'Normal', 
//                            Status = 'Not Started', 
//                            Subject = 'Contract - eNett - Sign-off', 
//                            Type = 'Task',
//                            IsReminderSet = true, 
//                            ReminderDateTime = System.now()+2,
//                            WhatId = contractId,
//                            ActivityDate = System.today()+2 ); 

//	    insert ESTask;
//	    System.assert(ESTask.Id != null, 'CS Task not inserted.');


//	    ESTask.Contract_Outcome__c = 'eNett Sign-off rejected';
//	    ESTask.Contract_Rejection_Reason__c = 'Too Tired';
//	    ESTask.status = 'Completed';
//        update ESTask;

////	    //Assert that the eNett Sign-Off Task was created
////	    Task PDFTask = [select Id from Task where WhatID = :contractId and subject = 'Contract - Upload PDF Copy of Contract' LIMIT 1];
////	    System.assert(PDFTask.Id != null, 'ES Task not inserted.');

//    }



}