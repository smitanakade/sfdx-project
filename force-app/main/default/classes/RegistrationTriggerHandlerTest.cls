@isTest
public class RegistrationTriggerHandlerTest {
    private static testMethod void UpdateReferenceLeadTestInsert(){
		Registration__c testReg = eNettTestUtility.createRegistration('Test Company');
        Account testReferrer = eNettTestUtility.createAccount('Test Referrer');
        
        testReferrer.Account_Type__c = 'Referrer';
        update testReferrer;
        
        testReg.Registration_Type__c = 'External Registration';
        testReg.Salutation__c = 'Mr';
        testReg.First_Name__c = 'FName';
        testReg.Last_Name__c = 'LName';
        testReg.Job_Title__c = 'CEO';
		testReg.Country__c = 'Australia';
        testReg.Email__c = 'test@email.com';
        testReg.Phone__c = '1234';
        testReg.Referrer__c = testReferrer.Id;
        
        Test.startTest();
        update testReg;
        Test.stopTest();
        
        testReg = [SELECT Id, Lead__c, Salutation__c, First_Name__c, Last_Name__c, Registered_Company_Name__c,
                   Job_Title__c, Product__c, Country__c, Email__c, Phone__c, Referrer__c
                   FROM Registration__c
                   WHERE Id =: testReg.Id
                   LIMIT 1];
        Lead testLead = [SELECT Id, Salutation, FirstName, LastName, Company, Job_Title__c,
                         Account_Type__c, eNett_Products__c, Reference_Registration__c, Contract_Type__c,
                         LeadSource, Country__c, Email, Phone, Registration_Type__c, Referrer__c
                         FROM Lead
                         WHERE Reference_Registration__c =: testReg.Id
                         LIMIT 1];
		
        System.assertEquals(testReg.Lead__c, testLead.Id);
        System.assertEquals(testReg.Salutation__c, testLead.Salutation);
        System.assertEquals(testReg.First_Name__c, testLead.FirstName);
        System.assertEquals(testReg.Last_Name__c, testLead.LastName);
        System.assertEquals(testReg.Registered_Company_Name__c, testLead.Company);
        System.assertEquals(testReg.Job_Title__c, testLead.Job_Title__c);
        System.assertEquals('Customer', testLead.Account_Type__c);
        System.assertEquals(String.valueOf(testReg.Product__c).remove(' '), String.valueOf(testLead.eNett_Products__c).remove(' '));
        System.assertEquals(testReg.Id, testLead.Reference_Registration__c);
        System.assertEquals('Standard T&Cs', testLead.Contract_Type__c);
        System.assertEquals('eNett Online Registration', testLead.LeadSource);
        System.assertEquals(testReg.Country__c, testLead.Country__c);
        System.assertEquals(testReg.Email__c, testLead.Email);
        System.assertEquals(testReg.Phone__c, testLead.Phone);
        System.assertEquals('External Registration', testLead.Registration_Type__c);
        System.assertEquals(testReg.Referrer__c, testLead.Referrer__c);
    }
    
    private static testMethod void UpdateReferenceLeadTestUpdate(){
        Registration__c testReg = eNettTestUtility.createRegistration('Test Company');
        Lead testLead = eNettTestUtility.createLead('Test Lead');
        Account testReferrer = eNettTestUtility.createAccount('Test Referrer');
        
        testReferrer.Account_Type__c = 'Referrer';
        update testReferrer;
        
        testReg.Registration_Type__c = 'External Registration';
        testReg.Lead__c = testLead.Id;
        testReg.Salutation__c = 'Mr';
        testReg.First_Name__c = 'FName';
        testReg.Last_Name__c = 'LName';
        testReg.Job_Title__c = 'CEO';
		testReg.Country__c = 'Australia';
        testReg.Email__c = 'test@email.com';
        testReg.Phone__c = '1234';
        testReg.Referrer__c = testReferrer.Id;
        
        Test.startTest();
        update testReg;
        Test.stopTest();
        
        testLead = [SELECT Id, Salutation, FirstName, LastName, Company, Job_Title__c,
                    Account_Type__c, eNett_Products__c, Reference_Registration__c, Contract_Type__c,
                    LeadSource, Country__c, Email, Phone, Registration_Type__c, Referrer__c
                    FROM Lead
                    WHERE Id =: testLead.Id
                    LIMIT 1];
        
        System.assertEquals(testReg.Lead__c, testLead.Id);
        System.assertEquals(testReg.Salutation__c, testLead.Salutation);
        System.assertEquals(testReg.First_Name__c, testLead.FirstName);
        System.assertEquals(testReg.Last_Name__c, testLead.LastName);
        System.assertEquals(testReg.Registered_Company_Name__c, testLead.Company);
        System.assertEquals(testReg.Job_Title__c, testLead.Job_Title__c);
        System.assertEquals('Customer', testLead.Account_Type__c);
        System.assertEquals(String.valueOf(testReg.Product__c).remove(' '), String.valueOf(testLead.eNett_Products__c).remove(' '));
        System.assertEquals(testReg.Id, testLead.Reference_Registration__c);
        System.assertEquals('Standard T&Cs', testLead.Contract_Type__c);
        System.assertEquals('eNett Online Registration', testLead.LeadSource);
        System.assertEquals(testReg.Country__c, testLead.Country__c);
        System.assertEquals(testReg.Email__c, testLead.Email);
        System.assertEquals(testReg.Phone__c, testLead.Phone);
        System.assertEquals('External Registration', testLead.Registration_Type__c);
        System.assertEquals(testReg.Referrer__c, testLead.Referrer__c);
    }
    
