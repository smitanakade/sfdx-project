@isTest
public class AddressSubRegionProcessorTest {
    @testSetup
    public static void setup(){
        //setting up master Account
        Account acc = new Account(Name='TestAccount');
        insert acc;
        //setting up 10 addresses
        List<Address__c> adds = new List<Address__c>();
        for (Integer i=0;i<10;i++){
            //because Name is not writable, using Line1__c as an identifier
            adds.add(new Address__C(Client__c = acc.Id,Line1__c='TestLead'+i ,Country__c='Australia'));
        }
        insert adds;
    }
    
    @isTest
    public static void test(){
        //checking that 10 leads are processed
        //checking that leads have been updated but country fields are still the same
        Test.startTest();
        DateTime startTime = System.now();
        AddressSubRegionProcessor processor = new AddressSubRegionProcessor();
        Id batchId = Database.executeBatch(processor);
        Test.stopTest();
        
        Integer count1 = [SELECT COUNT()
                          FROM Address__c
                          WHERE Line1__c LIKE 'TestLead%'
                          AND Country__c = 'Australia'];
        
        Integer count2 = [SELECT COUNT()
                          FROM Address__c
                          WHERE Line1__c LIKE 'TestLead%'
                          AND LastModifiedDate >= :startTime];
        
        System.assertEquals(10, count1);
        System.assertEquals(10, count2);
    }
}