global class CC_OpenCTI {

    private static CC_Llamada_Input parseJson(String inputJson) {
        return (CC_Llamada_Input)JSON.deserialize(inputJson, CC_Llamada_Input.class);
    }

    webService static CC_Usuario_Genesys__c obtenerUsuarioGenesys() {
        return CC_Usuario_Genesys.obtenerDatosUsuario();
    }
    
    webService static String obtenerPrefijo(String telefono, String tipoPrefijo, String casoId) {
        Id recordId = casoId;
        if (recordId.getSobjectType() == Schema.getGlobalDescribe().get('Opportunity')) {
            String recordTypeOportunidad = [SELECT RecordType.DeveloperName FROM Opportunity WHERE Id = :recordId].RecordType.DeveloperName;
            if (recordTypeOportunidad == 'CSBD_CMN' || recordTypeOportunidad == 'CSBD_CMB') {
                return '54321';
            } else {
                return '55501';
            }
        } else {
            return CC_Servicio_Genesys.obtenerPrefijo(telefono, tipoPrefijo, casoId);
        }
    }
    
    webService static Id registrarLlamadaEntrante(String llamadaJson) {
        CC_Llamada_Input input = parseJson(llamadaJson);
        if (esServicioSach(input.servicio)) {
             return SACH_Llamada.registrarLlamadaEntrante(input).Id;
        }else if (esServicioCSBD(input.servicio)) {
            return CSBD_Llamada.registrarLlamadaEntrante(input).Id;
        } else {
        return CC_Llamada.registrarLlamadaEntrante(input).Id;
    }
    }

    webService static Id registrarLlamadaSaliente(String llamadaJson) {
        CC_Llamada_Input input = parseJson(llamadaJson);
        if (input.negocio == 'CSBD') {
            return CSBD_Llamada.registrarLlamadaSaliente(input).Id;
        } else if (input.negocio == 'CSBD + CC') {
            Id objetId = input.casoId;
            if(objetId.getSobjectType() == Schema.Opportunity.SObjectType){
                return CSBD_Llamada.registrarLlamadaSaliente(input).Id;
            }else{
                return CC_Llamada.registrarLlamadaSaliente(input).Id;
            }            
        }else if (esRegistroSach(input)) {
            return SACH_Llamada.registrarLlamadaSaliente(input).Id;
        } else {
            return CC_Llamada.registrarLlamadaSaliente(input).Id;
        }
    }
    
    @TestVisible 
    private static Boolean esServicioSach(String codigoServicio) {
        Boolean esServicioSach = false;
        if (!String.isEmpty(codigoServicio)) {
            esServicioSach = [SELECT CBK_Negocio__c FROM CC_Servicio_Genesys__c WHERE CC_Codigo__c = :codigoServicio].CBK_Negocio__c == 'SACH';
        }
        return esServicioSach;
    }

    @TestVisible 
    private static Boolean esServicioCSBD(String codigoServicio) {
        Boolean esServicioCSBD = false;
        if (!String.isEmpty(codigoServicio)) {
            esServicioCSBD = [SELECT CBK_Negocio__c FROM CC_Servicio_Genesys__c WHERE CC_Codigo__c = :codigoServicio].CBK_Negocio__c == 'CSBD';
        }
        return esServicioCSBD;
    }

    @TestVisible
    private static Boolean esRegistroSach(CC_Llamada_Input input) {
        Boolean esRegistroSach = false;
        if(!String.isBlank(input?.llamadaId) && input?.llamadaId != 'null'){
            Id recordId = String.valueOf(input.llamadaId);
            if(String.valueOf(recordId?.getSobjectType()) == 'Case') {
                List<Task> tarea = [SELECT Id, CC_Llamada_Id__c FROM Task 
                                        WHERE WhatId = :input.llamadaId AND CC_Llamada_Id__c != null AND RecordType.DeveloperName = 'SACH_Task' AND Status = 'Open' 
                                        ORDER BY CreatedDate DESC LIMIT 1];
                if(!tarea.isEmpty()) {
                    input.llamadaId = tarea[0].CC_Llamada_Id__c;                 
                }
            }
        }
        if (!String.isEmpty(input?.casoId)) {
            esRegistroSach = [SELECT RecordType.DeveloperName FROM Case WHERE Id = :input.casoId].RecordType.DeveloperName.startsWith('SACH_');
        } else if (!String.isEmpty(input?.llamadaId)) {
            esRegistroSach = [SELECT RecordType.DeveloperName FROM CC_Llamada__c WHERE Id = :input.llamadaId].RecordType.DeveloperName.startsWith('SACH_');
        }
        return esRegistroSach;
    }
    
    webService static Id registrarConsulta(String consultaJson) {
        //Solo aplica para CC
        CC_Llamada_Input input = parseJson(consultaJson);
        if (String.isEmpty(input.salesforceParentId)) {
            return CC_Llamada.registrarConsultaExterna(input).Id;
        } else {
            return CC_Llamada.registrarConsulta(input).Id;
        }
    } 

    webService static Id registrarConsultaNoAtendida(String llamadaJson, String consultaJson) {
        //Solo aplica para CC
        return CC_Llamada.registrarConsultaNoAtendida(parseJson(llamadaJson), parseJson(consultaJson));
    }

    webService static void registrarEncuesta(String llamadaJson) {
        if(!String.isBlank(llamadaJson)){
            CC_Llamada_Input input = parseJson(llamadaJson);
            CC_Llamada.registrarEncuesta(input);
        }
        
    }

//PENDENT
webService static void finalizarLlamada(String llamadaJson, String tipoCierre) {
    CC_Llamada_Input input = parseJson(llamadaJson);
    if (input.negocio == 'CSBD') {
        CSBD_Llamada.finalizarLlamada(input, tipoCierre);
    } else if (input.negocio == 'CSBD + CC') {
        List<Task> actividades = new List<Task>();
        Id recordId = String.valueOf(input.llamadaId);
        if(String.valueOf(recordId?.getSobjectType()) == 'Opportunity') {
            actividades = [SELECT Id, CC_Llamada_Id__c, RecordTypeId FROM Task 
                                    WHERE WhatId = :input.llamadaId AND CC_Llamada_Id__c != null AND RecordType.DeveloperName = 'CSBD_Task' AND Status = 'Open' 
                                    ORDER BY CreatedDate DESC LIMIT 1];
            if(!actividades.isEmpty()) {
                input.llamadaId = actividades[0].CC_Llamada_Id__c;                 
            }
        }
        else {
            actividades = [SELECT Id,RecordTypeId FROM Task WHERE CC_Llamada_Id__c = :input.llamadaId AND RecordType.DeveloperName = 'CSBD_Task' LIMIT 1];
        }
        if(!actividades.isEmpty()){
            CSBD_Llamada.finalizarLlamada(input, tipoCierre);
        }else{
            CC_Llamada.finalizarLlamada(input, tipoCierre);
        } 
    } else if (esRegistroSach(input)) {
        SACH_Llamada.finalizarLlamada(input, tipoCierre);
    } else {
        CC_Llamada.finalizarLlamada(input, tipoCierre);
    }
}

    webService static void finalizarConsulta(String consultaJson, String tipoCierre) {
        //Solo aplica para CC
        CC_Llamada.finalizarConsulta(parseJson(consultaJson), tipoCierre);
    }

    webService static void finalizarConsultaExterna(String consultaJson, String tipoCierre) {
        //Solo aplica para CC
        CC_Llamada.finalizarConsultaExterna(parseJson(consultaJson), tipoCierre);
    }

    webService static void cancelarConsulta(String consultaJson) {
        //Solo aplica para CC
        CC_Llamada.cancelarConsulta(parseJson(consultaJson));
    }

    webService static void completarConsulta(String consultaJson) {
        //Solo aplica para CC
        CC_Llamada.completarConsulta(parseJson(consultaJson));
    }

    webService static Contact obtenerEmpleadoGestor(String llamadaId) {
        //Solo aplica para CC
        return CC_Llamada.getEmpleadoGestor(llamadaId);
    }

    webService static CC_Servicio_Genesys__c obtenerServicioGenesys(String codigo) {
        return CC_Servicio_Genesys.getServicioGenesys(codigo);
    }

    webService static CC_Servicio_Genesys__c obtenerServicioGenesysDesdeCaso(String casoId) {
        return CC_Servicio_Genesys.getServicioGenesysDesdeCaso(casoId);
    }

    webService static Case obtenerCaso(String casoId) {
        return CC_Case.getDatosCaso(casoId);
    }

    webService static String obtenerIdiomaRegistro(String recordId) {
        Id id = recordId;
        if (id.getSobjectType() == Schema.getGlobalDescribe().get('Opportunity')) {
            //CSBD
            return CSBD_Llamada.getIdiomaOportunidad(id);
        } else {
            //CC
            return CC_Case.getDatosCaso(id)?.CC_Idioma__c;
        }
    }

    //Obtiene todos los metadatos de telefonía
    webService static String obtenerConfiguracionTelefonia() {
        return JSON.serialize([SELECT DeveloperName, CC_Valor__c FROM CC_Configuracion_Telefonia__mdt]);
    }
    
    //Obtiene el Id de un estado de omnichannel a partir de su developer name
    webService static ServicePresenceStatus obtenerEstadoOmnichannel(String estado) {
        return [SELECT DeveloperName FROM ServicePresenceStatus WHERE DeveloperName = :estado LIMIT 1];
    }

    /** Envía una interacción */	
    @TestVisible 
    private class CC_InteraccionInput {
        public String externalId {get;} //Id de la oportunidad por ejemplo
        public String interactionId {get;} //Id en Genesys/iWD
        public String ticketId {get;}
        public String proxyClientId {get;}
        public String medio {get;}
        public String usuario {get;}
        public String extension {get;}
        public String workItemId {get;}
        public String pendingServiceRoutingId {get;}
    }

    webService static String enviarInteraccion(String interaccionJson) {
        CC_InteraccionInput interaccion = (CC_InteraccionInput)JSON.deserialize(interaccionJson, CC_InteraccionInput.class);
        if (interaccion.medio != null && !interaccion.medio.equals('CHAT')) {
            return CSBD_Opportunity.asignacionIWD(interaccion.externalId, interaccion.interactionId);
        } else {
            return CC_WS_Routing.CC_AgentWork(interaccion.pendingServiceRoutingId, interaccion.ticketId, interaccion.proxyClientId, interaccion.interactionId, interaccion.usuario, interaccion.extension);
        }
    }
    
    //Obtiene la encuesta relacionada al canal de resolución del caso
    webService static CC_Servicio_Genesys__c obtenerServicioEncuestaDesdeCaso(Id casoId) {
        return CC_Servicio_Genesys.obtenerServicioEncuestaDesdeCaso(casoId);
    }
	
    webService static CC_Servicio_Genesys__c obtenerServicioSalienteGenesys(Id casoId) {
        return CC_Servicio_Genesys.obtenerServicioSaliente(casoId);
    }
    
    webService static CC_Servicio_Genesys__c obtenerServiciosSegundoNivel(Id casoId) {
        return CC_Servicio_Genesys.obtenerServiciosSegundoNivel(casoId);
    }
}