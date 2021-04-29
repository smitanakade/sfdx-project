public class EmailUtils {
 
    // Public method
    public static Boolean sendMail(String[] toAddresses, String subject, String body) 
  {
        // Create an email message object
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        // Pass this email message to the built-in sendEmail method
        // of the Messaging class
        System.debug('#####mail = '+mail );
        Messaging.SendEmailResult[] results = Messaging.sendEmail(
                                 new Messaging.SingleEmailMessage[] { mail });
        // Call a helper method to inspect the returned results
        System.debug('#####results  = '+results );
        return inspectResults(results);
    }
     
    // Helper method
    private static Boolean inspectResults(Messaging.SendEmailResult[] results) {
        Boolean sendResult = true;
        // sendEmail returns an array of result objects.
        // Iterate through the list to inspect results.
        // In this class, the methods send only one email,
        // so we should have only one result.
        for (Messaging.SendEmailResult res : results) {
            if (res.isSuccess()) {
                System.debug('Email sent successfully');
           }
            else {
                sendResult = false;
                System.debug('The following errors occurred: ' + res.getErrors());                
            }
        }
        return sendResult;
    }
    
    //Surajsingh Thakur : 18/12/2018 :SF-5417 : Error logging for SF-Jira sync issues
    //Sends alert emails to the Public Group - Salesforce Alert
    public static Integer sendAlertEmail(String subject, String content){
        List<Group> selectedGroup = [SELECT Id,DeveloperName FROM Group WHERE DeveloperName LIKE '%Salesforce_Alert%' LIMIT 1];
        List<GroupMember> groupMember = [SELECT GroupId,Id,UserOrGroupId FROM GroupMember WHERE GroupId =: selectedGroup];
        List<Id> userIdList = new List<Id>();
        for (GroupMember gm : groupMember){
            userIdList.add(gm.UserOrGroupId);
        }
        List<User> users = [SELECT Id, ProfileId, Email FROM User WHERE Id IN: userIdList];
        List<String> emailList = new List<String>();
        for (User u : users){
            emailList.add(u.Email);
        }
        //Send emails to users
        EmailUtils.sendMail(emailList, subject, content);
        System.debug('#####EmailUtils.sendAlertEmail email sent.'+Limits.getEmailInvocations());
        return Limits.getEmailInvocations();
    }

}