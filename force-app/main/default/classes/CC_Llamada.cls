public with sharing class CC_Llamada {
    public static CC_Llamada__c registrarLlamadaEntrante(CC_Llamada_Input inputLlamada) {

        CC_Servicio_Genesys__c servicioGenesys = [SELECT Name, CC_Canal_Procedencia__c, CC_Tipo_Cliente__c, CC_Codigo__c
                                                    FROM CC_Servicio_Genesys__c WHERE CC_Codigo__c = :inputLlamada.servicio LIMIT 1];
        Case caso = null;
        CC_Llamada__c llamada = new CC_Llamada__c(
            CC_Tipo__c = String.isBlank(inputLlamada.nombreCampana) ? 'Entrante': 'Saliente',
            CC_Agente__c = inputLlamada.usuario,
            CC_Extension__c = inputLlamada.extension,
            CC_ConnId__c = inputLlamada.connId,
            //CC_ConnId_Consulta__c = null,
            CC_ANI__c = inputLlamada.ani,
            CC_DNIS__c = inputLlamada.dnis,
            CC_Servicio_Genesys__c = servicioGenesys.Id,
            CC_Idioma__c = codigoIdioma(inputLlamada.idioma),
            //CC_Asunto__c = inputLlamada.asunto.substring(0, inputLlamada.asunto.length() > 255 ? 255 : inputLlamada.asunto.length()),
            CC_Asunto__c = inputLlamada.asunto.left(255),
            CC_Datos_Genesys__c = inputLlamada.datos,
            CC_ConnId_Cognitivo__c = inputLlamada.connIdCognitivo,
            CC_NumPerso__c = inputLlamada.numPerso,
            CC_Llamada_Padre__c = String.isEmpty(inputLlamada.salesforceParentId) ? null : inputLlamada.salesforceParentId,
            CC_No_Identificado__c = false,
            CC_Fecha_Inicio__c = System.now(),
            //CC_Cuenta__c = null,
            //CC_Contacto__c = null,
            CC_Canal_del_Empleado__c = inputLlamada.canalEmpleado,
            CC_Id_Cognitivo__c = inputLlamada.cognitivoId,
            CC_IdentCliente__c = '0',  //Sin datos ALF
            //CC_Campana_Genesys__c = (inputLlamada.nombreCampana == null ? null: inputLlamada.nombreCampana)
            CC_Campana_Genesys__c = inputLlamada.nombreCampana,
            //CC_Status_Autorizacion__c = inputLlamada.statusAuto,
            CC_Perfil__c = inputLlamada.perfil
        );

        //Validamos que el valor este dentro de la picklist CC_Status_Autorizacion__c
        List<String> valoresPermitidos = new List<String>();
        Schema.DescribeFieldResult fieldResult = CC_Llamada__c.CC_Status_Autorizacion__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry picklistEntry : picklistValues) {
            valoresPermitidos.add(picklistEntry.getValue());
        }

        if (valoresPermitidos.contains(inputLlamada.statusAuto)) {
            llamada.CC_Status_Autorizacion__c = inputLlamada.statusAuto;
        } else {
            llamada.CC_Status_Autorizacion__c = 'SIN ESTADO';
        }

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
            CC_Llamada.identificarPorTelefono(llamada, inputLlamada.ani);
            if (String.isEmpty(inputLlamada.casoId) && !String.isEmpty(llamada.CC_Id_Cognitivo__c)) {
                //Buscamos el caso correspondiente al Id de cognitivo. Si no lo encuentra, lo crea con la información de la llamada y el chat obtenido de cognitivo
                caso = CC_WS_Recupera_LogConversacion.CC_WS_Recupera_Conversacion(llamada);
            }
        } else {
            llamada.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', 'CC_Cliente');
            CC_Llamada.identificarPorNumPerso(llamada, inputLlamada.numPerso);
        }

        finalizarLlamadasActividadesAbiertas(UserInfo.getUserId());
        insert llamada;

        if (String.isEmpty(inputLlamada.casoId)) {
            if (caso != null) {
                actualizarCaso(caso.Id, UserInfo.getUserId());
                vincularCaso(caso, llamada, servicioGenesys);
            }

            //if (llamada.CC_Cuenta__c != null && hayCasosAbiertosCuenta(llamada.CC_Cuenta__c) != true) {
            /*if (llamada.CC_Cuenta__c != null
            && (servicioGenesys.CC_Tipo_Cliente__c == 'Cliente' || !hayCasosAbiertosCuenta(llamada.CC_Cuenta__c))) {*/
             if (servicioGenesys.CC_Codigo__c != 'MAC_NOWINSALES'){    
                crearVincularCaso(llamada);
             }
            /*}*/
        } else {
            //Cuando se pasa el caso, es que se ha hecho una transferencia ciega y entra como llamada
            crearActividad(llamada.Id, inputLlamada.casoId, 'Llamada transferida', servicioGenesys.Name);
            actualizarCaso(inputLlamada.casoId, UserInfo.getUserId(), servicioGenesys.CC_Canal_Procedencia__c);
        }
        return llamada;
    }

    public static CC_Llamada__c registrarLlamadaSaliente(CC_Llamada_Input inputLlamada) {

        finalizarLlamadasActividadesAbiertas(UserInfo.getUserId());
        CC_Llamada__c llamada;

        if (String.isBlank(inputLlamada.nombreCampana)){
            Case caso = [SELECT CC_Canal_Resolucion__c, Subject, CC_Idioma__c, AccountId, ContactId, CC_No_Identificado__c, RecordType.DeveloperName
                            FROM Case WHERE Id = :inputLlamada.casoId];

            llamada = new CC_Llamada__c(
                CC_Tipo__c = 'Saliente',
                CC_Agente__c = inputLlamada.usuario,
                CC_Extension__c = inputLlamada.extension,
                CC_ConnId__c = inputLlamada.connId,
                //CC_ConnId_Consulta__c = null,
                CC_DNIS__c = inputLlamada.dnis,
                CC_Idioma__c = caso.CC_Idioma__c,
                CC_Asunto__c = caso.Subject,
                CC_Cuenta__c = caso.AccountId,
                CC_Contacto__c = caso.ContactId,
                CC_No_Identificado__c = caso.CC_No_Identificado__c,
                CC_Fecha_Inicio__c = System.now(),
                CC_Servicio_Llamada_Saliente__c  = caso.CC_Canal_Resolucion__c,
                CC_IdentCliente__c = '0', // Sin datos ALF);
                CC_Campana_Genesys__c =  inputLlamada.nombreCampana
            );

            if (caso.RecordType.DeveloperName == 'CC_Empleado' || caso.RecordType.DeveloperName == 'CC_CSI_Bankia') {
                llamada.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', 'CC_Empleado');
            } else {
                llamada.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', 'CC_Cliente');
            }
            insert llamada;
            crearActividad(llamada.Id, inputLlamada.casoId, 'Llamada saliente', null);
        } else {
            llamada = registrarLlamadaEntrante(inputLlamada);
        }
        return llamada;
    }

    public static CC_Llamada__c registrarConsulta(CC_Llamada_Input inputConsulta) {
        finalizarLlamadasActividadesAbiertas(UserInfo.getUserId());
        CC_Servicio_Genesys__c servicioGenesys = [SELECT Name, CC_Activo_Salesforce__c, CC_Tipo__c, CC_Tipo_Cliente__c FROM CC_Servicio_Genesys__c WHERE CC_Codigo__c = :inputConsulta.servicio LIMIT 1];
        CC_Llamada__c llamada = [SELECT CC_Idioma__c, CC_Contacto__c, CC_Cuenta__c, CC_Cuenta__r.AV_OficinaPrincipal__c,CC_Cuenta__r.CC_OficinaGestoraId__c, CC_No_Identificado__c, OwnerId, CC_IdentCliente__c, RecordTypeId FROM CC_Llamada__c WHERE Id = :inputConsulta.salesforceParentId];
        Case caso = [SELECT Subject, CC_Idioma__c, AccountId, ContactId FROM Case WHERE Id = :inputConsulta.casoId];

        CC_Llamada__c consulta = new CC_Llamada__c(
            CC_Tipo__c = 'Entrante',
            CC_Agente__c = inputConsulta.usuario,
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
            CC_Fecha_Inicio__c = System.now(),
            CC_IdentCliente__c = llamada.CC_IdentCliente__c
        );
        consulta.recordTypeId = llamada.RecordTypeId;
        insert consulta;

        String tipoActividad = tipoConsulta(servicioGenesys);
        crearActividad(consulta.Id, caso.Id, tipoActividad, servicioGenesys.Name);
        return consulta;
    }

    public static CC_Llamada__c registrarConsultaExterna(CC_Llamada_Input inputConsulta) {
        finalizarLlamadasActividadesAbiertas(UserInfo.getUserId());
        CC_Servicio_Genesys__c servicioGenesys = [SELECT Name, CC_Activo_Salesforce__c, CC_Tipo__c, CC_Tipo_Cliente__c
                                                    FROM CC_Servicio_Genesys__c WHERE CC_Codigo__c = :inputConsulta.servicio LIMIT 1];
        CC_Llamada__c consulta = new CC_Llamada__c(
            CC_Tipo__c = 'Entrante',
            CC_Agente__c = inputConsulta.usuario,
            CC_Extension__c = inputConsulta.extension,
            CC_ConnId__c = null,
            CC_ConnId_Consulta__c = inputConsulta.connId,
            CC_ANI__c = inputConsulta.ani,
            CC_DNIS__c = inputConsulta.dnis,
            CC_Servicio_Genesys__c = servicioGenesys.Id,
            CC_Idioma__c = codigoIdioma(inputConsulta.idioma),
            CC_Fecha_Inicio__c = System.now(),
            CC_IdentCliente__c = '0' // Sin datos ALF
        );

        if (servicioGenesys.CC_Tipo_Cliente__c == 'Empleado' || servicioGenesys.CC_Tipo_Cliente__c == 'CSI Bankia') {
            consulta.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', 'CC_Empleado');
        } else {
            consulta.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', 'CC_Cliente');
        }
        insert consulta;
        return consulta;
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

    public static void registrarEncuesta(CC_Llamada_Input inputLlamada) {

        String llamadaId = CC_Llamada.buscarLlamada(inputLlamada);
        if (!String.isBlank(llamadaId)) {
            CC_Llamada__c llamada = [SELECT CC_Servicio_Genesys__r.CC_Encuesta__r.Name, CC_Tipo__c FROM CC_Llamada__c WHERE Id = :llamadaId];
            llamada.CC_Encuesta__c = llamada.CC_Servicio_Genesys__r.CC_Encuesta__c;

            //Recuperamos el nombre de la encuesta para la tarea
            String nombreEncuesta = llamada.CC_Servicio_Genesys__r.CC_Encuesta__r.Name;

            if (llamada.CC_Encuesta__c == null && llamada.CC_Tipo__c == 'Saliente') {
                List<AggregateResult> casoIds = [SELECT WhatId FROM Task WHERE CC_Llamada_Id__c = :llamadaId GROUP BY WhatId];

                if (!casoIds.isEmpty())
                {
                    Id casoId = String.valueOf(casoIds[0].get('WhatId'));
                    if (casoId != null) {
                        CC_Servicio_Genesys__c servicioGen = CC_Servicio_Genesys.obtenerServicioEncuestaDesdeCaso(casoId);
                        if (servicioGen != null)
                        {
                            //Relacionamos la llamada con la encuesta
                            llamada.CC_Encuesta__c = servicioGen.CC_Encuesta__c;
                            //Recuperamos el nombre de la encuesta para la tarea
                            nombreEncuesta = servicioGen.CC_Encuesta__r.Name;
                        }
                    }
                }
            }
            update llamada;

            crearActividadCasos(llamadaId, 'Encuesta', nombreEncuesta, 'Encuesta enviada');
        }
    }

    /** Cuando no nos llega el Id de llamada, lo buscamos por connId, usuario y extensión */
    private static String buscarLlamada(CC_Llamada_Input jsonLlamada) {
        String resultado = jsonLlamada.llamadaId;
        if (String.isEmpty(resultado)) {
            List<CC_Llamada__c> llamadas = [SELECT Id FROM CC_Llamada__c WHERE RecordTypeId IN :recordTypesLlamadasCC()
                                            AND CC_ConnId__c = :jsonLlamada.connId AND CC_Agente__c = :jsonLlamada.usuario
                                            AND CC_Extension__c = :jsonLlamada.extension AND CC_Fecha_Fin__c = null];
            if (llamadas.size() == 1) {
                resultado = llamadas[0].Id;
            }
        }
        return resultado;
    }

    /** Cuando no nos llega el Id de consulta, lo buscamos por connId, usuario y extensión */
    private static String buscarConsulta(CC_Llamada_Input jsonConsulta) {
        String resultado = jsonConsulta.llamadaId;
        if (String.isEmpty(resultado)) {
            List<CC_Llamada__c> consultas = [SELECT Id FROM CC_Llamada__c WHERE RecordTypeId IN :recordTypesLlamadasCC()
                                                AND CC_ConnId_Consulta__c = :jsonConsulta.connId
                                                AND CC_Agente__c = :jsonConsulta.usuario
                                                AND CC_Extension__c = :jsonConsulta.extension AND CC_Fecha_Fin__c = null];
            if (consultas.size() == 1) {
                resultado = consultas[0].Id;
            }
        }
        return resultado;
    }

    public static void finalizarLlamada(CC_Llamada_Input inputLlamada, String tipoCierre) {
        String llamadaId = CC_Llamada.buscarLlamada(inputLlamada);
        if(String.isNotBlank(llamadaId)){
          finalizarLlamadaActividades(new CC_Llamada__c(Id = llamadaId), 'Llamada%', tipoCierre != '' ? tipoCierre : 'Llamada finalizada');
        }
    }

    public static void finalizarConsulta(CC_Llamada_Input inputConsulta, String tipoCierre) {
        String consultaId = CC_Llamada.buscarConsulta(inputConsulta);
        if(String.isNotBlank(consultaId)){
          finalizarLlamadaActividades(new CC_Llamada__c(Id = consultaId), 'Consulta%', tipoCierre);
        }
    }

    public static void finalizarConsultaExterna(CC_Llamada_Input inputConsulta, String tipoCierre) {
        if (String.isNotBlank(inputConsulta.servicio)) {
            CC_Servicio_Genesys__c servicioGenesys = [SELECT CC_Tipo__c, CC_Activo_Salesforce__c FROM CC_Servicio_Genesys__c WHERE CC_Codigo__c = :inputConsulta.servicio LIMIT 1];
            if (!servicioGenesys.CC_Activo_Salesforce__c) {
                crearActividad(inputConsulta.salesforceParentId, inputConsulta.casoId, servicioGenesys.CC_Tipo__c.equals('Empleado') ? 'Consulta externa a empleado' : 'Consulta externa', inputConsulta.servicio, tipoCierre);
            }
        } else if (String.isNotBlank(inputConsulta.empleadoTelefono)) {
            crearActividadEmpleado(inputConsulta.salesforceParentId, inputConsulta.casoId, inputConsulta.empleadoId, inputConsulta.empleadoTelefono, tipoCierre, 'Consulta externa a empleado');
        } else {
            IllegalArgumentException excepcion = new IllegalArgumentException();
            excepcion.setMessage('No se puede finalizar una consulta externa sin servicio/empleado.');
            throw excepcion;
        }
    }

    public static void cancelarConsulta(CC_Llamada_Input inputConsulta) {
        String consultaId = CC_Llamada.buscarConsulta(inputConsulta);
        finalizarLlamadaActividades(new CC_Llamada__c(Id = consultaId), 'Consulta%', 'Consulta cancelada');
    }

    public static void completarConsulta(CC_Llamada_Input inputConsulta) {
        String consultaId = CC_Llamada.buscarConsulta(inputConsulta);
        if(String.isNotBlank(consultaId)){
            CC_Llamada__c consulta = [SELECT CC_Llamada_Padre__c, CC_Case_Consulta__c, OwnerId, CC_Servicio_Genesys__r.Name, CC_Servicio_Genesys__r.CC_Tipo__c, CC_Servicio_Genesys__r.CC_Activo_Salesforce__c, CC_Servicio_Genesys__r.CC_Canal_Procedencia__c FROM CC_Llamada__c WHERE Id = :consultaId];

            if(consulta != null){
                CC_Llamada__c llamada = null;
                List<CC_Llamada__c> llamadas = [SELECT CC_ANI__c, CC_Servicio_Genesys__r.Name FROM CC_Llamada__c WHERE Id = :consulta.CC_Llamada_Padre__c];
                if (!llamadas.isEmpty()) {
                    llamada = llamadas[0];
                }

                consulta.CC_ConnId__c = inputConsulta.transferConnId;
                update consulta;

                finalizarActividades(consulta, 'Consulta%', 'Consulta completada');
                crearActividad(consulta.Id, consulta.CC_Case_Consulta__c, 'Llamada transferida', llamada != null ? llamada.CC_Servicio_Genesys__r.Name : 'externo');

                if (consulta.CC_Servicio_Genesys__r.CC_Tipo__c.equals('Tercer nivel')) {
                    traspasarTercerNivel(consulta.CC_Case_Consulta__c, consulta.OwnerId, consulta.CC_Servicio_Genesys__r.Name, consulta.Id);
                } else if (consulta.CC_Case_Consulta__c != null) {
                    if (consulta.CC_Servicio_Genesys__r.CC_Tipo__c.equals('Servicio')) {
                        //El canal de resolución sólo se actualiza para transferencias entre servicios normales
                        actualizarCaso(consulta.CC_Case_Consulta__c, consulta.OwnerId, consulta.CC_Servicio_Genesys__r.CC_Canal_Procedencia__c);
                    } else {
                        actualizarCaso(consulta.CC_Case_Consulta__c, consulta.OwnerId);
                    }
                }
            }
        }
    }

    public static Contact getEmpleadoGestor(Id llamadaId) {
        List<CC_Llamada__c> llamadas = [SELECT CC_Cuenta__r.AV_EAPGestor__c FROM CC_Llamada__c WHERE Id = :llamadaId];
        if (!llamadas.isEmpty() && llamadas[0].CC_Cuenta__c != null && llamadas[0].CC_Cuenta__r.AV_EAPGestor__c != null) {
            List<Contact> contactos = [SELECT Name, (SELECT CC_Telefono__c FROM Canales_Comunicacion__r WHERE RecordType.DeveloperName = 'CC_Telefono' ORDER BY CC_Clase_Com__c DESC)
                                        FROM Contact WHERE Id = :llamadas[0].CC_Cuenta__r.AV_EAPGestor__c];
            if (!contactos.isEmpty()) {
                return contactos[0];
            }
        }
        return null;
    }

    public static Case crearVincularCaso(CC_Llamada__c llamada) {
        CC_Servicio_Genesys__c servicioGenesys = [SELECT Name,CC_Codigo__c, CC_Canal_Procedencia__c, CC_Canal_de_Entrada__c,CC_Activo_Salesforce__c, CC_Tipo__c, CC_Tipo_Cliente__c
                                                    FROM CC_Servicio_Genesys__c WHERE Id = :llamada.CC_Servicio_Genesys__c];
        Case caso = crearCaso(llamada, servicioGenesys);
        vincularCaso(caso,llamada,servicioGenesys);
        return [SELECT CaseNumber, Status, Owner.Name, CreatedDate, Subject FROM Case WHERE Id = :caso.Id];
    }

    public static Case crearCaso(CC_Llamada__c llamada, CC_Servicio_Genesys__c servicioGenesys) {
        Case caso = new Case(
            Subject = llamada.CC_Asunto__c,
            Origin = servicioGenesys.CC_Canal_de_Entrada__c == 'Telefono' ? 'Phone' : String.isBlank(servicioGenesys.CC_Canal_de_Entrada__c) ? 'Phone' : servicioGenesys.CC_Canal_de_Entrada__c,
            CC_Canal_Respuesta__c = 'Phone',
            CC_Telefono_Contacto__c = llamada.CC_ANI__c,
            CC_No_Identificado__c = llamada.CC_No_Identificado__c,
            CC_Canal_Procedencia__c = servicioGenesys.CC_Canal_Procedencia__c,
            CC_Idioma__c = llamada.CC_Idioma__c,
            AccountId = llamada.CC_Cuenta__c,
            ContactId = llamada.CC_Contacto__c,
            CC_IdentCliente__c = llamada.CC_IdentCliente__c,
            Canal_del_Empleado__c = llamada.CC_Canal_del_Empleado__c,
            CC_Id_Cognitivo__c = llamada.CC_Id_Cognitivo__c,
            CC_Status_Autorizacion__c = llamada.CC_Status_Autorizacion__c
        );

        if (servicioGenesys.CC_Codigo__c == 'MAC_NOWINSALES'){
            caso.CC_En_Tercer_Nivel__c = true;
            caso.CC_Grupo_3N__c = '3N de CSBD';
            caso.CC_Detalles_Consulta__c = 'Creado en 3N';            
            // try {
            //     Group cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName='Cola_3N_CSBD' LIMIT 1];
            //     caso.OwnerId=cola.Id;
            // } catch (QueryException e) {
            //     System.debug('Falta Cola: ' + e);
            // }
        }
        if (servicioGenesys.CC_Tipo_Cliente__c == 'Cliente') {
            caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
            caso.CC_Tipo_Cliente__c = 'Cliente';
            if (llamada.CC_Cuenta__c != null) {
                /**List<CC_Llamada__c> recuperarLlamada = [SELECT Id, CC_Cuenta__c, CC_Cuenta__r.CC_OficinaGestoraId__c FROM CC_Llamada__c WHERE Id = :llamada.Id LIMIT 1];
                if (!recuperarLlamada.isEmpty()) {
                  caso.CC_Oficina_Afectada_Lookup__c = recuperarLlamada.get(0).CC_Cuenta__r.CC_OficinaGestoraId__c;
                }   **/
				caso.CC_Oficina_Afectada_Lookup__c = llamada.CC_Cuenta__r.AV_OficinaPrincipal__c;
            }
        } else if (servicioGenesys.CC_Tipo_Cliente__c == 'Empleado') {
            caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
            caso.CC_Tipo_Cliente__c = 'Empleado';
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

    public static void vincularCaso(Case caso, CC_Llamada__c llamada, CC_Servicio_Genesys__c servicioGenesys) {
        String tipoActividad;
        if (llamada.CC_ConnId__c == null) { //Si es una consulta
            tipoActividad = tipoConsulta(servicioGenesys);
        } else {
            tipoActividad = llamada.CC_Tipo__c.equals('Saliente') ? 'Llamada saliente' : 'Llamada entrante';
        }
        crearActividadFuture(llamada.Id, caso.Id, tipoActividad, servicioGenesys.Name);
    }

    private static void identificarPorNumPerso(CC_Llamada__c llamada, String numPerso) {
        //Realizamos una búsqueda para informar el contacto y la cuenta
        
        if(llamada != null){
            if(!String.isEmpty(llamada.CC_DNIS__c)){
            	 List<Account> cuentas = [SELECT Id, name, CC_Inactivo__c, CC_Centro_Integrador__c, CC_Tipo_Centro__c FROM Account 
                                          WHERE Phone =: llamada.CC_DNIS__c AND recordType.Developername='CC_CentroCaixaBank' 
                                          AND CC_Tipo_Centro__c ='OF' AND CC_Inactivo__c = false AND (CC_Centro_Integrador__c = null OR CC_Centro_Integrador__c = '')
                                         LIMIT 1];
                if(!cuentas.isEmpty()){
                	llamada.CC_Oficina_Contactada__c = cuentas[0].Id;
                }
            }  
        }
        
        
        if (!String.isEmpty(numPerso)) {
            List<Contact> contactos = new List<Contact>();
            Map<String, Object> mapaCuentasContactos = CC_IdentCliente_Future.getIdentificacionALF('NP', numPerso);
            List<Account> cuentas = (List<Account>)mapaCuentasContactos.get('CUENTAS');
            List<Account> cuentasAct = new List<Account>();

            system.debug('DPK cuentas --->' + cuentas.size());
            system.debug('DPK cuentas --->' + cuentas);

            if (cuentas.size() == 1) {
               if (llamada.CC_Perfil__c == 'EMPLEADOSEAP'){
					cuentas[0].CC_Empleados_Familiares__c = true;
                    cuentas[0].CC_Perfil__c = llamada.CC_Perfil__c;
                    Account cuentaSinNombre = new Account(Id=cuentas[0].Id, CC_Empleados_Familiares__c=cuentas[0].CC_Empleados_Familiares__c,  CC_Perfil__c=cuentas[0].CC_Perfil__c);
                    cuentasAct.add(cuentaSinNombre);
                    }
                else if(llamada.CC_Perfil__c != '' && llamada.CC_Perfil__c != null){
                    cuentas[0].CC_Perfil__c = llamada.CC_Perfil__c;
                    Account cuentaSinNombre = new Account(Id=cuentas[0].Id, CC_Perfil__c=cuentas[0].CC_Perfil__c);
                    cuentasAct.add(cuentaSinNombre);
                 }
                 system.debug('DPK cuentasAct --->' + cuentasAct.size());
                 system.debug('DPK cuentasAct --->' + cuentasAct);
     

                // Cambio para añadir representantes.
                if (mapaCuentasContactos.containsKey('REPRESENTANTES')) {
                    contactos = (List<Contact>)mapaCuentasContactos.get('REPRESENTANTES');
                    if (contactos.size() == 1) {
                        llamada.CC_Cuenta__c = cuentas[0].Id;
                        llamada.CC_Contacto__c = contactos[0].Id;
                        llamada.CC_IdentCliente__c = '1'; // Alfabético automático
                    }
                } else if (mapaCuentasContactos.containsKey('CONTACTOS')) {
                    contactos = (List<Contact>)mapaCuentasContactos.get('CONTACTOS');
                    if (contactos.size() == 1) {
                        llamada.CC_Cuenta__c = cuentas[0].Id;
                        llamada.CC_Contacto__c = contactos[0].Id;
                        llamada.CC_IdentCliente__c = '1'; // Alfabético automático
                    }
                }
            }
             if(cuentasAct.size() > 0){
            	Database.SaveResult[] oResCuentas = Database.update(cuentasAct, false);
            }
        }
    }

    private static CC_Canal_Com__c buscarEmpleadoPorTelefono(String telefono) {
        telefono = telefono.replace('+34', '');
        List<CC_Canal_Com__c> listCanales = [SELECT CC_ContactoId__c, CC_ContactoId__r.AccountId FROM CC_Canal_Com__c WHERE CC_Telefono__c = :telefono
                                                AND CC_ContactoId__r.RecordType.DeveloperName = 'CC_Empleado' AND RecordType.DeveloperName = 'CC_Telefono'];
        if (listCanales.size() == 1) {
            return listCanales[0];
        }
        return null;
    }

    private static void identificarPorTelefono(CC_Llamada__c llamada, String telefono) {
        if (!String.isEmpty(telefono)) {
            CC_Canal_Com__c canalComunicacion = buscarEmpleadoPorTelefono(telefono);
            if (canalComunicacion != null) {
                llamada.CC_Cuenta__c = canalComunicacion.CC_ContactoId__r.AccountId;
                llamada.CC_Contacto__c = canalComunicacion.CC_ContactoId__c;
            }
        }
    }

    private static String obtenerTipoCierre(String tipoCierre) {
        Schema.DescribeFieldResult tipoCierreLlamada = CC_Llamada__c.CC_Tipo_Cierre__c.getDescribe();
        List<Schema.PicklistEntry> tiposCierre = tipoCierreLlamada.getPicklistValues();
        for (Schema.PicklistEntry tipo : tiposCierre) {
            if (tipo.getValue().equals(tipoCierre)) {
                return tipo.getLabel();
            }
        }
        return tipoCierre;
    }

    private static void finalizarActividades(CC_Llamada__c llamada, String tipoActividad, String tipoCierre) {
        finalizarActividades(new List<CC_Llamada__c>{llamada}, tipoActividad, tipoCierre);
    }

    private static void finalizarActividades(List<CC_Llamada__c> llamadas, String tipoActividad, String tipoCierre) {
        List<Id> llamadaIds = new List<Id>();
        for (CC_Llamada__c llamada : llamadas) {
            llamadaIds.add(llamada.Id);
        }

        if (llamadaIds.size() == 0) return;

        List<Task> actividades = [SELECT Id, Type, OwnerId FROM Task WHERE CC_Llamada_Id__c IN :llamadaIds AND Status = 'Open' AND Type LIKE :tipoActividad
                                    AND RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task')];

        Id usuarioBluewolfId = [SELECT Id FROM User WHERE Name = 'Bluewolf'].Id;
        
        for (Task actividad : actividades) {
            actividad.CC_Fecha_Fin__c = System.now();
            String obtenerTipoCierre = obtenerTipoCierre(tipoCierre);
            if(obtenerTipoCierre == 'Llamada no atendida' && actividad.Type == 'Llamada entrante'){
                actividad.CC_Tipo_Cierre__c = obtenerTipoCierre;
                actividad.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_ReadOnly');
				actividad.OwnerId = usuarioBluewolfId;
            }else{
                actividad.CC_Tipo_Cierre__c = obtenerTipoCierre;
            }
            actividad.Status = 'Completed';
        }
        if (!actividades.isEmpty()) {
            update actividades;
            
        }
    }

    //Metodo nuevo para la optimización de código: Nerea Sanchez-Bermejo, Octubre 2021
    private static void finalizarActividadesNew(List<CC_Llamada__c> llamadas) {
        if (!llamadas.isEmpty()) {
            List<Task> actividadesActualizar = new List<Task>();

            List<Id> llamadaIds = new List<Id>();
            for (CC_Llamada__c llamada : llamadas) {
                llamadaIds.add(llamada.Id);
            }

            for (Task actividad : [SELECT Type FROM Task WHERE CC_Llamada_Id__c IN :llamadaIds AND Status = 'Open'
                                    AND RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task')]) {
                if (actividad.Type.startsWith('Consulta')) {
                    actividad.CC_Fecha_Fin__c = System.now();
                    actividad.CC_Tipo_Cierre__c = obtenerTipoCierre('Consulta cancelada');
                    actividad.Status = 'Completed';
                    actividadesActualizar.add(actividad);
                } else if (actividad.Type.startsWith('Llamada')) {
                    actividad.CC_Fecha_Fin__c = System.now();
                    actividad.CC_Tipo_Cierre__c = obtenerTipoCierre('Llamada finalizada');
                    actividad.Status = 'Completed';
                    actividadesActualizar.add(actividad);
                }
            }
            if (!actividadesActualizar.isEmpty()) {
                update actividadesActualizar;
            }
        }
    }

    private static void finalizarLlamadaActividades(CC_Llamada__c llamada, String tipoActividad, String tipoCierre) {
        finalizarLlamadasActividades(new List<CC_Llamada__c>{llamada}, tipoActividad, tipoCierre);
    }

    private static void finalizarLlamadas(List<CC_Llamada__c> llamadas, String tipoCierre) {
        for (CC_Llamada__c llamada : llamadas) {
            llamada.CC_Fecha_Fin__c = System.now();
            llamada.CC_Tipo_Cierre__c = tipoCierre;
        }
        if (!llamadas.isEmpty()) {
            update llamadas;
        }
    }

    private static void finalizarLlamadasActividades(List<CC_Llamada__c> llamadas, String tipoActividad, String tipoCierre) {
        if (!llamadas.isEmpty()) {
            finalizarLlamadas(llamadas, tipoCierre);
            finalizarActividades(llamadas, tipoActividad, tipoCierre);
        }
    }

    private static void finalizarLlamadasActividadesAbiertas(Id userId) {
        List<CC_Llamada__c> llamadas = [SELECT Id FROM CC_Llamada__c WHERE RecordTypeId IN :recordTypesLlamadasCC() AND CC_Fecha_Fin__c = NULL AND OwnerId = :userId];
        finalizarLlamadas(llamadas, 'Llamada finalizada');
        finalizarActividadesNew(llamadas);
    }

    private static Task crearObjetoActividad(Id llamadaId, Id casoId, String tipoActividad, String detalle, String tipoCierre) {
        Task actividad = new Task(
            Subject = tipoActividad + (detalle != null ? ' (' + detalle + ')' : ''),
            CC_Llamada_Id__c = llamadaId,
            ActivityDate = System.today(),
            CC_Fecha_Inicio__c = System.now(),
            WhatId = casoId,
            Type = tipoActividad,
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task'),
            CC_validacion_tarea_manual__c = true
        );

        if (tipoCierre != null) {
            actividad.CC_Fecha_Fin__c = System.now();
            actividad.CC_Tipo_Cierre__c = obtenerTipoCierre(tipoCierre);
            actividad.Status = 'Completed';
        }
        return actividad;
    }

    private static Id crearActividad(Id llamadaId, Id casoId, String tipoActividad, String detalle, String tipoCierre) {
        Task actividad = crearObjetoActividad(llamadaId, casoId, tipoActividad, detalle, tipoCierre);
        insert actividad;
        return actividad.Id;
    }

    private static Id crearActividad(Id llamadaId, Id casoId, String tipoActividad, String telefono) {
        return crearActividad(llamadaId, casoId, tipoActividad, telefono, null);
    }

    @future
    private static void crearActividadFuture(Id llamadaId, Id casoId, String tipoActividad, String telefono) {
        crearActividad(llamadaId, casoId, tipoActividad, telefono, null);
    }

    @future
    private static void crearActividadCasos(Id llamadaId, String tipoActividad, String detalle, String tipoCierre) {
        List<Task> actividades = new List<Task>();
        List<AggregateResult> casoIds = [SELECT WhatId FROM Task WHERE CC_Llamada_Id__c = :llamadaId GROUP BY WhatId];
        for(AggregateResult resultado : casoIds) {
            Id casoId = String.valueOf(resultado.get('WhatId'));
            Task actividad = crearObjetoActividad(llamadaId, casoId, tipoActividad, detalle, tipoCierre);
            actividades.add(actividad);
        }
        insert actividades;
    }

    private static Id crearActividadEmpleado(Id llamadaId, Id casoId, String empleadoId, String empleadoTelefono, String tipoCierre, String tipoActividad) {
        Task actividad = new Task(
            ActivityDate = System.today(),
            CC_Fecha_Inicio__c = System.now(),
            CC_Llamada_Id__c = llamadaId,
            Type = tipoActividad,
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task'),
            CC_validacion_tarea_manual__c = true
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
            actividad.CC_Fecha_Fin__c = System.now();
            actividad.CC_Tipo_Cierre__c = obtenerTipoCierre(tipoCierre);
            actividad.Status = 'Completed';
        }
        insert actividad;
        return actividad.Id;
    }

    private static String codigoIdioma(String idioma) {
        return 'Inglés'.equals(idioma) ? 'en' : ('Catalán'.equals(idioma) ? 'ca' : 'es');
    }

    private static void actualizarCaso(Id casoId, Id propietarioId) {
        Case caso = new Case(
            Id = casoId,
            OwnerId = propietarioId
        );
        update caso;
    }

    private static void actualizarCaso(Id casoId, Id propietarioId, String canalResolucion) {
        Case caso = new Case(
            Id = casoId,
            CC_Canal_Resolucion__c = canalResolucion,
            OwnerId = propietarioId
        );
        update caso;
    }

    private static void traspasarTercerNivel(Id casoId, Id propietarioId, String grupo, Id llamadaId) {
        List<Case> ccccc = [SELECT Id,OwnerId,CC_Owner_Anterior__c FROM Case WHERE Id =: casoId ];
        List<user> us = [SELECT Id,userName,Name FROM User WHERE Id =: propietarioId ];
        Case caso = new Case(
            Id = casoId,
            Status = 'Activo',
            CC_En_Tercer_Nivel__c = true,
            CC_Grupo_3N__c = grupo,
            OwnerId = propietarioId
        );
        update caso;

        String asunto = 'Traslado a ' + grupo + ' de Tercer Nivel';
        String tipo = 'Traslado Tercer Nivel';
        CC_EmailSendController.createActivityTraslados(caso.Id, null, asunto, tipo, grupo, null, llamadaId);
    }

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
        }
        return tipoActividad;
    }

    @InvocableMethod(label='Informar llamada en tarea' description='Informar llamada en tarea')
    public static void informarLlamadaEnCurso(List<Id> idNuevasTareas) {
        List<CC_Llamada__c> llamadas = [SELECT OwnerId, CC_Contacto__c FROM CC_Llamada__c
                                        WHERE CC_Fecha_Fin__c = null AND Recordtype.DeveloperName != 'OB_Cliente'
                                        AND OwnerId = :UserInfo.getUserId() ORDER BY CreatedDate DESC LIMIT 1];
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

    @AuraEnabled
    public static String obtenerGrabacion(String fechaNice, String connId, String extension) {
        String nombreFichero = fechaNice + '_' + connId + '_' + extension + '.mp3';
        String ficheroBase64 = null;
        try {
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setEndpoint('https://PASOfile-examples.com/wp-content/uploads/2017/11/file_example_MP3_700KB.mp3');
            req.setHeader('Connection','keep-alive');
            //req.setHeader('Cookie','hcp-ns-auth=YzNjY3M4X2Z1bGw=:859303cc43b37af8da2a0b0f8eaddc3a'); //PRE
            req.setHeader('content-type', 'audio/mpeg');
            Http http = new Http();
            HttpResponse res = http.send(req);
            Blob ficheroBlob = res.getBodyAsBlob();
            if (res.getStatusCode() == 200) {
                ficheroBase64 = EncodingUtil.base64Encode(ficheroBlob);
            }
        } catch(Exception e) {
            CBK_Log.error(e);
        }
        return ficheroBase64;
    }

    @AuraEnabled
    public static String obtenerUrl(String fechaNice, String connId, String extension){
        connId = connId.toUppercase();
        String datosGrabacion = fechaNice + '_' + connId + '_' + extension + '.mp3';
        String url = null;
        List<CC_InterfaceSettings__mdt> listUrl = [SELECT CC_EndPoint__c FROM CC_InterfaceSettings__mdt WHERE label = 'CC_Int_HCP' LIMIT 1];
        if (!listUrl.isEmpty()) {
            url = listUrl[0].CC_EndPoint__c + datosGrabacion;
        }
        return url;
    }


    /**
     * @description devuelve la URL de la grabación
     * @param nombreFicheroGrabacion
     * @return obtenerUrlCOPS
     */
    @AuraEnabled
    public static String obtenerUrlCOPS(String nombreFicheroGrabacion) {
        String url = null;
        List<CC_InterfaceSettings__mdt> listUrl = [SELECT CC_EndPoint__c FROM CC_InterfaceSettings__mdt WHERE label = 'OS_Int_HCP' LIMIT 1];
        if (!listUrl.isEmpty()) {
            url = listUrl[0].CC_EndPoint__c + nombreFicheroGrabacion;
        }
        return url;
    }


    private static List<Id> recordTypesLlamadasCC() {
        return new List<Id>{
            CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', 'CC_Cliente'),
            CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', 'CC_Empleado')
        };
    }

    @AuraEnabled(cacheable=true)
    public static Boolean grabacionEnOcp(Datetime fechaLlamada) {
        Boolean grabacionEnOcp = false;
        if (fechaLlamada != null) {
            List<CC_Parametros__mdt> paramFechaInicioOcp = [SELECT Valor_Texto__c FROM CC_Parametros__mdt WHERE DeveloperName = 'CC_Fecha_Inicio_Ocp'];
            if (!paramFechaInicioOcp.isEmpty()) {
                Datetime fechaInicioOcp = Date.valueOf(paramFechaInicioOcp[0].Valor_Texto__c);
                grabacionEnOcp = fechaInicioOcp <= fechaLlamada;
            }
        }
        return grabacionEnOcp;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, String> datosUrlGrabacion(Id idLlamada) {

        String ticketOcp = [SELECT CBK_Ticket_OCP__c FROM CC_Llamada__c WHERE Id = :idLlamada].CBK_Ticket_OCP__c;

        CC_InterfaceSettings__mdt cfg = [SELECT CC_EndPoint__c, CC_OCP_Aplicacion__c, CC_OCP_Usuario__c, CC_OCP_Canal__c, CC_Body__c
                                            FROM CC_InterfaceSettings__mdt WHERE DeveloperName = 'CC_Int_OCP' AND CC_Activa__c = TRUE];

        Map<String, String> datosMap = new Map<String, String>();
        datosMap.put('tiquet', ticketOcp);
        datosMap.put('appid', cfg.CC_OCP_Aplicacion__c);
        datosMap.put('username', cfg.CC_OCP_Usuario__c);
        datosMap.put('canal', cfg.CC_OCP_Canal__c);
        datosMap.put('publicKey', cfg.CC_Body__c);
        datosMap.put('baseUrl', cfg.CC_EndPoint__c + ticketOcp);
        datosMap.put('timestamp', System.now().format('yyyyMMddHHmmss'));
        return datosMap;
    }
}