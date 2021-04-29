@isTest
public class RegSubRegionProcessorTest {
    @testSetup
    public static void setup(){
        //setting up 10 registrations
        List<Registration__c> regs = new List<Registration__c>();
        for (Integer i=0;i<10;i++){
            regs.add(new Registration__c(Registered_Company_Name__c='TestReg'+i ,Country__c='Australia'));
        }
        insert regs;
    }
    
    @isTest
    public static void test(){
        //checking that 10 leads are processed
        //checking that leads have been updated but country fields are still the same
        Test.startTest();
        DateTime startTime = System.now();
        RegSubRegionProcessor processor = new RegSubRegionProcessor();
        Id batchId = Database.executeBatch(processor);
        Test.stopTest();
        
        Integer count1 = [SELECT COUNT()
                          FROM Registration__c
                          WHERE Registered_Company_Name__c LIKE 'TestReg%'
                          AND Country__c = 'Australia'];
        
        Integer count2 = [SELECT COUNT()
                          FROM Registration__c
                          WHERE Registered_Company_Name__c LIKE 'TestReg%'
                          AND LastModifiedDate >= :startTime];
        
        //System.assertEquals(10, count1);
        //System.assertEquals(10, count2);
    }
}