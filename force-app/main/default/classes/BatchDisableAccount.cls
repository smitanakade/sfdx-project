public class BatchDisableAccount implements Database.Batchable<sObject>, Database.Stateful 
{
	//We need to determine if we execute
	public List<Account> Targets{ get; set; }
	public Boolean EmailNotification{ get; set; }

	private	string MsgContent = ''; 
	
	public Database.QueryLocator start(Database.BatchableContext info)
	{
		
	    msgContent += '\r\n ==============================================================================';
   		msgContent += '\r\n ======================== ACCOUNT DISABLE BATCH ===============================';
   		msgContent += '\r\n ==============================================================================';
	    msgContent += '\r\n ';
	    msgContent += '\r\n Executing at (GMT):' + datetime.now();
	    msgContent += '\r\n Executing at (Local):' + datetime.now().format();
	    msgContent += '\r\n ';
   		msgContent += '\r\n ==============================================================================';
	    msgContent += '\r\n Account Information';
	    for(Account a : Targets){
   			msgContent += '\r\n ' + a;
	    }
   		msgContent += '\r\n ==============================================================================';
		
		Map<string, integer> emailAddresses = new Map<string, integer>();
		for( Contact c : [select Email from Contact where AccountId in :Targets ])
			if (!string.IsBlank( c.Email )) 
		    	emailAddresses.put( c.Email, 0 );
		
	    msgContent += '\r\n ';
   		msgContent += '\r\n ==============================================================================';
	    msgContent += '\r\n Contact Information';
		msgContent += '\r\n ' + string.join(new List<string>(emailAddresses.keyset()), '\r\n ');
   		msgContent += '\r\n ==============================================================================';

		for( AggregateResult ar : [select Email from Contact where Email in :emailAddresses.keyset() group by Email, AccountId, Name order by Email, AccountId, name ])
			emailAddresses.put( (string)ar.get('Email'), emailAddresses.get((string)ar.get('Email')) + 1);

		for( string addr : emailAddresses.keySet())
       		if ( emailAddresses.containsKey(addr) && ( emailAddresses.get(addr) > 1 ))
            	emailAddresses.remove(addr);

	    msgContent += '\r\n ';
   		msgContent += '\r\n ==============================================================================';
	    msgContent += '\r\n Deduplicated Contact Information';
		msgContent += '\r\n ' + string.join(new List<string>(emailAddresses.keyset()), '\r\n ');
   		msgContent += '\r\n ==============================================================================';

		return Database.getQueryLocator([SELECT Id FROM MC4SF__MC_Subscriber__c where MC4SF__Member_Status__c != 'Unsubscribed' and MC4SF__Email2__c in :emailAddresses.keyset()]);
	}      

	public void execute(Database.BatchableContext info, List<sobject> scope)
	{
		
		//MC4SF__Member_Status__c ,MC4SF__Status_Reason_Text__c,MC4SF__Status_Reason__c,MC4SF__Status_Timestamp__c
		
	    msgContent += '\r\n ';
   		msgContent += '\r\n ==============================================================================';
	    msgContent += '\r\n Batch Execute Method:';
		msgContent += '\r\n' + info;
	    msgContent += '\r\n ';
   		msgContent += '\r\n ==============================================================================';
	    msgContent += '\r\n Scope Information';
		msgContent += '\r\n ' + string.join(scope, ' \r\n ');
   		msgContent += '\r\n ==============================================================================';
   		
   		List<MC4SF__MC_Subscriber__c> upsertList = new List<MC4SF__MC_Subscriber__c>();
   		for(sobject obj : scope)
   			upsertList.add( new MC4SF__MC_Subscriber__c( Id = obj.Id, MC4SF__Member_Status__c = 'Unsubscribed', MC4SF__Status_Reason__c = 'Account deactivated', MC4SF__Status_Timestamp__c = DateTime.now()));

	    msgContent += '\r\n ';
   		msgContent += '\r\n ==============================================================================';
	    msgContent += '\r\n Upserting:';
   		Database.SaveResult[] updateResults = database.update( upsertList, true );
   		for( integer counter = 0; counter < upsertList.size(); counter++){
	   		msgContent += '\r\n Record:' + upsertList[counter];
	   		Database.SaveResult sr = updateResults[counter];
	   		if (sr.isSuccess()) { 
	   			msgContent += '\r\n OK:' + sr.getId();
	   		} else { 
   				msgContent += '\r\n ==============================================================================';
	   			msgContent += '\r\n FAIL:';
    			for(Database.Error err : sr.getErrors()) { 
	   				msgContent += '\r\n     :[' + err.getStatusCode() + '] ' + err.getMessage(); 
	   				msgContent += '\r\n     :[Fields] ' + err.getFields();
    			}
    			msgContent += '\r\n ==============================================================================';
	   		}
   		}
   		msgContent += '\r\n ==============================================================================';
	}
	  
	public void finish(Database.BatchableContext info)
	{
   		AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :info.getJobId()];
   		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
   		String[] toAddresses = new String[] {a.CreatedBy.Email};
	   	mail.setToAddresses(toAddresses);
   		mail.setSubject('BatchDisableAccount:' + a.Status);
   		
	    msgContent += '\r\n ';
   		msgContent += '\r\n ==============================================================================';
	    msgContent += '\r\n Batch Process Completion:';
		msgContent += '\r\n ' + info;
		msgContent += '\r\n ' + a;
	    msgContent += '\r\n ';
   		msgContent += '\r\n ==============================================================================';
	    msgContent += '\r\n Batch Summamry:';
		msgContent += '\r\n The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.';
   		msgContent += '\r\n ==============================================================================';
  		mail.setPlainTextBody( msgContent );
   		if (!Test.isRunningTest() && EmailNotification) Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}    
	
	public static Id Execute(List<Account> accts){
		BatchDisableAccount runThisBatch = new BatchDisableAccount();
		runThisBatch.Targets = accts;
		runThisBatch.EmailNotification = false;
		return Database.executeBatch(runThisBatch, 200);
	}

	public static Id Execute(List<Account> accts, boolean sendEmail){
		BatchDisableAccount runThisBatch = new BatchDisableAccount();
		runThisBatch.Targets = accts;
		runThisBatch.EmailNotification = sendEmail;
		return Database.executeBatch(runThisBatch, 200);
	}
}