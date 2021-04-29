global with sharing class eNettRegoDuplicateAccountController {
     
    @RemoteAction
    global static String sendManagerEmail(String theTitle, String theFirstName, String theLastName, String theEmail, 
                                            String theContactNumber, String theAdditional, String theEFT,
                                            String theNewUser, String theGeneral, String theShortMessage) {

        String emailTo = 'bryan.heenan@enett.com';
        String emailBody = 'theTitle: ' + theTitle + '\r\ntheFirstName: ' + theFirstName + '\r\ntheLastName: ' + theLastName 
                                + '\r\ntheEmail: ' + theEmail + '\r\ntheContactNumber: ' + theContactNumber + '\r\ntheAdditional: ' + theAdditional + '\r\ntheEFT: ' + theEFT
                                + '\r\ntheNewUser: ' +  theNewUser + '\r\ntheGeneral: ' + theGeneral + '\r\ntheShortMessage: ' + theShortMessage;
        String response;


        Generic_Lookups__c emailReplyTo = Generic_Lookups__c.getInstance('RegDupAcctReplyTo');
        String replyTo = emailReplyTo.Value__c;

        Generic_Lookups__c emailSender = Generic_Lookups__c.getInstance('RegDupAcctSender');
        String sender = emailSender.Value__c;

        Generic_Lookups__c emailSubject = Generic_Lookups__c.getInstance('RegDupAcctSubject');
        String subject = emailSubject.Value__c;


        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {emailTo});
        mail.setReplyTo(replyTo);
        mail.setSenderDisplayName(sender);
        mail.setSubject(subject);
        mail.setPlainTextBody(emailBody);
        try
        {
            Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            if(resultMail[0].isSuccess())      
                response = 'ok sent!';
            else
            {
                response = resultMail[0].getErrors().get(0).getMessage();
            }
        }
        catch(System.EmailException ex)
        {
            response = ex.getMessage();
        }  
        return response;
    }

}