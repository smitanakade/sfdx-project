@isTest 
public class UpdateDefaultYearlyActualUSDTest {
    @isTest static void UpdateDefaultYearlyActualUSDTest(){
        //Data setup
        List<Account> accountList = new List<Account>();
        for(Integer i = 0; i < 10; i++){
            accountList.add(new Account(Name = 'Account ' + i,
                                        Children_Yearly_Actual_USD__c = NULL));
        }
        insert accountList;
        
        //Perform test
        Test.startTest();
        UpdateDefaultYearlyActualUSD udya = new UpdateDefaultYearlyActualUSD();
        Id batchId = Database.executeBatch(udya);
        Test.stopTest();
        
        //Verify
        System.assertEquals(10, [SELECT Count() FROM Account WHERE Children_Yearly_Actual_USD__c = 0 ]);
    }
}