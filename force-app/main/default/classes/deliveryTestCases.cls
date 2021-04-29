/*
Author: Paul Swarnapandian
Last Updated: 08/05/15
This is the class for the delivery cloud test cases
*/

@isTest
public class deliveryTestCases {
    
    static Account testaccount = null;
    static Datetime dt = DateTime.parse('10/10/2014 12:00 AM');
    static testMethod void testUpdate(){
    
       
       System.debug('The test case for Delivery'); 
       setUpTestData();
       
       
       
     }
     public static void setUpTestData(){
         
         testaccount = new Account(Name = 'Account Test', Legal_Name__c = 'Account Test', 
         Client_Status__c = 'Prospect', IntegratorModifiedDate__c = system.now(), IsApi__c = true, Due_Diligence_Completed__c = dt); 
         //Client_internal_classification__c = 100000.00 );
         insert testaccount;
      
     }
}