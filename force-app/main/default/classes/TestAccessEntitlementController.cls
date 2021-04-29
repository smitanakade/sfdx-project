/* Author : Kishore Potla
 * Test class for AccessEntitlementController.apxc
 * 
 * Will test the functionality of the below Access Entitlement Reports 
 *   1. User Access level Report
 *   2. Profile Access level Report
 *   3. Profile Vs UserCount Report.
 *  
*/

@isTest
public class TestAccessEntitlementController {
     
    static testMethod void runTest() {
        AccessEntitlementController aeController = new AccessEntitlementController();
        aeController.getProfileVsUsercountReport();
        aeController.getProfileAccessReport();
        aeController.getUserAccessReport();
        aeController.getPermissionsetAccessReport();
        aeController.getPermissionsetAssignmentReport();
     
        System.assert(aeController.userAccessLevelList.size() >  0, 'User Access Entitlement report is empty');
        System.assert(aeController.profileAccessLevelList.size() >  0, 'Profile Access Entitlement report is empty');
        System.assert(aeController.permissionsetList.size() >  0, 'Permissinset Access Entitlement report is empty');
        System.assert(aeController.permissionsetAssignmentMap.size() >  0, 'Permissionset Assignment report is empty');
        System.assert(aeController.profileUserCountList.size() >  0, 'Profile Vs UserCount report is empty');
    }
}