@isTest
public class TestAssignUnassignedEnett{
    
    static testMethod void testUpdate(){
        setUpTestData();
    }
        
    public static void setUpTestData(){
       /* Opportunity testOpp = new Opportunity (Name = 'Test Region', AccountId = '0019000001F89F1', Region__c= 'Americas', 
                                                Product__c = 'VANs', Type = 'New', CurrencyIsoCode = 'EUR', StageName = 'Proposal', CloseDate = Date.today(),  Primary_Implementation_Contact__c = '003N000000KDFRE');
        Insert testOpp;
        System.debug('The owner is ' + testOpp.owner);
        
        Opportunity testOppEmea = new Opportunity (Name = 'Test Region', AccountId = '001N000000O6mYg', Region__c= 'EMEA', 
                                                Product__c = 'VANs', Type = 'New', CurrencyIsoCode = 'EUR', StageName = 'Proposal', CloseDate = Date.today(),  Primary_Implementation_Contact__c = '003N000000KDFRE');
        Insert testOppEmea ;
        
        System.debug('The owner is ' + testOppEmea.owner); */
        
        Datetime dt = DateTime.parse('10/10/2014 12:00 AM');

        Account testaccount = new Account(Name = 'Account Test', Legal_Name__c = 'Account Test', 
        Client_Status__c = 'Prospect', IntegratorModifiedDate__c = system.now(), IsApi__c = true, Due_Diligence_Completed__c = dt);
        insert testaccount;

        Contact contactperson = new Contact(FirstName = 'Firsttest', LastName = 'Lastest', AccountId = testaccount.id, IsApi__c = true);
        insert contactperson ;
        
        Opportunity Opp = new Opportunity(Name= 'Test Opp', AccountId = testaccount.id, Product__c = 'VANs', 
        Type = 'New', CloseDate = date.valueOf('2014-01-01'), 
        StageName = '1. Prospect', CurrencyIsoCode = 'USD', Region__c= 'Americas');
        
        /*insert Opp;
        
        Opportunity unOpp = new Opportunity(Name= 'Test Opp', AccountId = testaccount.id, Product__c = 'VANs', 
        Type = 'New', CloseDate = date.valueOf('2014-01-01'), 
        StageName = '1. Prospect', CurrencyIsoCode = 'USD', Region__c= 'APAC');
    
        insert unOpp;
        
        System.debug('The owner is ' + Opp.owner);*/
        
    }
}