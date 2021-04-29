@isTest
private class GDVAlertBatchTest {
    @isTest private static void GDVAlertBatchTest(){
        //Data Setup
        Account testAcc = eNettTestUtility.createAccount('testAccount');
        TransactionalData__c testTD = new TransactionalData__c(Name = 'Test Transaction', 
                                                               LinkedAccount__c = testAcc.Id);
        insert testTD;
        Date testDate = Date.today().addDays(-1);
        test.setCreatedDate(testTD.Id, testDate);
        
        //Perform Test
        Test.startTest();
        Integer isEmailSentTest = Limits.getEmailInvocations();
        //Run everyday at 6.00am as GDV is synced at 4.00am local time
        String defaultSchedule = '0 0 6 * * ?';
        GDVAlertBatch gab = new GDVAlertBatch();
        Id batchJobId = System.schedule('GDVAlertBatchTest', defaultSchedule, gab);
        Test.stopTest();
       
        System.assertNotEquals(isEmailSentTest,gab.isEmailSent,'should have increased.');
    }
}