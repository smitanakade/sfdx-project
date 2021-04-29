/* Author : Kishore Potla
 * 
 * Controller class to implement the functionality of the below 3 Access Entitlement Reports 
 *   1. User Access level Report
 *   2. Profile Access level Report
 *   3. Profile Vs UserCount Report.
 *  
*/

public class AccessEntitlementController {
    public List<UserAccessLevel> userAccessLevelList  {set;get;}
    public List<ProfileAccessLevel> profileAccessLevelList  {set;get;}
    public List<PermissionsetAccessLevel> permissionsetList  {set;get;}
    public List<ProfileUserCount> profileUserCountList {set; get;}
    public Map<String, String> permissionsetAssignmentMap {set; get;}
    public Map<id, List<ObjectPermissions>> uIdObjPermsMap = new Map<id, List<ObjectPermissions>>();
    public Boolean isUserReport {set; get;}
    public Boolean isProfileReport {set; get;}
    public Boolean isPermissionsetReport {set; get;}
    public Boolean isPermissionsetAssignmentReport {set; get;}
    public Boolean isProfileUserCountReport {set; get;}    
    
    public AccessEntitlementController(){
        isUserReport = false;
        isProfileReport = false;
        isPermissionsetReport = false;
        isPermissionsetAssignmentReport = false;
        isProfileUserCountReport = false;
    }
    
    /* Method to generate the Profile Access Level Report */
    public void getProfileAccessReport(){
        isUserReport = false;
        isProfileReport = true;
        isPermissionsetReport = false;
        isPermissionsetAssignmentReport = false;
        isProfileUserCountReport = false;
        
        List<PermissionSet> profilePermissionSetList = [SELECT Id, ProfileId, profile.name, profile.UserLicense.name, profile.PermissionsViewAllData, profile.PermissionsModifyAllData, 
                                                                   profile.PermissionsApiEnabled, profile.PermissionsAssignPermissionSets, 
                                                                           profile.PermissionsManageInternalUsers, profile.PermissionsManageIpAddresses, profile.PermissionsManageLoginAccessPolicies, 
                                                                           profile.PermissionsManagePasswordPolicies, profile.PermissionsManageProfilesPermissionsets, profile.PermissionsManageSharing, 
                                                                           profile.PermissionsManageRoles, profile.PermissionsManageUsers,  
                                                                   (SELECT parentid, SobjectType, PermissionsCreate, PermissionsDelete, PermissionsEdit, 
                                                                           PermissionsModifyAllRecords, PermissionsRead, PermissionsViewAllRecords 
                                                                    FROM ObjectPerms 
                                                                    WHERE SobjectType in ('Account', 'Registration__C', 'Lead', 'Opportunity', 'Contact','Case', 'Contract', 'TransactionalData__c')) 
                                                        FROM PermissionSet 
                                                        WHERE profileId in (SELECT id FROM profile) ORDER BY profile.UserLicense.name, profile.name];
        
        profileAccessLevelList = new List<ProfileAccessLevel>();
        for(PermissionSet ps : profilePermissionSetList){
   //         if(ps.ObjectPerms.size() > 0){  //Enable this if condition, If you want to drop the profiles who don't have any access to the selected objects.
                ProfileAccessLevel profileAccessLevelObj = new ProfileAccessLevel();
                SfObjectsAccess sfObjectsAccessObj = new SfObjectsAccess();
                
                profileAccessLevelObj.profileName = ps.profile.name;
                profileAccessLevelObj.userLicenseName = ps.profile.UserLicense.name;
                profileAccessLevelObj.viewAllData = ps.profile.PermissionsViewAllData;
                profileAccessLevelObj.modifyAllData = ps.profile.PermissionsModifyAllData;
                profileAccessLevelObj.apiEnabled = ps.profile.PermissionsApiEnabled;
                profileAccessLevelObj.assignPermissionSets = ps.profile.PermissionsAssignPermissionSets;
                profileAccessLevelObj.manageInternalUsers = ps.profile.PermissionsManageInternalUsers;
                profileAccessLevelObj.manageIpAddresses = ps.profile.PermissionsManageIpAddresses;
                profileAccessLevelObj.manageLoginAccessPolicies = ps.profile.PermissionsManageLoginAccessPolicies;
                profileAccessLevelObj.managePasswordPolicies = ps.profile.PermissionsManagePasswordPolicies;
                profileAccessLevelObj.manageProfilesPermissionsets = ps.profile.PermissionsManageProfilesPermissionsets;
                profileAccessLevelObj.manageSharing = ps.profile.PermissionsManageSharing;
                profileAccessLevelObj.manageRoles = ps.profile.PermissionsManageRoles;
                profileAccessLevelObj.manageUsers = ps.profile.PermissionsManageUsers;
                
                sfObjectsAccessObj = profileAccessLevelInfoMapping(sfObjectsAccessObj, ps.ObjectPerms);
                profileAccessLevelObj.sfObjectsAccess = sfObjectsAccessObj;
                profileAccessLevelList.add(profileAccessLevelObj);
      //     }
        }
    }
    
