public with sharing class CC_EmailMessage_AI_TRHan extends CC_TriggerHandlerBase {
    private static String handlerClass = 'CC_EmailMessage_AI_TRHan';
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
            Map<Id, EmailMessage> mapaCorreos = new Map<Id, EmailMessage>();
            for (EmailMessage correo : correos) {
                mapaCorreos.put(correo.Id, correo);
            }
            
            Set<Id> idCasosCc = new Set<Id>();
            //Hemos quitado el filtro de SAC ya que los casos derivados no se procesaban las respuetas
            for (Case casoCc : [SELECT Id FROM Case WHERE Id IN :idsPadre AND RecordType.DeveloperName LIKE 'CC_%']) {
                idCasosCc.add(casoCc.Id);
            }
            
            if(!idCasosCc.isEmpty()){
                for (EmailMessage correo : correos) { 
                    if (idCasosCc.contains(correo.ParentId) || idCasosCc.contains(correo.RelatedToId)) {
                        correosCc.add(mapaCorreos.get(correo.Id));
                    } 
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
        
        List<Case> listCasoCorreo = [SELECT Id, Origin, Status, OwnerId, ContactId, Subject, RecordTypeId  FROM Case WHERE Id IN :idsCasos];
        Map<Id, Case> mapIdCaso = new Map<Id, Case>();
        for (Case caso : listCasoCorreo) {
            mapIdCaso.put(caso.Id, caso);
        }

        if (!referencias.isEmpty()){
            List<Task> tareasOrigen = [SELECT Type, WhatId FROM Task WHERE WhatId IN :idsCasos AND CC_Referencia_Correo_Saliente__c IN :referencias AND (RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task')) ];
            for (Task tarea : tareasOrigen) {
                mapaTipoTareaDelCorreo.put(tarea.WhatId, tarea.Type);
            }
        }
        
        //US477729*********************
        String htmlBody = '';
        if(!correosCc.isEmpty()){
            htmlBody = [SELECT DeveloperName, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'Respuesta_automatica_cliente_Castellano_Caso_Email_Revisar' LIMIT 1].HtmlValue;
        }
        Map <String,OrgWideEmailAddress> owasMap = new Map<String,OrgWideEmailAddress>();
        List<Case> casesEmailRevisar = new List <Case>();
        List<CC_Buzones_Por_Defecto__mdt> owaPorDefecto = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE CC_Canal_Procedencia__c = 'Por defecto' AND CC_Idioma__c = 'Castellano' AND CC_Activo__c = true LIMIT 1];
        //*****************************
        
        //USUS598485*******************
        Map <Id,CC_Lista_Valores__c> mapaValores = new Map<Id,CC_Lista_Valores__c>();
        Set<Id> idsCasosSpam = new Set<Id>();
        
        if(!correosCc.isEmpty()){
            for(CC_Lista_Valores__c valor : [SELECT Id, Name, CC_Valor__c, CC_Valor_SFDC__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name  = 'CC_Casos_Spam' 
            AND (CC_Valor_SFDC__c = 'Asunto' OR CC_Valor_SFDC__c = 'Dominio')]){
                
                mapaValores.put(valor.Id, valor);
            }
        }
        //*****************************/
        
        for (OrgWideEmailAddress owa : [SELECT Id, Address FROM OrgWideEmailAddress]) {
            owasMap.put(String.valueOf(owa.Address), owa);
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
                        
                        //US477729 -- USUS598485
                        Case caso = mapIdCaso.get(correo.ParentId);
                        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
                        //US477729
                        //Si el caso es creado con el valor 'Email - Revisar' en el campo Origin, enviaremos un correo automático y actualizaremos el Status del caso a 'Rechazado'
                        if(caso.Origin == 'Email - Revisar' && caso.RecordTypeId == rtCliente){
                            List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
                            List<OrgWideEmailAddress> owa = new List<OrgWideEmailAddress>();
                            String emailCorreoEntrante;
                            
                            
                            if(correo.ToAddress.contains(';')){
                                List<String> emailAddress = correo.ToAddress.split('; ');
                                for(String email : emailAddress){
                                    if(owasMap.containsKey(email)){
                                        emailCorreoEntrante = email;
                                    }
                                }
                            } else {
                                if(owasMap.containsKey(correo.ToAddress)){
                                    emailCorreoEntrante = correo.ToAddress;
                                }
                            }
                            
                            if(emailCorreoEntrante == null){
                                emailCorreoEntrante = owaPorDefecto[0].CC_Direccion_Correo__c;
                            }

                                owa.add(owasMap.get(emailCorreoEntrante));

                                
                                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                                //Falta que nos pasen la plantilla                                
                                email.setHtmlBody(htmlBody + '<br/>__________<br/><br/>');                            
                                email.subject = 'Respuesta Automática';
                                email.setSaveAsActivity(true);
                                email.setWhatId(caso.Id);
                                email.setTargetObjectId(caso.ContactId);
                                email.setTreatTargetObjectAsRecipient(false);
                                email.setOrgWideEmailAddressId(owa[0].Id);
                            
                                List<String> toAddress = new List<String>();
                                toAddress.add(correo.FromAddress);
                                email.setToAddresses(toAddress);
                                allmsg.add(email);
                                
                                List<Object> listError = new List<Object>();
                                
                                if (!allmsg.isEmpty()) {
                                  
                                    for (Messaging.SendEmailResult sr : Messaging.sendEmail(allmsg, false)) {
                                        if (!sr.isSuccess()) {
                                            for (Database.Error err : sr.getErrors()) {
                                                listError.add(err);
                                            }
                                        }
                                    }
                                }

                                if(!listError.isEmpty()){
                                    CBK_Log.error('Fallo el envio de mails' + listError);
                                }
                            
                            caso.Status = 'Rechazado';
                            casesEmailRevisar.add(caso);
                        }
                        
                        //USUS598485
                        if(!casesEmailRevisar.contains(caso) && caso.RecordTypeId == rtCliente){
                            
                            for(Id key : mapaValores.keySet()){
                                if(mapaValores.get(key).CC_Valor_SFDC__c == 'Asunto' && caso.Subject != null){
                                    if(caso.Subject.contains(mapaValores.get(key).CC_Valor__c)){
                                        idsCasosSpam.add(caso.Id);
                                    }
                                } else {
                                    if(String.valueOf(correo.FromAddress) == (mapaValores.get(key).CC_Valor__c)){
                                        idsCasosSpam.add(caso.Id);
                                    }
                                }
                            } 
                        } 
                        
                    }                
                }
            } //Fin "for (EmailMessage correo : newList)"
        }
        //US477729
        update casesEmailRevisar;
        //USUS598485
        if(!idsCasosSpam.isEmpty()){
            updateCasosSpam(idsCasosSpam);
        }
        
        //Ejecución de las actualizaciones de caso
        if(Schema.sObjectType.Case.fields.Status.isUpdateable()){
            update casos;
        }
        
        //Ejecución de las inserciones de las nuevas actividades de traslado
        if (!actividadesTraslado.isEmpty()) {
            //insert actividadesTraslado;
            CC_Activity.crearActividades(actividadesTraslado);
        }
        
        List<Id> idActividesCorreo = new List<Id>();
        for (EmailMessage correo : correosCc) {
            //Actualización de las actividades existentes de correo para relacionarlas con las de traslado
            idActividesCorreo.add(correo.ActivityId);
        }
        //TODO: REVISAR QUE HACE ESTO
        //Actualización de las actividades existentes de correo para relacionarlas con las de traslado
        /*List<Task> actividadesCorreo = [SELECT CC_Actividad_Relacionada_Id__c FROM Task WHERE Id IN :idActividesCorreo];
        
        for (Task actividadCorreo : actividadesCorreo) {
            //actividadCorreo.Type = .Incoming ? 'Correo - Entrante' : 'Correo - Saliente';
            actividadCorreo.CC_Actividad_Relacionada_Id__c = actividadesTraslado.get(relacionActividades.get(actividadCorreo.Id)).Id;
        }
        update actividadesCorreo;*/
    }
    
    @future
    public static void updateCasosSpam(Set<Id> idsCasos){
        
        List <Case> casosRechazadosUpdate= new List<Case>(); 
        
        for(Case caso : [SELECT Id, Status FROM Case WHERE Id IN: idsCasos]){
            caso.CC_Rechazado_No_Tabulado__c = TRUE;
            caso.Status = 'Rechazado';
            casosRechazadosUpdate.add(caso);
        }
        update casosRechazadosUpdate;
    }
    
    private List<EmailMessage> filtrarEmailMessageNoCC(List<EmailMessage> listNewObj) {
        
        List<EmailMessage> newList = new List<EmailMessage> ();
        for (EmailMessage emailMessage : listNewObj) {
            if ((emailMessage.RelatedToId != null && OT_Proyectos.registroProyecto(emailMessage.RelatedToId) == 'CC') || (emailMessage.ParentId != null && OT_Proyectos.registroProyecto(emailMessage.ParentId) == 'CC')) {
                newList.add(emailMessage);
            }
        }
        return newList;
    }
    
    private static void envioTrasladoColaborador(EmailMessage correo, List<Case> casos, List<Task> actividadesTraslado) {
        //Cambio de estado del caso

        Case caso = [SELECT CC_Canal_Procedencia__C, CC_Referencia_Correo_Saliente__c, CC_Cambio_Estado_Pendiente_Externo__c, Status, Origin,
        CC_Fecha_1a_Respuesta_Twitter__c, CC_Fecha_Respuesta_Stores__c, Id, CC_MCC_Plantilla__c, CC_MCC_Tematica__r.Name, CC_Grupo_Colaborador__c, CC_Canal_Resolucion__c, CC_Idioma__c, Contact.Email, ContactId, CC_Buzon_Salida__c, CC_MailTelfNotif__c, RecordTypeId FROM Case WHERE Id = :correo.ParentId ];
        //caso.CC_Cambio_Estado_Pendiente_Externo__c = true;
        caso.Status = 'Pendiente Colaborador';
        caso.CC_Fecha_Traslado_Colaborador__c = Datetime.valueOf(System.now());
        //Si es Twitter o Stores informamos fecha respuesta para SLA reports, cuenta como gestión
        if (caso.Origin == 'Twitter' && caso.CC_Fecha_1a_Respuesta_Twitter__c == null) {
            caso.CC_Fecha_1a_Respuesta_Twitter__c = Datetime.valueOf(System.now());
        } else if (caso.Origin == 'Comentarios Stores') {
            if (caso.CC_Fecha_Respuesta_Stores__c == null) {
                caso.CC_Fecha_Respuesta_Stores__c = Datetime.valueOf(System.now());
            }
        }
        
        if(String.isNotEmpty(correo.CC_Segunda_Oficina__c)){
            Task actividadTraslado2 = new Task();
            actividadTraslado2.Type = 'Traslado Colaborador Segunda Oficina';
            actividadTraslado2.Subject = 'Traslado Colaborador Segunda Oficina';
            actividadTraslado2.WhatId = correo.ParentId;
            actividadTraslado2.Status = 'Completed';
            actividadTraslado2.Description = 'Traslado Colaborador a la segunda oficina: '+correo.CC_Segunda_Oficina__c;
            actividadTraslado2.CC_Correo_Asociado_Id__c = correo.Id;
            actividadTraslado2.RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
            actividadesTraslado.add(actividadTraslado2);
        }
        
        //Nueva actividad de tipo "Trasladar Colaborador"
        Task actividadTraslado = new Task();
        actividadTraslado.Type = 'Traslado Colaborador';
        actividadTraslado.Subject = 'Traslado Colaborador';
        actividadTraslado.WhatId = correo.ParentId;
        actividadTraslado.Status = 'Open';
        actividadTraslado.Description = correo.TextBody.left(32000);
        actividadTraslado.CC_Referencia_Correo_Saliente__c = caso.CC_Referencia_Correo_Saliente__c;
        actividadTraslado.RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
        List<CC_Grupo_Colaborador__c> grupos = [SELECT Id, Name FROM CC_Grupo_Colaborador__c WHERE Name = :correo.CC_Grupo_Colab__c];
        List<Contact> empleadosLst = new List<Contact>();
        if(!grupos.isEmpty()){
            actividadTraslado.CC_Grupo_Colaborador_Id__c = grupos[0].Id;
            CC_Activity.informarFechaVencimientoSLA('Grupo colaborador', correo.CC_Grupo_Colab__c, actividadTraslado);
            CC_Configuracion_Reclamaciones_Auto.informarFechasReclamacionesAuto(actividadTraslado);
        }else{
            empleadosLst = [FIND :correo.CC_Grupo_Colab__c RETURNING Contact (Id, Name WHERE RecordType.DeveloperName = 'CC_Empleado' AND CC_Inactivo__c = false LIMIT 1)][0];
            if(!empleadosLst.isEmpty()){
                actividadTraslado.CC_Empleado_Gestor__c = empleadosLst[0].Id;
            } 
        }
        
        actividadTraslado.CC_Correo_Asociado_Id__c = correo.Id;
        insert actividadTraslado;
        //actividadesTraslado.add(actividadTraslado);
        
        CBK_Activity_Extension__c tareaExtension = new CBK_Activity_Extension__c();
        tareaExtension.AV_ActivityId__c = actividadTraslado.Id;
        if (!grupos.isEmpty()) {
            tareaExtension.CC_Grupo_Colaborador_Name__c = grupos[0].Name;
        }
        insert tareaExtension;
        
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
        
        //Correo automático de información para el contacto en caso de tener canal de resolución de Wivai
        if (caso.CC_Buzon_Salida__c != null && caso.Contact.Email != null && (caso.CC_Canal_Resolucion__c == 'Postventa CompraEstrella' || caso.CC_Canal_Resolucion__c == 'Soporte Clientes CompraEstrella' || caso.CC_Canal_Resolucion__c == 'Soporte Empleados CompraEstrella' 
        || (caso.CC_Canal_Resolucion__c == 'Marketing'  && caso.CC_Canal_Procedencia__c != 'Formulario Consultas Operativas' && 
            (caso.CC_MCC_Tematica__r.Name.contains('Wivai')|| caso.CC_MCC_Tematica__r.Name.contains('Facilitea')))))
        {  enviarCorreoAutomaticoConfirmacionTrasladoWivai (caso); }
        if (caso.CC_Buzon_Salida__c != null && caso.CC_MailTelfNotif__c != null && caso.CC_Canal_Procedencia__c == 'Formulario Consultas Operativas'){  
            enviarCorreoAutomaticoTrasladoFormularioConsultasOperativas(caso);
        }
        
    }
    
    private static void respuestaTrasladoColaborador(EmailMessage correo, List<Case> casos) {
        //Cambio de estado del caso
        Case caso = [SELECT Status, Subject, CC_Canal_Procedencia__c, Origin, CC_Autoasignado_Coordinador__c, CC_Cola_Procedencia__c, 
        CC_En_Tercer_Nivel__c, CC_Grupo_3N__c, OwnerId, CC_Fecha_Traslado_Colaborador__c FROM Case WHERE Id = :correo.ParentId ];
        Boolean propietario = true;
        if (caso.Status == 'Pendiente Colaborador') {
            caso.CC_Ultima_Interaccion__c = 'Respuesta de colaborador';
            caso.CC_Fecha_Ultima_Interaccion__c = System.now();
            caso.CC_Situacion_Caso__c = 'Respuesta colaborador';
            
            /* 
             *  COMENTAMOS ESTE DESARROLLO YA QUE NO FUNCIONA       
            List <CC_Lista_Valores__c> listaFestivos = [SELECT CC_Valor__c, CC_Valor2__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'Festivos nacionales' AND CC_Activa__c = true ORDER BY CC_Valor2__c];
            Integer horasTotales = Integer.valueOf((System.now().getTime() - caso.CC_Fecha_Traslado_Colaborador__c.getTime())/(1000*60*60));
            Datetime startDate = caso.CC_Fecha_Traslado_Colaborador__c;
            Datetime endDate = DateTime.now();
            Integer actualYear = System.Today().year();
            
            while (startDate < endDate) {
                for(CC_Lista_Valores__c posibleFestivo : listaFestivos){

                    DateTime valorFestivo = Datetime.newInstance(actualYear, Integer.valueof(posibleFestivo.CC_Valor2__c), Integer.valueof(posibleFestivo.CC_Valor__c));
                    if (startDate == valorFestivo) {
                        if (!startDate.format('EEEE').startsWith('Sat') || !startDate.format('EEEE').startsWith('Sun')) {
                            horasTotales = horasTotales - 24;
                        }
                    }
                }
                
                if (startDate.format('EEEE').startsWith('Sat') || startDate.format('EEEE').startsWith('Sun')) {
                    horasTotales = horasTotales - 24;
                }
                startDate = startDate.addDays(1);
            }
            caso.CC_Tiempo_Respuesta__c = String.valueOf(horasTotales);
			*/
			
			Map <Id, Case> casosCambiar = new Map <Id, Case>();
			Map <Id, Datetime> casosFecha = new Map <Id, Datetime>();

			casosFecha.put(caso.Id, caso.CC_Fecha_Traslado_Colaborador__c);

			List<Case> casosSLACumplido = new List <Case>();

			//Map para tener el nombre de la lista de valores con sus valores
            Map<String, Map<String, List <Time>>> horariosPorCanalProcedencia = new Map<String, Map<String, List <Time>>> ();
            horariosPorCanalProcedencia = CC_MetodosUtiles.horariosPorCanalProcedencia();

			Map<Integer, List<Integer>> festivosPorMesMap = new Map<Integer, List<Integer>> ();
            festivosPorMesMap = CC_MetodosUtiles.sacarFestivosPorMes();
			
			Double horasSLATraslado = 0;
            if(caso != null){
               
					//horariosPorCanalProcedencia ----->
                    horasSLATraslado = calcularHoras(correo, caso, festivosPorMesMap);
                    caso.CC_Tiempo_Respuesta__c = horasSLATraslado.toString();
            }

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
                if (propietario && caso.Origin == 'Email' && caso.CC_Canal_Procedencia__c == 'Atención al Cliente') {
                    List<Task> tareasReasignacion = [SELECT Subject FROM TASK WHERE WhatId = :caso.Id AND Type = 'Reasignación' AND Status = 'Completed' AND Subject != NULL  ORDER BY CreatedDate DESC];
                    if (!tareasReasignacion.isEmpty()) {
                        for (Task tarea : tareasReasignacion) {
                            tarea.Subject = 'Reasignación del caso a ' + caso.CC_Cola_Procedencia__c;
                        }
                    }
                }
                if (propietario) {
                    /*if (caso.CC_Canal_Procedencia__c == 'Formulario Consultas Operativas' && caso.CC_Grupo_Transfer__c != null) {
                        caso.OwnerId = caso.CC_Grupo_Transfer__c;
                    } else {*/
                        if(caso.CC_Canal_Procedencia__c != 'Formulario Consultas Operativas'){
                            List<Group> grupoList = [SELECT Id FROM Group WHERE DeveloperName = :caso.CC_Cola_Procedencia__c and type = 'Queue' LIMIT 1];
                            if (!grupoList.isEmpty())
                            {
                                caso.OwnerId = grupoList[0].Id;
                            }
                        }
                    //}
                    
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
            //if (caso.Origin == 'Comentarios Stores') {
                caso.CC_Fecha_Respuesta_Colaborador__c = Datetime.valueOf(System.now());
            //}
            casos.add(caso);
            
            //Cierre de la actividad de envío del traslado a grupo colaborador
            CC_Activity.finalizarActividadCaso(correo.ParentId, 'Traslado Colaborador', null, null);
            
            //Creamos la baja del aviso para TRZ
            CC_Trazabilidad_Methods.bajaAviso('A', 'AVISPDTEOFI', caso.Id);
        }
    }
    
    private static void envioResponderCliente(EmailMessage correo, List<Case> casos, List<Task> actividadesTraslado) {
        Case caso = [SELECT CC_Referencia_Correo_Saliente__c,  CC_MCC_Plantilla__c, Status FROM Case WHERE Id = :correo.ParentId ];
        
        Task actividadTraslado = new Task();
        actividadTraslado.Type = 'Responder a cliente';
        actividadTraslado.Subject = 'Responder a cliente';
        actividadTraslado.WhatId = correo.ParentId;
        actividadTraslado.Subject = correo.Subject;
        actividadTraslado.Description = correo.TextBody.left(32000);
        actividadTraslado.Status = 'Completed';
        actividadTraslado.CC_Referencia_Correo_Saliente__c = caso.CC_Referencia_Correo_Saliente__c;
        actividadTraslado.CC_Correo_Asociado_Id__c = correo.Id;
        actividadTraslado.RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
        actividadesTraslado.add(actividadTraslado);
        
        caso.CC_Referencia_Correo_Saliente__c = '';
        casos.add(caso);
    }
    
    private static void envioRemitirColaborador(EmailMessage correo, List<Case> casos, List<Task> actividadesTraslado) {
        
        Case caso = [SELECT Id, CC_Referencia_Correo_Saliente__c, CC_MCC_Plantilla__c, CC_Grupo_Colaborador__c, Status, CC_Canal_Procedencia__c, CC_Canal_Resolucion__c, ContactId, ContactEmail, CC_Idioma__c FROM Case WHERE Id = :correo.ParentId ];
        
        if(String.isNotEmpty(correo.CC_Segunda_Oficina__c)){
            Task actividadTraslado2 = new Task();
            actividadTraslado2.Type = 'Remitir Colaborador Segunda Oficina';
            actividadTraslado2.Subject = 'Remitir Colaborador Segunda Oficina';
            actividadTraslado2.WhatId = correo.ParentId;
            actividadTraslado2.Status = 'Completed';
            actividadTraslado2.Description = 'Remitir Colaborador a la segunda oficina: '+correo.CC_Segunda_Oficina__c ;
            actividadTraslado2.CC_Correo_Asociado_Id__c = correo.Id;
            actividadTraslado2.RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
            actividadesTraslado.add(actividadTraslado2);
        }
        Task actividadTraslado = new Task();
        actividadTraslado.Type = 'Remitir Colaborador';
        actividadTraslado.Subject = 'Remitir Colaborador';
        actividadTraslado.WhatId = correo.ParentId;
        actividadTraslado.Subject = correo.CC_Procedencia__c;
        actividadTraslado.RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
        List<CC_Grupo_Colaborador__c> grupos = [SELECT Id, Name FROM CC_Grupo_Colaborador__c WHERE Name = :correo.CC_Grupo_Colab__c];
        List<Contact> empleadosLst = new List<Contact>();
        if(!grupos.isEmpty()){
            actividadTraslado.CC_Grupo_Colaborador_Id__c = grupos[0].Id;
        }else{
            empleadosLst = [FIND :correo.CC_Grupo_Colab__c RETURNING Contact (Id, Name WHERE RecordType.DeveloperName = 'CC_Empleado' AND CC_Inactivo__c = false LIMIT 1)][0];
            if(!empleadosLst.isEmpty()){
                actividadTraslado.CC_Empleado_Gestor__c = empleadosLst[0].Id;
            } 
        }
        actividadTraslado.Description = correo.TextBody.left(32000);
        actividadTraslado.Status = 'Completed';
        actividadTraslado.CC_Referencia_Correo_Saliente__c = caso.CC_Referencia_Correo_Saliente__c;
        actividadTraslado.CC_Correo_Asociado_Id__c = correo.Id;
        insert actividadTraslado;
        //actividadesTraslado.add(actividadTraslado);

        CBK_Activity_Extension__c tareaExtension = new CBK_Activity_Extension__c();
        tareaExtension.AV_ActivityId__c = actividadTraslado.Id;
        if (!grupos.isEmpty()) {
            tareaExtension.CC_Grupo_Colaborador_Name__c = grupos[0].Name;
        }
        insert tareaExtension;
        
        if (caso.CC_Canal_Procedencia__c == 'Formulario Consultas Operativas') {
            List<CC_Buzones_Por_Defecto__mdt> buzonDefault = new List<CC_Buzones_Por_Defecto__mdt>();
            if(caso.CC_Canal_Resolucion__c !=null){
                if (caso.CC_Idioma__c == 'ca' ) {
                    buzonDefault = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE CC_Canal_Procedencia__c = :caso.CC_Canal_Resolucion__c AND CC_Activo__c = true AND CC_Idioma__c = 'Català'];
                } else {
                    buzonDefault = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE CC_Canal_Procedencia__c = :caso.CC_Canal_Resolucion__c AND CC_Activo__c = true AND CC_Idioma__c = 'Castellano'];
                    
                }
            }
            
            //Si el buzón está vacío usamos el por defecto
            if (buzonDefault.isEmpty())
            {
                buzonDefault  = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt
                WHERE CC_Canal_Procedencia__c = 'Por defecto empleados' AND CC_Idioma__c = 'Castellano'
                AND CC_Activo__c = true ];
            }

            //Solo se envía en caso de que haya alguna dirección
            if (!buzonDefault.isEmpty())
            {
                OrgWideEmailAddress oweaid = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :buzonDefault[0].CC_Direccion_Correo__c ];
                List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
                String titulo;
                Id idEmailTemplate;
                if (caso.CC_Idioma__c == 'ca') {
                    idEmailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Remitido_a_Colaborador_CAT_Formulario' LIMIT 1].Id;
                    titulo = 'Resposta Automàtica';

                } else {
                    idEmailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Remitido_a_Colaborador_ES_Formulario' LIMIT 1].Id;
                    titulo = 'Respuesta Automática';
                }
                
                Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(idEmailTemplate, caso.ContactId, caso.Id);
                email.subject = titulo;
                email.setSaveAsActivity(true);
                email.setWhatId(caso.Id);
                email.setTargetObjectId(caso.ContactId);
                email.setTreatTargetObjectAsRecipient(false);
                email.setOrgWideEmailAddressId(oweaid.Id);
                email.setToAddresses(new String[] {caso.ContactEmail});
                allmsg.add(email);
                Messaging.sendEmail(allmsg, false);
            }
        }

        caso.CC_Referencia_Correo_Saliente__c = '';
        caso.CC_Grupo_Colaborador__c = correo.CC_Grupo_Colab__c;
        casos.add(caso);
    }
    
    private static void respuestaRemitirColaborador(EmailMessage correo, List<Case> casos) {
        
        //Cambio de estado del caso
        Case caso = [SELECT Status, CC_Fecha_Traslado_Colaborador__c, CC_Tiempo_Respuesta__c FROM Case WHERE Id = :correo.ParentId  LIMIT 1];
        if (caso.Status == 'Pendiente Colaborador') {
            caso.Status = 'Activo';
            caso.CC_Tiempo_Respuesta__c = String.valueOf(Integer.valueOf((System.now().getTime() - caso.CC_Fecha_Traslado_Colaborador__c.getTime())/(1000*60*60)));
            casos.add(caso);
            
            //Cierre de la actividad de envío del traslado a grupo colaborador
            CC_Activity.finalizarActividadCaso(correo.ParentId, 'Remitir Colaborador', null, null);
        }
    }
    
    private static void envioSolicitudInfo(EmailMessage correo, List<Case> casos, List<Task> actividadesTraslado) {
        //Recuperamos el plazo que tendrá cliente/empleado para responder al mail de Sol. Inf. para asignarlo al caso y tarea
        //Posteriormente habrá un PB que cerrará el caso y enviará un mail en el momento que cumpla el plazo
        Datetime fechaFinPlazo = CC_Cierre_Automatico_Methods.CC_Cierre_Automatico_SolicitudInformacion(correo.ParentId);
        
        //Cambio de estado del caso
        Case caso = [SELECT CC_Referencia_Correo_Saliente__c, CC_MCC_Plantilla__c, Status FROM Case WHERE Id = :correo.ParentId ];
        caso.Status = 'Pendiente Cliente';
        caso.CC_Fecha_Cierre_SolInf__c = fechaFinPlazo;
        caso.CC_Fecha_Solicitud_Informacion__c = System.today();
        
        //Nueva actividad de tipo "Solicitud Información"
        Task actividadTraslado = new Task();
        actividadTraslado.Type = 'Solicitud Información';
        actividadTraslado.Subject = 'Solicitud Información';
        actividadTraslado.WhatId = correo.ParentId;
        actividadTraslado.CC_Fecha_FinPlazo_SolInf__c = fechaFinPlazo;
        actividadTraslado.Status = 'Open';
        actividadTraslado.Description = correo.TextBody.left(32000);
        actividadTraslado.CC_Referencia_Correo_Saliente__c = caso.CC_Referencia_Correo_Saliente__c;
        actividadTraslado.RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
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
        CC_En_Tercer_Nivel__c, CC_Grupo_3N__c, OwnerId, CC_Grupo_Transfer__c FROM Case WHERE Id = :correo.ParentId ];
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
            /*if (caso.CC_Canal_Procedencia__c == 'Formulario Consultas Operativas' && caso.CC_Grupo_Transfer__c != null) {
                caso.OwnerId = caso.CC_Grupo_Transfer__c;
            } else {*/
            if (caso.CC_Canal_Procedencia__c != 'Formulario Consultas Operativas' && !caso.CC_Autoasignado_Coordinador__c && caso.CC_Cola_Procedencia__c != null && canviarPropietario) {
                List<Group> grupoList = [SELECT Id FROM Group WHERE DeveloperName = :caso.CC_Cola_Procedencia__c and type = 'Queue' LIMIT 1];
                if (!grupoList.isEmpty())
                {
                    caso.OwnerId = grupoList[0].Id;
                }
            }
            //}
            
            //Controlamos cuando se hace la devolución y se pone Activo para report de FormWeb.
            if (caso.CC_Canal_Procedencia__c == 'Formulario web' || caso.CC_Canal_Procedencia__c == 'Caixabank Talks') {
                caso.CC_Fecha_Activo_Formulario__c = Datetime.valueOf(System.now());
            }
            casos.add(caso);
            
            //Cierre de la actividad de envío del traslado a grupo colaborador
            CC_Activity.finalizarActividadCaso(correo.ParentId, 'Solicitud Información', null, null);
            
        } else if (caso.Status == 'Cerrado') {
            //Para solicitudes info se reabre el caso aunque se hubiera cerrado
            CC_Case.reapertura(caso.Id, correo.TextBody.left(32000));
        }
        
        //Creamos la baja del aviso para TRZ
        CC_Trazabilidad_Methods.bajaAviso('I', 'AVISPDTECLI', caso.Id);
    }
    
    public static void respuestaCliente(EmailMessage correo, List<Case> casos) {
        //Cuando un cliente responde a un email enviado desde la operativa reponder a cliente se envía un email automático
        Case caso = [SELECT Status, CC_Numero_Documento__c, CC_Idioma__c, AccountId, ContactId, OwnerId, CC_Canal_Resolucion__c, CC_Canal_Procedencia__c, CC_Autoasignado_Coordinador__c,
        Origin,CC_Cola_Procedencia__c, RecordTypeId, Canal_del_Empleado__c FROM Case WHERE Id = :correo.ParentId ];
        Set<String> oLOVVal = new Set<String>();
        Set<String> oLOV = new Set<String>();
        
        if (caso.Status == 'Cerrado' && Schema.SObjectType.Case.getRecordTypeInfosById().get(caso.RecordTypeId).getDeveloperName() == 'CC_Empleado' &&
        (caso.Origin == 'Chat' || (caso.Origin == 'Email' && caso.CC_Canal_Procedencia__c == 'Formulario Consultas Operativas'))) {
            String lov = '';
            if(caso.Origin == 'Chat'){
                lov='CC_Respuesta_a_empleado';
            }
            else if(caso.Origin == 'Email' && caso.CC_Canal_Procedencia__c == 'Formulario Consultas Operativas'){
                lov = 'CC_Respuesta_a_empleado_form';
            }
            if(lov != ''){
                oLOV.add(lov);
                oLOVVal.add(caso.CC_Canal_Resolucion__c);
                Map<String,Object> respuestaEmp = CC_MetodosUtiles.getLOVWithVal(oLOV,oLOVVal); 
                List<Group> lstRespuestas = new List<Group>();
                if(!respuestaEmp.isEmpty()){
                    Map <String,String> valRespEmp = (Map <String,String>)respuestaEmp.get(lov);
                    lstRespuestas = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = :valRespEmp.get(caso.CC_Canal_Resolucion__c) LIMIT 1];
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
            
            // Comprobar si el caso es de cliente o empleado
            if (caso.CC_Canal_Procedencia__c == 'Soporte Empleados CompraEstrella') {
                if (caso.CC_Idioma__c == 'ca') {
                    htmlBody = [SELECT DeveloperName, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'CC_Respuesta_Automatica_Promocaixa_Empleado_ca' LIMIT 1].HtmlValue;
                } else {
                    htmlBody = [SELECT DeveloperName, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'CC_Respuesta_Automatica_Promocaixa_Empleado_es' LIMIT 1].HtmlValue;
                }
            } else if (caso.Canal_del_Empleado__c != null && caso.Canal_del_Empleado__c.equalsIgnoreCase('CSI')) {
                htmlBody = [SELECT DeveloperName, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'CC_Respuesta_automatica_CSI_Bankia_Castellano' LIMIT 1].HtmlValue;
            } else {
                if (caso.CC_Idioma__c == 'en') {
                    htmlBody = [SELECT DeveloperName, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'CC_Respuesta_Automatica_Cliente_en'  LIMIT 1].HtmlValue;
                } else if (caso.CC_Idioma__c == 'ca') {
                    htmlBody = [SELECT DeveloperName, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'CC_Respuesta_Automatica_Cliente_ca'  LIMIT 1].HtmlValue;
                } else {
                    htmlBody = [SELECT DeveloperName, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'CC_Respuesta_Automatica_Cliente_es'  LIMIT 1].HtmlValue;
                }
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
                        //en el caso de ser cierto assignar el owa.Id de OrgWideEmailAddress en cuestion
                        owa = owaAccionistas;
                    }
                }
                
                //Comprobar que el canal de procedencia es de tipo promocaixa empleado
            } else if (owa.isEmpty() && caso.CC_Canal_Procedencia__c == 'Soporte Empleados CompraEstrella') {
                List<OrgWideEmailAddress> owaEmpleados = [SELECT DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = 'Atención Oficinas Facilitea'  LIMIT 1];
                List<CC_Valores__mdt> listaValoresCorreos = [SELECT CC_Valor_SFDC__c, CC_Valor__c, CC_Lista__c  FROM CC_Valores__mdt
                WHERE CC_Lista__c = 'promocaixaEmpleados' ];
                for (CC_Valores__mdt listaCorreo : listaValoresCorreos) {
                    if (listaCorreo.CC_Valor_SFDC__c == correo.ToAddress || listaCorreo.CC_Valor__c == correo.ToAddress) {
                        owa = owaEmpleados;
                    }
                }            
                
            } else if (owa.isEmpty() && caso.CC_Canal_Procedencia__c == 'Soporte Clientes CompraEstrella') {
                List<OrgWideEmailAddress> owaClientes = [SELECT DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = 'Atención Clientes Facilitea'  LIMIT 1];
                List<CC_Valores__mdt> listaValoresCorreos = [SELECT CC_Valor_SFDC__c, CC_Valor__c, CC_Lista__c  FROM CC_Valores__mdt
                WHERE CC_Lista__c = 'promocaixaClientes' ];
                
                for (CC_Valores__mdt listaCorreo : listaValoresCorreos) {
                    if (listaCorreo.CC_Valor_SFDC__c == correo.ToAddress || listaCorreo.CC_Valor__c == correo.ToAddress) {
                        owa = owaClientes;
                    }
                }
                //Preventiva
            }else if (owa.isEmpty() && caso.CC_Canal_Procedencia__c == 'Oficina Preventiva'){
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
            
            List<Object> listError = new List<Object>();
            //Enviamos todos los mensajes
            if (!allmsg.isEmpty()) {
                for (Messaging.SendEmailResult sr : Messaging.sendEmail(allmsg, false)) {
                    if (!sr.isSuccess()) {
                        for (Database.Error err : sr.getErrors()) {
                            listError.add(err);
                        }
                    }
                }
            }
            if(!listError.isEmpty()){
                CBK_Log.debug('Fallo el envio de mails' + listError);
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
    
    private static void enviarCorreoAutomaticoConfirmacionTrasladoWivai(Case casoTras){
        
        String recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosById().get(casoTras.RecordTypeId).getDeveloperName();
        EmailTemplate plantilla = new EmailTemplate ();   
        
        //escogemos plantilla segun idioma y RecordType
        if (casoTras.CC_Idioma__c != 'ca' && recordTypeCaso.equals('CC_Cliente') ){
            plantilla = [SELECT Id, Subject FROM EmailTemplate WHERE DeveloperName = 'CC_Notificacion_Traslado_Cliente_Wivai_ES' ];
        }
        else{  
            if (recordTypeCaso.equals('CC_Cliente') ){ 
                plantilla = [SELECT Id, Subject FROM EmailTemplate WHERE DeveloperName = 'CC_Notificacion_Traslado_Cliente_Wivai_CA' ]; 
            }
            else {
                if(casoTras.CC_Idioma__c != 'ca' && recordTypeCaso.equals('CC_Empleado')  ){
                    plantilla = [SELECT Id, Subject FROM EmailTemplate WHERE DeveloperName = 'CC_Notificacion_Traslado_Empleado_Wivai_ES' ];
                }
                else {
                    if (recordTypeCaso.equals('CC_Empleado')){
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
            }catch(exception e){
                CBK_Log.error('Resultado error: ' + e);
            }
            
        }           
        
    }
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
                //CBK_Log.debug('Resultado: ' + result);
                
            }catch(exception e){
                String exc = e.getMessage();
                CBK_Log.error(e + '-' + exc);
                CBK_Log.error('Resultado error: ' + e);
            }
        }
    }
    
    //FechaRespuesta = correo.createdDate
 	private static Double calcularHoras (EmailMessage correo, case caso, Map<Integer, List<Integer>> festivos){
        
        //Map para tener el nombre de la lista de valores con sus valores
        Map<String, Map<String, List <Time>>> horariosPorCanalProcedencia = new Map<String, Map<String, List <Time>>> ();
        horariosPorCanalProcedencia = CC_MetodosUtiles.horariosPorCanalProcedencia();
        Map<String, List <Time>> horario = horariosPorCanalProcedencia.get(caso.CC_Canal_Procedencia__c);
		Map<Integer, List<Integer>> festivosPorMesMap = new Map<Integer, List<Integer>> ();
        festivosPorMesMap = CC_MetodosUtiles.sacarFestivosPorMes();
        Datetime FechaRespuesta = correo.createdDate;
		Datetime fechaTraslado = caso.CC_Fecha_Traslado_Colaborador__c; //pasar a valor de método (Arriba)
        Double horasPasadas = 0;

		if(fechaRespuesta != null && correo.createdDate != null){

		//Obtenemos los horarios de las jornadas:
	
			Double horasTrabajoViernes = 0;
            Double horasTrabajoNormal = 0;

            if(horario == null){
                horario = horariosPorCanalProcedencia.get('Generico');
            }

                if (horario.size() > 1){

                    horasTrabajoViernes = CC_MetodosUtiles.restarHoras(horario.get('V').get(1), horario.get('V').get(0));
                    horasTrabajoNormal = CC_MetodosUtiles.restarHoras(horario.get('L-J').get(1), horario.get('L-J').get(0));
                }
				else{

                    horasTrabajoNormal = CC_MetodosUtiles.restarHoras(horario.get('L-V').get(1), horario.get('L-V').get(0));
                    horasTrabajoViernes = CC_MetodosUtiles.restarHoras(horario.get('L-V').get(1), horario.get('L-V').get(0));
                }
				
				//Creamos una opcion para cuando la respuesta del correo no es el mismo dia:
				if (!fechaTraslado.isSameDay(fechaRespuesta)){
					
					Datetime diaSemanaBucle = fechaTraslado.date();
					
					//traslado creado dentro de la jornada laboral que no sea festivo
					//Primero sacamos las horas que han pasado desde que se hizo el traslado hasta el fin del horario
					 if (fechaTraslado.time() >= CC_MetodosUtiles.horarioDiaTurno(horario, fechaTraslado.format('u'), 'Entrada') 
                         && fechaTraslado.time() <= CC_MetodosUtiles.horarioDiaTurno(horario, fechaTraslado.format('u'), 'Salida')
                         && !CC_MetodosUtiles.isFestive(fechaTraslado, festivos)){
						 horasPasadas = horasPasadas + CC_MetodosUtiles.restarHoras(CC_MetodosUtiles.horarioDiaTurno(horario, fechaTraslado.format('u'), 'Salida'), fechaTraslado.time());
                     } 
                    //Si la fecha de traslado se hizo antes de comenzar la jornada laboral y que no sea festivo :
                      else if(fechaTraslado.time() < CC_MetodosUtiles.horarioDiaTurno(horario, fechaTraslado.format('u'), 'Entrada') 
                        	 && !CC_MetodosUtiles.isFestive(fechaTraslado, festivos)){
                                   
								 if(Integer.valueOf(diaSemanaBucle.format('u')) == 5) {
                                                horasPasadas = horasPasadas + horasTrabajoViernes;
                                            }
                                            else{
                                                horasPasadas = horasPasadas + horasTrabajoNormal;
                                            }
                         				}

				        	  //Vamos sumando la fecha de traslado dias hasta alcanzar la fecha de respuesta (Cada dia que se suma se procesan las horas)
				        	  Integer i = 1;
				        	  while (!diaSemanaBucle.addDays(i).format('u').equals(fechaRespuesta.format('u'))) {
								  
				        		   //Si no es festivo o no es fin de semana
				        		   if (!CC_MetodosUtiles.isFestive(diaSemanaBucle.addDays(i), festivos) && !CC_MetodosUtiles.isWeekend(diaSemanaBucle.addDays(i))) {
                                
				        			//Si aun no hemos llegado al día de la respuesta, añadido horas de jornada laboral sea L-J o V
				        			if(fechaRespuesta != null && !diaSemanaBucle.addDays(i).isSameDay(fechaRespuesta)){
                                            if (Integer.valueOf(diaSemanaBucle.addDays(i).format('u')) == 5) {
                                                horasPasadas = horasPasadas + horasTrabajoViernes;

                                            }
                                            else{
                                                horasPasadas = horasPasadas + horasTrabajoNormal;
                                            }
											
										//Comentado, no hacemos esto porque no va a pasar por aqui
				        				//Si llegamos a la fecha de respuesta restamos el tiempo de respuesta con la hora de jornada laboral de ese dia
				        				//Ejemplo, si la respuesta entra a las 12:00, obtenemos las horas que han habido entre la entrada de jornada a las 8:00 y las 12:00
										
                                        }
/*										else{ //Si la respuesta ha llegado en jornada laboral
                                                if (fechaRespuesta.time() < horarioDiaTurno(horario, fechaTraslado.addDays(i).format('u'), 'Salida')){
                                                    horasPasadas = horasPasadas + restarHoras(horarioDiaTurno(horario, fechaTraslado.addDays(i).format('u'), 'Salida'), fechaRespuesta.time());
                                                }
                                            }
											*/
						           }
						          i++;
					            }
							//Si se recibe la información cuando no está trabajando
							if (fechaRespuesta.time() < CC_MetodosUtiles.horarioDiaTurno(horario, fechaTraslado.addDays(i).format('u'), 'Salida') 
								&& fechaRespuesta.time() >= CC_MetodosUtiles.horarioDiaTurno(horario, fechaTraslado.addDays(i).format('u'), 'Entrada')  ){ 	

                                    horasPasadas = horasPasadas + CC_MetodosUtiles.restarHoras(CC_MetodosUtiles.horarioDiaTurno(horario, fechaTraslado.addDays(i).format('u'), 'Entrada'), fechaRespuesta.time());
								}
                }
				else
				{
		        	//Si se recibe la información cuando es en jornada de trabajando
		        	 if (fechaRespuesta.time() <= CC_MetodosUtiles.horarioDiaTurno(horario, fechaTraslado.format('u'), 'Salida')){ 
                            horasPasadas = horasPasadas + CC_MetodosUtiles.restarHoras(fechaRespuesta.time(), fechaTraslado.time());
                            }
		        	//else{horasPasadas = horasPasadas + restarHoras(horarioDiaTurno(horario, fechaTraslado.addDays(i).format('u'), 'Salida'), fechaRespuesta.time());}
		        }
		}
     	return horasPasadas;
	}
    	
}