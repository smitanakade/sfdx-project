@isTest
public class RiskRatingsUtilityTest {
    
    testmethod static void testRiskRatingFalse(){
        Registration__c reg1 = eNettTestUtility.createRegistration('compName');
        Risk_Rating_Evidence__c rre1 = new Risk_Rating_Evidence__c(Risk_Rating__c = 'High', Registration__c = reg1.Id);
        insert rre1;
        Account acc1 = eNettTestUtility.createAccount('testAccount');
        acc1.Due_Diligence_Risk_Rating__c = 'High';
        update acc1;
        
        // Perform test and verify
        Test.startTest();
        System.assertEquals(false,RiskRatingsUtility.checkRiskRatingDowngrade(reg1.Id, acc1.Id));
        Test.stopTest();
    }
    
    @isTest static void testRiskRatingTrue(){
        Registration__c reg2 = eNettTestUtility.createRegistration('compName2');
        Risk_Rating_Evidence__c rre2 = new Risk_Rating_Evidence__c(Risk_Rating__c = 'Low', Registration__c = reg2.Id);
        insert rre2;
        Account acc2 = eNettTestUtility.createAccount('testAccount');
        acc2.Due_Diligence_Risk_Rating__c = 'High';
        update acc2;
        
        // Perform test and verify
        Test.startTest();
        System.assertEquals(true,RiskRatingsUtility.checkRiskRatingDowngrade(reg2.Id, acc2.Id));
        Test.stopTest();        
    }
}