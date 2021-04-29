public class UpdateRRActiveCheckboxes {
    /*
    @InvocableMethod
    public static void UpdateToInactive (List<Id> rIds) {

        LIST<Risk_Rating_Evidence__c> cRs = new LIST<Risk_Rating_Evidence__c>();
        SET<Id> pRIds = new SET<Id>();
    
        for (Risk_Rating_Evidence__c cR : [SELECT Id, Due_Diligence_Checklist__c FROM Risk_Rating_Evidence__c WHERE Id IN :rIds]) {
            pRIds.add(cR.Due_Diligence_Checklist__c);
        }
        
        for (Risk_Rating_Evidence__c cR : [SELECT Id FROM Risk_Rating_Evidence__c WHERE Status__c = 'Active' AND Due_Diligence_Checklist__c IN :pRIds AND Id NOT IN :rIds]) {
            cR.Status__c = 'Inactive';
            cRs.add(cR);
        }

        if (cRs.size() > 0) {
            database.update(cRs, false);
        }
        
    } 
    */

}