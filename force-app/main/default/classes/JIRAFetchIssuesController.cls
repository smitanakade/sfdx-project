/**
* This class contains all the action functions and business logic for the VF component in a ticket to create Jira Tickets from SF.  

@author : Unknown, Surajsingh Thakur

@version : 1.1

@updates : - Surajsingh Thakur : 16/01/2019 : PDS-365 : Jira Integration Changes in Salesforce
             Surajsingh Thakur : 21/10/2019 : PDS-5291 : Add diagnostics for call to Jira from SF for Http request and responses
        
**/

public class JIRAFetchIssuesController {
 
    private String issuesJson;
 
    private final Case theCase;
    private ApexPages.StandardController stdController;
    private final Integer delay = 50000;

    // Constructor of this class. Note that a request will be sent to JIRA when this class is constructed.
    public JIRAFetchIssuesController(ApexPages.StandardController stdController) {
        this.theCase = (Case)stdController.getRecord();
       
    }
 
    // Sends request to JIRA and returns the request body which should be a valid JSON.
    private static String getResultJson(String objectType, String objectId) {
        try {
            HttpRequest req = buildRequest(JIRA.baseUrl, JIRA.username, JIRA.password, JIRA.systemId, objectType, objectId);
            HttpResponse res = JIRA.sendRequest(req);
            return res.getBody();
        } catch(System.CalloutException e) {
            System.debug(e);
            return '';
        }
    }
 
    // Constructs request needed to fetch JIRA issues from provided parameters.
    @testVisible private static HttpRequest buildRequest(String baseUrl, String username, String password,
                                     String systemId, String objectType, String objectId) {
        HttpRequest req = new HttpRequest();
        String basicAuthHeader = JIRA.authHeader(username, password);
        String endpoint = getEndpoint(baseUrl, systemId, objectType, objectId);
        req.setHeader('Authorization', basicAuthHeader);
        req.setHeader('Content-Type','application/json');
        req.setMethod('GET');
        req.setEndpoint(endpoint);
        return req;
    }
 
    // Creates the endpoint to fetch the issue from provided parameters.
    private static String getEndpoint(String baseUrl, String systemId, String objectType, String objectId) {
        return baseUrl + '/rest/customware/connector/1.0/' + systemId + '/' + objectType + '/' + objectId + '/issue/fetch.json';
    }
 
    public String getIssuesJSON() {
        return this.issuesJson;
    }
 
    public List<JIRAIssue> getIssues() {
    
        //Surajsingh Thakur : 18/12/2018 :SF-5417 : Error logging for SF-Jira sync issues
        //Added and if block which deserializes a JSON only when its not NULL to avoid the NULL Pointer exception.
        if(this.issuesJson!='' && this.issuesJson!=NULL){
            return (List<JIRAIssue>)JSON.deserialize(this.issuesJson , List<JIRAIssue>.class);
        }
        return new List<JiraIssue>();
        
    }
 
    // JIRA Issue Object.
    @testVisible class JIRAIssue {
 
        public String summary { get; }
        public String project { get; }
        public String reporter { get; }
        public String key { get;}
        public String status { get; }
        public String resolution { get; }
        public String url { get; }
        public String type { get; }
        public String assignee { get; }
        public String description { get; }
        public String priority { get; }
        public String due_date { get; }
 
    }

    public String caseId {
        get;
        set {
            caseId = value;
        }
    }


    public String JIRAKey {
        get;
        set {
            JIRAKey = value;
        }
    }

