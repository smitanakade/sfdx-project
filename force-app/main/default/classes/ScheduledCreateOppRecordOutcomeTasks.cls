global class ScheduledCreateOppRecordOutcomeTasks implements Schedulable {

    global void execute(SchedulableContext sc) {
        List<Process_Task__c> oppTaskList = new List<Process_Task__c>();
        List<Opportunity> oppUpdates = new List<Opportunity>();
        Map<string,RecordType> recTypeMap = FutureCalls.mapRecordTypes('Process_Task__c');
        
        Date today_plus_1month = date.today().addDays(30);
        for (Opportunity opp : [SELECT Id, OwnerId, Account_Name__c, Delivery_type__c, ECN__c, Opportunity_Record_Outcome_Due__c, Opportunity_Record_Outcome_Created__c
                                FROM Opportunity 
                                WHERE Opportunity_Record_Outcome_Due__c = :today_plus_1month]) {
            if (opp.Opportunity_Record_Outcome_Created__c == null) {
                oppTaskList.add(
                    PT_Utils.createOpportunityPT(opp.OwnerId, recTypeMap.get('Opportunity_Record_Opportunity_Outcome').Id, opp.Account_Name__c, 
                                                 opp.Delivery_type__c, opp.ECN__c, 'Opportunity - Record Opportunity Outcome', 
                                                 opp.Id, opp.Opportunity_Record_Outcome_Due__c)
                );
                opp.Opportunity_Record_Outcome_Created__c = System.today();
                opp.Opportunity_Record_Outcome_Name__c = 'Opportunity - Record Opportunity Outcome';
                oppUpdates.add(opp);
            }
        }
        if (!oppTaskList.isEmpty()) insert oppTaskList;
        if (!oppUpdates.isEmpty()) update oppUpdates;
    }
    
    public static string defaultSchedule = '0 0 * * * ?';
   
    public static void schedule() {
        ScheduledCreateOppRecordOutcomeTasks.schedule(defaultSchedule);
    }

    public static void schedule(string sch) {
        ScheduledCreateOppRecordOutcomeTasks m = new ScheduledCreateOppRecordOutcomeTasks();
        system.schedule('ScheduledCreateRecordOppOutcomeTasks', sch, m);
    }

}