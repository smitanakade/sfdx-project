global without sharing class eNettRegoController {


    public PageReference redirect() {
        String userAgent = getUserAgent();

        if(userAgent.contains('Chrome/57')) {
            PageReference pr = Page.oldBrowserFriendlyPage;
            pr.setRedirect(true);
            return pr;
        }
        Return null;
    }

    public String getUserAgent() {
        Return ApexPages.currentPage().getHeaders().get('USER-AGENT');
    }
    //global static string CurrentID;

    public String getCurrentId() {
             return JSON.serialize(ApexPages.currentPage().getParameters().get('id'));

    }
    // Get Token for URL
    public String getCurrentToken() {
         return JSON.serialize(ApexPages.currentPage().getParameters().get('Token'));
    }

    

    public String getReferrer() {
         return JSON.serialize(ApexPages.currentPage().getParameters().get('Referrer'));
    }
    public String getSelectedStep() {
         return JSON.serialize(ApexPages.currentPage().getParameters().get('Step'));
    }
    public static Map<String, String> getErrorType() {

        Map<String, String> result = new Map<String, String>();
        String errorType = ApexPages.currentPage().getParameters().get('errorType');
        if(errorType=='invalidToken'){
            result.put('title', 'Account set-up');
            result.put('heading', 'Sorry, this page cannot be found.');
            result.put('messages', 'The address may have been typed incorrectly or the link may be out of date');
           return result;
        }
        else if(errorType=='WithECN'){
            result.put('title', 'Account set-up');
            result.put('heading', 'Snap! Our database is telling us your company already has a (VANs/EFT) account with us.');
            result.put('messages', 'If this doesn’t seem right or you\'d like more information, please get in touch below.');
           return result;
        }
        else if(errorType=='WithOutECN'){
            result.put('title', 'Account set-up');
            result.put('heading', 'Snap! Our database is telling us your company has a (VANs/EFT) account setup currently in progress with us.');
            result.put('messages', 'If this doesn\'t seem right or you’d like more information, please get in touch below.');
           return result;
        }
        else if(errorType=='CompletedRegistration'){
            result.put('title', 'Account set-up');
            result.put('heading', 'Your Form has been successfully submitted.');
            result.put('messages', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris commodo sagittis nulla a finibus.');
           return result;
        }

        else
        {
           result.put('title', 'Account set-up');
            result.put('heading', 'Oh No, looks like an error has occurred');
            result.put('messages', 'We apologise if this has caused you any inconvenience.');
           return result;
        }

        return result;

    }
    public String getRegId() {
        return ApexPages.currentPage().getParameters().get('id');
    }

    /*
    * Get Token (Name) by Record ID (RegistrationID)
    ****************************************************************/
    @RemoteAction
    global static string getToken(String RegistrationID)
    {
        List<Registration__c> registrations = [select Name from Registration__c where id =  :RegistrationID  LIMIT 1];
        return registrations[0].Name;
    }


    /****************************************************************
    * >>>>>> POC Code Start
    * >>>>>> POC Code Start
    * >>>>>> POC Code Starta2AO0000000vaeT
    ****************************************************************/



    global static String getClientAgreementHTML() {
        String regID = ApexPages.currentPage().getParameters().get('id');
        ClientAgreementController cAC = new ClientAgreementController(regId);
        string pageHTML = cAC.getMergedHTML();
        return pageHTML;
    }

    /****************************************************************
    * >>>>>> POC Code End
    * >>>>>> POC Code End
    * >>>>>> POC Code End
    ****************************************************************/


  /***************************************************************
    * Get Client Agreement HTML
    ****************************************************************/
    @RemoteAction
    global static String getClientAgreementHTML2(String registrationID) {
        ClientAgreementController cAC = new ClientAgreementController(registrationID);
        string pageHTML = cAC.getMergedHTML();
        return pageHTML;
    }

    /***************************************************************
    * Get Client T and C
    ****************************************************************/
    @RemoteAction
    global static String getTermsAndConditionsHTML2(String registrationID) {
        ClientAgreementController cAC = new ClientAgreementController(registrationID);
        string pageHTML = cAC.getTermsAndConditionsHTML();
        return pageHTML;
    }
   
   /***************************************************************
    * Get Register Attachment  
    * @registrationID
    * @namePrefix of the document. 
    ****************************************************************/    
    @RemoteAction
    global static List<Registration__c>  getAttachments(String registrationID,String namePrefix)
    {
       return [SELECT Id, (SELECT Id, Name,ContentType FROM Attachments where Name LIKE :namePrefix) from Registration__c where id=:registrationID ];    
    }

     /***************************************************************
     * Delete Register Attachment
     * @attachmentID
     * @namePrefix of the document.
     * @ParentID Id of registration object.
     ****************************************************************/
    @RemoteAction
    global static List<Attachment>  deleteAttachment(String attachmentID,String namePrefix , String ParentId)
    {

        List<Attachment> attachment = [select id from attachment where id = :attachmentID and Name LIKE :namePrefix AND ParentId =:ParentId];
        List<Attachment> att = [select id from attachment where id = :attachmentID and Name LIKE :namePrefix AND ParentId =:ParentId];

        if(att.size() > 0){

            delete att;

        }
        return attachment;
    }
    /***************************************************************
    * Get Bank Accounts 
    ****************************************************************/    
    @RemoteAction
    global static List<Registration_Bank_Account__c>  getBankAccounts(String registrationID, String accountType)
    {
       return [select Id, Is_IBAN__c,IBAN__c,Account_Number__c,SWIFT_BIC__c,Bank_Code__c,Account_Name__c,Account_Currency__c,Account_Country__c,Financial_Institution__c,Address_Line_1__c,Address_Line_2__c,City__c,State_Province_LKP__c,Postcode__c from Registration_Bank_Account__c where Active_Registration__c = :registrationID AND Account_Type__c = :accountType order by Id];
    }

    /****************************************************************
    *
    *          Registration Methods
    *
    ****************************************************************/



    /*****************************************************************
    * Get Registration detail
    ****************************************************************/
    @RemoteAction
    global static Registration__c getRegistrationData(String registrationID) {

            return [SELECT
                Id,Name, 
                Online_Registration_Stage__c, 
                Online_Registration_Sub_Stage__c,
                Online_Registration_Max_Sub_Stage__c,
                Registration_Type__c, Registration_Status__c, Agreement_Type__c, Account_Type__c, Salutation__c,
                First_Name__c, Last_Name__c, Email__c, No_business_email_reason__c, Phone__c, Country__c, Registered_Company_Name__c,
                Job_Title__c, Business_Type__c, Sector__c, Reg_Contains_VANs__c, Reg_Contains_EFT__c, Product__c, Trading_Name__c,
                Address_Line_1__c, Address_Line_2__c, City__c, State__c, Postcode__c, 
                Business_Tax_Number__c,
                Business_Number__c,
                Established_Year__c,
                Estimated_Annual_Transaction_Value__c, 
                Estimated_Transaction_CurrencyISOCode__c, 
                Purpose_of_VAN_Account__c,
                RegBusiness_Country__c, 
                RegBusiness_Address_Line_1__c, 
                RegBusiness_Address_Line_2__c, 
                RegBusiness_City__c, RegState__c, 
                RegBusiness_Postcode__c,
                BState_Name__c, State_Province__c, 
                RegBusiness_State_Province__c,
                Account_ECN__c,
                Accept_Terms_and_Conditions__c,
                EFT_Subscription_Fee__c, 
                VANs_Subscription_Fee__c,
                eNett_Account_Fee__c,
                Subscription_Fee_Currency__c,
                Subscription_Fee_Symbol__c
            FROM Registration__c
            WHERE id = :registrationID
            LIMIT 1];

  }
    /*
    * Upsert the Registration
    ****************************************************************/
    @RemoteAction
    global static string saveRegistration(String regoJson)
    {
        System.debug('Registration__c:'+Registration__c.class);
        Registration__c r = (Registration__c)JSON.deserialize(regoJson,Registration__c.class);
        upsert r;
        //        CurrentID = r.Id;
        return r.Id;
    }


    /*****************************************************************
    * Upsert the Registration
    ****************************************************************/    
    @RemoteAction
    global static string saveRegistrationFields(String regoJson)
    {
        System.debug('Registration__c:'+Registration__c.class);
        Registration__c r = (Registration__c)JSON.deserialize(regoJson,Registration__c.class);

        upsert r;
        return r.Id;
    }

    /****************************************************************
    *
    *          Delete Methods.
    *
    ****************************************************************/


    /*
    * Delete Beneficial Owner
    ****************************************************************/
    @RemoteAction
    global static void deleteBeneficialOwner(string id){
        Beneficial_Owner__c acc = [select id from Beneficial_Owner__c where id =: id];
        delete acc;
    }


    /*
    * Delete Director
    ****************************************************************/
    @RemoteAction
    global static void deleteDirector(string id){
        Director__c acc = [select id from Director__c where id =: id];
        delete acc;
    }


    /*
    * Delete Funding Account
    ****************************************************************/
    @RemoteAction
    global static void deleteFundingAccount(string id){
        Registration_Bank_Account__c acc = [select id from Registration_Bank_Account__c where id =: id];
        delete acc;
    }




    /****************************************************************
    *
    *          Account Methods.
    *
    ****************************************************************/

    /*
    * Funding
    ****************************************************************/
    @RemoteAction
    global static string theDefaultCurrency(string theCountry){

        //Registration_Bank_Account__c acc = [select Enett_Default_Currency__c from CountryMappings__c where id = :regoId LIMIT 1].Id;
        String dflt = [select Enett_Default_Currency__c from CountryMappings__c where Name = :theCountry LIMIT 1].Enett_Default_Currency__c;
        return dflt;
    }


    /*
    * New Beneficial Owner
    ****************************************************************/
    global static String getNewBO() {
        Beneficial_Owner__c nBO = new Beneficial_Owner__c();
        return JSON.serialize(nBO);
    }


    /*
    * Save Beneficial Owner
    ****************************************************************/
    @RemoteAction
    global static string saveBenOwner(String BO_Json)
    {
        Beneficial_Owner__c bo = (Beneficial_Owner__c)JSON.deserialize(BO_Json,Beneficial_Owner__c.class);
        upsert bo;
        return bo.Id;
    }


    /*
    * Payable / Receivable / Billing
    ****************************************************************/
    @RemoteAction
    global static string savePRBAccount(String p_r_b_Json)
    {
        Registration_Bank_Account__c prb = (Registration_Bank_Account__c)JSON.deserialize(p_r_b_Json,Registration_Bank_Account__c.class);
        upsert prb;
        return prb.Id;
    }

    /*
    * Beneficial Owner - Business
    ****************************************************************/
    global static String getBOBusinessRecType() {

        string orgId = UserInfo.getOrganizationId();
        string recType = [select Business__c from recTypesBenOwner__c where SetupOwnerId =  :orgId LIMIT 1].Business__c;
        return recType;
    }


    /*
    * Beneficial Owner - Individual
    ****************************************************************/
    global static String getBOIndividualRecType() {

        string orgId = UserInfo.getOrganizationId();
        string recType = [select Individual__c from recTypesBenOwner__c where SetupOwnerId =  :orgId LIMIT 1].Individual__c;
        return recType;
    }


    /*
    * Beneficial Owner - Trust
    ****************************************************************/
    global static String getBOTrustRecType() {

        string orgId = UserInfo.getOrganizationId();
        string recType = [select Trust__c from recTypesBenOwner__c where SetupOwnerId =  :orgId LIMIT 1].Trust__c;
        return recType;
    }



    /*
    * Check for an existing Lead
    ****************************************************************/
    @RemoteAction
    global static Boolean checkForLead(String emailAddr, String companyName) {

        List<Lead> leads = [select Id from Lead where (Email = :emailAddr OR Company = :companyName) AND isConverted = false LIMIT 1];
        if(leads.isEmpty()){
            return false;
        } else {
            return true;
        }

    }

    /*
    * Check for an existing Duplicate
    ****************************************************************/
    @RemoteAction
    global static Map<String, String> checkForDuplicates(String companyName, String emailAddr) {


        List<Account> accountsWithECN   = [select Legal_Name__c,Id   from Account where Legal_Name__c = :companyName AND ECN__c != null LIMIT 1];
        List<Account> accountsNoECN     = [select Legal_Name__c,Id   from Account where Legal_Name__c = :companyName AND ECN__c = null LIMIT 1];
        List<Contact> contactsWithAccountECN = [select Id from Contact where Email = :emailAddr AND Account.ECN__c != null LIMIT 1];
        List<Contact> contactsWithAccountNoECN = [select Id from Contact where Email = :emailAddr AND Account.ECN__c = '' LIMIT 1];
        List<Registration__c> registrations = [select Id from Registration__c where Email__c =  :emailAddr OR Registered_Company_Name__c = :companyName LIMIT 1];
        List<Lead> leads = [select Id from Lead where (Email =  :emailAddr OR Company = :companyName) AND isConverted = false LIMIT 1];
        Map<String, String> result = new Map<String, String>();

        if(!accountsWithECN.isEmpty()){
             result.put('errorType', 'DuplicateAccountWithECN');
            result.put('Id', '');
            return result;

        } else if(!accountsNoECN.isEmpty()){
            result.put('errorType', 'DuplicateAccountnoECN');
            result.put('Id', '');
            return result;

        }else if(!contactsWithAccountECN.isEmpty()){
            result.put('errorType', 'DuplicateAccountWithECN');
            result.put('Id', '');
            return result;
            
        }else if(!contactsWithAccountNoECN.isEmpty()){
            result.put('errorType', 'DuplicateAccountnoECN');
            result.put('Id', '');
            return result;
            
        } else if(!registrations.isEmpty()){
            result.put('errorType', 'DuplicateRegistration');
            result.put('Id', registrations[0].Id);
            return result;
        } else if(!leads.isEmpty()){
            result.put('errorType', 'DuplicateLead');
            result.put('Id', leads[0].Id);
            return result;
        } else {
            result.put('errorType', 'NoDuplicates');
            result.put('Id', '');
            return result;
        }
    }


    /*
    * Get Subscription Fee Detail
    ****************************************************************/

    @RemoteAction
    global static CountryMappings__c getFees(String country) {
        return [select EFT_Subscription_Fee__c, VANs_Subscription_Fee__c, Enett_Default_Currency__c, Enett_Default_Currency_Symbol__c, 
                eNett_Account_Fee__c, EFT_Default_Payment__c, EFT_Transaction_Fee__c,Chargeback_Fee_With_Document__c, Chargeback_Fee_Without_Document__c
                from CountryMappings__c where Name = :country LIMIT 1];
    }


    /****************************************************************
    *
    *          Tooltip Methods.
    *
    ****************************************************************/

    /* getTTHeadersData */
    private List<Rego_Field_Detail__c> getTTHeadersData()
    {
        return [select Name, Tool_Tip_Header__c from Rego_Field_Detail__c];
    }

    /* getTTHeadersMap */
    private  Map<String, String>  getTTHeadersMap (List<Rego_Field_Detail__c> TTHeaders)
    {
        Map <String, String> result = new Map <String, String>();
        for (Rego_Field_Detail__c TTHeader: TTHeaders)
        {
            result.put (TTHeader.Name, TTHeader.Tool_Tip_Header__c);
        }
        return result;
    }

    /* getTTHeaders */
    global String getTTHeaders()
    {
        List<Rego_Field_Detail__c> TTHeaders = getTTHeadersData();
        Map<String, String> result = getTTHeadersMap(TTHeaders);
        return JSON.serialize(result);
    }


    /*
    * Methods to get the Tooltip Content Detail
    * Reurns detail in the format of a JS Object
    ****************************************************************/

    /* getTTContentsData */
    private List<Rego_Field_Detail__c> getTTContentsData()
    {
        return [select Name, Tool_Tip_Content__c from Rego_Field_Detail__c];
    }

    /* getTTContentsMap */
    private  Map<String, String>  getTTContentsMap (List<Rego_Field_Detail__c> TTContents)
    {
        Map <String, String> result = new Map <String, String>();
        for (Rego_Field_Detail__c TTContent: TTContents)
        {
            result.put (TTContent.Name, TTContent.Tool_Tip_Content__c);
        }
        return result;
    }

    /* getTTContents */
    global String getTTContents()
    {
        List<Rego_Field_Detail__c> TTContents = getTTContentsData();
        Map<String, String> result = getTTContentsMap(TTContents);
        return JSON.serialize(result);
    }


    /****************************************************************
    *
    *          Picklist Related Methods.
    *
    ****************************************************************/

    /*
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


    /*
    * Get Registration Salutations Picklist values
    ****************************************************************/
    global static String getSalutations() {
        return getPLVs('Registration__c', 'Salutation__c');
    }


    /*
    * Get Registration Countries Picklist values
    ****************************************************************/
    global static String getCountries() {
        List<String> approvedCountries = new List<String>();
        for(CountryMappings__c cm : [select Name from CountryMappings__c where  IsApprovedCountry__c = true Order by Name]){
            approvedCountries.add(cm.Name);
        }
        return JSON.serialize(approvedCountries);
    }


    /*
    * Get Registration GDS Picklist values
    ****************************************************************/
    global static String getGDSVals() {
        return getPLVs('Registration__c', 'GDS_Details__c');
    }


    /*
    * Get Registration Sectors Picklist values
    ****************************************************************/
    global static String getSectors() {
        return getPLVs('Registration__c', 'Sector__c');
    }


    /*
    * Get Registration Business Types Picklist values
    ****************************************************************/
    global static String getBusinessTypes() {
        return getPLVs('Registration__c', 'Business_Type__c');
    }


    /*
    * Get Registration Agency Group Picklist values
    ****************************************************************/
    global static String getAgencyGroups() {
        return getPLVs('Registration__c', 'Agency_Group__c');
    }



    /* Get Registration Business Regions Picklist values
    ***************************************************************/
    //    global static String getBusRegions() {
    //        return getPLVs('Registration__c', 'BState_Name__c');
    //    }


    /*
    * Get Registration Estimated Currencies Picklist values
    ****************************************************************/
    global static String getEstCurrencies() {
        return getPLVs('Registration__c', 'Estimated_Transaction_CurrencyISOCode__c');
    }


    /*
    * Get  Beneficial Owner Owner Types Picklist values
    ****************************************************************/
    global static String getOwnerTypes() {
        return getPLVs('Beneficial_Owner__c', 'Owner_Type__c');
    }


    /*
    * Get Beneficial Owner Salutations Picklist values
    ****************************************************************/
    global static String getBOSalutations() {
        return getPLVs('Beneficial_Owner__c', 'Salutation__c');
    }

    /*
    * Get Director Salutations Picklist values
    ****************************************************************/
    global static String getDirSalutations() {
        return getPLVs('Director__c', 'Salutation__c');
    }


    /*
    * Get applicable Funding Account Currencies
    ****************************************************************/
    global static String getFundingCurrencies() {
        List<String> fundingCountries = new List<String>();
        for(CurrencyType ct : [select IsoCode FROM CurrencyType WHERE IsActive = true order by IsoCode]){
            fundingCountries.add(ct.IsoCode);
        }
        return JSON.serialize(fundingCountries);
    }


    /*
    * Get Funding Record Type
    ****************************************************************/
    global static String getFundingRecType() {

        string orgId = UserInfo.getOrganizationId();
        string recType = [select Funding__c from recTypesRBA__c where SetupOwnerId =  :orgId LIMIT 1].Funding__c;
        return recType;
    }


    /*
    * Get NON Funding Record Type
    ****************************************************************/
    global static String getNonFundingRecType() {

        string orgId = UserInfo.getOrganizationId();
        string recType = [select Other__c from recTypesRBA__c where SetupOwnerId =  :orgId LIMIT 1].Other__c;
        return recType;
    }


    /*
    * Get Regions for Provided Country
    ****************************************************************/
    @RemoteAction
    global static Map<String, String> getRegions(String theCountry) {


        //List<String> theRegions = new List<String>();
        //for(State_Detail__c reg : [select Id, Name from State_Detail__c where Country_Name__c = :theCountry order by Name]){
        //    theRegions.add(reg.Id);
        //}
        //return theRegions;
        Map<String, String> theRegions = new Map<String, String>();

        if(theCountry=='undefined')
        {

        }
        else
        {
            for(State_Detail__c reg : [select Id, Name from State_Detail__c where Country_Name__c = :theCountry AND Approved_State__c = true order by Name]){
                theRegions.put(reg.Name, reg.Id);
            }

        }
        
       
        return theRegions;

    }



    /***************************************************************
    * Code for the Summary Page
    ****************************************************************/

    public list <Registration__c> thisRegistration {get;set;}
    public Id registrationID = ApexPages.currentPage().getParameters().get('Id');


    public eNettRegoController (){

        thisRegistration = [
            SELECT
                Online_Registration_Stage__c,
                Online_Registration_Sub_Stage__c,
                Online_Registration_Max_Sub_Stage__c,
                Registration_Type__c,
                Registration_Status__c,
                Agreement_Type__c,
                Account_Type__c,
                Salutation__c,
                First_Name__c,
                Last_Name__c,
                Email__c,
                No_business_email_reason__c,
                Phone__c,
                Country__c,
                Registered_Company_Name__c,
                Job_Role__c,
                Business_Type__c,
                Sector__c,
                Reg_Contains_VANs__c,
                Reg_Contains_EFT__c,
                Product__c,
                Trading_Name__c,
                Address_Line_1__c,
                Address_Line_2__c,
                City__c,
                State__c,
                Postcode__c,
                Referrer_ECN__c,
                Business_Tax_Number__c,
                Business_Number__c,
                Established_Year__c,
                Estimated_Annual_Transaction_Value__c,
                Estimated_Transaction_CurrencyISOCode__c,
                Purpose_of_VAN_Account__c,
                RegBusiness_Country__c,
                RegBusiness_Address_Line_1__c,
                RegBusiness_Address_Line_2__c,
                RegBusiness_City__c,
                RegState__c,
                RegBusiness_Postcode__c,
                BState_Name__c,
                State_Province__c,
                RegBusiness_State_Province__c,
                //CEO_CFO_Job_Role__c,
                //CEO_CFO__c,
                //CEO_CFO_First_Name__c,
                //CEO_CFO_Middle_Name__c,
                //CEO_CFO_Last_Name__c,
                //CEO_CFO_Date_of_Birth__c,
                //Listed_Exchange__c,
                //Agency_Group__c,
                //Industry_Type__c,
                //IATA_ARC_TIDS_Number__c,
                //Business_presence_in_high_risk_country__c,
                Accept_Terms_and_Conditions__c,
                Account_ECN__c,
                Marketing_Subscription__c,
                EFT_Subscription_Fee__c,
                VANs_Subscription_Fee__c,
            	eNett_Account_Fee__c,
                Subscription_Fee_Currency__c,
                Subscription_Fee_Symbol__c
            FROM Registration__c
            WHERE id = 'a1ZO0000008z3qw'
            LIMIT 1];

    }
    

    /*********** Need to delete This following Function *************/
    /* !!!========Not In use ========!!  
        New Function : getTermsAndConditionsHTML2
        TODO: Neet to Delete this Function 
    **/
    global static String getTheAgreementForm()
    {
        String html = '';
        String conId = ApexPages.currentPage().getParameters().get('id');
        return  html;
    }

    /* !!!========Not In use ========!!  
        New Function : getTermsAndConditionsHTML2
        TODO: Neet to Delete this Function 
    **/
    global static String getTheText()
    {
        String regID = ApexPages.currentPage().getParameters().get('id');
        ClientAgreementController cAC = new ClientAgreementController(regId);
        string pageHTML = cAC.getTermsAndConditionsHTML();
        return pageHTML;
        //return [select Id, Content__c from Document_Template__c where Id = 'a2AO0000000w29o'].Content__c;
        //return [select Id, Content__c from Document_Template__c where Id = 'a2AO0000000vcMe'].Content__c;
    }
    /* !!!========Not In use ========!!
        New Function : getClientAgreementHTML2
        TODO: Neet to Delete this Function 
     **/


    /*
    * Get the registration detail or return a new registration object.
    * ------- Not IN use have some SF Data cash Issue-------
    ****************************************************************/
    global String getRegistration() {


        String qParam = ApexPages.currentPage().getParameters().get('id');

        if (String.isBlank(qParam)) {
            Registration__c YYZ = new Registration__c();
            return JSON.serialize(YYZ);
        } else {
            return JSON.serialize([
                select
                Name,
                Online_Registration_Stage__c,
                Online_Registration_Sub_Stage__c,
                Online_Registration_Max_Sub_Stage__c,
                Registration_Type__c,
                Registration_Status__c,
                Agreement_Type__c,
                Account_Type__c,
                Salutation__c,
                First_Name__c,
                Last_Name__c,
                Email__c,
                No_business_email_reason__c,
                Phone__c,
                Country__c,
                Registered_Company_Name__c,
                Job_Role__c,
                Business_Type__c,
                Sector__c,
                Reg_Contains_VANs__c,
                Reg_Contains_EFT__c,
                Product__c,
                Referrer_ECN__c,
                Trading_Name__c,
                Address_Line_1__c,
                Address_Line_2__c,
                City__c,
                State__c,
                Postcode__c,
                Business_Tax_Number__c,
                Business_Number__c,
                Established_Year__c,
                Estimated_Annual_Transaction_Value__c,
                Estimated_Transaction_CurrencyISOCode__c,
                Purpose_of_VAN_Account__c,
                RegBusiness_Country__c,
                RegBusiness_Address_Line_1__c,
                RegBusiness_Address_Line_2__c,
                RegBusiness_City__c,
                RegState__c,
                RegBusiness_Postcode__c,
                BState_Name__c,
                State_Province__c,
                RegBusiness_State_Province__c,
                CEO_CFO_Job_Role__c,
                CEO_CFO__c,
                CEO_CFO_First_Name__c,
                CEO_CFO_Middle_Name__c,
                CEO_CFO_Last_Name__c,
                CEO_CFO_Date_of_Birth__c,
                Listed_Exchange__c,
                Agency_Group__c,
                Industry_Type__c,
                IATA_ARC_TIDS_Number__c,
                Business_presence_in_high_risk_country__c,
                Accept_Terms_and_Conditions__c,
                Account_ECN__c,
                Marketing_Subscription__c,
                EFT_Subscription_Fee__c,
                VANs_Subscription_Fee__c,
                eNett_Account_Fee__c,
                Subscription_Fee_Currency__c,
                Subscription_Fee_Symbol__c,
                GDS_Details__c,
                PCC_or_SID__c,
                Email_TCs_from_Online_Form__c,
               // Save_and_Continue__c,
                Resume_Application__c
                from Registration__c where id = :qParam] [0] ) ;
        }
    }

    




}