    public void createJiraIssue(){  

        String objectId;

        // Define parameters to be used in calling Apex Class
        String objectType ='Case';  // Please change this according to the object type
        if(System.Test.isRunningTest())
        {
            objectId = '123456789012345';
        }
        else
        {
            objectId = this.caseId.left(15);
        }
        
        //Surajsingh : 16/01/2019 : PDS-365 : Jira Integration Changes in Salesforce
        //Setup config in Jira was changed and all tickets created from SF, the project type, will now be 'APS' instead on 'AS'. 
        //Therefore removed the previously hard coded type 'AS' with a configurable Custom Label containg the present agreed project type - 'APS'
        String projectKey = Label.JiraTicketType; // Type of the Jira Ticket which will be created in Jira from SF
        
        String issueType;
        
        //Surajsingh Thakur : 16/01/2019 : PDS-365 : Jira Integration Changes in Salesforce - Start
        //Setup config in Jira was changed and so SF integration code had to be modified to support only 'Change', 'Investigation', 'Problem' and 'Report' issue types.
        if (theCase.JIRA_Type__c == 'Change') issueType = Generic_Lookups__c.getInstance('Jira_Change').Value__c;
        if (theCase.JIRA_Type__c == 'Investigation') issueType = Generic_Lookups__c.getInstance('Jira_Investigation').Value__c;
        if (theCase.JIRA_Type__c == 'Problem') issueType = Generic_Lookups__c.getInstance('Jira_Problem').Value__c;
        if (theCase.JIRA_Type__c == 'Report') issueType = Generic_Lookups__c.getInstance('Jira_Report').Value__c;
        //Surajsingh Thakur : 16/01/2019 : PDS-365 : Jira Integration Changes in Salesforce - End
        
       // Calls the actual callout to create the JIRA issue.
        JIRAConnectorWebserviceCalloutCreate.createIssue(JIRA.baseUrl, JIRA.systemId, objectType, objectId, projectKey, issueType);

        //Force a wait and hope process has finished.  
        if(!System.Test.isRunningTest()) {
            for(Integer i =0 ; i < delay; i++){  }  
        }
        
    }  


    public void reopenJiraIssue(){
        System.debug('#####theCase '+theCase);
        System.debug('#####theCase.JIRA_Type__c '+theCase.JIRA_Type__c );
        System.debug('#####theCase.JIRA_Status__c '+theCase.JIRA_Status__c);
        // Call the callout to set the status on the JIRA Issue.
        String transitionId;
        if (theCase.JIRA_Type__c == 'Investigation' && theCase.JIRA_Status__c == 'Resolved') {
            transitionId = Generic_Lookups__c.getInstance('Jira_Reopen_From_Resolved_Inv').Value__c;
        } else if (theCase.JIRA_Type__c == 'Investigation' && theCase.JIRA_Status__c == 'Cancelled') {
            System.debug('#####In Jira_Reopen_From_Cancelled_Inv '+Generic_Lookups__c.getInstance('Jira_Reopen_From_Cancelled_Inv').Value__c);
            transitionId = Generic_Lookups__c.getInstance('Jira_Reopen_From_Cancelled_Inv').Value__c;            
        } else if (theCase.JIRA_Type__c == 'Report' && theCase.JIRA_Status__c == 'Resolved') {
            transitionId = Generic_Lookups__c.getInstance('Jira_Reopen_From_Resolved_Rep').Value__c;
        } else if (theCase.JIRA_Type__c == 'Report' && theCase.JIRA_Status__c == 'Cancelled') {
            transitionId = Generic_Lookups__c.getInstance('Jira_Reopen_From_Cancelled_Rep').Value__c;            
        } 
        
        //Surajsingh Thakur : 16/01/2019 : PDS-365 : Jira Integration Changes in Salesforce - Start
        else if (theCase.JIRA_Type__c == 'Change' && theCase.JIRA_Status__c == 'Resolved') {
            transitionId = Generic_Lookups__c.getInstance('Jira_Reopen_From_Resolved_Change').Value__c;
        } else if (theCase.JIRA_Type__c == 'Change' && theCase.JIRA_Status__c == 'Cancelled') {
            transitionId = Generic_Lookups__c.getInstance('Jira_Reopen_From_Cancelled_Change').Value__c;            
        }
        else if (theCase.JIRA_Type__c == 'Problem' && theCase.JIRA_Status__c == 'Resolved') {
            transitionId = Generic_Lookups__c.getInstance('Jira_Reopen_From_Resolved_Problem').Value__c;
        } else if (theCase.JIRA_Type__c == 'Problem' && theCase.JIRA_Status__c == 'Cancelled') {
            transitionId = Generic_Lookups__c.getInstance('Jira_Reopen_From_Cancelled_Problem').Value__c;            
        } 
        //Surajsingh Thakur : 16/01/2019 : PDS-365 : Jira Integration Changes in Salesforce - End
        
        JIRAWebserviceCalloutSyncStatus.syncstatus(this.JIRAKey, transitionId);        

        //Force a wait and hope process has finished.  
        if(!System.Test.isRunningTest()) {
            for(Integer i =0 ; i < delay; i++){ }              
        }

        theCase.JIRA_Resolution__c = 'Unresolved';
        theCase.JIRA_Status__c = 'Waiting for Triage';
        update theCase;


        String objectType ='Case';
        String objectId = theCase.id;

        // Calls the actual callout to synchronize with the JIRA issue.
        
        JIRAConnectorWebserviceCalloutSync.synchronizeWithJIRAIssue(JIRA.baseUrl, JIRA.systemId, objectType, objectId);

    }  


