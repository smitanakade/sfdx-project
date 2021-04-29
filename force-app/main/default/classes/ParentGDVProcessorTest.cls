/*
* This is a test class for ParentGDVProcessor
* Ticket: SF-5230
* Author: Ronnie Yang
*/
@IsTest
public class ParentGDVProcessorTest {
    @testSetup
    private static void setUp(){
        Customer__c customer = eNettTestUtility.createCustomer('Customer');
        Account parent = eNettTestUtility.createAccount('Parent');
        parent.Customer__c = customer.Id;
        Account child = eNettTestUtility.createAccountWithParent('Child', parent.Id);
        Account grandchild = eNettTestUtility.createAccountWithParent('Grandchild', child.Id);
        
        List<Account> accountsToUpdate = new List<Account>();
        accountsToUpdate.add(parent);
        accountsToUpdate.add(child);
        accountsToUpdate.add(grandchild);
        
        for(Account a : accountsToUpdate){
            a.Yearly_Actual__c = 1;
            a.eNett_Products__c = 'VANs';
            a.Account_Status__c = 'Active';
        }
        
        update accountsToUpdate;
    }
    
    private static testMethod void test(){
        Test.startTest();
        Id batchId = Database.executeBatch(new ParentGDVProcessor());
        Test.stopTest();
        Account parent = [SELECT Id, Yearly_Actual__c, Children_Yearly_Actual_USD__c
                          FROM Account
                          WHERE Name = 'Parent'
                          LIMIT 1];
        Account child = [SELECT Id, Yearly_Actual__c, Children_Yearly_Actual_USD__c
                         FROM Account
                         WHERE Name = 'Child'
                         LIMIT 1];
        Account grandchild = [SELECT Id, Yearly_Actual__c, Children_Yearly_Actual_USD__c
                              FROM Account
                              WHERE Name = 'Grandchild'
                              LIMIT 1];
        Customer__c testCustomer = [SELECT Name, Annual_GDV__c
                                    FROM Customer__c
                                    WHERE Name = 'Customer'
                                    LIMIT 1];
        System.debug(parent);
        System.debug(child);
        System.debug(grandchild);
        System.debug(testCustomer);
        System.assertEquals(1, child.Children_Yearly_Actual_USD__c);
        System.assertEquals(2, parent.Children_Yearly_Actual_USD__c);
        System.assertEquals(3, testCustomer.Annual_GDV__c);
    }
}