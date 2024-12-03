/*********************************************************************************************************
 * Name: SAC_Grupo_Colaborador_Contact_AD_TRHan
 * Copyright © 2019  CaixaBank
 *  
 * Proposito: Trigger Handler para controlar el After Delete  del objeto Grupo_Colaborador_Contact__c
 *              Esta clase se testea con SAC_GrupoColaboradorContact_Test
 *  
 * Historial
 * -------
 * VERSION        USER_STORY            AUTHOR               DATE             Description
 * 1.0            US206848              Marcela Neira        22/04/21            Creación
**********************************************************************************************************/

public with sharing class SAC_Grupo_Colaborador_Contact_AD_TRHan extends CC_TriggerHandlerBase {
    private static Set<String> objetos = new Set<String>{'CC_Grupo_Colaborador__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPEPROVEEDORES = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SAC_GrupoProveedores').getRecordTypeId();
    private static final Id RECTYPELETRADOS = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SAC_Letrados').getRecordTypeId();

    private static final String VIDA_CAIXA_GROUPS = '%'+'VidaCaixa'+'%';  
    private static final String VCX_GROUPS = '%'+'VCX'+'%'; 
    private static final String ASESORIA_JURIDICA = 'Asesoria Juridica';
    private static final String COPS = 'COPS';
    private static final String GESTOR_LETRADOS_ADMIN = 'Gestor/letrados administrador';
    private static final String AUDITORES = 'Auditores';

    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<CC_Grupo_Colaborador_Contact__c>)tp.newList, (Map<Id, CC_Grupo_Colaborador_Contact__c>)tp.newMap, (List<CC_Grupo_Colaborador_Contact__c>)tp.oldList, (Map<Id, CC_Grupo_Colaborador_Contact__c>)tp.oldMap);
    }
    
    private void process(List<CC_Grupo_Colaborador_Contact__c> listNewObj, Map<Id, CC_Grupo_Colaborador_Contact__c> mapNewObj, List<CC_Grupo_Colaborador_Contact__c> listOldObj, Map<Id, CC_Grupo_Colaborador_Contact__c> mapOldObj) {
        List<Id> listaIdesGrupos = new List<Id>();
        List<Id> listIdGrupoNivel3 = new List<Id>();

        SAC_ActualizacionUsuario.actualizar(listNewObj,listOldObj);
        List<CC_Grupo_Colaborador_Contact__c> listaVidaCaixaGroup = new List<CC_Grupo_Colaborador_Contact__c>();
        List<CC_Grupo_Colaborador_Contact__c> listaAJGroup = new List<CC_Grupo_Colaborador_Contact__c>();
        List<CC_Grupo_Colaborador_Contact__c> listaAdminCOPS = new List<CC_Grupo_Colaborador_Contact__c>();
        List<CC_Grupo_Colaborador_Contact__c> listaAdminCopsAj = new List<CC_Grupo_Colaborador_Contact__c>();
        List<CC_Grupo_Colaborador_Contact__c> listaGestorLetradosAdmin = new List<CC_Grupo_Colaborador_Contact__c>();
        List<CC_Grupo_Colaborador_Contact__c> listaAuditores = new List<CC_Grupo_Colaborador_Contact__c>();
        List<CC_Grupo_Colaborador_Contact__c> listGruposMoneyToPay = new List<CC_Grupo_Colaborador_Contact__c>();

        List<CC_Grupo_Colaborador__c> listGruposVidaCaixa = new List<CC_Grupo_Colaborador__c>();
        List<CC_Grupo_Colaborador__c> listJuridicaGrupo = new List<CC_Grupo_Colaborador__c>();
        List<CC_Grupo_Colaborador__c> listGrupoCOPS = new List<CC_Grupo_Colaborador__c>();
        List<CC_Grupo_Colaborador__c> listGrupoGestorLetradoAdmin = new List<CC_Grupo_Colaborador__c>();
        List<CC_Grupo_Colaborador__c> listGrupoAuditores = new List<CC_Grupo_Colaborador__c>();

        List<CC_Grupo_Colaborador__c> listGruposSAC = [SELECT Id, name, RecordTypeId, SAC_NivelGrupo__c FROM CC_Grupo_Colaborador__c WHERE Name LIKE : VIDA_CAIXA_GROUPS OR Name LIKE : VCX_GROUPS OR Name =: ASESORIA_JURIDICA 
                                        OR Name =: COPS OR Name =: GESTOR_LETRADOS_ADMIN OR Name =: AUDITORES OR SAC_NivelGrupo__c = 'SAC_Nivel3'];

        if(!listGruposSAC.isEmpty()){
            for(CC_Grupo_Colaborador__c grupo : listGruposSAC){
                if(grupo.name.toUpperCase().contains('VCX') || grupo.name.toUpperCase().contains('VIDACAIXA')) {
                    listGruposVidaCaixa.add(grupo);
                } else if(grupo.name == ASESORIA_JURIDICA) {
                    listJuridicaGrupo.add(grupo);
                } else if(grupo.name == COPS) {
                    listGrupoCOPS.add(grupo);
                } else if(grupo.name == GESTOR_LETRADOS_ADMIN) {
                    listGrupoGestorLetradoAdmin.add(grupo);
                } else if(grupo.name == AUDITORES) {
                    listGrupoAuditores.add(grupo);
                }
                if(grupo.SAC_NivelGrupo__c == 'SAC_Nivel3') {
                    listIdGrupoNivel3.add(grupo.id);
                }
            }
        }

        Map<Id, CC_Grupo_Colaborador_Contact__c> mapaAdminsCOPS = new Map<Id, CC_Grupo_Colaborador_Contact__c>();

        List<CC_Grupo_Colaborador__c> listGruposProvAndLetrados = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE RecordTypeId =: RECTYPEPROVEEDORES OR RecordTypeId =: RECTYPELETRADOS];

        List<Id> listGruposVidaCaixaIds = New List<Id>();
        List<Id> listGruposProvAndLetIds = New List<Id>();
        String juridicaGrupoId = '';
        String copsGrupoId = '';
        String gestorLetradoAdminGrupoId = '';
        String auditoresGrupoId = '';

        if(!listGruposVidaCaixa.isEmpty() ){
            for(CC_Grupo_Colaborador__c gvcx : listGruposVidaCaixa){
                listGruposVidaCaixaIds.add(gvcx.Id);
            }
        }

        if(!listJuridicaGrupo.isEmpty()){
            juridicaGrupoId = listJuridicaGrupo[0].Id;
        }  

        if(!listGrupoCOPS.isEmpty()){
            copsGrupoId = listGrupoCOPS[0].Id;
        } 

        if(!listGrupoGestorLetradoAdmin.isEmpty()){
            gestorLetradoAdminGrupoId = listGrupoGestorLetradoAdmin[0].Id;
        } 

        if(!listGrupoAuditores.isEmpty()){
            auditoresGrupoId = listGrupoAuditores[0].Id;
        } 

        if(!listGruposProvAndLetrados.isEmpty()){
            for(CC_Grupo_Colaborador__c gprovlet : listGruposProvAndLetrados){
                listGruposProvAndLetIds.add(gprovlet.Id);
            }
        }        

        
        for (CC_Grupo_Colaborador_Contact__c gcc : listOldObj) {
            listaIdesGrupos.add(gcc.CC_Grupo_Colaborador__c);

            if(listGruposVidaCaixaIds.contains(gcc.CC_Grupo_Colaborador__c)){
                listaVidaCaixaGroup.add(gcc);
            }
            
            if(juridicaGrupoId != '' && gcc.CC_Grupo_Colaborador__c == Id.valueOf(juridicaGrupoId)){
                listaAJGroup.add(gcc);
            }

            if(copsGrupoId != '' && gcc.CC_Grupo_Colaborador__c == Id.valueOf(copsGrupoId) && gcc.SAC_Administrador__c == true){
                listaAdminCOPS.add(gcc);
                mapaAdminsCOPS.put(gcc.id, gcc);
            }

            if(copsGrupoId != '' && gcc.CC_Grupo_Colaborador__c == Id.valueOf(copsGrupoId) && gcc.SAC_Administrador__c == false){
                listaAdminCopsAj.add(gcc);
            }

            if(gestorLetradoAdminGrupoId != '' && gcc.CC_Grupo_Colaborador__c == Id.valueOf(gestorLetradoAdminGrupoId)){
                listaGestorLetradosAdmin.add(gcc);
                mapaAdminsCOPS.put(gcc.id, gcc);
            }

            if(auditoresGrupoId != '' && gcc.CC_Grupo_Colaborador__c == Id.valueOf(auditoresGrupoId)){
                listaAuditores.add(gcc);
            }

            if(listGruposProvAndLetIds.contains(gcc.CC_Grupo_Colaborador__c) && gcc.SAC_Auditor__c == true){
                //US770903 Auditorias / Raúl Santos / Eliminamos el PS de Auditorias
                listaAuditores.add(gcc);
            }

            // Si el usuario se elimina de grupo que no es Nivel 3 y es el único se tiene que eleimar del public group de Money To Pay
            if(!listIdGrupoNivel3.contains(gcc.CC_Grupo_Colaborador__c)){
                listGruposMoneyToPay.add(gcc);
            }
        }        
        
        if(!listaIdesGrupos.isEmpty()){
            SAC_GrupoColaboradorContact.recalcularUsuarioActivos(listaIdesGrupos);
            SAC_ActualizacionUsuario.actualizarSupervisores(null, mapOldObj);   
        }

        if(!mapaAdminsCOPS.isEmpty()){
            SAC_ActualizacionUsuario.actualizarAdministradores(null, mapaAdminsCOPS);
        }

        if(!listaVidaCaixaGroup.isEmpty()){
            SAC_AdministrarUsuarios.asignarVidaCaixaPermisionSet(listaVidaCaixaGroup, 'eliminar');
        }else if(!listaAJGroup.isEmpty()){
            SAC_AdministrarUsuarios.asignarAJPermisionSet(listaAJGroup, 'eliminar');
        }else if(!listaAdminCOPS.isEmpty()){
            SAC_AdministrarUsuarios.asignarAuditorPermisionSet(listaAdminCOPS, 'eliminar');
            //US770903 Auditorias / Raúl Santos / Eliminamos el PS de Auditorias
            SAC_AdministrarUsuarios.asignarPermissionSetAuditores(listaAdminCOPS, 'eliminar');
        }else if(!listaGestorLetradosAdmin.isEmpty()){
            SAC_AdministrarUsuarios.asignarAuditorPermisionSet(listaGestorLetradosAdmin, 'eliminar');
        }else if(!listaAdminCopsAj.isEmpty()){
            SAC_AdministrarUsuarios.asignarAdministradorPermisionSet(listaAdminCopsAj, 'eliminar');
            //US770903 Auditorias / Raúl Santos / Eliminamos el PS de Auditorias
            SAC_AdministrarUsuarios.asignarPermissionSetAuditores(listaAdminCopsAj, 'eliminar');
        }else if(!listaAuditores.isEmpty()){
            SAC_AdministrarUsuarios.asignarPermissionSetAuditores(listaAuditores, 'eliminar');
        }
        if(!listGruposMoneyToPay.isEmpty()){
            SAC_ActualizacionUsuario.actualizarGrupoMoneyToPay(listGruposMoneyToPay, listIdGrupoNivel3 ,'eliminar');
        }
	}
}