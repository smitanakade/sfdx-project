@isTest
private class TEST_SetECN {
	
	@isTest static void test_ECN_Creation() {

		Account testAccount = TEST_DataFactory.createAccount();
		insert testAccount;
		System.assert(testAccount.Id != null, 'Account not inserted.');
		System.Debug('---------------Account ID:' + testAccount.Id);

		testAccount.ECN__c = '9876';
		update testAccount;

		List<Id> aId = new List<Id>{testAccount.Id};  
		System.Debug('---------------Account ID List:' + aId);

		SetECN.SetAccountECN(aId);

	}
	
	
}