public with sharing class CC_KnowledgeCaseHandler {
    public static final String KNOWLEDGE_SETTINGS = 'CC_Knowledge_Settings';
    public static final String CONTACT_EMPLEADO_RT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
    public static final String CASE_KNOWDLEGE_RT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Knowledge').getRecordTypeId();
    public static final String CASE_STATUS_PENDIENTE_COLABORADOR = 'Pendiente Colaborador';
    public static final String CASE_STATUS_ACTIVO = 'Activo';
    public static final String TASK_TYPE_NOTIFICAR_VENCIMIENTO_KNOWLEDGE = 'Notificar vencimiento Knowledge';
    public static final String TASK_TYPE_CAMBIO_ESTADO_CASO_KNOWLEDGE = 'Cambio de estado caso Knowledge';
    public static final String KNOWLEDGE_TYPE_ARTICULO = 'Cliente';

    public class KnowledgeSettings{
        public List<Integer> diasAvisoAntes;
        public Integer diasAvisoDespues;
        public Boolean activarEnvioCorreos;
        public String buzonSalida;
        public String emailTemplatePorVencer;
        public String emailTemplateVencido;
        public String queueName;
        public String avisoArchivar;
        public String avisoRenovar;
        public String avisoActualizar;
        public List<String> tiposArticulos;
    }

    public static KnowledgeSettings getCustomSetting(){
        List<CC_Settings__c> mcs = new List<CC_Settings__c>();

        mcs = [
            SELECT Id, Name, 
                CC_Configuracion_1__c, 
                CC_Configuracion_2__c, 
                CC_Configuracion_3__c, 
                CC_Configuracion_4__c,
                CC_Configuracion_6__c, 
                CC_Configuracion_7__c, 
                CC_Configuracion_8__c,                
                CC_Configuracion_9__c, 
                CC_Configuracion_10__c, 
                CC_Configuracion_11__c, 
                CC_Configuracion_12__c, 
                CC_Descripcion__c
            FROM CC_Settings__c
            WHERE Name = :KNOWLEDGE_SETTINGS
            AND CC_Activa__c = true
        ];
        if(!mcs.isEmpty()){
            KnowledgeSettings settings = new KnowledgeSettings();
            settings.diasAvisoAntes = mcs[0].CC_Configuracion_1__c != null ? procesarStringDias(mcs[0].CC_Configuracion_1__c) : new List<Integer>{30};
            settings.diasAvisoDespues = mcs[0].CC_Configuracion_2__c != null ? Integer.valueOf(mcs[0].CC_Configuracion_2__c) : 7;
            settings.activarEnvioCorreos = mcs[0].CC_Configuracion_3__c != null ? Boolean.valueOf(mcs[0].CC_Configuracion_3__c) : true;
            settings.buzonSalida = mcs[0].CC_Configuracion_4__c != null ? mcs[0].CC_Configuracion_4__c : 'contactcenter.devservice@gmail.com';
            settings.emailTemplatePorVencer = mcs[0].CC_Configuracion_6__c != null ? mcs[0].CC_Configuracion_6__c : 'CC_KnowledgeArticlePorVencer';
            settings.emailTemplateVencido = mcs[0].CC_Configuracion_7__c != null ? mcs[0].CC_Configuracion_7__c : 'CC_KnowledgeArticleVencido';
            settings.queueName = mcs[0].CC_Configuracion_8__c != null ? mcs[0].CC_Configuracion_8__c : 'CC_Knowledge_Cases';
            settings.avisoArchivar = mcs[0].CC_Configuracion_9__c != null ? mcs[0].CC_Configuracion_9__c : '';
            settings.avisoActualizar = mcs[0].CC_Configuracion_10__c != null ? mcs[0].CC_Configuracion_10__c : '';
            settings.avisoRenovar = mcs[0].CC_Configuracion_11__c != null ? mcs[0].CC_Configuracion_11__c : '';
            settings.tiposArticulos = mcs[0].CC_Configuracion_12__c != null ? procesarStringTipos(mcs[0].CC_Configuracion_12__c) : new List<String>{KNOWLEDGE_TYPE_ARTICULO};
            return settings;
        }else {
            return null;
        }
    }


    private static List<Integer> procesarStringDias(String diasString) {
        List<Integer> diasList = new List<Integer>();
        
        if (String.isNotBlank(diasString)) {
            List<String> diasStringList = diasString.split(';');
            for (String dia : diasStringList) {
                if (String.isNotBlank(dia)) {
                    diasList.add(Integer.valueOf(dia.trim()));                   
                }
            }
        }         
        return diasList;
    }

    private static List<String> procesarStringTipos(String tiposString) {
        List<String> tiposList = new List<String>();
        
        if (String.isNotBlank(tiposString)) {
            tiposList = tiposString.trim().split(';');
        }else {
            tiposList.add(KNOWLEDGE_TYPE_ARTICULO);
        }         
        return tiposList;
    }

    /**
     * Reemplaza las ocurrencias de [Knowledge.XXXX] en el texto por los valores de los campos del artículo
     * @param texto Texto original que contiene las ocurrencias a reemplazar
     * @param articulo Registro del artículo Knowledge__kav con los valores de los campos
     * @return Texto con las ocurrencias reemplazadas
     */
    public static String reemplazarCamposKnowledge(String texto, Knowledge__kav articulo) {
        if (texto == null || articulo == null) {
            return texto;
        }
        
        String resultado = texto;
        
        // Patrón para encontrar [Knowledge.XXXX]
        Pattern patron = Pattern.compile('\\[Knowledge\\.([^\\]]+)\\]');
        Matcher matcher = patron.matcher(texto);
        
        while (matcher.find()) {
            String campoCompleto = matcher.group(0); // [Knowledge.XXXX]
            String nombreCampo = matcher.group(1);   // XXXX (nombre del campo)
            
            // Obtener el valor del campo usando reflexión
            Object valorCampo = articulo.get(nombreCampo);
            String valorString = '';
            
            if (valorCampo != null) {
                if (valorCampo instanceof Date) {
                    Date fecha = (Date)valorCampo;
                    DateTime fechaTime = DateTime.newInstance(fecha.year(), fecha.month(), fecha.day());
                    valorString = fechaTime.format('dd/MM/yyyy');
                } else if (valorCampo instanceof Datetime) {
                    Datetime fechaTime = (Datetime) valorCampo;
                    valorString = fechaTime.format('dd/MM/yyyy HH:mm');
                } else if (valorCampo instanceof Boolean) {
                    valorString = String.valueOf((Boolean) valorCampo);
                } else if (valorCampo instanceof Decimal) {
                    valorString = String.valueOf((Decimal) valorCampo);
                } else if (valorCampo instanceof Integer) {
                    valorString = String.valueOf((Integer) valorCampo);
                } else {
                    valorString = String.valueOf(valorCampo);
                }
            }
            
            // Reemplazar la ocurrencia
            resultado = resultado.replace(campoCompleto, valorString);
        }
        
        return resultado;
    }

    public static Map<Id, List<ContentVersion>> obtenerAdjuntos(Set<Id> articleIds, List<Knowledge__kav> scope) {
        Map<Id, List<ContentVersion>> archivosPorArticulo = new Map<Id, List<ContentVersion>>();
        List<ContentDocumentLink> links = [
            SELECT ContentDocumentId, LinkedEntityId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN :articleIds
        ];
        
        if(!links.isEmpty()) {
            Set<Id> contentDocIds = new Set<Id>();
            for(ContentDocumentLink link : links) {
                contentDocIds.add(link.ContentDocumentId);
            }
            
            List<ContentVersion> versions = [
                SELECT Id, ContentDocumentId, VersionData, Title, FileType, FileExtension
                FROM ContentVersion 
                WHERE ContentDocumentId IN :contentDocIds 
                AND IsLatest = true
            ];
            
            for(ContentVersion version : versions) {
                for(ContentDocumentLink link : links) {
                    if(version.ContentDocumentId == link.ContentDocumentId) {
                        for(Knowledge__kav art : scope) {
                            if(art.Id == link.LinkedEntityId) {
                                if(!archivosPorArticulo.containsKey(art.Id)) {
                                    archivosPorArticulo.put(art.Id, new List<ContentVersion>());
                                }
                                archivosPorArticulo.get(art.Id).add(version);
                            }
                        }
                    }
                }
            }
        }
        return archivosPorArticulo;
    }

    public static void logKnowledgeCase(String log) {
        CBK_Log.error('CC_KnowledgeCaseHandler: ' + log);
    }

    public static Task crearTareaEnvioCorreo(Id casoId, Boolean isSuccess, String referenciaCorreoSaliente, String descripcion) {
        Task tarea = new Task();
        tarea.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
        tarea.WhatId = casoId;
        tarea.Type = TASK_TYPE_NOTIFICAR_VENCIMIENTO_KNOWLEDGE;
        tarea.Status = 'Completed';
        tarea.ActivityDate = CBK_UtilsDate.todayDT();
        if(isSuccess) {
            tarea.Subject = 'Notificación de vencimiento enviada';
            tarea.CC_Referencia_Correo_Saliente__c = referenciaCorreoSaliente;
        } else {
            tarea.Subject = 'Error en el envio de correo';          
        }
        tarea.Description = descripcion;   
        return tarea;
    }

    public static Task crearTareaCambioStatus(Id casoId, String status, String action) {
        Task tarea = new Task();
        tarea.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
        tarea.WhatId = casoId;
        tarea.Type = TASK_TYPE_CAMBIO_ESTADO_CASO_KNOWLEDGE;
        tarea.Status = 'Completed';
        tarea.ActivityDate = CBK_UtilsDate.todayDT();
        tarea.Subject = 'Caso actualizado a: ' + status;
        tarea.Description = 'El caso se actualizó a ' + status + ' por el usuario con la acción: ' + action;   
        if(status == 'Cerrado') {
            tarea.CC_Tipo_Cierre__c = action;
        } 
        return tarea;
    }

    public static void gestionarArticulosNotificaciones(List<Knowledge__kav> scope){
        gestionarArticulosNotificaciones(scope, false);
    }

    public static void gestionarArticulosNotificaciones(List<Knowledge__kav> scope, Boolean notificacionVencido){
        KnowledgeSettings config = CC_KnowledgeCaseHandler.getCustomSetting();
        if(config == null) {
            CC_KnowledgeCaseHandler.logKnowledgeCase('No se encontró la configuración para las notificaciones :' + config);
            return;
        }
        
        // Crear mapas para almacenar los contactos por artículo
        Map<Id, List<Contact>> mapaContactosTo = new Map<Id, List<Contact>>();
        Map<Id, List<Contact>> mapaContactosCC = new Map<Id, List<Contact>>();
        
        // Obtener todos los Account IDs únicos
        Set<Id> accountIds = new Set<Id>();
        Set<Id> articleIds = new Set<Id>();
        for(Knowledge__kav art : scope) {
            if(art.CC_Area_Responsable__c != null) {
                accountIds.add(art.CC_Area_Responsable__c);
            }
            articleIds.add(art.Id);
        }
        
        // Consultar todos los contactos relacionados con los Accounts
        List<Contact> contactos = [
            SELECT Id, Email, CC_ResponsableKnowledge__c, AccountId
            FROM Contact
            WHERE AccountId IN :accountIds
            AND RecordTypeId = :CONTACT_EMPLEADO_RT
            AND CC_ResponsableKnowledge__c != null
            AND Email != null
        ];
        
        if(contactos.isEmpty()) {
            CC_KnowledgeCaseHandler.logKnowledgeCase('No se encontraron contactos para el batch articlesIds :' + articleIds);
            return;
        }
            
        for(Knowledge__kav art : scope) {
            mapaContactosTo.put(art.Id, new List<Contact>());
            mapaContactosCC.put(art.Id, new List<Contact>());            
            
            // Distribuir los contactos para este artículo
            for(Contact c : contactos) {
                if(art.CC_Area_Responsable__c == c.AccountId) {
                    if(c.CC_ResponsableKnowledge__c == 'Primer contacto') {
                        mapaContactosTo.get(art.Id).add(c);
                    } else if(c.CC_ResponsableKnowledge__c == 'Segundo contacto') {
                        mapaContactosCC.get(art.Id).add(c);
                    }
                }
            }
        }

        //Buscar los cases que estén relacionados con los artículos
        Map<Id, CBK_Case_Extension__c> caseExtensionPorArticulo = new Map<Id, CBK_Case_Extension__c>();            
        Map<Id, Case> casePorArticulo = new Map<Id, Case>();          
        // Consultar los casos relacionados
        List<CBK_Case_Extension__c> casosRelacionados = [
            SELECT Id, CC_Articulo_Relacionado__c, Case_Id__c, Case_Id__r.CC_Referencia_Correo_Saliente__c
            FROM CBK_Case_Extension__c
            WHERE CC_Articulo_Relacionado__c IN :articleIds
            AND Case_Id__c != null
            AND Case_Id__r.Status != 'Cerrado' //Para no coger cases del pasado creados para el mismo articulo.
        ];
        if(!casosRelacionados.isEmpty()){
            // Crear el mapa de casos por artículo
            for(CBK_Case_Extension__c casoExt : casosRelacionados) {
                for(Knowledge__kav art : scope) {
                    if(art.Id == casoExt.CC_Articulo_Relacionado__c) {
                        caseExtensionPorArticulo.put(art.Id, casoExt); 
                        casePorArticulo.put(art.Id, new Case(
                                Id = casoExt.Case_Id__c, 
                                CC_Referencia_Correo_Saliente__c = CC_EmailMessage.generarReferenciaCorreoSaliente(casoExt.Case_Id__c) //para que se vuelva a generar al enviar el mail. 
                            )
                        );
                        break;
                    }
                }
            }
        }
        
        // Crear casos y case extensions para artículos que no los tienen
        List<Case> casosACrear = new List<Case>();
        List<CBK_Case_Extension__c> caseExtensionsACrear = new List<CBK_Case_Extension__c>();
        Map<Id, CBK_Case_Extension__c> mapaCaseExtensionsTemp = new Map<Id, CBK_Case_Extension__c>();
        Map<Id, Case> mapaCaseTemp = new Map<Id, Case>();

        List<Group> queueSObjects = new List<Group>();
        if(config.queueName != null){
            queueSObjects = [SELECT Id FROM Group WHERE DeveloperName = :config.queueName AND Type = 'Queue' LIMIT 1];
        }     
        if(queueSObjects.isEmpty()) {
            CC_KnowledgeCaseHandler.logKnowledgeCase('No se encontró la cola para el batch queueName :' + config.queueName);
            return;
        }
        
        // Identificar artículos que necesitan casos
        for(Knowledge__kav art : scope) {
            if(!caseExtensionPorArticulo.containsKey(art.Id)) {
                // Crear el caso
                Case nuevoCaso = new Case(
                    RecordTypeId = CASE_KNOWDLEGE_RT,
                    Subject = art.Title,
                    Status = CASE_STATUS_PENDIENTE_COLABORADOR,
                    Description = 'Artículo de Knowledge próximo a caducar: ' + art.Title,
                    OwnerId = !queueSObjects.isEmpty() ? queueSObjects[0].Id : UserInfo.getUserId(),
                    CC_Ultima_Operativa_Correo__c = 'Notificacion Articulo Por Vencer'
                );
                casosACrear.add(nuevoCaso);
                
                // Crear el case extension
                CBK_Case_Extension__c nuevoCaseExt = new CBK_Case_Extension__c(
                    CC_Articulo_Relacionado__c = art.Id
                );
                caseExtensionsACrear.add(nuevoCaseExt);
                mapaCaseExtensionsTemp.put(art.Id, nuevoCaseExt);
                mapaCaseTemp.put(art.Id, nuevoCaso);
            }
        }
        
        // Insertar los casos si hay alguno para crear            
        if(!casosACrear.isEmpty()) {
            insert casosACrear;
            
            // Actualizar los case extensions con los IDs de los casos
            for(Integer i = 0; i < casosACrear.size(); i++) {
                caseExtensionsACrear[i].Case_Id__c = casosACrear[i].Id;
            }
            
            // Insertar los case extensions
            insert caseExtensionsACrear;
            
            // Actualizar los casos con los IDs de los case extensions
            List<Case> casosAActualizar = new List<Case>();
            for(Integer i = 0; i < casosACrear.size(); i++) {
                casosACrear[i].CBK_Case_Extension_Id__c = caseExtensionsACrear[i].Id;
                casosACrear[i].CC_Referencia_Correo_Saliente__c = CC_EmailMessage.generarReferenciaCorreoSaliente(casosACrear[i].Id);
                casosAActualizar.add(casosACrear[i]);
            }
            update casosAActualizar;
            
            // Actualizar el mapa de casos por artículo con los nuevos registros
            for(Knowledge__kav art : scope) {
                if(mapaCaseExtensionsTemp.containsKey(art.Id)) {
                    caseExtensionPorArticulo.put(art.Id, mapaCaseExtensionsTemp.get(art.Id));
                    casePorArticulo.put(art.Id, mapaCaseTemp.get(art.Id));
                }
            }
        }

        String plantillaName = notificacionVencido ? config.emailTemplateVencido : config.emailTemplatePorVencer;
        // Obtener el ID de la plantilla de correo
        List<EmailTemplate> templates = [
            SELECT Id, HtmlValue, Subject 
            FROM EmailTemplate 
            WHERE Name = :plantillaName 
            LIMIT 1
        ];
        if(templates.isEmpty()) {
            CC_KnowledgeCaseHandler.logKnowledgeCase('No se encontró la plantilla para el batch emailTemplatePorVencer :' + plantillaName);
            return;
        }
        EmailTemplate template = templates[0];
        //Obtener el OWA
        List<OrgWideEmailAddress> lstOWEA = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = :config.buzonSalida ];          

        if(lstOWEA.isEmpty()) {
            CC_KnowledgeCaseHandler.logKnowledgeCase('No se encontró el OWA para el buzón de salida buzonSalida :' + config.buzonSalida);
            return;
        }

        Id orgWideEmailAddressId = lstOWEA[0].Id;

        // Obtener los archivos adjuntos de los artículos
        Map<Id, List<ContentVersion>> archivosPorArticulo = CC_KnowledgeCaseHandler.obtenerAdjuntos(articleIds, scope);
        
        // Preparar y enviar los correos
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();      
        List<Knowledge__kav> artToSendEmail = new List<Knowledge__kav>();
        for(Knowledge__kav art : scope) {          
            if(caseExtensionPorArticulo.containsKey(art.Id)) {
                CBK_Case_Extension__c casoExt = caseExtensionPorArticulo.get(art.Id);
                List<Contact> contactosTo = mapaContactosTo.get(art.Id);
                List<Contact> contactosCC = mapaContactosCC.get(art.Id);
                
                if(!contactosTo.isEmpty() || !contactosCC.isEmpty()) {
                    Map<String, String> renderedEmail = CC_KnowledgeCaseHandler.renderFromTemplate(template.Id, casoExt.Case_Id__c);
        
                    String body = renderedEmail.get('body');
                    String subject = renderedEmail.get('subject');
                    //hacer replacement de campos de articulo
                    body = CC_KnowledgeCaseHandler.reemplazarCamposKnowledge(body, art);
                    
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();                    
                    mail.setSubject(subject);
                    mail.setOrgWideEmailAddressId(orgWideEmailAddressId);
                    mail.setWhatId(casoExt.Case_Id__c);
                    mail.setSaveAsActivity(true);
                    
                    // Configurar destinatarios
                    List<String> toAddresses = new List<String>();
                    List<String> ccAddresses = new List<String>();
                    
                    for(Contact c : contactosTo) {
                        toAddresses.add(c.Email);
                    }
                    for(Contact c : contactosCC) {
                        ccAddresses.add(c.Email);
                    }
                    
                    mail.setToAddresses(toAddresses);
                    mail.setCcAddresses(ccAddresses);
                    
                    // Agregar archivos adjuntos si existen
                    if(archivosPorArticulo.containsKey(art.Id)) {
                        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
                        for(ContentVersion version : archivosPorArticulo.get(art.Id)) {
                            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                            attachment.setFileName(version.Title + '.' + version.FileExtension);
                            attachment.setBody(version.VersionData);
                            attachments.add(attachment);
                        }
                        mail.setFileAttachments(attachments);
                        body = body.replace('[Knowledge_Cuerpo_Articulo]', '');
                        mail.setHtmlBody(body);
                    } else {
                        // Si no hay archivos, agregar el contenido del artículo al cuerpo
                        String contenidoArticulo = art.Answer__c != null ? art.Answer__c : '';
                        if(body.contains('[Knowledge_Cuerpo_Articulo]')) {
                            body = body.replace('[Knowledge_Cuerpo_Articulo]',  '<br/><br/>Contenido del artículo:<br/>' + contenidoArticulo);                          
                        }else{
                            body = body +  '<br/><br/>Contenido del artículo:<br/>' + contenidoArticulo;
                        }
                        mail.setHtmlBody(body);
                    }
                    
                    emails.add(mail);
                    artToSendEmail.add(art);
                }  

            }
        }
        
        // Enviar todos los correos
        if(!emails.isEmpty() && config.activarEnvioCorreos) {
            // Enviar correos y recoger resultados
            List<Messaging.SendEmailResult> resultadosEnvio = Messaging.sendEmail(emails, false);
            
            // Preparar tareas según el resultado
            List<Task> tareas = new List<Task>();
            Id recordTypeTaskCC = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
            for(Integer i = 0; i < resultadosEnvio.size(); i++) {
                Knowledge__kav art = artToSendEmail.get(i);
                Case caso = casePorArticulo.get(art.Id);
                if (caso == null) continue;
                String referenciaCorreoSaliente = caso.CC_Referencia_Correo_Saliente__c;
                String descripcion = resultadosEnvio[i].isSuccess() ? 'Se envió el correo de notificación de vencimiento de artículo' : 
                    'Error al enviar el correo de notificación de vencimiento de artículo: ' + String.join(resultadosEnvio[i].getErrors(), ' | ');
                Task tareaEnvioCorreo = CC_KnowledgeCaseHandler.crearTareaEnvioCorreo(caso.Id, resultadosEnvio[i].isSuccess(), referenciaCorreoSaliente, descripcion);
                tareas.add(tareaEnvioCorreo);                  
            }
            if(!tareas.isEmpty()) {
                CC_Activity.crearActividades(tareas); 
            }
        }
    }

    public static Map<String, String> renderFromTemplate(String templateId, Id whatId) {
        Map<String, String> mapa = new Map<String, String>();
        Messaging.SingleEmailMessage renderedEmail = Messaging.renderStoredEmailTemplate(
            templateId, 
            UserInfo.getUserId(), 
            whatId
        );
        mapa.put('subject', renderedEmail.getSubject());
        mapa.put('body', renderedEmail.getHtmlBody());
        return mapa;
    }

    public static void procesarNotificacionArticulosVencidos(List<Id> articleIds) {
        KnowledgeSettings config = CC_KnowledgeCaseHandler.getCustomSetting();
        if(config == null) {
            CC_KnowledgeCaseHandler.logKnowledgeCase('No se encontró la configuración para el ejecucion de la notificacion de articulos vencidos config :' + config);
            return;
        }

        //Si el articulo archivado, tiene algun caso abierto o pendiente de colaborador, se notifica, 
        //Si no, no se hace nada. 
        List<Knowledge__kav> articlesToSendEmail = new List<Knowledge__kav>();
        List<Knowledge__kav> articles = [
            SELECT Id, KnowledgeArticleId, CC_Area_Responsable__c, CC_Fecha_Caducidad__c, Title, Answer__c, PublishStatus 
            FROM Knowledge__kav 
            WHERE Id IN :articleIds AND CC_Tipo__c IN :config.tiposArticulos
        ];
        Map<Id, Knowledge__kav> mapaArticles = new Map<Id, Knowledge__kav>();
        for(Knowledge__kav art : articles) {
            if(art.PublishStatus == 'Archived') {
                mapaArticles.put(art.Id, art);
            }
        }

        if(mapaArticles.isEmpty()) {
            return;
        }

        List<Case> cases = [
            SELECT Id, Status, CBK_Case_Extension_Id__r.CC_Articulo_Relacionado__c
            FROM Case 
            WHERE RecordTypeId = :CASE_KNOWDLEGE_RT 
            AND CBK_Case_Extension_Id__c != null 
            AND CBK_Case_Extension_Id__r.CC_Articulo_Relacionado__c IN :mapaArticles.keySet()            
        ];

        Map<Id, Case> mapaCases = new Map<Id, Case>();
        for(Case c : cases) {
            mapaCases.put(c.CBK_Case_Extension_Id__r.CC_Articulo_Relacionado__c, c);
        }

        //Se notifica
        List<CBK_SCH_PendingProcess__c> listaPendingProcess = new List<CBK_SCH_PendingProcess__c>();
        Integer diasAvisoDespues = config.diasAvisoDespues;
        for(Id artId : mapaArticles.keySet()) {
            if(mapaCases.containsKey(artId)) {
                Case c = mapaCases.get(artId);
                if(c.Status == CASE_STATUS_ACTIVO || c.Status == CASE_STATUS_PENDIENTE_COLABORADOR) {
                    articlesToSendEmail.add(mapaArticles.get(artId));
                    //para republicar el chequeo
                    listaPendingProcess.add(crearPendingProcessNotificacion(artId, diasAvisoDespues));
                }
            }else{
                //Se notifica
                articlesToSendEmail.add(mapaArticles.get(artId));
                 //para republicar el chequeo
                listaPendingProcess.add(crearPendingProcessNotificacion(artId, diasAvisoDespues));
            } 
        }

        if(articlesToSendEmail.isEmpty()) {
            return;
        }

        //Se notifica
        CC_KnowledgeCaseHandler.gestionarArticulosNotificaciones(articlesToSendEmail, true); 

        //Se vuelve a programar el schedule para X dias despues
        if(!listaPendingProcess.isEmpty()) {
            insert listaPendingProcess;
        }
        
    }

    public static CBK_SCH_PendingProcess__c crearPendingProcessNotificacion(Id recordId, Integer diasAvisoDespues) {
        CBK_SCH_PendingProcess__c pendingProcessNotificacion = new CBK_SCH_PendingProcess__c();
        pendingProcessNotificacion.recordId__c = recordId;
        pendingProcessNotificacion.Schedule_Time__c = CBK_UtilsDate.nowDT().addDays(diasAvisoDespues);
        pendingProcessNotificacion.className__c = 'CC_SchedulableKnowledge';
        pendingProcessNotificacion.Param1__c = 'notificacionVencimiento';
        pendingProcessNotificacion.Param2__c = 'articuloVencido';
        return pendingProcessNotificacion;
    }
}