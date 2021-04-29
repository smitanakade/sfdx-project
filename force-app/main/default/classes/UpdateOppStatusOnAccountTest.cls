@isTest
public class UpdateOppStatusOnAccountTest {
    @testSetup static void Setup(){
        Account a = new Account(Name = 'TestAcc');
        Account b = new Account(Name = 'TestAcc2');
        insert a;
        insert b;
        Opportunity oProspect = new Opportunity(Name = 'oProspect', StageName = '1. Prospect', CloseDate = Date.Today(), Opportunity_Qualify_Created__c = Date.Today(), AccountId = a.Id);
        Opportunity oQualified = new Opportunity(Name = 'oQualified', StageName = '2. Sales Qualified', CloseDate = Date.Today(), Opportunity_Qualify_Created__c = Date.Today(), AccountId = a.Id);
        Opportunity oLost = new Opportunity(Name = 'oLost', StageName = '7. Closed/Lost', CloseDate = Date.Today(), Opportunity_Qualify_Created__c = Date.Today(), AccountId = a.Id);
        Opportunity oRemoved = new Opportunity(Name = 'oRemoved', StageName = '8. Closed/Lost - Product Removed', CloseDate = Date.Today(), Opportunity_Qualify_Created__c = Date.Today(), AccountId = a.Id);
        insert oProspect;
        insert oQualified;
        insert oLost;
        insert oRemoved;
    }
    
    @isTest static void InProgress () {
        //Amber means in progress
        //So as long as one of the opportunities is Prospect, Status is the same name of the last modified opp
        Account a = [SELECT Id, Opportunity_Status__c,
                     (SELECT id, StageName FROM Opportunities ORDER BY LastModifiedDate DESC LIMIT 50)
                     FROM Account
                     WHERE Name = 'TestAcc' LIMIT 1];
        //Last modified opp should represent the status of the opportunities on account
        System.assertEquals(a.Opportunities[0].StageName, a.Opportunity_Status__c);
    }
    
    @isTest public static void AllRemoved () {
        //When all opportunities have product removed as status
        Account a = [SELECT Id, Opportunity_Status__c,
                     (SELECT id, StageName FROM Opportunities ORDER BY LastModifiedDate DESC LIMIT 50)
                     FROM Account
                     WHERE Name = 'TestAcc' LIMIT 1];
        for(Opportunity o : a.Opportunities){
            //remove opp if it doesn't have product removed as status
            if(o.StageName != '8. Closed/Lost - Product Removed')
                o.AccountId = null;
        }
        update a.Opportunities;
        Account after = [SELECT Id, Opportunity_Status__c
                         FROM Account
                         WHERE Name = 'TestAcc' LIMIT 1];
        System.assertEquals('Product Removed', after.Opportunity_Status__c);
    }
    
    @isTest public static void NoOpp () {
        //When no opportunity exists
        Account a = [SELECT Id, Opportunity_Status__c,
                     (select id, StageName from Opportunities ORDER BY LastModifiedDate DESC LIMIT 50)
                     FROM Account
                     WHERE Name = 'TestAcc' LIMIT 1];
        for(Opportunity o : a.Opportunities){
            //remove all opp
            o.AccountId = null;
        }
        update a.Opportunities;
        Account after = [SELECT Id, Opportunity_Status__c
                         FROM Account
                         WHERE Name = 'TestAcc' LIMIT 1];
        System.assertEquals('Not Available', after.Opportunity_Status__c);
    }
    
    @isTest public static void Qualified () {
        //None of the above applies, opportunities are all qualified
        Account a = [SELECT Id, Opportunity_Status__c,
                     (SELECT id, StageName FROM Opportunities ORDER BY LastModifiedDate DESC LIMIT 50)
                     FROM Account
                     WHERE Name = 'TestAcc' LIMIT 1];
        for(Opportunity o : a.Opportunities){
            //remove opp if it doesn't qualified as status
            if(o.StageName != '2. Sales Qualified')
                o.AccountId = null;
        }
        update a.Opportunities;
        Account after = [SELECT Id, Opportunity_Status__c
                         FROM Account
                         WHERE Name = 'TestAcc' LIMIT 1];
        System.assertEquals('Qualified', after.Opportunity_Status__c);
    }       
    @isTest static void ReReferenceTest(){
        //When an opportunity changes its reference account
        //Both the old and new account should be updated
        Account a = [SELECT Id, Opportunity_Status__c,
                     (SELECT id, StageName FROM Opportunities ORDER BY LastModifiedDate DESC LIMIT 50)
                     FROM Account
                     WHERE Name = 'TestAcc' LIMIT 1];
        
        Account b = [SELECT Id
                     FROM Account
                     WHERE Name = 'TestAcc2' LIMIT 1];
        //Re-reference to Account b
        for(Opportunity o : a.Opportunities){
                o.AccountId = b.Id;
        }
        update a.Opportunities;
        Account aAfter = [SELECT Id, Opportunity_Status__c
                          FROM Account
                          WHERE Name = 'TestAcc' LIMIT 1];
        Account bAfter = [SELECT Id, Opportunity_Status__c
                          FROM Account
                          WHERE Name = 'TestAcc2' LIMIT 1];
        System.assertEquals('Not Available', aAfter.Opportunity_Status__c);
        System.assertNotEquals(null, bAfter.Opportunity_Status__c);
    }
}