/**
* This class contains all the webservices developed for SF integration with GDPR systems.  
  @author : Surajsingh Thakur
  @version : 1.0
  @update : -
**/

@RestResource(urlMapping='/GDPRMaskECN/*')
global with sharing class GDPR{

   /*
      A REST HttpPost class for the GDPR subscriber to send ECNs for data masking.
      GDPR subscriber will send one ECN at a time. Upon receiving that ECN, a record of GDPR_Masking__c will be created.
   */
   @HttpPost
   global static void doPost() {
	
     try{
        //Instantoiating the HttpRequest
        RestRequest req = RestContext.request;

        //Instanciating GDPR_Data_Subject__c object record.
        GDPR_Masking__c dataSubject = new GDPR_Masking__c();
        String ECN =  String.valueOf(req.params.get('ECN'));
       	List<Account> accounts = [SELECT Id from Account where ECN__C =: ECN];
       	if(accounts.size() > 0){
       		dataSubject.ECN__c = ECN;
       		dataSubject.GDPR_status__C = 'New';
           	insert dataSubject;
       	}else{
            EmailUtils.sendAlertEmail('GDPR request for invalid ECN : '+ECN, 'GDPR request for an invalid ECN number is found');
       	}
     }catch(Exception e){
           System.debug('#####Exception in GDPR - GDPRMaskECN HttpPost : '+e.getMessage());
           EmailUtils.sendAlertEmail('Exception in GDPR record creation - GDPRMaskECN HttpPost', e.getMessage() );
      }
    }
}