    /* Method to generate the Profile Vs UserCount Report */
    public void getProfileVsUsercountReport(){
        isUserReport = false;
        isProfileReport = false;
        isPermissionsetReport = false;
        isPermissionsetAssignmentReport = false;
        isProfileUserCountReport = true;
        
        profileUserCountList = new List<ProfileUserCount>();
        List<AggregateResult> aggrList = [SELECT profile.name profileName, count(id) UserCount FROM user WHERE isactive = true GROUP BY profile.name ];
        for(AggregateResult aggr: aggrList){
            if(String.isBlank((String) aggr.get('profileName') ))
               continue;
            ProfileUserCount profileUserCountObj = new ProfileUserCount();
            profileUserCountObj.profileName = (String) aggr.get('profileName');
            profileUserCountObj.userCount = (Integer) aggr.get('UserCount');
            profileUserCountList.add(profileUserCountObj);
        }
    }
    
    /* Method to generate the Permissionset Access Level Report */
    public void getPermissionsetAccessReport(){
        isUserReport = false;
        isProfileReport = false;
        isPermissionsetReport = true;
        isPermissionsetAssignmentReport = false;
        isProfileUserCountReport = false;
        
		List<ObjectPermissions> ObjectPermissionsList = [SELECT ParentId, Parent.Name, Parent.Label, SobjectType, PermissionsRead, PermissionsCreate, PermissionsEdit, PermissionsDelete, 
            	PermissionsViewAllRecords, PermissionsModifyAllRecords 
            	FROM ObjectPermissions  
            	WHERE ParentId IN (SELECT id FROM PermissionSet  WHERE Profile.Name = '') 
            	];
        
       	Map<String, List<PermissionsetAccessLevel>> permissionsetAccessMap = new Map<String, List<PermissionsetAccessLevel>>();
        for(ObjectPermissions op : ObjectPermissionsList){
            
            if(permissionsetAccessMap.get(op.Parent.Name) != null){
                PermissionsetAccessLevel permissionsetAccessLevelObj = new PermissionsetAccessLevel();
                permissionsetAccessLevelObj.permissionsetName = op.Parent.Name;
                permissionsetAccessLevelObj.permissionsetLabel = ((PermissionSet)op.parent).label; //op.Parent.Label throwing error "Variable 'Label' does not existed". Hence used type conversion procedure. 
                permissionsetAccessLevelObj.sObjectType = op.SobjectType;
                permissionsetAccessLevelObj.objectLabel = getObjLabel(op.SobjectType);
                permissionsetAccessLevelObj.readPerm = op.PermissionsRead;
                permissionsetAccessLevelObj.createPerm = op.PermissionsCreate;
                permissionsetAccessLevelObj.editPerm = op.PermissionsEdit;
                permissionsetAccessLevelObj.deletePerm = op.PermissionsDelete;
                permissionsetAccessLevelObj.viewAllPerm = op.PermissionsViewAllRecords;
                permissionsetAccessLevelObj.modifyAllPerm = op.PermissionsModifyAllRecords;
                
                permissionsetAccessMap.get(op.Parent.Name).add(permissionsetAccessLevelObj);
            }else{
            	PermissionsetAccessLevel permissionsetAccessLevelObj = new PermissionsetAccessLevel();
                List<PermissionsetAccessLevel> permissionsetAccessLevelList = new List<PermissionsetAccessLevel>();
                
                permissionsetAccessLevelObj.permissionsetName = op.Parent.Name;
                permissionsetAccessLevelObj.permissionsetLabel = ((PermissionSet)op.parent).label; //op.Parent.Label throwing error "Variable 'Label' does not existed". Hence used type conversion procedure. 
                permissionsetAccessLevelObj.sObjectType = op.SobjectType;
                permissionsetAccessLevelObj.objectLabel = getObjLabel(op.SobjectType);
                permissionsetAccessLevelObj.readPerm = op.PermissionsRead;
                permissionsetAccessLevelObj.createPerm = op.PermissionsCreate;
                permissionsetAccessLevelObj.editPerm = op.PermissionsEdit;
                permissionsetAccessLevelObj.deletePerm = op.PermissionsDelete;
                permissionsetAccessLevelObj.viewAllPerm = op.PermissionsViewAllRecords;
                permissionsetAccessLevelObj.modifyAllPerm = op.PermissionsModifyAllRecords;
                
                permissionsetAccessLevelList.add(permissionsetAccessLevelObj);
                permissionsetAccessMap.put(op.Parent.Name, permissionsetAccessLevelList);
            }
        }
        
       // permissionsetAccessLevelList = permissionsetAccessMap.values();
        permissionsetList = new List<PermissionsetAccessLevel>();
        for(String permSetName : permissionsetAccessMap.keySet()){
            permissionsetList.addAll(permissionsetAccessMap.get(permSetName));
        }
        System.debug('AccessEntitlementController ##### size of permissionsetList : '+permissionsetList.size() +'\npermissionsetList : '+ permissionsetList);
        
    }
    
