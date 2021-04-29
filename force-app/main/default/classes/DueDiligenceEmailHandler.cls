global class DueDiligenceEmailHandler implements Messaging.InboundEmailHandler {

  global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,
    Messaging.InboundEnvelope envelope) {

    Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
    result.success = false;

    String regObjPrefix = Registration__c.sObjectType.getDescribe().getKeyPrefix();

    String subject = email.subject;
    String refId;
    Task t;
    
    if (subject != null && subject.containsIgnoreCase('ref:')) {
        List<String> sa = subject.split('(?i)ref:');
        if (sa.size() > 1 && sa[1].length() >= 15) {
            refId = sa[1].substring(0,15);
        }
        subject = subject.replaceFirst('(?i)\\[ref:[a-z,0-9]*\\]', '');
    }       
    
    if (refID != null && refID.startswith(regObjPrefix)) {
        t = new Task();
        t.Subject = 'Email: ' + email.subject;
        t.WhatId = refID;
        t.Type = 'Email';
        t.priority= 'Normal';
        t.status = 'Not Started';
        t.description = 'From: ' + Email.FromName + ' <' + Email.FromAddress + '>\n\n' + email.plainTextBody;
        t.ActivityDate = system.today();
        try {
            insert t;

            if (email.binaryAttachments != null && email.binaryAttachments.size() > 0) {
                for (integer i = 0 ; i < email.binaryAttachments.size() ; i++) {
                    Attachment attachment = new Attachment();
                    attachment.ParentId = t.id;
                    attachment.Name = email.binaryAttachments[i].filename;
                    attachment.Body = email.binaryAttachments[i].body;
                    insert attachment;
                }
            }
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            result.success = false;
        }
    }
    result.success = true;
    return result;

  }

}