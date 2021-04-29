public class FieldAuditing {
    private static MAP<String, Set<String>> objectAuditFields {get; set;}
       
    public static Set<String> getAuditFields (String objectName) {

        if (objectAuditFields != null && objectAuditFields.containskey(objectName)) {
            return objectAuditFields.get(objectName);
        } else {
            String fields, fields2, fields3, auditfieldsStr;
            Set<String> auditfields = new Set<String>();
    
            for (AuditFields__c af : AuditFields__c.getall().values()) {
                if (af.Name == objectName) {
                    fields = (af.Fields__c == null) ? '' : af.Fields__c;
                    fields2 = (af.Fields2__c == null) ? '' : af.Fields2__c;
                    fields3 = (af.Fields3__c == null) ? '' : af.Fields3__c;
                }
            }

            auditfieldsStr = (fields + ',' + fields2 + ',' + fields3).deleteWhitespace().toLowerCase();

            for (String auditfield : auditfieldsStr.split(',')) {
                auditfields.add(auditfield);
            }

            if (objectAuditFields == null) objectAuditFields = new MAP<String, Set<String>>();
            objectAuditFields.put(objectName, auditfields);
            return auditfields;
        }
    }
    
    public static void doFieldAuditing(String sObjectName, Map<Id, SObject> triggerOldMap, List<sObject> triggerNew) {       
    	//skip if trigger old and trigger new are the same
    	//or this is part of unit test
        if (Test.isRunningTest() || triggerOldMap == new Map<Id, SObject>(triggerNew)) return;

        String auditLog, newValue, oldValue, fieldLabel;
        String timeStampLT = '(' + DateTime.now().format('hh:mm a') + ' local user time)'; //DateTime.now().format();
        String timeStampGMT = DateTime.now().formatGmt('dd/MM/yyyy hh:mm a') + ' GMT';
        sObject objOld;
        Id userId = System.UserInfo.getUserId();
        String userName = [SELECT Name FROM User WHERE Id = :userId].Name;
        String auditFullText;
    
        Set<String> auditFields = FieldAuditing.getAuditFields(sObjectName);
        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap();
        Set<String> objectFieldAPINames = objectFields.keySet();
    
        for (sObject obj : triggerNew) {
            auditLog = '';
            objOld = triggerOldMap.get(obj.id);
        
            for (String auditField : auditFields) {
                fieldLabel = objectFields.get(auditField).getDescribe().getLabel();
                if (objectFieldAPINames.contains(auditField) && obj.get(auditField) != objOld.get(auditField)) {
                    oldValue = String.valueof(objOld.get(auditField));
                    newValue = String.valueof(obj.get(auditField));
                    auditLog += String.format('Changed <b>{0}</b> from {1} to <b>{2}</b>.<br/>', new List<String>{fieldLabel, oldValue, newValue});
                }
            }
        
            if (!String.isBlank(auditLog)) {
                auditLog = String.format('{0}: <a href="/{1}">{2}<a> {3}<br/>', new List<String>{timeStampGMT,userId,userName,timeStampLT}) 
                      + '<div style="margin-left: 67px;">' + auditLog + '</div><br/>';
                if (obj.get('Audit_Log__c') == null) {
                    obj.put('Audit_Log__c', auditLog);
                } else {
                    auditFullText = (String) obj.get('Audit_Log__c');
                    obj.put('Audit_Log__c', auditLog + auditFullText.subString(0, math.min(auditFullText.length(), 31060 - auditLog.length())));
                }
            }
        }
    }
}