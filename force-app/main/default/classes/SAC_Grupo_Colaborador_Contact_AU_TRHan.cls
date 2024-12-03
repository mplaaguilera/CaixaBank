/*********************************************************************************************************
 * Name: SAC_Grupo_Colaborador_Contact_AU_TRHan
 * Copyright © 2019  CaixaBank
 *  
 * Proposito: Trigger Handler para controlar el After Update del objeto Grupo_Colaborador_Contact__c
 *              Esta clase se testea con SAC_GrupoColaboradorContact_Test
 *  
 * Historial
 * -------
 * VERSION        USER_STORY            AUTHOR               DATE             Description
 * 1.0            US206848              Marcela Neira        22/04/21            Creación
**********************************************************************************************************/

public with sharing class SAC_Grupo_Colaborador_Contact_AU_TRHan extends CC_TriggerHandlerBase {
    private static Set<String> objetos = new Set<String>{'CC_Grupo_Colaborador__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPEPROVEEDORES = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SAC_GrupoProveedores').getRecordTypeId();
    private static final Id RECTYPELETRADOS = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SAC_Letrados').getRecordTypeId();

    private static final String COPS = 'COPS';

    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<CC_Grupo_Colaborador_Contact__c>)tp.newList, (Map<Id, CC_Grupo_Colaborador_Contact__c>)tp.newMap, (List<CC_Grupo_Colaborador_Contact__c>)tp.oldList, (Map<Id, CC_Grupo_Colaborador_Contact__c>)tp.oldMap);
    }
    private void process(List<CC_Grupo_Colaborador_Contact__c> listNewObj, Map<Id, CC_Grupo_Colaborador_Contact__c> mapNewObj, List<CC_Grupo_Colaborador_Contact__c> listOldObj, Map<Id, CC_Grupo_Colaborador_Contact__c> mapOldObj) {
        
        SAC_ActualizacionUsuario.actualizar(listNewObj,listOldObj); 

        List<Id> listaIdesGrupos = new List<Id>();
        Map<Id, CC_Grupo_Colaborador_Contact__c> mapaCOPSNew = new Map<Id, CC_Grupo_Colaborador_Contact__c>();
        Map<Id, CC_Grupo_Colaborador_Contact__c> mapaCOPSOld = new Map<Id, CC_Grupo_Colaborador_Contact__c>();
        List<CC_Grupo_Colaborador_Contact__c> listaAuditoresAdd = new List<CC_Grupo_Colaborador_Contact__c>();
        List<CC_Grupo_Colaborador_Contact__c> listaAuditoresDelete = new List<CC_Grupo_Colaborador_Contact__c>();

        List<CC_Grupo_Colaborador__c> listGrupoCOPS = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name =: COPS];
        List<CC_Grupo_Colaborador__c> listGruposProvAndLetrados = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE RecordTypeId =: RECTYPEPROVEEDORES OR RecordTypeId =: RECTYPELETRADOS];

        String copsGrupoId = '';
        List<Id> listGruposProvAndLetIds = New List<Id>();

        if(!listGrupoCOPS.isEmpty()){
            copsGrupoId = listGrupoCOPS[0].Id;
        } 
        if(!listGruposProvAndLetrados.isEmpty()){
            for(CC_Grupo_Colaborador__c gprovlet : listGruposProvAndLetrados){
                listGruposProvAndLetIds.add(gprovlet.Id);
            }
        }

        for (CC_Grupo_Colaborador_Contact__c gcc : listNewObj) {
            listaIdesGrupos.add(gcc.CC_Grupo_Colaborador__c);

            if(copsGrupoId != '' && gcc.CC_Grupo_Colaborador__c == Id.valueOf(copsGrupoId)){
                mapaCOPSNew.put(gcc.id, gcc);
            }

            if(listGruposProvAndLetIds.contains(gcc.CC_Grupo_Colaborador__c) && gcc.SAC_Auditor__c == true){
                //US770903 Auditorias / Raúl Santos / Añadimos el PS de Auditorias
                listaAuditoresAdd.add(gcc);
            }else if(listGruposProvAndLetIds.contains(gcc.CC_Grupo_Colaborador__c) && gcc.SAC_Auditor__c == false){
                //US770903 Auditorias / Raúl Santos / Eliminamos el PS de Auditorias
                listaAuditoresDelete.add(gcc);
            }
        }

        for (CC_Grupo_Colaborador_Contact__c gcc : listOldObj) {
            if(copsGrupoId != '' && gcc.CC_Grupo_Colaborador__c == Id.valueOf(copsGrupoId)){
                mapaCOPSOld.put(gcc.id, gcc);
            }
        }

        if(!listaIdesGrupos.isEmpty()){
            SAC_GrupoColaboradorContact.recalcularUsuarioActivos(listaIdesGrupos);
            SAC_ActualizacionUsuario.actualizarSupervisores(mapNewObj, mapOldObj);
        }  
        
        if(!mapaCOPSNew.isEmpty() && !mapaCOPSOld.isEmpty()){
            SAC_ActualizacionUsuario.actualizarAdministradores(mapaCOPSNew, mapaCOPSOld);
        }

        if(!listaAuditoresAdd.isEmpty()){
            SAC_AdministrarUsuarios.asignarPermissionSetAuditores(listaAuditoresAdd, 'agregar');
        }
        if(!listaAuditoresDelete.isEmpty()){
            SAC_AdministrarUsuarios.asignarPermissionSetAuditores(listaAuditoresDelete, 'eliminar');
        }
       
    }
    
}