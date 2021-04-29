@isTest (SeeAllData = true)
public class StaticUtilsTest {
    //Null object should return null or object without country as a field
    @isTest static void TestNull(){
        StaticUtils.PopulateCountryFields(null);
        //Case object doesn't have country as a field
        Case c = new Case();
        StaticUtils.PopulateCountryFields(c);
    }

    //Object with country as a field but no value or an invalid country name in it 
    @isTest static void TestWrongCountry(){
        Registration__c r = new Registration__c(Country__c = 'Utopia',Region__c = 'EMEA',EFT_Subscription_Fee__c=123);
        StaticUtils.PopulateCountryFields(r);
        System.AssertEquals('EMEA',r.Region__c,'Object country-related info got updated even though the country name is invalid');
    }
    
    //Happy Path 1
    @isTest static void TestHappyPathCountryFields(){
        //get custom settings
        Account acc = new Account(Country__c = 'Australia');
        CountryMappings__c info = CountryMappings__c.getInstance((string)acc.get('Country__c'));
        String iso2 = info.ISO2__c, iso3 = info.ISO3__c, currencyName = info.currency_name__c, currencyCode = info.currency_alphabetic_code__c,
            region = info.Region__c, subRegion = info.Sub_Region__c, subRegion2 = info.Sub_Region_2__c;
        //do the deed
        StaticUtils.PopulateCountryFields(acc);
		//check the fields are updated
		System.AssertEquals(iso2,acc.CountryCode2__c);
        System.AssertEquals(iso3,acc.CountryCode3__c);
        System.AssertEquals(currencyName,acc.CurrencyName__c);
        System.AssertEquals(currencyCode,acc.CurrencyCode__c);
        System.AssertEquals(region,acc.Region__c);
        System.AssertEquals(subRegion,acc.Sub_Region__c);
        System.AssertEquals(subRegion2,acc.Sub_Region_2__c);
    }
}