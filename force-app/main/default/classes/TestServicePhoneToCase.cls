@isTest
public class TestServicePhoneToCase{
   
    static testMethod void testUpdate(){
        FutureCalls.forceFutureCalls = true; //Remember to put this back in the test method
        User saUser = [ select Id from User where Id = :UserInfo.getUserId() ];

        case serviceCase = null;
        string queueId = null;
        
        RecordType accRT = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND NAME ='Customer'];  
        Account testaccount = new Account(Name = 'Account Test', Legal_Name__c = 'Account Test', Client_Status__c = 'Prospect', DD_Completed_Date__c = system.today()-56, RecordTypeId = accRT.Id );
        insert testaccount;

        Contact contactperson = new Contact(FirstName = 'Firsttest', LastName = 'Lastest', AccountId = testaccount.id, IsApi__c = true);
        insert contactperson ; 
        
         
        string profileId =  [select id from profile where name='Stefanini Service Desk User'].Id; 
        string roleId = [select id from UserRole where name='Global Service Desk Level 1'].Id;   
        string owner = [select Id from User where ProfileId = :profileId AND UserRoleId = :roleId AND ISACTIVE =:TRUE LIMIT 1].Id;
             
        User runAsUser = [Select Id from User where Id = :owner];
        system.runAs (runAsUser){
            serviceCase = new Case (Subject = 'Test Subject', Origin = 'Phone', Type = 'Task', Status = 'Open', ContactId = contactperson.Id, Priority = 'Not None');
            insert serviceCase;
            
            //Checking the first owner field update
            serviceCase = [Select First_Ownership__c  from Case where Case.Id = :serviceCase.Id];
            //system.debug('The First Owner is  ' + serviceCase.First_Ownership__c );
            Boolean firstownership = !String.isEmpty(serviceCase.First_Ownership__c);
            system.assert(firstownership, 'Error: The first ownership is not entered.'); 
            
            
            // Case escalation to Service Desk 1
            queueId = [select Id from Group where Name = 'Global Service Desk Level 1' and Type = 'Queue'].Id;     
            serviceCase.OwnerId = queueId;
            update serviceCase ;
            //system.Debug('Service case owner updated to Global Service Desk Level 1:' + serviceCase);        
                        
            system.assertEquals(queueId, serviceCase.OwnerId, 'Error: The Case Owner Id is not Case Escalation Service Desk 1');
            //system.debug('The queue id is ' + queueId + ' and the queue case owner id is ' + [Select OwnerId from Case where Case.Id = :serviceCase.Id] + ' the case status is ' + serviceCase.Status  );        
        } 
           
        
        system.runAs(saUser){
            
            //Assigning members of Global Service Desk Level 1
            //SF-5277 27/10/2018 Jasmine - No need to re-query the owner as this has been done above
            //owner = [select Id from User where profileId = :profileId AND ISACTIVE = TRUE LIMIT 1].Id;
            //runAsUser = [Select Id from User where Id = :owner];
              
            //system.debug('Global Service Desk Level 1 User id ' + owner );
            serviceCase.OwnerId = owner ;
            update serviceCase;
            //system.Debug('Service case owner updated to Global Service Desk Level 1 User:' + serviceCase);       
            system.assertEquals(owner , serviceCase.OwnerId, 'Error: The Case has not been assigned to Global Service Desk Level 1');
        }
        
