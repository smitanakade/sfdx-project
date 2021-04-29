/*
 * This is a test class for UnsubscribePageController
 * Ticket: SF-5202
 * Author: Ronnie Yang
 */
@isTest
public class UnsubscribePageControllerTest {
    private static testMethod void Test(){
        UnsubscribePageController controller;
        //setting up test data
        Contact testContact = eNettTestUtility.createContact(eNettTestUtility.createAccount('Test Account').id);
        //Customer Experience Surveys subscription is set to true by default
        System.assertEquals(true,testContact.Customer_Experience_Surveys__c);
        
        Test.setCurrentPage(Page.UnsubscribedPage);
        ApexPages.currentPage().getParameters().put('ContactId', testContact.Id);
        controller = new UnsubscribePageController();
        controller.unsubscribe();
        //upon page load the InitPage method will set it to false instead
        testContact = [SELECT Id, Customer_Experience_Surveys__c FROM Contact WHERE Id=: testContact.Id];
        System.assertEquals(false,testContact.Customer_Experience_Surveys__c);
    }
}