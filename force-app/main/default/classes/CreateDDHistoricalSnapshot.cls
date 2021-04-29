public with sharing class CreateDDHistoricalSnapshot {
    @future
    public static void save(Id ddId, Id pId){
    
        PageReference pdf = new PageReference('/apex/DD_Historical_Snapshot?id=' + ddId);
        Attachment attach = new Attachment();
        
        Blob body;
        
        body = pdf.getContentAsPDF();       
        attach.Body = body;
        attach.Name = 'historical_snapshot.pdf';
        attach.IsPrivate = false;
        attach.contentType = 'application/pdf';
        attach.ParentId = pId;
        insert attach;
        
    }
}