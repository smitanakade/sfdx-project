global class StartOfMonthTasks implements Schedulable {
   /*
        If today is Start of Month then;
            For all Opportunities that are not Closed update the fields as follows 
                Opp.SOM_Estimated_Completion__c = Opp.Estimated_Completion_Date__c;
                Opp.SOM_Estimated_Annual_GDV__c = Opp.Attainable_TTV_annual__c;
             
   */
   
    public boolean overrideDate = false;
   
    global void execute(SchedulableContext SC){

        List<Delivery_Dormant_History__c> dormantHistoryList = [select id, Dormant_End_Date__c, Dormant_Reason__c from Delivery_Dormant_History__c where Dormant_End_Date__c = :date.today() and Related_Delivery_Ticket__r.Status = 'Dormant']; 
        Process_Log__c log = new Process_Log__c(Process_Name__c = 'StartOfMonthTasks Scheduled Job');
        log.Process_Message__c = 'Processing records: ';
        for (Delivery_Dormant_History__c dH : dormantHistoryList) {
            log.Process_Message__c += ' ' + dH.Id + ',';
        }
        insert log;

        try {
            for(Delivery_Dormant_History__c dormantHistory : dormantHistoryList ){
                dormantHistory.Activated_Automatically__c = true;
                dormantHistory.Dormant_Reason__c = (string.IsBlank(dormantHistory.Dormant_Reason__c) ? '' : dormantHistory.Dormant_Reason__c + '\r\n') + 'Dormant period expired, reactivating delivery automatically';
            }
            if (!dormantHistoryList.isEmpty()) update dormantHistoryList;
            log.Completed_Successfully__c = true;
            update log;
        } catch (Exception e) {
            log.trace__c = 'Type: ' + e.getTypeName() + '\n' + 'Cause: ' + e.getCause() + '\n' + 'Message: '
                           + e.getMessage() + '\n' + 'Line #: ' + e.getLineNumber() + '\n' + e.getStackTraceString();
            log.process_failed__c = true;
            update log;
        }

        if ( date.today().day() == 1 || overrideDate ){
            Process_Log__c log2 = new Process_Log__c(Process_Name__c = 'StartOfMonthTasks Scheduled Job');
            log2.Process_Message__c = 'Running start of month process';
            insert log2;
            try {
                //*** SF-1595: Modified the select 
                List<Opportunity> opportunities = new List<Opportunity>();
                for (Opportunity Opp : [select SOM_Estimated_Completion__c, Estimated_Completion_Date__c, SOM_Estimated_Annual_GDV__c, Attainable_TTV_annual__c 
                                     from Opportunity where IsClosed = false and (Compare_Completion_Date__c = 'false' or Compare_Annual_GDV__c = 'false')]) {
                    Opp.SOM_Estimated_Completion__c = Opp.Estimated_Completion_Date__c;
                    Opp.SOM_Estimated_Annual_GDV__c = Opp.Attainable_TTV_annual__c;
                    opportunities.add( Opp );

                    if ( opportunities.size() >= 100)
                    {
                        update opportunities;
                        opportunities.clear();
                    }

                }
         
                if (!opportunities.isEmpty()) update opportunities;
                log2.Completed_Successfully__c = true;
                update log2;
            } catch (Exception e) {
                log2.trace__c = 'Type: ' + e.getTypeName() + '\n' + 'Cause: ' + e.getCause() + '\n' + 'Message: '
                               + e.getMessage() + '\n' + 'Line #: ' + e.getLineNumber() + '\n' + e.getStackTraceString();
                log2.process_failed__c = true;
                update log2;
            }

        }
        
    }
   
    public static string defaultSchedule = '0 0 1 ? * *';
   
    public static void schedule(){
        StartOfMonthTasks.schedule(defaultSchedule);
    }
   
    public static void Run(){
        Run(false);
    }

    public static void Run(boolean forceCreationofTasks){
        StartOfMonthTasks tasks = new StartOfMonthTasks();
        tasks.overrideDate = forceCreationofTasks;
        tasks.execute(null);
    }

    public static void schedule(string sch){
        StartOfMonthTasks m = new StartOfMonthTasks();
        system.schedule('Start of Month Tasks', sch, m);    
    }
 
}