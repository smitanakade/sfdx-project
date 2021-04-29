public class FutureCalls {   
/* 
      This has been expanded to include a number of static calls - apologies for the bad naming convention 
    
      Author: Mark Townsend
              Coroma Consulting
              0488071505
              14 April 2015
      
      Update History
      --15/11/2019 - Added additional item to serviceCloudRecordTypes in the method IsServiceCloud (Task - PDS-5754)

*/  
    public class FutureCallException extends Exception{}
    public class GenericException extends Exception{}
    public class RecordTypeException extends Exception{}
    
    public static Boolean forceFutureCalls = false; 
    

    /* 
       Record Type calls and other associated lookups
       Retrieve RecordTypes and save based on Developer Name for reference
    */
    private static map<string, map<string,RecordType>> allRecordTypes = new map<string,map<string,RecordType>>();
    public static map<string,RecordType> mapRecordTypes(string SobjectType){
        if (!allRecordTypes.containsKey(SobjectType)){
            map<string,RecordType> mapRecordType = new map<string,RecordType>();
            for( RecordType rt: [Select Id, Name, DeveloperName from RecordType where SObjectType = :SObjectType]){
                mapRecordType.put( rt.DeveloperName, rt );
            }
            allRecordTypes.put(SobjectType,mapRecordType);
        }
        return allRecordTypes.get(SobjectType);
    }

    // Map containg all email templates
    private static map<string,EmailTemplate> allEmailTemplates = new map<string,EmailTemplate>();
    public static map<string,EmailTemplate> mapEmailTemplates(){
        if (allEmailTemplates == null || allEmailTemplates.isEmpty()){

            List<EmailTemplate> templateList = [Select Id, DeveloperName from EmailTemplate where IsActive = true]; 
            for(EmailTemplate et : templateList){ 
                allEmailTemplates.put(et.DeveloperName,et); 
            }
        }
        return allEmailTemplates;
    }

    // Map containg all users
    private static map<id,User> allUsers = new map<id,User>();
    public static map<id,User> mapUsers(){
        if (allUsers == null || allUsers.isEmpty()){
            allUsers = new Map<id, User>([SELECT Id, email FROM User where IsActive = true]);
        }
        return allUsers;
    }

    // Provide a Dummy Contact
    private static Contact con;
    public static Contact getDummyContact(){
        if ( con == null ) {
            con = Test.isRunningTest() ? new Contact( Email = 'test@test.cm') : [select id, Email from Contact where email <> null limit 1];
        }
        return con;        
    }


    //SF-1569 - Map of the Qualify Opportunity Tasks for an Opportunity (used in Opportunity_Update.trigger)
    private static List<Process_Task__c> myList = new List<Process_Task__c>();
    public static List<Process_Task__c> listQOTasks(set<Id> opportunityIds){
        if (myList.isEmpty()) {
            myList = [select Id, Opportunity__c, Attainable_TTV_Monthly__c, GDV_Change_Justification__c, Record_Type__c, Status__c from Process_Task__c 
                                where Record_Type__c = 'Opportunity Qualify Opportunity' and Status__c <> 'Completed' and Opportunity__c in :opportunityIds ]; 
        }
        return myList;
    }
    


    //SF-1569 - Map of the Opportunity Contracts for an Opportunity (used in Opportunity_Update.trigger)
    private static List<eNett_Contract__c> oppContractsList = new List<eNett_Contract__c>();
    public static List<eNett_Contract__c> listOppCons(set<Id> oppConIds){
        if (oppContractsList.isEmpty()) {
            oppContractsList = [select Id, Opportunity_Name__c, VAN_Currencies__c, Status__c from eNett_Contract__c 
                                                    where Opportunity_Name__c in :oppConIds ];                                
        }
        return oppContractsList;
    }


    //SF-1703 - Map of the Opportunity Incentives for an Opportunity (used in Opportunity_Update.trigger)
//*** START ------- SF-1578: Need to comment this out for deployments prior to incentives going live
    //private static List<Incentive__c> oppIncentivesList = new List<Incentive__c>();
    //public static List<Incentive__c> listOppIns(set<Id> oppIds){
    //    if (oppIncentivesList.isEmpty()) {
    //        oppIncentivesList = [select Id, CurrencyIsoCode, Opportunity__c from Incentive__c where Opportunity__c in :oppIds ];                                
    //    }
    //    return oppIncentivesList;
    //}
//*** END ------- SF-1578: Need to comment this out for deployments prior to incentives going live



    ////SF-1569 - List of the Account Opportunities for an Account (used in Account_After.trigger)
    //private static List<Opportunity> accOppsList = new List<Opportunity>();
    //public static List<Opportunity> listAccOpps(set<Id> accOppIds){
    //    if (accOppsList.isEmpty()) {
    //        accOppsList = [SELECT Id, OwnerId, StageName, in_year_gdv__c, attainable_ttv_monthly__c FROM Opportunity WHERE AccountId IN :accOppIds];                                
    //    }
    //    return accOppsList;
    //}



    //SF-1569 - List of the Account Contacts for an Account (used in Account_After.trigger)
    private static List<Contact> accConList = new List<Contact>();
    public static List<Contact> listAccCons(set<Id> accConIds){
        if (accConList.isEmpty()) {
            accConList = [SELECT Id, FirstName, LastName, Email, AccountId FROM Contact WHERE AccountId IN :accConIds];                               
        }
        return accConList;
    }




    private static map<string,map<string,Delivery_Category_Benchmarks__c>> allBenchmarks;
    public static map<string,Delivery_Category_Benchmarks__c> mapBenchmarks(integer year){
         if (allBenchmarks == null){
            allBenchmarks = new map<string,map<string,Delivery_Category_Benchmarks__c>>();
            for(Delivery_Category_Benchmarks__c bm : [SELECT Id, Name, Delivery_Category__c, Days__c, Man_Hours__c, Year__c FROM Delivery_Category_Benchmarks__c]){
                map<string,Delivery_Category_Benchmarks__c> mapBenchmark = allBenchmarks.containsKey(bm.Year__c) ? allBenchmarks.get(bm.Year__c) : new map<string,Delivery_Category_Benchmarks__c>();
                mapBenchmark.put( bm.Delivery_Category__c, bm);
                allBenchmarks.put( bm.year__c, mapBenchmark);
            }
        }
        return allBenchmarks.get(string.valueOf(year));
    }
    
    private static set<Id> serviceCloudRecordTypes;
    public static boolean IsServiceCloud(Case c){
        if (serviceCloudRecordTypes == null){
            map<string,RecordType> mapCaseTypes = mapRecordTYpes('Case');
            serviceCloudRecordTypes = new set<Id>();
            
            serviceCloudRecordTypes.add(mapCaseTypes.get('Zendesk_Historical_Record').Id);
            serviceCloudRecordTypes.add(mapCaseTypes.get('Enett_Service_Cloud_Record_Type').Id);
            serviceCloudRecordTypes.add(mapCaseTypes.get('Closed_Enett_Service_Cloud_Record_Type').Id);
            serviceCloudRecordTypes.add(mapCaseTypes.get('Reopen_Enett_Service_Cloud_Record_Type').Id);
            serviceCloudRecordTypes.add(mapCaseTypes.get('Internal_Service_Cloud_Record_Type').Id);
            /* Start - Added Priority Service to list of items - PDS-5754) */
            serviceCloudRecordTypes.add(mapCaseTypes.get('Priority_Service').Id);
            /* Start - Added Priority Service to list of items - PDS-5754) */
        }
        return serviceCloudRecordTypes.contains(c.RecordTypeId);    
    }
    
    public static boolean IsDeliveryType(Case c){
        return !IsServiceCloud(c);
    }
    
 /*
    Definition of Delivery Tasks - based on Record Types therefore if the subject is the same as a RecordTYpe name - its a system one
 */   
    private static set<id> userRecordTypes;
    public static boolean isUserTask(Process_Task__c pt){
        if ( userRecordTypes == null ){
            map<string,RecordType> mapTaskTypes = mapRecordTypes('Process_Task__c');
            userRecordTypes = new set<id>();
            
            userRecordTypes.add(mapTaskTypes.get('Sales_Task').Id);
            userRecordTypes.add(mapTaskTypes.get('Service_Desk_Task').Id);
        }
        return userRecordTypes.contains(pt.RecordTypeId);
        
    }
    public static boolean isSystemTask(Process_Task__c pt){
        return !isUserTask(pt);
    }

    private static map<Id,Profile> serviceCloudProfiles;
    public static boolean isServiceCloudProfile(string profileId){
        if (serviceCloudProfiles == null ){
//          profiles = new Map<Id,Profile>([select Id, Name from Profile where Id in ('00e90000001HYt0','00e90000001HYt5','00e90000001HUfM','00e90000001I1Ru')])
            serviceCloudProfiles = new Map<Id,Profile>([select Id, Name from Profile where Name in ('System Administrator (no expiry)',
                                                                                                    'System Administrator (with expiry)',
                                                                                                    'System Administrator (without managed users permission)',
                                                                                                    'System Administrator',
                                                                                                    'eNett Service Desk User',
                                                                                                    'eNett Service Desk Administrator',
                                                                                                    'Stefanini Service Desk User',
                                                                                                    'Deployment Automation')]);
        }
        return serviceCloudProfiles.containsKey(profileId);
    }
    
    public static boolean isSystemAdmin(string profileid){
        //check if its a Service Cloud profile (loading the map if not already done) and then confirm the profile is also system admin
        //PDS-8714 - fixed syntax error
        return (isServiceCloudProfile(profileid) && (serviceCloudProfiles.get(profileId).Name == 'System Administrator' || serviceCloudProfiles.get(profileId).Name == 'System Administrator (no expiry)' || serviceCloudProfiles.get(profileId).Name == 'System Administrator (with expiry)' || serviceCloudProfiles.get(profileId).Name == 'System Administrator (without managed users permission)' || serviceCloudProfiles.get(profileId).Name == 'Deployment Automation'));
    }
    
    public static boolean isServiceCloudKPIProfile(string profileId){
        //check if its a Service Cloud profile (loading the map if not already done) and then confirm the profile is system admin or Stefanini
        return (isSystemAdmin(profileid) || (serviceCloudProfiles.containsKey(profileId) && serviceCloudProfiles.get(profileId).Name == 'Stefanini Service Desk User'));        
    }
    
    private static Map<string,BusinessHours> businessHoursOfOperation;
    public static BusinessHours Hours(string location){
        if (businessHoursOfOperation == null) {
            businessHoursOfOperation = new Map<string, BusinessHours>();
            for( BusinessHours hrs : [select Id, Name, IsDefault from BusinessHours]){
                businessHoursOfOperation.put(hrs.Name, hrs);
                if ( hrs.IsDefault ) businessHoursOfOperation.put('Default', hrs);
            }
        }
        return businessHoursOfOperation.get(location);
    }
    
    private static Map<string,List<string>> mapObjectFields = new Map<string,List<string>>();
    public static List<string> fieldListing(Sobject obj){
        string mapKey = string.valueOf(obj.getsObjectType());
        if (!mapObjectFields.containsKey(mapKey)){
            mapObjectFields.put(mapKey, new List<string>( obj.getsObjectType().getDescribe().fields.getMap().keyset()));
        }
        return mapObjectFields.get(mapKey);
    }
    
    public static RecordType MapAssertion(map<string,RecordType> mapOfRecordTypes, string DeveloperName){
        if ( !mapOfRecordTypes.containsKey(developerName)) throw new FutureCalls.RecordTypeException('The Record Type : ' + developerName + ' cannot be found.');
        return mapOfRecordTypes.get(developerName);
    }
    
    public static Id MapIdAssertion(map<string,RecordType> mapOfRecordTypes, string DeveloperName){
        return MapAssertion(mapOfRecordTypes,developerName).Id;
    }
    
    
/* 
    Optimisation calls to prevent sync of Case data when something hasnt changed 
    
*/
    private static boolean hasChanged(Object oldObj, Object newObj){
        return oldObj != newObj;
    }

    public static boolean hasChanged(Sobject oldObj, Sobject newObj, string fieldName){
        return (oldObj == null || newObj == null || hasChanged(oldObj.get(fieldName),newObj.get(fieldName)));
    }
    public static boolean hasChanged(Sobject oldObj, Sobject newObj, List<string> fieldList){
        for(string fieldName : fieldList)
            if(hasChanged(oldObj, newObj, fieldName))
                return true;
        return false;
    }
    public static boolean hasChanged(Sobject oldObj, Sobject newObj){
        return hasChanged(oldObj, newObj, fieldListing(oldObj == null ? newObj : oldObj));  
    }

/*
    TODO: Need to create this map and use dynamic soql
    private map<string,string> syncCaseToOpportunity
*/

    public static boolean RequiresSync(Case oldObj, Case newObj){
        if ( oldObj == null ) return true;
        
        if (hasChanged(oldObj.Actual_Development_Completed__c,newObj.Actual_Development_Completed__c))return true;
        System.Debug('Identical Values:Actual_Development_Completed__c');
        if (hasChanged(oldObj.Actual_Live_Testing_Completed__c,newObj.Actual_Live_Testing_Completed__c))return true;
        System.Debug('Identical Values:Actual_Live_Testing_Completed__c');
        if (hasChanged(oldObj.Actual_Planning_and_Prep_Completed__c,newObj.Actual_Planning_and_Prep_Completed__c))return true;
        System.Debug('Identical Values:Actual_Planning_and_Prep_Completed__c');
        if (hasChanged(oldObj.Actual_Production_Cut_Over_Date__c,newObj.Actual_Production_Cut_Over_Date__c))return true;
        System.Debug('Identical Values:Actual_Production_Cut_Over_Date__c');
        if (hasChanged(oldObj.Actual_UAT_Completed__c,newObj.Actual_UAT_Completed__c))return true;
        System.Debug('Identical Values:Actual_UAT_Completed__c');
        if (hasChanged(oldObj.Current_Activity__c,newObj.Current_Activity__c))return true;
        System.Debug('Identical Values:Current_Activity__c');
        if (hasChanged(oldObj.Closed_Lost_Terminated_Reason__c,newObj.Closed_Lost_Terminated_Reason__c))return true;
        System.Debug('Identical Values:Closed_Lost_Terminated_Reason__c');
        if (hasChanged(oldObj.Delivery_Category__c,newObj.Delivery_Category__c))return true;
        System.Debug('Identical Values:Delivery_Category__c');
        if (hasChanged(oldObj.Delivery_Category_Benchmark_Days__c,newObj.Delivery_Category_Benchmark_Days__c))return true;
        System.Debug('Identical Values:Delivery_Category_Benchmark_Days__c');
        if (hasChanged(oldObj.Delivery_Category_Benchmark_Man_Hours__c,newObj.Delivery_Category_Benchmark_Man_Hours__c))return true;
        System.Debug('Identical Values:Delivery_Category_Benchmark_Man_Hours__c');
        if (hasChanged(oldObj.Delivery_Implementation_Start_Date__c,newObj.Delivery_Implementation_Start_Date__c))return true;
        System.Debug('Identical Values:Delivery_Implementation_Start_Date__c');
        if (hasChanged(oldObj.Delivery_Phase__c,newObj.Delivery_Phase__c))return true;
        System.Debug('Identical Values:Delivery_Phase__c');
        if (hasChanged(oldObj.Estimated_Completion_Date__c,newObj.Estimated_Completion_Date__c))return true;
        System.Debug('Identical Values:Estimated_Completion_Date__c');
        if (hasChanged(oldObj.Enter_Pre_Kick_off_Quest_Completed_Date__c,newObj.Enter_Pre_Kick_off_Quest_Completed_Date__c))return true;
        System.Debug('Identical Values:Enter_Pre_Kick_off_Quest_Completed_Date__c');
        if (hasChanged(oldObj.Funding_Task_Completed__c,newObj.Funding_Task_Completed__c))return true;
        System.Debug('Identical Values:Funding_Task_Completed__c');
        if (hasChanged(oldObj.Implementation_Complete_Date__c,newObj.Implementation_Complete_Date__c))return true;
        System.Debug('Identical Values:Implementation_Complete_Date__c');
        if (hasChanged(oldObj.OwnerId,newObj.OwnerId))return true;
        System.Debug('Identical Values:OwnerId');
        if (hasChanged(oldObj.Phase_2_VAN_Training_Completed_Date__c,newObj.Phase_2_VAN_Training_Completed_Date__c))return true;
        System.Debug('Identical Values:Phase_2_VAN_Training_Completed_Date__c');
        if (hasChanged(oldObj.Related_Delivery_Opportunity__c,oldObj.Related_Delivery_Opportunity__c)) return true;
        System.Debug('Identical Values:Related_Delivery_Opportunity__c');
        if (hasChanged(oldObj.Status,newObj.Status))return true;
        System.Debug('Identical Values:Status');
        if (hasChanged(oldObj.Total_Delivery_Effort_Time_hours__c,newObj.Total_Delivery_Effort_Time_hours__c))return true;
        System.Debug('Identical Values:Total_Delivery_Effort_Time_hours__c');
        if (hasChanged(oldObj.Total_Dormant_Time_Days__c,newObj.Total_Dormant_Time_Days__c))return true;
        System.Debug('Identical Values:Total_Dormant_Time_Days__c');
        if (hasChanged(oldObj.Dormant_Reason__c,newObj.Dormant_Reason__c))return true;
        System.Debug('Identical Values:Dormant_Reason__c');
        if (hasChanged(oldObj.Dormant_Start_Date__c,newObj.Dormant_Start_Date__c))return true;
        System.Debug('Identical Values:Dormant_Start_Date__c');
        if (hasChanged(oldObj.Dormant_Category__c,newObj.Dormant_Category__c))return true;
        System.Debug('Identical Values:Dormant_Category__c');
        if (hasChanged(oldObj.Training_Booking_Created__c,newObj.Training_Booking_Created__c))return true;
        System.Debug('Identical Values:Training_Booking_Created__c');
        if (hasChanged(oldObj.Training_Completed_Date__c,newObj.Training_Completed_Date__c))return true;
        System.Debug('Identical Values:Training_Completed_Date__c');
        
        System.Debug('Objects are identical deferring update');
        return false;                            
    }
 
    /* 
      Static handlers for the future calls will always follow the same pattern
         public static handler that is called 
            private static future handler that is called from the public one ONLY if not Running tests, that subsequently 
            private static handler that is called from the public one (and the future one) to peform the work - is called also when running tests
            
            
            Firstly Cases ---> Opportunity sync
    */
    public static void AfterCaseUpdates(list<string> caseList){
        if (test.IsRunningTest() && forceFutureCalls) {AfterCaseUpdates_Execution(caseList); } else {AfterCaseUpdates_Future(caseList);}
    }
    
    @Future
    private static void AfterCaseUpdates_Future( list<string> oppList )
    {
        AfterCaseUpdates_Execution(oppList);
    }

    private static integer AfterCaseUpdates_ExecutionCount = 0;
    private static void AfterCaseUpdates_Execution( list<string> oppList )
    {
        AfterCaseUpdates_ExecutionCount++;
        System.Debug('WARNING COUNT IS [' + AfterCaseUpdates_ExecutionCount + ']. The following cases require sync:' + oppList);
        
        List<Opportunity> updateOpp = new List<opportunity>();
        for( Case c : [SELECT
                            Actual_Development_Completed__c,
                            Actual_Live_Testing_Completed__c,
                            Actual_Planning_and_Prep_Completed__c,
                            Actual_Production_Cut_Over_Date__c,
                            Actual_UAT_Completed__c,
                            CaseNumber,
                            Closed_Lost_Terminated_Reason__c,
                            Current_Activity__c,
                            Delivery_Category_Benchmark_Days__c,
                            Delivery_Category_Benchmark_Man_Hours__c,
                            Delivery_Category__c,
                            Delivery_Implementation_Start_Date__c,
                            Delivery_Phase__c,
                            Dormant_Category__c,
                            Dormant_End_Date__c,
                            Dormant_Historical_Notes__c,
                            Dormant_Reason__c,
                            Current_Dormant_Reason_Picklist__c,
                            Dormant_Start_Date__c,
                            Enter_Pre_Kick_off_Quest_Completed_Date__c,
                            Estimated_Completion_Date__c,
                            Funding_Confirmed__c, 
                            Funding_Task_Completed__c,
                            Implementation_Complete_Date__c,
                            OwnerId,
                            Phase_2_VAN_Training_Completed_Date__c,
                            Related_Delivery_Opportunity__c,
                            Status,
                            Total_Delivery_Effort_Time_hours__c,
                            Total_Dormant_Time_Days__c,
                            Total_Dormant_Time_hours__c,
                            Training_Booking_Created__c,
                            Training_Completed_Date__c,
                            Related_Delivery_Opportunity__r.Completed_Date__c,
                            Related_Delivery_Opportunity__r.Current_Activity__c,
                            Related_Delivery_Opportunity__r.Current_Dormant_Reason__c,
                            Related_Delivery_Opportunity__r.Current_Dormant_Reason_Picklist__c,
                            Related_Delivery_Opportunity__r.Current_Dormant_Start_Date__c,
                            Related_Delivery_Opportunity__r.Delivery_Category_Benchmark_Days__c,
                            Related_Delivery_Opportunity__r.Delivery_Category_Benchmark_Man_Hours__c,
                            Related_Delivery_Opportunity__r.Delivery_Category_Name__c,
                            Related_Delivery_Opportunity__r.Delivery_Owner__c,
                            Related_Delivery_Opportunity__r.Delivery_Phase__c,
                            Related_Delivery_Opportunity__r.Delivery_Status__c,
                            Related_Delivery_Opportunity__r.Delivery_Ticket_Number__c,
                            Related_Delivery_Opportunity__r.Dormant_Category__c,
                            Related_Delivery_Opportunity__r.Estimated_Completion_Date__c,
                            Related_Delivery_Opportunity__r.Funds_received__c,
                            Related_Delivery_Opportunity__r.Hours_Man_Effort_To_Date__c,
                            Related_Delivery_Opportunity__r.Implementation_Start_Date__c,
                            Related_Delivery_Opportunity__r.Name, 
                            Related_Delivery_Opportunity__r.Phase_0_Pre_Implement_Completed_Date__c,
                            Related_Delivery_Opportunity__r.Phase_1_Planning_Prep_Completed_Date__c,
                            Related_Delivery_Opportunity__r.Phase_1_Setup_and_Conf_Completed_Date__c,
                            Related_Delivery_Opportunity__r.Phase_2_Development_Completed_Date__c,
                            Related_Delivery_Opportunity__r.Phase_2_VAN_Training_Completed_Date__c,
                            Related_Delivery_Opportunity__r.Phase_3_Funding_Completed_Date__c,
                            Related_Delivery_Opportunity__r.Phase_3_UAT_Completed_Date__c,
                            Related_Delivery_Opportunity__r.Phase_4_Live_Testing__c,
                            Related_Delivery_Opportunity__r.Phase_5_Prod_Cut_Over_Completed_Date__c,
                            Related_Delivery_Opportunity__r.Total_Dormant_Duration__c,
                            Related_Delivery_Opportunity__r.Won_Lost_Reason__c
                   FROM Case 
                   WHERE Id in :oppList AND Related_Delivery_Opportunity__c <> null ]){

                 Boolean updateRequired = false;
                 Opportunity o = new Opportunity( Id = c.Related_Delivery_Opportunity__c );
                 if (hasChanged(c.Related_Delivery_Opportunity__r.Delivery_Ticket_Number__c,c.CaseNumber)){
                     o.Delivery_Ticket_Number__c = c.CaseNumber;
                     updateRequired = true;
                 }
                 if (hasChanged(c.Related_Delivery_Opportunity__r.Funds_received__c,c.Funding_Confirmed__c)){
                     o.Funds_received__c = c.Funding_Confirmed__c;
                     updateRequired = true;
                 }
                 if (hasChanged(c.Related_Delivery_Opportunity__r.Delivery_Phase__c,c.Delivery_Phase__c)){
                     o.Delivery_Phase__c = c.Delivery_Phase__c;
                     updateRequired = true;
                 }
                 if (hasChanged(c.Related_Delivery_Opportunity__r.Current_Activity__c,c.Current_Activity__c)){
                     o.Current_Activity__c = c.Current_Activity__c;
                     updateRequired = true;
                 }
                 if (hasChanged(c.Related_Delivery_Opportunity__r.Won_Lost_Reason__c,c.Closed_Lost_Terminated_Reason__c)){
                     o.Won_Lost_Reason__c = c.Closed_Lost_Terminated_Reason__c;
                     updateRequired = true;
                 }
                 if (hasChanged(c.Related_Delivery_Opportunity__r.Delivery_Owner__c,c.OwnerId)){
                    //*** SF-1669: Set Opp Owner ONLY if the Case Owner is a user
                    if ( ((string)c.OwnerId).startsWith('005')) {
                         o.Delivery_Owner__c = c.OwnerId;
                         updateRequired = true;
                    }
                 }
                 if (hasChanged(c.Related_Delivery_Opportunity__r.Implementation_Start_Date__c,c.Delivery_Implementation_Start_Date__c)){
                     o.Implementation_Start_Date__c = c.Delivery_Implementation_Start_Date__c;
                     updateRequired = true;
                 }
                 if (hasChanged(c.Related_Delivery_Opportunity__r.Completed_Date__c,c.Implementation_Complete_Date__c)){
                     o.Completed_Date__c = c.Implementation_Complete_Date__c;
                     updateRequired = true;
                 }
                 if (hasChanged(c.Related_Delivery_Opportunity__r.Delivery_Category_Benchmark_Days__c,c.Delivery_Category_Benchmark_Days__c)){
                     o.Delivery_Category_Benchmark_Days__c = c.Delivery_Category_Benchmark_Days__c;
                     updateRequired = true;
                 }
                 if (hasChanged(c.Related_Delivery_Opportunity__r.Delivery_Category_Name__c,c.Delivery_Category__c)){
                     o.Delivery_Category_Name__c = c.Delivery_Category__c;
                     updateRequired = true;
                 }
                 if (hasChanged(c.Related_Delivery_Opportunity__r.Current_Dormant_Reason__c,c.Dormant_Reason__c)){
                     o.Current_Dormant_Reason__c = c.Dormant_Reason__c;
                     updateRequired = true;
                 }
                 if (hasChanged(c.Related_Delivery_Opportunity__r.Current_Dormant_Reason_Picklist__c,c.Current_Dormant_Reason_Picklist__c)){
                     o.Current_Dormant_Reason_Picklist__c = c.Current_Dormant_Reason_Picklist__c;
                     updateRequired = true;
                 }                 
                 if (hasChanged(c.Related_Delivery_Opportunity__r.Current_Dormant_Start_Date__c,c.Dormant_Start_Date__c)){
                     o.Current_Dormant_Start_Date__c = c.Dormant_Start_Date__c;
                     updateRequired = true;
                 }
                 if (hasChanged(c.Related_Delivery_Opportunity__r.Dormant_Category__c,c.Dormant_Category__c)){
                     o.Dormant_Category__c = c.Dormant_Category__c;
                     updateRequired = true;
                 }
                 if (hasChanged(c.Related_Delivery_Opportunity__r.Total_Dormant_Duration__c,c.Total_Dormant_Time_Days__c)){
                     o.Total_Dormant_Duration__c = c.Total_Dormant_Time_Days__c;
                     updateRequired = true;
                 }
                 if (hasChanged(c.Related_Delivery_Opportunity__r.Phase_1_Planning_Prep_Completed_Date__c,c.Actual_Planning_and_Prep_Completed__c)){
                     o.Phase_1_Planning_Prep_Completed_Date__c = c.Actual_Planning_and_Prep_Completed__c;
                     updateRequired = true;
                 }
                 if (hasChanged(c.Related_Delivery_Opportunity__r.Phase_2_Development_Completed_Date__c,c.Actual_Development_Completed__c)){
                     o.Phase_2_Development_Completed_Date__c = c.Actual_Development_Completed__c;
                     updateRequired = true;
                 }
                 if (hasChanged(c.Related_Delivery_Opportunity__r.Phase_3_UAT_Completed_Date__c,c.Actual_UAT_Completed__c)){
                     o.Phase_3_UAT_Completed_Date__c = c.Actual_UAT_Completed__c;
                     updateRequired = true;
                 }
                 if (hasChanged(c.Related_Delivery_Opportunity__r.Phase_4_Live_Testing__c,c.Actual_Live_Testing_Completed__c)){
                     o.Phase_4_Live_Testing__c = c.Actual_Live_Testing_Completed__c;
                     updateRequired = true;
                 }
                 if (hasChanged(c.Related_Delivery_Opportunity__r.Phase_5_Prod_Cut_Over_Completed_Date__c,c.Actual_Production_Cut_Over_Date__c)){
                     o.Phase_5_Prod_Cut_Over_Completed_Date__c = c.Actual_Production_Cut_Over_Date__c;
                     updateRequired = true;
                 }
                 if (hasChanged(c.Related_Delivery_Opportunity__r.Estimated_Completion_Date__c,c.Estimated_Completion_Date__c)){
                     o.Estimated_Completion_Date__c = c.Estimated_Completion_Date__c;
                     updateRequired = true;
                 }
                 if (hasChanged(c.Related_Delivery_Opportunity__r.Delivery_Status__c,c.Status)){
                     o.Delivery_Status__c = c.Status;
                     updateRequired = true;
                 }
                 if (hasChanged(c.Related_Delivery_Opportunity__r.Delivery_Category_Benchmark_Man_Hours__c,c.Delivery_Category_Benchmark_Man_Hours__c)){
                     o.Delivery_Category_Benchmark_Man_Hours__c = c.Delivery_Category_Benchmark_Man_Hours__c;
                     updateRequired = true;
                 }
                 if (hasChanged(c.Related_Delivery_Opportunity__r.Phase_0_Pre_Implement_Completed_Date__c,c.Delivery_Implementation_Start_Date__c)){
                     o.Phase_0_Pre_Implement_Completed_Date__c = c.Delivery_Implementation_Start_Date__c;
                     updateRequired = true;
                 }
                 if (hasChanged(c.Related_Delivery_Opportunity__r.Phase_1_Setup_and_Conf_Completed_Date__c,c.Training_Booking_Created__c)){
                     o.Phase_1_Setup_and_Conf_Completed_Date__c = c.Training_Booking_Created__c;
                     updateRequired = true;
                 }
                 if (hasChanged(c.Related_Delivery_Opportunity__r.Phase_2_VAN_Training_Completed_Date__c,c.Phase_2_VAN_Training_Completed_Date__c)){
                     o.Phase_2_VAN_Training_Completed_Date__c = c.Phase_2_VAN_Training_Completed_Date__c;
                     updateRequired = true;
                 }
                 if (hasChanged(c.Related_Delivery_Opportunity__r.Phase_3_Funding_Completed_Date__c,c.Funding_Task_Completed__c)){
                     o.Phase_3_Funding_Completed_Date__c = c.Funding_Task_Completed__c;
                     updateRequired = true;
                 }
                 if (hasChanged(c.Related_Delivery_Opportunity__r.Hours_Man_Effort_To_Date__c,c.Total_Delivery_Effort_Time_hours__c)){
                     o.Hours_Man_Effort_To_Date__c = c.Total_Delivery_Effort_Time_hours__c;
                     updateRequired = true;
                 }
                 if (updateRequired){
                    System.Debug('The following fields have been modified on the Opportunity, a sync is required :' + o);
                    updateOpp.add(o);
                 }
        }
        if (!updateOpp.isEmpty()) update updateOpp;
    }
    
     /*
            Task Updates - Dormant and terminated
    */
    public static void CloseRelatedTasks(list<string> caseList ){
        if (test.IsRunningTest() && forceFutureCalls) {UpdateTasks_Execution('Terminated', caseList);} else {UpdateTasks_Future('Terminated', caseList);}
    }
    public static void DormantTasksOn(list<string> caseList ){
        if (test.IsRunningTest() && forceFutureCalls) {UpdateTasks_Execution('Deferred', caseList);} else {UpdateTasks_Future('Deferred', caseList);}
    }
    public static void DormantTasksOff(list<string> caseList ){
        if (test.IsRunningTest() && forceFutureCalls) {UpdateTasks_Execution('Not Started', caseList);} else {UpdateTasks_Future('Not Started', caseList);}
    }

    @Future
    private static void UpdateTasks_Future(string Status, list<string> caseList )
    {
        UpdateTasks_Execution(Status, caseList );
    }

    private static integer UpdateTasks_ExecutionCount = 0;
    private static void UpdateTasks_Execution( string Status, list<string> caseList )
    {
        UpdateTasks_ExecutionCount++;
        System.Debug('WARNING COUNT IS [' + UpdateTasks_ExecutionCount + ']. The following cases require tasks to be updated to "' + Status + '":' + caseList);

        List<Process_Task__c> AllTasks = [SELECT Id, Status__c FROM Process_Task__c WHERE Delivery_Ticket__c in :caseList and Status__c != 'Completed' and Status__c != 'Terminated'];
        for( Process_Task__c pt: AllTasks){
            pt.Status__c = Status;
            if ( Status == 'Deferred' ) pt.Due_Date__c = date.today().AddMonths(12);
            if ( Status == 'In Progress') pt.Due_Date__c = date.today();
        }
        update AllTasks;
    }
    
    /*  
        Account ---> Case
    */
     public static void AccountIsTransacting(list<string> updateTicketsList){
        if (test.IsRunningTest() && forceFutureCalls) {AccountIsTransacting_Execution(updateTicketsList);} else {AccountIsTransacting_Future(updateTicketsList);}
    }
    
    @Future
    private static void AccountIsTransacting_Future( list<string> updateTicketsList )
    {
        AccountIsTransacting_Execution(updateTicketsList);
    }
    
    private static integer AccountIsTransacting_ExecutionCount = 0;
    private static void AccountIsTransacting_Execution( list<string> updateTicketsList )
    {
        AccountIsTransacting_ExecutionCount++;
        System.Debug('WARNING COUNT IS [' + AccountIsTransacting_ExecutionCount + ']. The following Accounts require updates applied to their cases ' + updateTicketsList);

        List<Case> DeliveryTicketList = [SELECT Id FROM Case WHERE (AccountId in :updateTicketsList) AND 
                                                (Delivery_Type__c = 'Delivery - API' OR Delivery_Type__c = 'Delivery - Desktop' OR Delivery_Phase__c = 'Unassigned Delivery') 
                                                AND (Status != 'Terminate') AND (Client_Is_Transacting__c = false or Client_Is_Transacting__c = null)];
        for(Case c: DeliveryTicketList )
            c.Client_Is_Transacting__c = true;
        if (!deliveryTicketList.isEmpty()) update DeliveryTicketList;   
    }   


    //*** SF-1569: Moved the setting the Ownership to this future call due to Toom Many SOQL 101 errors.
    /*  
        Reassign Ownership of Opportunity and Qualify Opportunity Tasks when Account Owner changes
        Called from Account_after.trigger
    */

     public static void ChangeOppTaskOwnership(Id updateTasksList, Id theOwner){
        if (test.IsRunningTest() && forceFutureCalls) {ChangeOppTaskOwnership_Execution(updateTasksList, theOwner);} else {ChangeOppTaskOwnership_Future(updateTasksList, theOwner);}
    }
    
    @Future
    private static void ChangeOppTaskOwnership_Future( Id updateTasksList, Id theOwner)
    {
        ChangeOppTaskOwnership_Execution(updateTasksList, theOwner);
    }

    private static integer ChangeOppTaskOwnership_ExecutionCount = 0;
    private static void ChangeOppTaskOwnership_Execution( Id updateTasksList, Id theOwner )
    {
        ChangeOppTaskOwnership_ExecutionCount++;
        System.Debug('WARNING COUNT IS [' + ChangeOppTaskOwnership_ExecutionCount + ']. The following Account requires updates applied to their Opportunity and Opportunity Task owners ' + updateTasksList);


        List<Opportunity> oppList = [SELECT Id, OwnerId FROM Opportunity WHERE AccountId = :updateTasksList];                                

        for(Opportunity ol: oppList )
            ol.OwnerId = theOwner;
        if (!oppList.isEmpty()) update oppList;   


        List<Process_Task__c> taskList = [select Id from Process_Task__c
                                    where Opportunity__c in (select Id from Opportunity where AccountId = :updateTasksList) 
                                    and Record_Type__c = 'Opportunity_Qualify_Opportunity' and Status__c <> 'Completed'];

        for(Process_Task__c t: taskList )
            t.OwnerId = theOwner;
        if (!taskList.isEmpty()) update taskList;   

    }   




    ////*** SF-1578
    ///*  
    //    When Account First Transaction date is set copy detail from the opportunity to the Account.
    //    Code needs to go here as it references values set by WF on the opportunity.
    //    Called from Account_before.trigger
    //*/

    //public static void setAccountForecastDetail(Id theAccount){
    //    if (test.IsRunningTest() && forceFutureCalls) {setAccountForecastDetail_Execution(theAccount);} else {setAccountForecastDetail_Future(theAccount);}
    //}
    
    //@Future
    //private static void setAccountForecastDetail_Future( Id theAccount)
    //{
    //    setAccountForecastDetail_Execution(theAccount);
    //}

    //private static integer setAccountForecastDetail_ExecutionCount = 0;
    //private static void setAccountForecastDetail_Execution( Id theAccount )
    //{
    //    setAccountForecastDetail_ExecutionCount++;
    //    System.Debug('WARNING COUNT IS [' + setAccountForecastDetail_ExecutionCount + ']. The following Account requires updates to its forecast detail. ID =  ' + theAccount);

    //    List<Account> accountToUpdate = new List<Account>();

    //    List<Opportunity> aOppsList = [select Id, in_year_gdv__c, attainable_ttv_monthly__c from Opportunity 
    //                                        where AccountId = :theAccount and StageName = '4. Delivery Complete / GDV Ramp Up' LIMIT 1];
    //    for(Opportunity aol: aOppsList ) {

    //        account UpdateAccount = new Account(Id = theAccount);
    //        UpdateAccount.Expected_in_Year_GDV__c = aol.in_year_gdv__c;
    //        UpdateAccount.Expected_Monthly_GDV__c = aol.attainable_ttv_monthly__c;            
    //        accountToUpdate.add(UpdateAccount);
    //    }

    //    if (!accountToUpdate.isEmpty()) update accountToUpdate;   

    //}   


    ////*** SF-1578
      
    //    When GDV is modified on an Opportunity copy detail from the opportunity to the Account 
    //    if the First Transaction Date has been set on the associated Account.
    //    Code needs to go here as it references values set by WF on the opportunity.
    //    Called from Opportunity_After.trigger
    

    //public static void setAccountForecastDetailFromOpp(Id theOpp){
    //    if (test.IsRunningTest() && forceFutureCalls) {setAccountForecastDetailFromOpp_Execution(theOpp);} else {setAccountForecastDetailFromOpp_Future(theOpp);}
    //}
    
    //@Future
    //private static void setAccountForecastDetailFromOpp_Future( Id theOpp)
    //{
    //    setAccountForecastDetailFromOpp_Execution(theOpp);
    //}

    //private static integer setAccountForecastDetailFromOpp_ExecutionCount = 0;
    //private static void setAccountForecastDetailFromOpp_Execution( Id theOpp )
    //{
    //    setAccountForecastDetailFromOpp_ExecutionCount++;
    //    System.Debug('WARNING COUNT IS [' + setAccountForecastDetailFromOpp_ExecutionCount + ']. The following Opportunity requires updates to its Accounts forecast detail. ID =  ' + theOpp);

    //    List<Account> accountToUpdate = new List<Account>();

    //    List<Opportunity> aOppsList = [select Id, in_year_gdv__c, attainable_ttv_monthly__c, AccountId, Account.First_Transaction_Date__c from Opportunity 
    //                                        where Id = :theOpp and StageName = '4. Delivery Complete / GDV Ramp Up' LIMIT 1];

    //    for(Opportunity aol: aOppsList ) {
    //        if (aol.Account.First_Transaction_Date__c != null) {
    //            account UpdateAccount = new Account(Id = aol.AccountId);
    //            UpdateAccount.Expected_in_Year_GDV__c = aol.in_year_gdv__c;
    //            UpdateAccount.Expected_Monthly_GDV__c = aol.attainable_ttv_monthly__c;            
    //            accountToUpdate.add(UpdateAccount);         
    //        }
    //    }

    //    if (!accountToUpdate.isEmpty()) update accountToUpdate;   

    //}   


}