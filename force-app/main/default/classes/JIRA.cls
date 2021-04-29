public with sharing class JIRA {

    public static Boolean IntegrationEnabled = (!Test.isRunningTest() && Generic_Lookups__c.getInstance('Jira_Integration_Enabled') != null && Generic_Lookups__c.getInstance('Jira_Integration_Enabled').Value__c == 'true') ? true : false;
    public static String baseUrl  = Test.isRunningTest() ? 'www.jira.com' : Generic_Lookups__c.getInstance('Jira_baseUrl').Value__c; // Base URL of your JIRA instance
    public static String systemId = Test.isRunningTest() ? '1' : Generic_Lookups__c.getInstance('Jira_systemId').Value__c; // Salesforce Connector System ID in JIRA
    public static String username = Test.isRunningTest() ? 'username' : Generic_Lookups__c.getInstance('Jira_username').Value__c;  // JIRA username
    public static String password = Test.isRunningTest() ? 'password' : Generic_Lookups__c.getInstance('Jira_password').Value__c; // JIRA password
    public static String agentProfileName = Test.isRunningTest() ? 'JIRA Agent' : Generic_Lookups__c.getInstance('Jira_agentProfileName').Value__c; // Jira agent profile name in Salesforce

    // Constructs Basic Http Authentication header from provided credentials
    public static String authHeader(String u, String p) {
        Blob headerValue = Blob.valueOf(u + ':' + p);
        return 'Basic ' + EncodingUtil.base64Encode(headerValue);
    }
 
    // Sends a request and returns the response
    public static HttpResponse sendRequest(HttpRequest request) {
        Http http = new Http();
        HttpResponse response = new HttpResponse();
        try{
            
            //Surajsingh Thakur : 21/10/2019 : PDS-5291 : Add diagnostics for call to Jira from SF for Http request and responses - Start
            
            response = http.send(request);
            
            //Surajsingh Thakur : 21/10/2019 : PDS-5291 : Add diagnostics for call to Jira from SF for Http request and responses - End
        }
        catch(System.CalloutException e) {
            System.debug(e);
            //Surajsingh Thakur : 18/12/2018 :SF-5417 : Error logging for SF-Jira sync issues
            //Added better exceptional hadling by sending an email notificatoin.
            EmailUtils.sendAlertEmail('Jira Sync Error - ', 'On sending request to Jira, received a CalloutException : '+e);
        }
        catch(System.Exception e) {
            System.debug(e);
            //Surajsingh Thakur : 18/12/2018 :SF-5417 : Error logging for SF-Jira sync issues
            //Added better exceptional hadling by sending an email notificatoin.
            EmailUtils.sendAlertEmail('Jira Sync Error - ', 'On sending request to Jira, received an Exception : '+e);
        }
        
        //Surajsingh Thakur : 21/10/2019 : PDS-5291 : Add diagnostics for call to Jira from SF for Http request and responses - Start
            
        finally{
        
           //Inserting an integration log record ONLY if Generic_Lookups__c -> Integration Logs -> Value = true
           /*if(Generic_Lookups__c.getValues('Integration Logs').Value__c == 'true'){
               Integration_Log__c integrationLog = new Integration_Log__c(Request__c = request.getEndpoint(), Response_Code__c = response.getStatusCode(), Response_Message__c = response.getStatus());
               insert integrationLog;
           }  */
           
           //Inserting an integration log record ONLY if Generic_Lookups__c -> Integration - Log Successes -> Value = true OR Generic_Lookups__c -> Integration - Log Errors -> Value = true
           if(Generic_Lookups__c.getValues('Integration - Log Successes')!=NULL && Generic_Lookups__c.getValues('Integration - Log Errors')!=NULL){
               if((Generic_Lookups__c.getValues('Integration - Log Successes').Value__c == 'true' && response.getStatusCode() == 200) || 
                   (Generic_Lookups__c.getValues('Integration - Log Errors').Value__c == 'true' && response.getStatusCode() != 200)){
                   Integration_Log__c integrationLog = new Integration_Log__c(Request__c = request.getEndpoint(), Response_Code__c = response.getStatusCode(), Response_Message__c = response.getStatus());
                   insert integrationLog;
               }
           }     
        }
        
        return response;
        
        //Surajsingh Thakur : 21/10/2019 : PDS-5291 : Add diagnostics for call to Jira from SF for Http request and responses - End
        
    }
 
    // Detects whether current user is not JIRA agent. By calling this you can make sure that
    // infinite loops won't happen in triggers (for instance when synchronizing an issue with JIRA)
    public static Boolean currentUserIsNotJiraAgent() {
        Boolean allow = false;
        List<Profile> jiraAgentProfile = [SELECT Id FROM Profile WHERE Name=:JIRA.agentProfileName];
        if (!jiraAgentProfile.isEmpty()) {
            String jiraProfileAgentId = String.valueOf(jiraAgentProfile[0].id);
            allow = UserInfo.getProfileId() != jiraProfileAgentId;
        }
        return allow || Test.isRunningTest();
    }
 
}