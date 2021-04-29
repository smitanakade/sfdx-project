@isTest public class PT_noDeleteTaskTest {
    @isTest static void testRun(){
        //Create a standard user
        String uniqueUserName = 'sysad' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u = new User(Alias = 'sysad', Email='sysad@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);
        //Run test as system admin user
        System.runAs(u){
            Process_Task__c testTask = new Process_Task__c(Subject__c = 'test');
            insert testTask;
            List<Process_Task__c> taskList = [SELECT Id FROM Process_Task__c];
            if (taskList.size() > 0){
                for (Process_Task__c pt : taskList){
                    delete pt;
                }   
            }    
        }
    }
}