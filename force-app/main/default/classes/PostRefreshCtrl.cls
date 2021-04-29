/**
1) 	Ticket: PDS-5789
	Date: 18/11/2019
	Developer: Kishore Potla
	Changes:
  	1) Added new feature to assign System Administrator profile to System Admin/Dev public group users.
  	2) Removed 'Run All' feature to avoid mixed DML exception
  	3) Redesigned the page: Removed separate buttons for toop tip text, Removed table element for dancing dots on the page design.

2) 	SCS-302: Activate or Deactivate the below users in Sandboxes"
	Activate users   :  "salesforce.testautomation@enett.com", "sf_deploy_tst@enett.com"
   	Deacitvate Users :  "sf_deploy_prd@enett.com"
   	Developer - Kishore Potla
   	Date: 04/04/2020
*/
public class PostRefreshCtrl {
    public boolean isSandbox {get; set;}
    public boolean changeEmailDone {get; set;}
    public boolean changeProfileDone {get; set;}
    public boolean updateSiteSettingDone {get; set;}
    public boolean updateMessageDialogDone {get; set;}
    public boolean hideRunAllButton {get; set;}
    public boolean createStateDetailsDone {get; set;}
    public boolean activateAndDeactivateUsersDone {get; set;}
    public Profile sysAd {get; set;}
    Public String[] activateAndDeactiveUsers = new String[]{'salesforce.testautomation@enett.com%','sf_deploy_prd@enett.com%','sf_deploy_tst@enett.com%'};
    
    //Check if the tasks have been performed already
    public PostRefreshCtrl(){     
        //Check if emails of users in public groups have been updated and their profiles have been changed to 'System Administrator'
        List<Group> selectedGroup = [SELECT Id,Name FROM Group WHERE Name LIKE '%System Admin/Developer%' LIMIT 1];
        List<GroupMember> groupMember = [SELECT GroupId,Id,UserOrGroupId FROM GroupMember WHERE GroupId =: selectedGroup];
        List<Id> userIdList = new List<Id>();
        for (GroupMember gm : groupMember){
            userIdList.add(gm.UserOrGroupId);
        }
        
        //SCS-302 
        activateAndDeactivateUsersDone = TRUE;
        List<User> activateDeactivateUserList = [SELECT Id, Email, IsActive from USER WHERE EMAIL LIKE :activateAndDeactiveUsers];
        for(User actDeactuser : activateDeactivateUserList){
            if(actDeactuser.Email.contains('salesforce.testautomation@enett.com') && actDeactuser.isActive == FALSE){
                activateAndDeactivateUsersDone = FALSE;
                break;
            }
            else if(actDeactuser.Email.contains('sf_deploy_prd@enett.com') && actDeactuser.isActive == TRUE){
                activateAndDeactivateUsersDone = FALSE;
                break;
            }
            else if(actDeactuser.Email.contains('sf_deploy_tst@enett.com') && actDeactuser.isActive == FALSE){ 
                activateAndDeactivateUsersDone = FALSE;
                break;
            }
        }
  
        List<User> users = [SELECT Id, ProfileId, Email FROM User WHERE Id IN: userIdList];
        sysAd = fetchSysAdminProfile();
        // PDS-5789: Change START
        List<User> updateUserList = new List<User>();
         for(User u : users){
            if(u.ProfileId != sysAd.Id){
                changeProfileDone = false;
                break;
            }else{
                changeProfileDone = true;
            }
        }
        // PDS-5789: Change END
        String text = '.invalid';
        for (User u : users){
            if (u.Email.indexOf(text) == -1 && u.ProfileId == sysAd.Id){
                changeEmailDone = true;
            } else{
                changeEmailDone = false;
                break;
            }
        }
        //Check if RegoSettings custom setting have been updated
        RegoSettings__c rs = [SELECT Id, Name, sfdcHostName__c, sfdcHostAccountSetup__c FROM RegoSettings__c];
        String sandboxName = UserInfo.getUserName().substringAfterLast('.');
        Site st = [SELECT Id, Subdomain, urlPathPrefix FROM Site WHERE Name = 'eNettRegistration' LIMIT 1];
        String subDomain = st.Subdomain;
        String urlPathPrefix = st.urlPathPrefix;
        Organization myOrg = [SELECT Id, InstanceName FROM Organization LIMIT 1];
        String instanceName = myOrg.InstanceName.toLowerCase();
        String correctURL = sandboxName + '-' + subDomain + '.' + instanceName + '.force.com/' + urlPathPrefix;
        if (rs.sfdcHostName__c.indexOf(correctURL) == -1 || rs.sfdcHostAccountSetup__c.indexOf(correctURL) == -1){
            updateSiteSettingDone = false;
        } else {
            updateSiteSettingDone = true;
        }
        //Check if message dialogs have been created or updated
        List<bigiant_dialog__bDialog__c> dialogList = [SELECT Id, Name, bigiant_dialog__Title__c, bigiant_dialog__Content_url__c FROM bigiant_dialog__bDialog__c];
        if (dialogList.size() == 0){
            updateMessageDialogDone = false;
        } else {
            updateMessageDialogDone = true;
        }
        
        //SF-5182 30/8/2018 Jasmine - Adding feature to create state details data
        //Check if State Details object has any records
        List<State_Detail__c> sdL = [SELECT Id, Name FROM State_Detail__c];
        if (sdL.size() == 0){
            createStateDetailsDone = false;
        } else {
            createStateDetailsDone = true;
        }
    }   
    
