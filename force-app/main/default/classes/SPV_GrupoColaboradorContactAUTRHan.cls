/*********************************************************************************************************
 * Name: SPV_GrupoColaboradorContactAUTRHan
 * Copyright © 2024  CaixaBank
 * 
 * Proposito: Trigger Handler para controlar el After Update del objeto Grupo_Colaborador_Contact__c
 *              Esta clase se testea con SPV_GrupoColaboradorContact_Test
 * 
 * Historial
 * -------
 * VERSION        USER_STORY            AUTHOR               DATE             Description
 * 1.0             US828257           Raúl Santos          29/04/24             Creación
**********************************************************************************************************/

public with sharing class SPV_GrupoColaboradorContactAUTRHan extends CC_TriggerHandlerBase{

    private static Set<String> objetos = new Set<String>{'CC_Grupo_Colaborador__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPEGESTORES = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SPV_GrupoGestor').getRecordTypeId();
    private static final Id RECTYPELETRADOS = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SPV_GrupoLetrado').getRecordTypeId();
    private static final Id RECTYPETAREAS = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SPV_GrupoDeTareas').getRecordTypeId();

    private static final String PS_ADMINGRUPO = 'SPV_AdministradorGrupos';
    private static final String COPS = 'SPV_COPS';
    private static final String AJ = 'SPV_AJ';
    private static final String GRUPO_AUDITOR = 'SPV_GrupoAuditor';

    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<CC_Grupo_Colaborador_Contact__c>)tp.newList, (Map<Id, CC_Grupo_Colaborador_Contact__c>)tp.newMap, (List<CC_Grupo_Colaborador_Contact__c>)tp.oldList, (Map<Id, CC_Grupo_Colaborador_Contact__c>)tp.oldMap);
    }

    private void process(List<CC_Grupo_Colaborador_Contact__c> listNewObj, Map<Id, CC_Grupo_Colaborador_Contact__c> mapNewObj, List<CC_Grupo_Colaborador_Contact__c> listOldObj, Map<Id, CC_Grupo_Colaborador_Contact__c> mapOldObj) {

        List<CC_Grupo_Colaborador__c> listGruposSPV = new List<CC_Grupo_Colaborador__c>();
        List<CC_Grupo_Colaborador_Contact__c> listGrupoColabContactSPV = new List<CC_Grupo_Colaborador_Contact__c>();

        List<CC_Grupo_Colaborador_Contact__c> listAdminsGrupoAdd = new List<CC_Grupo_Colaborador_Contact__c>();
        List<CC_Grupo_Colaborador_Contact__c> listAdminsGrupoDelete = new List<CC_Grupo_Colaborador_Contact__c>();
      
        Set<Id> setIdsGruposColab = new Set<Id>();
        Set<Id> setIdGruposColaboradores = new Set<Id>();
        Set<Id> setIdGruposGestores = new Set<Id>();
        Set<Id> setIdGruposLetrados = new Set<Id>();
        Set<Id> setIdGruposTareas = new Set<Id>();
        Set<Id> setIdGrupoCops = new Set<Id>();
        Set<Id> setIdGrupoAj = new Set<Id>();

        
        //Recupero el id del grupo asociado al colaborador de la lista
        for (CC_Grupo_Colaborador_Contact__c gcc : listNewObj){
            if(String.isNotBlank(gcc.CC_Grupo_Colaborador__c)){
                setIdGruposColaboradores.add(gcc.CC_Grupo_Colaborador__c);
            }
        }

        //Recupero los grupos de SPV cuyo id se encuentra entre los grupos de los colaboradores
        if(Schema.sObjectType.CC_Grupo_Colaborador__c.isAccessible()){
            listGruposSPV = [SELECT Id, Name, RecordType.DeveloperName FROM CC_Grupo_Colaborador__c WHERE (RecordTypeId =: RECTYPEGESTORES OR RecordTypeId =: RECTYPELETRADOS OR RecordTypeId =: RECTYPETAREAS) 
                                AND Id IN :setIdGruposColaboradores];
        }

        //Almaceno el id de los grupos obtenidos según su RT
        if(!listGruposSPV.isEmpty()){
            for(CC_Grupo_Colaborador__c grupo : listGruposSPV){
                if(grupo.RecordTypeId == RECTYPEGESTORES) {
                    setIdGruposGestores.add(grupo.Id);
                }else if(grupo.RecordTypeId == RECTYPELETRADOS) {
                    setIdGruposLetrados.add(grupo.Id);
                }else if(grupo.RecordTypeId == RECTYPETAREAS) {
                    setIdGruposTareas.add(grupo.Id);
                    if(grupo.SAC_DeveloperName__c == COPS){
                        setIdGrupoCops.add(grupo.Id);
                    }else if(grupo.SAC_DeveloperName__c == AJ){
                        setIdGrupoAj.add(grupo.Id);
                    }
                }
            }
        }

        //Recorro la lista de colaboradores filtrado para quedarme solo con aquellos que pertenecen a grupos de SPV
        for (CC_Grupo_Colaborador_Contact__c gcc : listNewObj){
            
            if(setIdGruposGestores.contains(gcc.CC_Grupo_Colaborador__c) || setIdGruposLetrados.contains(gcc.CC_Grupo_Colaborador__c) || setIdGruposTareas.contains(gcc.CC_Grupo_Colaborador__c)){
                listGrupoColabContactSPV.add(gcc);
                setIdsGruposColab.add(gcc.CC_Grupo_Colaborador__c);
            }

            if((setIdGruposGestores.contains(gcc.CC_Grupo_Colaborador__c) || setIdGruposLetrados.contains(gcc.CC_Grupo_Colaborador__c)) && mapOldObj.containsKey(gcc.Id) && mapOldObj.get(gcc.Id).SAC_Administrador__c != gcc.SAC_Administrador__c){
                if(gcc.SAC_Administrador__c == true){
                    listAdminsGrupoAdd.add(gcc);
                }else if(gcc.SAC_Administrador__c == false){
                    listAdminsGrupoDelete.add(gcc);
                }
            }
        }

        if(!listGrupoColabContactSPV.isEmpty()){
            SPV_GrupoColaboradorContactHelper.actualizarGruposPertenecientesUser(listGrupoColabContactSPV, null);
            SPV_GrupoColaboradorContactHelper.recalcularUsuarioActivos(setIdsGruposColab);
        }

        if(!listAdminsGrupoAdd.isEmpty()){
            //Le asigno al usuario colaborador el permission set de administrador de grupos
            SPV_GrupoColaboradorContactHelper.procesarPermissionSet(listAdminsGrupoAdd, 'agregar', PS_ADMINGRUPO);
            SPV_GrupoColaboradorContactHelper.procesarPublicGroup(listAdminsGrupoAdd, 'agregar', GRUPO_AUDITOR);
        }
        if(!listAdminsGrupoDelete.isEmpty()){
            //Le quito al usuario colaborador el permission set de administrador de grupos
            SPV_GrupoColaboradorContactHelper.procesarPermissionSet(listAdminsGrupoDelete, 'eliminar', PS_ADMINGRUPO);
            SPV_GrupoColaboradorContactHelper.procesarPublicGroup(listAdminsGrupoDelete, 'eliminar', GRUPO_AUDITOR);
        }
    }
}