     /* Method to generate the Permissionset assignment Report */
    public void getPermissionsetAssignmentReport(){
        isUserReport = false;
        isProfileReport = false;
        isPermissionsetReport = false;
        isPermissionsetAssignmentReport = true;
        isProfileUserCountReport = false;
        
        //SOQL to fetch Permissionset assignments to all ACTIVE users.
        List<PermissionSetAssignment> PermissionSetAssignments = [Select Assignee.IsActive, Assignee.Name, PermissionSet.Label, permissionset.profileid 
				FROM PermissionSetAssignment 
				WHERE assignee.isactive = TRUE 
	  			AND permissionset.profileid = NULL 
				ORDER BY PermissionSet.Label];
        
        permissionsetAssignmentMap = new Map<String, String>();
        String userNamesStr;
        for(PermissionSetAssignment psa : PermissionSetAssignments){
            if(permissionsetAssignmentMap.get(psa.PermissionSet.Label) == null){
                permissionsetAssignmentMap.put(psa.PermissionSet.Label, psa.Assignee.Name);
            }else{
               	userNamesStr = permissionsetAssignmentMap.get(psa.PermissionSet.Label) + ', ' + psa.Assignee.Name;
                permissionsetAssignmentMap.put(psa.PermissionSet.Label, userNamesStr);
            }
        }
     }
    
