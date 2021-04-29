public class CalculateBusinessHours {

    private static final Map<String, String> regionBHnameMap;
    private static Map<String, Id> BHNameIdMap;
    private static Map<String, Id> regionBHIdMap;
    private static final Id defaultBHId;
    
    static {
        
        regionBHnameMap = new Map<String, String>{'APAC' => 'Australian Eastern Seaboard', 'Americas' => 'San Fransisco', 'EMEA' => 'EMEA'};
        BHNameIdMap = new Map<String, Id>();
        regionBHIdMap = new Map<String, Id>();
        
        for (BusinessHours bH : [SELECT id, isDefault, Name FROM BusinessHours WHERE isActive = true]) {
            BHNameIdMap.put(bH.Name, bH.id);
            if (bH.isDefault) {
                defaultBHId = bH.id;
            }
        }
        
        for (String region : regionBHnameMap.keySet()) {
            if (BHNameIdMap.containsKey(regionBHnameMap.get(region))) {
                regionBHIdMap.put(region, BHNameIdMap.get(regionBHnameMap.get(region)));
            } else {
                regionBHIdMap.put(region, defaultBHId);
            }
        }
    
    }
    
    public static Id getBHId(String bhRegion) {
        return regionBHIdMap.containsKey(bhRegion) ? regionBHIdMap.get(bhRegion) : null;
    }

    public static Decimal calculateElapsedBusinessHours (DateTime startDT, DateTime endDT, Id businessHoursId) {
        if (startDT == null) startDT = Datetime.now();
        return BusinessHours.diff(businessHoursId, startDT, endDT) / 3600000.0;
    }
    
    public static Decimal calculateElapsedBusinessHours (DateTime startDT, DateTime endDT) {
        return calculateElapsedBusinessHours(startDT, endDT, defaultBHId);
    }

    public static Decimal calculateElapsedBusinessHours (String bhRegion, DateTime startDT, DateTime endDT) {
        return calculateElapsedBusinessHours(startDT, endDT, getBHId(bhRegion));
    }

    public static Decimal calculateElapsedBusinessHours (String bhRegion, DateTime startDT, DateTime endDT, Decimal addAccHours) {
        if (addAccHours == null) addAccHours = 0.0;
        return calculateElapsedBusinessHours(startDT, endDT, getBHId(bhRegion)) + addAccHours;
    }

    @future
    public static void updateDDBusinessHoursFuture(Integer queryLimit, Integer offSet) {
        SET<String> auditStatusList = new Set<String>{'In Progress', 'Awaiting Client', 'Awaiting Approval', 'Referred', 
                                                      'Approval In Progress', 'Needs More Time', 'Non Responsive', 'On Hold'};
        updateDDBusinessHours(queryLimit, offSet, auditStatusList);        
    }

    public static void updateDDBusinessHours() {
        SET<String> auditStatusList = new Set<String>{'In Progress', 'Awaiting Client', 'Awaiting Approval', 'Referred', 
                                                      'Approval In Progress', 'Needs More Time', 'Non Responsive', 'On Hold'};
        updateDDBusinessHours(100, 0, auditStatusList);
    }

    public static void updateDDBusinessHours(Integer queryLimit, Integer offSet, SET<String> auditStatusList) {
        DateTime dtNow = Datetime.now();
        LIST<Registration__c> regUpdateList = new LIST<Registration__c>();
        for (Registration__c r : [SELECT Id, DD_Status__c, BH_Region__c, BH_lastupdated__c,
                                         BH_InProgress__c, BH_AwaitingClient__c, BH_AwaitingApproval__c, BH_Referred__c, BH_OnHold__c,
                                         BH_ApprovalInProgress__c, BH_NeedsMoreTime__c, BH_NonResponsive__c
                                  FROM Registration__c WHERE DD_Status__c IN: auditStatusList ORDER BY CreatedDate DESC LIMIT :queryLimit OFFSET :offSet]) { // Limit records to avoid CPU timeout -> should never be this many active DDs
            if (r.DD_Status__c == 'In Progress') {
                r.BH_InProgress__c = CalculateBusinessHours.calculateElapsedBusinessHours(r.BH_Region__c, r.BH_lastupdated__c, dtNow, r.BH_InProgress__c);
            } else if (r.DD_Status__c == 'Awaiting Client') {
                r.BH_AwaitingClient__c = CalculateBusinessHours.calculateElapsedBusinessHours(r.BH_Region__c, r.BH_lastupdated__c, dtNow, r.BH_AwaitingClient__c);
            } else if (r.DD_Status__c == 'Awaiting Approval') {
                r.BH_AwaitingApproval__c = CalculateBusinessHours.calculateElapsedBusinessHours(r.BH_Region__c, r.BH_lastupdated__c, dtNow, r.BH_AwaitingApproval__c);
            } else if (r.DD_Status__c == 'Referred') {
                r.BH_Referred__c = CalculateBusinessHours.calculateElapsedBusinessHours(r.BH_Region__c, r.BH_lastupdated__c, dtNow, r.BH_Referred__c);
            } else if (r.DD_Status__c == 'Approval In Progress') {
                r.BH_ApprovalInProgress__c = CalculateBusinessHours.calculateElapsedBusinessHours(r.BH_Region__c, r.BH_lastupdated__c, dtNow, r.BH_ApprovalInProgress__c);
            } else if (r.DD_Status__c == 'Needs More Time') {
                r.BH_NeedsMoreTime__c = CalculateBusinessHours.calculateElapsedBusinessHours(r.BH_Region__c, r.BH_lastupdated__c, dtNow, r.BH_NeedsMoreTime__c);
            } else if (r.DD_Status__c == 'Non Responsive') {
                r.BH_NonResponsive__c = CalculateBusinessHours.calculateElapsedBusinessHours(r.BH_Region__c, r.BH_lastupdated__c, dtNow, r.BH_NonResponsive__c);
            } else if (r.DD_Status__c == 'On Hold') {
                r.BH_OnHold__c = CalculateBusinessHours.calculateElapsedBusinessHours(r.BH_Region__c, r.BH_lastupdated__c, dtNow, r.BH_OnHold__c);
            }
            r.BH_lastupdated__c = dtNow;
            regUpdateList.add(r);
        }
        update regUpdateList;
    }

}