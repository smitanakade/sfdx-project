/**
* This class contains utility methods for creating test data for unit tests development
*
* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition.
*
* All test methods in an organization are executed whenever Apex code is deployed
* to a production organization to confirm correctness, ensure code
* coverage, and prevent regressions. All Apex classes are
* required to have at least 75% code coverage in order to be deployed
* to a production organization. In addition, all triggers must have some code coverage.
* 
* See the Apex Language Reference for more information about Testing and Code Coverage.
*
* author : Surajsingh Thakur
* Date   : 27/12/2017 
*/

public without sharing class eNettTestUtility {
    
    //Create Test User
    public static User createUser(String profileName){
        
        Profile givenProfile = [SELECT Id FROM Profile WHERE Name = :profileName]; 
        
        User testUser = new User(Alias = 'tuser', Email='testuser@testenett.com', 
                                 EmailEncodingKey='UTF-8', LastName='TestUser', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_AU', ProfileId = givenProfile.Id, 
                                 TimeZoneSidKey='Australia/Sydney', UserName='testuser@testenett.com');
        
        insert testUser;
        return testUser;
    }
    
    //Create Test Lead
    public static Lead createLead(String lastName){
        
        Lead testLead = new Lead( LastName = lastName,FirstName='Jay',Company='Wingo Ducks',Phone='(707) 555-0328');
        
        insert testLead;
        return testLead;
    }
    
    //Create Test Account
    public static Account createAccount(String accountName){
        Account testAccount = new Account(Name = accountName, Legal_Name__c = accountName, Trading_As__c = accountName, ECN__c = '000001', Client_Status__c = 'Prospect', IsApi__c = true);
        
        insert testAccount;
        return testAccount;
    }
    
    //Create Test Account with Parent
    public static Account createAccountWithParent(String accountName, ID accountID){
        Account testAccount = new Account(Name = accountName, Legal_Name__c = accountName, Trading_As__c = accountName, Client_Status__c = 'Prospect', IsApi__c = true);
        testAccount.ParentID = accountID;
        testAccount.Commercial_Parent_Account__c = accountID;
        testAccount.Legal_Parent__c = accountID;
        
        insert testAccount;
        return testAccount;
    }
    
    //Create Test Account with ECN
    public static Account createAccountWithECN(String accountName, String ECN){
        Account testAccount = new Account(Name = accountName, Legal_Name__c = accountName, Trading_As__c = accountName, ECN__c = ECN, Client_Status__c = 'Prospect', IsApi__c = true);
        
        insert testAccount;
        return testAccount;
    }
    
    //Create Test Contact
    public static Contact createContact(ID accountID){
        Contact testContact = new Contact(FirstName = 'Enett', 
                                          LastName = 'Contact', 
                                          AccountID = accountID, 
                                          Job_Role__c = 'Primary; Secondary; Financial',
                                          Primary_Email_Address__c = 'primary@email.com',
                                          Secondary_Email_Address__c = 'seoncdary@email.com',
                                          Financial_Email_Address__c = 'financial@email.com',
                                          Salutation = 'Ms',
                                          Title__c = 'CEO',
                                          IsApi__c = true,
                                          Customer_Experience_Surveys__c = true);
        insert testContact; 
        return testContact;
        
    }
    
    //Create Test Opportunity
    public static Opportunity createOpportunity(String opportunityName, ID accountID){
        Opportunity testOpportunity = new Opportunity( Name= opportunityName ,AccountId = accountID ,Product__c = 'VANs',Type = 'New', CloseDate = date.valueOf('2014-01-01'), StageName = '1. Prospect',CurrencyIsoCode = 'USD',Delivery_Type__c = null, Opportunity_Qualify_Created__c = null);
        
        insert testOpportunity;
        return testOpportunity;
    }
    
    //Create Test Registration
    public static Registration__c createRegistration(String companyName, ID accountID){
        Registration__c testReg = new Registration__c(Registered_Company_Name__c = companyName, Account__c = accountID, Product__c = 'VANs; eNett EFT');
        
        insert testReg;
        return testReg;
    }
    
    //Create Test Registration without Parent Account
    public static Registration__c createRegistration(String companyName){
        Registration__c testReg = new Registration__c(Registered_Company_Name__c = companyName, Product__c = 'VANs; eNett EFT');
        
        insert testReg;
        return testReg;
    }
    
    //Create Test Registration Bank Account
    public static Registration_Bank_Account__c createRegistrationBankAccount(ID registrationID){
        Registration_Bank_Account__c testRegistrationBankAccount = new Registration_Bank_Account__c(Registration__c = registrationID, Bank_Code__c = '1', Account_Number__c = '1');
        insert testRegistrationBankAccount;
        return testRegistrationBankAccount;
    }
    
    //Create Test eNett Contract 
    public static eNEtt_Contract__c createENettContract(ID accountID){
        eNEtt_Contract__c testContract = new eNEtt_Contract__c( Account_Name__c = accountID, VAN_Currencies__c = 'some random value', Contract_Type__c ='Standard T&Cs');
        
        insert testContract;
        return testContract;
    }
    
    //Create Test Case 
    public static Case createCase(){
        Case testCase = new Case(Priority = 'Call');
        
        insert testCase;
        return testCase;
    }
    
    //Create Test Case with Parent
    public static Case createCase(Id parentId){
        Case testCase = new Case(Priority = 'Call', ParentId = parentId);
        
        insert testCase;
        return testCase;
    }
    
    //Create Test Beneficial Owner
    public static Beneficial_Owner__c createBeneficialOwner(ID registrationID){
        Beneficial_Owner__c testBeneficialOwner = new Beneficial_Owner__c(Registration__c = registrationID);
        
        insert testBeneficialOwner;
        return testBeneficialOwner;
    }
    
    //Create Test Verification
    public static Verification__c createVerification(){
        Verification__c testVerification = new Verification__c();
        
        insert testVerification;
        return testVerification;
    }
    
    //Create Test Risk Assessment
    public static Risk_Rating_Evidence__c createRiskAssessment(ID registrationId){
        Risk_Rating_Evidence__c testRiskAssessment = new Risk_Rating_Evidence__c(Registration__c = registrationId);
        
        insert testRiskAssessment;
        return testRiskAssessment;
    }
    
    //Create Test Attachment (Note that this will now be converted to File anyway after insert by trigger -- original attachment deleted)
    public static Attachment createAttachment(ID parentID){
        Attachment testAttachment = new Attachment();    
        testAttachment.Name = 'Unit Test Attachment';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        testAttachment.body = bodyBlob;
        testAttachment.parentId = parentID;
        insert testAttachment;
        return testAttachment;
    }
    
    //Create Test File without Parent
    public static ContentDocument createFile(){
        ContentVersion testFileVersion = new ContentVersion(Title = 'Unit Test File',
                                                            PathOnClient = '/testfile',
                                                            VersionData = Blob.valueOf('Unit Test File Body'));
        insert testFileVersion;
        ContentVersion insertedVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: testFileVersion.Id LIMIT 1];
        return [SELECT Id FROM ContentDocument where Id =: insertedVersion.ContentDocumentId LIMIT 1];
    }
    
    //Create Test File with Parent
    public static ContentDocument createFile(ID parentID){
        ContentVersion testFileVersion = new ContentVersion(Title = 'Unit Test File',
                                                            PathOnClient = '/testfile',
                                                            VersionData = Blob.valueOf('Unit Test File Body'), 
                                                            FirstPublishLocationId = parentID);
        insert testFileVersion;
        ContentVersion insertedVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: testFileVersion.Id LIMIT 1];
        return [SELECT Id FROM ContentDocument where Id =: insertedVersion.ContentDocumentId LIMIT 1];
    }
    
    //Create Test Email Message
    public static EmailMessage createEmailMessage(){
        EmailMessage testEmail = new EmailMessage();
        insert testEmail;
        return testEmail;
    }
    
    //Create Test Email Message with Parent
    public static EmailMessage createEmailMessage(Id parentId){
        EmailMessage testEmail = new EmailMessage(ParentId = parentId);
        insert testEmail;
        return testEmail;
    }
    
    //Create Test Note
    public static Note createNote(){
        Note testNote = new Note();
        insert testNote;
        return testNote;
    }
    
    //Create Customer
    public static Customer__c createCustomer(String customerName){
        Customer__c testCustomer = new Customer__c(Name = customerName);
        
        insert testCustomer;
        return testCustomer;
    }
    
    //Create InboundEmail
    public static Inbound_Email__c createInboundEmail(String emailFromName, String emailFromAddress, String htmlBody, String eamilToAddress, String Subject){
        Inbound_Email__c testInboundEmail = new Inbound_Email__c(From__c= emailFromName,fromAddress__c= emailFromAddress,htmlBody__c = htmlBody, To__c = eamilToAddress,  Subject__c=Subject );
        
        insert testInboundEmail ;
        return testInboundEmail ;
    }
}