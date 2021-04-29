@isTest
public class UpdatedAddedChildrenYearlyGDVValueTest {
    @testSetup
    public static void setup(){
        //setting up 10 accounts
        List<Account> accs = new List<Account>();
        for (Integer i=0;i<10;i++){
            accs.add(new Account(Name='TestLead'+i, Added_Children_Yearly_Actual_GDV_Value__c= null));
        }
        insert accs;
    }
    
    @isTest
    public static void test(){
        //checking that 10 accounts are processed and Added_Children_Yearly_Actual_GDV_Value__c fields is updated to 0
        Test.startTest();
        DateTime startTime = System.now();
        UpdatedAddedChildrenYearlyGDVValue processor = new UpdatedAddedChildrenYearlyGDVValue();
        Id batchId = Database.executeBatch(processor);
        Test.stopTest();
        
        Integer count = [SELECT COUNT()
                          FROM Account
                          WHERE Name LIKE 'TestLead%'
                          AND Added_Children_Yearly_Actual_GDV_Value__c = 0];
        
        System.assertEquals(10, count);
    }
}