    public profile fetchSysAdminProfile(){
        return [SELECT Id FROM Profile WHERE Name = 'System Administrator' limit 1];
    }
    
    //Check if the current environment is a sandbox
    public void checkIfSandbox(){
        Organization org = [SELECT isSandbox FROM Organization LIMIT 1];
        isSandbox = org.IsSandbox;  
    }
    
    /** PDS-5789: Change START
      * Note: Salesforce limitation: Current logged-in user's profile id can't be changed.[FIELD_INTEGRITY_EXCEPTION]
     */
    public void changeProfile(){
        checkIfSandbox(); //Only in Sandboxes, assign System Administrator profile to 'System Admin/Developer' group users 
        if (changeProfileDone == false && isSandbox){
           System.debug('########### PostRefreshController:: changeProfile() is invoked');
            List<Group> selectedGroup = [SELECT Id,Name FROM Group WHERE Name LIKE '%System Admin/Developer%' LIMIT 1];
            List<GroupMember> groupMember = [SELECT GroupId,Id,UserOrGroupId FROM GroupMember WHERE GroupId =: selectedGroup];
            List<Id> userIdList = new List<Id>();
            for (GroupMember gm : groupMember){
                userIdList.add(gm.UserOrGroupId);
            }
            List<User> users = [SELECT Id, ProfileId, Email FROM User WHERE Id IN: userIdList];
            if(sysAd == null) 
                sysAd = fetchSysAdminProfile();
           // Profile sysAd = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
           List<User> updateUserList = new List<User>();
           for(User u : users){
                if(u.ProfileId != sysAd.Id && u.id != UserInfo.getUserId()){
                    u.ProfileId = sysAd.Id;
                    updateUserList.add(u);
                    System.debug('########### PostRefreshController:: User '+u.Email+ ' will be assigned to System Administrator profile');
                }
            }
            if(updateUserList.size() > 0){
                try{
                Database.SaveResult[] srList = Database.update(updateUserList);
                for (Database.SaveResult sr : srList){
                    if (sr.isSuccess()){
                        changeProfileDone = true;
                    } else {
                        changeProfileDone = false;
                        System.debug('########### PostRefreshController:: profile change failed :: '+sr.getErrors());
                        break;
                    }
                }
                }catch(Exception e){
                     System.debug('#####Exception in Post Sandbox Refresh Activity :: changeProfile() :: '+e.getMessage());
                }
            }else{
                changeProfileDone = true; //Ignorning current user's profile change.
            }
        }
    }
    // PDS-5789: Change END
    
