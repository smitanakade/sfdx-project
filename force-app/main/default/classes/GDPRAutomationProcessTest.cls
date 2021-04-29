/*
*  This is Test class for trigger GDPRAutomationProcessTrigger.apxt 
 *  This class contains the test methods for trigger handler class GDPRAutomationProcessTriggerHandler.apxc
 *  @author  : Kishore Potla
 *  @version : 1.0
 *  @update  : 
*/
@isTest public class GDPRAutomationProcessTest {
    
    @istest private static void customerTest(){
        //CREATE TEST DATA
        Account acc = new Account(Name = 'Test Account',
                                  ECN__c = '9999');
        insert acc;
        
        Contact primaryCont = new Contact (Firstname = 'Test Primary',
                                           Lastname = 'Contact',
                                           Birthdate = date.today(),
                                           Department = 'Accounting',
                                           Email = 'test@gmail.com',
                                           Fax = '832482482',
                                           MailingStreet = '123 ABC Street',
                                           MailingPostalCode = '3323',
                                           MailingState = 'State',
                                           MailingCity = 'City',
                                           MailingCountry = 'Country',
                                           Primary_Email_Address__c = 'primary@gmail.com',
                                           Secondary_Email_Address__c = 'secondary@gmail.com',
                                           Financial_Email_Address__c = 'financial@gmail.com',
                                           Alternative_Email_Adress__c = 'alternative@gmail.com',
                                           User_Email_Address__c = 'user@gmail.com',
                                           FEmail__c = 'femail@gmail.com',
                                           SEmail__c = 'semail@gmail.com',
                                           UEmail__c = 'uemail@gmail.com',
                                           Alternative_Mobile__c = '3234234131',
                                           Alternative_Phone__c = '80820948290',
                                           Phone = '88889999',
                                           MobilePhone = '85038290482',
                                           HomePhone = '47394723',
                                           OtherPhone = '34242342342',
                                           Job_Role__c = 'Primary',
                                           Salutation = 'Mr',
                                           AccountId = acc.Id);
        insert primaryCont;
        
        Contact secondaryCont = new Contact (Firstname = 'Test Secondary',
                                             Lastname = 'Contact',
                                             Email = 'test@gmail.com',
                                             Primary_Email_Address__c = 'test@gmail.com',
                                             Secondary_Email_Address__c = 'test@gmail.com',
                                             Financial_Email_Address__c = 'test@gmail.com',
                                             Phone = '88889999',
                                             MobilePhone = '85038290482',
                                             HomePhone = '47394723',
                                             Job_Role__c = 'Secondary',
                                             AccountId = acc.Id);
        insert secondaryCont;
        
        Case testCase = new Case (AccountId = acc.Id,
                                  ContactId = secondaryCont.Id,
                                  Status = 'New',
                                  Priority = 'Should have');
        insert testCase;
        
        CaseComment testComment = new CaseComment(ParentId = testCase.Id,
                                                  CommentBody = 'test@gmail.com');
        insert testComment;
        
        Lead testLead = new Lead (FirstName = 'test',
                                  LastName = 'Lead',
                                  Email = 'test@gmail.com', 
                                  Company = 'testCompany',
                                  IsConverted = true,
                                  Relationship_Channel__C = 'F2F (client’s office)',
                                  ConvertedAccountId = acc.id);
        insert testLead;
        
        Action__c testAction = new Action__c (Related_To__c  = testCase.Id);
        insert testAction;
        
        Inbound_Email__c testInboundEmail = new Inbound_Email__c(Account__c = acc.Id,
                                                                 Contact__c = secondaryCont.Id,
                                                                 Case__c = testCase.id,
                                                                 From__c = 'test@gmail.com');
        insert testInboundEmail;
        
        Id [] fixedSearchResults= new Id[6];
        fixedSearchResults[0] = primaryCont.Id;
        fixedSearchResults[1] = secondaryCont.Id;
        fixedSearchResults[2] = testCase.Id;
        fixedSearchResults[3] = testComment.Id;
        fixedSearchResults[4] = testAction.Id;
        fixedSearchResults[5] = testInboundEmail.Id;
    
        Test.setFixedSearchResults(fixedSearchResults);
        
        //PERFORM TEST
        test.startTest();
        GDPR_Masking__c sub = new GDPR_Masking__c(ECN__c = '9999', GDPR_Status__C = 'New');
        insert sub;
        test.stopTest();
        
        //ASSERTION
        //List<Contact> resultPrimary
        Account resultAcc = [SELECT Id, 
                             (SELECT Id, Job_Role__c, Birthdate, Department, Email, Fax, HomePhone, MobilePhone, Firstname, Lastname,
                              MailingStreet, MailingPostalCode, MailingState, MailingCity, MailingCountry, OtherPhone, Phone,
                              Alternative_Email_Adress__c, Alternative_Mobile__c, Alternative_Phone__c, FEmail__c, Financial_Email_Address__c,
                              Primary_Email_Address__c, Secondary_Email_Address__c, Salutation, SEmail__c, UEmail__c, User_Email_Address__c FROM Contacts)
                             FROM Account WHERE ECN__c = '9999' LIMIT 1];
        
        if (resultAcc.Contacts != NULL){
            System.assertEquals(1, resultAcc.Contacts.size());
            for (Contact resultContact : resultAcc.Contacts){
                if(resultContact.Job_Role__c == 'Primary'){
                    System.assertEquals(NULL, resultContact.Birthdate);
                    System.assertEquals('XXXX', resultContact.Department);
                    System.assertEquals('axxx@enett.com', resultContact.Email.toLowerCase());
                    System.assertEquals('XXXXXXXXXX', resultContact.Fax);
                    System.assertEquals('XXXXXXXX', resultContact.HomePhone);
                    System.assertEquals('XXXXXXXXXX', resultContact.MobilePhone);
                    System.assertEquals('XXXX', resultContact.FirstName);
                    System.assertEquals('XXXX', resultContact.LastName);
                    System.assertEquals('XXXX', resultContact.MailingStreet);
                    System.assertEquals('XXXX', resultContact.MailingPostalCode);
                    System.assertEquals('XXXX', resultContact.MailingState);
                    System.assertEquals('XXXX', resultContact.MailingCity);
                    System.assertEquals('XXXX', resultContact.MailingCountry);
                    System.assertEquals('XXXXXXXX', resultContact.OtherPhone);
                    System.assertEquals('XXXXXXXX', resultContact.Phone);
                    System.assertEquals('axxx@enett.com', resultContact.Alternative_Email_Adress__c);
                    System.assertEquals('XXXXXXXXXX', resultContact.Alternative_Mobile__c);
                    System.assertEquals('XXXXXXXX', resultContact.Alternative_Phone__c);
                    System.assertEquals('aXXX@enett.com', resultContact.FEmail__c);
                    System.assertEquals('aXXX@enett.com', resultContact.SEmail__c);
                    System.assertEquals('aXXX@enett.com', resultContact.UEmail__c);
                    System.assertEquals('axxx@enett.com', resultContact.Financial_Email_Address__c);
                    System.assertEquals('axxx@enett.com', resultContact.Primary_Email_Address__c);
                    System.assertEquals('axxx@enett.com', resultContact.Secondary_Email_Address__c);
                    System.assertEquals('axxx@enett.com', resultContact.User_Email_Address__c);
                    System.assertEquals('XXXX', resultContact.Salutation);
                    System.assertEquals(true, resultContact.Job_Role__c.contains('Primary'));
                }else if(resultContact.Job_Role__c == 'Secondary'){
                    System.assertEquals('XXXX', resultContact.FirstName);
                    System.assertEquals('XXXX', resultContact.LastName);
                    System.assertEquals('axxx@enett.com', resultContact.Financial_Email_Address__c);
                    System.assertEquals('axxx@enett.com', resultContact.Primary_Email_Address__c);
                    System.assertEquals('axxx@enett.com', resultContact.Secondary_Email_Address__c);
                    System.assertEquals('XXXXXXXX', resultContact.Phone);
                    System.assertEquals('XXXXXXXX', resultContact.HomePhone);
                    System.assertEquals('XXXXXXXXXX', resultContact.MobilePhone);
                    System.assertEquals(true, resultContact.Job_Role__c.contains('Secondary'));
                }
            }
        }
        System.assertEquals(0, [SELECT Id FROM Case WHERE AccountId =: resultAcc.Id].size());
        System.assertEquals(0, [SELECT Id FROM CaseComment WHERE CommentBody = 'test@gmail.com'].size());
        System.assertEquals(0, [SELECT Id FROM Lead WHERE Email = 'test@gmail.com'].size());
        System.assertEquals(0, [SELECT Id FROM Action__c].size());
        System.assertEquals(0, [SELECT Id FROM Inbound_Email__c WHERE Account__c =: resultAcc.Id].size());
    }
}