public with sharing class CC_Llamada_GC {
    
    private String param1;
    private String param2;
    private String param3;
    private Id idLlamada;
    
    public static Map<String, Object> registrarLlamadaEntrante(CC_Llamada_Input inputLlamada) {
        CC_Servicio_Genesys__c servicioGenesys = [SELECT Name, CC_Canal_Procedencia__c, CC_Tipo_Cliente__c, CC_Codigo__c, CC_Encuesta__r.CC_Codigo__c
													FROM CC_Servicio_Genesys__c WHERE CC_Codigo__c = :inputLlamada.servicio LIMIT 1];
        Case caso = null;
        Case casoVinculado = null;
        CC_Llamada__c llamada = new CC_Llamada__c(
            KIN_Genesys_Cloud__c = true,
        KIN_Llamada_Origen__c = true,
        CC_Tipo__c = String.isBlank(inputLlamada.nombreCampana) ? 'Entrante' : 'Saliente',
        CC_Agente__c = [SELECT EmployeeNumber FROM User WHERE Id = :UserInfo.getUserId()].EmployeeNumber,
        CC_Extension__c = inputLlamada.extension,
        CC_ConnId__c = inputLlamada.connId,
        CC_ANI__c = inputLlamada.ani,
        CC_DNIS__c = inputLlamada.dnis,
        CC_Servicio_Genesys__c = servicioGenesys.Id,
        CC_Idioma__c = codigoIdioma(inputLlamada.idioma),
        CC_Asunto__c = String.isNotEmpty(inputLlamada.userQuery) ? inputLlamada.userQuery.left(255) : inputLlamada.asunto.left(255),
        CC_Datos_Genesys__c = inputLlamada.datos,
        CC_ConnId_Cognitivo__c = inputLlamada.connIdCognitivo,
        CC_NumPerso__c = inputLlamada.numPerso,
        CC_Llamada_Padre__c = String.isEmpty(inputLlamada.salesforceParentId) ? null : inputLlamada.salesforceParentId,
        CC_No_Identificado__c = false,
        CC_Fecha_Inicio__c = CBK_UtilsDate.nowSYS(),
        CC_Id_Cognitivo__c = inputLlamada.cognitivoId,
        CC_IdentCliente__c = '0',  //Sin datos ALF
        CC_Campana_Genesys__c = inputLlamada.nombreCampana,
        CC_Perfil__c = inputLlamada.perfil,
        KIN_Genesys_Cloud_URL_Grabacion__c = inputLlamada.urlGrabacion,
        CC_Sentimiento__c = inputLlamada.sentiment,
        CC_Respuesta_Asistente__c = inputLlamada.assistantResponse,
        
        
        //Campo para US750318
        CC_LlamadoOficina__c = String.isEmpty(inputLlamada.telefonoUnico) ? false : true
            );
        
        
        if (servicioGenesys.CC_Codigo__c == 'INC_TEC_DESPLIEGUES') {
            llamada.CC_Canal_del_Empleado__c = 'Despliegues';
        } else if (servicioGenesys.CC_Codigo__c == 'INC_TEC_DESPLIEGUES2') {
            llamada.CC_Canal_del_Empleado__c = 'Despliegues2';
        } else if (servicioGenesys.CC_Codigo__c == 'CSI_HDT_DESBORDE') {
            //Cuando llega una llamada por desborde de CSI, se debe indicar siempre como canal de empleado CSI
            llamada.CC_Canal_del_Empleado__c = 'CSI';
        }
        
        if (servicioGenesys.CC_Tipo_Cliente__c == 'Empleado' || servicioGenesys.CC_Tipo_Cliente__c == 'CSI Bankia') {
            llamada.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', 'CC_Empleado');
            identificarPorTelefono(llamada, inputLlamada.ani);
            if (String.isEmpty(inputLlamada.casoId) && !String.isEmpty(llamada.CC_Id_Cognitivo__c)) {
                //Buscamos el caso correspondiente al Id de cognitivo. Si no lo encuentra, lo crea con la información de la llamada y el chat obtenido de cognitivo
                caso = CC_WS_Recupera_LogConversacion.CC_WS_Recupera_Conversacion(llamada);
            }
        } else {
            llamada.RecordTypeId = Schema.SObjectType.CC_Llamada__c.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            
            //GLM Logica para identificar el contacto en funcion de si viene o no el numperso, o por el numero de documento o por el ani
            Contact contactoAsociado = identificarPorNumPerso(llamada, inputLlamada.numPerso);
            if(contactoAsociado== null){
                //Buscamos contacto por numero de documento. Si encontramos varios, revisamos si hay alguno que sea cliente, si hay varios cogeremos el mas reciente, y sino hay cogeremos el mas reciente de los encontrados
                if(inputLlamada.vRUDoc != null && inputLlamada.vRUDoc !=''){
                    List<Contact> lstContactos = [SELECT Id, AccountId, Account.AV_Cliente__c, Account.CC_MarcaSenior__c, Account.CC_Empleado_Familiar__c 
												FROM Contact WHERE CC_Numero_Documento__c = :inputLlamada.vRUDoc 
												AND (RecordType.DeveloperName = 'CC_Cliente' OR Account.RecordType.DeveloperName = 'CC_ClientePA') AND Account.AV_Confidencial__c = false
												ORDER BY CreatedDate DESC];
                    
                    Contact cliente = null;
                    Contact noCliente = null;
                    for(Contact c: lstContactos){
                        if(c.Account.AV_Cliente__c && cliente == null){
                            cliente = c;
                        }
                        if(!c.Account.AV_Cliente__c && noCliente == null){
                            noCliente = c;
                        }
                    }
                    if(cliente != null){
                        llamada.CC_Cuenta__c = cliente.AccountId;
                        llamada.CC_Contacto__c = cliente.Id;
                        llamada.CC_IdentCliente__c = '0'; //Sin datos ALF
                        contactoAsociado = cliente;
                    }else if(noCliente != null){
                        llamada.CC_Cuenta__c = noCliente.AccountId;
                        llamada.CC_Contacto__c = noCliente.Id;
                        llamada.CC_IdentCliente__c = '0'; //Sin datos ALF
                        contactoAsociado = noCliente;
                    }
                }
                //Buscamos por ANI. Si encontramos varios, revisamos si hay alguno que sea cliente, si hay varios cogeremos el mas reciente, y sino hay cogeremos el mas reciente de los encontrados
                if(contactoAsociado==null && inputLlamada.ani !=null && inputLlamada.ani!=''){
                    String telefono = inputLlamada.ani;
                    telefono = telefono.replace('+3400', '');
                    telefono = telefono.replace('+34', '');
                    List<CC_Canal_Com__c> telefonos = [SELECT CC_ContactoId__c, CC_ContactoId__r.AccountId, CC_ContactoId__r.Account.AV_Cliente__c
														FROM CC_Canal_Com__c
														WHERE CC_Telefono__c =:telefono AND RecordType.DeveloperName = 'CC_Telefono'
														AND CC_ContactoId__r.Account.AV_Confidencial__c = false 
														AND (CC_ContactoId__r.RecordType.DeveloperName = 'CC_Cliente' OR CC_ContactoId__r.Account.RecordType.DeveloperName = 'CC_ClientePA')
														ORDER BY CreatedDate DESC];
                    Id clienteId = null;
                    Id noClienteId = null;
                    for(CC_Canal_Com__c c: telefonos){
                        if(c.CC_ContactoId__r.Account.AV_Cliente__c && clienteId == null){
                            clienteId = c.CC_ContactoId__c;
                        }
                        if(!c.CC_ContactoId__r.Account.AV_Cliente__c && noClienteId == null){
                            noClienteId = c.CC_ContactoId__c;
                        }
                    }
                    if(clienteId != null){
                        Contact cliente = [SELECT Id, AccountId, Account.CC_MarcaSenior__c, Account.CC_Empleado_Familiar__c FROM Contact WHERE Id = :clienteId LIMIT 1];
                        llamada.CC_Cuenta__c = cliente.AccountId;
                        llamada.CC_Contacto__c = cliente.Id;
                        llamada.CC_IdentCliente__c = '0'; //Sin datos ALF
                        contactoAsociado = cliente;
                    }else if(noClienteId != null){
                        Contact noCliente = [SELECT Id, AccountId, Account.CC_MarcaSenior__c, Account.CC_Empleado_Familiar__c FROM Contact WHERE Id = :noClienteId LIMIT 1];
                        llamada.CC_Cuenta__c = noCliente.AccountId;
                        llamada.CC_Contacto__c = noCliente.Id;
                        llamada.CC_IdentCliente__c = '0'; //Sin datos ALF
                        contactoAsociado = noCliente;
                    }
                }
            }
            
            if(!String.isEmpty(inputLlamada.summary)){
                llamada.CC_Resumen_AI__c = inputLlamada.summary;
            }else if(llamada.CC_Idioma__c == 'en' || contactoAsociado != null && (contactoAsociado.Account.CC_Empleado_Familiar__c || contactoAsociado.Account.CC_MarcaSenior__c)){
                llamada.CC_Resumen_AI__c = 'No hay conversación con el asistente';
            }else{
                llamada.CC_Resumen_AI__c = 'Sin Información';
            }
            if (String.isNotBlank(inputLlamada.statusAuto)) {
                //Validamos que el valor este dentro de la picklist CC_Status_Autorizacion__c
                List<String> valoresPermitidos = new List<String>();
                for (Schema.PicklistEntry picklistEntry : Schema.sObjectType.CC_Llamada__c.fields.CC_Status_Autorizacion__c.getPicklistValues()) {
                    
                    valoresPermitidos.add(picklistEntry.getValue());
                }
                if (valoresPermitidos.contains(inputLlamada.statusAuto)) {
                    llamada.CC_Status_Autorizacion__c = inputLlamada.statusAuto;
                } else {
                    llamada.CC_Status_Autorizacion__c = null;
                }
            }
            
        }
        finalizarLlamadasActividadesAbiertas(UserInfo.getUserId());
        insert llamada;
        
        if (String.isEmpty(inputLlamada.casoId)) {
            if (caso != null) {
                actualizarCaso(caso.Id, UserInfo.getUserId());
                vincularCaso(caso, llamada, servicioGenesys);
                casoVinculado = caso;
            }else {
                casoVinculado = crearVincularCaso(llamada);
            }
        } else {
            //Cuando se pasa el caso, es que se ha hecho una transferencia ciega y entra como llamada
            crearActividad(llamada.Id, inputLlamada.casoId, 'Llamada transferida', servicioGenesys.Name);
            actualizarCaso(inputLlamada.casoId, UserInfo.getUserId(), servicioGenesys.CC_Canal_Procedencia__c);
        }
        
        
        if(servicioGenesys.CC_Tipo_Cliente__c == 'Cliente'){
            Id casoIdCom = (casoVinculado != null && !String.isEmpty(String.valueOf(casoVinculado.Id))) ? casoVinculado.Id : inputLlamada.casoId;
            
            if(llamada.CC_Status_Autorizacion__c == 'DENIED' && !String.isEmpty(String.valueOf(casoIdCom))){
                CC_Comunicaciones__c comunicacion = crearComunicacion(llamada, casoIdCom, 'Denegado');
            }else if(llamada.CC_Status_Autorizacion__c == 'APPROVED' && !String.isEmpty(String.valueOf(casoIdCom))){
                CC_Comunicaciones__c comunicacion = crearComunicacion(llamada, casoIdCom, 'Aprobado');
            }else if(llamada.CC_Status_Autorizacion__c == 'REJECTED' && !String.isEmpty(String.valueOf(casoIdCom))){
                CC_Comunicaciones__c comunicacion = crearComunicacion(llamada, casoIdCom, 'Rechazado');
            }
        }
        
        Map<String, Object> mapReturn = new Map<String, Object>{
            'className' => CC_Llamada_GC.class.getName(),
            'llamada' => llamada,
            'caso' => casoVinculado,
            'encuestaId' => servicioGenesys.CC_Encuesta__r.CC_Codigo__c,
            'abrirTabId' => llamada.Id
        };
        List<Task> tarea = [SELECT Id, WhatId, What.RecordType.DeveloperName FROM Task WHERE CC_Llamada_Id__c = :llamada.Id];
        if (!tarea.isEmpty() && String.isNotBlank(tarea[0].What.RecordType.DeveloperName) && tarea[0].What.RecordType.DeveloperName == 'CC_Empleado') {
            mapReturn.put('abrirTabId', tarea[0].WhatId);
        }
        
        return mapReturn;
    }
    
    public static Map<String, Object> registrarLlamadaSaliente(CC_Llamada_Input inputLlamada) {
        finalizarLlamadasActividadesAbiertas(UserInfo.getUserId());
        
        // Obtener el usuario, servicios Genesys y caso en una sola consulta para eficiencia
        User usuario = [SELECT EmployeeNumber FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        
        Map<String, CC_Servicio_Genesys__c> servicioGenesysMap = new Map<String, CC_Servicio_Genesys__c>();
        for (CC_Servicio_Genesys__c servicio : [SELECT CC_Tipo_Cliente__c, Id, CC_Codigo__c FROM CC_Servicio_Genesys__c WHERE CC_Codigo__c IN ('CC_GenesysCloudOutboundDefault', 'CC_GenesysCloudOutboundDefaultEmpleados')]) {
            servicioGenesysMap.put(servicio.CC_Codigo__c, servicio);
        }
        
        Case caso = String.isNotBlank(inputLlamada.casoId) ?
            [SELECT CC_Canal_Resolucion__c, Subject, CC_Idioma__c, AccountId, ContactId,
					 CC_No_Identificado__c, RecordType.DeveloperName, OS_Proveedor__c, CC_Canal_Procedencia__c
			 FROM Case WHERE Id = :inputLlamada.casoId LIMIT 1] : null;
        
        if (String.isBlank(inputLlamada.nombreCampana)) {
            CC_Llamada__c llamada = new CC_Llamada__c(
                KIN_Genesys_Cloud__c = true,
            KIN_Llamada_Origen__c = true,
            CC_Tipo__c = 'Saliente',
            CC_Agente__c = usuario.EmployeeNumber,
            CC_Extension__c = inputLlamada.extension,
            CC_ConnId__c = inputLlamada.connId,
            CC_DNIS__c = inputLlamada.dnis,
            CC_Idioma__c = codigoIdioma(inputLlamada.idioma),
            CC_Asunto__c = String.isNotBlank(inputLlamada.asunto) ? inputLlamada.asunto.left(255) : null,
            CC_No_Identificado__c = false,
            CC_Fecha_Inicio__c = CBK_UtilsDate.nowSYS(),
            CC_IdentCliente__c = '0',
            KIN_Genesys_Cloud_URL_Grabacion__c = inputLlamada.urlGrabacion
                );
            
            // Asignar servicio y RecordType según el tipo de cliente
            String tipoCliente = caso?.RecordType.DeveloperName;
            if (tipoCliente == 'CC_Empleado' || tipoCliente == 'CC_CSI_Bankia') {
                llamada.CC_Servicio_Genesys__c = servicioGenesysMap.get('CC_GenesysCloudOutboundDefaultEmpleados')?.Id;
                llamada.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', 'CC_Empleado');
            } else {
                llamada.CC_Servicio_Genesys__c = servicioGenesysMap.get('CC_GenesysCloudOutboundDefault')?.Id;
                llamada.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', 'CC_Cliente');
            }
            
            try {
                insert llamada;
            } catch (Exception e) {
                CBK_Log.debug('Error al insertar llamada: ' + e.getMessage());
                
            }
            String tipoActividad = caso.CC_Canal_Procedencia__c == 'Call Me Back' ? 'Llamada CMB' : 'Llamada saliente';
            crearActividad(llamada.Id, inputLlamada.casoId, tipoActividad, null);
            return new Map<String, Object>{
                'className' => CC_Llamada_GC.class.getName(),
                'llamada' => llamada,
                'idioma' => caso?.CC_Idioma__c != null ? formatoIdiomaGenesys(caso.CC_Idioma__c) : null,
                'proveedor' => caso?.OS_Proveedor__c != null ? caso.OS_Proveedor__c : ''
            };
        }
        
        return registrarLlamadaEntrante(inputLlamada);
    }

    public static Map<String, Object> registrarConsulta(CC_Llamada_Input inputConsulta) {
        finalizarLlamadasActividadesAbiertas(UserInfo.getUserId());
        CC_Servicio_Genesys__c servicioGenesys = [SELECT Name, CC_Activo_Salesforce__c, CC_Tipo__c, CC_Tipo_Cliente__c
													FROM CC_Servicio_Genesys__c WHERE CC_Codigo__c = :inputConsulta.servicio LIMIT 1];
        
        CC_Llamada__c llamada = [SELECT CC_Idioma__c, CC_Contacto__c, CC_Cuenta__c, CC_Cuenta__r.AV_OficinaPrincipal__c,
									CC_Cuenta__r.CC_OficinaGestoraId__c, CC_No_Identificado__c, OwnerId, CC_IdentCliente__c, RecordTypeId
									FROM CC_Llamada__c WHERE Id = :inputConsulta.salesforceParentId];
        
        Case caso = [SELECT Subject, CC_Idioma__c, AccountId, ContactId FROM Case WHERE Id = :inputConsulta.casoId];
        
        CC_Llamada__c consulta = new CC_Llamada__c(
            RecordTypeId = llamada.RecordTypeId,
        KIN_Genesys_Cloud__c = true,
        KIN_Consulta__c = true,
        CC_Tipo__c = 'Entrante',
        CC_Agente__c = [SELECT EmployeeNumber FROM User WHERE Id = :UserInfo.getUserId()].EmployeeNumber,
        CC_Extension__c = inputConsulta.extension,
        CC_ConnId__c = null,
        CC_ConnId_Consulta__c = inputConsulta.connId,
        CC_ANI__c = inputConsulta.ani,
        CC_DNIS__c = inputConsulta.dnis,
        CC_Servicio_Genesys__c = servicioGenesys.Id,
        CC_Asunto__c = caso.Subject,
        CC_Case_Consulta__c = caso.Id,
        CC_Llamada_Padre__c = llamada.Id,
        CC_Idioma__c = codigoIdioma(inputConsulta.idioma),
        CC_Contacto__c = llamada.CC_Contacto__c,
        CC_Cuenta__c = llamada.CC_Cuenta__c,
        CC_No_Identificado__c = llamada.CC_No_Identificado__c,
        CC_Fecha_Inicio__c = CBK_UtilsDate.nowSYS(),
        CC_IdentCliente__c = llamada.CC_IdentCliente__c,
        KIN_Genesys_Cloud_URL_Grabacion__c = inputConsulta.urlGrabacion
            );
        insert consulta;
        
        crearActividad(consulta.Id, caso.Id, tipoConsulta(servicioGenesys), servicioGenesys.Name);
        // return consulta;
        return new Map<String, Object>{'className' => CC_Llamada_GC.class.getName(), 'llamada' => consulta, 'caso' => caso};
    }
    
    public static Id registrarConsultaNoAtendida(CC_Llamada_Input inputLlamada, CC_Llamada_Input inputConsulta) {
        if (String.isNotBlank(inputConsulta.servicio)) {
            CC_Servicio_Genesys__c servicioGenesys = [SELECT Name, CC_Activo_Salesforce__c, CC_Tipo__c, CC_Tipo_Cliente__c
														FROM CC_Servicio_Genesys__c WHERE CC_Codigo__c = :inputConsulta.servicio LIMIT 1];
            String tipoActividad = tipoConsulta(servicioGenesys);
            return crearActividad(inputLlamada.llamadaId, inputConsulta.casoId, tipoActividad, servicioGenesys.Name, 'Consulta no atendida');
        } else if (String.isNotBlank(inputConsulta.empleadoTelefono)) {
            return crearActividadEmpleado(inputConsulta.salesforceParentId, inputConsulta.casoId, inputConsulta.empleadoId, inputConsulta.empleadoTelefono, 'Consulta no atendida', 'Consulta externa a empleado no atendida');
        } else {
            IllegalArgumentException excepcion = new IllegalArgumentException();
            excepcion.setMessage('No se puede registrar una consulta no atendida sin servicio/empleado.');
            throw excepcion;
        }
    }
    
    public static Map<String, Object> registrarEncuesta(CC_Llamada_Input inputLlamada) {
        String nombreEncuesta;
        if (String.isNotBlank(inputLlamada.llamadaId)) {
            String connId = String.valueOf(inputLlamada.connId);
            List<CC_Llamada__c> llamada = [SELECT Id, CC_Servicio_Genesys__r.CC_Encuesta__r.Name, CC_Tipo__c FROM CC_Llamada__c WHERE CC_ConnId__c = :connId AND RecordType.DeveloperName IN ('CC_Cliente', 'CC_Empleado') ORDER BY CreatedDate DESC];
            Id idLlamada = llamada[0].Id;
            
            llamada[0].CC_Encuesta__c = llamada[0].CC_Servicio_Genesys__r.CC_Encuesta__c;
            nombreEncuesta = llamada[0].CC_Servicio_Genesys__r.CC_Encuesta__r.Name;
            
            if (String.isEmpty(llamada[0].CC_Encuesta__c) && llamada[0].CC_Tipo__c == 'Saliente') {
                List<Task> tareas = [SELECT WhatId FROM Task WHERE CC_Llamada_Id__c = :idLlamada ORDER BY CreatedDate DESC LIMIT 1];
                if (!tareas.isEmpty()) {
                    Id idCaso = Id.valueOf(tareas[0].WhatId);
                    if (idCaso != null) {
                        CC_Servicio_Genesys__c svcGenesys = CC_Servicio_Genesys.obtenerServicioEncuestaDesdeCaso(idCaso);
                        if (svcGenesys != null) {
                            llamada[0].CC_Encuesta__c = svcGenesys.CC_Encuesta__c;
                            nombreEncuesta = svcGenesys.CC_Encuesta__r.Name;
                        }
                    }
                }
            }
            update llamada[0];
            
            
            try {
                
                DateTime dt = DateTime.now();
                Long dateInMilliseconds = dt.getTime();
                
                AsyncOptions options = new AsyncOptions();
                options.DuplicateSignature = QueueableDuplicateSignature.Builder()
                    .addId(UserInfo.getUserId())
                    .addString(String.valueOf(dateInMilliseconds))
                    .build();
                
                crearActividadCasosQueueable crearActividad = new crearActividadCasosQueueable();
                Id idLlamadaParam =  idLlamada;
                String param1 = 'Encuesta';
                String param2 = nombreEncuesta;
                String param3 = 'Encuesta enviada';
                crearActividad.setParams(llamada[0].Id, param1, param2, param3);
                System.enqueueJob(crearActividad);
                
            } catch (DuplicateMessageException ex) {
                //Exception is thrown if there is already an enqueued job with the same signature
                CBK_Log.error(ex);
            }
            //crearActividadCasos(idLlamada, 'Encuesta', nombreEncuesta, 'Encuesta enviada');
        }
        return new Map<String, Object>{
            'className' => 'CC_Llamada_GC',
            'nombreEncuesta' => nombreEncuesta
        };
    }
    
    public class crearActividadCasosQueueable implements Queueable {
        
        private String param1;
        private String param2;
        private String param3;
        private Id idLlamadaParam;
        
        public void setParams(Id idLlamadaParam,String param1,String param2, String param3) {
            this.idLlamadaParam = idLlamadaParam;
            this.param1 = param1;
            this.param2 = param2;
            this.param3 = param3;
        }
        
        public void execute(QueueableContext context) {
            crearActividadCasosNoFuture(idLlamadaParam, param1, param2, param3);
        }
    }
    
    private static String buscarLlamada(CC_Llamada_Input jsonLlamada, Boolean esConsulta) {
        String resultado = jsonLlamada.llamadaId;
        if (String.isEmpty(resultado)) {
            Map<String, Object> queryBinds = new Map<String, Object>{
                'recordTypesLlamada' => new List<String>{'CC_Cliente', 'CC_Empleado'},
                'interactionId' => jsonLlamada.connId,
                'numeroEmpleado' => [SELECT EmployeeNumber FROM User WHERE Id = :UserInfo.getUserId()].EmployeeNumber,
                'esConsulta' => esConsulta
            };
            String queryString = 'SELECT Id FROM CC_Llamada__c WHERE RecordType.DeveloperName IN :recordTypesLlamada';
            queryString += ' AND ' + (esConsulta ? 'CC_ConnId_Consulta__c' : 'CC_ConnId__c') + ' = :interactionId';
            queryString += ' AND CC_Agente__c = :numeroEmpleado AND KIN_Consulta__c = :esConsulta AND CC_Fecha_Fin__c = NULL';
            
            List<CC_Llamada__c> llamadas = Database.queryWithBinds(queryString, queryBinds, AccessLevel.USER_MODE);
            if (llamadas.size() == 1) {
                resultado = llamadas[0].Id;
            }
        }
        return resultado;
    }
    
    public static Map<String, Object> finalizarLlamada(CC_Llamada_Input inputLlamada, String tipoCierre) {
        	String llamadaId = buscarLlamada(inputLlamada, false);
        	if (String.isNotBlank(llamadaId)) {
            CC_Llamada__c llamada = [SELECT CC_Tipo_Cierre__c FROM CC_Llamada__c WHERE Id = :llamadaId];
            // US1299643: Registrar tarea de Llamadas emitidas desde Salesforce
            if (llamada.CC_Tipo_Cierre__c != 'Llamada atendida' && llamada.CC_Tipo_Cierre__c != 'Llamada finalizada') {
                tipoCierre = 'Llamada no atendida';
            }
            finalizarLlamadaActividades(llamada, 'Llamada%', tipoCierre);
        	}
        	return new Map<String, Object>{'className' => CC_Llamada_GC.class.getName(), 'idLlamada' => llamadaId};
    }
    
    public static Boolean finalizarConsulta(CC_Llamada_Input inputConsulta, String tipoCierre) {
        String consultaId = buscarLlamada(inputConsulta, true);
        if (String.isNotBlank(consultaId)) {
            finalizarLlamadaActividades(new CC_Llamada__c(Id = consultaId), 'Consulta%', tipoCierre);
            return true;
        } else {
            return false;
        }
    }
    
    public static Boolean cancelarConsulta(CC_Llamada_Input inputConsulta) {
        String consultaId = buscarLlamada(inputConsulta, true);
        if (String.isNotBlank(consultaId)) {
            finalizarLlamadaActividades(new CC_Llamada__c(Id = consultaId), 'Consulta%', 'Consulta cancelada');
            return true;
        } else {
            return false;
        }
    }
    
    public static Map<String, Object> completarConsulta(String connIdConsulta, Id idNuevoOwner) {

        CC_Settings__c settings = CC_Settings__c.getValues('CC_Colas_HDT_CCO_Activas');
        
        CC_Llamada__c consulta = [SELECT CC_ConnId_Consulta__c, CC_Llamada_Padre__c, CC_Case_Consulta__c, OwnerId, CC_Servicio_Genesys__r.Name,
									CC_Servicio_Genesys__r.CC_Tipo__c, CC_Servicio_Genesys__r.CC_Activo_Salesforce__c, CC_Servicio_Genesys__r.CC_Canal_Procedencia__c,  CC_Servicio_Genesys__r.CC_Tipo_Cliente__c,
									CC_Servicio_Genesys__r.CC_Grupo__c, RecordType.DeveloperName, CC_Case_Consulta__r.ContactId
									FROM CC_Llamada__c WHERE RecordType.DeveloperName IN ('CC_Cliente', 'CC_Empleado')
									AND CC_ConnId_Consulta__c = :connIdConsulta AND CC_Fecha_Fin__c = NULL AND OwnerId = :idNuevoOwner AND KIN_Consulta__c = TRUE];
        consulta.CC_ConnId__c = consulta.CC_ConnId_Consulta__c;
        update consulta;
        finalizarActividadesLlamada(consulta, 'Consulta%', 'Consulta completada');
        if (consulta.RecordType.DeveloperName == 'CC_Empleado') {
            crearActividadEmpleados(consulta.Id, consulta.CC_Case_Consulta__c, 'Llamada transferida', consulta.CC_Servicio_Genesys__r.Name, 'Llamada transferida', consulta.CC_Servicio_Genesys__r.CC_Grupo__c, consulta.CC_Case_Consulta__r.ContactId);
        } else {
            crearActividad(consulta.Id, consulta.CC_Case_Consulta__c, 'Llamada transferida',  consulta.CC_Servicio_Genesys__r.Name, 'Llamada transferida');
        }
        
        if (consulta.CC_Servicio_Genesys__r.CC_Tipo__c.equals('Tercer nivel')) {
            traspasarTercerNivel(consulta.CC_Case_Consulta__c, idNuevoOwner, consulta.CC_Servicio_Genesys__r.Name, consulta.Id, consulta.CC_Servicio_Genesys__r.CC_Tipo_Cliente__c, consulta.CC_Servicio_Genesys__r.CC_Grupo__c);
        } else if (consulta.CC_Case_Consulta__c != null) {
            if (consulta.CC_Servicio_Genesys__r.CC_Tipo__c.equals('Servicio')) {
                //El canal de resolución sólo se actualiza para transferencias entre servicios normales
                actualizarCaso(consulta.CC_Case_Consulta__c, idNuevoOwner, consulta.CC_Servicio_Genesys__r.CC_Canal_Procedencia__c);
            } else if(settings.CC_Activa__c && consulta.CC_Servicio_Genesys__r.CC_Canal_Procedencia__c == 'CCO' && consulta.CC_Servicio_Genesys__r.CC_Tipo_Cliente__c == 'Empleado' && consulta.CC_Servicio_Genesys__r.CC_Tipo__c == 'Tranferencias CCO HDT'){
                    CC_Transferir_HDT_CCO transfer = new CC_Transferir_HDT_CCO(consulta.CC_Case_Consulta__c, idNuevoOwner, consulta, 'CC');
                    Case caso = transfer.transferEmpleado();
            } else {
                actualizarCaso(consulta.CC_Case_Consulta__c, idNuevoOwner);
            }
        }
        
        CC_Llamada__c llamadaCliente = [SELECT CC_Servicio_Genesys__r.Name FROM CC_Llamada__c WHERE Id = :consulta.CC_Llamada_Padre__c];
        //Cierre de la llamada con el cliente
        finalizarLlamadaActividades(llamadaCliente, 'Llamada%', 'Llamada finalizada');
        //DMV: Devuelve un mapa con el tipo de consulta que se completó: consulta.CC_Servicio_Genesys__r.CC_Tipo__c y con la llamada id nueva..
        return new Map<String, Object>{'tipoServicio' => consulta.CC_Servicio_Genesys__r.CC_Tipo__c, 'llamadaId' => consulta.Id};
        //MMC añadido caso al retorno
        //return new Map<String, Object>{'tipoServicio' => consulta.CC_Servicio_Genesys__r.CC_Tipo__c, 'llamadaId' => consulta.Id, 'caso' => consulta.CC_Case_Consulta__c};

    }
    
    public static Case crearVincularCaso(CC_Llamada__c llamada) {
        CC_Servicio_Genesys__c servicioGenesys = [SELECT Name, CC_Canal_Procedencia__c, CC_Canal_de_Entrada__c, CC_Activo_Salesforce__c, CC_Tipo__c, CC_Tipo_Cliente__c
													FROM CC_Servicio_Genesys__c WHERE Id = :llamada.CC_Servicio_Genesys__c];
        Case caso = crearCaso(llamada, servicioGenesys);
        vincularCaso(caso, llamada, servicioGenesys);
        return [SELECT Id,CaseNumber, Status, Owner.Name, CreatedDate, Subject FROM Case WHERE Id = :caso.Id];
    }
    
    public static void crearVincularCasoDesborde(CC_Llamada__c llamada, CC_Servicio_Genesys__c servicioGenesys) {
        Case caso = crearCaso(llamada, servicioGenesys, true);
        vincularCaso(caso, llamada, servicioGenesys);
    }
    
    public static Case crearCaso(CC_Llamada__c llamada, CC_Servicio_Genesys__c servicioGenesys){
        return crearCaso(llamada, servicioGenesys, false);
    }
    
    public static Case crearCaso(CC_Llamada__c llamada, CC_Servicio_Genesys__c servicioGenesys, Boolean esDesborde) {
        
        String telefonoCaso;
        List<Account> cuenta = new List<Account>();
        if (llamada.CC_Cuenta__c != null) {
            cuenta = [SELECT Phone, PersonMobilePhone, CC_MarcaSenior__c, CC_Empleado_Familiar__c  FROM Account WHERE Id = :llamada.CC_Cuenta__c];
            if (cuenta[0].PersonMobilePhone != null) {
                telefonoCaso = cuenta[0].PersonMobilePhone;
            } else if (cuenta[0].Phone != null) {
                telefonoCaso = cuenta[0].Phone;
            }
        }
        
        Case caso = new Case(
            Subject = llamada.CC_Asunto__c,
        Origin = servicioGenesys.CC_Canal_de_Entrada__c == 'Telefono' ? 'Phone' : String.isBlank(servicioGenesys.CC_Canal_de_Entrada__c) ? 'Phone' : servicioGenesys.CC_Canal_de_Entrada__c,
        CC_Canal_Respuesta__c = 'Phone',
        CC_Telefono_Contacto__c = llamada.CC_ANI__c,
        OS_Telefono__c = telefonoCaso,
        CC_Canal_Procedencia__c = esDesborde? 'Call Me Back':servicioGenesys.CC_Canal_Procedencia__c,
        CC_Idioma__c = llamada.CC_Idioma__c,
        AccountId = llamada.CC_Cuenta__c,
        ContactId = llamada.CC_Contacto__c,
        CC_Representante__c = llamada.CC_Representante__c,
        CC_IdentCliente__c = llamada.CC_IdentCliente__c,
        Canal_del_Empleado__c = llamada.CC_Canal_del_Empleado__c,
        CC_Id_Cognitivo__c = llamada.CC_Id_Cognitivo__c,
        CC_Status_Autorizacion__c = llamada.CC_Status_Autorizacion__c,
        CC_Sentimiento__c = llamada.CC_Sentimiento__c,
        CC_Respuesta_Asistente__c = llamada.CC_Respuesta_Asistente__c
            );
        
        if (servicioGenesys.CC_Tipo_Cliente__c == 'Cliente') {
            
            caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
            caso.CC_Tipo_Cliente__c = 'Cliente';
            caso.CC_OTP_Nivel__c = llamada.CC_Status_Autorizacion__c != null ? 'Cliente Digital' : '';
            
            if (llamada.CC_Cuenta__c != null) {
                caso.CC_Oficina_Afectada_Lookup__c = llamada.CC_Cuenta__r.AV_OficinaPrincipal__c;
            }
            
            if(!String.isEmpty(llamada.CC_Resumen_AI__c)){
                caso.CC_Resumen_AI__c = llamada.CC_Resumen_AI__c;
            }else if(!cuenta.isEmpty() || llamada.CC_Idioma__c == 'en' && (cuenta[0].CC_Empleado_Familiar__c || cuenta[0].CC_MarcaSenior__c)){
                caso.CC_Resumen_AI__c = 'No hay conversación con el asistente';
            }else{
                caso.CC_Resumen_AI__c = 'Sin Información';
            }
            
            
            
        } else if (servicioGenesys.CC_Tipo_Cliente__c == 'Empleado') {
            caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
            caso.CC_Tipo_Cliente__c = 'Empleado';
            caso.CC_Fecha_Traslado_1N__c = DateTime.now();
            //Identificar si es un caso de agente de desborde y ponerlo en la cola
			if(esDesborde){ //Este campo se informa en el WS. 
				//Buscar la cola
				CC_Settings__c settings = CC_MetodosUtiles.getCustomSetting('CC_ColaAgenteDesborde');
				if(settings != null){
					Group cola = [
						SELECT Id 
						FROM Group 
						WHERE DeveloperName = :settings.CC_Configuracion_1__c AND Type = 'Queue' 
						LIMIT 1
					];
					if(cola != null){
					    caso.OwnerId = cola.Id;
                        caso.CC_Admin__c = false;
				    }
			    }
            }
        } else if (servicioGenesys.CC_Tipo_Cliente__c == 'CSI Bankia') {
            caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_CSI_Bankia');
            caso.CC_Tipo_Cliente__c = 'Empleado';
        }
        
        //Preparar el contacto intermedio
        if (servicioGenesys.CC_Canal_Procedencia__c == 'Atención al Cliente') {
            caso.CC_Cont_Interm_Delay__c = CC_MetodosUtiles.delayContactoIntermedio('CC_Contacto_Intermedio_AC_ES', 'CC_Contacto_Intermedio_AC');
        }
        insert caso;
        return caso;
    }
    
    private static CC_Comunicaciones__c crearComunicacion(CC_Llamada__c llamada, Id caseId, String estado){
        List<CC_Comunicaciones__c> comunicaciones = [SELECT Id FROM CC_Comunicaciones__c WHERE CreatedDate = TODAY AND CC_Origen__c = 'Cognitivo' AND CC_Case__c = :caseId];
        if(comunicaciones.isEmpty()){
            CC_Comunicaciones__c comunicacion = new CC_Comunicaciones__c(
                CC_Case__c = caseId,
            CC_Cliente__c = llamada.CC_Cuenta__c,
            CC_Estado__c = estado,
            CC_Nivel__c = 'Cliente Digital',
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Comunicaciones__c', 'CC_OTPSMS'),
            CC_Tipo_Llamada__c = llamada.CC_Tipo__c,
            CC_Origen__c = 'Cognitivo'
                );
            insert comunicacion;
            return comunicacion;
        }
        return null;
    }
    
    public static void vincularCaso(Case caso, CC_Llamada__c llamada, CC_Servicio_Genesys__c servicioGenesys) {
        String tipoActividad;
        if (llamada.CC_ConnId__c == null) { //Si es una consulta
            tipoActividad = tipoConsulta(servicioGenesys);
        } else {
            tipoActividad = llamada.CC_Tipo__c.equals('Saliente') ? 'Llamada saliente' : 'Llamada entrante';
        }
        crearActividad(llamada.Id, caso.Id, tipoActividad, servicioGenesys.Name);
    }
    
    @TestVisible
    // private static void identificarPorNumPerso(CC_Llamada__c llamada, String numPerso) {
	private static Contact identificarPorNumPerso(CC_Llamada__c llamada, String numPerso) {
		Contact retorno = null;
		//Realizamos una búsqueda para informar el contacto y la cuenta
		if(llamada != null){
			if (!String.isEmpty(llamada.CC_DNIS__c)) {
				List<Account> cuentas = [SELECT Id, Name, CC_Inactivo__c, CC_Centro_Integrador__c, CC_Tipo_Centro__c FROM Account
										WHERE Phone = :llamada.CC_DNIS__c AND recordType.Developername = 'CC_CentroCaixaBank'
										AND CC_Tipo_Centro__c = 'OF' AND CC_Inactivo__c = FALSE AND CC_Centro_Integrador__c = NULL LIMIT 1];
				if (!cuentas.isEmpty()) {
					llamada.CC_Oficina_Contactada__c = cuentas[0].Id;
				}
			}
		}
		if (!String.isEmpty(numPerso)) {
			Boolean identificarConAlf = false;
			if (!Test.isRunningTest()) {
				List<CC_Identificacion_Telefonia__mdt> mdt = [SELECT Id FROM CC_Identificacion_Telefonia__mdt
															WHERE CC_Identificar_Mediante_ALF__c = TRUE LIMIT 1];
				identificarConAlf = !mdt.isEmpty();
			}
			
			if (identificarConAlf) {
				//Identificación contra Alfabetico
				List<Contact> contactos = new List<Contact>();
				Map<String, Object> mapaCuentasContactos = CC_IdentCliente_Future.getIdentificacionALF('NP', numPerso);
				List<Account> cuentas = (List<Account>)mapaCuentasContactos.get('CUENTAS');
				List<Account> cuentasAct = new List<Account>();
				
				if (cuentas.size() == 1) {
					/*if (llamada.CC_Perfil__c == 'EMPLEADOS'){
						cuentas[0].CC_Eapizado_4223__c = true;
						Account cuentaSinNombre = new Account(Id=cuentas[0].Id, CC_Eapizado_4223__c=cuentas[0].CC_Eapizado_4223__c);
						cuentasAct.add(cuentaSinNombre);
					}*/
					if (llamada.CC_Perfil__c != '' && llamada.CC_Perfil__c != null){
						cuentas[0].CC_Perfil__c = llamada.CC_Perfil__c;
						cuentasAct.add(new Account(Id = cuentas[0].Id, CC_Perfil__c = cuentas[0].CC_Perfil__c));
					}
					
					// Cambio para añadir representantes.
					if (mapaCuentasContactos.containsKey('REPRESENTANTES')) {
						contactos = (List<Contact>)mapaCuentasContactos.get('REPRESENTANTES');
						if (contactos.size() == 1) {
							llamada.CC_Cuenta__c = cuentas[0].Id;
							llamada.CC_Contacto__c = contactos[0].Id;
							llamada.CC_IdentCliente__c = '1'; // Alfabético automático
							retorno = contactos[0];
						}
					} else if (mapaCuentasContactos.containsKey('CONTACTOS')) {
						contactos = (List<Contact>)mapaCuentasContactos.get('CONTACTOS');
						if (contactos.size() == 1) {
							llamada.CC_Cuenta__c = cuentas[0].Id;
							llamada.CC_Contacto__c = contactos[0].Id;
							llamada.CC_IdentCliente__c = '1'; // Alfabético automático
							retorno = contactos[0];
						}
					}
				}
				if (!cuentasAct.isEmpty()) {
					Database.update(cuentasAct, false);
				}
			} else {
				//Identificación contra BD
				List<Contact> contactos = [SELECT AccountId, Account.CC_MarcaSenior__c, Account.CC_Empleado_Familiar__c FROM Contact WHERE CC_NumPerso__c = :numPerso
										AND (RecordType.DeveloperName = 'CC_Cliente' OR Account.RecordType.DeveloperName = 'CC_ClientePA') AND Account.AV_Confidencial__c = false LIMIT 2];
				if (contactos.size() == 1) {
					llamada.CC_Cuenta__c = contactos[0].AccountId;
					llamada.CC_Contacto__c = contactos[0].Id;
					llamada.CC_IdentCliente__c = '0'; //Sin datos ALF
					retorno = contactos[0];
				}
			}
		}
		return retorno;
	}
	
	@TestVisible
	private static void identificarPorTelefono(CC_Llamada__c llamada, String telefono) {
		
		if (!String.isEmpty(telefono)) {
			telefono = telefono.replace('+3400', '');
			telefono = telefono.replace('+34', '');
			
			List<CC_Canal_Com__c> telefonos = [SELECT CC_ContactoId__c, CC_ContactoId__r.AccountId FROM CC_Canal_Com__c
											WHERE CC_Telefono__c =:telefono AND RecordType.DeveloperName = 'CC_Telefono'
											AND CC_ContactoId__r.RecordType.DeveloperName = 'CC_Empleado' LIMIT 2];
			if (telefonos.size() == 1 ) {
				llamada.CC_Cuenta__c = telefonos[0].CC_ContactoId__r.AccountId;
				llamada.CC_Contacto__c = telefonos[0].CC_ContactoId__c;
			}
		}
	}
	
	private static String obtenerTipoCierre(String tipoCierre) {
		for (Schema.PicklistEntry tipo : CC_Llamada__c.CC_Tipo_Cierre__c.getDescribe().getPicklistValues()) {
			if (tipo.getValue().equals(tipoCierre)) {
				return tipo.getLabel();
			}
		}
		return tipoCierre;
	}
	
	private static void finalizarActividadesLlamada(CC_Llamada__c llamada, String tipoActividad, String tipoCierre) {
		finalizarActividadesLlamada(new List<CC_Llamada__c>{llamada}, tipoActividad, tipoCierre);
	}
	
	private static void finalizarActividadesLlamada(List<CC_Llamada__c> llamadas, String tipoActividad, String tipoCierre) {
		if (llamadas.isEmpty()) {
			return;
		}
		List<Task> tareas = [SELECT Id FROM Task WHERE CC_Llamada_Id__c IN :CC_MetodosUtiles.listaCampo(llamadas, 'Id')
							AND Status = 'Open' AND Type LIKE :tipoActividad AND RecordType.DeveloperName = 'CC_Task'];
		for (Task actividad : tareas) {
			actividad.CC_Fecha_Fin__c = CBK_UtilsDate.nowSYS();
			actividad.CC_Tipo_Cierre__c = obtenerTipoCierre(tipoCierre);
			actividad.Status = 'Completed';
		}
		update tareas;
	}
	
	//Metodo nuevo para la optimización de código: Nerea Sanchez-Bermejo, Octubre 2021
	private static void finalizarActividadesNew(List<CC_Llamada__c> llamadas) {
		if (!llamadas.isEmpty()) {
			List<Id> llamadaIds = new List<Id>();
			for (CC_Llamada__c llamada : llamadas) {
				llamadaIds.add(llamada.Id);
			}
			
			List<Task> actividadesActualizar = new List<Task>();
			for (Task actividad : [SELECT Type FROM Task WHERE CC_Llamada_Id__c IN :llamadaIds
								AND Status = 'Open' AND RecordType.DeveloperName = 'CC_Task']) {
				if (actividad.Type.startsWith('Consulta')) {
					actividad.CC_Tipo_Cierre__c = obtenerTipoCierre('Consulta cancelada');
				} else if (actividad.Type.startsWith('Llamada')) {
					actividad.CC_Tipo_Cierre__c = obtenerTipoCierre('Llamada finalizada');
				}
				actividad.CC_Fecha_Fin__c = CBK_UtilsDate.nowSYS();
				actividad.Status = 'Completed';
				actividadesActualizar.add(actividad);
			}
			update actividadesActualizar;
		}
	}
	
	private static void finalizarLlamadas(List<CC_Llamada__c> llamadas, String tipoCierre) {
		for (CC_Llamada__c llamada : llamadas) {
			llamada.CC_Fecha_Fin__c = CBK_UtilsDate.nowSYS();
			llamada.CC_Tipo_Cierre__c = tipoCierre;
		}
		update llamadas;
	}
	
	private static void finalizarLlamadaActividades(CC_Llamada__c llamada, String tipoActividad, String tipoCierre) {
		finalizarLlamadasActividades(new List<CC_Llamada__c>{llamada}, tipoActividad, tipoCierre);
	}
	
	private static void finalizarLlamadasActividades(List<CC_Llamada__c> llamadas, String tipoActividad, String tipoCierre) {
		if (!llamadas.isEmpty()) {
			finalizarLlamadas(llamadas, tipoCierre);
			finalizarActividadesLlamada(llamadas, tipoActividad, tipoCierre);
		}
	}
	
	private static void finalizarLlamadasActividadesAbiertas(Id userId) {
		List<CC_Llamada__c> llamadas = [SELECT Id FROM CC_Llamada__c WHERE RecordType.DeveloperName IN ('CC_Cliente', 'CC_Empleado')
									AND CC_Fecha_Fin__c = NULL AND OwnerId = :userId];
		finalizarLlamadas(llamadas, 'Llamada finalizada');
		finalizarActividadesNew(llamadas);
	}
	
	private static Task crearObjetoActividad(Id llamadaId, Id whatId, String tipoActividad, String asunto, String tipoCierre, Id contactId) {
		Task actividad = new Task(
			Subject = tipoActividad + (asunto != null ? ' (' + asunto + ')' : ''),
		CC_Llamada_Id__c = llamadaId,
		ActivityDate = CBK_UtilsDate.todaySYS(),
		CC_Fecha_Inicio__c = CBK_UtilsDate.nowSYS(),
		WhatId = whatId,
		WhoId = contactId,
		Type = tipoActividad,
		CC_validacion_tarea_manual__c = true,
		RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId()
			);
		if (tipoCierre != null) {
			actividad.CC_Fecha_Fin__c = CBK_UtilsDate.nowSYS();
			actividad.CC_Tipo_Cierre__c = obtenerTipoCierre(tipoCierre);
			actividad.Status = 'Completed';
		}
		return actividad;
	}
	
	private static Id crearActividadEmpleados(Id llamadaId, Id casoId, String tipoActividad, String asunto, String tipoCierre, String grupo, String contactId) {
		Task actividad = new Task(
			Subject = tipoActividad + (asunto != null ? ' (' + asunto + ')' : ''),
		CC_Llamada_Id__c = llamadaId,
		ActivityDate = CBK_UtilsDate.todaySYS(),
		CC_Fecha_Inicio__c = CBK_UtilsDate.nowSYS(),
		WhatId = casoId,
		Type = tipoActividad,
		CC_validacion_tarea_manual__c = true,
		RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId()
			);
		if (tipoCierre != null) {
			actividad.CC_Fecha_Fin__c = CBK_UtilsDate.nowSYS();
			actividad.CC_Tipo_Cierre__c = obtenerTipoCierre(tipoCierre);
			actividad.Status = 'Completed';
		}
		if (String.isNotBlank(grupo)) {
			actividad.CC_Grupo_Colaborador_Id__c = grupo;
		}
		if (String.isNotBlank(contactId)) {
			actividad.WhoId = contactId;
		}
		
		insert actividad;
		return actividad.Id;
	}
	
	private static Id crearActividad(Id llamadaId, Id casoId, String tipoActividad, String asunto, String tipoCierre) {
		Id contactId = [SELECT Id, contactId FROM Case WHERE Id =: casoId].contactId;
		Task actividad = crearObjetoActividad(llamadaId, casoId, tipoActividad, asunto, tipoCierre, contactId);
		insert actividad;
		return actividad.Id;
	}
	
	private static Id crearActividad(Id llamadaId, Id casoId, String tipoActividad, String asunto) {
		return crearActividad(llamadaId, casoId, tipoActividad, asunto, null);
	}
	
	private static void crearActividadCasosNoFuture(Id llamadaId, String tipoActividad, String detalle, String tipoCierre) {
		List<Task> actividades = new List<Task>();
		List<Id> lstCaseId = new List<Id>();
		List<AggregateResult> casoIds = [SELECT WhatId FROM Task WHERE CC_Llamada_Id__c = :llamadaId GROUP BY WhatId];
		for(AggregateResult resultado : casoIds){
			Id casoId = String.valueOf(resultado.get('WhatId'));
			lstCaseId.add(casoId);
		}
		
		Map<String,String> mpIdCasosAccount = new Map<String,String>();
		for(Case caso : [SELECT Id, contactId FROM Case WHERE Id IN :lstCaseId]){
			mpIdCasosAccount.put(caso.Id, caso.contactId);
		}
		for (AggregateResult resultado : [SELECT WhatId FROM Task WHERE CC_Llamada_Id__c = :llamadaId GROUP BY WhatId]) {
			Id casoId = String.valueOf(resultado.get('WhatId'));
			actividades.add(crearObjetoActividad(llamadaId, String.valueOf(resultado.get('WhatId')), tipoActividad, detalle, tipoCierre, mpIdCasosAccount.containsKey(casoId) ? mpIdCasosAccount.get(casoId) : null));
		}
		insert actividades;
	}
	
	private static Id crearActividadEmpleado(Id llamadaId, Id casoId, String empleadoId, String empleadoTelefono, String tipoCierre, String tipoActividad) {
		Task actividad = new Task(
			ActivityDate = CBK_UtilsDate.todaySYS(),
		CC_Fecha_Inicio__c = CBK_UtilsDate.nowSYS(),
		CC_Llamada_Id__c = llamadaId,
		Type = tipoActividad,
		CC_validacion_tarea_manual__c = true,
		RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task')
			);
		
		List<Case> caso = [SELECT Id FROM Case WHERE Id = :casoId];
		if (caso.size() == 1) {
			actividad.WhatId = casoId;
		}
		
		Contact empleado = null;
		if (String.isNotBlank(empleadoId)) {
			empleado = [SELECT Name FROM Contact WHERE Id = :empleadoId];
		} else { // Si no tenemos el ID, el widget nos proporciona empleadoTelefono
			List<CC_Canal_Com__c> listaCanales = [SELECT CC_ContactoId__r.Id, CC_ContactoId__r.Name FROM CC_Canal_Com__c WHERE CC_Telefono__c = :empleadoTelefono];
			if (listaCanales.size() == 1) {
				empleado = listaCanales[0].CC_ContactoId__r;
			}
		}
		
		if (empleado != null) {
			actividad.Subject = tipoActividad + ' (' + empleado.Name + ')';
			actividad.CC_Empleado_Gestor__c = empleado.Id;
		} else {
			actividad.Subject = tipoActividad + ' (' + empleadoTelefono + ')';
		}
		
		if (tipoCierre != null) {
			actividad.CC_Fecha_Fin__c = CBK_UtilsDate.nowSYS();
			actividad.CC_Tipo_Cierre__c = obtenerTipoCierre(tipoCierre);
			actividad.Status = 'Completed';
		}
		insert actividad;
		return actividad.Id;
	}
	
	@TestVisible
	private static String codigoIdioma(String idioma) {
		return 'Inglés'.equals(idioma) ? 'en' :
			'Catalán'.equals(idioma) ? 'ca' :
			'Valenciano'.equals(idioma) ? 'va' :
			'Euskera'.equals(idioma) ? 'eu' :
			'Gallego'.equals(idioma) ? 'ga' : 'es';
		
	}
	
	private static Case actualizarCaso(Id casoId, Id propietarioId) {
		Case caso = new Case(Id = casoId);
		caso.OwnerId = propietarioId;
		update caso;
		return caso;
	}
	
	private static Case actualizarCaso(Id casoId, Id propietarioId, String canalResolucion) {
		Case caso = new Case(Id = casoId);
		caso.CC_Canal_Resolucion__c = canalResolucion;
		caso.OwnerId = propietarioId;
		update caso;
		return caso;
	}
	
	
	private static void traspasarTercerNivel(Id casoId, Id propietarioId, String grupo3n, Id llamadaId, String tipoCliente, String idGrupoServicioGenesys) {
		String grupoApiName = '3N de Carteras CAM'.equals(grupo3N) ? 'CC_3n_Carteras_CAM' : '3N de Valores CAM'.equals(grupo3N) ? 'CC_3n_Valores_CAM' :'3N de Fondos CAM'.equals(grupo3N) ? 'CC_3n_Fondos_CAM' : '';
		
		Case caso = new Case(Id = casoId);
		caso.Status = 'Activo';
		caso.CC_En_Tercer_Nivel__c = true;
		caso.CC_Fecha_Traslado_3N__c  = CBK_UtilsDate.nowSYS();
		caso.CC_Grupo_3N__c = grupo3n;
		caso.OwnerId = propietarioId;
		
		if(tipoCliente == 'Empleado'){
			List<Case> casoEmple = [SELECT CC_Tiempo_Nivel_1__c, CC_Fecha_Traslado_1N__c FROM Case WHERE Id = :casoId LIMIT 1];
			Id idGrupo = [SELECT Id, Name, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName = :grupoApiName LIMIT 1]?.Id;
			Datetime ahora = DateTime.now();
			caso.CC_Tiempo_Nivel_1__c = (casoEmple[0].CC_Tiempo_Nivel_1__c ?? 0) + ((ahora.getTime() - casoEmple[0].CC_Fecha_Traslado_1N__c.getTime()) / 1000);
			
			CC_Activity.createActivityTraslados(casoEmple[0].Id, null, 'Traslado a ' + grupo3n + ' de Tercer Nivel', 'Traslado Tercer Nivel', idGrupo, idGrupoServicioGenesys, llamadaId, 'Completed');
		}else{
			CC_Activity.createActivityTraslados(caso.Id, null, 'Traslado a ' + grupo3n + ' de Tercer Nivel', 'Traslado Tercer Nivel', grupo3n, null, llamadaId, 'Open');
		}
		
		update caso;
		
	}
	
	
	@TestVisible
	private static boolean hayCasosAbiertosCuenta(Id cuentaId) {
		if (cuentaId == null) {
			return false;
		} else {
			List<Case> casosCuentaActivos = [SELECT Id FROM Case WHERE AccountId = :cuentaId AND Status NOT IN ('Cerrado', 'Rechazado')];
			return !casosCuentaActivos.isEmpty();
		}
	}
	
	private static String tipoConsulta(CC_Servicio_Genesys__c servicioGenesys) {
		String tipoActividad = 'Consulta';
		if (!servicioGenesys.CC_Activo_Salesforce__c) {
			tipoActividad = 'Consulta externa';
		}
		
		if (servicioGenesys.CC_Tipo__c.equals('Tercer nivel')) {
			tipoActividad = tipoActividad + ' a tercer nivel';
		} else if (servicioGenesys.CC_Tipo__c.equals('Segundo nivel')) {
			tipoActividad = tipoActividad + ' a segundo nivel';
		} else if (servicioGenesys.CC_Tipo__c.equals('Tranferencias CCO HDT')) {
			tipoActividad = tipoActividad + ' a CCO HDT';
        }
		return tipoActividad;
	}
	
	@InvocableMethod(label='Informar llamada en tarea' description='Informar llamada en tarea')
	public static void informarLlamadaEnCurso(List<Id> idNuevasTareas) {
		List<CC_Llamada__c> llamadas = [SELECT OwnerId, CC_Contacto__c FROM CC_Llamada__c
									WHERE CC_Fecha_Fin__c = null AND Recordtype.DeveloperName in('CC_Cliente','CC_Empleado')
									AND OwnerId = :UserInfo.getUserId() AND  createddate >= last_n_days:7 ORDER BY CreatedDate DESC LIMIT 1];
		if (llamadas.size() > 0) {
			CC_Llamada__c llamada = llamadas[0];
			Id contactoLlamadaId = llamada.CC_Contacto__c;
			
			Set<Id> casoIds = new Set<Id>();
			List<Task> tareas = [SELECT WhatId FROM Task WHERE Id IN :idNuevasTareas];
			for (Task tarea : tareas) {
				casoIds.add(tarea.WhatId);
			}
			
			Map<Id, Id> casoContactoMapa = new Map<Id, Id>();
			List<Case> casos = [SELECT ContactId FROM Case WHERE Id IN :casoIds];
			for (Case caso : casos) {
				casoContactoMapa.put(caso.Id, caso.ContactId);
			}
			
			List<Task> tareasActualizadas = new List<Task>();
			for (Task tarea : tareas) {
				Id contactoTareaId = casoContactoMapa.get(tarea.WhatId);
				if (contactoTareaId != null && contactoLlamadaId != null && contactoTareaId.equals(contactoLlamadaId)) {
					tarea.CC_Llamada_Id__c = llamada.Id;
					tareasActualizadas.add(tarea);
				}
			}
			
			if (tareasActualizadas.size() > 0) {
				update tareasActualizadas;
			}
		}
	}
	
	private static String formatoIdiomaGenesys(String idioma) {
		if (idioma == 'ca') {
			return 'Catalan';
		} else if (idioma == 'en') {
			return 'Ingles';
		} else {
			return 'Castellano';
		}
	}

    // US1299643: Registrar tarea de Llamadas emitidas desde Salesforce
    public static Map<String, Object> iniciarLlamadaSalienteClickToDial(CC_Llamada_Input inputLlamada) {
		
		List<CC_Llamada__c> llamadasAnteriores = [SELECT Id FROM CC_Llamada__c WHERE OwnerId = :UserInfo.getUserId()
													AND CC_Fecha_Fin__c = null AND Id != :inputLlamada.llamadaId];
		if (!llamadasAnteriores.isEmpty()) {
			for (CC_Llamada__c llamadaAnterior : llamadasAnteriores) {
				llamadaAnterior.CC_Fecha_Fin__c = CBK_UtilsDate.nowSYS();
				llamadaAnterior.CC_Tipo_Cierre__c = 'Llamada finalizada';
			}
			update llamadasAnteriores;

			finalizarActividades(llamadasAnteriores, 'Llamada%', 'Llamada finalizada');
			finalizarActividades(llamadasAnteriores, 'Consulta%', 'Consulta cancelada');
		}

		Datetime ahora = CBK_UtilsDate.nowSYS();
		CC_Llamada__c llamada = new CC_Llamada__c(Id = inputLlamada.llamadaId);
		llamada.CC_ConnId__c = inputLlamada.connId;
		llamada.KIN_Genesys_Cloud_URL_Grabacion__c = inputLlamada.urlGrabacion;
		llamada.CC_Fecha_Inicio__c = ahora;
		llamada.CC_Tipo_Cierre__c = 'Llamada atendida';
		update llamada;
		Id idTarea = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamada.Id LIMIT 1]?.Id;
		if (idTarea != null) {
			Task tarea = new Task(Id = idTarea);
			tarea.CC_Fecha_Inicio__c = ahora;
			tarea.CC_Tipo_Cierre__c = 'Llamada atendida';
			update tarea;
		}

		Case caso = [SELECT CC_Canal_Resolucion__c, Subject, CC_Idioma__c, AccountId, ContactId, CC_No_Identificado__c, RecordType.DeveloperName
								FROM Case WHERE Id = :inputLlamada.casoId];

		return new Map<String, Object>{'className' => 'CC_Llamada_GC', 'llamada' => llamada, 'caso' => caso};
	}

    public static void finalizarActividades(List<CC_Llamada__c> llamadas, String tipoActividad, String tipoCierre) {
		Set<Id> llamadaIds = new Set<Id>();

		if (!llamadas.isEmpty()) {
			List<Task> actividades = [SELECT CC_Fecha_Inicio__c, WhatId FROM Task WHERE CC_Llamada_Id__c IN :CC_MetodosUtiles.listaCampo(llamadas, 'Id')
										AND Status = 'Open' AND Type LIKE :tipoActividad AND RecordType.DeveloperName = 'CC_Task'];
			if (!actividades.isEmpty()) {
				for (Task actividad : actividades) {
					actividad.CC_Fecha_Fin__c = CBK_UtilsDate.nowSYS();
					actividad.CC_Tipo_Cierre__c = obtenerTipoCierre(tipoCierre);
					actividad.Status = 'Completed';
				}
				update actividades;
			}
		}
	}
}