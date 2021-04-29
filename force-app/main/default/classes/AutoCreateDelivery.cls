global class AutoCreateDelivery {

    @InvocableMethod
    public static void AutoCreateDeliveryTicket (List<Id> accIds) {

System.debug('>>>>>>>>>>>>>>>> In the class');        
        List<Opportunity> OpportunityList = new LIST<Opportunity>();
        List<Case> newDeliveryList = new List<Case>();
        Id queueId;
        Id recTypeId;
        Map<string,RecordType> caseRecTypeMap = FutureCalls.mapRecordTypes('Case');
        String DelPhase;
		
        //SF-5267 Combining Delivery Queues to one Global
        //Group APACQueue = [select Id from Group where Name = 'APAC Delivery Queue' and Type = 'Queue'];
        //Group EMEAQueue = [select Id from Group where Name = 'EMEA/Americas Delivery Queue' and Type = 'Queue'];   
        Group deliveryQueue = [SELECT Id 
                              FROM Group
                              WHERE Name = 'Global Delivery Queue'
                              AND Type = 'Queue'
                              LIMIT 1];
                      
        for (Opportunity o : [  
                SELECT Id, Delivery_type__c, Name, Region__c, AccountId
                FROM Opportunity 
                WHERE AccountId IN :accIds 
                AND StageName IN ('1. Prospect', '2. Sales Qualified', '3. Contracted') 
                AND (Delivery_type__c = 'Delivery - API' OR Delivery_type__c = 'Delivery - Desktop') ] ) {

System.debug('>>>>>>>>>>>>>>>> Found Opp');        

                List<Case> existingDeliveryList = [ 
                    SELECT Id 
                    FROM Case 
                    WHERE Related_Delivery_Opportunity__c = :o.Id 
                    AND Delivery_Ticket__c = true];

                if (existingDeliveryList.isEmpty()) {
System.debug('>>>>>>>>>>>>>>>> No DT');        
					//SF-5267 Combining Delivery Queues to one Global
                    //queueId = o.Region__c == 'APAC' ? APACQueue.Id : EMEAQueue.Id;
                    queueId = deliveryQueue.Id;
                    recTypeId = o.Delivery_type__c == 'Delivery - API' ? caseRecTypeMap.get('API_Delivery_Phase_0_Record_Type').Id : caseRecTypeMap.get('Desktop_Delivery_Phase_0_Record_Type').Id;

                    DelPhase = o.Delivery_type__c == 'Delivery - API' ? 'Unassigned Delivery' : '0 - Pre-Implementation Kick-off';

                    // Create a Delivery Ticket
                    newDeliveryList.add(new Case(
                        Related_Delivery_Opportunity__c = o.Id, 
                        AccountId = o.AccountId,
                        Priority = 'Should Have',
                        Delivery_Phase__c = DelPhase,
                        RecordTypeId = recTypeId,
                        OwnerId = queueId,
                        Delivery_Type__c = o.Delivery_type__c,
                        Subject = 'Delivery - ' + o.Name)); 

                }
        }

        if (!newDeliveryList.isEmpty()) insert newDeliveryList;

    }
}