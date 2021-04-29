public class SetECN {

    @InvocableMethod
    public static void SetAccountECN(List<Id> accId) {
    System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> I am here.');
        // Query implements a lock to prevent Duplicate ECN's being generated
        LIST<Account> acc = 
            [SELECT Id, ECN__c FROM Account WHERE Id IN :accId LIMIT 1 FOR UPDATE];

        // Note: this should be moved to a custom setting
        SET<String> ExcludedECNs = new SET<String>{'999999', '888888', '299996'};

        AggregateResult[] MaxECN = 
            [Select MAX(ECN_Number__c)maxecn FROM Account WHERE ECN__c NOT IN :ExcludedECNs];

        Integer MaxNum = Integer.valueof(MaxECN[0].get('maxecn'));

        acc[0].ECN__c = (MaxNum == null) ? '200000' : String.valueof(++MaxNum);

        try{ Update acc; }
        catch (DMLException e){for (Account account : acc) {account.addError('There was a problem generating the ECN');}
        }

    }
}