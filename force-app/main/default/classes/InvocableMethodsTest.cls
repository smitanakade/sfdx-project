@isTest
public class InvocableMethodsTest {
    
    @isTest static void testAccountTypeFunding(){
        //Data Setup
        Registration__c testReg = eNettTestUtility.createRegistration('testCompany');
        List<Id> regIds = new List<Id>();
        regIds.add(testReg.Id);
        Registration_Bank_Account__c testBankAccount = eNettTestUtility.createRegistrationBankAccount(testReg.Id);
        testBankAccount.Account_Type__c ='Funding';
        update testBankAccount;
        Verification__c testVer = new Verification__c(Registration_Bank_Account__c = testBankAccount.Id,
                                                     Evidence_Type__c = 'Trading Name',
                                                     Purpose__c = 'ADD');
        insert testVer;
        
        //Perform Test
        test.startTest();
        InvocableMethods.SetAccountsAndVersToReadOnly(regIds);
        test.stopTest();
        
        //Verify Test
        List<Registration_Bank_Account__c> testbAs = [SELECT Account_Type__c FROM Registration_Bank_Account__c
                                                      WHERE Registration__c IN :regIds];
        System.assertEquals(testbAs[0].Account_Type__c, 'Funding');
        List<Verification__c> testVer2 = [SELECT Id, RecordTypeId FROM Verification__c WHERE Registration_Bank_Account__c IN :regIds ];
        if (testVer2.size() > 0){
			System.assertEquals(testVer2[0].RecordTypeId, '01290000001Iirn');
        }
    }
    
        @isTest static void testAccountTypeNotFunding(){
        //Data Setup
        Registration__c testReg = eNettTestUtility.createRegistration('testCompany');
        List<Id> regIds = new List<Id>();
        regIds.add(testReg.Id);
        Registration_Bank_Account__c testBankAccount = eNettTestUtility.createRegistrationBankAccount(testReg.Id);
        testBankAccount.Account_Type__c ='Billing';
        update testBankAccount;
        Verification__c testVer = new Verification__c(Registration_Bank_Account__c = testBankAccount.Id,
                                                     Evidence_Type__c = 'Business Address',
                                                     Purpose__c = 'PEP');
        insert testVer;
        
        //Perform Test
        test.startTest();
        InvocableMethods.SetAccountsAndVersToReadOnly(regIds);
        test.stopTest();
        
        //Verify Test
        List<Registration_Bank_Account__c> testbAs = [SELECT Account_Type__c FROM Registration_Bank_Account__c
                                                      WHERE Registration__c IN :regIds];
        System.assertEquals(testbAs[0].Account_Type__c, 'Billing');
        List<Verification__c> testVer2 = [SELECT Id, RecordTypeId FROM Verification__c WHERE Registration_Bank_Account__c IN :regIds ];
        if (testVer2.size() > 0){
			System.assertEquals(testVer2[0].RecordTypeId, '01290000001Iirn');
        }
    }
}