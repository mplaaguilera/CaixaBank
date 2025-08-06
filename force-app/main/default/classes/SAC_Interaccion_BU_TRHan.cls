public with sharing class SAC_Interaccion_BU_TRHan extends CC_TriggerHandlerBase{
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<SAC_Interaccion__c>) tp.newList, (Map<Id, SAC_Interaccion__c>) tp.newMap, (List<SAC_Interaccion__c>) tp.oldList, (Map<Id, SAC_Interaccion__c>) tp.oldMap);
    }    
    private void process(List<SAC_Interaccion__c> listNewObj, Map<Id, SAC_Interaccion__c> mapNewObj, List<SAC_Interaccion__c> listOldObj, Map<Id, SAC_Interaccion__c> mapOldObj){
        //obtener record type
        Id recTypeConsulta = Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Consulta').getRecordTypeId();
        Id recTypeEscaladoNv2 = Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Escalado').getRecordTypeId();
        Id recTypeEscaladoNv3 = Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_EscaladoNV3').getRecordTypeId();

        List<SAC_Interaccion__c> listaConsultas = new List<SAC_Interaccion__c>();
        List<SAC_Interaccion__c> listaConsultasPreg = new List<SAC_Interaccion__c>();
        List<SAC_Interaccion__c> listaEscaladosNV2 = new List<SAC_Interaccion__c>();
        List<SAC_Interaccion__c> listaEscaladosNV3 = new List<SAC_Interaccion__c>();
        List<SAC_Interaccion__c> listaValidarCampos = new List<SAC_Interaccion__c>();
        List<SAC_Interaccion__c> listaConsultaRespondida = new List<SAC_Interaccion__c>();
        List<SAC_Interaccion__c> listaConsultasGrupoCambiado = new List<SAC_Interaccion__c>();
        List<SAC_Interaccion__c> listaConsultasOficinaCambiada = new List<SAC_Interaccion__c>();
        
        Map<Id, date> mapFechaVencimiento = new Map<Id, date>();

        //Recorremos la lista de interacciones
        for (SAC_Interaccion__c consulta : listNewObj) {
            if(consulta.RecordTypeId == recTypeConsulta){
                listaConsultas.add(consulta);
                if(consulta.SAC_Pregunta__c != mapOldObj.get(consulta.Id).SAC_Pregunta__c 
                    && String.isBlank(mapOldObj.get(consulta.Id).SAC_Pregunta__c)
                ){ 
                    consulta.SAC_Estado__c = 'SAC_PendienteRespuesta';
                    listaConsultasPreg.add(consulta);
                    
                }
                //Si cambia el grupo de la consulta y no está vacío
                if (mapOldObj.containsKey(consulta.Id) && mapOldObj.get(consulta.Id).SAC_GrupoColaborador__c != consulta.SAC_GrupoColaborador__c && String.isNotBlank(consulta.SAC_GrupoColaborador__c)) {
                    listaConsultasGrupoCambiado.add(consulta);
                }
                //Si cambia la oficina de la consulta
                if (mapOldObj.containsKey(consulta.Id) && mapOldObj.get(consulta.Id).SAC_Oficina__c != consulta.SAC_Oficina__c) {
                    listaConsultasOficinaCambiada.add(consulta);
                }
            }

            if (consulta.RecordTypeId == recTypeEscaladoNv2) {
                listaEscaladosNV2.add(consulta);

                if(mapOldObj.containsKey(consulta.id) && (consulta.SAC_Titulo__c != mapOldObj.get(consulta.Id).SAC_Titulo__c || consulta.SAC_Observaciones_Interaccion__c != mapOldObj.get(consulta.Id).SAC_Observaciones_Interaccion__c || consulta.SAC_GrupoColaborador__c != mapOldObj.get(consulta.Id).SAC_GrupoColaborador__c || consulta.SAC_PropuestaCOPS__c != mapOldObj.get(consulta.Id).SAC_PropuestaCOPS__c)){
                    listaValidarCampos.add(consulta);
                }

                if(mapOldObj.containsKey(consulta.id) && consulta.SAC_Estado__c != mapOldObj.get(consulta.Id).SAC_Estado__c ){
                    if(consulta.SAC_Estado__c == 'SAC_Atendida' || consulta.SAC_Estado__c == 'SAC_Reescalada') {
                        consulta.SAC_FechaFin__c = System.now();
                    }else{
                        consulta.SAC_FechaFin__c = null;
                    }
                }
            }
            if (consulta.RecordTypeId == recTypeEscaladoNv3) {
                listaEscaladosNV3.add(consulta);

                if(mapOldObj.containsKey(consulta.id) && (consulta.SAC_Titulo__c != mapOldObj.get(consulta.Id).SAC_Titulo__c || consulta.SAC_Observaciones_Interaccion__c != mapOldObj.get(consulta.Id).SAC_Observaciones_Interaccion__c || consulta.SAC_GrupoColaborador__c != mapOldObj.get(consulta.Id).SAC_GrupoColaborador__c || consulta.SAC_PropuestaCOPS__c != mapOldObj.get(consulta.Id).SAC_PropuestaCOPS__c)){
                    listaValidarCampos.add(consulta);
                }
            }
        }


        if (!listaConsultas.isEmpty()) {   
            SAC_Interaccion.crearThreadId(listaConsultas);
        }
        // if(!listaEscaladosNV2.isEmpty()) {
        //     SAC_Interaccion.validarImporteEscalados(listaEscaladosNV2);
        // }
        if(!listaConsultasPreg.isEmpty()) {
            List<SAC_Interaccion__c> listaConsultasConGrupo = [SELECT Id, SAC_GrupoColaborador__r.SAC_PeriodoConsulta__c
                                FROM SAC_Interaccion__c
                                WHERE Id IN: listaConsultasPreg AND SAC_GrupoColaborador__r.SAC_PeriodoConsulta__c <> null];
            if(!listaConsultasConGrupo.isEmpty()) {
                mapFechaVencimiento = SAC_Interaccion.calculoFechaVencimiento(listaConsultasConGrupo);
                for(SAC_Interaccion__c consulta : listaConsultasPreg) {
                    if(consulta.SAC_Fecha_Vencimiento__c == null && mapFechaVencimiento.containskey(consulta.Id)) {
                            consulta.SAC_Fecha_Vencimiento__c = mapFechaVencimiento.get(consulta.Id);
                    }
                }
            }
        } 

        if(!listaValidarCampos.isEmpty()){
            validarUpdateCampos(listaValidarCampos);
        }

        if (!listaConsultasGrupoCambiado.isEmpty()) {
            // Se recuperan los grupos colaboradores de la lista de interacciones listaConsultasGrupoCambiado
            List<CC_Grupo_Colaborador__c> listaGrupos = SAC_Interaccion.recuperarGruposConsulta(listaConsultasGrupoCambiado);
            SAC_Interaccion.cambiarOficinaConsulta(listaConsultasGrupoCambiado, listaGrupos);
            SAC_Interaccion.asignarPropietarioConsultaInterna(listaConsultasGrupoCambiado, listaGrupos);
        }
        if (!listaConsultasOficinaCambiada.isEmpty()) {
            SAC_Interaccion.informarCorreoOficina(listaConsultasOficinaCambiada);
        }
    }

    /*
    * @description Campo para validar que solo el owner y los usuarios con PS SAC_Administrador puedan modificar los campos
    */
    public static void validarUpdateCampos(List<SAC_Interaccion__c> listEscalados) {

        Id userId = userinfo.getUserId();

        List<PermissionSetAssignment> psa = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :userId AND PermissionSet.Name = 'SAC_Administrador' LIMIT 1];

        for(SAC_Interaccion__c escalado : listEscalados){
            if(escalado.OwnerId != userId && psa.isEmpty()){
                escalado.addError('No tiene permisos para editar el registro.');
            }  
        }
    }
}