/**
 * Asynchronus queueable job to update child Accounts 
 * Author: Kishore Potla
 * Date: 17/10/2019
 * 
 * Note: Due to a complicated account hierarchy of Flight Centre customer, updating Registered Business Adderess on parent ECN
 *       will trigger AfterUpdate trigger event on all its children account. Which is throwing 'Apex CPU time limit exceeded' exception.
 *       Hence Asynchronus queueable job is written to update children accounts. 
 * 
 * [03/Jan/2020] PDS-6874: Only Additonal ECNs should have same RBA as their parent. Affiliates, Customers and any other accounts should not.
 **/
 
public class AsyncUpdateChildAccounts implements Queueable {
    private   Map<Id, Account> accMap= new Map<Id, Account>();
    
    public AsyncUpdateChildAccounts (Map<Id, Account> childrenToScan ){
        accMap = childrenToScan;
    }
    public void execute(QueueableContext context) {

        List<Account> allChildAccounts = new List<Account>();
        List<Account> updateChildAccounts = new List<Account>();
        Map<Id, Account> curLevelChildAccounts = new Map<Id, Account>();
        Set<Id> curLevelParentAccIds = new Set<Id>(accMap.keySet());
        Integer level = 0;
        while(curLevelParentAccIds.size() > 0){
            curLevelChildAccounts = getChildAccounts(curLevelParentAccIds);
            if(curLevelChildAccounts.size() > 0){
                allChildAccounts.addAll(curLevelChildAccounts.values());
                System.debug('########### Count of child Additional ECNs in hierarchy level '+ ++level + ' is ' + curLevelChildAccounts.size());
                curLevelParentAccIds.clear();
                curLevelParentAccIds.addAll(curLevelChildAccounts.keySet());
            }else{
                curLevelParentAccIds.clear();
                System.debug('########### Child Accounts check :: Last level in the Account hierarchy is reached. No more child accounts');
            }
        }
        
        //Update all child accounts registered business address with parent account's RBA
        Account parent = accMap.get(new List<Id>(accMap.keySet()).get(0));
        for(Account a : allChildAccounts){
            if(a.RBA_Address_Line_1__c != parent.RBA_Address_Line_1__c || a.RBA_Address_Line_2__c != parent.RBA_Address_Line_2__c || a.RBA_City__c != parent.RBA_City__c || 
                    a.RBA_Country__c != parent.RBA_Country__c || a.RBA_Postcode__c != parent.RBA_Postcode__c ||  a.RBA_State_Province__c != parent.RBA_State_Province__c){
                a.RBA_Address_Line_1__c = parent.RBA_Address_Line_1__c;
                a.RBA_Address_Line_2__c = parent.RBA_Address_Line_2__c;
                a.RBA_City__c = parent.RBA_City__c;
                a.RBA_Country__c = parent.RBA_Country__c;
                a.RBA_Postcode__c = parent.RBA_Postcode__c;
                a.RBA_State_Province__c = parent.RBA_State_Province__c; 
                        
                updateChildAccounts.add(a); //To update only if RBA is not same as their parent.
            }
        }
        update updateChildAccounts;
        System.debug('########### Total No. of children Accounts updated are: ' + updateChildAccounts.size());     

    }
    // Returns all child Additional ECNs of Parent Ids.
     public Map<Id, Account> getChildAccounts(Set<id> parentAccIds){
        Map<Id, Account> childAccs = new Map<Id, Account>();
        childAccs = new Map<Id, Account>([SELECT Id, RBA_Address_Line_1__c, RBA_Address_Line_2__c, RBA_City__c, 
                                           RBA_Country__c, RBA_Postcode__c, RBA_State_Province__c, Parent.Id
                                           FROM Account 
                                           WHERE Parent.Id IN:parentAccIds
                                             AND Account_Type__c = 'Additional ECN']);
        return childAccs;
    }

}