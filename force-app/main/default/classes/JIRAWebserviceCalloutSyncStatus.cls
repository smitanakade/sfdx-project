global class JIRAWebserviceCalloutSyncStatus {
    @future (callout=true)
    WebService static void syncstatus(String jiraKey, String transitionId) {
        //Modify these variables:
        String username = JIRA.username;
        String password = JIRA.password;
        String jiraURL = JIRA.baseUrl;
//        String transitionId = '1011';
         
        //Construct HTTP request and response
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
 
        //Construct Authorization and Content header
        Blob headerValue = Blob.valueOf(username+':'+password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type','application/json');
 
        //Construct Endpoint
        String endpoint = jiraURL+'/rest/api/2/issue/'+jiraKey+'/transitions';
         
        //Set Method and Endpoint and Body
        req.setMethod('POST');
        req.setEndpoint(endpoint);
        req.setBody('{ \"transition\": {\"id\": \"'+transitionId+'\"}}');

		try {
			//Send endpoint to JIRA
			res = http.send(req);
		} catch(System.CalloutException e) {
			System.debug(res.toString());
		}
	}
}