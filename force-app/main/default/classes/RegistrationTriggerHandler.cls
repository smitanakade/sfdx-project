public class RegistrationTriggerHandler {
    public void onBeforeInsert(List<Registration__c> newList){
        populateCountryProductFields(newList);
        updateReferrer(newList);
    }
    
    public void onBeforeUpdate(Map<Id, Registration__c> oldMap, Map<Id, Registration__c> newMap){
        populateCountryProductFields(oldMap, newMap);
        updateReferrer(newMap.values());
        calculateDDHours(oldMap, newMap);
        FieldAuditing.doFieldAuditing('Registration__c', (Map<Id, SObject>) oldMap, (list<SObject>) newMap.values());
    }
    
    public void onAfterInsert(Map<Id, Registration__c> newMap){
        updateReferenceLead(newMap);
    }
    
    public void onAfterUpdate(Map<Id, Registration__c> newMap){
        updateReferenceLead(newMap);
    }
    /*
* This method updates the key information on the the reference lead when a registration is created or updated
*/ 
    private void updateReferenceLead(Map<Id, Registration__c> newMap){
        List<Lead> leadsToUpsert = new List<Lead>();
        //get reference leads that are converted so we are not updating them
        Map<Id, Lead> convertedReferenceLeadMap = new Map<Id, Lead>([
            SELECT Id FROM Lead WHERE Reference_Registration__c IN : newMap.keySet() AND IsConverted = true
        ]);
        
        for(Registration__c r : newMap.values()){
            //External reg inserted without lead attached --> to insert a lead
            if (r.Registration_Type__c == 'External Registration' && r.Lead__c == null) {
                Lead l = new Lead (
                    Salutation = r.Salutation__c,
                    FirstName = r.First_Name__c,
                    LastName = r.Last_Name__c,
                    Company = r.Registered_Company_Name__c,
                    Job_Title__c = r.Job_Title__c,
                    Account_Type__c = 'Customer',
                    eNett_Products__c = r.Product__c,
                    Reference_Registration__c = r.Id,
                    LeadSource = 'eNett Online Registration',
                    Country__c = r.Country__c,
                    Email = r.Email__c,
                    Phone = r.Phone__c,
                    Registration_Type__c = 'External Registration',
                    Referrer__c = r.Referrer__c,
                    Contract_Type__c = 'Standard T&Cs'
                );
                leadsToUpsert.add(l);
            }
            //External reg that has Lead --> update the lead
            else if (r.Lead__c != null && convertedReferenceLeadMap.get(r.Lead__c) == null && r.Registration_Type__c == 'External Registration') {
                Lead l = new Lead (
                    Id = r.Lead__c,
                    Salutation = r.Salutation__c,
                    FirstName = r.First_Name__c,
                    LastName = r.Last_Name__c,
                    Company = r.Registered_Company_Name__c,
                    Job_Title__c = r.Job_Title__c,
                    Account_Type__c = 'Customer',
                    eNett_Products__c = r.Product__c,
                    Reference_Registration__c = r.Id,
                    LeadSource = 'eNett Online Registration',
                    Country__c = r.Country__c,
                    Email = r.Email__c,
                    Phone = r.Phone__c,
                    Registration_Type__c = 'External Registration',
                    Referrer__c = r.Referrer__c,
                    Contract_Type__c = 'Standard T&Cs'
                );
                leadsToUpsert.add(l);
            }
            try{
                
                upsert leadsToUpsert;
            } catch (Exception e){
                System.debug('####ERROR ENCOUNTERED: ' + e.getMessage());
                throw e;
            }
        }
    }
    /*
* This helps calculate the business hour elapsed in the process of progressing DD
*/ 
    private void calculateDDHours(Map<Id, Registration__c> oldMap, Map<Id, Registration__c> newMap){
        String oldDDStatus, oldOwnerId, oldBHRegion;
        DateTime dtNow = Datetime.now();
        for (Registration__c r : newMap.values()) {
            oldDDStatus = oldMap.get(r.Id).DD_Status__c;
            oldOwnerId = oldMap.get(r.Id).OwnerId;        
            
            if (r.DD_Status__c != oldDDStatus || r.OwnerId != oldOwnerId) {            
                oldBHRegion = oldMap.get(r.Id).BH_Region__c;            
                if (oldDDStatus == 'In Progress') {
                    r.BH_InProgress__c = CalculateBusinessHours.calculateElapsedBusinessHours(oldBHRegion, r.BH_lastupdated__c, dtNow, r.BH_InProgress__c);
                } else if (oldDDStatus == 'Awaiting Client') {
                    r.BH_AwaitingClient__c = CalculateBusinessHours.calculateElapsedBusinessHours(oldBHRegion, r.BH_lastupdated__c, dtNow, r.BH_AwaitingClient__c);
                } else if (oldDDStatus == 'Awaiting Approval') {
                    r.BH_AwaitingApproval__c = CalculateBusinessHours.calculateElapsedBusinessHours(oldBHRegion, r.BH_lastupdated__c, dtNow, r.BH_AwaitingApproval__c);
                } else if (oldDDStatus == 'Referred') {
                    r.BH_Referred__c = CalculateBusinessHours.calculateElapsedBusinessHours(oldBHRegion, r.BH_lastupdated__c, dtNow, r.BH_Referred__c);
                } else if (oldDDStatus == 'Approval In Progress') {
                    r.BH_ApprovalInProgress__c = CalculateBusinessHours.calculateElapsedBusinessHours(oldBHRegion, r.BH_lastupdated__c, dtNow, r.BH_ApprovalInProgress__c);
                } else if (oldDDStatus == 'Needs More Time') {
                    r.BH_NeedsMoreTime__c = CalculateBusinessHours.calculateElapsedBusinessHours(oldBHRegion, r.BH_lastupdated__c, dtNow, r.BH_NeedsMoreTime__c);
                } else if (oldDDStatus == 'Non Responsive') {
                    r.BH_NonResponsive__c = CalculateBusinessHours.calculateElapsedBusinessHours(oldBHRegion, r.BH_lastupdated__c, dtNow, r.BH_NonResponsive__c);
                } else if (oldDDStatus == 'On Hold') {
                    r.BH_OnHold__c = CalculateBusinessHours.calculateElapsedBusinessHours(oldBHRegion, r.BH_lastupdated__c, dtNow, r.BH_OnHold__c);
                }
                
                r.BH_lastupdated__c = dtNow;
            }
        }
    }
    /*
* When a user puts down an Referrer ECN, the corresponding referrer id will be written to the Referrer__c field
*/
    private void updateReferrer(List<Registration__c> newList){
        Set<String> referrerECNs = new Set<String>();
        List<Registration__c> registrationsToUpdate = new List<Registration__c>();
        for(Registration__c r : newList){
            if (r.Referrer_ECN__c != null && r.Referrer_ECN__c.isNumeric()){
                referrerECNs.add(r.Referrer_ECN__c);
                registrationsToUpdate.add(r);
            }
        }
        if (referrerECNs.size()>0){
            Map<String, Account> referrerAccountByECNMap = new Map<String, Account>();
            for(Account a : [SELECT Id, ECN__c FROM Account WHERE Account_Type__c = 'Referrer' AND ECN__c IN: referrerECNs]){
                if(a.ECN__c != null)
                    referrerAccountByECNMap.put(a.ECN__c, a);
            }
            for(Registration__c r : registrationsToUpdate){
                if(referrerAccountByECNMap.get(r.Referrer_ECN__c) != null)
                    r.Referrer__c = referrerAccountByECNMap.get(r.Referrer_ECN__c).Id;
                else
                    r.addError('No referrer account found with the referrer ECN provided.');
            }
        }
    }
    /*
* For inserts only,
* Before a new reg is inserted, this method will populate all the country/product specific info on the record
*/
    private void populateCountryProductFields(List<Registration__c> newList){
        for(Registration__c r : newList){
            String country = r.Country__c;
            String products = r.Product__c;
            CountryMappings__c info = CountryMappings__c.getInstance(country);
            //don't proceed if the country name is invalid
            if(info != null){
                //if country is not null and country has changed
                if(country != null){
                    r.Region__c = info.Region__c;
                    r.Sub_Region__c = info.Sub_Region__c;
                    r.Sub_Region_2__c = info.Sub_Region_2__c;
                    r.Standard_TCs_Template_EFT__c = GetStandardTCTemplate.getStandardTCTemplate((country == 'Australia' || country == 'New Zealand') ? country : info.Region__c, 'eNett EFT');
                    r.Standard_TCs_template_VANs__c = GetStandardTCTemplate.getStandardTCTemplate((country == 'Australia' || country == 'New Zealand') ? country : info.Region__c, 'VANs');
                }
                //if product is not null and product has changed
                if(products != null){
                    r.EFT_Subscription_Fee__c = (!products.contains('eNett EFT') || info.EFT_Subscription_Fee__c == 0) ? null : info.EFT_Subscription_Fee__c;
                    r.EFT_Transaction_Fee__c =  (!products.contains('eNett EFT')) ? null : info.EFT_Transaction_Fee__c;
                    r.EFT_Default_Payment__c = (!products.contains('eNett EFT')) ? null : info.EFT_Default_Payment__c;
                    r.VANs_Subscription_Fee__c = (!products.contains('VANs')) ? null : info.VANs_Subscription_Fee__c;
                    r.eNett_Account_Fee__c = (!products.contains('VANs')) ? null : info.eNett_Account_Fee__c;
                    r.Chargeback_Fee_With_Document__c = (!products.contains('VANs')) ? null : info.Chargeback_Fee_With_Document__c;
                    r.Chargeback_Fee_Without_Document__c = (!products.contains('VANs')) ? null : info.Chargeback_Fee_Without_Document__c;
                    r.Subscription_Fee_Currency__c = info.Enett_Default_Currency__c;
                    r.Subscription_Fee_Symbol__c = info.Enett_Default_Currency_Symbol__c;
                }     
            }
        }
    }    
    /*
* For updates only,
* Before country/product is updated on a reg this method will populate update the country/product specific info 
*/
    private void populateCountryProductFields(Map<Id, Registration__c> oldMap, Map<Id, Registration__c> newMap){
        for(Registration__c r : newMap.values()){
            String country = r.Country__c;
            String products = r.Product__c;
            CountryMappings__c info = CountryMappings__c.getInstance(country);
            //SF-5381 3/12/2018 Jasmine - Check if T&C is accepted, if yes then do not update the version of T&C
            Boolean TCAccepted = r.Accept_Terms_and_Conditions__c;
            //don't proceed if the country name is invalid
            if(info != null){
                //if country is not null and country has changed
                if(country != null && country != oldMap.get(r.Id).Country__c){
                    r.Region__c = info.Region__c;
                    r.Sub_Region__c = info.Sub_Region__c;
                    r.Sub_Region_2__c = info.Sub_Region_2__c;
                    //SF-5381 3/12/2018 Jasmine - Check if T&C is accepted, if yes then do not update the version of T&C
                    if (TCAccepted != true){
                        r.Standard_TCs_Template_EFT__c = GetStandardTCTemplate.getStandardTCTemplate((country == 'Australia' || country == 'New Zealand') ? country : info.Region__c, 'eNett EFT');
                        r.Standard_TCs_template_VANs__c = GetStandardTCTemplate.getStandardTCTemplate((country == 'Australia' || country == 'New Zealand') ? country : info.Region__c, 'VANs');
                    }
                }
                
                //if product is not null and product has changed
                if(products != null && products != (String)oldMap.get(r.Id).Product__c){
                    r.EFT_Subscription_Fee__c = (!products.contains('eNett EFT') || info.EFT_Subscription_Fee__c == 0) ? null : info.EFT_Subscription_Fee__c;
                    r.EFT_Transaction_Fee__c =  (!products.contains('eNett EFT')) ? null : info.EFT_Transaction_Fee__c;
                    r.EFT_Default_Payment__c = (!products.contains('eNett EFT')) ? null : info.EFT_Default_Payment__c;
                    r.VANs_Subscription_Fee__c = (!products.contains('VANs')) ? null : info.VANs_Subscription_Fee__c;
                    r.eNett_Account_Fee__c = (!products.contains('VANs')) ? null : info.eNett_Account_Fee__c;
                    r.Chargeback_Fee_With_Document__c = (!products.contains('VANs')) ? null : info.Chargeback_Fee_With_Document__c;
                    r.Chargeback_Fee_Without_Document__c = (!products.contains('VANs')) ? null : info.Chargeback_Fee_Without_Document__c;
                    r.Subscription_Fee_Currency__c = info.Enett_Default_Currency__c;
                    r.Subscription_Fee_Symbol__c = info.Enett_Default_Currency_Symbol__c;
                }     
            }
        }
        
    }
}