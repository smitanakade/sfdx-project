/*
* Parent GDV Processor runs that aggregate all the YTD GDV sums from child to their ultimate parents
* Then it will also update the corresponding customer record
* Ticket: SF-5230
* Author: Ronnie Yang
*/
global class ParentGDVProcessor implements Database.Batchable<sObject>, Database.Stateful{
    // instance member to retain state across transactions
    global Integer recordsProcessed = 0;
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, Yearly_Actual__c, Legal_Parent__c, Children_Yearly_Actual_USD__c, Customer__c ' +
            'FROM Account ' +
            'WHERE Account_Status__c = \'Active\' ' + 
            'AND eNett_Products__c INCLUDES (\'VANs\') '
        );
    }
    global void execute(Database.BatchableContext bc, List<Account> scope){
        Map<Id, Account> accountMap = new Map<Id,Account>(scope);
        // ---  *** Part 1: Aggregating total GDV from children all the way to their parents *** ---
        
        //childAccountMap -- get a map of all accounts that have no children (bottom of the tree *ultimate children)
        Map<Id, Account> childAccountMap = accountMap.clone();
        
        for(Account a: accountMap.values()){
            if(a.Legal_Parent__c != null){
                childAccountMap.remove(a.Legal_Parent__c);
            }
            //reset calculation
            a.Children_Yearly_Actual_USD__c = 0;
        }
        
        if(childAccountMap.size()>0){
            Map<Id,Account> mapToLoopThrough = childAccountMap.clone();
            Map<Id,Account> nextLevelParentMap = new Map<Id,Account>();
            while(mapToLoopThrough.size()>0){
                for(Account a: mapToLoopThrough.values()){
                    Account parent = accountMap.get(a.Legal_Parent__c);
                    if(parent != null){
                        parent.Children_Yearly_Actual_USD__c += a.Children_Yearly_Actual_USD__c == null ? 0 : a.Children_Yearly_Actual_USD__c;
                        parent.Children_Yearly_Actual_USD__c += a.Yearly_Actual__c == null ? 0 : a.Yearly_Actual__c;
                        nextLevelParentMap.put(parent.Id, parent);
                    }
                }
                
                mapToLoopThrough = nextLevelParentMap.clone();
                nextLevelParentMap.clear();
            }
            
        }
        
        // ---  *** Part 2: Update the corresponding customer record *** ---
        Map<Id, Account> accountMapByCustomerId = new Map<Id, Account>();
        for(Account a: accountMap.values()){
            if(a.Customer__c != null){
                accountMapByCustomerId.put(a.Customer__c, a);
            }
        }
        List<Customer__c> customers = [SELECT Id, Annual_GDV__c
                                       FROM Customer__c
                                       WHERE Id =: accountMapByCustomerId.keySet()];
        
        for(Customer__c c : customers){
            Account referenceAccount = accountMapByCustomerId.get(c.Id);
            if(referenceAccount != null){
                c.Annual_GDV__c = referenceAccount.Yearly_Actual__c == null ? 0 : referenceAccount.Yearly_Actual__c;
                c.Annual_GDV__c += referenceAccount.Children_Yearly_Actual_USD__c == null ? 0 : referenceAccount.Children_Yearly_Actual_USD__c;
            }
        }
        
        // ---  *** Part 3: Update *** --- 
        //removing child accounts from map as child accounts won't have parent gdv total
        accountMap.keySet().removeAll(childAccountMap.keyset());
        System.debug(accountMap.values());
        if(accountMap.values().size() > 0){
            SavePoint sp = Database.setSavepoint();
            try{
                Database.DMLOptions dmo = new Database.DMLOptions();
                //allowing partial processing
                dmo.optAllOrNone = false;
                
                List<Database.SaveResult> saveResults = Database.update(accountMap.values(), dmo);
                for(Database.SaveResult saveResult : saveResults){
                    if(!saveResult.isSuccess()){
                        for(Database.Error err: saveResult.getErrors()){
                            System.debug('####ERROR WHILE PROCESSING PARENT GDV TOTAL: ' + err.getMessage());
                        }
                    }
                    else
                        recordsProcessed ++;
                }
            }catch (Exception e){
                //rollback if something else is wrong
                Database.rollback(sp);
                System.debug('####ERROR ENCOUNTERED: ' + e.getMessage());
                throw e;
            }
        }
        if(customers.size() > 0){
            SavePoint sp = Database.setSavepoint();
            try{
                Database.DMLOptions dmo = new Database.DMLOptions();
                //allowing partial processing
                dmo.optAllOrNone = false;
                
                List<Database.SaveResult> saveResults = Database.update(customers, dmo);
                for(Database.SaveResult saveResult : saveResults){
                    if(!saveResult.isSuccess()){
                        for(Database.Error err: saveResult.getErrors()){
                            System.debug('####ERROR WHILE PROCESSING GRANDPARENT GDV TOTAL: ' + err.getMessage());
                        }
                    }
                    else
                        recordsProcessed ++;
                }
            }catch (Exception e){
                //rollback if something else is wrong
                Database.rollback(sp);
                System.debug('####ERROR ENCOUNTERED: ' + e.getMessage());
                throw e;
            }
        }
    }   
    global void finish(Database.BatchableContext bc){
        AsyncApexJob job = [SELECT Id, CompletedDate, JobItemsProcessed, NumberOfErrors, Status, TotalJobItems
                            FROM AsyncApexJob
                            WHERE Id =: bc.getJobId()
                            LIMIT 1];
        //inform devs of the result via email
        List<Group> devGroup = [SELECT Id,DeveloperName FROM Group WHERE DeveloperName LIKE '%System_Admin_Developer%' LIMIT 1];
        List<GroupMember> devGroupMembers = [SELECT GroupId,Id,UserOrGroupId FROM GroupMember WHERE GroupId =: devGroup];
        List<Id> devIdList = new List<Id>();
        for (GroupMember gm : devGroupMembers){
            devIdList.add(gm.UserOrGroupId);
        }
        List<User> devs = [SELECT Id, ProfileId, Email FROM User WHERE Id IN: devIdList];
        List<String> emailList = new List<String>();
        for (User u : devs){
            emailList.add(u.Email);
        }
        String Subject = 'Daily Parent GDV Processor Results';
        String Content = 'Job ' + job.Id + ' ran on ' + job.CompletedDate + ' with the status *' + job.Status + '*. ' + recordsProcessed + ' records were processed.';
        //Send emails to users
        EmailUtils.sendMail(emailList, Subject, Content);
    }
}