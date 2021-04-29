global without sharing class eNettRegistrationFallbackController {


    String Countries; // Not suer what this for

    /*******************************************************************************************
    *
    *   Get QueryString Data from URL
    *
    /*******************************************************************************************/

    /*****************************************************************
    * Get Registration SF ID form QueryStirng
    ****************************************************************/ 
    public String getCurrentId() {
        return JSON.serialize(ApexPages.currentPage().getParameters().get('id'));
    }

    /*****************************************************************
    * Get Registration SF Name as Token form QueryStirng
    ****************************************************************/ 

    public String getCurrentToken() {
        return JSON.serialize(ApexPages.currentPage().getParameters().get('Token')); 
    }

    /*****************************************************************
    * Get Referrer form QueryStirng
    ****************************************************************/ 
     public String getReferrer() {
        return JSON.serialize(ApexPages.currentPage().getParameters().get('Referrer')); 
    }

    /*****************************************************************
    * Get getSelected Step form QueryStirng
    ****************************************************************/  
     public String getSelectedStep() {
         return JSON.serialize(ApexPages.currentPage().getParameters().get('Step')); 
    }
    
    /*******************************************************************************************
    *
    *   Get Data from SalesForce
    *
    /*******************************************************************************************/

    public static Registration__c registration { get; set; }


    /*****************************************************************
    * Get Registration detail
    ****************************************************************/    
    @RemoteAction
    global static Registration__c getRegistration(String registrationID) {

       // Id regID = ApexPages.currentPage().getParameters().get('Id');

        registration = 
            [SELECT                
                Id,Name,Lead__c, Online_Registration_Stage__c, Online_Registration_Sub_Stage__c, Online_Registration_Max_Sub_Stage__c,
                Registration_Type__c, Registration_Status__c, Agreement_Type__c, Account_Type__c, Salutation__c, 
                First_Name__c, Last_Name__c, Email__c, No_business_email_reason__c, Phone__c, Country__c, Registered_Company_Name__c,
                Job_Role__c, Job_Title__c, Business_Type__c, Sector__c, Reg_Contains_VANs__c, Reg_Contains_EFT__c, Product__c, Trading_Name__c,
                Address_Line_1__c, Address_Line_2__c, City__c, State__c, Postcode__c, Business_Tax_Number__c, Business_Number__c,
                Established_Year__c, Estimated_Annual_Transaction_Value__c, Estimated_Transaction_CurrencyISOCode__c, Purpose_of_VAN_Account__c,
                RegBusiness_Country__c, RegBusiness_Address_Line_1__c, RegBusiness_Address_Line_2__c, RegBusiness_City__c, RegState__c, RegBusiness_Postcode__c,
                BState_Name__c, State_Province__c, RegBusiness_State_Province__c,Account_ECN__c,
                CEO_CFO_Job_Role__c, CEO_CFO__c, CEO_CFO_First_Name__c, CEO_CFO_Middle_Name__c, CEO_CFO_Last_Name__c, CEO_CFO_Date_of_Birth__c,
                Listed_Exchange__c, Agency_Group__c, Industry_Type__c, IATA_ARC_TIDS_Number__c, Business_presence_in_high_risk_country__c,
                Accept_Terms_and_Conditions__c, EFT_Subscription_Fee__c, VANs_Subscription_Fee__c, Subscription_Fee_Currency__c, Subscription_Fee_Symbol__c
            FROM Registration__c
            WHERE id = :registrationID 
            LIMIT 1];
        return registration;
    }
    
    /***************************************************************
    * Get Bank Accounts 
    ****************************************************************/    
    @RemoteAction
    global static List<Registration_Bank_Account__c>  getBankAccounts(String registrationID, String accountType)
    {
       return [select Id, Is_IBAN__c,IBAN__c,Account_Number__c,SWIFT_BIC__c,Bank_Code__c,Account_Name__c,Account_Currency__c,Account_Country__c,Financial_Institution__c,Address_Line_1__c,Address_Line_2__c,City__c,State_Province_LKP__c,Postcode__c from Registration_Bank_Account__c where Active_Registration__c = :registrationID AND Account_Type__c = :accountType order by Id];
    }

    /***************************************************************
    * Get Terms amd Conditions HTML 
    ****************************************************************/   
    global static String getTandCHTML()
    {
        String regID = ApexPages.currentPage().getParameters().get('id');
        ClientAgreementController cAC = new ClientAgreementController(regId);
        string pageHTML = cAC.getTermsAndConditionsHTML();
        return pageHTML;    
    }

    /***************************************************************
    * Get Client Agreement HTML 
    ****************************************************************/   
     global static String getClientAgreementHTML() {
        String regID = ApexPages.currentPage().getParameters().get('id');
        ClientAgreementController cAC = new ClientAgreementController(regId);
        string pageHTML = cAC.getMergedHTML();
        return pageHTML;
    }   

    /****************************************************************
    * Get Funding Record Type
    ****************************************************************/    

    global static String getFundingRecType() {
        string orgId = UserInfo.getOrganizationId(); 
        string recType = [select Funding__c from recTypesRBA__c where SetupOwnerId =  :orgId LIMIT 1].Funding__c;
        return recType;
    }
    
    /****************************************************************
    * Get NON Funding Record Type
    ****************************************************************/ 

    global static String getNonFundingRecType() {
        string orgId = UserInfo.getOrganizationId(); 
        string recType = [select Other__c from recTypesRBA__c where SetupOwnerId =  :orgId LIMIT 1].Other__c;
        return recType;
    }

    /***************************************************************
    /* Get Subscription Fee Detail
    ****************************************************************/ 

    @RemoteAction
    global static CountryMappings__c getFees(String country) {
        return [select EFT_Subscription_Fee__c, VANs_Subscription_Fee__c, Enett_Default_Currency__c, Enett_Default_Currency_Symbol__c from CountryMappings__c where Name = :country LIMIT 1];
    }

    /****************************************************************
    * Get Regions for Provided Country
    ****************************************************************/    
    @RemoteAction
    global static Map<String, String> getRegions(String theCountry) {
        Map<String, String> theRegions = new Map<String, String>();
        for(State_Detail__c reg : [select Id, Name from State_Detail__c where Country_Name__c = :theCountry AND Approved_State__c = true order by Name]){
            theRegions.put(reg.Name, reg.Id);
        }
        return theRegions;
    }

    /*****************************************************************
    * Get Registration Salutations Picklist values
    ****************************************************************/ 

    global static String getSalutations() {
        return getPLVs('Registration__c', 'Salutation__c');
    }
    

    /*****************************************************************
    * Get Registration Sectors Picklist values
    ****************************************************************/    

    global static String getSectors() {
        return getPLVs('Registration__c', 'Sector__c');
    }
    

    /*****************************************************************
    * Get Registration Business Types Picklist values
    ****************************************************************/    

    global static String getBusinessTypes() {
        return getPLVs('Registration__c', 'Business_Type__c');
    }
    

    /*****************************************************************
    * Get Registration Countries Picklist values
    ****************************************************************/  

    global static String getCountries() {
        List<String> approvedCountries = new List<String>();
        for(CountryMappings__c cm : [select Name from CountryMappings__c where  IsApprovedCountry__c = true Order by Name]){
            approvedCountries.add(cm.Name);
        }
        return JSON.serialize(approvedCountries);
    }

    /*****************************************************************
    * Get Currencies Picklist values
    ****************************************************************/  

    global static String getFundingCurrencies() {
        List<String> fundingCountries = new List<String>();
        for(CurrencyType ct : [select IsoCode FROM CurrencyType WHERE IsActive = true order by IsoCode]){
            fundingCountries.add(ct.IsoCode);
        }
        return JSON.serialize(fundingCountries);
    }


    /*******************************************************************************************
    *
    *   Upsert/Set  Registration and Bank_Account
    *
    /*******************************************************************************************/

    
    /*****************************************************************
    * Upsert the Registration
    ****************************************************************/    
    @RemoteAction
    global static string saveRegistration(String regoJson)
    {
        System.debug('Registration__c:'+Registration__c.class);
        Registration__c r = (Registration__c)JSON.deserialize(regoJson,Registration__c.class);

        upsert r;
        return r.Id;
    }

    /*****************************************************************
    /* Upsert the Bank Account
    ****************************************************************/ 
    @RemoteAction
    global static string saveFundingAccount(String regoJson)
    {
        System.debug('Registration_Bank_Account__c:'+Registration_Bank_Account__c.class);
        Registration_Bank_Account__c ba = (Registration_Bank_Account__c)JSON.deserialize(regoJson,Registration_Bank_Account__c.class);

        upsert ba;
        return ba.Id;
    }

    /*******************************************************************************************
    *
    *  Delete Data form SalesForce
    *
    /*******************************************************************************************/

    /*****************************************************************
    * Delete Funding Account
    ****************************************************************/    
    @RemoteAction
    global static void deleteFundingAccount(string id){
        Registration_Bank_Account__c acc = [select id from Registration_Bank_Account__c where id =: id];
        delete acc;
    }


    /*******************************************************************************************
    *
    *   Utility Module/Function
    *
    /*******************************************************************************************/

    /*****************************************************************
    * Check for an existing Duplicate
    ****************************************************************/    
    @RemoteAction
    global static Map<String, String> checkForDuplicates(String companyName, String emailAddr) {
        
        List<Account> accountsWithECN   = [select Legal_Name__c,Id   from Account where Legal_Name__c = :companyName AND ECN__c != null LIMIT 1];
        List<Account> accountsNoECN     = [select Legal_Name__c,Id   from Account where Legal_Name__c = :companyName AND ECN__c = null LIMIT 1];
        List<Contact> contacts = [select Id from Contact where Email =  :emailAddr LIMIT 1];
        List<Registration__c> registrations = [select Id,Lead__c from Registration__c where Email__c =  :emailAddr OR Registered_Company_Name__c = :companyName LIMIT 1];
        List<Lead> leads = [select Id,Reference_Registration__c from Lead where (Email = :emailAddr OR Company = :companyName) AND isConverted = false LIMIT 1];
        Map<String, String> result = new Map<String, String>();

        if(!accountsWithECN.isEmpty()){
            result.put('errorType', 'DuplicateAccountWithECN');
            result.put('Id', '');
            result.put('LeadId', '');
            return result;

        } else if(!accountsNoECN.isEmpty()){
            result.put('errorType', 'DuplicateAccountnoECN');
            result.put('Id', '');
            result.put('LeadId', '');
            return result;

        }else if(!contacts.isEmpty()){
            result.put('errorType', 'DuplicateAccountnoECN');
            result.put('Id', '');
            result.put('LeadId', '');
            return result;

        } else if(!registrations.isEmpty()){
            result.put('errorType', 'DuplicateRegistration');
            result.put('Id', registrations[0].Id);
            result.put('LeadId', registrations[0].Lead__c);
            return result;
        } else if(!leads.isEmpty()){
            result.put('errorType', 'DuplicateLead');
            result.put('Id', leads[0].Reference_Registration__c);
            result.put('LeadId', leads[0].Id);
            
            return result;
        } else {
            result.put('errorType', 'NoDuplicates');
            result.put('Id', '');
            result.put('LeadId', '');
            return result;
        }
    }

    /*****************************************************************
    * Generic get Picklist functionality. Called by all Picklist getters.
    ****************************************************************/    
    global static String getPLVs(String objectName, String fieldName) {
        
        Schema.SObjectType t = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult r = t.getDescribe();
        Schema.DescribeFieldResult fieldResult = r.fields.getMap().get(fieldName).getDescribe();
        
        List<Schema.PicklistEntry> plv = fieldResult.getPicklistValues();
        List<String> options = new List<String>();
        
        for( Schema.PicklistEntry x : plv) {
            options.add(x.getLabel());
        }
        return JSON.serialize(options);
    }
    



    /**************************************************************************
    *
    *   Only for Testing .
    *
    **************************************************************************/

    /*****************************************************************
    *  Generate Random Stirng
    ****************************************************************/    
    public String getRandomString() {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
        Integer len =15;
        String randStr = '';
        while (randStr.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }

    /*****************************************************************
    *  Generate Random Number
    ****************************************************************/    
    public String getRandomNumber() {
        final String chars = '0123456789';
        Integer len =8;
        String randStr = '';
        while (randStr.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
     /*****************************************************************
    *  Generate Random Email Address
    ****************************************************************/    
    public String getRandomEmail() {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        Integer len =6;
        String randStr = '';
        String email = '';
        while (randStr.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }
        email=randStr+'@'+randStr+'.com';
        return email; 
    }



}