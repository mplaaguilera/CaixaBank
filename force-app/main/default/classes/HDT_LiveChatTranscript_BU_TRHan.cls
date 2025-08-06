/**
 * @description       :
 * @author            : Moisés Cano
 * @group             :
 * @last modified on  : 15-05-2023
 * @last modified by  : Moisés Cano
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   15-05-2023   Moisés Cano   Initial Version
**/
public with sharing class HDT_LiveChatTranscript_BU_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<LiveChatTranscript>)tp.newList, (Map<Id, LiveChatTranscript>)tp.newMap, (List<LiveChatTranscript>)tp.oldList, (Map<Id, LiveChatTranscript>)tp.oldMap);
    }

    private void process(List<LiveChatTranscript> listNewObj, Map<Id, LiveChatTranscript> mapNewObj,
    List<LiveChatTranscript> listOldObj, Map<Id, LiveChatTranscript> mapOldObj) {
        //Informa Origen a partir de la Procedencia antes de guardar el registro
        //Descartar los que vengan de CSBD
        List<LiveChatTranscript> listNewTranscript = new List<LiveChatTranscript>();
        for(LiveChatTranscript transcript : listNewObj){
            if(transcript.UserAgent == 'ChatdeempleadosHDT'){
                listNewTranscript.add(transcript);
            }
        }
        if(!listNewTranscript.isEmpty()){
            processAux(listNewTranscript, mapNewObj, listOldObj, mapOldObj);
        }
	}

    private void processAux(List<LiveChatTranscript> listNewObj, Map<Id, LiveChatTranscript> mapNewObj,
                        List<LiveChatTranscript> listOldObj, Map<Id, LiveChatTranscript> mapOldObj) {
        //cerrarCasoSiebel(mapOldObj, mapNewObj);
        //sincronizarDatosTranscripciones(listNewObj);
        sincronizarDatosTranscripciones(mapOldObj, mapNewObj);
        crearActividades(mapOldObj, listNewObj);
      //  updateproveedor(mapOldObj, listNewObj);
    }

    //private static void sincronizarDatosTranscripciones(List<LiveChatTranscript> listNewObj) {
    private static void sincronizarDatosTranscripciones(Map<Id, LiveChatTranscript> mapOldObj, Map<Id, LiveChatTranscript> mapNewObj) {

        List<LiveChatTranscript> chatsCognitivo = new List<LiveChatTranscript>();

        // Detectar la actualización del cliente, contacto o caso.
        List<Id> idsCognitivo = new List<Id>();
        List<ID> chatEmpleados = new List<ID>();
        Id idRtChatHdt = Schema.SObjectType.LiveChatTranscript.getRecordTypeInfosByDeveloperName().get('HDT_Empleados').getRecordTypeId();
        for (Id key : mapNewObj.keySet()) {
                chatEmpleados.add(mapNewObj.get(key).Id);
        }

        if (!chatEmpleados.isEmpty())
        {
            List<LiveChatTranscript> listadoChats = [SELECT  CC_Id_Cognitive__c, CaseId, Case.AccountId, Case.ContactId
            FROM LiveChatTranscript
            WHERE Id IN :chatEmpleados];
            for (LiveChatTranscript chat : listadoChats)
            {
                if (mapNewObj.get(chat.Id) != null)
                {
                    if (mapNewObj.get(chat.Id).AccountId == null && chat.Case.AccountId != null)
                    mapNewObj.get(chat.Id).AccountId = chat.Case.AccountId;

                    if (mapNewObj.get(chat.Id).ContactId == null && chat.Case.AccountId != null)
                    mapNewObj.get(chat.Id).ContactId = chat.Case.ContactId;
                }
            }
        }

        if (chatsCognitivo.size() > 0)
        {
            update chatsCognitivo;
        }

    }

    private static void crearActividades(Map<Id, LiveChatTranscript> mapOldObj, List<LiveChatTranscript> listNewObj) {
        //Se crea actividad para cada transcripción de agente. No se puede hacer en el After Insert
        //al no tener aún el Case Id. Además para la de agente es necesario esperar también a que
        //SFDC guarde asíncronamente la transcripción en el Body después de finalizar el chat.

        List<Case> casos = new List<Case>();
        List<Task> nuevasActividades = new List<Task>();
        Set<Id> setIdsChats = new Set<Id>();
        Set<Id> setIdsCasos = new Set<Id>();

        Map<Id, LiveChatTranscript> mapChats = new Map<Id, LiveChatTranscript>();
        Map<Id, Case> mapCasos = new Map<Id, Case>();

        for (LiveChatTranscript oChatNew : listNewObj) {
            setIdsChats.add(oChatNew.Id);
            setIdsCasos.add(oChatNew.CaseId);
        }

        if (!setIdsChats.isEmpty()) {
            mapChats.putall([SELECT RecordType.Name, Id, CC_Tipo__c, AccountId, ContactId FROM LiveChatTranscript WHERE Id IN :setIdsChats]);
        }

        if (!setIdsCasos.isEmpty()) {
            mapCasos.putAll([SELECT Id, RecordTypeId, CC_Tipo_ChatTranscript__c, Status FROM Case WHERE Id IN :setIdsCasos]);
        }

        for (LiveChatTranscript oChatNew : listNewObj) {
            LiveChatTranscript oChatOld = mapOldObj.get(oChatNew.Id);

            // Desvinculamos el código para los chats de empleados.
            /*if (oChatNew.RecordTypeId != Schema.SObjectType.LiveChatTranscript.getRecordTypeInfosByDeveloperName().get('HDT_Empleados').getRecordTypeId())
            {
                //Si se ha informado el caso se actualiza el caso con el canal de procedencia del chat
                if (oChatOld.CaseId == null && oChatNew.CaseId != null) { //Agente
                    Case casoUpdt = new Case(Id = oChatNew.CaseId);
                    if(oChatNew.CC_Canal_Procedencia__c != null){
                        if(oChatNew.CC_Aplicacion_Origen__c == 'Whatsapp')
                        {
                            casoUpdt.CC_Canal_Procedencia__c = 'Chat NOA WhatsApp';
                            casoUpdt.CC_Canal_Resolucion__c = 'Chat NOA WhatsApp';
                        }else {
                            casoUpdt.CC_Canal_Procedencia__c = oChatNew.CC_Canal_Procedencia__c;
                            casoUpdt.CC_Canal_Resolucion__c = oChatNew.CC_Canal_Procedencia__c;
                        }

                    }
                    if(oChatNew.CC_Canal_operativo__c != null) {
                        casoUpdt.CC_Canal_Operativo__c = oChatNew.CC_Canal_operativo__c;
                    }
                    casoUpdt.CC_Tipo_Contacto__c = 'Consulta'; // update traído del PB CC_Gestion_Caso - 10/12/2019
                    //Actualizar el tipo de registro del caso.
                    //LiveChatTranscript listChat = [SELECT RecordType.Name, Id, CC_Tipo__c, AccountId, ContactId FROM LiveChatTranscript WHERE Id =: oChatNew.Id LIMIT 1];
                    casoUpdt.CC_Canal_Resolucion__c = oChatNew.CC_Canal_Procedencia__c;
                    //Reapertura del caso si es hidden y RecordType es de empleado
                    if (casoUpdt.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId()){
                        if(casoUpdt.CC_Tipo_ChatTranscript__c == 'Hidden' || casoUpdt.CC_Tipo_ChatTranscript__c == 'Agente'){
                            casoUpdt.OwnerId = oChatNew.OwnerId;
                            casoUpdt.CC_Tipo_ChatTranscript__c = mapChats.get(oChatNew.Id).CC_Tipo__c;
                            if (casoUpdt.Status == 'Cerrado'){
                                casoUpdt.Status = 'Activo';
                            }
                        }
                    }
                    casos.add(casoUpdt);
                } else if ((oChatOld.CaseId == null && oChatNew.CaseId != null) || (oChatOld.CaseId == oChatNew.CaseId && oChatNew.CaseId != null)) {
                    //Si la transcripcion tiene el caso asociado, se realiza la reapertura del caso si es hidden y RecordType es de empleado
                    Case casoUpdt = new Case(Id = oChatNew.CaseId);
                    //Case oDatosCaso = [SELECT Id, RecordTypeId, CC_Tipo_ChatTranscript__c, Status FROM CASE WHERE Id =:oChatNew.CaseId];
                    //LiveChatTranscript listChat = [SELECT RecordType.Name, Id, CC_Tipo__c, AccountId, ContactId FROM LiveChatTranscript WHERE Id =: oChatNew.Id LIMIT 1];

                    if(oChatNew.CC_Canal_Procedencia__c != null){
                        if(oChatNew.CC_Aplicacion_Origen__c == 'Whatsapp')
                        {
                            casoUpdt.CC_Canal_Procedencia__c = 'Chat NOA WhatsApp';
                            casoUpdt.CC_Canal_Resolucion__c = 'Chat NOA WhatsApp';
                        }else {
                            casoUpdt.CC_Canal_Procedencia__c = oChatNew.CC_Canal_Procedencia__c;
                            casoUpdt.CC_Canal_Resolucion__c = oChatNew.CC_Canal_Procedencia__c;
                        }

                    }
                    Id empleadoRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
                    if (mapCasos.get(oChatNew.CaseId).RecordTypeId == empleadoRecordType){
                        if(mapCasos.get(oChatNew.CaseId).CC_Tipo_ChatTranscript__c == 'Hidden' || mapCasos.get(oChatNew.CaseId).CC_Tipo_ChatTranscript__c == 'Agente'){
                            casoUpdt.OwnerId = oChatNew.OwnerId;
                            casoUpdt.CC_Tipo_ChatTranscript__c = mapChats.get(oChatNew.Id).CC_Tipo__c;
                            if (mapCasos.get(oChatNew.CaseId).Status == 'Cerrado'){
                                casoUpdt.Status = 'Activo';
                            }
                        }

                    }
                    casos.add(casoUpdt);
                }

                if (oChatOld.CaseId == null && oChatNew.CaseId != null) {
                    //Crear actividad de tipo "Conversación con chatbot"
                    Task nuevaActividadChatbot = new Task();
                    nuevaActividadChatbot.Status = 'Completed';
                    nuevaActividadChatbot.Subject = 'Conversación con chatbot';
                    nuevaActividadChatbot.Priority = 'Normal';
                    nuevaActividadChatbot.Type = 'Automática';
                    nuevaActividadChatbot.WhatId = oChatNew.CaseId;
                    nuevaActividadChatbot.OwnerId = oChatNew.OwnerId;
                    nuevaActividadChatbot.CC_Categoria__c = oChatNew.CC_Categoria__c;
                    nuevaActividadChatbot.CC_Espacio__c = oChatNew.CC_Espacio__c;
                    nuevaActividadChatbot.CC_Chat_Cognitivo_Id__c = oChatNew.CC_Id_Cognitive__c;
                    nuevaActividadChatbot.CC_LiveChatTranscript_Id__c = oChatNew.CC_ChatOrigen__c;
                    nuevasActividades.add(nuevaActividadChatbot);

                    //Crear actividad de tipo "Conversación con agente chat"
                    Task nuevaActividadAgente = new Task();
                    nuevaActividadAgente.Status = 'Completed';
                    if(oChatNew.CC_Tipo__c == 'Hidden')
                    {
                        nuevaActividadAgente.Subject = 'Conversación con agente hidden';

                    }else{
                        nuevaActividadAgente.Subject = 'Conversación con agente chat';
                    }
                    nuevaActividadAgente.Priority = 'Normal';
                    nuevaActividadAgente.Type = 'Automática';
                    nuevaActividadAgente.WhatId = oChatNew.CaseId;
                    nuevaActividadAgente.OwnerId = oChatNew.OwnerId;
                    nuevaActividadAgente.CC_Categoria__c = oChatNew.CC_Categoria__c;
                    nuevaActividadAgente.CC_Espacio__c = oChatNew.CC_Espacio__c;
                    nuevaActividadAgente.CC_Chat_Cognitivo_Id__c = oChatNew.CC_Id_Cognitive__c;
                    nuevaActividadAgente.CC_LiveChatTranscript_Id__c = oChatNew.Id;
                    nuevasActividades.add(nuevaActividadAgente);
                }
            }*/
        }

        if (!casos.isEmpty()) { //update casos;
            Database.update(casos, false);
        }

        if (!nuevasActividades.isEmpty()) { //insert actividades
            //insert nuevasActividades;
            HDT_Activity.crearActividades(nuevasActividades);
        }
    }

   /* @testvisible
    private static void updateproveedor(Map<Id, LiveChatTranscript> mapOldObj, List<LiveChatTranscript> listNewObj) {

        system.debug('Llegando a la funcion : ');
        system.debug(mapOldObj);
        system.debug('Llegando a la funcion 22222: ');
        system.debug(listNewObj);
        

        List<Id> chatstosearch = new List<Id>();

        for (LiveChatTranscript newChat : listNewObj) {
            LiveChatTranscript oldChat = mapOldObj.get(newChat.Id);
                
                //Si el estado ha cambiado de Waiting, podemos buscar la traza asociada. Esto solo lo hacemos para chats de tipo agente
                if (oldChat.Status == 'Waiting' && newChat.Status != 'Waiting' && newChat.CC_Tipo__c == 'Agente') {
                    chatstosearch.add(newChat.Id);
                }
        }

        List<CC_TrazaInt__c> trazas = [SELECT Name, CC_TipoError__c, CC_MensajeSalida__c FROM CC_TrazaInt__c
                                        WHERE (Name='ChatProveedorInicial' OR Name='ChatProvInicialReparto') AND CC_TipoError__c IN: chatstosearch];
        List<CC_TrazaInt__c> trazasProveedorEnrutado = new List<CC_TrazaInt__c>();
        List<CC_TrazaInt__c> trazasProveedorInicialReparto = new List<CC_TrazaInt__c>();
        for (CC_TrazaInt__c traza : trazas) {
            if (traza.Name == 'ChatProveedorInicial') {
                trazasProveedorEnrutado.add(traza);
            } else {
                trazasProveedorInicialReparto.add(traza);
            }
        }
		Map<Id,String> maplctprov = new Map<Id,String>();
        Map<Id,String> mapProvInicialReparto = new Map<Id,String>();

        // Proveedor enrutado
		if(!trazasProveedorEnrutado.isEmpty()) {
			for (CC_TrazaInt__c trace : trazasProveedorEnrutado) {
				if(maplctprov.containsKey(trace.CC_TipoError__c)){
                    String provtoadd = maplctprov.get(trace.CC_TipoError__c);
                    provtoadd = trace.CC_MensajeSalida__c;
                    maplctprov.put(trace.CC_TipoError__c,trace.CC_MensajeSalida__c);
                }else{
                    String provtoadd = '';
                    provtoadd = trace.CC_MensajeSalida__c;
                    maplctprov.put(trace.CC_TipoError__c,trace.CC_MensajeSalida__c);
                }
			}
		}
        // Proveedor inicial reparto
        if(!trazasProveedorInicialReparto.isEmpty()) {
			for (CC_TrazaInt__c trace : trazasProveedorInicialReparto) {
                mapProvInicialReparto.put(trace.CC_TipoError__c, trace.CC_MensajeSalida__c);
			}
		}

        if (!maplctprov.isEmpty() || !mapProvInicialReparto.isEmpty()) {
            for (LiveChatTranscript lct : listNewObj) {
                if (maplctprov.containsKey(lct.Id)){
                    lct.CC_Proveedor_Enrutado__c = maplctprov.get(lct.Id);
                }
                if (mapProvInicialReparto.containsKey(lct.Id)) {
                    lct.CC_Proveedor_Inicial_Reparto__c = mapProvInicialReparto.get(lct.Id);
                }
            }
        }
     }*/
}