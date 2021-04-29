global class ParentGDVProcessorScheduler implements Schedulable {
    global void execute (SchedulableContext ctx){
        //execute batch
        Id batchId = Database.executeBatch(new ParentGDVProcessor(),2000);
    }
}