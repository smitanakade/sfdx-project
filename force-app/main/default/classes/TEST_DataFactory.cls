@isTest
public class TEST_DataFactory {

    //      Create Generic Account.
    //******************************************************************/

    public static Account createAccount(){
        Account testAccount = new Account(
                                  Name = 'Account Test', 
                                  Legal_Name__c = 'Account Test', 
                                  Client_Status__c = 'Prospect', 
                                  Country__c = 'Australia',
                                  Region__c = 'APAC',
                                  Customer_Sector__c = 'Agent',                                   
//                                  Client_internal_classification__c = 12000000,
//                                  Referrer_Name__c = 'Mastercard',
//                                  Contract_Type__c = 'Standard T&Cs',
//                                  PointOfOrigin__c = 0,
//                                  IsApi__c = true
                                  eNett_products__c = 'VANs'); 
        return testAccount;
    }


  //      Create Generic Contact.
  //******************************************************************/

    public static Contact createContact(string accountId){
        Contact testContact = new Contact(
                                  FirstName = 'Firsttest', 
                                  LastName = 'Lastest', 
                                  AccountId = accountId, 
                                  Email = 'Trevor@trevor.com', 
                                  IsApi__c = true);
      return testContact;
    }


  //      Create Contact  with Type.
  //******************************************************************/

    public static Contact createContact(string accountId, String ContactType){
        Contact testContact = new Contact(
                                  FirstName = 'Firsttest', 
                                  LastName = 'Lastest', 
                                  AccountId = accountId, 
                                  //Email = 'Trevor@trevor.com', 
                                  Job_Role__c = ContactType,
                                  IsApi__c = true);
      return testContact;
    }


    
}