    /* Method to generate the User Access Level Report */
    public void getUserAccessReport(){
        isUserReport = true;
        isProfileReport = false;
        isPermissionsetReport = false;
        isPermissionsetAssignmentReport = false;
        isProfileUserCountReport = false;
        
        //Fetch active User details: name, profile and role
        Map<id, USER> activeUserMap= new Map<id, User>([SELECT id, Name, Email, Profile.Id, Profile.Name, UserRole.Name FROM USER WHERE isActive = true ORDER BY Profile.Name]);
        
        //Map for <UserId, ProfileId>
        Map<id, id> userToProfileMap = new Map<id, id>();
        for(USER u : activeUserMap.values()){
            userToProfileMap.put(u.id, u.profile.id);
        }
       
        //get Profile information for all users.
        Map<id, list<ObjectPermissions>> profileObjPermMap = new Map<id, list<ObjectPermissions>>();
        List<PermissionSet> profilePermSet = [SELECT Id, ProfileId, (select parentid, SobjectType, PermissionsCreate, PermissionsDelete, PermissionsEdit, PermissionsModifyAllRecords, PermissionsRead, PermissionsViewAllRecords 
                                                                        from ObjectPerms 
                                                                        where SobjectType in ('Account', 'Registration__C', 'Lead', 'Opportunity', 'Contact','Case', 'Contract', 'TransactionalData__c')) 
                                                FROM PermissionSet 
                                                where profileId in :userToProfileMap.values()  ]; 
        for(PermissionSet ps : profilePermSet){
            profileObjPermMap.put(ps.ProfileId, ps.ObjectPerms);
        }
         
        //Get PermissionSet information for all users.
        uIdObjPermsMap = getPermissionSetDetails(activeUserMap.keySet());
        
        userAccessLevelList = new List<UserAccessLevel>();
        
        /* This loop maps each User to their corresponding ProfileAccessLevelInfo and PermissionSetAccessLevelInfo */
        for(User u : activeUserMap.values()){
            UserAccessLevel userAccessLevelObj = new UserAccessLevel();
            SfObjectsAccess sfObjectsAccessObj = new SfObjectsAccess();
            userAccessLevelObj.userName = u.name;
            userAccessLevelObj.emailId = u.email;
            userAccessLevelObj.profileName = u.profile.name;
            userAccessLevelObj.roleName = u.UserRole.name;
            
            /* Mapping of profile access level information */
            List<ObjectPermissions> objectPermList = profileObjPermMap.get(u.ProfileId);
            
            //Comment the below if condition and enable if/else condition, If you want to drop the profiles who don't have any access to the selected objects.
            if(objectPermList != null)
                sfObjectsAccessObj = profileAccessLevelInfoMapping(sfObjectsAccessObj, objectPermList);
           /* if(objectPermList != null && objectPermList.size() > 0){
                //Enable this if condition, If you want to drop the profiles who don't have any access to the selected objects.
                sfObjectsAccessObj = profileAccessLevelInfoMapping(sfObjectsAccessObj, objectPermList);
            }else
                // If any profile doesn't have entries in ObjectPermissions table, ignore the User assigned to that Profile. 
                //   No need to check permissionset information also. Hence 'conitnue' statement 
                continue;  */
                                        
            /* Applying permissionset information on top of profile access level information */
            List<ObjectPermissions> permSetList =    uIdObjPermsMap.get(u.id);
        
            if(permSetList != null){
                for(ObjectPermissions op : permSetList){
                    if(op.SobjectType == 'Account'){
                        sfObjectsAccessObj.accountCreate = sfObjectsAccessObj.accountCreate || op.PermissionsCreate;
                        sfObjectsAccessObj.accountDelete = sfObjectsAccessObj.accountDelete || op.PermissionsDelete;
                        sfObjectsAccessObj.accountEdit = sfObjectsAccessObj.accountEdit || op.PermissionsEdit;
                        sfObjectsAccessObj.accountModifyAll = sfObjectsAccessObj.accountModifyAll || op.PermissionsModifyAllRecords;
                        sfObjectsAccessObj.accountRead = sfObjectsAccessObj.accountRead || op.PermissionsRead;
                        sfObjectsAccessObj.accountViewAll = sfObjectsAccessObj.accountViewAll || op.PermissionsViewAllRecords;
                    }else if(op.sObjectType == 'Registration__C'){
                        sfObjectsAccessObj.registrationCreate = sfObjectsAccessObj.registrationCreate || op.PermissionsCreate;
                        sfObjectsAccessObj.registrationDelete = sfObjectsAccessObj.registrationDelete || op.PermissionsDelete;
                        sfObjectsAccessObj.registrationEdit = sfObjectsAccessObj.registrationEdit || op.PermissionsEdit;
                        sfObjectsAccessObj.registrationModifyAll = sfObjectsAccessObj.registrationModifyAll || op.PermissionsModifyAllRecords;
                        sfObjectsAccessObj.registrationRead = sfObjectsAccessObj.registrationRead || op.PermissionsRead;
                        sfObjectsAccessObj.registrationViewAll = sfObjectsAccessObj.registrationViewAll || op.PermissionsViewAllRecords;
                    }else if(op.sObjectType == 'Lead'){
                        sfObjectsAccessObj.leadCreate = sfObjectsAccessObj.leadCreate || op.PermissionsCreate;
                        sfObjectsAccessObj.leadDelete = sfObjectsAccessObj.leadDelete || op.PermissionsDelete;
                        sfObjectsAccessObj.leadEdit = sfObjectsAccessObj.leadEdit || op.PermissionsEdit;
                        sfObjectsAccessObj.leadModifyAll = sfObjectsAccessObj.leadModifyAll || op.PermissionsModifyAllRecords;
                        sfObjectsAccessObj.leadRead = sfObjectsAccessObj.leadRead || op.PermissionsRead;
                        sfObjectsAccessObj.leadViewAll = sfObjectsAccessObj.leadViewAll || op.PermissionsViewAllRecords;
                    }else if(op.sObjectType == 'Opportunity'){
                        sfObjectsAccessObj.opportunityCreate = sfObjectsAccessObj.opportunityCreate || op.PermissionsCreate;
                        sfObjectsAccessObj.opportunityDelete = sfObjectsAccessObj.opportunityDelete || op.PermissionsDelete;
                        sfObjectsAccessObj.opportunityEdit = sfObjectsAccessObj.opportunityEdit || op.PermissionsEdit;
                        sfObjectsAccessObj.opportunityModifyAll = sfObjectsAccessObj.opportunityModifyAll || op.PermissionsModifyAllRecords;
                        sfObjectsAccessObj.opportunityRead = sfObjectsAccessObj.opportunityRead || op.PermissionsRead;
                        sfObjectsAccessObj.opportunityViewAll = sfObjectsAccessObj.opportunityViewAll || op.PermissionsViewAllRecords;
                    }else if(op.sObjectType == 'case'){
                        sfObjectsAccessObj.caseCreate = sfObjectsAccessObj.caseCreate || op.PermissionsCreate;
                        sfObjectsAccessObj.caseDelete = sfObjectsAccessObj.caseDelete || op.PermissionsDelete;
                        sfObjectsAccessObj.caseEdit = sfObjectsAccessObj.caseEdit || op.PermissionsEdit;
                        sfObjectsAccessObj.caseModifyAll = sfObjectsAccessObj.caseModifyAll || op.PermissionsModifyAllRecords;
                        sfObjectsAccessObj.caseRead = sfObjectsAccessObj.caseRead || op.PermissionsRead;
                        sfObjectsAccessObj.caseViewAll = sfObjectsAccessObj.caseViewAll || op.PermissionsViewAllRecords;
                    }else if(op.sObjectType == 'Contact'){
                        sfObjectsAccessObj.contactCreate = sfObjectsAccessObj.contactCreate || op.PermissionsCreate;
                        sfObjectsAccessObj.contactDelete = sfObjectsAccessObj.contactDelete || op.PermissionsDelete;
                        sfObjectsAccessObj.contactEdit = sfObjectsAccessObj.contactEdit || op.PermissionsEdit;
                        sfObjectsAccessObj.contactModifyAll = sfObjectsAccessObj.contactModifyAll || op.PermissionsModifyAllRecords;
                        sfObjectsAccessObj.contactRead = sfObjectsAccessObj.contactRead || op.PermissionsRead;
                        sfObjectsAccessObj.contactViewAll = sfObjectsAccessObj.contactViewAll || op.PermissionsViewAllRecords;
                    }else if(op.sObjectType == 'Contract'){
                        sfObjectsAccessObj.contractCreate = sfObjectsAccessObj.contractCreate || op.PermissionsCreate;
                        sfObjectsAccessObj.contractDelete = sfObjectsAccessObj.contractDelete || op.PermissionsDelete;
                        sfObjectsAccessObj.contractEdit = sfObjectsAccessObj.contractEdit || op.PermissionsEdit;
                        sfObjectsAccessObj.contractModifyAll = sfObjectsAccessObj.contractModifyAll || op.PermissionsModifyAllRecords;
                        sfObjectsAccessObj.contractRead = sfObjectsAccessObj.contractRead || op.PermissionsRead;
                        sfObjectsAccessObj.contractViewAll = sfObjectsAccessObj.contractViewAll || op.PermissionsViewAllRecords;
                    }else if(op.sObjectType == 'TransactionalData__c'){
                        sfObjectsAccessObj.transactionalDataCreate = sfObjectsAccessObj.transactionalDataCreate || op.PermissionsCreate;
                        sfObjectsAccessObj.transactionalDataDelete = sfObjectsAccessObj.transactionalDataDelete || op.PermissionsDelete;
                        sfObjectsAccessObj.transactionalDataEdit = sfObjectsAccessObj.transactionalDataEdit || op.PermissionsEdit;
                        sfObjectsAccessObj.transactionalDataModifyAll = sfObjectsAccessObj.transactionalDataModifyAll || op.PermissionsModifyAllRecords;
                        sfObjectsAccessObj.transactionalDataRead = sfObjectsAccessObj.transactionalDataRead || op.PermissionsRead;
                        sfObjectsAccessObj.transactionalDataViewAll = sfObjectsAccessObj.transactionalDataViewAll || op.PermissionsViewAllRecords;
                    }
                }
            }
            userAccessLevelObj.sfObjectsAccess = sfObjectsAccessObj;
            userAccessLevelList.add(userAccessLevelObj);
        }
    }
    