         // Running as Serivce Desk Level 1 User
        system.runAs (runAsUser){                
            //Checking Ticket Service level and ECN    
            serviceCase = [Select Level_2_Counter__c, Level_3_Counter__c, Ticket_Service_Level__c, AccountECN__c, Assignee_Service_Level__c, Level_1_Counter__c from case where Id =: serviceCase.Id];
            
            system.assertEquals(testaccount.ECN__c, serviceCase.AccountECN__c, 'Error: The Account ECN does not match Case ECN');
            system.assertEquals(1, serviceCase.Ticket_Service_Level__c, 'Error the Ticket Service Level should be 1');
            
            //system.debug('The Ticket Service level is Global Service Desk Level 1 Id ' + serviceCase.Ticket_Service_Level__c);
            //system.Assert(FutureCalls.IsServiceCloud(serviceCase), 'Error: The Ticket is not assigned to a Service Cloud Record Type');
            system.assertEquals(testaccount.ECN__c, serviceCase.AccountECN__c, 'Error: The Account ECN does not match Case ECN');
            system.assertEquals(1, serviceCase.Ticket_Service_Level__c, 'Error the Ticket Service Level should be 1');
            system.assertEquals('Service Desk Level 1', serviceCase.Assignee_Service_Level__c, 'Error: The Assgines Service level should be Service Desk Level 1');
            system.assertEquals(1, serviceCase.Level_1_Counter__c, 'Error: The Level 1 Counter do not match');
            system.assertEquals(0, serviceCase.Level_2_Counter__c, 'Error: The Level 2 Counter do not match');
            system.assertEquals(0, serviceCase.Level_3_Counter__c, 'Error: The Level 3 Counter do not match');
            
            system.debug('The Ticket Service level is Global Service Desk Level 1 Id ' + serviceCase.Ticket_Service_Level__c);
            
            // Case escalation to Service Desk 2 - this is by user allocation (not by setting the queue, even though we also set this)
            queueId = [select Id from Group where Name = 'Global Service Desk Level 2' and Type = 'Queue'].Id;     
            system.debug('The queue Id is ' + queueId);
            serviceCase.OwnerId = queueId;
            //system.Debug('Service case owner updated to Global Service Desk Level 2:' + serviceCase);       
            //system.debug('The queue id in Service Desk Level 2 ' + queueId + ' and the queue case owner id is ' + [Select OwnerId from Case where Case.Id = :serviceCase.Id] + ' the case status is ' + serviceCase.Status  );        
            
        }   
        
         //Assigning to members 'eNett Sales Service and Delivery Administrator' profile Level 2
        //profileId = [select id from Profile where name= 'eNett Sales Service and Delivery Administrator' LIMIT 1].Id;
        //owner = [select Id from User where ProfileId = :profileId AND ISACTIVE = TRUE LIMIT 1].Id;
        
        
        //Surajsingh Thakur : PDS-1892 - Update Test Class - TestServicePhoneToCase to fix deployment failure- Start
        //Following SF coding best practice, collected query result in a List and processed only if there are active users in the profile
        
        List<Profile> profiles = [select id from Profile where name= 'eNett Sales Service and Delivery Administrator' LIMIT 1];
        if(profiles.size()>0){
            profileId = profiles.get(0).id;
            List<User> users = [select Id from User where ProfileId = :profileId AND ISACTIVE = TRUE LIMIT 1];
                if(users.size()>0){
                    owner = users.get(0).id; 
            
                    runAsUser = [Select Id from User where Id = :owner];
        
                    system.runAs(runAsUser){
                        serviceCase.Description = 'eNett Sales Service and Delivery Administrator';
                        update serviceCase;
            }   
        }
        }
        //Surajsingh Thakur : PDS-1892 - Update Test Class - TestServicePhoneToCase to fix deployment - End
        
        
        

//*** SF-1591: Removed following code as we have no users with this profile and it prevents deploy.             
//        //Assigning to members 'eNett Sales Service and Delivery' profile Level 2
        
//        profileId = [select id from Profile where name= 'eNett Sales Service and Delivery' LIMIT 1].Id;
//System.Debug('>>>>> ProfileID: ' + profileId);
//        owner = [select Id from User where ProfileId = :profileId  and IsActive = true LIMIT 1].Id;
//System.Debug('>>>>> Owner: ' + owner);
//        runAsUser = [Select Id from User where Id = :owner];
//System.Debug('>>>>> runAsUser: ' + runAsUser);
        
//        system.runAs(saUser){
//            serviceCase.OwnerId = owner;
//            update serviceCase;
//        }
        
        
//        system.runAs(runAsUser){
//            serviceCase = [Select RecordTypeId, Ticket_Service_Level__c, Level_1_Counter__c, Level_2_Counter__c, Level_3_Counter__c, AccountECN__c, Assignee_Service_Level__c, First_Ownership__c  from case where Id =: serviceCase.Id];
//            system.assertEquals(testaccount.ECN__c, serviceCase.AccountECN__c, 'Error: The Account ECN does not match Case ECN');
//            system.assertEquals(2, serviceCase.Ticket_Service_Level__c, 'Error the Ticket Service Level should be 2');
//            system.assertEquals('Service Desk Level 2', serviceCase.Assignee_Service_Level__c, 'Error: The Assgines Service level should be Service Desk Level 2');
//            system.assertEquals(1, serviceCase.Level_1_Counter__c, 'Error: The Level 1 Counter do not match');
//            //system.assertEquals(1, serviceCase.Level_2_Counter__c, 'Error: The Level 2 Counter do not match');
//            system.assertEquals(0, serviceCase.Level_3_Counter__c, 'Error: The Level 3 Counter do not match');        
            
//            serviceCase.Product__c = 'feeNett';
//            update serviceCase;
//            system.Debug('Service case product updated to feeNet:' + serviceCase);       
            
//            // Case escalation to Global Service Desk Level 3 Delivery
//            queueId = [select Id from Group where Name = 'Global Service Desk Level 3 Delivery' and Type = 'Queue'].Id;     
//            //system.debug('The queue Id is ' + queueId);
//            serviceCase.OwnerId = queueId;
//            update serviceCase;
//        }              
        


//*** SF-1591: Removed following code as it violates sharing rules and it prevents deploy.             
        // //Assigning to queue members of Global Service Desk Level 3 Delivery queue, if queue members are present    
        //roleId = [select id from UserRole where name='Global Service Desk Level 3 Delivery'].Id;
        //profileId = [select id from Profile where name= 'eNett Sales Service and Delivery' LIMIT 1].Id;
        