    @isTest(SeeAllData=True)
    private static void PopulateCountryProductFieldsTestInsert(){
        //get custom settings
        Registration__c r = new Registration__c(Country__c = 'Australia', Product__c = 'VANs;eNett EFT', Registered_Company_Name__c = 'Test Company');
        CountryMappings__c info = CountryMappings__c.getInstance('Australia');
        String region = info.Region__c, subRegion = info.Sub_Region__c, subRegion2 = info.Sub_Region_2__c, 
            currencyName = info.Enett_Default_Currency__c, symbolName = info.Enett_Default_Currency_Symbol__c;
        Decimal eftSubFee = info.EFT_Subscription_Fee__c, eftTransFee = info.EFT_Transaction_Fee__c, 
            eftDefaultFee = info.EFT_Default_Payment__c, vansSubFee = info.VANs_Subscription_Fee__c,
            accountFee= info.eNett_Account_Fee__c,
            chargebackFee1 = info.Chargeback_Fee_With_Document__c, chargebackFee2 = info.Chargeback_Fee_Without_Document__c;
        
        //do the deed
        Test.startTest();
        insert r;
        Test.stopTest();
        r = [SELECT Id, Region__c, Sub_Region__c, Sub_Region_2__c, Subscription_Fee_Currency__c, Subscription_Fee_Symbol__c,
             EFT_Subscription_Fee__c, EFT_Transaction_Fee__c, EFT_Default_Payment__c, VANs_Subscription_Fee__c,
             eNett_Account_Fee__c, Chargeback_Fee_With_Document__c, Chargeback_Fee_Without_Document__c
             FROM Registration__c
             WHERE Registered_Company_Name__c = 'Test Company'
             LIMIT 1];
        System.debug(r);
		//check the fields are updated
        System.AssertEquals(region,r.Region__c);
        System.AssertEquals(subRegion,r.Sub_Region__c);
        System.AssertEquals(subRegion2,r.Sub_Region_2__c);
        System.AssertEquals(currencyName,r.Subscription_Fee_Currency__c);
        System.AssertEquals(symbolName,r.Subscription_Fee_Symbol__c);
        System.AssertEquals(eftSubFee,r.EFT_Subscription_Fee__c);    
        System.AssertEquals(eftTransFee,r.EFT_Transaction_Fee__c);
        System.AssertEquals(eftDefaultFee,r.EFT_Default_Payment__c);
        System.AssertEquals(vansSubFee,r.VANs_Subscription_Fee__c);  
        System.AssertEquals(accountFee,r.eNett_Account_Fee__c);
        System.AssertEquals(chargebackFee1,r.Chargeback_Fee_With_Document__c);
        System.AssertEquals(chargebackFee2,r.Chargeback_Fee_Without_Document__c);   
    
    }
    
