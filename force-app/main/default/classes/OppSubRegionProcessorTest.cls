@isTest
public class OppSubRegionProcessorTest {
    @testSetup
    public static void setup(){
        //setting up 10 accounts
        List<Opportunity> opps = new List<Opportunity>();
        for (Integer i=0;i<10;i++){
            opps.add(new Opportunity(Name='TestLead'+i,StageName='1. Prospect',CloseDate=System.today(), 
                                     Opportunity_Qualify_Created__c=System.today(),Country__c='Australia'));
        }
        insert opps;
    }
    
    @isTest
    public static void test(){
        //checking that 10 leads are processed
        //checking that leads have been updated but country fields are still the same
        Test.startTest();
        DateTime startTime = System.now();
        OppSubRegionProcessor processor = new OppSubRegionProcessor();
        Id batchId = Database.executeBatch(processor);
        Test.stopTest();
        
        Integer count1 = [SELECT COUNT()
                          FROM Opportunity
                          WHERE Name LIKE 'TestLead%'
                          AND Country__c = 'Australia'];
        
        Integer count2 = [SELECT COUNT()
                          FROM Opportunity
                          WHERE Name LIKE 'TestLead%'
                          AND LastModifiedDate >= :startTime];
        
        System.assertEquals(10, count1);
        System.assertEquals(10, count2);
    }
}