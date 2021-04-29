/*
* This is the controller class for UnsubscribedPage
* When a customer access a link to the page with their contact Id, this will uncheck the Customer Experience Survey checkbox
* Ticket: SF-5202
* Author: Ronnie Yang
*/ 
public class UnsubscribePageController {
    public String ContactId {get;set;}
    public Boolean ShowMessage {get;set;}
    public Boolean Success {get; set;}
    public UnsubscribePageController(){
        ContactId = ApexPages.currentPage().getParameters().get('ContactId');
        ShowMessage = false;
        Success = false;
    }
    
    public void unsubscribe(){
        ShowMessage = true;
        try{
            List<Contact> contactToUnsubscribe = [SELECT Id, Customer_Experience_Surveys__c
                                                  FROM Contact
                                                  WHERE Id=: ContactId 
                                                  LIMIT 1];
            if (!contactToUnsubscribe.isEmpty()){
                contactToUnsubscribe[0].Customer_Experience_Surveys__c = false;
                update contactToUnsubscribe;
            }
            Success = true;    
        }
        catch(Exception e){
            System.debug('ERROR CUSTOMER UPDATING EMAIL PREFERENCE: ' + e.getMessage());
            Success = false; 
        }
    }
}