    @isTest(SeeAllData=True)
    private static void PopulateCountryProductFieldsTestUpdate(){
        //get custom settings
        Registration__c r = new Registration__c(Country__c = 'Canada', Registered_Company_Name__c = 'Test Company');
        insert r;
        
        CountryMappings__c info = CountryMappings__c.getInstance('Australia');
        String region = info.Region__c, subRegion = info.Sub_Region__c, subRegion2 = info.Sub_Region_2__c, 
            currencyName = info.Enett_Default_Currency__c, symbolName = info.Enett_Default_Currency_Symbol__c;
        Decimal eftSubFee = info.EFT_Subscription_Fee__c, eftTransFee = info.EFT_Transaction_Fee__c, 
            eftDefaultFee = info.EFT_Default_Payment__c, vansSubFee = info.VANs_Subscription_Fee__c,
            accountFee= info.eNett_Account_Fee__c,
            chargebackFee1 = info.Chargeback_Fee_With_Document__c, chargebackFee2 = info.Chargeback_Fee_Without_Document__c;

        //do the deed
        Test.startTest();
        r.Country__c = 'Australia';
        r.Product__c = 'VANs;eNett EFT';
        update r;
        Test.stopTest();
        r = [SELECT Id, Region__c, Sub_Region__c, Sub_Region_2__c, Subscription_Fee_Currency__c, Subscription_Fee_Symbol__c,
             EFT_Subscription_Fee__c, EFT_Transaction_Fee__c, EFT_Default_Payment__c, VANs_Subscription_Fee__c,
             eNett_Account_Fee__c, Chargeback_Fee_With_Document__c, Chargeback_Fee_Without_Document__c
             FROM Registration__c
             WHERE Registered_Company_Name__c = 'Test Company'
             LIMIT 1];
		System.debug(r);
        //check the fields are updated
        System.AssertEquals(region,r.Region__c);
        System.AssertEquals(subRegion,r.Sub_Region__c);
        System.AssertEquals(subRegion2,r.Sub_Region_2__c);
        System.AssertEquals(currencyName,r.Subscription_Fee_Currency__c);
        System.AssertEquals(symbolName,r.Subscription_Fee_Symbol__c);
        System.AssertEquals(eftSubFee,r.EFT_Subscription_Fee__c);    
        System.AssertEquals(eftTransFee,r.EFT_Transaction_Fee__c);
        System.AssertEquals(eftDefaultFee,r.EFT_Default_Payment__c);
        System.AssertEquals(vansSubFee,r.VANs_Subscription_Fee__c);  
        System.AssertEquals(accountFee,r.eNett_Account_Fee__c);
        System.AssertEquals(chargebackFee1,r.Chargeback_Fee_With_Document__c);
        System.AssertEquals(chargebackFee2,r.Chargeback_Fee_Without_Document__c);   
    }
    
    private static testMethod void UpdateReferrerTest(){
        Account testAcc = eNettTestUtility.createAccountWithECN('Test Account', '999999');
        testAcc.Account_Type__c = 'Referrer';
        update testAcc;
        
        Registration__c testReg = eNettTestUtility.createRegistration('Test Company');
        
        testReg.Referrer_ECN__c = '999999';
        
        Test.startTest();
        update testReg;
        Test.stopTest();
        
        testReg = [SELECT Id, Referrer__c
                 	FROM Registration__c
                  WHERE Id =: testReg.Id
                  LIMIT 1];
        System.assertEquals(testAcc.Id, testReg.Referrer__c);
    }

    private static testMethod void CalculateDDHoursTestUpdateFromInProgress(){
        Account testAcc = eNettTestUtility.createAccount('Test Account');
        Registration__c testReg = eNettTestUtility.createRegistration('Test Company', testAcc.Id);
        testReg.DD_Status__c = 'In Progress';
        update testReg;
        Test.startTest();
        testReg.DD_Status__c = 'New Status Irrelevant';
        update testReg;
        testReg = [SELECT Id, BH_InProgress__c FROM Registration__c WHERE ID =: testReg.Id LIMIT 1]; 
        Test.stopTest();
        System.assertNotEquals(null, testReg.BH_InProgress__c);
    }
    
	private static testMethod void CalculateDDHoursTestUpdateFromAwaitingClient(){
        Account testAcc = eNettTestUtility.createAccount('Test Account');
        Registration__c testReg = eNettTestUtility.createRegistration('Test Company', testAcc.Id);
        testReg.DD_Status__c = 'Awaiting Client';
        update testReg;
        Test.startTest();
        testReg.DD_Status__c = 'New Status Irrelevant';
        update testReg;
        testReg = [SELECT Id, BH_AwaitingClient__c FROM Registration__c WHERE ID =: testReg.Id LIMIT 1]; 
        Test.stopTest();
        System.assertNotEquals(null, testReg.BH_AwaitingClient__c);
    }
    
