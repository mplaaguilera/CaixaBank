/**
 * @description       : 
 * @author            : fzaragoza
 * @group             : 
 * @last modified on  : 02-06-2022
 * @last modified by  : fzaragoza
 * Modifications Log
 * Ver   Date         Author      Modification
 * 1.0   26-04-2022   fzaragoza   Initial Version
**/
public with sharing class CBK_PermissionUtils {

    public static List<PermissionSetAssignment> retrievePermissionSetAssignments(Set<String> permissionSetAssignList, List<User> userList){
        List<PermissionSetAssignment> perm =  (System.Test.isRunningTest()?[SELECT Id, PermissionSetId, PermissionSet.Name, PermissionSetGroupId, PermissionSetGroup.DeveloperName, AssigneeId, Assignee.CreatedDate, Assignee.LastLoginDate FROM PermissionSetAssignment WHERE AssigneeId IN :userList ORDER BY Assignee.CreatedDate ASC Limit 50]:[SELECT Id, PermissionSetId, PermissionSet.Name, PermissionSetGroupId, PermissionSetGroup.DeveloperName, AssigneeId, Assignee.CreatedDate, Assignee.LastLoginDate FROM PermissionSetAssignment WHERE AssigneeId IN :userList]);
        return perm;
    }

    public static List<PermissionSetLicenseAssign> retrievePermissionSetLicenseAssignments(Set<String> permissionSetLicenseAssignList, List<User> userList){     
        List<PermissionSetLicenseAssign> perm =  (System.Test.isRunningTest()?[SELECT Id, PermissionSetLicenseId, PermissionSetLicense.DeveloperName, AssigneeId,Assignee.CreatedDate, Assignee.LastLoginDate  FROM PermissionSetLicenseAssign WHERE AssigneeId IN :userList ORDER BY Assignee.CreatedDate ASC Limit 50]:[SELECT Id, PermissionSetLicenseId, PermissionSetLicense.DeveloperName, AssigneeId,Assignee.CreatedDate, Assignee.LastLoginDate  FROM PermissionSetLicenseAssign WHERE AssigneeId IN :userList]);
        return perm;        
    }

    public static List<CBK_PermissionRecycleSettings__mdt> retrieveConfigPermission(){
        list <CBK_PermissionRecycleSettings__mdt> mcs = CBK_PermissionRecycleSettings__mdt.getAll().values();
        list <CBK_PermissionRecycleSettings__mdt> activos = new list <CBK_PermissionRecycleSettings__mdt>();
        for (CBK_PermissionRecycleSettings__mdt mc : mcs){
            if(mc.CBK_Activo__c){
                activos.add(mc);
            }
        }
        if (System.Test.isRunningTest()){
                //insertamos las entradas necesarias para los tests de CBK_PermissionUtils_Test
                User us = [SELECT Id,LastLoginDate,createdDate FROM User WHERE UserType= 'Standard' AND IsActive = true AND UserRoleId != null ORDER BY LastLoginDate  DESC NULLS LAST LIMIT 1];
                integer daysCheck = System.Math.abs(Date.today().daysBetween(date.valueof(((us.LastLoginDate != null)?us.LastLoginDate:(us.createdDate != null)?us.createdDate:Date.today().addDays(-900))-5)));
            
            
            List <PermissionSetLicense> listPSL = [SELECT Id,DeveloperName FROM PermissionSetLicense ORDER BY ID DESC LIMIT 2];
            List <PermissionSet> listPS = [SELECT Id, Name FROM PermissionSet WHERE PermissionSetGroupId = null and iscustom = true and IsOwnedByProfile = false AND LicenseId = null ORDER BY ID DESC LIMIT 4];
            List <PermissionSet> listPSG = [SELECT Id, Name, PermissionSetGroup.DeveloperName FROM PermissionSet WHERE PermissionSetGroupId != null and iscustom = true and IsOwnedByProfile = false AND LicenseId = null ORDER BY ID DESC LIMIT 4];
            List <CustomPermission> listCP = [SELECT Id, DeveloperName FROM CustomPermission LIMIT 1];

            CBK_PermissionRecycleSettings__mdt cfg2 = new CBK_PermissionRecycleSettings__mdt();
            cfg2.CBK_Activo__c = true;
            cfg2.DeveloperName = 'Test_2';
            cfg2.CBK_NombrePermisoOrigen__c = String.ValueOf(listPSL[0].DeveloperName);
            cfg2.CBK_NombrePermisoDestino__c = String.ValueOf(listPSL[1].DeveloperName);
            cfg2.CBK_DiasInactividad__c = daysCheck;
            cfg2.CBK_Operacion__c = 'CBK_Modificacion_PSL_PSL';
            cfg2.CBK_DesactivarUsuario__c = false;
            activos.add(cfg2);
			CBK_PermissionRecycleSettings__mdt cfg3 = new CBK_PermissionRecycleSettings__mdt();
            cfg3.CBK_Activo__c = true;
            cfg3.DeveloperName = 'Test_3';
            cfg3.CBK_NombrePermisoOrigen__c = String.ValueOf(listPS[0].Name);
            cfg3.CBK_NombrePermisoDestino__c = String.ValueOf(listPS[1].Name);
            cfg3.CBK_DiasInactividad__c = daysCheck;
            cfg3.CBK_Operacion__c = 'CBK_Modificacion_PS_PS';
            cfg3.CBK_DesactivarUsuario__c = false;
            activos.add(cfg3);
			CBK_PermissionRecycleSettings__mdt cfg4 = new CBK_PermissionRecycleSettings__mdt();
            cfg4.CBK_Activo__c = true;
            cfg4.DeveloperName = 'Test_4';
            cfg4.CBK_NombrePermisoOrigen__c = String.ValueOf(listPS[2].Name);
            cfg4.CBK_NombrePermisoDestino__c = String.ValueOf(listPSG[0].PermissionSetGroup.DeveloperName);
            cfg4.CBK_DiasInactividad__c = daysCheck;
            cfg4.CBK_Operacion__c = 'CBK_Modificacion_PS_PSG';
            cfg4.CBK_DesactivarUsuario__c = true;
            activos.add(cfg4);
			CBK_PermissionRecycleSettings__mdt cfg5 = new CBK_PermissionRecycleSettings__mdt();
            cfg5.CBK_Activo__c = true;
            cfg5.DeveloperName = 'Test_5';
            cfg5.CBK_NombrePermisoOrigen__c = String.ValueOf(listPSG[1].PermissionSetGroup.DeveloperName);
            cfg5.CBK_NombrePermisoDestino__c =  String.ValueOf(listPS[3].Name);
            cfg5.CBK_DiasInactividad__c = daysCheck;
            cfg5.CBK_Operacion__c = 'CBK_Modificacion_PSG_PS';
            cfg5.CBK_DesactivarUsuario__c = false;
            activos.add(cfg5);
			CBK_PermissionRecycleSettings__mdt cfg6 = new CBK_PermissionRecycleSettings__mdt();
            cfg6.CBK_Activo__c = true;
            cfg6.DeveloperName = 'Test_6';
            cfg6.CBK_NombrePermisoOrigen__c =  String.ValueOf(listPSG[2].PermissionSetGroup.DeveloperName);
            cfg6.CBK_NombrePermisoDestino__c =  String.ValueOf(listPSG[3].PermissionSetGroup.DeveloperName);
            cfg6.CBK_DiasInactividad__c = daysCheck;
            cfg6.CBK_Operacion__c = 'CBK_Modificacion_PSG_PSG';
            cfg6.CBK_DesactivarUsuario__c = true;
            activos.add(cfg6);

            CBK_PermissionRecycleSettings__mdt cfg7 = new CBK_PermissionRecycleSettings__mdt();
            cfg7.CBK_Activo__c = true;
            cfg7.DeveloperName = 'Test_7';
            cfg7.CBK_NombrePermisoOrigen__c =  String.ValueOf(listPS[3].Name);
            cfg7.CBK_NombrePermisoDestino__c =  null;
            cfg7.CBK_DiasInactividad__c = daysCheck;
            cfg7.CBK_Operacion__c = 'CBK_Exclusion_PS';
            cfg7.CBK_DesactivarUsuario__c = false;
            activos.add(cfg7);

            CBK_PermissionRecycleSettings__mdt cfg8 = new CBK_PermissionRecycleSettings__mdt();
            cfg8.CBK_Activo__c = true;
            cfg8.DeveloperName = 'Test_8';
            cfg8.CBK_NombrePermisoOrigen__c =  String.ValueOf(listCP[0].DeveloperName);
            cfg8.CBK_NombrePermisoDestino__c =  null;
            cfg8.CBK_DiasInactividad__c = daysCheck;
            cfg8.CBK_Operacion__c = 'CBK_Exclusion_CP';
            cfg8.CBK_DesactivarUsuario__c = false;
            activos.add(cfg8);

            }
        return activos;
    }

    public static Map<String,PermissionSet> getMapPermissionSetsForGroupsByGroup(){
        Map<String,PermissionSet> psForPsgs = new Map<String,PermissionSet>();
        for (PermissionSet ps : [SELECT Id, Name,PermissionSetGroupId, PermissionSetGroup.DeveloperName FROM PermissionSet WHERE PermissionSetGroupId != null]){
            psForPsgs.put(ps.PermissionSetGroup.DeveloperName, ps);
        }
        return psForPsgs;
    }

    public static Map<String,PermissionSet> getMapPermissionSets(){
        Map<String,PermissionSet> pss = new Map<String,PermissionSet>();
        for (PermissionSet ps : [SELECT Id, Name FROM PermissionSet WHERE PermissionSetGroupId = null and iscustom = true and IsOwnedByProfile = false]){
            pss.put(ps.Name, ps);
        }
        return pss;
    }

    public static Map<String,PermissionSetLicense> getMapPermissionSetLicenses(){
        Map<String,PermissionSetLicense> psl = new Map<String,PermissionSetLicense>();
        for (PermissionSetLicense ps : [SELECT Id, DeveloperName FROM PermissionSetLicense]){
            psl.put(ps.DeveloperName, ps);
        }
        return psl;
    }

    public static void recyclePermissionSets(List<Id> recycledPermissionSetIDs){
        if (recycledPermissionSetIDs.size()>0){
            List <PermissionSetAssignment> delPS = [SELECT id FROM PermissionSetAssignment WHERE ID in :recycledPermissionSetIDs];
            if (delPS != null && delPS.size()>0) {
                delete delPS;
            }
        }
    }

    /*
    public static void recyclePermissionSetLicenses(List<Id> recycledPermissionSetLicenseIDs){
        if (recycledPermissionSetLicenseIDs.size()>0){
            List <PermissionSetLicenseAssign> delPSL = [SELECT id FROM PermissionSetLicenseAssign WHERE Id in :recycledPermissionSetLicenseIDs];
            if (delPSL != null && delPSL.size()>0) {
                delete delPSL;
            }
        }
    }*/

    public static void recyclePermissionSetLicenses(List<Id> recycledPermissionSetLicenseIDs){
        if (recycledPermissionSetLicenseIDs != null && !recycledPermissionSetLicenseIDs.isEmpty()){
            // Validar permisos de CRUD para PermissionSetLicenseAssign
            if (Schema.sObjectType.PermissionSetLicenseAssign.isDeletable()) {
                // Realizar la consulta SOQL y eliminar los registros si es posible
                List <PermissionSetLicenseAssign> delPSL = [SELECT id FROM PermissionSetLicenseAssign WHERE Id IN :recycledPermissionSetLicenseIDs];
                if (!delPSL.isEmpty()) {
                    delete delPSL;
                }
            } else {
                // Manejar la falta de permisos adecuadamente
                System.debug('No tienes permisos para eliminar PermissionSetLicenseAssign');
                // Agrega aquí tu lógica para manejar el caso en que no tienes permisos de eliminación
            }
        }
    }

    
    public static void deactivateUsers(List<Id> usersIds){
        if (usersIds.size()>0){
            List <User> actUsers = new List<User>();
            for (User us : [SELECT CBK_VIP__c,id, IsActive,CommunityNickname,Username,EmployeeNumber,FederationIdentifier,AV_ExternalID__c FROM User WHERE ID in :usersIds AND IsActive = true]){
                
                if (!us.CBK_VIP__c){   //Comprobamos que no sea VIP el usuario a desactivar
                    us.IsActive = false;
                
                    //Actualizaciones para actulizar al usuario
                    Datetime now = Datetime.now();
                    Date fechaHoy = Date.today();
                    //String fechaFormateada = String.valueOf(fechaHoy.year()) + String.valueOf(fechaHoy.month()).leftPad(2, '0') + String.valueOf(fechaHoy.day()).leftPad(2, '0');
                    String fechaHoraMinutos = now.format('yyyyMMddHHmm');
                    String fechaFormateada = now.format('yyyyMMdd');

                    us.Username  = (us.Username + '.old' + Datetime.now().format('yyyyMMddHHmmss')).left(80);              // String 80
                    us.CommunityNickname = (us.CommunityNickname + '.old' + fechaHoraMinutos).left(40); // String 40
                    us.EmployeeNumber = (us.EmployeeNumber + '.old' + fechaFormateada).left(20);    //String 20
                    us.FederationIdentifier = (us.FederationIdentifier + '.old' + Datetime.now().format('yyyyMMddHHmmss')).left(512);    //String 512
                    us.AV_ExternalID__c = (us.AV_ExternalID__c + '.old' + fechaFormateada).left(255);       //String 255
                    actUsers.add(us);
                }
            }
            if (actUsers.size()>0){
                
                update actUsers;
            }     
        }
    }
    public static void createPermissionSetAssignments(List<PermissionSetAssignment> convertedPermissionSets){
        if (convertedPermissionSets != null && convertedPermissionSets.size()>0) {
            insert convertedPermissionSets;
        }
    }
    public static void createPermissionSetLicenseAssigns(List<PermissionSetLicenseAssign> convertedPermissionSetLicenses){
        if (convertedPermissionSetLicenses != null && convertedPermissionSetLicenses.size()>0) {
            insert convertedPermissionSetLicenses;
        }
    }
    
    public static Set<Id> retrieveExcludedUsers() {
        Set<Id> idUsersExcluidos = new Set<Id>();
        List <String> psExclusion = new List <String>();
        List <String> cpExclusion = new List <String>();
        Set<String> psCpExclusion = new Set<String>();
        List <SetupEntityAccess> lstcpExclusion = new List <SetupEntityAccess>();
        List<CBK_PermissionRecycleSettings__mdt> configRecyclePerms = CBK_PermissionUtils.retrieveConfigPermission();
        for (CBK_PermissionRecycleSettings__mdt cfg : configRecyclePerms){
            if(cfg.CBK_Operacion__c == 'CBK_Exclusion_PS'){
                psExclusion.add(cfg.CBK_NombrePermisoOrigen__c);
            }
            if(cfg.CBK_Operacion__c == 'CBK_Exclusion_CP'){
                cpExclusion.add(cfg.CBK_NombrePermisoOrigen__c);
            }
        }
        if (cpExclusion.size()>0){
            //psCpExclusion = new Map<String,SetupEntityAccess>([SELECT Parent.Name from SetupEntityAccess where SetupEntityType = 'CustomPermission' AND SetupEntityId IN (SELECT Id FROM CustomPermission WHERE DeveloperName IN :cpExclusion)]).keyset();
            lstcpExclusion = [SELECT Parent.Name from SetupEntityAccess where SetupEntityType = 'CustomPermission' AND SetupEntityId IN (SELECT Id FROM CustomPermission WHERE DeveloperName IN :cpExclusion)];
            for (SetupEntityAccess sea : lstcpExclusion){
                psCpExclusion.add(sea.Parent.Name);
            }
        }
        psCpExclusion.addAll(psExclusion);

        if (psCpExclusion.size()>0){
            idUsersExcluidos = new Map<Id,PermissionSetAssignment>([SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId in (SELECT Id FROM PermissionSet WHERE Name IN :psCpExclusion)]).keyset();
        }
        return idUsersExcluidos;
    }


}