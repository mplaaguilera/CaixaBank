/*********************************************************************************************************
 * Name: SPV_GrupoColaboradorContactBDTRHan
 * Copyright © 2024  CaixaBank
 * 
 * Proposito: Trigger Handler para controlar el Before Delete del objeto Grupo_Colaborador_Contact__c
 *              Esta clase se testea con SPV_GrupoColaboradorContact_Test
 * 
 * Historial
 * -------
 * VERSION        USER_STORY            AUTHOR               DATE             Description
 * 1.0             US828257           Raúl Santos          29/04/24             Creación
**********************************************************************************************************/
public with sharing class SPV_GrupoColaboradorContactBDTRHan extends CC_TriggerHandlerBase{

    private static Set<String> objetos = new Set<String>{'CC_Grupo_Colaborador__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPEGESTORES = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SPV_GrupoGestor').getRecordTypeId();
    private static final Id RECTYPELETRADOS = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SPV_GrupoLetrado').getRecordTypeId();
    private static final Id RECTYPETAREAS = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SPV_GrupoDeTareas').getRecordTypeId();

    private static final String PS_ADMINISTRADOR = 'SPV_Administrador';
    private static final String PS_GENERAL = 'SPV_General';

    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<CC_Grupo_Colaborador_Contact__c>)tp.newList, (Map<Id, CC_Grupo_Colaborador_Contact__c>)tp.newMap, (List<CC_Grupo_Colaborador_Contact__c>)tp.oldList, (Map<Id, CC_Grupo_Colaborador_Contact__c>)tp.oldMap);
	}

    private void process(List<CC_Grupo_Colaborador_Contact__c> listNewObj, Map<Id, CC_Grupo_Colaborador_Contact__c> mapNewObj, List<CC_Grupo_Colaborador_Contact__c> listOldObj, Map<Id, CC_Grupo_Colaborador_Contact__c> mapOldObj) {

        List<CC_Grupo_Colaborador__c> listGruposSPV = new List<CC_Grupo_Colaborador__c>();
        List<CC_Grupo_Colaborador_Contact__c> listNewObjFiltrada = new List<CC_Grupo_Colaborador_Contact__c>();

        Set<Id> setIdGruposColaboradores = new Set<Id>();
        Set<Id> setIdGruposFiltrados = new Set<Id>();

        //Recupero el id del grupo asociado al colaborador de la lista
        for (CC_Grupo_Colaborador_Contact__c gcc : listOldObj){
            if(String.isNotBlank(gcc.CC_Grupo_Colaborador__c)){
                setIdGruposColaboradores.add(gcc.CC_Grupo_Colaborador__c);
            }
        }

        //Recupero los grupos de SPV cuyo id se encuentra entre los grupos de los colaboradores
        if(Schema.sObjectType.CC_Grupo_Colaborador__c.isAccessible()){
            listGruposSPV = [SELECT Id, RecordTypeId FROM CC_Grupo_Colaborador__c WHERE (RecordTypeId =: RECTYPEGESTORES OR RecordTypeId =: RECTYPELETRADOS OR RecordTypeId =: RECTYPETAREAS)
                                AND Id IN: setIdGruposColaboradores];
        }

        //Almaceno el id de los grupos obtenidos
        if(!listGruposSPV.isEmpty()){
            for(CC_Grupo_Colaborador__c grupo : listGruposSPV){
                if(grupo.RecordTypeId == RECTYPEGESTORES || grupo.RecordTypeId == RECTYPELETRADOS || grupo.RecordTypeId == RECTYPETAREAS) {
                    setIdGruposFiltrados.add(grupo.Id);
                }
            }
        }

        //Recorro la lista de colaboradores filtrado para quedarme solo con aquellos que pertenecen a grupos de SPV
        for (CC_Grupo_Colaborador_Contact__c gcc : listOldObj){
            if(setIdGruposFiltrados.contains(gcc.CC_Grupo_Colaborador__c)){
                listNewObjFiltrada.add(gcc);
            }
        }

        if(!listNewObjFiltrada.isEmpty()){
            Boolean esDeSPV = false;
            Boolean esAdmin = false;

            //Compruebo si el usuario actual tiene los permisos de SPV administrador o SPV general
            List<PermissionSetAssignment> permisosAsignados =[SELECT Id, PermissionSetId, PermissionSet.Name, AssigneeId FROM 
                                            PermissionSetAssignment WHERE (PermissionSet.Name =: PS_ADMINISTRADOR OR PermissionSet.Name =: PS_GENERAL)
                                            AND assigneeId =: userInfo.getUserId()];

            if(!permisosAsignados.isEmpty()){
                for (PermissionSetAssignment psa : permisosAsignados) {
                    if(psa.PermissionSet.Name == PS_GENERAL){
                        esDeSPV = true;
                    } 
                    if(psa.PermissionSet.Name == PS_ADMINISTRADOR){
                        esAdmin = true;
                    }
                }

                //Si el usuario tiene SPV general pero no SPV administrador, valido si puede realizar cambios sobre los colaboradores de un grupo
                if(esDeSPV && !esAdmin){
                    SPV_GrupoColaboradorContactHelper.validarAdmin(listNewObjFiltrada);               
                }           
            }
        }
    }
}