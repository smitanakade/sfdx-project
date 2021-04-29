global class ScheduledDDBusinessHourUpdates implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        CalculateBusinessHours.updateDDBusinessHoursFuture(200, 0);
        CalculateBusinessHours.updateDDBusinessHoursFuture(200, 200);
        CalculateBusinessHours.updateDDBusinessHoursFuture(200, 400);
        CalculateBusinessHours.updateDDBusinessHoursFuture(200, 600);
    }
    
    public static string defaultSchedule = '0 0 * * * ?';
   
    public static void schedule() {
        ScheduledDDBusinessHourUpdates.schedule(defaultSchedule);
    }

    public static void schedule(string sch) {
        ScheduledDDBusinessHourUpdates m = new ScheduledDDBusinessHourUpdates();
        system.schedule('Update Reg DD Business Hours', sch, m);
    }

}