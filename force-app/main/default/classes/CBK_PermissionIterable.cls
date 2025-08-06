/**********************************************************************************************************************
 Name:	  CBK_PermissionIterator
 Copyright © 2021  CaixaBank
***********************************************************************************************************************
Proposito: Clase Apex correspondiente iterable permisos. Clase base para el iterador de reciclado de permisos.
***********************************************************************************************************************
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								Francisco Zaragoza	19/04/2022			Init version
***********************************************************************************************************************/
public class CBK_PermissionIterable implements Iterable<CBK_Permission> {

    List<User> userList;
    Set<String> permissionSetAssignList;
    Set<String> permissionSetLicenseAssignList;

    public CBK_PermissionIterable(Set<String> permissionSetAssignList,Set<String> permissionSetLicenseAssignList,List<User> userList) {
        this.userList = userList;
        this.permissionSetAssignList = permissionSetAssignList;
        this.permissionSetLicenseAssignList = permissionSetLicenseAssignList;
    }

    public Iterator<CBK_Permission> iterator() {
        List<CBK_Permission> permissionsList = new List<CBK_Permission>();
        List<PermissionSetAssignment> permisos = new List<PermissionSetAssignment>();
        List<PermissionSetLicenseAssign> licencias = new List<PermissionSetLicenseAssign> ();
        Set<Id> getUsersExcludedPermissionSet = new Set<Id>();
        
        if (!permissionSetAssignList.isEmpty()) {
            permisos = CBK_PermissionUtils.retrievePermissionSetAssignments(permissionSetAssignList,userList);
        }

         if (!permissionSetLicenseAssignList.isEmpty()) {
            licencias = CBK_PermissionUtils.retrievePermissionSetLicenseAssignments(permissionSetLicenseAssignList,userList); 
         }
        

        getUsersExcludedPermissionSet = CBK_PermissionUtils.retrieveExcludedUsers();

        for (PermissionSetAssignment pe : permisos){
            if(!getUsersExcludedPermissionSet.contains(pe.AssigneeId)){
                permissionsList.add( new CBK_Permission((pe.PermissionSetGroupId != null?CBK_Permission.PERMISSIONTYPE.PERMISSIONSETGROUP:CBK_Permission.PERMISSIONTYPE.PERMISSIONSET),pe.Id,(pe.PermissionSetGroupId != null?pe.PermissionSetGroup.DeveloperName:pe.PermissionSet.Name),pe.AssigneeId,pe.Assignee.CreatedDate,pe.Assignee.LastLoginDate));
            }
        }
        for (PermissionSetLicenseAssign lic : licencias){
            if(!getUsersExcludedPermissionSet.contains(lic.AssigneeId)){
                permissionsList.add( new CBK_Permission(CBK_Permission.PERMISSIONTYPE.PERMISSIONSETLICENSE,lic.Id,lic.PermissionSetLicense.DeveloperName,lic.AssigneeId,lic.Assignee.CreatedDate,lic.Assignee.LastLoginDate));
            }
        }
       return new CBK_PermissionIterator(permissionsList);
    }
 }