    /* Method will return the list of PermissionSets assigned to each user */
    public Map<id, List<ObjectPermissions>> getPermissionSetDetails(Set<id> userIds){
        uIdObjPermsMap = new Map<id, List<ObjectPermissions>>();
        Map<id, list<id>> userPermIdsMap = new Map<id, list<id>>();
         List<PermissionSetAssignment> psaList = [select AssigneeId, PermissionSetId from PermissionSetAssignment where AssigneeId in :userIds];
        for(PermissionSetAssignment psa : psaList){
            if(userPermIdsMap.get(psa.AssigneeId) == null)
                userPermIdsMap.put(psa.AssigneeId, new List<id>());
                
            userPermIdsMap.get(psa.AssigneeId).add(psa.PermissionSetId);
        }
     
        List<ObjectPermissions> objectPerms = [SELECT ParentId, SobjectType, PermissionsCreate, PermissionsDelete, PermissionsEdit, PermissionsModifyAllRecords, PermissionsRead, PermissionsViewAllRecords 
                                                    FROM ObjectPermissions 
                                                    where parentId in (select PermissionSetId from PermissionSetAssignment where AssigneeId in :userIds) 
                                                      and sObjectType in ('Account', 'Registration__C', 'Lead', 'Opportunity', 'Contact','Case', 'Contract', 'TransactionalData__c')];
   
        Map<id, List<ObjectPermissions>> parIdobjPermsMap = new Map<id, List<ObjectPermissions>>();
        
        for(ObjectPermissions op : objectPerms){
            if(parIdobjPermsMap.get(op.ParentId) == null)
                parIdobjPermsMap.put(op.ParentId, new List<ObjectPermissions>());
            parIdobjPermsMap.get(op.ParentId).add(op);
        }
   
        for(id userId : userIds){
            if(userPermIdsMap.get(userId) != null){
                for(id permSetId : userPermIdsMap.get(userId)){
                    if(uIdObjPermsMap.get(userId) == null)
                        uIdObjPermsMap.put(userId, new List<ObjectPermissions>());
                    if(parIdobjPermsMap.get(permSetId) != null)
                        uIdObjPermsMap.get(userId).addAll(parIdobjPermsMap.get(permSetId));
                }
            }
        }
        return uIdObjPermsMap;
    }
    
