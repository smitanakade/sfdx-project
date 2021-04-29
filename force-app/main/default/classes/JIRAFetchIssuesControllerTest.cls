@isTest(SeeAllData = true)
private class JIRAFetchIssuesControllerTest {

    // Tests buildRequest method in JIRAFetchIssuesController.
    static testMethod void buildRequestTest() {
        JIRA.IntegrationEnabled = true;
        HttpRequest req = JIRAFetchIssuesController.buildRequest(TestFixture.baseUrl, TestFixture.username,
            TestFixture.password, TestFixture.systemId, TestFixture.objectType, TestFixture.objectId);
        System.assertEquals(req.getMethod(), 'GET');
        System.assertEquals(req.getEndpoint(), 'http://jira.com/rest/customware/connector/1.0/1/Case/1/issue/fetch.json');
    }
 
    // Tests whether the response is fetched successfully when JIRAFetchIssuesController is constructed.
    static testMethod void getIssuesJSONTest() {
        JIRA.IntegrationEnabled = true;
        insert new Generic_Lookups__c(Name = 'Jira_Reopen', Value__c = '1011');
        
        Case c = new Case();
        c.Priority = 'Call';
        insert c;
 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseFetchJIRAIssue());
         
        JIRAFetchIssuesController controller = new JIRAFetchIssuesController(new ApexPages.StandardController(c));
        controller.JiraCallout();
        //List<Integration_Log__c> integrationLog = [Select id from Integration_Log__c Order By CreatedDate LIMIT 1];
        //System.debug('#####integrationLog = '+integrationLog );
        //System.assertEquals(TestFixture.jiraIssueResponseBody, controller.getIssuesJSON());
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseFetchJIRAIssue());
        List<JIRAFetchIssuesController.JIRAIssue> jiraIssues = controller.getIssues();
 
        JIRAFetchIssuesController.JIRAIssue issue1 = jiraIssues[0];
        JIRAFetchIssuesController.JIRAIssue issue2 = jiraIssues[1];
 
        System.assertEquals('Project One', issue1.summary);
        System.assertEquals('project one', issue1.project);
        System.assertEquals('admin@gmail.com', issue1.reporter);
        System.assertEquals('PO-1', issue1.key);
        System.assertEquals('open', issue1.status);
        System.assertEquals('yes', issue1.resolution);
        System.assertEquals('www.google.com', issue1.url);
        System.assertEquals('bug', issue1.type);
        System.assertEquals('admin', issue1.assignee);
        System.assertEquals('issue 1', issue1.description);
        System.assertEquals('high', issue1.priority);
        System.assertEquals('12-12-2015', issue1.due_date);
        System.assertEquals('Project Two', issue2.summary);
        System.assertEquals('project two', issue2.project);

        controller.createJiraIssue();
        controller.reopenJiraIssue();
        controller.triageJiraIssue();
        controller.resolveJiraIssue();

        Test.stopTest();       
    }
    
    // Negative Test for Exception response for JIRAFetchIssuesController.
    static testMethod void getIssuesJSONTestException() {
        JIRA.IntegrationEnabled = true;
        insert new Generic_Lookups__c(Name = 'Jira_Reopen', Value__c = '1011');
        
        Case c = new Case();
        c.Priority = 'Call';
        insert c;
 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseFetchJIRAIssueNegative());
         
        JIRAFetchIssuesController controller = new JIRAFetchIssuesController(new ApexPages.StandardController(c));
        controller.JiraCallout();
        List<Integration_Log__c> integrationLog = [Select id, Request__c, Response_Code__c, Response_Message__c from Integration_Log__c Order By CreatedDate DESC LIMIT 1];
        
        //Asserting Response exception/other than 200 is also logged
        System.assertEquals(integrationLog[0].Response_Code__c, 403);
        
        Test.stopTest();       
    }
    
    
 
}