    public void triageJiraIssue() {
        // Call the callout to set the status on the JIRA Issue.
        String transitionId;
        if (theCase.JIRA_Type__c == 'Investigation') {
            transitionId = Generic_Lookups__c.getInstance('Jira_Triage_Inv').Value__c;
        } else if (theCase.JIRA_Type__c == 'Report') {
            transitionId = Generic_Lookups__c.getInstance('Jira_Triage_Rep').Value__c;
        } 
        //Surajsingh Thakur : 16/01/2019 : PDS-365 : Jira Integration Changes in Salesforce - Start
        else if (theCase.JIRA_Type__c == 'Change') {
            transitionId = Generic_Lookups__c.getInstance('Jira_Triage_Change').Value__c;
        } else if (theCase.JIRA_Type__c == 'Problem') {
            transitionId = Generic_Lookups__c.getInstance('Jira_Triage_Problem').Value__c;
        } else {
            transitionId = Generic_Lookups__c.getInstance('Jira_Triage').Value__c;
        }
        //Surajsingh Thakur : 16/01/2019 : PDS-365 : Jira Integration Changes in Salesforce - End
        
        JIRAWebserviceCalloutSyncStatus.syncstatus(this.JIRAKey, transitionId);

        //Force a wait and hope process has finished.  
        if(!System.Test.isRunningTest()) {
            for(Integer i =0 ; i < delay; i++){ }              
        }

        theCase.JIRA_Resolution__c = 'Unresolved';
        theCase.JIRA_Status__c = 'Waiting for Triage';
        update theCase;


        String objectType ='Case';
        String objectId = theCase.id;

        // Calls the actual callout to synchronize with the JIRA issue.
        JIRAConnectorWebserviceCalloutSync.synchronizeWithJIRAIssue(JIRA.baseUrl, JIRA.systemId, objectType, objectId);

    }  



    public void resolveJiraIssue() {
        // Call the callout to set the status on the JIRA Issue.
        JIRAWebserviceCalloutSyncStatus.syncstatus(this.JIRAKey, Generic_Lookups__c.getInstance('Jira_Resolve').Value__c);

        //Force a wait and hope process has finished.  
        if(!System.Test.isRunningTest()) {
            for(Integer i =0 ; i < delay; i++){ }              
        }

        theCase.JIRA_Resolution__c = 'Done';
        theCase.JIRA_Status__c = 'Resolved';
        update theCase;


        String objectType ='Case';
        String objectId = theCase.id;

        // Calls the actual callout to synchronize with the JIRA issue.
        JIRAConnectorWebserviceCalloutSync.synchronizeWithJIRAIssue(JIRA.baseUrl, JIRA.systemId, objectType, objectId);

    }
    
    //Surajsingh Thakur : 21/10/2019 : PDS-5291 : Add diagnostics for call to Jira from SF for Http request and responses - Start
    /*
        This method is now invoked from the action attribute of the FetchJIRAIssue VF page. This was moved from the constructor to allow us write DML statements
        which was not possible when it was part of the constructor previously.
    **/
    public void JiraCallout(){
        
        this.issuesJson = getResultJson('Case', theCase.id);    
    }  
    
    //Surajsingh Thakur : 21/10/2019 : PDS-5291 : Add diagnostics for call to Jira from SF for Http request and responses - End
}