    //remove the '.invalid' from admin users' email addresses
    public void changeEmail(){
        checkIfSandbox(); //Run only in Sandboxes  
        if (changeEmailDone == false && isSandbox){
            System.debug('########### PostRefreshController:: changeEmail() is invoked');
            //Retrieve the public group, if the group does not exist then do nothing
            List<Group> selectedGroup = [SELECT Id,Name FROM Group WHERE Name LIKE '%System Admin/Developer%' LIMIT 1];
            //Retrieve the group members and their user Ids
            List<GroupMember> groupMember = [SELECT GroupId,Id,UserOrGroupId FROM GroupMember WHERE GroupId =: selectedGroup];
            List<Id> userIdList = new List<Id>();
            for (GroupMember gm : groupMember){
                userIdList.add(gm.UserOrGroupId);
            }
            List<User> users = [SELECT Id, Email FROM User WHERE Id IN: userIdList];
            //For each user in the list, update the emails by removing '.invalid' at end.
            //Also, change the user's profile to 'System Administrator'
            List<User> updatedUsers = new List<User>();
            String text = '.invalid';
            for (User u : users){
                if (u.Email.indexOf(text) != -1){
                    u.Email = u.Email.removeEnd('.invalid');
                    updatedUsers.add(u);
                }
            }
            try{
            Database.SaveResult[] srList = Database.update(updatedUsers);
            for (Database.SaveResult sr : srList){
                if (sr.isSuccess()){
                    changeEmailDone = true;
                } else {
                    changeEmailDone = false;
                }
            }
            }catch(Exception e){
                System.debug('#####Exception in Post Sandbox Refresh Activity :: changeEmail() :: '+e.getMessage());
            }
        }
    }
    
   	//SCS-302 - Activate or Deactivate Users in sandboxes
    public void activateAndDeactivateUsers(){
        checkIfSandbox(); //Run only in Sandboxes  
        List<User> updateUsrList = new List<User>();
        if (activateAndDeactivateUsersDone == false && isSandbox){
            List<User> activateDeactivateUserList = [SELECT Id, Email, IsActive from USER WHERE EMAIL LIKE :activateAndDeactiveUsers];
            for(User actDeactuser : activateDeactivateUserList){
                if(actDeactuser.Email.contains('salesforce.testautomation@enett.com') && actDeactuser.isActive == FALSE){
                    actDeactuser.IsActive = TRUE;
                    updateUsrList.add(actDeactuser);
                }
                else if(actDeactuser.Email.contains('sf_deploy_prd@enett.com') && actDeactuser.isActive == TRUE){
                    actDeactuser.IsActive = FALSE;
                    updateUsrList.add(actDeactuser);
                }
                else if(actDeactuser.Email.contains('sf_deploy_tst@enett.com') && actDeactuser.isActive == FALSE){ 
                    actDeactuser.IsActive = TRUE;
                    updateUsrList.add(actDeactuser);
                }
            } 
            update updateUsrList;
            activateAndDeactivateUsersDone = TRUE;
        }
    }
    
    //Update the site setting in custom settings
    public void updateSiteSetting(){
        checkIfSandbox(); //Run only in Sandbox
        if (updateSiteSettingDone == false && isSandbox){
            System.debug('########### PostRefreshController:: updateSiteSetting() is invoked');
            //Retrieve the custom setting, if the custom setting not found then do nothing
            RegoSettings__c rs = [SELECT Id, Name, sfdcHostName__c, sfdcHostAccountSetup__c FROM RegoSettings__c];
            //Build the URL, since we cannot retrieve the URL at once, we have to retrieve each components at a time and put them together 
            String sandboxName = UserInfo.getUserName().substringAfterLast('.');
            Site st = [SELECT Id, Subdomain, urlPathPrefix FROM Site WHERE Name = 'eNettRegistration' LIMIT 1];
            String subDomain = st.Subdomain;
            String urlPathPrefix = st.urlPathPrefix;
            Organization myOrg = [SELECT Id, InstanceName FROM Organization LIMIT 1];
            String instanceName = myOrg.InstanceName.toLowerCase();
            String correctURL = sandboxName + '-' + subDomain + '.' + instanceName + '.force.com/' + urlPathPrefix;
            //Replace the custom setting with the new URL
            rs.sfdcHostName__c = correctURL;
            rs.sfdcHostAccountSetup__c = correctURL;
            try{
            Database.SaveResult sr = Database.update(rs);
            if (sr.isSuccess()){
                updateSiteSettingDone = true;
            } else {
                updateSiteSettingDone = false;
            }
            }catch(Exception e){
                System.debug('#####Exception in Post Sandbox Refresh Activity :: updateSiteSetting() :: '+e.getMessage());
            }
        }
    }
    
