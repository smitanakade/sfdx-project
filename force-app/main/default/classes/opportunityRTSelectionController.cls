public class opportunityRTSelectionController {

    public final RecordType contractRT;

    public opportunityRTSelectionController(ApexPages.StandardController stdController) {
        contractRT = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND IsActive = TRUE AND DeveloperName = 'Contract'][0];
    }

    public PageReference getNewOpportunityContractPageRef() {
        Date d = date.today();
        d = d.addDays(90);
       
        PageReference ref = new PageReference('/006/e');
        ref.getParameters().put('RecordType', contractRT.Id);
        ref.getParameters().put('retURL', '/006/o');
        ref.getParameters().put('ent', 'Opportunity');
        //ref.getParameters().put('opp4_lkid', '{!Record.AccountId}');
        ref.getParameters().put('opp9', d.format());
        ref.getParameters().put('nooverride', '1');
        return ref;
    }

}