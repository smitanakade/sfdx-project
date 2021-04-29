public with sharing class HierarchyController{
    //Load all the products
    @RemoteAction 
    public static List<Beneficial_Owner__c> loadBenHier(Id RegId) {
        return [select Id, Percentage_Shareholder__c, Registered_Business_Name__c, Beneficial_Owner_Of_ID__c from Beneficial_Owner__c where Registration__c = :RegId order by CreatedDate DESC];
    }
}