@isTest
public class LeadSubRegionProcessorTest {
    @testSetup
    public static void setup(){
        //setting up 10 leads
        List<Lead> leads = new List<Lead>();
        for (Integer i=0;i<10;i++){
            leads.add(new Lead(LastName='TestLead'+i, Company = 'Test Company', Country__c='Australia'));
        }
        insert leads;
    }
    
    @isTest
    public static void test(){
        //checking that 10 leads are processed
        //checking that leads have been updated but country fields are still the same
        Test.startTest();
        DateTime startTime = System.now();
        LeadSubRegionProcessor processor = new LeadSubRegionProcessor();
        Id batchId = Database.executeBatch(processor);
        Test.stopTest();
        
        Integer count1 = [SELECT COUNT()
                          FROM Lead
                          WHERE LastName LIKE 'TestLead%'
                          AND Country__c = 'Australia'];
        
        Integer count2 = [SELECT COUNT()
                          FROM Lead
                          WHERE LastName LIKE 'TestLead%'
                          AND LastModifiedDate >= :startTime];
        
        System.assertEquals(10, count1);
        System.assertEquals(10, count2);
    }
}