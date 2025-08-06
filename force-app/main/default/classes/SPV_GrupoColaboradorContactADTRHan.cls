/*********************************************************************************************************
 * Name: SPV_GrupoColaboradorContactADTRHan
 * Copyright © 2024  CaixaBank
 * 
 * Proposito: Trigger Handler para controlar el After Delete del objeto Grupo_Colaborador_Contact__c
 *              Esta clase se testea con SPV_GrupoColaboradorContact_Test
 * 
 * Historial
 * -------
 * VERSION        USER_STORY            AUTHOR               DATE             Description
 * 1.0             US828257           Raúl Santos          29/04/24             Creación
**********************************************************************************************************/

public with sharing class SPV_GrupoColaboradorContactADTRHan extends CC_TriggerHandlerBase{
    
    private static Set<String> objetos = new Set<String>{'CC_Grupo_Colaborador__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPEGESTORES = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SPV_GrupoGestor').getRecordTypeId();
    private static final Id RECTYPELETRADOS = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SPV_GrupoLetrado').getRecordTypeId();
    private static final Id RECTYPETAREAS = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SPV_GrupoDeTareas').getRecordTypeId();

    private static final String PS_GESTORES = 'SPV_Gestor';
    private static final String PS_LETRADOS = 'SPV_Letrado';
    private static final String PS_ADMINGRUPO = 'SPV_AdministradorGrupos';
    private static final String PS_ADMINISTRADOR = 'SPV_Administrador';
    private static final String PS_AJESCALADOS = 'SPV_Escalados';
    private static final String PS_AUDITOR = 'SPV_Auditor';

    private static final String GRUPO_AUDITOR = 'SPV_GrupoAuditor';

    private static final String COPS = 'SPV_COPS';
    private static final String AJ = 'SPV_AJ';

    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<CC_Grupo_Colaborador_Contact__c>)tp.newList, (Map<Id, CC_Grupo_Colaborador_Contact__c>)tp.newMap, (List<CC_Grupo_Colaborador_Contact__c>)tp.oldList, (Map<Id, CC_Grupo_Colaborador_Contact__c>)tp.oldMap);
    }

    private void process(List<CC_Grupo_Colaborador_Contact__c> listNewObj, Map<Id, CC_Grupo_Colaborador_Contact__c> mapNewObj, List<CC_Grupo_Colaborador_Contact__c> listOldObj, Map<Id, CC_Grupo_Colaborador_Contact__c> mapOldObj) {

        List<CC_Grupo_Colaborador__c> listGruposSPV = new List<CC_Grupo_Colaborador__c>();
        List<CC_Grupo_Colaborador_Contact__c> listGrupoColabContactSPV = new List<CC_Grupo_Colaborador_Contact__c>();

        List<CC_Grupo_Colaborador_Contact__c> listGestores = new List<CC_Grupo_Colaborador_Contact__c>();
        List<CC_Grupo_Colaborador_Contact__c> listLetrados = new List<CC_Grupo_Colaborador_Contact__c>();
        List<CC_Grupo_Colaborador_Contact__c> listAdminsGrupo = new List<CC_Grupo_Colaborador_Contact__c>();
        List<CC_Grupo_Colaborador_Contact__c> listAdminsGrupoGestor = new List<CC_Grupo_Colaborador_Contact__c>();
        List<CC_Grupo_Colaborador_Contact__c> listaAdminCopsAj = new List<CC_Grupo_Colaborador_Contact__c>();
        List<CC_Grupo_Colaborador_Contact__c> listaAJ = new List<CC_Grupo_Colaborador_Contact__c>();
        List<CC_Grupo_Colaborador_Contact__c> listaCOPS = new List<CC_Grupo_Colaborador_Contact__c>();

        Set<Id> setIdsGruposColab = new Set<Id>();
        Set<Id> setIdGruposColaboradores = new Set<Id>();
        Set<Id> setIdGruposGestores = new Set<Id>();
        Set<Id> setIdGruposLetrados = new Set<Id>();
        Set<Id> setIdGruposTareas = new Set<Id>();
        Set<Id> setIdGrupoCops = new Set<Id>();
        Set<Id> setIdGrupoAj = new Set<Id>();


        //Recupero el id del grupo asociado al colaborador de la lista
        for (CC_Grupo_Colaborador_Contact__c gcc : listOldObj){
            if(String.isNotBlank(gcc.CC_Grupo_Colaborador__c)){
                setIdGruposColaboradores.add(gcc.CC_Grupo_Colaborador__c);
            }
        }

        //Recupero los grupos de SPV cuyo id se encuentra entre los grupos de los colaboradores
        if(Schema.sObjectType.CC_Grupo_Colaborador__c.isAccessible()){
            listGruposSPV = [SELECT Id, Name, RecordType.DeveloperName, SAC_DeveloperName__c FROM CC_Grupo_Colaborador__c WHERE (RecordTypeId =: RECTYPEGESTORES OR RecordTypeId =: RECTYPELETRADOS OR RecordTypeId =: RECTYPETAREAS)
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
        for (CC_Grupo_Colaborador_Contact__c gcc : listOldObj){
            
            if(setIdGruposGestores.contains(gcc.CC_Grupo_Colaborador__c) || setIdGruposLetrados.contains(gcc.CC_Grupo_Colaborador__c) || setIdGruposTareas.contains(gcc.CC_Grupo_Colaborador__c)){
                listGrupoColabContactSPV.add(gcc);
                setIdsGruposColab.add(gcc.CC_Grupo_Colaborador__c);
            }

            if(setIdGruposGestores.contains(gcc.CC_Grupo_Colaborador__c)){
                listGestores.add(gcc);

                if(gcc.SAC_Administrador__c == true){
                    listAdminsGrupo.add(gcc);
                    listAdminsGrupoGestor.add(gcc);
                }
            }
            if(setIdGruposLetrados.contains(gcc.CC_Grupo_Colaborador__c)){
                listLetrados.add(gcc);

                if(gcc.SAC_Administrador__c == true){
                    listAdminsGrupo.add(gcc);
                }
            }
            if(setIdGrupoCops.contains(gcc.CC_Grupo_Colaborador__c)){
                listaAdminCopsAj.add(gcc);
                listaCOPS.add(gcc);
            }
            if(setIdGrupoAj.contains(gcc.CC_Grupo_Colaborador__c)){
                listaAdminCopsAj.add(gcc);
                listaAJ.add(gcc);
            }
        }

        if(!listGrupoColabContactSPV.isEmpty()){
            SPV_GrupoColaboradorContactHelper.actualizarGruposPertenecientesUser(listGrupoColabContactSPV, null);
            SPV_GrupoColaboradorContactHelper.recalcularUsuarioActivos(setIdsGruposColab);
        }

        if(!listGestores.isEmpty()){
            //Le quito al usuario colaborador el permission set de gestor
            SPV_GrupoColaboradorContactHelper.procesarPermissionSet(listGestores, 'eliminar', PS_GESTORES);
        }
        if(!listLetrados.isEmpty()){
            //Le quito al usuario colaborador el permission set de letrado
            SPV_GrupoColaboradorContactHelper.procesarPermissionSet(listLetrados, 'eliminar', PS_LETRADOS);
        }
        if(!listaAdminCopsAj.isEmpty()){
            //Le quito al usuario colaborador el permission set de administrador
            SPV_GrupoColaboradorContactHelper.procesarPermissionSet(listaAdminCopsAj, 'eliminar', PS_ADMINISTRADOR);
            if(!listaAJ.isEmpty()){
                //Le quito al usuario colaborador el permission set de escalados
                SPV_GrupoColaboradorContactHelper.procesarPermissionSet(listaAJ, 'eliminar', PS_AJESCALADOS);
            }
            if(!listaCOPS.isEmpty()){
                //Le quito al usuario colaborador el permission set de auditor y lo elimino del grupo SPV_GrupoAuditor
                SPV_GrupoColaboradorContactHelper.procesarPermissionSet(listaCOPS, 'eliminar', PS_AUDITOR);
                SPV_GrupoColaboradorContactHelper.procesarPublicGroup(listaCOPS, 'eliminar', GRUPO_AUDITOR);
            }
        }
        if(!listAdminsGrupo.isEmpty()){
            //Le quito al usuario colaborador el permission set de administrador de grupos
            SPV_GrupoColaboradorContactHelper.procesarPermissionSet(listAdminsGrupo, 'eliminar', PS_ADMINGRUPO);
        }
        if(!listAdminsGrupoGestor.isEmpty()){
            SPV_GrupoColaboradorContactHelper.procesarPublicGroup(listAdminsGrupoGestor, 'eliminar', GRUPO_AUDITOR);
        }
    }
}