    //Insert a list of dialogs and update the link for one of them
    public void updateMessageDialog(){
        checkIfSandbox(); //Run only in Sandboxes
        if(updateMessageDialogDone == false && isSandbox){
            System.debug('########### PostRefreshController:: updateMessageDialog() is invoked');
            //Retrieve the instance of the org
            Organization myOrg = [SELECT Id,InstanceName From Organization];
            String instanceName = myOrg.InstanceName.toLowerCase();
            //Query all the dialogs store in custome setting
            List<DialogPopUp__c> dialogCustomSetting = [SELECT Id, Name, Close_on_escape__c, Content_URL__c, Draggable__c,
                                                        External_content__c, Height__c, Hide_effect__c, Hide_titlebar_close__c, Modal__c,
                                                        Position__c, Resizable__c, Scrolling__c, Show_effect__c, Standard_style__c,
                                                        Title__c, Visualforce_page__c, Width__c FROM DialogPopUp__c ];
            List<bigiant_dialog__bDialog__c> dialogList = new List<bigiant_dialog__bDialog__c>();
            //Create a dialog record for each item in the custom setting list
            //If custom setting item's title and name are not 'Message Dialog' then insert with no changes, otherwise update the URL link
            for(DialogPopUp__c d : dialogCustomSetting){
                if(d.Name != 'Message Dialog' && d.Title__c != 'Message Dialog'){
                    bigiant_dialog__bDialog__c dialog = new bigiant_dialog__bDialog__c(Name = d.Name,
                                                                                       bigiant_dialog__Close_on_escape__c = d.Close_on_escape__c,
                                                                                       bigiant_dialog__Content_url__c = d.Content_URL__c,
                                                                                       bigiant_dialog__Draggable__c = d.Draggable__c,
                                                                                       bigiant_dialog__External_content__c = d.External_content__c,
                                                                                       bigiant_dialog__Height__c = d.Height__c,
                                                                                       bigiant_dialog__Hide_effect__c = d.Hide_effect__c,
                                                                                       bigiant_dialog__Hide_titlebar_close__c = d.Hide_titlebar_close__c,
                                                                                       bigiant_dialog__Modal__c = d.Modal__c,
                                                                                       bigiant_dialog__Position__c = d.Position__c,
                                                                                       bigiant_dialog__Resizable__c = d.Resizable__c,
                                                                                       bigiant_dialog__Scrolling__c = d.Scrolling__c,
                                                                                       bigiant_dialog__Show_effect__c = d.Show_effect__c,
                                                                                       bigiant_dialog__Standard_style__c = d.Standard_style__c,
                                                                                       bigiant_dialog__Title__c = d.Title__c,
                                                                                       bigiant_dialog__Visualforce_Page__c = d.Visualforce_page__c,
                                                                                       bigiant_dialog__Width__c = d.Width__c);
                    dialogList.add(dialog);
                } else {
                    bigiant_dialog__bDialog__c dialog = new bigiant_dialog__bDialog__c(Name = d.Name,
                                                                                       bigiant_dialog__Close_on_escape__c = d.Close_on_escape__c,
                                                                                       bigiant_dialog__Content_url__c = 'https://c.' + instanceName.toLowerCase() + '.visual.force.com/apex/PopUpDialog',
                                                                                       bigiant_dialog__Draggable__c = d.Draggable__c,
                                                                                       bigiant_dialog__External_content__c = d.External_content__c,
                                                                                       bigiant_dialog__Height__c = d.Height__c,
                                                                                       bigiant_dialog__Hide_effect__c = d.Hide_effect__c,
                                                                                       bigiant_dialog__Hide_titlebar_close__c = d.Hide_titlebar_close__c,
                                                                                       bigiant_dialog__Modal__c = d.Modal__c,
                                                                                       bigiant_dialog__Position__c = d.Position__c,
                                                                                       bigiant_dialog__Resizable__c = d.Resizable__c,
                                                                                       bigiant_dialog__Scrolling__c = d.Scrolling__c,
                                                                                       bigiant_dialog__Show_effect__c = d.Show_effect__c,
                                                                                       bigiant_dialog__Standard_style__c = d.Standard_style__c,
                                                                                       bigiant_dialog__Title__c = d.Title__c,
                                                                                       bigiant_dialog__Visualforce_Page__c = d.Visualforce_page__c,
                                                                                       bigiant_dialog__Width__c = d.Width__c); 
                    dialogList.add(dialog);
                }  
            }
            //insert dialogList;
            try{
            Database.SaveResult[] srList = Database.insert(dialogList);
            for (Database.SaveResult sr : srList){
                if (sr.isSuccess()){
                    updateMessageDialogDone = true;
                } else {
                    updateMessageDialogDone = false;
                }
            }
            }catch(Exception e){
                System.debug('#####Exception in Post Sandbox Refresh Activity :: updateMessageDialog() :: '+e.getMessage());
            }
        }
    }