    public SfObjectsAccess profileAccessLevelInfoMapping(SfObjectsAccess sfObjectsAccessObj, List<ObjectPermissions> objectPermList){
        for(ObjectPermissions op : objectPermList){
            if(op.sObjectType == 'Account'){
                sfObjectsAccessObj.accountCreate = op.PermissionsCreate;
                sfObjectsAccessObj.accountDelete = op.PermissionsDelete;
                sfObjectsAccessObj.accountEdit = op.PermissionsEdit;
                sfObjectsAccessObj.accountModifyAll = op.PermissionsModifyAllRecords;
                sfObjectsAccessObj.accountRead = op.PermissionsRead;
                sfObjectsAccessObj.accountViewAll = op.PermissionsViewAllRecords;
            }else if(op.sObjectType == 'Registration__C'){
                sfObjectsAccessObj.registrationCreate = op.PermissionsCreate;
                sfObjectsAccessObj.registrationDelete = op.PermissionsDelete;
                sfObjectsAccessObj.registrationEdit = op.PermissionsEdit;
                sfObjectsAccessObj.registrationModifyAll = op.PermissionsModifyAllRecords;
                sfObjectsAccessObj.registrationRead = op.PermissionsRead;
                sfObjectsAccessObj.registrationViewAll = op.PermissionsViewAllRecords;
            }else if(op.sObjectType == 'Lead'){
                sfObjectsAccessObj.leadCreate = op.PermissionsCreate;
                sfObjectsAccessObj.leadDelete = op.PermissionsDelete;
                sfObjectsAccessObj.leadEdit = op.PermissionsEdit;
                sfObjectsAccessObj.leadModifyAll = op.PermissionsModifyAllRecords;
                sfObjectsAccessObj.leadRead = op.PermissionsRead;
                sfObjectsAccessObj.leadViewAll = op.PermissionsViewAllRecords;
            }else if(op.sObjectType == 'Opportunity'){
                sfObjectsAccessObj.opportunityCreate = op.PermissionsCreate;
                sfObjectsAccessObj.opportunityDelete = op.PermissionsDelete;
                sfObjectsAccessObj.opportunityEdit = op.PermissionsEdit;
                sfObjectsAccessObj.opportunityModifyAll = op.PermissionsModifyAllRecords;
                sfObjectsAccessObj.opportunityRead = op.PermissionsRead;
                sfObjectsAccessObj.opportunityViewAll = op.PermissionsViewAllRecords;
            }else if(op.sObjectType == 'case'){
                sfObjectsAccessObj.caseCreate = op.PermissionsCreate;
                sfObjectsAccessObj.caseDelete = op.PermissionsDelete;
                sfObjectsAccessObj.caseEdit = op.PermissionsEdit;
                sfObjectsAccessObj.caseModifyAll = op.PermissionsModifyAllRecords;
                sfObjectsAccessObj.caseRead = op.PermissionsRead;
                sfObjectsAccessObj.caseViewAll = op.PermissionsViewAllRecords;
            }else if(op.sObjectType == 'Contact'){
                sfObjectsAccessObj.contactCreate = op.PermissionsCreate;
                sfObjectsAccessObj.contactDelete = op.PermissionsDelete;
                sfObjectsAccessObj.contactEdit = op.PermissionsEdit;
                sfObjectsAccessObj.contactModifyAll = op.PermissionsModifyAllRecords;
                sfObjectsAccessObj.contactRead = op.PermissionsRead;
                sfObjectsAccessObj.contactViewAll = op.PermissionsViewAllRecords;
            }else if(op.sObjectType == 'Contract'){
                sfObjectsAccessObj.contractCreate = op.PermissionsCreate;
                sfObjectsAccessObj.contractDelete = op.PermissionsDelete;
                sfObjectsAccessObj.contractEdit = op.PermissionsEdit;
                sfObjectsAccessObj.contractModifyAll = op.PermissionsModifyAllRecords;
                sfObjectsAccessObj.contractRead = op.PermissionsRead;
                sfObjectsAccessObj.contractViewAll = op.PermissionsViewAllRecords;
            }else if(op.sObjectType == 'TransactionalData__c'){
                sfObjectsAccessObj.transactionalDataCreate = op.PermissionsCreate;
                sfObjectsAccessObj.transactionalDataDelete = op.PermissionsDelete;
                sfObjectsAccessObj.transactionalDataEdit = op.PermissionsEdit;
                sfObjectsAccessObj.transactionalDataModifyAll = op.PermissionsModifyAllRecords;
                sfObjectsAccessObj.transactionalDataRead = op.PermissionsRead;
                sfObjectsAccessObj.transactionalDataViewAll = op.PermissionsViewAllRecords;
            }    
        }
        return sfObjectsAccessObj;
    }

