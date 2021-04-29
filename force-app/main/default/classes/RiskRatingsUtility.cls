global class RiskRatingsUtility {
    
    webservice static Boolean checkRiskRatingDowngrade (Id RegId, Id AccId) {
        
        LIST<Risk_Rating_Evidence__c> rrs;
        LIST<Account> accs;
        
        rrs = [SELECT Risk_Rating__c FROM Risk_Rating_Evidence__c WHERE Registration__c = :RegId AND Active__c = true ORDER BY Name DESC LIMIT 1];      
        accs = [SELECT Due_Diligence_Risk_Rating__c FROM Account WHERE Id = :AccId];
        
        // If Risk Rating downgraded from high => return true
        if (!accs.isEmpty() && !rrs.isEmpty() && accs[0].Due_Diligence_Risk_Rating__c == 'High' && rrs[0].Risk_Rating__c != 'High') {
            return true;
        } else {
            return false;
        }
    }

}