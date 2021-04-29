@isTest
public class TestJIRAWebserviceCalloutSyncStatus {

    static testMethod void TestJIRAWebserviceCalloutSyncStatus(){
        JIRA.IntegrationEnabled = true;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseJIRAConnector());
        JIRAWebserviceCalloutSyncStatus.syncstatus('AS-5190', '1011');
        Test.stopTest();
    }
}