    public String getObjLabel(String objName){
        try{
        	List<Schema.DescribeSObjectResult> describeSobjectsResult = Schema.describeSObjects(new List<String>{objName}); // this can accept list of strings, we describe only one object here
            if(describeSobjectsResult.size() > 0)
				return describeSobjectsResult[0].getLabel();
        	else
            	return '';
        }catch(Exception e){
            return '';
        }
        
    }
    public class UserAccessLevel{
        public String userName {set;get;}
        public String emailId  {set;get;}
        public String profileName  {set;get;}
        public String roleName  {set;get;}
        public SfObjectsAccess sfObjectsAccess {set; get;}
    }
    
    public class ProfileAccessLevel{
        public String profileName {set;get;} 
        public String userLicenseName {set;get;} 
        public Boolean viewAllData {set; get;} {viewAllData = false;}
        public Boolean modifyAllData {set; get;} {modifyAllData = false;}
        public Boolean apiEnabled {set; get;} {apiEnabled = false;}
        public Boolean assignPermissionSets {set; get;} {assignPermissionSets = false;}
        public Boolean manageInternalUsers {set; get;} {manageInternalUsers = false;}
        public Boolean manageIpAddresses {set; get;} {manageIpAddresses = false;}
        public Boolean manageLoginAccessPolicies {set; get;} {manageLoginAccessPolicies = false;}
        public Boolean managePasswordPolicies {set; get;} {managePasswordPolicies = false;}
        public Boolean manageProfilesPermissionsets {set; get;} {manageProfilesPermissionsets = false;}
        public Boolean manageSharing {set; get;} {manageSharing = false;}
        public Boolean manageRoles {set; get;} {manageRoles = false;}
        public Boolean manageUsers {set; get;} {manageUsers = false;} 
        public SfObjectsAccess sfObjectsAccess {set; get;}
    }
    
    public class PermissionsetAccessLevel{
        public String permissionsetLabel {set;get;}
        public String permissionsetName {set;get;}
        public String sObjectType {set;get;}
        public String objectLabel {set;get;}
        public Boolean readPerm {set;get;} {readPerm = false;}
        public Boolean createPerm {set;get;} {createPerm = false;}
        public Boolean editPerm {set;get;} {editPerm = false;}
        public Boolean deletePerm {set;get;} {deletePerm = false;}
        public Boolean viewAllPerm {set;get;} {viewAllPerm = false;}
        public Boolean modifyAllPerm {set;get;} {modifyAllPerm = false;}
        //public List<PermissionsetSobjectAccess> permissionsetSobjectAccessList {set; get;}
    }
  /*  public class PermissionsetSobjectAccess{
        public String sObjectType {set;get;}
        public Boolean readPerm {set;get;} {readPerm = false;}
        public Boolean createPerm {set;get;} {createPerm = false;}
        public Boolean editPerm {set;get;} {editPerm = false;}
        public Boolean deletePerm {set;get;} {deletePerm = false;}
        public Boolean viewAllPerm {set;get;} {viewAllPerm = false;}
        public Boolean modifyAllPerm {set;get;} {modifyAllPerm = false;}
    }*/
    
