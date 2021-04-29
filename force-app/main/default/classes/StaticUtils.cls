public class StaticUtils {
    //this is to populate country related info based on the country list custom setting
    public static void PopulateCountryFields( sObject obj ){
        if (obj != null){
            //don't proceed if the object has no country field
            if(obj.getSobjectType().getDescribe().fields.getMap().keySet().contains('country__c')){
                
                //Surajsingh Thakur : PDS-2913 : Additional EFT ECN automatically assigned incorrect Country - Start
                CountryMappings__c info = NULL;
                
                if((obj instanceOf Account) && ((string)obj.get('Country__c')==NULL || (string)obj.get('Country__c') == '')){
                    List<Account> parents = [Select id, Country__c from Account Where id =:(string)obj.get('ParentId') LIMIT 1];  
                    
                    if(parents.size()>0){
                        Account parent = parents[0];
                        info = CountryMappings__c.getInstance(parent.Country__c); 
                        if(info!=NULL){
                            obj.put('Country__c', info.Name);
                        }
                    }
                }
                
                else if(obj instanceOf Account){
                    if((string)obj.get('Country__c')!=NULL && (string)obj.get('Country__c')!=''){
                        info = CountryMappings__c.getInstance((string)obj.get('Country__c'));
                        if(info!=NULL){
                            obj.put('Country__c', info.Name);
                        }
                    }
                }
                //Surajsingh Thakur : PDS-2913 : Additional EFT ECN automatically assigned incorrect Country - End
                
                //don't proceed if the country name is invalid
                if(info != null){
                    obj.put('CountryCode2__c', info.ISO2__c);
                    obj.put('CountryCode3__c', info.ISO3__c);
                    obj.put('CurrencyName__c', info.currency_name__c);
                    obj.put('CurrencyCode__c', info.currency_alphabetic_code__c);
                    obj.put('Region__c', info.Region__c);
                    obj.put('Sub_Region__c', info.Sub_Region__c);
                    obj.put('Sub_Region_2__c', info.Sub_Region_2__c);}
            }
        }   
    }
    
    //this method is only applicable to Registration__c -- why are we accepting sObject?
    public static void PopulateRegSubscriptionFields(sObject obj, Boolean countryChanged ) {
        String country, products;
        if (obj != null){
            //don't proceed if the object has no country or products field
            if(obj.getSobjectType().getDescribe().fields.getMap().keySet().contains('country__c') &&
               obj.getSobjectType().getDescribe().fields.getMap().keySet().contains('product__c')){
                   country = (string)obj.get('Country__c');
                   products = (string)obj.get('Product__c');
                   CountryMappings__c info = CountryMappings__c.getInstance(country);
                   //don't proceed if the country name is invalid
                   if(info != null){
                       obj.put('Region__c', info.Region__c);
                       obj.put('Sub_Region__c', info.Sub_Region__c);
                       obj.put('Sub_Region_2__c', info.Sub_Region_2__c);
                       obj.put('Standard_TCs_Template_EFT__c', GetStandardTCTemplate.getStandardTCTemplate((country == 'Australia' || country == 'New Zealand') ? country : info.Region__c, 'eNett EFT'));
                       obj.put('Standard_TCs_template_VANs__c', GetStandardTCTemplate.getStandardTCTemplate((country == 'Australia' || country == 'New Zealand') ? country : info.Region__c, 'VANs'));
                       if(countryChanged){
                           //SF-4883 Add condition checking if products is not null to cater for a registration which does not have a product 
                           if(products != null){
                               obj.put('EFT_Subscription_Fee__c', (!products.contains('eNett EFT') || info.EFT_Subscription_Fee__c == 0) ? null : info.EFT_Subscription_Fee__c);
                               obj.put('EFT_Transaction_Fee__c',  (!products.contains('eNett EFT')) ? null : info.EFT_Transaction_Fee__c);
                               obj.put('EFT_Default_Payment__c', (!products.contains('eNett EFT')) ? null : info.EFT_Default_Payment__c);
                               obj.put('VANs_Subscription_Fee__c', (!products.contains('VANs')) ? null : info.VANs_Subscription_Fee__c);
                               obj.put('eNett_Account_Fee__c', (!products.contains('VANs')) ? null : info.eNett_Account_Fee__c);
                               obj.put('Chargeback_Fee_With_Document__c', (!products.contains('VANs')) ? null : info.Chargeback_Fee_With_Document__c);
                               obj.put('Chargeback_Fee_Without_Document__c', (!products.contains('VANs')) ? null : info.Chargeback_Fee_Without_Document__c);
                               obj.put('Subscription_Fee_Currency__c', info.Enett_Default_Currency__c);
                               obj.put('Subscription_Fee_Symbol__c', info.Enett_Default_Currency_Symbol__c);   
                           } 
                       }
                   }
               }
        }   
    }    
}