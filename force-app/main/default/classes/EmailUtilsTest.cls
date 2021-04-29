@isTest public class EmailUtilsTest{
    @isTest static void EmailUtilsSuccessTest(){
        List<string> addresses = new List<string>();
        String address = 'test@gmail.com';
        addresses.add(address);
        String subject = 'test';
        String body = 'body';
        
        Test.startTest();
        EmailUtils.sendMail(addresses, subject, body);
        Test.stopTest();
    }
    
    @isTest static void testEmailAlert(){
        EmailUtils.sendAlertEmail('Test Subject','Test Content');
        System.assert(Limits.getEmailInvocations()>0);
    }
}