@isTest public class HierarchyChartControllerTest {
	
    @isTest static void testRun(){
        
        //Data Setup
        Account testParentAcc = eNettTestUtility.createAccount('Parent');
        Account testChildAcc = eNettTestUtility.createAccountWithECN('Child', '2');
        testChildAcc.Allow_Change_to_Reporting_Parent__c = true;
        testChildAcc.ParentId = testParentAcc.Id;
        update testChildAcc;
        System.debug('#####parent: ' + testChildAcc.Ultimate_Parent__c);
        update testChildAcc;
        String name = 'Parent';
        
        //Perform Test
        test.startTest();
        HierarchyChartController testCtrl = new HierarchyChartController(new ApexPages.StandardController(testChildAcc));
       	testCtrl.getUpar();
        HierarchyChartController.loadAccounts(name);
        test.stopTest();
    }
}