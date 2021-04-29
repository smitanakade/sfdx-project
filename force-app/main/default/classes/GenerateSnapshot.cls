global without sharing class GenerateSnapshot {

    /*----------------------------------------------------------------------------------
    /   This method is called whenever a Snapshot needs to be generated.
    /   It copies fields and all applicatable relationships from Rego to Snaphot.
    /----------------------------------------------------------------------------------*/
    @InvocableMethod
    public static void CreateRegoSnapshot (List<Id> regIds) {

        String theRegId = regIds[0];

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
        //Map<String, Schema.SObjectField> mapSnapshotFields = destOject.getDescribe().fields.getMap();
        SET<String> snapshotFieldList = new SET<String>();
        for (FieldPermissions fP : [SELECT Id, Field, SObjectType, PermissionsRead, PermissionsEdit 
                                    FROM FieldPermissions WHERE SObjectType = :theDestination AND PermissionsEdit = true
                                    AND parentid in (SELECT id FROM permissionset WHERE PermissionSet.Profile.Name = 'System Administrator (no expiry)')]) {
            snapshotFieldList.add(fP.Field.substringAfter('.').tolowercase());
        }
        system.debug('->0');
        system.debug(snapshotFieldList);
        // Assign the Source Data to an Object so we can reference its fields
        SObject sObj = Database.query( query );

        // Create a new Object of the Target Type. Values will be copied here.
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(theDestination);
        sObject objTarget = targetType.newSObject();

        // Loop through each of the Field Names in the Source Object and if there is a field
        // in the Target Object with the same name, copy the value over.    
        for (String fn : idFieldNames) {
            system.debug('--<<');
            system.debug(fn);
            system.debug(snapshotFieldList.contains(fn));
            if (snapshotFieldList.contains(fn) && !setExcluded.contains(fn)) {
            //if (mapSnapshotFields.containsKey(fn) && mapSnapshotFields.get(fn).getDescribe().isUpdateable() && !setExcluded.contains(fn)) {
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