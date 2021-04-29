global class AccountStatusBannerExtension {
    private String accId {get; set;}
    private String RegStatus {get; set;}
    private String DDStatus {get; set;}
    private String ContractStatus {get; set;}
    public Id regId {get; private set;}
    public Id oppId {get; private set;}
    public Id contractId {get; private set;}
    public Boolean regShowHyperlink {get; private set;}
    public Boolean ddShowHyperlink {get; private set;}    
    public Boolean oppShowHyperlink {get; private set;}    
    public Boolean contractShowHyperlink {get; private set;}
    
    public String RegStatusColour {get; private set;}
    public String RegFontColour {get; private set;}
    public String RegBorderColour {get; private set;}
    
    public String DDStatusColour {get; private set;}
    public String DDFontColour {get; private set;}
    public String DDBorderColour {get; private set;}
    
    public String OppStatusColour {get; private set;}
    public String OppFontColour {get; private set;}
    public String OppBorderColour {get; private set;}
    
    public String ContractStatusColour {get; private set;}   
    public String ContractFontColour {get; private set;}
    public String ContractBorderColour {get; private set;}
    
    public Boolean RenderRegColumn {get; private set;}
    public Boolean RenderDDColumn {get; private set;}
    public Boolean RenderOppColumn {get; private set;}
    public Boolean RenderContractColumn {get; private set;}            
    
    private final MAP<String, String> cMap = new MAP<String, String>{'White' => '#ffffff', 
        'Green' => '#23a94b', 
        'Amber' => '#fbbc05',
        'Red' => '#c40818',
        'Grey' => '#999999',
        'LightGrey' => '#f2f2f2',
        'Black' => '#595959',
        'Purple' => '#DA70D6'};
            
            global AccountStatusBannerExtension(ApexPages.StandardController stdController) {
                accId = Apexpages.currentPage().getParameters().get('id');
                Account a = [SELECT Id, DD_Status__c, Account_Type__c, Account_Status__c, Reference_Registration__c, Registration_Status__c, 
                             product_contracts_active__c, CMPA_received__c, Awaiting_CMPA__c, Opportunity_Status__c,
                             (select id, StageName from Opportunities ORDER BY LastModifiedDate DESC LIMIT 50),
                             (select id, Status__c from eNett_Contract__r ORDER BY LastModifiedDate DESC LIMIT 50)
                             FROM Account WHERE Id = :accId LIMIT 1][0];
                regId =  a.Reference_Registration__c;
                oppId = null; 
                contractId = a.eNett_Contract__r.isEmpty() ? null : a.eNett_Contract__r[0].id;
                RegStatus = a.Registration_Status__c != null ? a.Registration_Status__c : '';
                DDStatus = a.DD_Status__c != null ? a.DD_Status__c : '';
                
                MAP<Id, Boolean> viewAccessMap = new MAP<Id, Boolean>();
                SET<Id> recIds = new Set<Id>();
                if (regId != null) recIds.add(regId);
                if (contractId != null) recIds.add(contractId);
                for (UserRecordAccess rAcc : [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId IN :recIds]) {
                    viewAccessMap.put(rAcc.RecordId, rAcc.HasReadAccess);
                }
                
                Integer contractInflight_count = 0;
                Integer contractActive_count = 0;
                Integer contractInactive_count = 0;
                for (eNett_Contract__c cnt : a.eNett_Contract__r) {
                    if (cnt.Status__c == 'In Flight') contractInflight_count += 1;
                    if (cnt.Status__c == 'Active') contractActive_count += 1;
                    if (cnt.Status__c == 'Inactive') contractInactive_count += 1;
                }
                Integer contract_count = contractInflight_count + contractActive_count + contractInactive_count;
                
                
                
                if (viewAccessMap.containsKey(regId)) {
                    regShowHyperlink = viewAccessMap.get(regId);
                    ddShowHyperlink = viewAccessMap.get(regId);
                } else {
                    regShowHyperlink = false;
                    ddShowHyperlink = false;
                }
                
                oppShowHyperlink = false;
                contractShowHyperlink = false;
                
                if (RegStatus == 'Complete') {
                    RegStatusColour = cMap.get('Green');
                } else if (RegStatus == 'Rejected - Non-responsive' || RegStatus == 'Rejected - Spam/test application' || RegStatus == 'Rejected - Application N/A') {
                    RegStatusColour = cMap.get('Red');        
                } else {
                    RegStatusColour = cMap.get('Amber');
                }
                
                if (DDStatus == 'DD Approved') {
                    DDStatusColour = cMap.get('Green');
                } else if (DDStatus == 'DD Declined') {
                    DDStatusColour = cMap.get('Red');
                } else {
                    DDStatusColour = cMap.get('Amber');
                }
                
                //2018-06-14
                //Since we are introducing Opportunity Status field on Account, we can just load the colours of the banner based on that field.
                //However older accounts are not populated with this field, I added the first condition for backward comp
                Integer oppProspect_count = 0;
                Integer oppClosedLost_count = 0;
                Integer oppClosedRemoved_count = 0;
                Integer opp_count = a.Opportunities.isEmpty() ? 0 : a.Opportunities.size();  

                if (String.isBlank(a.Opportunity_Status__c)){
                    for (Opportunity opp : a.Opportunities) {
                        if (opp.StageName == '1. Prospect') oppProspect_count += 1;
                        if (opp.StageName == '7. Closed/Lost') oppClosedLost_count += 1;
                        if (opp.StageName == '8. Closed/Lost - Product Removed') oppClosedRemoved_count += 1;            
                    }
                    if (opp_count == 0 || oppClosedRemoved_count == opp_count)// If NA or Product Removed
                        OppStatusColour = cMap.get('LightGrey');    
                    else if (oppClosedLost_count == opp_count)   // If all Closed/Lost
                        OppStatusColour = cMap.get('Red');
                    else if (oppProspect_count > 0) 
                        OppStatusColour = cMap.get('Amber');
                    else 
                        OppStatusColour = cMap.get('Green');
                }
                else if (a.Opportunity_Status__c == 'Not Available' || a.Opportunity_Status__c == 'Product Removed' )
                    OppStatusColour = cMap.get('LightGrey');    
                else if (a.Opportunity_Status__c == 'All Closed/Lost')
                    OppStatusColour = cMap.get('Red');
                else if (a.Opportunity_Status__c == 'Qualified') 
                    OppStatusColour = cMap.get('Green');
                else
                    OppStatusColour = cMap.get('Amber');
                
                
                if (UpdateActiveProductCheckboxesOnAccount.getUpdatedProductContractsActiveCheckbox(accId)) {
                    if (a.Awaiting_CMPA__c) {
                        ContractStatusColour = cMap.get('Amber');
                    } else {
                        ContractStatusColour = cMap.get('Green');
                    }
                } else if (contractInflight_count > 0) {
                    ContractStatusColour = cMap.get('Amber');
                } else {
                    ContractStatusColour = cMap.get('LightGrey');
                }
                
                RenderRegColumn = false;
                RenderDDColumn = false;
                RenderOppColumn = true;
                RenderContractColumn = true;
                
                if (a.Account_Type__c == 'Affiliate' || a.Account_Type__c == 'Customer' || a.Account_Type__c == 'Service Provider') {
                    RenderRegColumn = true;
                }
                
                if (a.Account_Type__c == 'Affiliate' || a.Account_Type__c == 'Customer' || a.Account_Type__c == 'Service Provider') {
                    RenderDDColumn = true;
                }
                
                if (a.Account_Type__c == 'Service Provider' || a.Account_Type__c == 'Referrer') {
                    RenderOppColumn = false;
                }
                
                if (a.Account_Type__c == 'Additional ECN') {
                    RenderContractColumn = false;
                }          
                
                if (a.Account_Status__c == 'Deactivated') {
                    RenderRegColumn = false;
                    RenderDDColumn = false;
                    RenderOppColumn = false;
                    RenderContractColumn = false;
                }
                
                RegFontColour = GetTextColour(RegStatusColour);
                RegBorderColour = GetBorderColour(RegStatusColour);
                
                DDFontColour = GetTextColour(DDStatusColour);
                DDBorderColour = GetBorderColour(DDStatusColour);
                
                OppFontColour = GetTextColour(OppStatusColour);
                OppBorderColour = GetBorderColour(OppStatusColour);
                
                ContractFontColour = GetTextColour(ContractStatusColour);
                ContractBorderColour = GetBorderColour(ContractStatusColour);       
            }
    
    private String GetTextColour(String StatusColour) {
        if (StatusColour == cMap.get('LightGrey')) {
            return cMap.get('Black');
        } else {
            return cMap.get('White');
        }
    }
    
    private String GetBorderColour(String StatusColour) {
        if (StatusColour == cMap.get('White')) {
            return StatusColour; //return cMap.get('Grey');
        } else {
            return StatusColour;
        }
    }   
    
}