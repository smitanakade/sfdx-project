@isTest private class JIRATest {

    // Tests authHeader method in JIRA class.
    static testMethod void authHeaderTest() {
        JIRA.IntegrationEnabled = true;
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseJIRAConnector());
        String authHeader = JIRA.authHeader(TestFixture.username, TestFixture.password);
        System.assertEquals(authHeader, 'Basic eW91ckpJUkF1c2VybmFtZTp5b3VySklSQXBhc3N3b3Jk');
        test.stopTest();        
    }
     
    // Tests sendRequest method in JIRA class.
    static testMethod void sendRequestTest() {
        JIRA.IntegrationEnabled = true;
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseJIRAConnector());
        HttpRequest req = new HttpRequest();
        HttpResponse res = JIRA.sendRequest(req);
        System.assertEquals(res.getStatusCode(), 200);
        test.stopTest(); 
    }
 
    // Tests currentUserIsNotJiraAgent method in JIRA class.
    static testMethod void currentUserIsNotJiraAgentTest() {
        JIRA.IntegrationEnabled = true;
        test.startTest();
        System.assert(JIRA.currentUserIsNotJiraAgent());
        test.stopTest();
    }
 
}