    //Registration -- Due Diligence needs access to hierarchy custom settings
    @isTest(SeeAllData=true)
    private static void CalculateDDHoursTestUpdateFromAwaitingApproval(){
        Account testAcc = eNettTestUtility.createAccount('Test Account');
        Registration__c testReg = eNettTestUtility.createRegistration('Test Company', testAcc.Id);
        testReg.DD_Status__c = 'Awaiting Approval';
        update testReg;
        Test.startTest();
        testReg.DD_Status__c = 'New Status Irrelevant';
        update testReg;
        testReg = [SELECT Id, BH_AwaitingApproval__c FROM Registration__c WHERE ID =: testReg.Id LIMIT 1]; 
        Test.stopTest();
        System.assertNotEquals(null, testReg.BH_AwaitingApproval__c);
    }
    
    //Registration -- Due Diligence needs access to hierarchy custom settings
    @isTest(SeeAllData=true)
    private static void CalculateDDHoursTestUpdateFromReferred(){
        
        Account testAcc = eNettTestUtility.createAccount('Test Account');
        Registration__c testReg = eNettTestUtility.createRegistration('Test Company', testAcc.Id);
        testReg.DD_Status__c = 'Referred';
        update testReg;
        
        Test.startTest();
        testReg.DD_Status__c = 'New Status Irrelevant';
        update testReg;
        testReg = [SELECT Id, BH_Referred__c FROM Registration__c WHERE ID =: testReg.Id LIMIT 1]; 
        Test.stopTest();
        System.assertNotEquals(null, testReg.BH_Referred__c);
    }
    
    private static testMethod void CalculateDDHoursTestUpdateFromApprovalInProgress(){
        Account testAcc = eNettTestUtility.createAccount('Test Account');
        Registration__c testReg = eNettTestUtility.createRegistration('Test Company', testAcc.Id);
        testReg.DD_Status__c = 'Approval In Progress';
        update testReg;
        Test.startTest();
        testReg.DD_Status__c = 'New Status Irrelevant';
        update testReg;
        testReg = [SELECT Id, BH_ApprovalInProgress__c FROM Registration__c WHERE ID =: testReg.Id LIMIT 1]; 
        Test.stopTest();
        System.assertNotEquals(null, testReg.BH_ApprovalInProgress__c);
    }
    
    private static testMethod void CalculateDDHoursTestUpdateFromNeedsMoreTime(){
        Account testAcc = eNettTestUtility.createAccount('Test Account');
        Registration__c testReg = eNettTestUtility.createRegistration('Test Company', testAcc.Id);
        testReg.DD_Status__c = 'Needs More Time';
        update testReg;
        Test.startTest();
        testReg.DD_Status__c = 'New Status Irrelevant';
        update testReg;
        testReg = [SELECT Id, BH_NeedsMoreTime__c FROM Registration__c WHERE ID =: testReg.Id LIMIT 1]; 
        Test.stopTest();
        System.assertNotEquals(null, testReg.BH_NeedsMoreTime__c);
    }
    
    private static testMethod void CalculateDDHoursTestUpdateFromNonResponsive(){
        Account testAcc = eNettTestUtility.createAccount('Test Account');
        Registration__c testReg = eNettTestUtility.createRegistration('Test Company', testAcc.Id);
        testReg.DD_Status__c = 'Non Responsive';
        update testReg;
        Test.startTest();
        testReg.DD_Status__c = 'New Status Irrelevant';
        update testReg;
        testReg = [SELECT Id, BH_NonResponsive__c FROM Registration__c WHERE ID =: testReg.Id LIMIT 1]; 
        Test.stopTest();
        System.assertNotEquals(null, testReg.BH_NonResponsive__c);
    }
    
	private static testMethod void CalculateDDHoursTestUpdateFromOnHold(){
        Account testAcc = eNettTestUtility.createAccount('Test Account');
        Registration__c testReg = eNettTestUtility.createRegistration('Test Company', testAcc.Id);
        testReg.DD_Status__c = 'On Hold';
        update testReg;
        Test.startTest();
        testReg.DD_Status__c = 'New Status Irrelevant';
        update testReg;
        testReg = [SELECT Id, BH_OnHold__c FROM Registration__c WHERE ID =: testReg.Id LIMIT 1]; 
        Test.stopTest();
        System.assertNotEquals(null, testReg.BH_OnHold__c);
    }
}