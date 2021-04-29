global class GetStandardTCTemplate {

    private static MAP<String, String> templateAssignmentMap;
    
    static {
        templateAssignmentMap = new MAP<String, String>();

        for (Document_Template__c dT : [SELECT Id, Product__c, Related_Regions__c 
                                        FROM Document_Template__c
                                        WHERE Type__c = 'Terms and Conditions'
                                        AND Status__c = 'Active'
                                        AND Product__c != null
                                        ORDER BY Activation_Date__c DESC]) {
            for (String region : dT.Related_Regions__c.split(';')) {
                if (!templateAssignmentMap.containsKey(region + dT.Product__c)) templateAssignmentMap.put(region + dT.Product__c, dT.Id);
            }
        }
    }
    
    public static Id getStandardTCTemplate (String region, String product) {
        Id TemplateId = null;
        if (templateAssignmentMap.containsKey(region + product)) {
            TemplateId = templateAssignmentMap.get(region + product);
        }
        return TemplateId;
    }

    public static Id getStandardTCTemplate (String regionproduct) {
        Id TemplateId = null;
        if (templateAssignmentMap.containsKey(regionproduct)) {
            TemplateId = templateAssignmentMap.get(regionproduct);
        }
        return TemplateId;
    }

}