    public class ProfileUserCount{
        public String profileName {set;get;}
        public Integer userCount {set; get;}
    }
    
    public class SfObjectsAccess{
        public Boolean accountRead {set;get;} {accountRead = false;}
        public Boolean accountCreate {set;get;} {accountCreate = false;}
        public Boolean accountEdit {set;get;} {accountEdit = false;}
        public Boolean accountDelete {set;get;} {accountDelete = false;}
        public Boolean accountViewAll {set;get;} {accountViewAll = false;}
        public Boolean accountModifyAll {set;get;} {accountModifyAll = false;}
        
        public Boolean registrationRead {set;get;} {registrationRead = false;}
        public Boolean registrationCreate {set;get;} {registrationCreate = false;}
        public Boolean registrationEdit {set;get;} {registrationEdit = false;}
        public Boolean registrationDelete {set;get;} {registrationDelete = false;}
        public Boolean registrationViewAll {set;get;} {registrationViewAll = false;}
        public Boolean registrationModifyAll {set;get;} {registrationModifyAll = false;}
        
        public Boolean leadRead {set;get;} {leadRead = false;}
        public Boolean leadCreate {set;get;} {leadCreate = false;}
        public Boolean leadEdit {set;get;} {leadEdit = false;}
        public Boolean leadDelete {set;get;} {leadDelete = false;}
        public Boolean leadViewAll {set;get;} {leadViewAll = false;}
        public Boolean leadModifyAll {set;get;} {leadModifyAll = false;}
        
        public Boolean opportunityRead {set;get;} {opportunityRead = false;}
        public Boolean opportunityCreate {set;get;} {opportunityCreate = false;}
        public Boolean opportunityEdit {set;get;} {opportunityEdit = false;}
        public Boolean opportunityDelete {set;get;} {opportunityDelete = false;}
        public Boolean opportunityViewAll {set;get;} {opportunityViewAll = false;}
        public Boolean opportunityModifyAll {set;get;} {opportunityModifyAll = false;}
        
        public Boolean contactRead {set;get;} {contactRead = false;}
        public Boolean contactCreate {set;get;} {contactCreate = false;}
        public Boolean contactEdit {set;get;} {contactEdit = false;}
        public Boolean contactDelete {set;get;} {contactDelete = false;}
        public Boolean contactViewAll {set;get;} {contactViewAll = false;}
        public Boolean contactModifyAll {set;get;} {contactModifyAll = false;}
   
        public Boolean caseRead {set;get;} {caseRead = false;}
        public Boolean caseCreate {set;get;} {caseCreate = false;}
        public Boolean caseEdit {set;get;} {caseEdit = false;}
        public Boolean caseDelete {set;get;} {caseDelete = false;}
        public Boolean caseViewAll {set;get;} {caseViewAll = false;}
        public Boolean caseModifyAll {set;get;} {caseModifyAll = false;}
        
        public Boolean contractRead {set;get;} {contractRead = false;}
        public Boolean contractCreate {set;get;} {contractCreate = false;}
        public Boolean contractEdit {set;get;} {contractEdit = false;}
        public Boolean contractDelete {set;get;} {contractDelete = false;}
        public Boolean contractViewAll {set;get;} {contractViewAll = false;}
        public Boolean contractModifyAll {set;get;} {contractModifyAll = false;}
        
        public Boolean transactionalDataRead {set;get;} {transactionalDataRead = false;}
        public Boolean transactionalDataCreate {set;get;} {transactionalDataCreate = false;}
        public Boolean transactionalDataEdit {set;get;} {transactionalDataEdit = false;}
        public Boolean transactionalDataDelete {set;get;} {transactionalDataDelete = false;}
        public Boolean transactionalDataViewAll {set;get;} {transactionalDataViewAll = false;}
        public Boolean transactionalDataModifyAll {set;get;} {transactionalDataModifyAll = false;}
   }
}