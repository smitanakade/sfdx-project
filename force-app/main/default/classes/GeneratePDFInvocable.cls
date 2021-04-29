global class GeneratePDFInvocable {

    @InvocableMethod (label='Generate Document')
    global static void GeneratePDFInvocable (LIST<GeneratePDFRequest> requests) {
        for (GeneratePDFRequest request : requests) {
            GeneratePDFInvocable.generatePDF(request.documentTemplateId, request.parentID);
        }
    }
    
    global class GeneratePDFRequest {
        @InvocableVariable(required=true)
        public ID documentTemplateId;

        @InvocableVariable(required=true)
        public ID parentID;
    }
 
    @future(callout=true)
    private static void generatePDF(Id documentTemplateId, Id parentID) {
        PageReference pageRef = new PageReference('/apex/DocumentTemplateTest?id=' + documentTemplateId);
        Blob docBody = pageRef.getContentAsPDF();
        String filename = [SELECT Output_Filename__c FROM Document_Template__c WHERE Id = :documentTemplateId].Output_Filename__c;
        Attachment a = new Attachment(Body = docBody, Name = filename, ParentId = parentID, contentType='application/pdf');
        insert a;       
    }
 
}