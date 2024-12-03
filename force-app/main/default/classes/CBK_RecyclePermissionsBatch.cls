/**********************************************************************************************************************
 Name:	  CBK_RecyclePermissionsBatch
 Copyright © 2021  CaixaBank
=======================================================================================================================
Proposito: Clase batch para el purgado del FW de purgado.
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								Francisco Zaragoza	18/04/2022			Init version
***********************************************************************************************************************/
global with sharing class CBK_RecyclePermissionsBatch implements Database.Batchable<CBK_Permission>, Database.Stateful {
    global Integer recordsProcessed = 0;
    global List<CBK_PermissionRecycleSettings__mdt> configRecyclePerms = CBK_PermissionUtils.retrieveConfigPermission();
    global Map <String,CBK_PermissionRecycleSettings__mdt> monitoredPSName = new Map <String,CBK_PermissionRecycleSettings__mdt>();
    global Map <String,CBK_PermissionRecycleSettings__mdt> monitoredPSGName = new Map <String,CBK_PermissionRecycleSettings__mdt>();
    global Map <String,CBK_PermissionRecycleSettings__mdt> monitoredPSLName = new Map <String,CBK_PermissionRecycleSettings__mdt>();
    global Map<String,PermissionSet> MapPermissionSetsForGroupsByGroup = CBK_PermissionUtils.getMapPermissionSetsForGroupsByGroup();
    global Map<String,PermissionSet> MapPermissionSets  = CBK_PermissionUtils.getMapPermissionSets();
    global Map<String,PermissionSetLicense> MapPermissionSetLicenses = CBK_PermissionUtils.getMapPermissionSetLicenses();
 
    /**
    * @description Start method of the batch process
    * @author fzaragoza | 18-04-2022 
    * @param Database.BatchableContext bc 
    * @return Iterable 
    **/
    global  Iterable<CBK_Permission> start(Database.BatchableContext bc) { 
        for (CBK_PermissionRecycleSettings__mdt cfg : configRecyclePerms){
            switch on cfg.CBK_Operacion__c {
                when 'CBK_Baja_PSL','CBK_Modificacion_PSL_PSL'{ 
                    monitoredPSLName.put(cfg.CBK_NombrePermisoOrigen__c,cfg);
                }
                when 'CBK_Baja_PS','CBK_Modificacion_PS_PSG','CBK_Modificacion_PS_PS'{
                    monitoredPSName.put(cfg.CBK_NombrePermisoOrigen__c,cfg);
                }
                when 'CBK_Baja_PSG','CBK_Modificacion_PSG_PSG','CBK_Modificacion_PSG_PS'{ 
                    monitoredPSGName.put(cfg.CBK_NombrePermisoOrigen__c,cfg);
                }
            }
        }
        return new CBK_PermissionIterable();
    }

    /**
    * @description Execute method of the batch process
    * @author fzaragoza | 18-04-2022 
    * @param Database.BatchableContext bc 
    * @param List<CBK_Permission> scope 
    **/
    public void execute(Database.BatchableContext bc, List<CBK_Permission> scope){
        List <Id> recycledPermissionSetIDs = new List <Id>();
        List <Id> recycledPermissionSetLicenseIDs = new List <Id>();
        Set <Id> deactivateUsers = new Set <Id>();
        List <PermissionSetAssignment> convertedPermissionSets = new List <PermissionSetAssignment>();
        List <PermissionSetLicenseAssign> convertedPermissionSetLicenses = new List <PermissionSetLicenseAssign>();
        try{
            for(CBK_Permission checkPerm : scope){
                recordsProcessed++;
                switch on String.ValueOf(checkPerm.type) {
                    //aunque el código de PERMISSIONSET y PERMISSIONSETGROUP son casi identicos, no se pueden agrupar; porque los uniqueNames salen de campos distintos, y por tanto no se pueden agrupar en el mismo mapa por el posible caso de coincidencias entre ambos tipos.
                    when 'PERMISSIONSET' { 
                        if(monitoredPSName.containsKey(checkPerm.uniquePermissionName)){
                            if (monitoredPSName.get(checkPerm.uniquePermissionName).CBK_DiasInactividad__c<checkPerm.currentLogoutDays){
                                recycledPermissionSetIDs.add(checkPerm.idPermiso);
                                switch on monitoredPSName.get(checkPerm.uniquePermissionName).CBK_Operacion__c {
                                    when 'CBK_Modificacion_PS_PS' {
                                        convertedPermissionSets.add(new PermissionSetAssignment(PermissionSetId = MapPermissionSets.get(monitoredPSName.get(checkPerm.uniquePermissionName).CBK_NombrePermisoDestino__c).Id, AssigneeId = checkPerm.userId));
                                    }
                                    when 'CBK_Modificacion_PS_PSG' { 
                                        convertedPermissionSets.add(new PermissionSetAssignment(AssigneeId = checkPerm.userId, PermissionSetGroupId = MapPermissionSetsForGroupsByGroup.get(monitoredPSName.get(checkPerm.uniquePermissionName).CBK_NombrePermisoDestino__c).PermissionSetGroupId));
                                    }
                                }
                                if(monitoredPSName.get(checkPerm.uniquePermissionName).CBK_DesactivarUsuario__c){
                                    deactivateUsers.add(checkPerm.userId);
                                }
                            }
                        }
                    }
                    when 'PERMISSIONSETGROUP' {
                        if(monitoredPSGName.containsKey(checkPerm.uniquePermissionName)){
                            if (monitoredPSGName.get(checkPerm.uniquePermissionName).CBK_DiasInactividad__c<checkPerm.currentLogoutDays){
                                recycledPermissionSetIDs.add(checkPerm.idPermiso);
                                switch on monitoredPSGName.get(checkPerm.uniquePermissionName).CBK_Operacion__c {
                                    when 'CBK_Modificacion_PSG_PS' {
                                        convertedPermissionSets.add(new PermissionSetAssignment(PermissionSetId = MapPermissionSets.get(monitoredPSGName.get(checkPerm.uniquePermissionName).CBK_NombrePermisoDestino__c).Id, AssigneeId = checkPerm.userId));
                                    }
                                    when 'CBK_Modificacion_PSG_PSG' { 
                                        convertedPermissionSets.add(new PermissionSetAssignment(AssigneeId = checkPerm.userId, PermissionSetGroupId = MapPermissionSetsForGroupsByGroup.get(monitoredPSGName.get(checkPerm.uniquePermissionName).CBK_NombrePermisoDestino__c).PermissionSetGroupId));
                                    }
                                }
                                if(monitoredPSGName.get(checkPerm.uniquePermissionName).CBK_DesactivarUsuario__c){
                                    deactivateUsers.add(checkPerm.userId);
                                }
                            }
                        }
                    }
                    when 'PERMISSIONSETLICENSE' { 
                        if(monitoredPSLName.containsKey(checkPerm.uniquePermissionName)){
                            if (monitoredPSLName.get(checkPerm.uniquePermissionName).CBK_DiasInactividad__c<checkPerm.currentLogoutDays){
                                recycledPermissionSetLicenseIDs.add(checkPerm.idPermiso);
                                if(monitoredPSLName.get(checkPerm.uniquePermissionName).CBK_Operacion__c == 'CBK_Modificacion_PSL_PSL') {
                                    convertedPermissionSetLicenses.add(new PermissionSetLicenseAssign(PermissionSetLicenseId = MapPermissionSetLicenses.get(monitoredPSLName.get(checkPerm.uniquePermissionName).CBK_NombrePermisoDestino__c).Id, AssigneeId = checkPerm.userId));
                                }
                                if(monitoredPSLName.get(checkPerm.uniquePermissionName).CBK_DesactivarUsuario__c){
                                    deactivateUsers.add(checkPerm.userId);
                                }
                            }
                        }
                    }
                }
            }

            CBK_PermissionUtils.recyclePermissionSets(recycledPermissionSetIDs);
            CBK_PermissionUtils.recyclePermissionSetLicenses(recycledPermissionSetLicenseIDs);
            CBK_PermissionUtils.createPermissionSetAssignments(convertedPermissionSets);
            CBK_PermissionUtils.createPermissionSetLicenseAssigns(convertedPermissionSetLicenses);
            list<Id> lstUsers = new list<Id>();
            lstUsers.addAll(deactivateUsers);
            CBK_PermissionUtils.deactivateUsers(lstUsers);       
        }catch(System.Exception e){
            CBK_Log.error(e);
        }
    }	

    /**
    * @description Finish method of the batch process
    * @author fzaragoza | 28-04-2022 
    * @param Database.BatchableContext bc 
    **/
    global void finish(Database.BatchableContext bc){
        CBK_Log.debug('Record Processed: ' + recordsProcessed);
    }

}