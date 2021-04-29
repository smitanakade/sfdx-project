public class InvocableMethods {

    @InvocableMethod
    public static void SetAccountsAndVersToReadOnly(List<Id> regIds) {
    
        LIST<Registration_Bank_Account__c> bAs = new LIST<Registration_Bank_Account__c>();
        LIST<Id> bAIds = new LIST<Id>();
        recTypesRBA__c recTypesBA = recTypesRBA__c.getInstance();
        recTypesVer__c recTypesV = recTypesVer__c.getInstance();
        
        for (Registration_Bank_Account__c bA : [SELECT Id, Account_Type__c FROM Registration_Bank_Account__c WHERE Registration__c IN :regIds AND Active__c = true]) {
            //bA.Active__c = false;
            if (bA.Account_Type__c != null && bA.Account_Type__c == 'Funding') {
                bA.RecordTypeId = recTypesBA.Funding_Read_Only__c;
            } else {
                bA.RecordTypeId = recTypesBA.Other_Read_Only__c;
            }
            bAs.add(bA);
            bAIds.add(bA.Id);
        }
    
        List<Verification__c> vers = new List<Verification__c>();        
        for (Verification__c v : [SELECT Id FROM Verification__c WHERE Registration_Bank_Account__c IN :bAIds]) {
            //v.Active__c = false;
            v.RecordTypeId = recTypesV.Bank_Account_Evidence_Read_Only__c;
            vers.add(v);
        }

        update bAs;
        update vers;

    }
    
}