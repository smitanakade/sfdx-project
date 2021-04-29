@istest
public class TestContractApprovalFastTrack {
    public static testMethod void unitTest () {
    
        // Initialise custom setting with assigned contract approval fast track users
        LIST<Generic_Lookups__c> levels = new LIST<Generic_Lookups__c>();
        levels.add(new Generic_Lookups__c(Name = 'Approval_FastTrack_Level1', Value__c = '01pN0000000AAAA,01pN0000000BBBB'));
        levels.add(new Generic_Lookups__c(Name = 'Approval_FastTrack_Level2', Value__c = '01pN0000000CCCC,01pN0000000DDDD'));
        levels.add(new Generic_Lookups__c(Name = 'Approval_FastTrack_Level3', Value__c = '01pN0000000EEEE'));
        insert levels;
        
        // Test that a user assigned L1 Fast Track Approval is contained in the Level 1 fast track user set
        System.assertEquals(true, ContractApprovalFastTrack.getFastTrackIds(1).contains('01pN0000000AAAA'));

        // Test that a user assigned L2 Fast Track Approval is contained in the Level 2 fast track user set
        System.assertEquals(true, ContractApprovalFastTrack.getFastTrackIds(2).contains('01pN0000000CCCC'));

        // Test that a user assigned L1 Fast Track Approval is NOT contained in the Level 3 fast track user set
        System.assertEquals(false, ContractApprovalFastTrack.getFastTrackIds(3).contains('01pN0000000AAAA'));
        
        // Test that a user assigned L3 Fast Track Approval is also contained in the Level 1 and 2 fast track user sets
        System.assertEquals(true, ContractApprovalFastTrack.getFastTrackIds(1).contains('01pN0000000EEEE'));
        System.assertEquals(true, ContractApprovalFastTrack.getFastTrackIds(2).contains('01pN0000000EEEE'));
        
        // Requesting an invalid level should return an empty set
        System.assertEquals(0, ContractApprovalFastTrack.getFastTrackIds(4).size());
    }
}