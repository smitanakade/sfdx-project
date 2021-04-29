@isTest private class JIRAConnectorWebserviceCalloutSyncTest {

    // Tests synchronizeWithJIRAIssue method in JIRAConnectorWebserviceCalloutSync.
    static testMethod void synchronizeWithJIRAIssueTest() {
        JIRA.IntegrationEnabled = true;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseJIRAConnector());
        JIRAConnectorWebserviceCalloutSync.synchronizeWithJIRAIssue(TestFixture.baseUrl, TestFixture.systemId, TestFixture.objectType, TestFixture.caseId);
        Test.stopTest();
    }
 
    // Tests buildRequest method in JIRAConnectorWebserviceCalloutSync.
    static testMethod void buildRequestTest() {
        JIRA.IntegrationEnabled = true;
        HttpRequest req = JIRAConnectorWebserviceCalloutSync.buildRequest(TestFixture.baseUrl, TestFixture.username,
                TestFixture.password, TestFixture.systemId, TestFixture.objectType, TestFixture.caseId);
        System.assertEquals(req.getMethod(), 'PUT');
        System.assertEquals(req.getEndpoint(), 'http://jira.com/rest/customware/connector/1.0/1/Case/1/issue/synchronize.json');
    }
 
    // Tests SynchronizeWithJIRAIssue trigger.
    static testMethod void synchronizeWithJIRAIssueTriggerTest() {
        JIRA.IntegrationEnabled = true;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseJIRAConnector());
        // insert case
        Case case1 = new Case();
        case1.Priority = 'Call';
        insert case1;

        //Add an attachment
        Attachment attach=new Attachment(); 
        attach.Name='Unit Test Attachment'; 
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body'); 
        attach.body=bodyBlob; attach.parentId = case1.id;
        insert attach;
 
        //update case
        case1.Description = 'updated case description';
        update case1;
    }
 
    // Tests caseCommentSync trigger.
    static testMethod void caseCommentSyncTriggerTest() {
        JIRA.IntegrationEnabled = true;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseJIRAConnector());
        // insert case
        Case case1 = new Case();
        case1.Priority = 'Call';
        insert case1;
 
        // insert casecomment
        CaseComment caseComment = new CaseComment();
        caseComment.ParentId = case1.id;
        insert caseComment;   
    }
    
}