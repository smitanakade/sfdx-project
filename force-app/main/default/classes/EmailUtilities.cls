public class EmailUtilities 
{
    public class EMailException extends Exception{}
        
    public static Messaging.InboundEmailResult processInboundEmail(Messaging.InboundEmail email){
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        result.success = false;
         
        /** create inboundEmailRecord with details of the email (as an Email Attachement)  **/
        Inbound_Email__c newEmail = new Inbound_Email__c(Received_Date__c = DateTime.Now());
        if ( email.Headers != null ) {
            newEmail.Headers__c = '';
            for( Messaging.InboundEmail.Header header : email.Headers)
                newEmail.Headers__c += header.name + ':' + header.value +';\n';
        }

        newEmail.Subject__c = email.Subject;
        newEmail.From__c = email.fromAddress;
        

        if (email.htmlBody != null)
            newEmail.htmlBody__c = email.htmlBody.SubString(0,Math.Min(email.htmlBody.length(),Inbound_Email__c.htmlBody__c.getDescribe().getLength()));
        if (email.plainTextBody != null)
            newEmail.textBody__c = email.plainTextBody.SubString(0,Math.Min(email.plainTextBody.length(),Inbound_Email__c.textBody__c.getDescribe().getLength()));
            
        /* **** To */
        if ( email.toAddresses != null ){
            string value = string.join(email.toAddresses,';\n');
            newEmail.To__c = value.subString(Math.Min(value.length(),Inbound_Email__c.To__c.getDescribe().getLength()));
        }
            
        /* **** CC */
        if(email.ccAddresses != null){
            string value = string.join(email.ccAddresses,';\n');
            newEmail.Cc__c = value.subString(Math.Min(value.length(),Inbound_Email__c.Cc__c.getDescribe().getLength()));
        } 
            
     
        /* **** From */
        newEmail.From__c = email.fromName;
        newEmail.fromAddress__c = email.fromAddress;
        
        
        insert newEmail;
        handleattachments(newEmail, email);
        
        /*
          "edge" case - if an insert occurs the before insert triggers fire (assigning the case and mapping the email) before the attachments are saved
          therefore re-query for the case and if this is "now" assigned call the cloneAttachments via this method rather than rely on the triggers
        */
        Inbound_Email__c checkCase = [select case__c from Inbound_Email__c where Id = :newEmail.Id];
        if ( checkCase.case__c != null ) cloneAttachments(newEmail.Id, checkCase.case__c);        
        
        result.success = true;
        return result;
    }

    public static void createEmailMessage(Id InboundId, Id parentObj) {
        Inbound_Email__c newEmail = [select Received_Date__c, 
                                            Headers__c, 
                                            Subject__c,
                                            htmlBody__c,
                                            textBody__c,
                                            To__c,
                                            Cc__c,
                                            From__c,
                                            fromAddress__c,
                                            Id
                                      from Inbound_Email__c where Id = :InboundId];

        EmailMessage theEmail = new EmailMessage();
        theEmail.Incoming = true;
        theEmail.Status = '0';

        theEmail.MessageDate = newEmail.Received_Date__c;
        theEmail.toAddress = newEmail.To__c;
        theEmail.CcAddress = newEmail.CC__c;
        theEmail.FromName = newEmail.From__c;

        if (newEmail.Headers__c != null) theEmail.Headers = newEmail.Headers__c.SubString(0,Math.Min(newemail.Headers__c.length(),EmailMessage.Headers.getDescribe().getLength()));
        if (newEmail.Subject__c != null) theEmail.Subject = newEmail.Subject__c.SubString(0,Math.Min(newemail.Subject__c.length(),EmailMessage.Subject.getDescribe().getLength()));
        if (newEmail.htmlBody__c != null) theEmail.htmlBody = newEmail.htmlBody__c.SubString(0,Math.Min(newemail.htmlBody__c.length(),EmailMessage.htmlBody.getDescribe().getLength()));
        if (newEmail.textBody__c != null) theEmail.textBody = newEmail.textBody__c.SubString(0,Math.Min(newemail.textBody__c.length(),EmailMessage.textBody.getDescribe().getLength()));
        if (newEmail.FromAddress__c != null) theEmail.Fromaddress = newEmail.FromAddress__c.SubString(0,Math.Min(newemail.FromAddress__c.length(),EmailMessage.Fromaddress.getDescribe().getLength()));

        theEmail.ParentId = parentObj;
        insert theEmail;    
        cloneAttachments( newEmail.Id, theEmail.Id );
    }   
    
    
    public static void cloneAttachments(Id parentObjId, Id newParentObjId){
        /*
            @author : Arun Sivanesan
    
            @version : 2.0
    
            @update : Ticket PDS-4994 
            
            Summary : As part of one of the projects in early 2018, attachments and notes were migrated to Files in preparation to SF lighting. 
            The incoming emails which has attachments are converted to Files in the Attachment Trigger ( AttachmentTriggerHandler()) . 
            Since that point, this method would not have fetched the attachments and cloned them as they will not exist.
            Code change is to have the documentlinked to one more parent (tickets). 
            
            Note: We have left the old code commented below for any reference.

        */       
        ContentDocumentLink [] insertCDLList = new ContentDocumentLink[]{};
                
        for(ContentDocumentLink cdl : [SELECT ContentDocumentId,ShareType,Visibility FROM ContentDocumentLink WHERE LinkedEntityId =:parentObjId]){
             ContentDocumentLink contDocLink = new ContentDocumentLink(ContentDocumentId = cdl.ContentDocumentId, LinkedEntityId = newParentObjId, ShareType = cdl.ShareType, Visibility = cdl.Visibility);
             insertCDLList.add(contDocLink);        
        }
        
        if(insertCDLList.size() > 0)
        {
           insert insertCDLList;
        }
        
        /* -- Code has been Commented and can we deleted at later stage.
        
        Attachment[] attList = [select id, name, body from Attachment where ParentId = :parentObjId];
        Attachment[] insertAttList = new Attachment[]{};
        for(Attachment a: attList)
        {
               Attachment att = new Attachment(name = a.name, body = a.body, parentid = newParentObjid);
               insertAttList.add(att);
        }
        if(insertAttList.size() > 0)
        {
            insert insertAttList;
        }*/
        
    }

    private static void handleAttachments(Sobject parentObj, Messaging.InboundEmail email) {
        List<Attachment> Attachments = new List<Attachment>();
        
        if(email.textAttachments!=null && email.textAttachments.size() >0) {
            for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) {
                Attachment attachment = new Attachment();  
                attachment.Name = tAttachment.fileName;
                attachment.Body = Blob.valueOf(tAttachment.body);
                attachment.ParentId = parentObj.Id;
                Attachments.add(attachment);
                system.debug('#####1 handleAttachments Name:' + attachment.Name);
                system.debug('#####1 handleAttachments attachment.ParentId:' + attachment.ParentId);
            }
        }
     
        if(email.binaryAttachments!=null && email.binaryAttachments.size() >0) {
            for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
                Attachment attachment = new Attachment();
                attachment.Name = bAttachment.fileName;
                attachment.Body = bAttachment.body;
                attachment.ParentId = parentObj.Id;
                Attachments.add(attachment);
                system.debug('#####1 handleAttachments BinaryAttachment:' + attachment.Name);
            }
        } 
        
        if (!Attachments.isEmpty()) system.debug('#####1 Inserting Attachments:' + attachment.Name); insert Attachments;
    }
    
    
    /**
      //This method will pick every inbound email and check if there is any associated Case
      //If one exists then it will assign the CaseID to the inbound email.
    @author : Arun Sivanesan
    
    @version : 1.0
    
    @update : Ticket PDS-3456
    **/

  @InvocableMethod(label='Assign Inbound Email To Case' description='Assign Inbound Emails To Case')  
      public static void assignInboundEmailToCase(List<ID> ids) {
    
        Map<string,Inbound_email__c>subjectMap = new Map<string,Inbound_email__c>();
        for( Inbound_email__c rec : [Select id, Subject__c, textBody__c from Inbound_Email__c  Where Id IN:ids]) {
            string content = ( rec.Subject__c != null && rec.Subject__c.contains('ref:')) ? rec.Subject__c : ( rec.textBody__c != null && rec.textBody__c.contains('ref:')) ? rec.textBody__c : '';
            string[] subjectArray = content.split('ref:');
            system.debug('##### Testing for:' + subjectArray);
    
                if ( subjectArray.size() > 1 ){
                        subjectMap.put('[ ref:_' + subjectArray[1].substring(1,subjectArray[1].indexOf(':')) +':ref ]', rec);   
                }
            }
        
        System.debug('##### Mapping to Records in :'+ subjectMap);
        
            for( Case c : [select Id, Ticket_Thread_ID__c from Case where Ticket_Thread_ID__c in :subjectMap.keyset()]){
                subjectMap.get(c.Ticket_Thread_ID__c).Case__c = c.Id;
            }
       
        try {     
                update subjectMap.values();
            }
            catch (DMLException e){
                System.Debug('#####DMLException Message: ' + e.getMessage());
                System.Debug('#####DMLException Number of DML: ' + e.getNumDml());
            } 
               
       }
      

  
}