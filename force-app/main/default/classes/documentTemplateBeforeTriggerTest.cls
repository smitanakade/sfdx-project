/**
* This is a test class class for the document Template Trigger. 
@author : Arun Sivanesan

@version : 1.0

@update : Arun Sivanesan updated on 25/07/2019 for adding 3 new method; if required Jira ticket number - PDS-3699
**/

@isTest 
private class documentTemplateBeforeTriggerTest {

       /**
         Method to test new template insert and Update
       **/

    static testMethod void unitTest() {
        Document_Template__c dT = new Document_Template__c(Document_Name__c = 'Test',
                                                           Status__c = 'In Flight', Content__c = 'This is Test Document');//SF-5277 17/10/2018 Jasmine - Add status to the test document template
        insert dT;
        
        dT.Document_Name__c = 'Update Test';
        dT.Content__c = 'This is Test Document Update';
        update dT;
    }
    
     /**
         Method to test new template insert and Update to Active Status and then create another new template and make it as current Active
     **/
    static testMethod void updateActiveTest() {
        Document_Template__c dT = new Document_Template__c(Document_Name__c = 'Test',
                                                           Status__c = 'In Flight');//
        insert dT;
        
        dT.Status__c = 'Active';
        update dT;
        
        Document_Template__c dT1 = new Document_Template__c(Document_Name__c = 'Test',
                                                           Status__c = 'In Flight');//
        insert dT1;

        dT1.Status__c = 'Active';
        update dT1;
        
    }
     /**
         Method to test new template insert and Update to Active Status and then Make it as Archived
     **/
         
    static testMethod void updateArchivedTest() {
        Document_Template__c dT = new Document_Template__c(Document_Name__c = 'Test',
                                                           Status__c = 'In Flight');//
        insert dT;
        
        dT.Status__c = 'Active';
        update dT;
        
        
        dT.Status__c = 'Archived';
        update dT;        
    }
     /**
         Method to test new template insert and Delete it
     **/
             
 
     static testMethod void DeleteTest() {
        Document_Template__c dT = new Document_Template__c(Document_Name__c = 'Test',
                                                           Status__c = 'In Flight');//
        insert dT;
        
        delete dT;       
    }   
    
}