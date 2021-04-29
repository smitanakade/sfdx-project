global class CreateProcessTasksBatch implements Database.Batchable<sObject> {
    
    //Query to gather accounts that meet the criteria
    global integer recordsProcessed = 0;
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('SELECT Id, Account_Type__c, Name, eNett_Products__c, CreatedDate, (SELECT Subject__c FROM Process_Tasks__r ORDER BY Subject__c) FROM Account WHERE eNett_Products__c INCLUDES (\'VANs\')'+ 
                                        'AND (Account_Type__c = \'Customer\' OR Account_Type__c = \'Affiliate\') AND CreatedDate >= 2018-01-01T00:00:00Z AND CreatedDate <= 2018-10-05T00:00:00Z');
    }
    
    //Loop through each account's process tasks and check that none of them is an 'Approve Account' task
    global void execute (Database.BatchableContext bc, List<Account> scope){
        Group apQueue = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Account_Approval_Queue'];
        RecordType recId = [SELECT Id FROM RecordType WHERE DeveloperName = 'VANs_Account_Approval_Record_Type'];
        Set<Account> accsNeedPT = new Set<Account>();
        Integer taskExist = 0;
        if (!scope.isEmpty()){
            for (Account acc : scope){
                for (Process_Task__c pt : acc.Process_Tasks__r){
                    if (pt.Subject__c == 'Approve Account'){
                        taskExist ++;
                    }
                }
                if (taskExist == 0){
                    accsNeedPT.add(acc);
                }
                taskExist = 0;
            }
        }
        
        //Create process tasks
        List<Process_Task__c> ptList = new List<Process_Task__c>();
        for (Account acc : accsNeedPT){
            Process_Task__c pt = new Process_Task__c(Subject__c = 'Approve Account',
                                                     Related_Account_Type__c = acc.Account_Type__c,
                                                     RecordTypeId = recId.Id,
                                                     Account__c = acc.Id,
                                                     OwnerId = apQueue.Id,
                                                     Assigned_Date__c = Date.today(),
                                                     Due_Date__c = CalculateBusinessDays.AddBusinessDays(Date.today(), 2),
                                                     Related_Account__c = acc.Name,
                                                     Status__c = 'Backlog');
            ptList.add(pt);
        }
        
        //DML Operation starts
        if (ptList.size() > 0){
            SavePoint sp = Database.setSavepoint();
            try{
                Database.DMLOptions dmo = new Database.DMLOptions();
                dmo.OptAllOrNone = false;
                
                List<Database.SaveResult> saveResults = Database.insert(ptList, dmo);
                for (Database.SaveResult sr : saveResults){
                    if (!sr.isSuccess()){
                        for (Database.Error err : sr.getErrors()){
                            System.debug('####ERROR WHILE PROCESSING ACCOUNT: ' + err.getMessage());
                            System.debug('####ERROR STATUS CODE: ' + err.getStatusCode());
                            System.debug('####ERROR FIELDS: ' + err.getFields());
                        }
                    } else {
                        recordsProcessed++;
                    }
                }
            } catch (Exception e){
                Database.rollback(sp);
                System.debug('####ERROR ENCOUNTERED: ' + e.getMessage());
                throw e; 
            }
        }        
    }
    
    //send out an email once the process is completed
    global void finish (Database.BatchableContext bc){
		System.debug(recordsProcessed + 'records have been processed.');
    }
}