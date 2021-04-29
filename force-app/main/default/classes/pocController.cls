public class pocController {

    public string renderMode {get; set;}
    public string contentType {get; set;}
    public string content {get; set;}
        
    public pocController(ApexPages.StandardController controller) {
        //ApexPages.currentPage().getParameters().get('id');
        if(ApexPages.currentPage().getParameters().get('renderAs') != null) {
            renderMode = 'pdf';
            contentType = null;
        } else {
            renderMode = null;
            contentType = null;
        }

        PageReference pageRef = new PageReference('/apex/Client_Agreement_AU_EFT_and_VANS?id=a1ZO00000096GJ0');
        String pageHTML = pageRef.getContent().toString();
        content = pageHTML + '<br/><p>' + [SELECT Content__c FROM Document_Template__c WHERE Id = 'a2AO0000000w2AI'][0].Content__c;
    }


}