        //owner = [select Id from User where UserRoleId = :roleId AND profileId =:profileId AND ISACTIVE = TRUE LIMIT 1].Id;
        //runAsUser = [Select Id from User where Id = :owner];
        
        ////Running as eNett Sales Service and Delivery profile
        //system.runAs(runAsUser){
        //    serviceCase.OwnerId = owner ;
        //    update serviceCase;
        //    system.assertEquals(owner , serviceCase.OwnerId, 'Error: The Case has not been assigned to Service Desk Level 3  Delivery');
        //    serviceCase = [Select RecordTypeId, Ticket_Service_Level__c, Level_1_Counter__c, Level_2_Counter__c, Level_3_Counter__c, AccountECN__c, Assignee_Service_Level__c, First_Ownership__c  from case where Id =: serviceCase.Id];
        //    system.assertEquals(testaccount.ECN__c, serviceCase.AccountECN__c, 'Error: The Account ECN does not match Case ECN');
        //    system.assertEquals(3, serviceCase.Ticket_Service_Level__c, 'Error the Ticket Service Level should be 3');
        //    system.assertEquals('Service Desk Delivery Level 3', serviceCase.Assignee_Service_Level__c, 'Error: The Assgines Service level should be Service Desk Level 3');
        //    system.assertEquals(1, serviceCase.Level_1_Counter__c, 'Error: The Level 1 Counter do not match');
        //    //system.assertEquals(1, serviceCase.Level_2_Counter__c, 'Error: The Level 2 Counter do not match');
        //   // system.assertEquals(1, serviceCase.Level_3_Counter__c, 'Error: The Level 3 Counter do not match'); - Workflow is not fired as the case does not trigger this.        
                  
        //    // Case escalation to Global Service Desk Level 3 Finance
        //    queueId = [select Id from Group where Name = 'Global Service Desk Level 3 Finance' and Type = 'Queue'].Id;     
        //    //system.debug('The queue Id is ' + queueId);
        //    serviceCase.OwnerId = queueId;
        //    update serviceCase ;
            
        //    system.assertEquals(queueId, serviceCase.OwnerId, 'Error: The Case is not assigned to Global Service Desk Level 3 Finance Queue');
        //}




                    
//*** SF-1591: Removed following code as it violates sharing rules and it prevents deploy.             
        ////Assigning to eNett Service Desk User profile    
        
        //roleId = [select id from UserRole where name='Global Service Desk Level 3 Finance'].Id;
        //profileId = [select id from Profile where name='eNett Service Desk User'].Id;
        //owner = [select Id from User where UserRoleId = :roleId AND profileId =:profileId AND ISACTIVE = TRUE LIMIT 1].Id;
        //runAsUser = [Select Id from User where Id = :owner];
        
        ////Running as Service Desk Level 3 Finance
        //system.runAs(runAsUser){
            
        //    system.debug('The Global Service Desk level 3 Finance User id ' + owner );
        //    serviceCase.OwnerId = owner ;
        //    update serviceCase;
        //    system.assertEquals(owner , serviceCase.OwnerId, 'Error: The Case has not been assigned to Service Desk Level 3  Finance');
            
