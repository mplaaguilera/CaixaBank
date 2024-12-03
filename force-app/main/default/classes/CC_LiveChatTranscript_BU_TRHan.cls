public with sharing class CC_LiveChatTranscript_BU_TRHan extends CC_TriggerHandlerBase {
    
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<LiveChatTranscript>)tp.newList, (Map<Id, LiveChatTranscript>)tp.newMap, (List<LiveChatTranscript>)tp.oldList, (Map<Id, LiveChatTranscript>)tp.oldMap);
    }
    
    private void process(List<LiveChatTranscript> listNewObj, Map<Id, LiveChatTranscript> mapNewObj,
    List<LiveChatTranscript> listOldObj, Map<Id, LiveChatTranscript> mapOldObj) {
        //Informa Origen a partir de la Procedencia antes de guardar el registro
        //Descartar los que vengan de CSBD
        List<LiveChatTranscript> listNewTranscript = new List<LiveChatTranscript>();
        for(LiveChatTranscript transcript : listNewObj){
            if(transcript.CC_Tipo__c != 'CSBD' && transcript.UserAgent != 'ChatdeempleadosHDT'){
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
        updateproveedor(mapOldObj, listNewObj);
        //preclasificarCaso(listNewObj, mapNewObj);
        
    }

   /* private void preclasificarCaso(List<LiveChatTranscript> listNewObj, Map<Id, LiveChatTranscript> mapOldObj){
        List<LiveChatTranscript> chatsUpdCase = new list<LiveChatTranscript>();        
        for (LiveChatTranscript chatAgente : listNewObj){            
            //Se modifica el espacio, la categor?a o el caso asociado
            if ((chatAgente.CC_Espacio__c!=mapOldObj.get(chatAgente.Id).CC_Espacio__c) ||
                (chatAgente.CC_Categoria__c!=mapOldObj.get(chatAgente.Id).CC_Categoria__c)||
                (chatAgente.caseId != mapOldObj.get(chatAgente.Id).caseId)
               )
            {
                chatsUpdCase.add(chatAgente);
            }
        }
        
        if (!chatsUpdCase.isEmpty()) {
            system.debug('NMA BU');
                CC_MCC_Preclasificacion.preclasificarCasosObj(chatsUpdCase);
                //CC_Encuestas_Chat.generarEncuesta(chatsUpdCase);
        }

    }*/
    
    /*
    private static void cerrarCasoSiebel(Map<Id, LiveChatTranscript> mapOldObj, Map<Id, LiveChatTranscript> mapNewObj) {
        //Detectar el cierre de chat para envío de datos a Siebel
        Set<Id> chatsCerrados = new Set<Id>();
        for (Id key : mapNewObj.keySet()) {
            
            if (mapOldObj.get(key).Status != 'Completed' && mapNewObj.get(key).Status == 'Completed'
            && mapNewObj.get(key).CC_SRId__c != null && mapNewObj.get(key).CC_SRId__c != ''
            && mapNewObj.get(key).CC_Id_Cognitive__c != null
            && mapNewObj.get(key).CC_Espacio__c != null && mapNewObj.get(key).CC_Categoria__c != null
            && (mapNewObj.get(key).CC_Tipo__c == 'Agente' || mapNewObj.get(key).CC_Tipo__c == 'Hidden')) {
                chatsCerrados.add(key);
            }
        }
        
        //Realizar el envío a Siebel. Lanzamos un máximo de 50 callouts (límite Hard), con las llamadas repartidas.
        if (!chatsCerrados.isEmpty()) {
            List<Id> oIDList = new List<Id>(chatsCerrados);
            Integer j = 1;
            Map<Integer, Set<Id>> oMap = new Map<Integer, Set<Id>>();
            for (Integer i = 0; i < oIDList.size(); i++) {
                if (j > 50) j = 1;
                
                //Inicializar listas.
                if (oMap.get(j) == null) {
                    Set<ID> oSet = new Set<ID>();
                    oMap.put(j, oSet);
                }
                
                //Añadir valor.
                oMap.get(j).add(oIDList[i]);
                j++;
            }
            
            //Lanzar llamadas Futuras
            for (Integer i : oMap.keySet()) {
                CC_Siebel_Alta_Chat.CC_Siebel_Fin_Chat(oMap.get(i));
            }
            
            oIDList.clear();
            oIDList = null;
            
            oMap.clear();
            oMap = null;
        }
        
        chatsCerrados.clear();
        chatsCerrados = null;
    }
    */
    //private static void sincronizarDatosTranscripciones(List<LiveChatTranscript> listNewObj) {
    private static void sincronizarDatosTranscripciones(Map<Id, LiveChatTranscript> mapOldObj, Map<Id, LiveChatTranscript> mapNewObj) {
        /* Marc Pla, 4 abril 2019: La API de Live Agent vincula el Transcript DE AGENTE con
        cuenta, contacto y caso asíncronamente, por lo que en este Before Update es necesario
        apuntar el Transcript DE COGNITIVO (creado en el After Insert) a las mismas entidades. */
        /*List<Id> idsCognitivo = new List<Id>();
        for (LiveChatTranscript chatActualizado : listNewObj) {
            if (chatActualizado.CC_Tipo__c == 'Agente'
            && (chatActualizado.AccountId != null || chatActualizado.ContactId != null || chatActualizado.CaseId != null)) {
                //Se añade chat cognitivo a lista de pendientes de sincronizar
                idsCognitivo.add(chatActualizado.CC_ChatOrigen__c);
            }
        }*/
        
        List<LiveChatTranscript> chatsCognitivo = new List<LiveChatTranscript>();
        
        // Detectar la actualización del cliente, contacto o caso.
        List<Id> idsCognitivo = new List<Id>(); 
        List<ID> chatEmpleados = new List<ID>();
        for (Id key : mapNewObj.keySet()) {
            
            // Desvinculamos el código para los chats de empleados.
            if (mapNewObj.get(key).RecordTypeId != Schema.getGlobalDescribe().get('LiveChatTranscript').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleados').getRecordTypeId())
            {
                if ((mapNewObj.get(key).CC_Tipo__c == 'Agente' || mapNewObj.get(key).CC_Tipo__c == 'Hidden') && (mapNewObj.get(key).AccountId != mapOldObj.get(key).AccountId || 
                mapNewObj.get(key).ContactId != mapOldObj.get(key).ContactId ||
                mapNewObj.get(key).CaseId != mapOldObj.get(key).CaseId))
                {
                    
                    
                    //idsCognitivo.add(chatActualizado.CC_ChatOrigen__c);
                    if (mapNewObj.get(key).CC_ChatOrigen__c != null)
                    {
                        //if (mapNewObj.get(key).CC_ChatOrigen__c != '')
                        //{
                            LiveChatTranscript oTmpAct = new LiveChatTranscript();
                            oTmpAct.Id = mapNewObj.get(key).CC_ChatOrigen__c;
                            
                            if (mapNewObj.get(key).AccountId !=  null)
                            {
                                oTmpAct.AccountId = mapNewObj.get(key).AccountId;
                            }
                            
                            if (mapNewObj.get(key).ContactId !=  null)
                            {
                                oTmpAct.ContactId = mapNewObj.get(key).ContactId;
                            }
                            if (mapNewObj.get(key).CaseId !=  null)
                            {
                                oTmpAct.CaseId = mapNewObj.get(key).CaseId;
                            }
                            
                            chatsCognitivo.add(oTmpAct);
                            //}
                    }
                }
            }else{
                chatEmpleados.add(mapNewObj.get(key).Id);
            }
        }
        
        if (!chatEmpleados.isEmpty())
        {
            List<LiveChatTranscript> listadoChats = [SELECT Id, CC_Id_Cognitive__c, CaseId, Case.AccountId, Case.ContactId
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
        
        /*       if (!idsCognitivo.isEmpty()) {
            //Se recuperan todas las transcripciones de cognitivo a actualizar
            List<LiveChatTranscript> chatsCognitivo = [SELECT AccountId, ContactId, CaseId FROM LiveChatTranscript WHERE Id IN :idsCognitivo];
            //Se sincronizan los vinculaciones con entidades entre ambas transcripciones.
            for (LiveChatTranscript chatActualizado : listNewObj) {
                try {
                    for (LiveChatTranscript chatCognitivo : chatsCognitivo) {
                        if (chatActualizado.CC_ChatOrigen__c == chatCognitivo.Id) {
                            if (chatCognitivo.AccountId != chatActualizado.AccountId) {
                                chatCognitivo.AccountId = chatActualizado.AccountId;
                            }
                            if (chatCognitivo.ContactId != chatActualizado.ContactId) {
                                chatCognitivo.ContactId = chatActualizado.ContactId;
                            }
                            if (chatCognitivo.CaseId != chatActualizado.CaseId) {
                                chatCognitivo.CaseId = chatActualizado.CaseId;
                            }
                        }
                    }
                } catch (Exception e) {
                    System.debug('No ha sido posible vincular la transcripción de cognitivo a la misma cuenta, contacto y caso que la transcripción de agente' + chatActualizado.Id + '.');
                    chatActualizado.addError('No ha sido posible vincular la transcripción de cognitivo a la misma cuenta, contacto y caso que la transcripción de agente' + chatActualizado.Id + '.');
                    continue;
                }
            }
            update chatsCognitivo;
        }*/
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
            mapCasos.putall([SELECT Id, RecordTypeId, CC_Tipo_ChatTranscript__c, Status FROM Case WHERE Id IN :setIdsCasos]);
        }

        for (LiveChatTranscript oChatNew : listNewObj) {
            LiveChatTranscript oChatOld = mapOldObj.get(oChatNew.Id);
            
            // Desvinculamos el código para los chats de empleados.
            if (oChatNew.RecordTypeId != Schema.getGlobalDescribe().get('LiveChatTranscript').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleados').getRecordTypeId())
            {
                //Si se ha informado el caso se actualiza el caso con el canal de procedencia del chat
                if (oChatOld.CaseId == null && oChatNew.CaseId != null) { //Agente
                    Case casoUpdt = new Case(Id = oChatNew.CaseId);
                    if(oChatNew.CC_Canal_Procedencia__c != null){
                        //Se da de baja whatsapp y se reemplaza por Chat Contáctanos App y Chat Contáctanos Web.
                        if(oChatNew.CC_Aplicacion_Origen__c == 'Whatsapp'){  
                            casoUpdt.CC_Canal_Procedencia__c = 'Chat NOA WhatsApp';
                            casoUpdt.CC_Canal_Resolucion__c = 'Chat NOA WhatsApp';
                        }
                        // US575560-START
                        // if(oChatNew.CC_Aplicacion_Origen__c == 'ContactaApp'){  
                        //     casoUpdt.CC_Canal_Procedencia__c = 'Chat Contáctanos App';
                        //     casoUpdt.CC_Canal_Resolucion__c = 'Chat Contáctanos App';
                        // }
                        // else if(oChatNew.CC_Aplicacion_Origen__c == 'ContactaWeb'){  
                        //     casoUpdt.CC_Canal_Procedencia__c = 'Chat Contáctanos Web';
                        //     casoUpdt.CC_Canal_Resolucion__c = 'Chat Contáctanos Web';
                        // } // US575560-END
                        else {
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
                    if (casoUpdt.RecordTypeId == Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId()){
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
                         //Se da de baja whatsapp y se reemplaza por Chat Contáctanos App y Chat Contáctanos Web.
                         if(oChatNew.CC_Aplicacion_Origen__c == 'Whatsapp'){  
                             casoUpdt.CC_Canal_Procedencia__c = 'Chat NOA WhatsApp';
                             casoUpdt.CC_Canal_Resolucion__c = 'Chat NOA WhatsApp';
                            }
                        // US575560-START
                        // if(oChatNew.CC_Aplicacion_Origen__c == 'ContactaApp'){  
                        //     casoUpdt.CC_Canal_Procedencia__c = 'Chat Contáctanos App';
                        //     casoUpdt.CC_Canal_Resolucion__c = 'Chat Contáctanos App';
                        // }
                        // else if(oChatNew.CC_Aplicacion_Origen__c == 'ContactaWeb'){  
                        //     casoUpdt.CC_Canal_Procedencia__c = 'Chat Contáctanos Web';
                        //     casoUpdt.CC_Canal_Resolucion__c = 'Chat Contáctanos Web';
                        // } // US575560-END
                        else {
                            casoUpdt.CC_Canal_Procedencia__c = oChatNew.CC_Canal_Procedencia__c;
                            casoUpdt.CC_Canal_Resolucion__c = oChatNew.CC_Canal_Procedencia__c;
                        }
                        
                    }
                    Id empleadoRecordType = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
                    if (mapCasos.get(oChatNew.CaseId).RecordTypeId == empleadoRecordType){
                        if(mapCasos.get(oChatNew.CaseId).CC_Tipo_ChatTranscript__c == 'Hidden' || mapCasos.get(oChatNew.CaseId).CC_Tipo_ChatTranscript__c == 'Agente'){
                            casoUpdt.OwnerId = oChatNew.OwnerId;
                            casoUpdt.CC_Tipo_ChatTranscript__c = mapChats.get(oChatNew.Id).CC_Tipo__c;
                            if (mapCasos.get(oChatNew.CaseId).Status == 'Cerrado'){
                                casoUpdt.Status = 'Activo';
                            }
                        }
                        /*if((casoUpdt.CC_Tipo_ChatTranscript__c == 'Hidden' && casoUpdt.CC_Tipo_ChatTranscript__c == 'Agente') && casoUpdt.Status == 'Cerrado'){
                            casoUpdt.Status = 'Activo';
                            casoUpdt.CC_Tipo_ChatTranscript__c = listChat.CC_Tipo__c;
                        } */   
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
                    
                    if(!String.valueOf(oChatNew.OwnerId).startsWith('00G')){
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
                }
            }
        }
        
        if (!casos.isEmpty()) { //update casos;   
            Database.SaveResult[] resultsCaso = Database.update(casos, false);
        }
        
        if (!nuevasActividades.isEmpty()) { //insert actividades
            //insert nuevasActividades;
            CC_Activity.crearActividades(nuevasActividades);
        }
    }

    private static void updateproveedor(Map<Id, LiveChatTranscript> mapOldObj, List<LiveChatTranscript> listNewObj) {

        List<Id> chatstosearch = new List<Id>();

        for (LiveChatTranscript NewChat : listNewObj) {
            LiveChatTranscript OldChat = mapOldObj.get(NewChat.Id);
            
                //Si el estado ha cambiado de Waiting, podemos buscar la traza asociada. Esto solo lo hacemos para chats de tipo agente
                if (OldChat.Status == 'Waiting' && NewChat.Status != 'Waiting' && NewChat.CC_Tipo__c == 'Agente') { 
                    chatstosearch.add(NewChat.Id);
                }
        }

        List<CC_TrazaInt__c> trazas = [SELECT Name, CC_TipoError__c, CC_MensajeSalida__c, CC_EstadoInt__c FROM CC_TrazaInt__c 
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

		Map<Id, String> maplctprov = new Map<Id, String>();
        Map<Id,Map<String,String>> mapProvInicialReparto = new Map<Id,Map<String,String>>();
		
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
			}//CC_Intentos_enrutamiento
		}
        // Proveedor inicial reparto
        if(!trazasProveedorInicialReparto.isEmpty()) {
			for (CC_TrazaInt__c trace : trazasProveedorInicialReparto) {
                Map<String,String> mapAux = new Map<String,String>();
                mapAux.put('ProveedorEnrutado',trace.CC_MensajeSalida__c );
                mapAux.put('NumeroEnrutamientos', trace.CC_EstadoInt__c);
                mapProvInicialReparto.put(trace.CC_TipoError__c, mapAux);
			}
		}

        if (!maplctprov.isEmpty() || !mapProvInicialReparto.isEmpty()) {
            for (LiveChatTranscript lct : listNewObj) {
                if (maplctprov.containsKey(lct.Id)){
                    lct.CC_Proveedor_Enrutado__c = maplctprov.get(lct.Id);
                }
                if (mapProvInicialReparto.containsKey(lct.Id)) {
                    String variableAux = mapProvInicialReparto.get(lct.Id).get('NumeroEnrutamientos');
                    lct.CC_Intentos_enrutamiento__c = !String.isEmpty(variableAux) ? variableAux : ''; 
                    lct.CC_Proveedor_Inicial_Reparto__c = mapProvInicialReparto.get(lct.Id).get('ProveedorEnrutado');
                }
            }
        }
     }
}