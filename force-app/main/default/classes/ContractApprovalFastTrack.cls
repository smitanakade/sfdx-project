public class ContractApprovalFastTrack {
    
    // Class returns User Ids assigned fast track permission for contract approvals.
    // Refer to SF-1753 for details including approval level definitions.
    
    private static SET<String> FastTrackIdsL1 {get; set;}
    private static SET<String> FastTrackIdsL2 {get; set;}
    private static SET<String> FastTrackIdsL3 {get; set;}
    private static Boolean Initialised = false;

    public static SET<String> getFastTrackIds (Integer Level) {
        if (!Initialised) {
            loadConfigurations();
        }
        if (Level == 1) {
            return FastTrackIdsL1;
        } else if (Level == 2) {
            return FastTrackIdsL2;        
        } else if (Level == 3) {
            return FastTrackIdsL3;
        } else {
            return new SET<String>();
        }
    }
    
    private static void loadConfigurations () {
        String ft1 = Generic_Lookups__c.getInstance('Approval_FastTrack_Level1').Value__c;
        String ft2 = Generic_Lookups__c.getInstance('Approval_FastTrack_Level2').Value__c;
        String ft3 = Generic_Lookups__c.getInstance('Approval_FastTrack_Level3').Value__c;

        FastTrackIdsL1 = new SET<String>();
        FastTrackIdsL2 = new SET<String>();
        FastTrackIdsL3 = new SET<String>();

        if (!string.IsBlank(ft1)) {
            FastTrackIdsL1.addAll(ft1.split(','));
        }
        
        if (!string.IsBlank(ft2)) {
            // Users with Level 2 fast track approval are automatically assigned Level 1 fast track
            FastTrackIdsL1.addAll(ft2.split(','));
            FastTrackIdsL2.addAll(ft2.split(','));
        }
        if (!string.IsBlank(ft3)) {
            // Users with Level 3 fast track approval are automatically assigned Level 1 & Level 2 fast track
            FastTrackIdsL1.addAll(ft3.split(','));
            FastTrackIdsL2.addAll(ft3.split(','));
            FastTrackIdsL3.addAll(ft3.split(','));
        }
        Initialised = true;
        
    }
}