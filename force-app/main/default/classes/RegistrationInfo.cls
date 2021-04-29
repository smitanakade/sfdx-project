public class RegistrationInfo {
/*
    public list <registration__c> thisRegDetails {get;set;}
    public list <Beneficial_Owner__c> benOwn {get;set;}
    public list <Director__c> dir {get;set;}
    public list <Registration_Bank_Account__c> bank {get;set;}
    public list <Verification__c> ver {get;set;}
    public list <Verification__c> compName {get;set;}
    public list <Verification__c> busAdd {get;set;}
    public list <Verification__c> regNum {get;set;}
    public list <Verification__c> traNam {get;set;}
    public list <Verification__c> priSig {get;set;}
    
    public Id thisReg = ApexPages.currentPage().getParameters().get('Id');

    public RegistrationInfo(ApexPages.StandardController controller) {
    
    thisRegDetails=[SELECT id,name,zPepCountBeneficialOwner__c,zPepCountDirector__c FROM Registration__c WHERE id = :thisReg LIMIT 1];
    
    compName = new List <Verification__c> ();
    busAdd = new List <Verification__c> ();
    regNum = new List <Verification__c> ();
    traNam = new List <Verification__c> ();
    priSig = new List <Verification__c> ();
    
    benOwn=[SELECT id,name,Active__c FROM beneficial_owner__c WHERE Active__c = TRUE AND Registration__c = :thisReg 
        AND of_Verified_Records__c <= 1];
    dir=[SELECT id,name,Active__c FROM Director__c WHERE Active__c = TRUE AND Registration__c = :thisReg
        AND of_Verified_Records__c <= 1];      
    bank=[SELECT id, name,Active__c FROM Registration_Bank_Account__c WHERE Active__c = TRUE AND Registration__c = :thisReg
        AND of_Verified_Records__c <= 1];
    ver=[SELECT id,name,Evidence_Type__c,Attachment_Status__c FROM Verification__c WHERE Registration__c = :thisReg];
        FOR (Verification__c v : ver) {
            IF (v.Evidence_Type__c == 'Registered Company Name' & v.Attachment_Status__c != 'Document Attached') {compName.add(v);}
            IF (v.Evidence_Type__c == 'Business Address' & v.Attachment_Status__c != 'Document Attached') {busAdd.add(v);}
            IF (v.Evidence_Type__c == 'Registered Business Number' & v.Attachment_Status__c != 'Document Attached') {regNum.add(v);}
            IF (v.Evidence_Type__c == 'Trading Name' & v.Attachment_Status__c != 'Document Attached') {traNam.add(v);}
            IF (v.Evidence_Type__c == 'Principal Signatory' & v.Attachment_Status__c != 'Document Attached') {priSig.add(v);}
        }
    }
    */
}