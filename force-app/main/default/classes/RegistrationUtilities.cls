global class RegistrationUtilities {
    
    /*----------------------------------------------------------------------------------
    /   This method is called whenever a Re-DD is started.
    /   It will loop through and set all Active records to inactive on the following Objects:
    /       # DD_Time_Out__c
    /       # Due_Diligence_Approval__c
    /       # Due_Diligence_Escalation__c
    /----------------------------------------------------------------------------------*/
    @InvocableMethod
    public static void ResetInactives (List<Id> regIds) {

        // Store th Rego Revison number for comparison when resetting the Risk Rating Evidence records
        Decimal DDRev = [SELECT DD_Revision__c FROM Registration__c WHERE Id IN :regIds LIMIT 1].DD_Revision__c;

        // Reset all Active DD Time Out records to Inactive
        LIST<DD_Time_Out__c> lstTO = new LIST<DD_Time_Out__c>();
        for (DD_Time_Out__c cntTO : [SELECT Id, Active__c FROM DD_Time_Out__c WHERE Active__c = true AND Registration__c IN :regIds]) {
            cntTO.Active__c = false;
            lstTO.add(cntTO);
        }
        if (!lstTO.isEmpty()) update lstTO;
        

        // Reset all Active DD Approval records to Inactive
        LIST<Due_Diligence_Approval__c> lstDDA = new LIST<Due_Diligence_Approval__c>();
        for (Due_Diligence_Approval__c cntDDA : [SELECT Id, Active__c FROM Due_Diligence_Approval__c WHERE Active__c = true AND Registration__c IN :regIds]) {
            cntDDA.Active__c = false;
            lstDDA.add(cntDDA);
        }
        if (!lstDDA.isEmpty()) update lstDDA;
        

        // Reset all Active DD Escallation records to Inactive
        LIST<Due_Diligence_Escalation__c> lstDDE = new LIST<Due_Diligence_Escalation__c>();
        for (Due_Diligence_Escalation__c cntDDE : [SELECT Id, Active__c FROM Due_Diligence_Escalation__c WHERE Active__c = true AND Registration__c IN :regIds]) {
            cntDDE.Active__c = false;
            lstDDE.add(cntDDE);
        }
        if (!lstDDE.isEmpty()) update lstDDE;

        // Reset all Active Risk Rating Evidence records to Inactive when the DD Revision does NOT match that on the Registration.
        LIST<Risk_Rating_Evidence__c> lstRRE = new LIST<Risk_Rating_Evidence__c>();
        for (Risk_Rating_Evidence__c cntRRE : [SELECT Id, Active__c, DD_Revision__c FROM Risk_Rating_Evidence__c WHERE Active__c = true AND Registration__c IN :regIds]) {
            if (cntRRE.DD_Revision__c <> DDRev) {
                cntRRE.Active__c = false;
                lstRRE.add(cntRRE);                
            }
        }
        if (!lstRRE.isEmpty()) update lstRRE;
        
    } // End Method



    /*----------------------------------------------------------------------------------
    /   This method is called whenever a Snapshot needs to be generated.
    /   It copies fields and all applicatable relationships from Rego to Snaphot.
    /----------------------------------------------------------------------------------*/
    webservice static void CreateRegoSnapshot (Id theRegId) {

        // Copy the Rego fields to a new Snaphot
        SObject theSnap = CopyObject (theRegId, 'Registration_Snapshot__c', 'recordtypeid,ID');
 
        // Add additional fields and insert the Sanpshot 
        theSnap.put('Registration__c',theRegId);
        insert theSnap;

        // Create all the Snaphot relationships
        CreateSnapshotTentacles (theRegId, theSnap.Id);

    } // End Method



    /*----------------------------------------------------------------------------------
    /   This is a generic function that takes fields from any record and copies
    /   its values to like named fields on another object.
    /
    /   It requires the following parameters:
    /   - The RecordID of the record to be copied
    /   - The name of the Object to be copied to
    /   - A Set containing the names of any fields to be ignored (Still to code)
    /----------------------------------------------------------------------------------*/
    private static SObject CopyObject (Id theSourceId, String theDestination, String setExcluded) {

        // Get the object detail for the Source Object
        DescribeSObjectResult idObject = theSourceId.getSObjectType().getDescribe();
        List<String> idFieldNames = new List<String>( idObject.fields.getMap().keySet() );

        // Obtain the Source Object field values and store in a list. 
        // This data will be copied to the target Object.
        String query =
          ' SELECT ' + String.join( idFieldNames, ',' ) +
          ' FROM ' + idObject.getName() +
          ' WHERE id = :theSourceId ' +
          ' LIMIT 1 ';

        List<SObject> listSourceFields = Database.query( query );

        // Get the object detail for the Target Object
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType destOject = schemaMap.get(theDestination);

        // Obtain the field detail for the Target Object and store in a Map
        Map<String, Schema.SObjectField> mapSnapshotFields = destOject.getDescribe().fields.getMap();

        // Assign the Source Data to an Object so we can reference its fields
        SObject sObj = Database.query( query );

        // Create a new Object of the Target Type. Values will be copied here.
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(theDestination);
        sObject objTarget = targetType.newSObject();


        // Loop through each of the Field Names in the Source Object and if there is a field
        // in the Target Object with the same name, copy the value over.    
        for (String fn : idFieldNames) {
            if (mapSnapshotFields.containsKey(fn) && mapSnapshotFields.get(fn).getDescribe().isUpdateable() && !setExcluded.contains(fn)){
                System.Debug('------------HereWeAre-------------- ' + fn + ' = ' + sObj.get(fn));
                objTarget.put(fn, sObj.get(fn));                
            }
        }

        return objTarget;

    } // End Method



    /*----------------------------------------------------------------------------------
    /   This function adds all the required relationships to a snapshot object.
    /----------------------------------------------------------------------------------*/
    private static void CreateSnapshotTentacles (Id theRegId, Id theSnapshotId) {

        /*----------------------------------------------------------------------------------
        /   Populate the junctions.
        /----------------------------------------------------------------------------------*/

        List<Snapshot_BenOwnr_Association__c> listSnapBO        = new List<Snapshot_BenOwnr_Association__c>();
        List<Snapshot_RegBankAccnt_Association__c> listSnapRBA  = new List<Snapshot_RegBankAccnt_Association__c>();
        List<Snapshot_Director_Association__c> listSnapDir      = new List<Snapshot_Director_Association__c>();
        List<Snapshot_Verification_Association__c> listSnapVer  = new List<Snapshot_Verification_Association__c>();

        // Select Active Beneficial Owners for the Registration and create Junction Object entries
        for(Beneficial_Owner__c benOwns : [Select Id from Beneficial_Owner__c where Registration__c = :theRegId and Active__c = true]){

                listSnapBO.add(new Snapshot_BenOwnr_Association__c(
                                            Registration_Snapshot__c = theSnapshotId,
                                            Beneficial_Owner__c = benOwns.Id));
        }

        // Select Active Bank Accounts for the Registration and create Junction Object entries
        for(Registration_Bank_Account__c bankAcc : [Select Id from Registration_Bank_Account__c where Registration__c = :theRegId and Active__c = true]){

                listSnapRBA.add(new Snapshot_RegBankAccnt_Association__c(
                                            Registration_Snapshot__c = theSnapshotId,
                                            Registration_Bank_Account__c = bankAcc.Id));
        }

        // Select Active Directors for the Registration and create Junction Object entries
        for(Director__c dirs : [Select Id from Director__c where Registration__c = :theRegId and Active__c = true]){

                listSnapDir.add(new Snapshot_Director_Association__c(
                                            Registration_Snapshot__c = theSnapshotId,
                                            Director__c = dirs.Id));
        }

        // Select Verification for the Registration and create Junction Object entries
        for(Verification__c ver : [Select Id from Verification__c where Registration__c = :theRegId and Active__c = true]){

                listSnapVer.add(new Snapshot_Verification_Association__c(
                                            Registration_Snapshot__c = theSnapshotId,
                                            Verification__c = ver.Id));
        }


        if (!listSnapBO.isEmpty())  insert listSnapBO;
        if (!listSnapRBA.isEmpty()) insert listSnapRBA;
        if (!listSnapDir.isEmpty()) insert listSnapDir;
        if (!listSnapVer.isEmpty()) insert listSnapVer;

        /*----------------------------------------------------------------------------------
        /   Populate the lookups.
        /----------------------------------------------------------------------------------*/

        List<DD_Time_Out__c> listDDTO               = new List<DD_Time_Out__c>();
        List<Risk_Rating_Evidence__c> listRRE       = new List<Risk_Rating_Evidence__c>();
        List<Due_Diligence_Approval__c> listDDA     = new List<Due_Diligence_Approval__c>();
        List<Due_Diligence_Escalation__c> listDDE   = new List<Due_Diligence_Escalation__c>();


        // Select DD_Time_Out__c for the Registration and set the lookup to the Snapshot
        for(DD_Time_Out__c DDTO : [Select Id, Registration_Snapshot__c from DD_Time_Out__c where Registration__c = :theRegId and Active__c = true]){
                DDTO.Registration_Snapshot__c = theSnapshotId;
                listDDTO.add(DDTO);
        }

        // Select Risk_Rating_Evidence__c for the Registration and set the lookup to the Snapshot
        for(Risk_Rating_Evidence__c RRE : [Select Id, Registration_Snapshot__c from Risk_Rating_Evidence__c where Registration__c = :theRegId and Active__c = true]){
                RRE.Registration_Snapshot__c = theSnapshotId;
                listRRE.add(RRE);
        }

        // Select Due_Diligence_Approval__c for the Registration and set the lookup to the Snapshot
        for(Due_Diligence_Approval__c DDA : [Select Id, Registration_Snapshot__c from Due_Diligence_Approval__c where Registration__c = :theRegId and Active__c = true]){
                DDA.Registration_Snapshot__c = theSnapshotId;
                listDDA.add(DDA);
        }

        // Select Due_Diligence_Escalation__c for the Registration and set the lookup to the Snapshot
        for(Due_Diligence_Escalation__c DDE : [Select Id, Registration_Snapshot__c from Due_Diligence_Escalation__c where Registration__c = :theRegId and Active__c = true]){
                DDE.Registration_Snapshot__c = theSnapshotId;
                listDDE.add(DDE);
        }

        if (!listDDTO.isEmpty()) update listDDTO;
        if (!listRRE.isEmpty())  update listRRE;
        if (!listDDA.isEmpty())  update listDDA;
        if (!listDDE.isEmpty())  update listDDE;

    } 

}