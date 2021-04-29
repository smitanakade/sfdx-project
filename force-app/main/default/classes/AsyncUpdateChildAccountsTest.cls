/**
 * Test class to test Asynchronus queueable job to update child Accounts 
 * Queueable Job class: AsyncUpdateChildAccounts.apxc
 * Author: Kishore Potla
 * Date: 21/10/2019
 * 
 * [03/Jan/2020] PDS-6874: Only Additonal ECNs should have same RBA as their parent.
 * 
 * */

@isTest(SeeAllData=TRUE)
public class AsyncUpdateChildAccountsTest {
	
    public static void setup(){
        Account parentAccount = new Account(Name = 'Test Parent Account',
                                  ECN__c = '100001',
                                  RBA_Address_Line_1__c = '111 XXXX Street',
                                  RBA_Address_Line_2__c = '',
                                  RBA_City__c = 'South Brisbane',
                                  RBA_Country__c = 'Australia',
                                  RBA_Postcode__c = '2000',
                                  eNett_products__c = 'eNett EFT',
                                  OwnerID = Userinfo.getUserId()
                                 );
        
        insert parentAccount;
    }
    
    /* Test cases to test queueable apex job for the below scenario. 
     * When R.B.Address of an Account is udpated, in the AfterUpdate event of AccountTrigger, 
     *    a Queueable apex job will be submitted to update the same R.B.Address to all its Additional ECN child accounts
     * 
     * [03/Jan/2020] PDS-6874: Only Additonal ECNs should have same RBA as their parent. Affiliates, Customers and any other accounts should not.
     * 
     **/
    
    @isTest
    public static void testAsyncUpdateChildAccounts_Affiliates(){
    	
        AsyncUpdateChildAccountsTest.setup();
        Account parentAccount = [Select id, OwnerId from Account Where ECN__c = '100001'];
        Account childAffiliate = new Account(Name = 'Test Child Affiliate Account',
                                  ECN__c = '100002',
                                  parentid = parentAccount.id,
                                  Legal_Parent__c = parentAccount.id,
                                  RBA_Address_Line_1__c = '111 XXXX Street',
                                  RBA_Address_Line_2__c = '',
                                  RBA_City__c = 'South Brisbane',
                                  RBA_Country__c = 'Australia',
                                  RBA_Postcode__c = '2000',
                           		  Account_Type__c = 'Affiliate',
                                  eNett_products__c = 'eNett EFT',
                                  Creation_type__c = 'Internal'
                                 );
        
        insert childAffiliate;
        
        test.startTest();
        //Updating RBA on parent account will trigger queueable apex job to update RBA on all Additional ECN childs in hiearchy.
        parentAccount.RBA_Address_Line_1__c = '111 XXXX Street_updated';
        update parentAccount;
        test.stopTest();
        
        childAffiliate = [Select RBA_Address_Line_1__c from Account Where ECN__c = '100002'];
        System.assertEquals('111 XXXX Street',childAffiliate.RBA_Address_Line_1__c);
    }
    
    @isTest
    public static void testAsyncUpdateChildAccounts_AdditionalECNs(){
    	
        AsyncUpdateChildAccountsTest.setup();
        Account parentAccount = [Select id, OwnerId from Account Where ECN__c = '100001'];
        Account childAddiECN = new Account(Name = 'Test Child Additional ECN Account',
                                  ECN__c = '100003',
                                  parentid = parentAccount.id,
                                  Legal_Parent__c = parentAccount.id,
                                  RBA_Address_Line_1__c = '111 XXXX Street',
                                  RBA_Address_Line_2__c = '',
                                  RBA_City__c = 'South Brisbane',
                                  RBA_Country__c = 'Australia',
                                  RBA_Postcode__c = '2000',
                           		  Account_Type__c = 'Additional ECN',
                                  eNett_products__c = 'eNett EFT',
                                  Creation_type__c = 'Internal'
                                 );
        insert childAddiECN;
        
        test.startTest();
        //Updating RBA on parent account will trigger queueable apex job to update RBA on all Additional ECN childs in hiearchy.
        parentAccount.RBA_Address_Line_1__c = '111 YYYY Street_updated';
        update parentAccount;
        test.stopTest();
        
        childAddiECN = [Select RBA_Address_Line_1__c from Account Where ECN__c = '100003'];
        System.assertEquals('111 YYYY Street_updated',childAddiECN.RBA_Address_Line_1__c);
    }
}