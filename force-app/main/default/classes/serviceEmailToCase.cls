@isTest
public class serviceEmailToCase{
    
   
    Case serviceTicket;
    
    static testMethod void testUpdate(){
    
        Account testaccount = new Account(Name = 'Account Test', Legal_Name__c = 'Account Test', 
        Client_Status__c = 'Prospect', IntegratorModifiedDate__c = system.now(), IsApi__c = true, Due_Diligence_Completed__c = System.today()-56 ); //, Client_internal_classification__c = 100000 );
        insert testaccount;

        Contact contactperson = new Contact(FirstName = 'Firsttest', LastName = 'Lastest', AccountId = testaccount.id, IsApi__c = true);
        insert contactperson ; 
        
        System.debug('Start');

        String queueId = [select Id from Group where Name = 'New Ticket Queue' and Type = 'Queue'].Id;

                
        
        Case serviceCase = new Case (Subject = 'Test Subject', Origin = 'Email', Type = 'Task', Status = 'New', ContactId = contactperson.Id, OwnerId = queueId);
        insert serviceCase;
        
        // Update the case owner to New Ticket Assignement Queue
        serviceCase.OwnerId = queueId;
        update serviceCase;
        
        System.debug('The Queue Case Owner id is ' + [Select OwnerId from Case where Case.Id = :serviceCase.Id]);
        
        
                    
        String profileId =  [select id from profile where name='Stefanini Service Desk User'].Id; 
        String roleId = [select id from UserRole where name='Global Service Desk Level 1'].Id;   
        String stefId = [select Id from User where ProfileId = :profileId AND UserRoleId = :roleId LIMIT 1].Id;
        
        System.debug('Inserted Stefanini User' + stefId );
        
        //Updating the Case owner to Stefanini user  
        serviceCase.OwnerId = stefId;
        update serviceCase;
        
        //System.debug('The User Case Owner id is ' + [Select OwnerId from Case where Case.Id = :serviceCase.Id]);
        
        //Checking the case status and KPI
        Case testCase = [Select Status, KPI_Met__c from Case where Case.Id = :serviceCase.Id];
        //System.assertEquals('Open', testCase.Status, 'Error: The Case status has not changed to open');
        
        //System.debug('The Status is ' + testCase.Status + ' and KPI is ' + testCase.KPI_Met__c );
        //System.debug('The Case Status is ' + serviceCase.Status + ' and KPI is ' + serviceCase.KPI_Met__c );
        
        
        // Case escalation to Service Desk 1
        
        queueId = [select Id from Group where Name = 'Global Service Desk Level 1' and Type = 'Queue'].Id;     
        testCase.OwnerId = queueId;
        update testCase ;
            
        System.assertEquals(queueId, testCase.OwnerId, 'Error: The Case Owner Id is not Case Escalation Service Desk 1');
        //System.debug('The queue id is ' + queueId + ' and the queue case owner id is ' + [Select OwnerId from Case where Case.Id = :testCase.Id] + ' the case status is ' + testCase.Status  );        
        
        List<GroupMember> users = [Select UserOrGroupId From GroupMember where GroupId =:queueId LIMIT 1];
        //System.debug('The size is ' + users.size());
        return;
        
        //Assigning to queue members if queue members are present
        if(users.size() > 0){
          for(GroupMember gm: users){
              queueId = gm.Id;
          }
          testCase.OwnerId = queueId;
          update testCase ;
        }
        
        // Case escalation to Service Desk 2
        queueId = [select Id from Group where Name = 'Global Service Desk Level 2' and Type = 'Queue'].Id;     
        System.debug('The queue Id is ' + queueId);
        testCase.OwnerId = queueId;
        update testCase ;
        
        //System.debug('The queue id in Service Desk Level 2 ' + queueId + ' and the queue case owner id is ' + [Select OwnerId from Case where Case.Id = :testCase.Id] + ' the case status is ' + testCase.Status  );        
        System.assertEquals(queueId, testCase.OwnerId, 'Error: TheCase is not assigned to Global Service Desk Level 2');
        
        
    
    }
    
    
}