public with sharing class HDT_EmailMessage_AI_TRHan extends CC_TriggerHandlerBase {
	private static String handlerClass = 'HDT_EmailMessage_AI_TRHan';
	private static String vEventType = 'afterInsert';

	public override void mainEntry(CC_TriggerParameters tp) {
		List<SObject> lstSO = CBK_EmailMessageTriggerHelper.filterEmailsHandlers(tp,handlerClass, vEventType);
		tp.newList = lstSO.size() > 0 ? lstSO : tp.newList;
		process((List<EmailMessage>)tp.newList, (Map<Id, EmailMessage>)tp.newMap);
    }

    private static List<EmailMessage> filtrarCorreosNoCc(List<EmailMessage> correos) {
        List<EmailMessage> correosCc = new List<EmailMessage>();
        Set<Id> idsPadre = new Set<Id>();
        for (EmailMessage correo : correos) {
            if (String.isNotBlank(correo.ParentId)) {
                idsPadre.add(correo.ParentId);
            } else if (String.isNotBlank(correo.RelatedToId)) {
                idsPadre.add(correo.RelatedToId);
            }
        }

        if (!idsPadre.isEmpty()) {
            Id idRecordTypeHdt = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            Map<Id, EmailMessage> mapaCorreos = new Map<Id, EmailMessage>();
            for (EmailMessage correo : correos) {
                mapaCorreos.put(correo.Id, correo);
            }

            Set<Id> idCasosCc = new Set<Id>();
            for (Case casoCc : [SELECT Id FROM Case WHERE Id IN :idsPadre AND RecordTypeId = :idRecordTypeHdt]) {
                idCasosCc.add(casoCc.Id);
            }

            for (EmailMessage correo : correos) {
                if (idCasosCc.contains(correo.ParentId) || idCasosCc.contains(correo.RelatedToId)) {
                    correosCc.add(mapaCorreos.get(correo.Id));
                }
            }
        }
        return correosCc;
    }

    private static void process(List<EmailMessage> correos, Map<Id, EmailMessage> mapaCorreos) {
        List<EmailMessage> correosCc = filtrarCorreosNoCc(correos);
        validarBuzonSalida(correosCc);
        //Se comprueba si el correo contiene algún fichero adjunto con un formato no permitido y, en tal caso, se impide su envío.
        comprobarAnexosPermitidos(correosCc, mapaCorreos);
        //Se acumulan las inserciones/actualizaciones en las siguientes listas para ejecutarlas al final
        List<Case> casos = new List<Case>();
        List<Task> actividadesTraslado = new List<Task>();
        //Hasta que se inserten las actividades de traslado no se pueden informar los Ids en las de
        //correo, así que se guardan las relaciones en este mapa y se informan los Ids al final
        Map<Id, Integer> relacionActividades = new Map<Id, Integer>();
        Set<Id> idsCasos = new Set<Id>();
        List<String> referencias = new List<String>();
        Map<Id, String> mapaTipoTareaDelCorreo = new Map<Id, String>();
        //En función de la operativa y de si el correo es saliente o entrante, se ejecutan acciones diferentes
        for (EmailMessage correo : correosCc) {
            idsCasos.add(correo.ParentId);
            if(correo.Status != '5' && correo.Incoming){
                String referencia = CC_EmailMessage.referenciaCorreo(correo);
                referencias.add(referencia);
            }
        }

        Map<Id, Case> mapIdCaso = new Map<Id, Case>();
        for (Case caso : [SELECT Status, OwnerId FROM Case WHERE Id IN :idsCasos]) {
            mapIdCaso.put(caso.Id, caso);
        }

        if (!referencias.isEmpty()){
            List<Task> tareasOrigen = [SELECT Type, WhatId FROM Task WHERE WhatId IN :idsCasos AND CC_Referencia_Correo_Saliente__c IN :referencias AND (RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'HDT_Task')) ];
            for (Task tarea : tareasOrigen) {
                mapaTipoTareaDelCorreo.put(tarea.WhatId, tarea.Type);
            }
        }

        for (EmailMessage correo : correosCc) {
            if (correo.Status != '5') { //0: New, 1: Read, 2: Replied, 3: Sent, 4: Forwarded, 5: Draft
                if (!correo.Incoming) {
                    //Correo SALIENTE
                    if (correo.CC_Procedencia__c == 'Traslado Colaborador') {
                        //Correo saliente de traslado del caso a grupo colaborador
                        envioTrasladoColaborador(correo, casos, actividadesTraslado);
                        relacionActividades.put(correo.ActivityId, actividadesTraslado.size() - 1);
                    } else if (correo.CC_Procedencia__c == 'Solicitud Información') {
                        //Correo saliente de solicitud de información a cliente
                        envioSolicitudInfo(correo, casos, actividadesTraslado);
                        relacionActividades.put(correo.ActivityId, actividadesTraslado.size() - 1);
                    } else if (correo.CC_Procedencia__c == 'Remitir Colaborador') {
                        //Correo saliente de remisión del caso a grupo colaborador
                        envioRemitirColaborador(correo, casos, actividadesTraslado);
                        relacionActividades.put(correo.ActivityId, actividadesTraslado.size() - 1);
                    } else if (correo.CC_Procedencia__c == 'Responder Cliente') {
                        envioResponderCliente(correo, casos, actividadesTraslado);
                        relacionActividades.put(correo.ActivityId, actividadesTraslado.size() - 1);
                    }
                    /* else {
                        //Envío automático de correo.
                        envioMailAuto(correo, actividadesTraslado);
                        relacionActividades.put(correo.ActivityId, actividadesTraslado.size() - 1);
                    }*/
                } else {
                    //Correo ENTRANTE
                    if(mapIdCaso.containsKey(correo.ParentId)){
                        //Si se ha encontrado la referencia se realizan acciones en función de la operativa del correo origen
                        if (mapaTipoTareaDelCorreo.containsKey(correo.parentId)) {
                            if (mapaTipoTareaDelCorreo.get(correo.parentId) == 'Traslado Colaborador') {
                                //Respuesta entrante de grupo colaborador
                                respuestaTrasladoColaborador(correo, casos);
                            } else if (mapaTipoTareaDelCorreo.get(correo.parentId) == 'Solicitud Información') {
                                //Respuesta entrante de solicitud de información de cliente
                                respuestaSolicitudInfo(correo, casos);
                            } else if (mapaTipoTareaDelCorreo.get(correo.parentId) == 'Remitir Colaborador') {
                                //Respuesta entrante de remisión del caso a grupo colaborador
                                respuestaRemitirColaborador(correo, casos);
                            }else if (mapaTipoTareaDelCorreo.get(correo.parentId) == 'Responder a cliente') {
                                //Respuesta entrante de respuesta de cliente
                                respuestaCliente(correo, casos);
                            }
                        }

                    }
                }
            } //Fin "for (EmailMessage correo : newList)"
        }

        //Ejecución de las actualizaciones de caso
        if (Schema.sObjectType.Case.fields.Status.isUpdateable()){
            update casos;
        }

        //Ejecución de las inserciones de las nuevas actividades de traslado
        if (!actividadesTraslado.isEmpty()) {
            //insert actividadesTraslado;
            HDT_Activity.crearActividades(actividadesTraslado);
        }

        List<Id> idActividesCorreo = new List<Id>();
        for (EmailMessage correo : correosCc) {
            //Actualización de las actividades existentes de correo para relacionarlas con las de traslado
            idActividesCorreo.add(correo.ActivityId);
        }
	}

    private static void envioTrasladoColaborador(EmailMessage correo, List<Case> casos, List<Task> actividadesTraslado) {
        Case caso = [SELECT CC_Canal_Procedencia__C, CC_Referencia_Correo_Saliente__c, CC_Cambio_Estado_Pendiente_Externo__c, Status, Origin,
                        CC_Fecha_1a_Respuesta_Twitter__c, CC_Fecha_Respuesta_Stores__c, Id, CC_MCC_Plantilla__c, CC_MCC_Tematica__r.Name, CC_Grupo_Colaborador__c, CC_Canal_Resolucion__c, CC_Idioma__c, Contact.Email, ContactId, CC_Buzon_Salida__c, CC_MailTelfNotif__c, RecordTypeId FROM Case WHERE Id = :correo.ParentId ];
        //caso.CC_Cambio_Estado_Pendiente_Externo__c = true;
        caso.Status = 'Pendiente Colaborador';
        caso.CC_Fecha_Traslado_Colaborador__c = Datetime.valueOf(System.now());

        /* Comentado por Moises
        //Si es Twitter o Stores informamos fecha respuesta para SLA reports, cuenta como gestión
        if (caso.Origin == 'Twitter' && caso.CC_Fecha_1a_Respuesta_Twitter__c == null) {
            caso.CC_Fecha_1a_Respuesta_Twitter__c = Datetime.valueOf(System.now());
        } else if (caso.Origin == 'Comentarios Stores') {
            if (caso.CC_Fecha_Respuesta_Stores__c == null) {
                caso.CC_Fecha_Respuesta_Stores__c = Datetime.valueOf(System.now());
            }
        }*/

        //Nueva actividad de tipo "Trasladar Colaborador"
        Task actividadTraslado = new Task();
        actividadTraslado.Type = 'Traslado Colaborador';
        actividadTraslado.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'HDT_Task');
        actividadTraslado.Subject = 'Traslado Colaborador';
        actividadTraslado.WhatId = correo.ParentId;
        actividadTraslado.Status = 'Open';
        actividadTraslado.Description = correo.TextBody.left(32000);
        actividadTraslado.CC_Referencia_Correo_Saliente__c = caso.CC_Referencia_Correo_Saliente__c;
        actividadTraslado.CC_Grupo_Colaborador_Id__c = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = :correo.CC_Grupo_Colab__c LIMIT 1].Id;
        HDT_Activity.informarFechaVencimientoSLA('Grupo colaborador', correo.CC_Grupo_Colab__c, actividadTraslado);
        CC_Configuracion_Reclamaciones_Auto.informarFechasReclamacionesAuto(actividadTraslado);
        actividadTraslado.CC_Correo_Asociado_Id__c = correo.Id;
        actividadesTraslado.add(actividadTraslado);

        caso.CC_Grupo_Colaborador__c = correo.CC_Grupo_Colab__c;
        caso.CC_Referencia_Correo_Saliente__c = ''; //Se vacía la referencia de correo saliente del caso para evitar que se reuse por error
        casos.add(caso);

        //Creamos el alta del aviso para TRZ
        String year = String.valueOf(Datetime.valueOf(System.now()).year());
        String month = String.valueOf(Datetime.valueOf(System.now()).month());
        String day = String.valueOf(Datetime.valueOf(System.now()).day());
        // Control de 0s en los dias y meses menores de 10
        if (month.length() == 1) {
            month = '0' + month;
        }
        if (day.length() == 1) {
            day = '0' + day;
        }
        String sDatpeticio = year + month + day;
		CC_Trazabilidad_Methods.altaAviso(sDatpeticio, 'A', 'AVISPDTEOFI', caso.Id);

        /* Comentado por Moises Cano
        //Correo automático de información para el contacto en caso de tener canal de resolución de Wivai
        if (caso.CC_Buzon_Salida__c != null && caso.Contact.Email != null && (caso.CC_Canal_Resolucion__c == 'Postventa CompraEstrella' || caso.CC_Canal_Resolucion__c == 'Soporte Clientes CompraEstrella' || caso.CC_Canal_Resolucion__c == 'Soporte Empleados CompraEstrella'
        || (caso.CC_Canal_Resolucion__c == 'Marketing'  && caso.CC_Canal_Procedencia__c != 'Formulario Consultas Operativas' && caso.CC_MCC_Tematica__r.Name.contains('Wivai'))))
        {  enviarCorreoAutomaticoConfirmacionTrasladoWivai (caso); }
        if (caso.CC_Buzon_Salida__c != null && caso.CC_MailTelfNotif__c != null && caso.CC_Canal_Procedencia__c == 'Formulario Consultas Operativas'){
            enviarCorreoAutomaticoTrasladoFormularioConsultasOperativas(caso);
        } */

    }

    private static void respuestaTrasladoColaborador(EmailMessage correo, List<Case> casos) {
        //Cambio de estado del caso


        Case caso = [SELECT Status, Subject, CC_Canal_Procedencia__c, Origin, CC_Autoasignado_Coordinador__c, CC_Cola_Procedencia__c,
                        CC_En_Tercer_Nivel__c, CC_Grupo_3N__c, OwnerId FROM Case WHERE Id = :correo.ParentId ];
        Boolean propietario = true;
        if (caso.Status == 'Pendiente Colaborador') {
            caso.CC_Ultima_Interaccion__c = 'Respuesta de colaborador';
            caso.CC_Fecha_Ultima_Interaccion__c = System.now();
            caso.CC_Situacion_Caso__c = 'Respuesta colaborador';

            // Si el caso viene de 3N debemos asignar el propietario del caso cuando se recibe la respuesta al último grupo de 3N
            if (caso.CC_En_Tercer_Nivel__c) {
                List<Task> tareas = [SELECT Type, Subject, WhatId, LastModifiedDate FROM Task WHERE WhatId = :caso.Id AND Type = 'Reasignación' AND Subject LIKE '%3N%' AND Status = 'Completed'  ORDER BY CreatedDate DESC LIMIT 1];
                if (!tareas.isEmpty()) {
                    String str = tareas[0].Subject;
                    //El espacio después de la a en el split es importante para que no falle, esta hecho de tal forma para que busque tanto si el grupo empieza por 3N o por Cola 3N
                    List<String> strList = str.split( 'Reasignación del caso a ');
                    if (!strList.isEmpty()) {
                        List<Group> cola3N = [SELECT Name FROM Group WHERE Type = 'queue' AND Name = :strList[1] ];
                        if (!cola3N.isEmpty()) {
                            caso.OwnerId = cola3N[0].Id;
                            propietario = false;
                        }
                    }
                }
            }

            if (caso.CC_Autoasignado_Coordinador__c) {
                //Se mantiene el coordinador que se ha autoasignado el caso como propietario  y se pasa a Activo
                caso.Status = 'Activo';
            } else if (caso.CC_En_Tercer_Nivel__c && caso.CC_Grupo_3N__c != null) {
                //Se devuelve el caso a la cola de 3N y se pasa a Activo
                //caso.OwnerId = [SELECT Id FROM Group WHERE Name = :caso.CC_Grupo_3N__c].Id;
                caso.Status = 'Pendiente Interno';
            } else if (caso.CC_Cola_Procedencia__c != null) {
                //Se devuelve el caso a la cola de procedencia y se pasa a Activo
                caso.Status = 'Activo';

                //Controlamos cuando se hace la devolución de un caso con canal de entrada Email + canal de procedencia = Atención al cliente, se reasigna a la cola de procedencia
                    /* Comentado por Moises Cano
                if (propietario && caso.Origin == 'Email' && caso.CC_Canal_Procedencia__c == 'Atención al Cliente') {
                        List<Task> tareasReasignacion = [SELECT Subject FROM TASK WHERE WhatId = :caso.Id AND Type = 'Reasignación' AND Status = 'Completed' AND Subject != NULL  ORDER BY CreatedDate DESC];
                        if (!tareasReasignacion.isEmpty()) {
                            for (Task tarea : tareasReasignacion) {
                                tarea.Subject = 'Reasignación del caso a ' + caso.CC_Cola_Procedencia__c;
                            }
                        }
                    }*/


                    if (propietario) {
                        caso.OwnerId = [SELECT Id FROM Group WHERE DeveloperName = :caso.CC_Cola_Procedencia__c].Id;
                    }

            } else {
                //Se pasa el caso a Activo
                caso.Status = 'Activo';
            }

            //Controlamos cuando se hace la devolución y se pone Activo para reports
            if (caso.CC_Canal_Procedencia__c == 'Formulario web' || caso.CC_Canal_Procedencia__c == 'Caixabank Talks') {
                caso.CC_Fecha_Activo_Formulario__c = Datetime.valueOf(System.now());
            } else if (caso.CC_Canal_Procedencia__c == 'Accionista') {
                caso.CC_Fecha_Activo_Formulario__c = CC_SLA_Utils.calculo_Fecha_Activo('Accionista');
            }

            //Informamos la fecha de respuesta para el report de Stores
            if (caso.Origin == 'Comentarios Stores') {
                caso.CC_Fecha_Respuesta_Colaborador__c = Datetime.valueOf(System.now());
            }
            casos.add(caso);

            //Cierre de la actividad de envío del traslado a grupo colaborador
            HDT_Activity.finalizarActividadCaso(correo.ParentId, 'Traslado Colaborador', null, null);

            //Creamos la baja del aviso para TRZ
            CC_Trazabilidad_Methods.bajaAviso('A', 'AVISPDTEOFI', caso.Id);
        }
    }

    private static void envioResponderCliente(EmailMessage correo, List<Case> casos, List<Task> actividadesTraslado) {
        Case caso = [SELECT CC_Referencia_Correo_Saliente__c,  CC_MCC_Plantilla__c, Status FROM Case WHERE Id = :correo.ParentId ];


        Task actividadTraslado = new Task();
        actividadTraslado.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'HDT_Task');
        actividadTraslado.Type = 'Responder a cliente';
        actividadTraslado.Subject = 'Responder a cliente';
        actividadTraslado.WhatId = correo.ParentId;
        actividadTraslado.Subject = correo.Subject;
        actividadTraslado.Description = correo.TextBody.left(32000);
        actividadTraslado.Status = 'Completed';
        actividadTraslado.CC_Referencia_Correo_Saliente__c = caso.CC_Referencia_Correo_Saliente__c;
        actividadTraslado.CC_Correo_Asociado_Id__c = correo.Id;
        actividadesTraslado.add(actividadTraslado);

        caso.CC_Referencia_Correo_Saliente__c = '';
        casos.add(caso);
    }

    private static void envioRemitirColaborador(EmailMessage correo, List<Case> casos, List<Task> actividadesTraslado) {
        Case caso = [SELECT CC_Referencia_Correo_Saliente__c, CC_MCC_Plantilla__c, CC_Grupo_Colaborador__c, Status FROM Case WHERE Id = :correo.ParentId ];

        caso.Status = 'Completed';
        caso.CC_Fecha_Traslado_Colaborador__c = Datetime.valueOf(System.now());

        Task actividadTraslado = new Task();
        actividadTraslado.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'HDT_Task');
        actividadTraslado.Type = 'Remitir Colaborador';
        actividadTraslado.Subject = 'Remitir Colaborador';
        actividadTraslado.WhatId = correo.ParentId;
        actividadTraslado.Subject = correo.CC_Procedencia__c;
        actividadTraslado.CC_Grupo_Colaborador_Id__c = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = :correo.CC_Grupo_Colab__c LIMIT 1].Id;
        actividadTraslado.Description = correo.TextBody.left(32000);
        actividadTraslado.Status = 'Completed';
        actividadTraslado.CC_Referencia_Correo_Saliente__c = caso.CC_Referencia_Correo_Saliente__c;
        actividadTraslado.CC_Correo_Asociado_Id__c = correo.Id;
        actividadesTraslado.add(actividadTraslado);

        caso.CC_Referencia_Correo_Saliente__c = '';
        casos.add(caso);
    }

    private static void respuestaRemitirColaborador(EmailMessage correo, List<Case> casos) {

        //Cambio de estado del caso
        Case caso = [SELECT Status FROM Case WHERE Id = :correo.ParentId  LIMIT 1];
        if (caso.Status == 'Pendiente Colaborador') {
            caso.Status = 'Activo';
            casos.add(caso);

            //Cierre de la actividad de envío del traslado a grupo colaborador
            HDT_Activity.finalizarActividadCaso(correo.ParentId, 'Remitir Colaborador', null, null);
        }
    }

    @Testvisible
    private static void envioSolicitudInfo(EmailMessage correo, List<Case> casos, List<Task> actividadesTraslado) {
        //Recuperamos el plazo que tendrá cliente/empleado para responder al mail de Sol. Inf. para asignarlo al caso y tarea
        //Posteriormente habrá un PB que cerrará el caso y enviará un mail en el momento que cumpla el plazo

        Datetime fechaFinPlazo = HDT_Cierre_Automatico_Methods.CC_Cierre_Automatico_SolicitudInformacion(correo.ParentId);

       // ID caseClienteRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();

        //Cambio de estado del caso
        Case caso = [SELECT CC_Referencia_Correo_Saliente__c, CC_MCC_Plantilla__c, Status FROM Case WHERE Id = :correo.ParentId ];
        caso.Status = 'Pendiente Cliente';
        caso.CC_Fecha_Cierre_SolInf__c = fechaFinPlazo;
        caso.CC_Fecha_Solicitud_Informacion__c = System.today();
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();

        //Nueva actividad de tipo "Solicitud Información"
        Task actividadTraslado = new Task();
        actividadTraslado.Type = 'Solicitud Información';
        actividadTraslado.Subject = 'Solicitud Información';
        actividadTraslado.WhatId = correo.ParentId;
        actividadTraslado.CC_Fecha_FinPlazo_SolInf__c = fechaFinPlazo;
        actividadTraslado.Status = 'Open';
        actividadTraslado.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
        actividadTraslado.Description = correo.TextBody.left(32000);
        actividadTraslado.CC_Referencia_Correo_Saliente__c = caso.CC_Referencia_Correo_Saliente__c;
        actividadesTraslado.add(actividadTraslado);

        caso.CC_Referencia_Correo_Saliente__c = ''; //Se vacía la referencia de correo saliente del caso para evitar que se reuse por error
        casos.add(caso);

        //Creamos el alta del aviso para TRZ
        String year = String.valueOf(Datetime.valueOf(System.now()).year());
        String month = String.valueOf(Datetime.valueOf(System.now()).month());
        String day = String.valueOf(Datetime.valueOf(System.now()).day());
        // Control de 0s en los dias y meses menores de 10
        if (month.length() == 1) {
            month = '0' + month;
        }
        if (day.length() == 1) {
            day = '0' + day;
        }
        String sDatpeticio = year + month + day;
		CC_Trazabilidad_Methods.altaAviso(sDatpeticio, 'I', 'AVISPDTECLI', caso.Id);
    }

    private static void respuestaSolicitudInfo(EmailMessage correo, List<Case> casos) {

        Case caso = [SELECT Status, Subject, CC_Canal_Procedencia__c, Origin, CC_Autoasignado_Coordinador__c, CC_Cola_Procedencia__c,
                     CC_En_Tercer_Nivel__c, CC_Grupo_3N__c, OwnerId FROM Case WHERE Id = :correo.ParentId ];

        Boolean canviarPropietario = true;
        if (caso.Status == 'Pendiente Cliente') {
            // Si el caso viene de 3N debemos asignar el propietario del caso cuando se recibe la respuesta al último grupo de 3N

            if (caso.CC_En_Tercer_Nivel__c) {
                List<Task> tareas = [SELECT Type, Subject, WhatId, LastModifiedDate FROM Task WHERE WhatId = :caso.Id AND Type = 'Reasignación' AND Subject LIKE '%3N%' AND Status = 'Completed'  ORDER BY CreatedDate DESC LIMIT 1];
                if (!tareas.isEmpty()) {
                    String str = tareas[0].Subject;
                    //El espacio después de la a en el split es importante para que no falle, esta hecho de tal forma para que busque tanto si el grupo empieza por 3N o por Cola 3N
                    List <String> strList = str.split( 'Reasignación del caso a ');
                    if (!strList.isEmpty()) {
                        List<Group> cola3N = [SELECT Name FROM Group WHERE Type = 'queue' AND Name = :strList[1] ];
                        if (!cola3N.isEmpty()) {
                            caso.OwnerId = cola3N[0].Id;
                            canviarPropietario = false;
                        }
                    }
                }
            }

            caso.Status = 'Activo';
            caso.CC_Ultima_Interaccion__c = 'Respuesta de solicitud de información';
            caso.CC_Fecha_Ultima_Interaccion__c = System.now();
            caso.CC_Situacion_Caso__c = 'Respuesta cliente';

            //Si la propiedad del caso no está fijada a un coordinador, se devuelve el caso a la cola para
            //que lo pueda atender cualquier agente, no solo el propietario previo a la solicitud
            if (!caso.CC_Autoasignado_Coordinador__c && caso.CC_Cola_Procedencia__c != null && canviarPropietario) {
                caso.OwnerId = [SELECT Id FROM Group WHERE DeveloperName = :caso.CC_Cola_Procedencia__c].Id;
            }

            //Controlamos cuando se hace la devolución y se pone Activo para report de FormWeb.
            if (caso.CC_Canal_Procedencia__c == 'Formulario web' || caso.CC_Canal_Procedencia__c == 'Caixabank Talks') {
                caso.CC_Fecha_Activo_Formulario__c = Datetime.valueOf(System.now());
            }
            casos.add(caso);

            //Cierre de la actividad de envío del traslado a grupo colaborador
            HDT_Activity.finalizarActividadCaso(correo.ParentId, 'Solicitud Información', null, null);

        } else if (caso.Status == 'Cerrado') {
            //Para solicitudes info se reabre el caso aunque se hubiera cerrado
            HDT_Case.reapertura(caso.Id, correo.TextBody);
        }

        //Creamos la baja del aviso para TRZ
        CC_Trazabilidad_Methods.bajaAviso('I', 'AVISPDTECLI', caso.Id);
    }

    @Testvisible
    public static void respuestaCliente(EmailMessage correo, List<Case> casos) {
        //Cuando un cliente responde a un email enviado desde la operativa reponder a cliente se envía un email automático
        Case caso = [SELECT Status, CC_Numero_Documento__c, CC_Idioma__c, AccountId, ContactId, OwnerId, CC_Canal_Resolucion__c, CC_Canal_Procedencia__c, CC_Autoasignado_Coordinador__c,
                        Origin,CC_Cola_Procedencia__c, RecordTypeId, Canal_del_Empleado__c FROM Case WHERE Id = :correo.ParentId ];
        Set<String> oLOVVal = new Set<String>();
        Set<String> oLOV = new Set<String>();

        if (caso.Status == 'Cerrado' && Schema.SObjectType.Case.getRecordTypeInfosById().get(caso.RecordTypeId).getDeveloperName() == 'HDT_Empleado' &&
            (caso.Origin == 'Chat' || (caso.Origin == 'Email' && caso.CC_Canal_Procedencia__c == 'Formulario Consultas Operativas'))) {
            //Pablo - 09/11/2022 - Se reabre el caso
            String lov ='';
            if(caso.Origin == 'Chat'){
                lov='CC_Respuesta_a_empleado';
            }
            else if(caso.Origin == 'Email' && caso.CC_Canal_Procedencia__c == 'Formulario Consultas Operativas'){
                lov='CC_Respuesta_a_empleado_form';
            }
            if(lov != ''){
                oLOV.add(lov);
                oLOVVal.add(caso.CC_Canal_Resolucion__c);
                Map<String,Object> respuestaEmp = CC_MetodosUtiles.getLOVWithVal(oLOV,oLOVVal);
                List<Group> lstRespuestas = new List<Group>();
                if(!respuestaEmp.isEmpty()){
                    Map <String,String> valRespEmp = (Map <String,String>)respuestaEmp.get(lov);
                    lstRespuestas = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = :valRespEmp.get(caso.CC_Canal_Resolucion__c) limit 1];
                }
                if(!lstRespuestas.isEmpty()){
                    caso.Status = 'Activo';
                    caso.OwnerId = lstRespuestas[0].id;
                    casos.add(caso);
                }
            }
        } else {
            List<CC_Queue_Procedencia__mdt> queues = [SELECT CC_Queue__c, CC_Canal_Procedencia__c FROM CC_Queue_Procedencia__mdt
                                                        WHERE CC_Canal_Procedencia__c = :caso.CC_Canal_Procedencia__c ];
            String developerNameCola;
            if (!queues.isEmpty()) {
                developerNameCola = queues[0].CC_Queue__c;
            } /*else {
                developerNameCola = 'CC_Inbound_Email_AC';
            }*/
            if (developerNameCola != null) {
                Group cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = :developerNameCola  LIMIT 1];
                caso.OwnerId = cola.Id;
            }
            String htmlBody;


                if (caso.CC_Idioma__c == 'en') {
                    htmlBody = [SELECT DeveloperName, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'CC_Respuesta_Automatica_Cliente_en'  LIMIT 1].HtmlValue;
                } else if (caso.CC_Idioma__c == 'ca') {
                    htmlBody = [SELECT DeveloperName, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'CC_Respuesta_Automatica_Cliente_ca'  LIMIT 1].HtmlValue;
                } else {
                    htmlBody = [SELECT DeveloperName, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'CC_Respuesta_Automatica_Cliente_es'  LIMIT 1].HtmlValue;
                }


            List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();

            List<OrgWideEmailAddress> owa = [SELECT DisplayName, Address FROM OrgWideEmailAddress WHERE Address = :correo.ToAddress  LIMIT 1];

            if (owa.isEmpty() && caso.CC_Canal_Procedencia__c == 'Accionista') {
                //hacer lista SELECT DEL METADATO CC_Valores__mdt y sacar Valor Valor SFDC y el campo lista tiene que ser accionistaslista
                List<OrgWideEmailAddress> owaAccionistas = [SELECT DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = 'Accionistas CaixaBank'  LIMIT 1];
                List<CC_Valores__mdt> listaValoresCorreos = [SELECT CC_Valor_SFDC__c, CC_Valor__c, CC_Lista__c FROM CC_Valores__mdt
                                                                WHERE CC_Lista__c = 'accionistaslista' ];

                for (CC_Valores__mdt listaCorreo : listaValoresCorreos) {
                    //comprobar si emailDestiono = algun metadato de custom accionistas
                    if (listaCorreo.CC_Valor_SFDC__c == correo.ToAddress || listaCorreo.CC_Valor__c == correo.ToAddress) {
                        //en el caso de ser cierto assignar el owa.id de OrgWideEmailAddress en cuestion
                        owa = owaAccionistas;
                    }
                }

                //Comprobar que el canal de procedencia es de tipo promocaixa empleado
            }

            /* Comentado por Moises Cano
            else if (owa.isEmpty() && caso.CC_Canal_Procedencia__c == 'Soporte Empleados CompraEstrella') {
                List<OrgWideEmailAddress> owaEmpleados = [SELECT DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = 'Atención Oficinas Wivai'  LIMIT 1];
                List<CC_Valores__mdt> listaValoresCorreos = [SELECT CC_Valor_SFDC__c, CC_Valor__c, CC_Lista__c  FROM CC_Valores__mdt
                                                                WHERE CC_Lista__c = 'promocaixaEmpleados' ];
                for (CC_Valores__mdt listaCorreo : listaValoresCorreos) {
                    if (listaCorreo.CC_Valor_SFDC__c == correo.ToAddress || listaCorreo.CC_Valor__c == correo.ToAddress) {
                        owa = owaEmpleados;
                    }
                }

            } else if (owa.isEmpty() && caso.CC_Canal_Procedencia__c == 'Soporte Clientes CompraEstrella') {
                List<OrgWideEmailAddress> owaClientes = [SELECT DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = 'Atención Clientes Wivai'  LIMIT 1];
                List<CC_Valores__mdt> listaValoresCorreos = [SELECT CC_Valor_SFDC__c, CC_Valor__c, CC_Lista__c  FROM CC_Valores__mdt
                                                                WHERE CC_Lista__c = 'promocaixaClientes' ];

                for (CC_Valores__mdt listaCorreo : listaValoresCorreos) {
                    if (listaCorreo.CC_Valor_SFDC__c == correo.ToAddress || listaCorreo.CC_Valor__c == correo.ToAddress) {
                        owa = owaClientes;
                    }
                }



            }

            //Preventiva
            else if (owa.isEmpty() && caso.CC_Canal_Procedencia__c == 'Oficina Preventiva'){
                List<OrgWideEmailAddress> owaClientes = [SELECT DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = 'Atención Clientes CaixaBank'  LIMIT 1];
                List<CC_Valores__mdt> listaValoresCorreos = [SELECT CC_Valor_SFDC__c, CC_Valor__c, CC_Lista__c  FROM CC_Valores__mdt
                WHERE CC_Lista__c = 'preventivaLista' ];

                for (CC_Valores__mdt listaCorreo : listaValoresCorreos) {
                    if (listaCorreo.CC_Valor_SFDC__c == correo.ToAddress || listaCorreo.CC_Valor__c == correo.ToAddress) {
                        owa = owaClientes;
                    }
                }
                //Atención al cliente
            }else if (owa.isEmpty() && caso.CC_Canal_Procedencia__c == 'Atención al Cliente'){
                List<OrgWideEmailAddress> owaClientesCA = [SELECT DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = 'Atenció Clients CaixaBank'  LIMIT 1];
                List<OrgWideEmailAddress> owaClientesEN = [SELECT DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = 'Customer Support CaixaBank'  LIMIT 1];
                List<OrgWideEmailAddress> owaClientesES = [SELECT DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = 'Atención Clientes CaixaBank'  LIMIT 1];
                List<CC_Valores__mdt> listaValoresCorreos = [SELECT CC_Valor_SFDC__c, CC_Valor__c, CC_Lista__c  FROM CC_Valores__mdt
                                                                WHERE CC_Lista__c = 'atencionClienteLista' ];

                                                                for (CC_Valores__mdt listaCorreo : listaValoresCorreos) {
                                                                    if (listaCorreo.CC_Valor_SFDC__c == correo.ToAddress || listaCorreo.CC_Valor__c == correo.ToAddress) {
                                                                        if (caso.CC_Idioma__c == 'ca') {
                                                                            owa = owaClientesCA;
                                                                        } else if (caso.CC_Idioma__c == 'en') {
                                                                            owa = owaClientesEN;
                                                                        } else {
                                                                            owa = owaClientesES;
                                                                        }
                                                                    }
                                                                }
                //CSI Bankia
            } else if (owa.isEmpty() && caso.Canal_del_Empleado__c != null && caso.Canal_del_Empleado__c.equalsIgnoreCase('CSI')) {
                                                                List<OrgWideEmailAddress> owaCSI = [SELECT DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = 'Atención Empleados Csi Bankia'  LIMIT 1];
                                                                List<CC_Valores__mdt> listaValoresCorreos = [SELECT CC_Valor_SFDC__c, CC_Valor__c, CC_Lista__c  FROM CC_Valores__mdt
                                                                WHERE CC_Lista__c = 'csiBankiaLista' ];

                                                                for (CC_Valores__mdt listaCorreo : listaValoresCorreos) {
                                                                    if (listaCorreo.CC_Valor_SFDC__c.equals(correo.ToAddress) || listaCorreo.CC_Valor__c.equals(correo.ToAddress)) {
                                                                        owa = owaCSI;
                    }
                }
            }

            */
            //Se envía el correo solo si hay alguna dirección para enviar
            if (!owa.isEmpty()){
            //Generamos el email a enviar. Debe mantener el cuerpo del email anterior y agregar el cuerpo de la plantilla recuperada
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                //Falta que nos pasen la plantilla
                email.setHtmlBody(htmlBody + '<br/>__________<br/><br/>' + correo.HtmlBody);
                email.setSaveAsActivity(true);
                email.setTreatBodiesAsTemplate(true);
                email.setWhatId(caso.Id);
                email.setTargetObjectId(caso.ContactId);
                email.setTreatTargetObjectAsRecipient(false);
                email.setOrgWideEmailAddressId(owa[0].Id);
                email.subject = correo.Subject;
                List<String> toAddress = new List<String>();
                toAddress.add(correo.FromAddress);
                email.setToAddresses(toAddress);
                allmsg.add(email);
            }

            //Enviamos todos los mensajes
            if (!allmsg.isEmpty()) {
                for (Messaging.SendEmailResult sr : Messaging.sendEmail(allmsg, false)) {
                    if (!sr.isSuccess()) {
                        for (Database.Error err : sr.getErrors()) {
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Fields that affected this error: ' + err.getFields());
                        }
                    }
                }
            }
        }
    }

    /* Comentado por Jorge
    private static void envioMailAuto(EmailMessage correo, List<Task> actividadesTraslado) {
        Task actividadTraslado = new Task();
        actividadTraslado.Type = 'Otros';

        if (correo.Subject != null && correo.Subject != '') {
            String sSubject = correo.Subject;
            if (sSubject.length() > 80) {
                sSubject = sSubject.substring(0, 80);
            }
            actividadTraslado.Subject = 'Email (Auto): ' + sSubject;
        } else {
            actividadTraslado.Subject = 'Email - Automático';
        }
        actividadTraslado.WhatId = correo.ParentId;
        actividadTraslado.Description = correo.TextBody;
        actividadTraslado.Status = 'Completed';
        actividadTraslado.CC_Correo_Asociado_Id__c = correo.Id;
        actividadesTraslado.add(actividadTraslado);
    }
    */

    private static void comprobarAnexosPermitidos(List<EmailMessage> listNewObj, Map<Id, EmailMessage> mapNewObj) {
        //Se obtienen las extensiones permitidas para un anexo
        List<String> extensionesPermitidas = new List<String>();
        for (CC_ConfiguracionAnexoPermitido__mdt extensionPermitida : [SELECT CC_Extension__c FROM CC_ConfiguracionAnexoPermitido__mdt ]) {
            extensionesPermitidas.add(extensionPermitida.CC_Extension__c);
        }

        // Se recopilan los correos salientes que contienen anexo
        List<Id> correosSalientes = new List<Id>();
        for (EmailMessage correo : listNewObj) {
            if (!correo.Incoming) {
                correosSalientes.add(correo.Id);
            }
        }

        if (!correosSalientes.isEmpty()) {
            // Se comprueban las extensiones de los anexos y se impide el envío del correo en caso de que contenga algún anexo con extensión no permitida.
            for (ContentDocumentLink contentDocumentLink : [SELECT LinkedEntityId FROM ContentDocumentLink
                                                            WHERE ContentDocument.FileExtension NOT IN :extensionesPermitidas AND LinkedEntityId IN :correosSalientes ]) {
                EmailMessage correoSalienteConAnexoProhibido = mapNewObj.get(contentDocumentLink.LinkedEntityId);
                correoSalienteConAnexoProhibido.addError('El correo tiene un archivo adjunto con un formato no permitido. Por favor, adjunte otro tipo de fichero.');
            }
        }
    }

    private static void validarBuzonSalida(List<EmailMessage> listNewObj) {
        //Se obtiene de CC_Buzones_Por_Defecto__mdt la lista de buzones de salida válidos
        List<String> buzonesSalidaValidos = new List<String>();
        for (CC_Buzones_Por_Defecto__mdt buzonPorDefecto : [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt ]) {
            buzonesSalidaValidos.add(buzonPorDefecto.CC_Direccion_Correo__c);
        }

        //Si el correo a enviar tiene un buzón de salida que no está en la lista, se muestra un error
        for (EmailMessage correo : listNewObj) {
            if (!correo.Incoming && !buzonesSalidaValidos.contains(correo.FromAddress)) {
                correo.addError('El buzón de salida indicado no es apto para el envío de correos.', false);
            }
        }
    }


    /* Comentado por Moises Cano
    private static void enviarCorreoAutomaticoConfirmacionTrasladoWivai(Case casoTras){

        String recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosById().get(casoTras.RecordTypeId).getDeveloperName();
        EmailTemplate plantilla = new EmailTemplate ();

        //escogemos plantilla segun idioma y RecordType
        if (casoTras.CC_Idioma__c != 'ca' && recordTypeCaso.equals('HDT_Empleado') ){
            plantilla = [SELECT Id, Subject FROM EmailTemplate WHERE DeveloperName = 'CC_Notificacion_Traslado_Cliente_Wivai_ES' ];
        }
        else{
            if (recordTypeCaso.equals('HDT_Empleado') ){
                plantilla = [SELECT Id, Subject FROM EmailTemplate WHERE DeveloperName = 'CC_Notificacion_Traslado_Cliente_Wivai_CA' ];
            }
            else {
                if(casoTras.CC_Idioma__c != 'ca' && recordTypeCaso.equals('HDT_Empleado')  ){
                    plantilla = [SELECT Id, Subject FROM EmailTemplate WHERE DeveloperName = 'CC_Notificacion_Traslado_Empleado_Wivai_ES' ];
                }
                else {
                    if (recordTypeCaso.equals('HDT_Empleado')){
                        plantilla = [SELECT Id, Subject FROM EmailTemplate WHERE DeveloperName = 'CC_Notificacion_Traslado_Empleado_Wivai_CA' ];
                    }

                }
            }
        }

        //recuperamos del caso la dirección de correo
        List<CC_Buzones_Por_Defecto__mdt> buzonDefault = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt
                                                           WHERE CC_Canal_Procedencia__c = :casoTras.CC_Canal_Resolucion__c AND CC_Activo__c = true ];
        //Si el buzón está vacío usamos el por defecto
        if (buzonDefault.isEmpty()){
            buzonDefault  = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt
                               WHERE CC_Canal_Procedencia__c = 'Por defecto' AND CC_Idioma__c = 'Castellano'
                               AND CC_Activo__c = true ];
        }

        //Solo se envía en caso de que haya alguna dirección
        if (!buzonDefault.isEmpty()){
            OrgWideEmailAddress oweaid = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :buzonDefault[0].CC_Direccion_Correo__c ];
            //creamos el email
            List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] {casoTras.Contact.Email});
            //email.setSubject(plantilla.Subject);
            email.setTemplateId(plantilla.Id);
            email.setWhatId(casoTras.Id);
            email.setSaveAsACtivity(true);
            email.setOrgWideEmailAddressId(oweaid.Id);
            email.setTargetObjectId(casoTras.ContactId);
            allmsg.add(email);
            //Enviamos el email
            try{
                Messaging.SendEmailResult [] result = Messaging.sendEmail(allmsg, false);

            } catch (Exception ex) {
                // Log the error for debugging purposes
                System.debug('Error occurred: ' + ex.getMessage());

                // Return an error message to the user
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred: ' + ex.getMessage()));
        }

        }

    } */

    @Testvisible
    private static void enviarCorreoAutomaticoTrasladoFormularioConsultasOperativas(Case caso){

        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();

        List<OrgWideEmailAddress> owa = new List<OrgWideEmailAddress>();
        if (Test.isRunningTest()) {
            owa = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName like 'Atención%'  LIMIT 1];
        } else {
            owa = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :caso.CC_Buzon_Salida__c ];
        }
        if (!owa.isEmpty()) {

            List<EmailTemplate> emailTemplates = [SELECT Id, Developername, subject, htmlvalue FROM EmailTemplate WHERE Developername IN ('CC_ConsultasOperativasCanalFormulario_Traslado_CAS','CC_ConsultasOperativasCanalFormulario_Traslado_CAT') ];
            Map<String,String> templateSubjectPorIdioma = new Map<String,String>();
            Map<String,String> templateHTMLBodyPorIdioma = new Map<String,String>();
            if (!emailTemplates.isEmpty()){
                for(EmailTemplate template : emailTemplates) {

                    if (template.DeveloperName.contains('_CAT')){
                        templateSubjectPorIdioma.put('ca', template.subject);
                        templateHTMLBodyPorIdioma.put('ca', template.htmlvalue);
                    }else {
                        templateSubjectPorIdioma.put('es', template.subject);
                        templateHTMLBodyPorIdioma.put('es', template.htmlvalue);
                    }
                }



                Messaging.SingleEmailMessage correo = new Messaging.SingleEmailMessage();
                correo.setOrgWideEmailAddressId(owa[0].Id);
                correo.setToAddresses(new List<String>{caso.CC_MailTelfNotif__c});
                correo.setTreatBodiesAsTemplate(true);
                correo.setSubject(templateSubjectPorIdioma.get(caso.CC_Idioma__c));
                correo.setHtmlBody(templateHTMLBodyPorIdioma.get(caso.CC_Idioma__c));
                correo.setTreatTargetObjectAsRecipient(false);
                correo.setWhatId(caso.Id);
                correo.setSaveAsActivity(true);
                allmsg.add(correo);


            }
        }

        if (!allmsg.isEmpty()){
            //Enviamos todos los mensajes
            try{
                Messaging.SendEmailResult [] result = Messaging.sendEmail(allmsg, false);

            } catch (Exception ex) {
                    // Log the error for debugging purposes
                    System.debug('Error occurred: ' + ex.getMessage());

                    // Return an error message to the user
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred: ' + ex.getMessage()));
            }
        }
    }
}