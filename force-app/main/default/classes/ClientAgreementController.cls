global without sharing class ClientAgreementController {

    global string renderMode {get; set;}
    global string contentType {get; set;}
    
    global string Id {get; private set;}
    global string Salutation {get; private set;}
    global string First_Name {get; private set;}
    global string Last_Name {get; private set;}
    global string Email {get; private set;}
    global string Products {get; private set;}    
    global string Phone {get; private set;}
    global string Registered_Company_Name {get; private set;}
    global string Business_Number {get; private set;}
    global string Country {get; private set;}
    global string Subscription_Fee_Currency {get; private set;}
    global string EFT_Subscription_Fee {get; private set;}
    global string EFT_Transaction_Fee {get; private set;}
    global string EFT_Default_Payment {get; private set;}
    global string VANs_Subscription_Fee {get; private set;}
    global string eNett_Account_Fee {get; private set;}
    global string Chargeback_Fee_With_Document {get; private set;}
    global string Chargeback_Fee_Without_Document {get; private set;}
    global Id Standard_TCs_Template_VANs {get; private set;}
    global Id Standard_TCs_Template_EFT {get; private set;}

    global ClientAgreementController() {
        if (ApexPages.currentPage().getParameters().get('renderAs') != null) {
            String renderAs = ApexPages.currentPage().getParameters().get('renderAs');
            if (renderAs == 'pdf') {
                renderMode = 'pdf';
                contentType = null;
            } else if (renderAs == 'html') {
                renderMode = null;
                contentType = 'html';
            } else {
                renderMode = null;
                contentType = null;
            }
        } else {
            renderMode = null;
            contentType = null;
        }

        if (ApexPages.currentPage().getParameters().get('Id') != null)
            loadReg(ApexPages.currentPage().getParameters().get('Id'));
    }
    
    global ClientAgreementController(Id regId) {
        loadReg(regId);
    }
    
    public void loadReg (Id regId) {
        Registration__c reg;
        if (regId != null) {
            this.id = regId;
            LIST<Registration__c> regs = [SELECT Id, Salutation__c, First_Name__c, Last_Name__c, Email__c, Phone__c,
                                          Registered_Company_Name__c, Business_Number__c, Country__c, Product__c,
                                          Subscription_Fee_Currency__c, EFT_Subscription_Fee__c, EFT_Transaction_Fee__c,
                                          EFT_Default_Payment__c, VANs_Subscription_Fee__c, Chargeback_Fee_With_Document__c,
                                          eNett_Account_Fee__c, Chargeback_Fee_Without_Document__c, 
                                          Standard_TCs_Template_EFT__c, Standard_TCs_Template_VANs__c
                                          FROM Registration__c WHERE Id = :this.Id LIMIT 1];
            if (!regs.isEmpty())
                reg = regs[0];
        }
        
        if (reg != null) {
            this.Salutation = reg.Salutation__c;
            this.First_Name = reg.First_Name__c;
            this.Last_Name = reg.Last_Name__c;
            this.Email = reg.Email__c;
            this.Phone = reg.Phone__c;
            this.Registered_Company_Name = reg.Registered_Company_Name__c;
            this.Business_Number = reg.Business_Number__c;
            this.Country = reg.Country__c;
            this.Products = reg.Product__c;            
            this.Subscription_Fee_Currency = reg.Subscription_Fee_Currency__c;
            this.EFT_Subscription_Fee = (reg.EFT_Subscription_Fee__c == null) ? '' : string.valueof(reg.EFT_Subscription_Fee__c);
            this.EFT_Transaction_Fee = (reg.EFT_Transaction_Fee__c == null) ? '' : string.valueof(reg.EFT_Transaction_Fee__c);
            this.EFT_Default_Payment = (reg.EFT_Default_Payment__c == null) ? '' : string.valueof(reg.EFT_Default_Payment__c);
            this.VANs_Subscription_Fee = (reg.VANs_Subscription_Fee__c == null) ? '' : string.valueof(reg.VANs_Subscription_Fee__c);
            this.eNett_Account_Fee = (reg.eNett_Account_Fee__c == null) ? '' : string.valueof(reg.eNett_Account_Fee__c);
            this.Chargeback_Fee_With_Document = (reg.Chargeback_Fee_With_Document__c == null) ? '' : string.valueof(reg.Chargeback_Fee_With_Document__c);
            this.Chargeback_Fee_Without_Document = (reg.Chargeback_Fee_Without_Document__c == null) ? '' : string.valueof(reg.Chargeback_Fee_Without_Document__c);
            this.Standard_TCs_Template_VANs = reg.Standard_TCs_Template_VANs__c;
            this.Standard_TCs_Template_EFT = reg.Standard_TCs_Template_EFT__c;            
        }    
    }
    
    public static string removeCarriageReturns (String s) {
        s = s.replace('\r\n', '');
        s = s.replace('\n', '');
        s = s.replace('\r', '');
        return s;        
    }
  
    public string getMergedHTML() {
        if (this.Id == null) return '';
        PageReference pageRef = getPageReference(this.Id, this.Country, this.Products, 'html');
        string pageHTML = '';
        if (pageRef != null) pageHTML = ClientAgreementController.removeCarriageReturns(pageRef.getContent().toString());
        return pageHTML;
    }    

    public Blob getMergedPDF() {
        if (this.Id == null) return null;
        PageReference pageRef = getPageReference(this.Id, this.Country, this.Products, 'pdf');
        Blob pdfBlob = null;
        if (pageRef != null) pdfBlob = pageRef.getContent();
        return pdfBlob;
    }

    public static void savePDF(Id regId, Id targetId) {
        ClientAgreementController cAC = new ClientAgreementController(regId);
        
        Attachment att = new Attachment();
        att.parentId = targetId;
        att.name = 'Client Agreement.pdf';
        att.body = cAC.getMergedPDF();
        att.contentType = 'application/pdf';
        insert att;
    }

    private static PageReference getPageReference(Id regId, String regCountry, String regProducts, String renderAs) {
        if (regid == null) return null;
        PageReference pageRef;    
        if (regCountry == 'Australia') {
            if (regProducts.contains('VANs') && regProducts.contains('eNett EFT')) {
                pageRef = new PageReference('/apex/Client_Agreement_AU_EFT_and_VANS?renderAs=' + renderAs + '&id=' + regID);
            } else if (regProducts.contains('eNett EFT')) {
                pageRef = new PageReference('/apex/Client_Agreement_AU_EFT?renderAs=' + renderAs + '&id=' + regID);
            } else {
                pageRef = new PageReference('/apex/Client_Agreement_AU_VANs?renderAs=' + renderAs + '&id=' + regID);
            }
        } else if (regCountry == 'New Zealand') {
            if (regProducts.contains('VANs') && regProducts.contains('eNett EFT')) {
                pageRef = new PageReference('/apex/Client_Agreement_NZ_EFT_and_VANS?renderAs=' + renderAs + '&id=' + regID);
            } else if (regProducts.contains('eNett EFT')) {
                pageRef = new PageReference('/apex/Client_Agreement_NZ_EFT?renderAs=' + renderAs + '&id=' + regID);
            } else {
                pageRef = new PageReference('/apex/Client_Agreement_ROW_VANS?renderAs=' + renderAs + '&id=' + regID);
            }        
        } else {
            pageRef = new PageReference('/apex/Client_Agreement_ROW_VANS?renderAs=' + renderAs + '&id=' + regID);
        }

        return pageRef;
    }

    public string getTermsAndConditionsHTML() {
        if (this.Id == null) return '';
        String s = '';
        if (this.Products.contains('VANs') && this.Standard_TCs_Template_VANs != null) {
            for (Document_Template__c dT : [SELECT Content__c FROM Document_Template__c 
                                            WHERE Id = :this.Standard_TCs_Template_VANs 
                                            AND (Status__c = 'Active' OR Status__c = 'Archived')
                                            LIMIT 1]) {
                s += dT.content__c;
            }
        }
        if (this.Products.contains('VANs') && this.Products.contains('eNett EFT')) {
            s += '<br/><br/><br/>';
        }
        if (this.Products.contains('eNett EFT') && this.Standard_TCs_Template_EFT != null) {
            for (Document_Template__c dT : [SELECT Content__c FROM Document_Template__c 
                                            WHERE Id = :this.Standard_TCs_Template_EFT 
                                            AND (Status__c = 'Active' OR Status__c = 'Archived')
                                            LIMIT 1]) {
                s += dT.content__c;
            }
        }
        return s;
    }

}