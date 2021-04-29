public class accountRTSelectionController {

    public final RecordType internalRT{get;set;}

    public accountRTSelectionController(ApexPages.StandardController stdController) {
        internalRT = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND IsActive = TRUE AND DeveloperName = 'eNett_Internal'][0];
    }

    public PageReference getNewInternalAccountPageRef() {
        PageReference ref = new PageReference('/001/e');
        ref.getParameters().put('RecordType', internalRT.Id);
        ref.getParameters().put('retURL', '/001/o');
        ref.getParameters().put('ent', 'Account');
        ref.getParameters().put('nooverride', '1');
        return ref;
    }

}