public class AM_EmailMessage_AI_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<EmailMessage>)tp.newList, (Map<Id, EmailMessage>)tp.newMap);
	}

    private List<EmailMessage> filtrarEmailMessageNoCAM(List<EmailMessage> listNewObj) {
        List<EmailMessage> newList = new List<EmailMessage>();
        Set<Id> parentIdCaseSet = new Set<Id>();
        for (EmailMessage emailMessage : listNewObj) {
            if (emailMessage.ParentId != null ) {
                if(String.valueOf(emailMessage.ParentId.getSobjectType()) == 'Case'){
                    parentIdCaseSet.add(emailMessage.ParentId);
                }
                else if(OT_Proyectos.registroProyecto(emailMessage.ParentId) == 'AM'){
                    newList.add(emailMessage);
                }                
            }
        }
        Set<Id> casesAMId = new Set<Id>();
        if(parentIdCaseSet!=null){
            Case[] caseRecordTypeList = [SELECT Recordtype.DeveloperName FROM Case WHERE Id=:parentIdCaseSet];
            for(Case caso: caseRecordTypeList){
                if(caso.Recordtype.DeveloperName.substringBefore('_') =='AM'){
                    casesAMId.add(caso.Id);
                }
            }
            for (EmailMessage emailMessage : listNewObj){
                if(casesAMId.contains(emailMessage.parentId)){
                    newList.add(emailMessage);
                }
            }

        }
        return newList;
    }

    private void process(List<EmailMessage> listNewObj, Map<Id, EmailMessage> mapNewObj) {
        
        List<EmailMessage> newList = filtrarEmailMessageNoCAM(listNewObj);

        validarBuzonSalida(newList);

        //Se comprueba si el correo contiene algún fichero adjunto con un formato no permitido y, en tal caso, se impide su envío.
        comprobarAnexosPermitidos(newList, mapNewObj);

        //Se acumulan las inserciones/actualizaciones en las siguientes listas para ejecutarlas al final
        List<Case> casos = new List<Case>();
        List<Task> actividadesTraslado = new List<Task>();

        //Hasta que se inserten las actividades de traslado no se pueden informar los Ids en las de
        //correo, así que se guardan las relaciones en este mapa y se informan los Ids al final
        Map<Id, Integer> relacionActividades = new Map<Id, Integer>();

        //En función de la operativa y de si el correo es saliente o entrante, se ejecutan acciones diferentes
        for (EmailMessage correo : newList) {
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
                }
            } //Fin "for (EmailMessage correo : newList)"
        }

        //Ejecución de las actualizaciones de caso
        update casos;

        //Ejecución de las inserciones de las nuevas actividades de traslado
        insert actividadesTraslado;
    
        List<Id> idActividesCorreo = new List<Id>();
        for (EmailMessage correo : newList) {
            //Actualización de las actividades existentes de correo para relacionarlas con las de traslado
            idActividesCorreo.add(correo.ActivityId);
        }
	}

    private static void envioTrasladoColaborador(EmailMessage correo, List<Case> casos, List<Task> actividadesTraslado) {
        //CORREO SALIENTE
        //Cambio de estado del caso
        Case caso = [SELECT CC_Ultima_Interaccion__c, CC_Fecha_Ultima_Interaccion__c, CC_Referencia_Correo_Saliente__c, CC_Cambio_Estado_Pendiente_Externo__c, Status, Origin,
                    CC_Fecha_1a_Respuesta_Twitter__c, CC_Fecha_Respuesta_Stores__c FROM Case WHERE Id = :correo.ParentId];

        //caso.CC_Cambio_Estado_Pendiente_Externo__c = true;
        caso.Status = 'Pendiente Colaborador';
        caso.CC_Ultima_Interaccion__c = 'Nuevo';
        caso.CC_Fecha_Ultima_Interaccion__c = System.now();
        caso.CC_Fecha_Traslado_Colaborador__c = Datetime.valueOf(System.now());
        //Si es Twitter o Stores informamos fecha respuesta para SLA reports, cuenta como gestión
        
        //Nueva actividad de tipo "Trasladar Colaborador"
        Task actividadTraslado = new Task();
        actividadTraslado.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'AM_Task');
        actividadTraslado.Type = 'Traslado Colaborador';
        actividadTraslado.Subject = 'Traslado Colaborador';
        actividadTraslado.WhatId = correo.ParentId;
        actividadTraslado.Status = 'Open';
        actividadTraslado.Description = correo.TextBody.left(32000);
        actividadTraslado.CC_Referencia_Correo_Saliente__c = caso.CC_Referencia_Correo_Saliente__c;
        actividadTraslado.CC_Grupo_Colaborador_Id__c = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = :correo.CC_Grupo_Colab__c LIMIT 1].Id;
        //CC_Activity.informarFechaVencimientoSLA('Grupo colaborador', correo.CC_Grupo_Colab__c, actividadTraslado);
        CC_Configuracion_Reclamaciones_Auto.informarFechasReclamacionesAuto(actividadTraslado);
        actividadTraslado.CC_Correo_Asociado_Id__c = correo.Id;
        actividadTraslado.ActivityDate = System.today();
        actividadesTraslado.add(actividadTraslado);

        caso.CC_Grupo_Colaborador__c = correo.CC_Grupo_Colab__c;
        caso.CC_Referencia_Correo_Saliente__c = ''; //Se vacía la referencia de correo saliente del caso para evitar que se reuse por error
        caso.CC_Ultima_Operativa_Correo__c = '';
        casos.add(caso);
    }

    private static void envioResponderCliente(EmailMessage correo, List<Case> casos, List<Task> actividadesTraslado) {
        //CORREO SALIENTE
        Case caso = [SELECT CC_Ultima_Interaccion__c, CC_Fecha_Ultima_Interaccion__c, CC_Referencia_Correo_Saliente__c, Status, OS_Cerrado_Operativa__c FROM Case WHERE Id = :correo.ParentId];

        Task actividadTraslado = new Task();
        actividadTraslado.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'AM_Task');
        actividadTraslado.Type = 'Responder a cliente';
        actividadTraslado.Subject = 'Responder a cliente';
        actividadTraslado.WhatId = correo.ParentId;
        actividadTraslado.Subject = correo.Subject;
        actividadTraslado.Description = correo.TextBody.left(32000);
        actividadTraslado.Status = 'Completed';
        actividadTraslado.CC_Referencia_Correo_Saliente__c = caso.CC_Referencia_Correo_Saliente__c;
        actividadTraslado.CC_Correo_Asociado_Id__c = correo.Id;
        actividadTraslado.ActivityDate = System.today();
        actividadesTraslado.add(actividadTraslado);

        caso.CC_Referencia_Correo_Saliente__c = '';
        caso.CC_Ultima_Interaccion__c = 'Nuevo';
        caso.CC_Fecha_Ultima_Interaccion__c = System.now();
        
        ///OS_Cerrado_Operativa__c = true EN OS_Case_Operativas_Controller
       if (caso.OS_Cerrado_Operativa__c) {
            caso = AM_Case.responderCerrar(caso);
        }  
        casos.add(caso);
    }

    private static void envioRemitirColaborador(EmailMessage correo, List<Case> casos, List<Task> actividadesTraslado) {
        
        //CORREO SALIENTE
        Case caso = [SELECT CC_Referencia_Correo_Saliente__c, CC_Ultima_Interaccion__c, CC_Fecha_Ultima_Interaccion__c, Status, CC_Ultima_Operativa_Correo__c FROM Case WHERE Id = :correo.ParentId];

        Task actividadTraslado = new Task();
        actividadTraslado.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'AM_Task');
        actividadTraslado.Type = 'Remitir Colaborador';
        actividadTraslado.Subject = 'Remitir Colaborador';
        actividadTraslado.WhatId = correo.ParentId;
        actividadTraslado.Subject = correo.CC_Procedencia__c;
        actividadTraslado.CC_Grupo_Colaborador_Id__c = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = :correo.CC_Grupo_Colab__c LIMIT 1].Id;
        actividadTraslado.Description = correo.TextBody.left(32000);
        actividadTraslado.Status = 'Completed';
        actividadTraslado.CC_Referencia_Correo_Saliente__c = caso.CC_Referencia_Correo_Saliente__c;
        actividadTraslado.CC_Correo_Asociado_Id__c = correo.Id;
        actividadTraslado.ActivityDate = System.today();
        actividadesTraslado.add(actividadTraslado);

        caso.CC_Referencia_Correo_Saliente__c = '';
        caso.CC_Ultima_Interaccion__c = 'Nuevo';
        caso.CC_Fecha_Ultima_Interaccion__c = System.now();
        casos.add(caso);
    }

    private static void envioSolicitudInfo(EmailMessage correo, List<Case> casos, List<Task> actividadesTraslado) {
        //CORREO SALIENTE
        //Recuperamos el plazo que tendrá cliente/empleado para responder al mail de Sol. Inf. para asignarlo al caso y tarea
        //Posteriormente habrá un PB que cerrará el caso y enviará un mail en el momento que cumpla el plazo
        Datetime fechaFinPlazo = null;
        
        //Cambio de estado del caso
        Case caso = [SELECT CC_Fecha_Ultima_Interaccion__c, CC_Canal_Procedencia__c, CC_Ultima_Interaccion__c, CC_Referencia_Correo_Saliente__c, Status, RecordType.DeveloperName FROM Case WHERE Id = :correo.ParentId];
        // El caso se cierra automáticamente tras x tiempo solo para valores
        if (caso.RecordType.DeveloperName.startsWith('AM') && caso.CC_Canal_Procedencia__c == 'Buzón Valores') {
            fechaFinPlazo = CC_Cierre_Automatico_Methods.CC_Cierre_Automatico_SolicitudInformacion(correo.ParentId);
        }
        caso.Status = 'Pendiente Cliente';
        caso.CC_Fecha_Cierre_SolInf__c = fechaFinPlazo;
        caso.CC_Ultima_Interaccion__c = 'Nuevo';
        caso.CC_Fecha_Ultima_Interaccion__c = System.now();
        caso.CC_Fecha_Solicitud_Informacion__c = System.today();

        //Nueva actividad de tipo "Solicitud Información"
        Task actividadTraslado = new Task();
        actividadTraslado.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'AM_Task');
        actividadTraslado.Type = 'Solicitud Información';
        actividadTraslado.Subject = 'Solicitud Información';
        actividadTraslado.WhatId = correo.ParentId;
        actividadTraslado.CC_Fecha_FinPlazo_SolInf__c = fechaFinPlazo;
        actividadTraslado.Status = 'Open';
        actividadTraslado.Description = correo.TextBody.left(32000);
        actividadTraslado.CC_Referencia_Correo_Saliente__c = caso.CC_Referencia_Correo_Saliente__c;
        actividadTraslado.ActivityDate = System.today();
        actividadesTraslado.add(actividadTraslado);
        
        caso.CC_Referencia_Correo_Saliente__c = ''; //Se vacía la referencia de correo saliente del caso para evitar que se reuse por error
        casos.add(caso);
    }

    private void comprobarAnexosPermitidos(List<EmailMessage> listNewObj, Map<Id, EmailMessage> mapNewObj) {
        
        if (!listNewObj.isEmpty()) {
            //Se obtienen las extensiones permitidas para un anexo
            List<String> extensionesPermitidas = new List<String>();
            for (CC_ConfiguracionAnexoPermitido__mdt extensionPermitida : [SELECT CC_Extension__c FROM CC_ConfiguracionAnexoPermitido__mdt]) {
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
                                                                WHERE ContentDocument.FileExtension NOT IN :extensionesPermitidas
                                                                AND LinkedEntityId IN :correosSalientes]) {
                    EmailMessage correoSalienteConAnexoProhibido = mapNewObj.get(contentDocumentLink.LinkedEntityId);
                    correoSalienteConAnexoProhibido.addError('El correo tiene un adjunto con una extensión no petmitida.');
                }
            }
        }
    }

    private static void validarBuzonSalida(List<EmailMessage> listNewObj) {
        if (!listNewObj.isEmpty()) {
            //Se obtiene de CC_Buzones_Por_Defecto__mdt la lista de buzones de salida válidos
            List<String> buzonesSalidaValidos = new List<String>();
            for (CC_Buzones_Por_Defecto__mdt buzonPorDefecto : [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt]) {
                buzonesSalidaValidos.add(buzonPorDefecto.CC_Direccion_Correo__c);
            }

            //Si el correo saliente tiene un buzón de salida que no está en la lista, se muestra un error
            for (EmailMessage correo : listNewObj) {
                if (!correo.Incoming && String.isNotEmpty(correo.FromAddress) && !buzonesSalidaValidos.contains(correo.FromAddress)) {
                    correo.addError('El buzón de salida indicado no es apto para el envío de correos.', false);
                }
            }
        }
    }
}