global with sharing class HierarchyChartController{

    private final Account acct;
    
    public HierarchyChartController(ApexPages.StandardController stdController) {
        if (!Test.isRunningTest()) {
        stdController.addFields(new List<String>{'Ultimate_Parent__c'});
        stdController.addFields(new List<String>{'Name'});
        }
        this.acct = (Account)stdController.getRecord();
    }
        
 
     public String getUpar() {
        return acct.Ultimate_Parent__c;
    }

 
    @RemoteAction 
    global static List<Account> loadAccounts(string UltPar){    
        return [select Id,Name,ParentId from Account where Ultimate_Parent__c = :UltPar order by CreatedDate DESC];
    }
    
}