        //    // Case escalation to Global Service Desk Level 3 IT
        //    queueId = [select Id from Group where Name = 'Global Service Desk Level 3 IT' and Type = 'Queue'].Id;     
        //    //system.debug('The queue Id is ' + queueId);
        //    serviceCase.OwnerId = queueId;
        //    update serviceCase ;
            
        //    system.assertEquals(queueId, serviceCase.OwnerId, 'Error: The Case is not assigned to Global Service Desk Level 3 Finance Queue');
        //}
        




//*** SF-1591: Removed following code as it violates sharing rules and it prevents deploy.             
       //  //Assigning to queue members of Global Service Desk Level 3 IT, if queue members are present    
       // roleId = [select id from UserRole where name='Global Service Desk Level 3 IT'].Id;
       // profileId = [select id from Profile where name='eNett Service Desk User'].Id;
       // owner = [select Id from User where UserRoleId = :roleId AND profileId =:profileId AND ISACTIVE = TRUE LIMIT 1].Id;
       // runAsUser = [Select Id from User where Id = :owner];
        
       // //Running as Service Desk Level 3 IT Role and eNett Service Desk User Profile 
       // system.runAs(runAsUser){
        
       //     //system.debug('The Global Service Desk level 3 IT User id ' + owner );
       //     serviceCase.OwnerId = owner ;
       //     update serviceCase;
       //     system.assertEquals(owner , serviceCase.OwnerId, 'Error: The Case has not been assigned to Service Desk Level 3  IT');
            
       //     //Checking Ticket Service level, ECN, Assignee Service Level, Level Counters
       //     serviceCase = [Select RecordTypeId, Ticket_Service_Level__c, Level_1_Counter__c, Level_2_Counter__c, Level_3_Counter__c, AccountECN__c, Assignee_Service_Level__c from case where Id =: serviceCase.Id];
            
       //     system.assertEquals(testaccount.ECN__c, serviceCase.AccountECN__c, 'Error: The Account ECN does not match Case ECN');
       //     system.assertEquals(3, serviceCase.Ticket_Service_Level__c, 'Error the Ticket Service Level should be 3');
       //     system.assertEquals('Service Desk IT Level 3', serviceCase.Assignee_Service_Level__c, 'Error: The Assgines Service level should be Service Desk Level 3');
       //     system.assertEquals(1, serviceCase.Level_1_Counter__c, 'Error: The Level 1 Counter do not match');
            
       //     //setting the case to Pending.
       //     serviceCase.Status = 'Pending';
            
       //     serviceCase.OwnerId = owner;
       //     update serviceCase;

       //     serviceCase.Final_Solution__c = 'Updated the final solution';
       //     serviceCase.Product__c = 'VANs';
       //     serviceCase.Status = 'Closed';
       //     update serviceCase;
       // }
       ////Excluded Administrator profile from testing based on a discussion with Rod
       //List<Profile>  orgProfiles = [select id , Name from Profile where UserType = 'Standard' and UserLicense.Name = 'Salesforce' 
       //AND Name NOT IN ('Stefanini Service Desk Manager', 'Read Only','Solution Manager','Marketing User','System Administrator (no expiry)', 'Contract Manager','Read Only','Standard User','Administrator', 'eNett Sales Service and Delivery Administrator', 'eNett Sales Service and Delivery', 'eNett Service Desk User', 'System Administrator', 'Stefanini Service Desk User' )] ;
       
       //TestCreateData td = new TestCreateData();
       //for(Profile p : orgProfiles){
       
       //    try{
       //    runAsUser = [Select Id from User where Id = :[select Id from User where ProfileId = :p.Id AND ISACTIVE =:TRUE LIMIT 1].Id];
       //    }
       //    catch (QueryException qe){
           
       //    }
       //    system.runAs(runAsUser){
            
                
       //        try{
       //          //system.debug('The profile name is ' + p.Name);
       //          td.reopenCase(serviceCase);
       //          system.assert(false, 'Error: Negative test case has failed and the profile name is ' + p.name);
       //        }
               
       //        catch(DMLException e){
       //              Boolean err = e.getMessage().startsWith('Update failed');
       //              //system.assert(e.getMessage().startsWith('Update failed'));
                     
       //              //String err = e.getMessage();
       //        }
               
       //    }
       //}
       
       
    }
    
}