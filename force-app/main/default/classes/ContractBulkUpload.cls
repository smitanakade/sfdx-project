public with sharing class ContractBulkUpload {

	//public class EContractException extends Exception{}
	
	
	//public ContractBulkUpload(){
	//    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Please select a region to update Standard T&Cs'));
	//	initPage();
	//}
	//private void initPage(){
	//    document = new Document(); 
	//	document.body = null; // clears the viewstate 
	//	region = null;
	//}
	
	///*   Static regions */
	//public List<SelectOption> getRegions() { 
 //       List<SelectOption> options = new List<SelectOption>(); 
 //       options.add(new SelectOption('APAC','APAC')); 
 //       options.add(new SelectOption('EMEA','EMEA')); 
 //       options.add(new SelectOption('Americas','Americas')); 
 //       return options; 
 //   } 
 //   /* Setters and getters */
	//public boolean getHasRegion(){
	//	return !string.IsBlank(region); 
	//}
	//public string Region{ get; set; }
	//public string getRegion(){
	//	return Region;
	//}
	//public void setRegion( string value){
	//	Region = value;
	//}
	
	//public string fileContentType = null;
	//public void setFileContentType(string value){
	//	fileContentType = value;
	//}
	//public string getFileContentType(){
	//	return fileContentType;
	//} 
	
 //   /* Action functions */
	//public PageReference LoadRegion(){
	//    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Please select the new Standard T&Cs PDF file for  ' + Region + ' and select Save'));
	//	return null;
	//}    
	//public PageReference LoadFile(){
	//	if ( string.IsBlank(fileContentType) || !FileContentType.toLowerCase().EndsWith('pdf')){
	//    	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a PDF file to upload.'));
	//    	return null;
	//	}
	//	list<account> accounts = null;
	//	Savepoint sp = null;
	//	try
	//	{
	//		RecordType rt = [select Id from Recordtype where DeveloperName = 'Contract_Upload_PDF_Copy_of_Contract' LIMIT 1];
	
	//    	list<eNEtt_Contract__c> contracts = new list<eNEtt_Contract__c>();
	//		list<Attachment> attachments = new list<Attachment>();
	//		list<Task> tasks = new list<Task>();
	
	//		accounts = [select Id, Name from Account where Region__c = :region and Contract_Type__c = 'Standard T&Cs'];
	//		for( Account a : accounts){
	//		    contracts.add(new eNEtt_Contract__c(Account_Name__c = a.Id, Contract_Stage__c = '7. T&C\'s Accepted.', Status__c = 'Active' ));
	//		    attachments.add(new Attachment(Body = document.Body, ContentType = fileContentType, Description = 'eNett Standard T&C\'s uploaded for ' + region + ' at ' + datetime.now().format(), Name = document.Name));
	//		    tasks.add(new Task(ActivityDate = Date.Today(), Description = 'New T&C\'s added', Status = 'Closed', Subject = 'New Terms and Conditions uploaded for ' + region + ' at ' + datetime.now().format() + ' from PDF source ' + document.name, RecordTypeId = rt.Id)); 
	//		}
			
	//		List<eNEtt_Contract__c> CancelledContracts = [select Id from eNEtt_Contract__c where Status__c = 'Active' and Account_Name__c in :accounts];
	//		for(eNEtt_Contract__c contract : CancelledContracts)
	//			contract.Status__c = 'Inactive';
			
	//		sp = Database.setSavepoint();  //Set transaction control in case we fail 

 //       	database.update(CancelledContracts, true); //We failed on first error so dont check sr.isSuccess()
 //       	Database.SaveResult[] srList = Database.insert(contracts, true); 
 //       	for(integer recCount = 0; recCount < srList.size(); recCount++){
 //       		tasks[recCount].WhatId = srList[recCount].getId();
 //       		attachments[recCount].ParentId = srList[recCount].getId();
 //       	}
 //       	Database.insert(tasks, true);
 //       	Database.insert(attachments, true);
 //       }
 //       catch(Exception Ex){
 //       	if (sp != null ) Database.rollback(sp);
	//    	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error ocurred: ' + ex));
	//    	return null;
 //       }	 
 //       initPage();
 //   	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'T&Cs from file ' + document.name + ' uploaded to:'));
	//	for( Account a : accounts)
	//    	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, ' ' + a.Name));

	//	return null;
	//}
	
	// public Document document { 
	//    get { 
	//      if (document == null) 
	//        document = new Document(); 
	//      return document; 
	//    } 
	//    set; 
	//  } 

}