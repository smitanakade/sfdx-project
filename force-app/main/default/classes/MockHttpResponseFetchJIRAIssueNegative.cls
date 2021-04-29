/**
* This class contains all the Mock webservice response developed for testing the Jira Fetch Response.  
  @author : Surajsingh Thakur
  @version : 1.0
  @Date : 23/10/2019
  @update : -
**/
@isTest
global class MockHttpResponseFetchJIRAIssueNegative implements HttpCalloutMock {
 
    // Mocks respond method for testing in JIRAFetchIssuesControllerTest.
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(403);
        res.setBody('CallOutException');
        return res;
    }
     
}