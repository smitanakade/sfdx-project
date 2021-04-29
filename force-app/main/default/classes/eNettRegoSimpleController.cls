public with sharing class eNettRegoSimpleController {

    private final Id regId;
    transient public final String regSalutation {get; set; }
    public Id registrationID = ApexPages.currentPage().getParameters().get('Id');

    public list <Registration__c> thisRegistration {get;set;}
    public list <Beneficial_Owner__c> beneficialOwners {get;set;}
    public list <Director__c> directors {get;set;}
    public list <Registration_Bank_Account__c> bankAccounts {get;set;}
    public list <Attachment> attachments {get;set;}


    
    public eNettRegoSimpleController () {

        thisRegistration = [
            SELECT                
                Online_Registration_Stage__c, Online_Registration_Sub_Stage__c, Online_Registration_Max_Sub_Stage__c,
                Registration_Type__c, Registration_Status__c, Agreement_Type__c, Account_Type__c, Salutation__c, 
                First_Name__c, Last_Name__c, Email__c, No_business_email_reason__c, Phone__c, Country__c, Registered_Company_Name__c,
                Job_Role__c, Business_Type__c, Sector__c, Reg_Contains_VANs__c, Reg_Contains_EFT__c, Product__c, Trading_Name__c,
                Address_Line_1__c, Address_Line_2__c, City__c, State__c, Postcode__c, Business_Tax_Number__c, Business_Number__c,
                Established_Year__c, Estimated_Annual_Transaction_Value__c, Estimated_Transaction_CurrencyISOCode__c, Purpose_of_VAN_Account__c,
                RegBusiness_Country__c, RegBusiness_Address_Line_1__c, RegBusiness_Address_Line_2__c, RegBusiness_City__c, RegState__c, RegBusiness_Postcode__c,
                BState_Name__c, State_Province__c, RegBusiness_State_Province__c,
                CEO_CFO_Job_Role__c, CEO_CFO__c, CEO_CFO_First_Name__c, CEO_CFO_Middle_Name__c, CEO_CFO_Last_Name__c, CEO_CFO_Date_of_Birth__c,
                Listed_Exchange__c, Agency_Group__c, Industry_Type__c, IATA_ARC_TIDS_Number__c, Business_presence_in_high_risk_country__c,
                Accept_Terms_and_Conditions__c,Marketing_Subscription__c, EFT_Subscription_Fee__c, VANs_Subscription_Fee__c, Subscription_Fee_Currency__c, Subscription_Fee_Symbol__c
            FROM Registration__c
            WHERE id = :registrationID 
            LIMIT 1];

                
            beneficialOwners = [
                SELECT Id, Active_Registration__c, Registration__c, Owner_Type__c, Salutation__c, First_Name__c, Middle_Name__c, Last_Name__c,
                    Registered_Business_Name__c, Business_Number__c, Percentage_Shareholder__c, 
                    Country__c, Address_Line_1__c, Address_Line_2__c, City__c, Postcode__c, State_Province_Text__c
                FROM Beneficial_Owner__c
                WHERE Registration__c = :registrationID
                ORDER by createdDate DESC
            ];

                
            directors = [
                SELECT Id, Active_Registration__c, Registration__c, Salutation__c, First_Name__c, Middle_Name__c, Last_Name__c 
                FROM Director__c 
                WHERE Registration__c = :registrationID
                ORDER by createdDate DESC
            ];


            bankAccounts = [
                SELECT Id, Active_Registration__c, Registration__c, Is_IBAN__c, Account_Type__c, SWIFT_BIC__c, IBAN__c,
                    Account_Currency__c, Account_Name__c, Account_Country__c, Bank_Code__c, Account_Number__c, Financial_Institution__c,
                    Address_Line_1__c, Address_Line_2__c, City__c, State_Province__c, State_Province_Text__c, Postcode__c, RecordTypeId
                FROM Registration_Bank_Account__c
                WHERE Registration__c = :registrationID
                ORDER by createdDate DESC
            ];

                    
            attachments = [
                SELECT
                    ContentType,
                    Name,
                    Id
                FROM attachment
                WHERE parentId = :registrationID
            ];

    }

    
    public PageReference save() {
        Registration__c myReg = [select Salutation__c from Registration__c where id = :regId];
        myReg.Salutation__c = regSalutation;
        update myReg;
        return null;
    }

}