    //Create State Details records
    public void createStateDetails(){
        checkIfSandbox(); //Run only in Sandbox
        if (createStateDetailsDone == false && isSandbox){
            System.debug('########### PostRefreshController:: createStateDetails() is invoked');
            List<State_Detail__c> sdList = new List<State_Detail__c>();
            State_Detail__c sd1 = new State_Detail__c(Name = 'Victoria',
                                                      State_ID__c = '12473',
                                                      Country_Name__c = 'Australia',
                                                      Approved_State__c = true,
                                                      CurrencyIsoCode = 'AUD',
                                                      eNett_Client_Abbreviation__c = 'VIC');
            sdList.add(sd1);
            State_Detail__c sd2 = new State_Detail__c(Name = 'New South Wales',
                                                      State_ID__c = '12477',
                                                      Country_Name__c = 'Australia',
                                                      Approved_State__c = true,
                                                      CurrencyIsoCode = 'AUD',
                                                      eNett_Client_Abbreviation__c = 'NSW');
            sdList.add(sd2);
            State_Detail__c sd3 = new State_Detail__c(Name = 'Western Australia',
                                                      State_ID__c = '12470',
                                                      Country_Name__c = 'Australia',
                                                      Approved_State__c = true,
                                                      CurrencyIsoCode = 'AUD',
                                                      eNett_Client_Abbreviation__c = 'WA');
            sdList.add(sd3);
            State_Detail__c sd4 = new State_Detail__c(Name = 'South Australia',
                                                      State_ID__c = '12472',
                                                      Country_Name__c = 'Australia',
                                                      Approved_State__c = true,
                                                      CurrencyIsoCode = 'AUD',
                                                      eNett_Client_Abbreviation__c = 'SA');
            sdList.add(sd4);
            State_Detail__c sd5 = new State_Detail__c(Name = 'Queensland',
                                                      State_ID__c = '12476',
                                                      Country_Name__c = 'Australia',
                                                      Approved_State__c = true,
                                                      CurrencyIsoCode = 'AUD',
                                                      eNett_Client_Abbreviation__c = 'QLD');
            sdList.add(sd5);
            try{
            Database.SaveResult[] srList = Database.insert(sdList);
            for (Database.SaveResult sr : srList){
                if (sr.isSuccess() == true){
                    createStateDetailsDone = true;
                } else {
                    createStateDetailsDone = false;
                }
            }   
            }catch(Exception e){
                System.debug('#####Exception in Post Sandbox Refresh Activity :: createStateDetails() : '+e.getMessage());
            }
        }
    }
}