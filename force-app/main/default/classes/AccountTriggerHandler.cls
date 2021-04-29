public with sharing class AccountTriggerHandler{
    public void OnAfterUpdate(Map<Id, Account> accMap){
        /**
		* After an account has been updated, 
		* this will loop through all its reporting child additional ECNs,
	    * ensuring that the registered addresses are updated to be the same.
		@author : Ronnie Yang
		@ticket : SF-5165
		**/
        List<Account> childAccs = [SELECT Id, RBA_Address_Line_1__c, RBA_Address_Line_2__c, RBA_City__c, 
                                   RBA_Country__c, RBA_Postcode__c, RBA_State_Province__c, Parent.Id
                                   FROM Account 
                                   WHERE Parent.Id IN:accMap.keySet()];
        for(Account a : childAccs){
            Account parent= accMap.get(a.Parent.Id);
            a.RBA_Address_Line_1__c = parent.RBA_Address_Line_1__c;
            a.RBA_Address_Line_2__c = parent.RBA_Address_Line_2__c;
            a.RBA_City__c = parent.RBA_City__c;
            a.RBA_Country__c = parent.RBA_Country__c;
            a.RBA_Postcode__c = parent.RBA_Postcode__c;
            a.RBA_State_Province__c = parent.RBA_State_Province__c;
        }
        update childAccs;
    }
}