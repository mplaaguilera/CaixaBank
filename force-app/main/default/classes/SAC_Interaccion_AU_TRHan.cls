public with sharing class SAC_Interaccion_AU_TRHan extends CC_TriggerHandlerBase{
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<SAC_Interaccion__c>) tp.newList, (Map<Id, SAC_Interaccion__c>) tp.newMap, (List<SAC_Interaccion__c>) tp.oldList, (Map<Id, SAC_Interaccion__c>) tp.oldMap);
    }    
    private void process(List<SAC_Interaccion__c> listNewObj, Map<Id, SAC_Interaccion__c> mapNewObj, List<SAC_Interaccion__c> listOldObj, Map<Id, SAC_Interaccion__c> mapOldObj){
        //obtener record type  
        Id recTypeEscaladoNv2 = Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Escalado').getRecordTypeId();
        Id recTypeEscaladoNv3 = Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_EscaladoNV3').getRecordTypeId();
        Id recTypeConsulta = Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Consulta').getRecordTypeId();
        Id recTypeGrupoResAccion = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoResponsableAccion').getRecordTypeId();
        String estadoBorradorInterraccion = 'SAC_Borrador';
        String estadoPendienteRespuestaDefinitivaInteraccion = 'SAC_PendienteRespuestaDefinitiva';

        List<SAC_Interaccion__c> listaEscaladosNV2yNV3 = new List<SAC_Interaccion__c>();
        List<SAC_Interaccion__c> listaConsultaOficinas = new List<SAC_Interaccion__c>();
        List<SAC_Interaccion__c> listaConsultaInterna = new List<SAC_Interaccion__c>();
        List<SAC_Interaccion__c> listaInteracciones = new List<SAC_Interaccion__c>();
        List<SAC_Interaccion__c> listaConsultaRespondida = new List<SAC_Interaccion__c>();
        List<SAC_Interaccion__c> listaConsultaPendienteRespuesta = new List<SAC_Interaccion__c>();
        List<SAC_Interaccion__c> listaConsultaPendienteRespuestaDefinitiva = new List<SAC_Interaccion__c>();
        List<SAC_Interaccion__c> listaCerrarTME = new List<SAC_Interaccion__c>();
        List<SAC_Interaccion__c> listaReabrirTME = new List<SAC_Interaccion__c>();
        List<SAC_Interaccion__c> listaConsultasConOficina = new List<SAC_Interaccion__c>();

        //Recorremos la lista de interacciones
        for (SAC_Interaccion__c consulta : listNewObj) {
            
            //listaConsulta.add(consulta);
            if (consulta.RecordTypeId == recTypeEscaladoNv2 || consulta.RecordTypeId == recTypeEscaladoNv3) {
                listaEscaladosNV2yNV3.add(consulta);
            }

            if(consulta.RecordTypeId == recTypeConsulta){
                //no es una funcionalidad unica para escalados, puede ser aplicada también para consultas

                if(consulta.SAC_Pregunta__c != mapOldObj.get(consulta.Id).SAC_Pregunta__c 
                    && String.isBlank(mapOldObj.get(consulta.Id).SAC_Pregunta__c)
                ){
                    listaConsultaOficinas.add(consulta);
                    //Añadir a una lista las consultas que tengan una oficina informada para posteriormente llamar al método que envía el correo electronico de la pregunta realizada
                    if (String.isNotBlank(consulta.SAC_Oficina__c)) {
                        listaConsultasConOficina.add(consulta);
                    }
                }
                if (mapOldObj.get(consulta.id).SAC_Estado__c != consulta.SAC_Estado__c && consulta.SAC_Estado__c == 'SAC_Resuelta') {
                    listaConsultaRespondida.add(consulta);
                }
                if (mapOldObj.get(consulta.Id).SAC_Estado__c != consulta.SAC_Estado__c && consulta.SAC_Estado__c == 'SAC_PendienteRespuesta') {
                    listaConsultaPendienteRespuesta.add(consulta);
                }
                if (mapOldObj.get(consulta.Id).SAC_Estado__c != consulta.SAC_Estado__c && consulta.SAC_Estado__c == 'SAC_PendienteRespuestaDefinitiva') {
                    listaConsultaPendienteRespuestaDefinitiva.add(consulta);
                }
            }

            if(consulta.SAC_Estado__c != estadoBorradorInterraccion){
                listaCerrarTME.add(consulta);
            }
            if(consulta.SAC_Estado__c == estadoPendienteRespuestaDefinitivaInteraccion){
                listaReabrirTME.add(consulta);
            }
        }

      

        if (!listaEscaladosNV2yNV3.isEmpty()) {
            SAC_Interaccion.crearTaskEscaladoAtendido(listaEscaladosNV2yNV3, mapOldObj);
            //SAC_Interaccion.cerrarTME(listaEscaladosNV2yNV3, mapOldObj);
            SAC_Notificacion.notificarEscaladoAtendido(listaEscaladosNV2yNV3, mapOldObj);
        }
        if(!listaCerrarTME.isEmpty()){
            SAC_Interaccion.cerrarTME(listaCerrarTME, mapOldObj);
        }
        if(!listaReabrirTME.isEmpty()){
            SAC_Interaccion.reabrirTME(listaCerrarTME, mapOldObj);
        }
        if (!listaConsultasConOficina.isEmpty()) {
            SAC_Interaccion.enviarEmailConsultaInterna(listaConsultasConOficina);
        }
        if(!listaConsultaOficinas.isEmpty()){
            //SAC_Interaccion.cambiaEstado(listaConsultasConGrupo); ahora se hace en el BU
            SAC_Interaccion.insertarTME(listaConsultaOficinas);
        }
        if (!listaConsultaRespondida.isEmpty()) {
            SAC_Notificacion.alertaConsultaRespondida(listaConsultaRespondida);
        }
        if (!listaConsultaPendienteRespuesta.isEmpty()) {
            SAC_Interaccion.scheduleAlertaConsulta24h(listaConsultaPendienteRespuesta);
        }
        if (!listaConsultaPendienteRespuestaDefinitiva.isEmpty()) {
            SAC_Interaccion.reprogramarAlertaConsulta(listaConsultaPendienteRespuestaDefinitiva);
        }
    }
}