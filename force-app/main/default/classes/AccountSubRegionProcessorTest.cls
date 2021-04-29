@isTest
public class AccountSubRegionProcessorTest {
    @testSetup
    public static void setup(){
        //setting up 10 accounts
        List<Account> accs = new List<Account>();
        for (Integer i=0;i<10;i++){
            accs.add(new Account(Name='TestLead'+i, Country__c='Australia'));
        }
        insert accs;
    }
    
    @isTest
    public static void test(){
        //checking that 10 leads are processed
        //checking that leads have been updated but country fields are still the same
        Test.startTest();
        DateTime startTime = System.now();
        AccountSubRegionProcessor processor = new AccountSubRegionProcessor();
        Id batchId = Database.executeBatch(processor);
        Test.stopTest();
        
        Integer count1 = [SELECT COUNT()
                          FROM Account
                          WHERE Name LIKE 'TestLead%'
                          AND Country__c = 'Australia'];
        
        Integer count2 = [SELECT COUNT()
                          FROM Account
                          WHERE Name LIKE 'TestLead%'
                          AND LastModifiedDate >= :startTime];
        
        System.assertEquals(10, count1);
        System.assertEquals(10, count2);
    }
}