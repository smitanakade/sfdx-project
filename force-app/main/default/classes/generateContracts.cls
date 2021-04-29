global class generateContracts {  

    @InvocableMethod
    webservice static void generateContract(List<Id> contractIDs) {
        List<Id> filteredIds = new List<Id>();
        for (eNett_Contract__c ct : [SELECT id, Account_Name__r.Reference_Registration__c, country_product__c FROM eNett_Contract__c WHERE Id in :contractIDs]) {
            if (ct.country_product__c != 'A-EV' && ct.country_product__c != 'NZ-EV' && ct.Account_Name__c != null && ct.Account_Name__r.Reference_Registration__c != null)
                ClientAgreementController.savePDF(ct.Account_Name__r.Reference_Registration__c, ct.Id);
                //filteredIds.add(ct.id);
        }
        
        //if (!filteredIds.isEmpty()) {
        //    generateContracts.batchGenerate(filteredIds, UserInfo.getSessionID());
        //}

    }

    @future(callout=true)
    public static void batchGenerate(LIST<ID> contractIDs, String sessionID) { 

        final ID DDPId = Generic_Lookups__c.getInstance('Standard_Agreement_DDP').Value__c;
        final ID deliveryId = Generic_Lookups__c.getInstance('Standard_Agreement_DDP_Delivery').Value__c;


        Loop.loopMessage lm = new Loop.loopMessage();
        for (ID contractId : contractIDs) {
            lm.requests.add(new Loop.loopMessage.loopMessageRequest(contractId, DDPId, new Map<string, string>{'deploy' => deliveryId}));
        }
        lm.sessionId = sessionID;
        lm.sendAllRequests();
    }

    /* Obsolete PoC
    public static void setTCsVersion(LIST<ID> contractIDs) { 

        // Map containing the latest versions of the T&Cs for each region
        Map<string,ContentDocument> versionMap = new Map<string,ContentDocument>();
        for( ContentDocument cd : [ Select Id,Title, LatestPublishedVersionId from ContentDocument where Title Like 'eNett - Client Agreement%']){
            versionMap.put( cd.Title, cd );
        } 

        Id TCVersionID = null;
        List<eNett_Contract__c> contrUpdate = new LIST<eNett_Contract__c>();

        for (eNett_Contract__c contr : [select Id, Country_Product__c, Account_Region__c, APAC_Country__c, eNett_Product__c from eNett_Contract__c  where Id in :contractIDs]) {

            TCVersionID = null;

            if (contr.Country_Product__c == 'A-V') TCVersionID = versionMap.get('eNett - Client Agreement AUS VANs only').LatestPublishedVersionId;
            else if ( contr.Country_Product__c == 'A-E') TCVersionID = versionMap.get('eNett - Client Agreement AUS EFT only').LatestPublishedVersionId;
            else if ( contr.Country_Product__c == 'A-EV') TCVersionID = versionMap.get('eNett - Client Agreement AUS EFT and VANs').LatestPublishedVersionId;
            else if ( contr.Country_Product__c == 'A-EV*') TCVersionID = versionMap.get('eNett - Client Agreement AUS EFT and VANs').LatestPublishedVersionId;
            else if ( contr.Country_Product__c == 'NZ-V') TCVersionID = versionMap.get('eNett - Client Agreement NZ VANs Only').LatestPublishedVersionId;
            else if ( contr.Country_Product__c == 'NZ-E') TCVersionID = versionMap.get('eNett - Client Agreement NZ EFT only').LatestPublishedVersionId;
            else if ( contr.Country_Product__c == 'NZ-EV') TCVersionID = versionMap.get('eNett - Client Agreement NZ EFT and VANs').LatestPublishedVersionId;
            else if ( contr.Country_Product__c == 'NZ-EV*') TCVersionID = versionMap.get('eNett - Client Agreement NZ EFT and VANs').LatestPublishedVersionId;
            else TCVersionID = versionMap.get('eNett - Terms and Conditions Rest of the world').LatestPublishedVersionId;

            contr.Path_To_T_Cs__c = URL.getSalesforceBaseUrl().toExternalForm() + '/' + TCVersionID;
            contrUpdate.add(contr);
        }
        database.update(contrUpdate, false);
    }*/

}