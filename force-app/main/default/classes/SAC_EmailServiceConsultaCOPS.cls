public without sharing class SAC_EmailServiceConsultaCOPS implements Messaging.InboundEmailHandler{

    private static Set<String> objetos = new Set<String>{'Task','Case', 'CC_Grupo_Colaborador__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);
    
    final static Id RECORDTYPETAREA = mapRTsObjects.get('Task').get('SAC_TareaMail').getRecordTypeId();
    final static String RECORDTYPERECLAMACION = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    final static String RECORDTYPECONSULTA = mapRTsObjects.get('Case').get('SAC_Consulta').getRecordTypeId();
    final static String RECORDTYPECONSULTASAC = mapRTsObjects.get('Case').get('SAC_ConsultaSAC').getRecordTypeId();
    final static String RECORDTYPEPRETENSION = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();
    final static String RECORDTYPEGRUPORESPONSABLE = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SAC_GrupoResponsableAccion').getRecordTypeId();
    final static string CLASSNAME = 'SAC_EmailServiceConsultaCOPS';
    
    /*****************************************************************
    * Proposito: Procesa el email para asociarlo a un caso existente o crear uno nuevo
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US219261         Nicolás G.   15/06/21     Creación
    *****************************************************************/
    public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
       String methodname = 'handleInboundEmail';

        // Trazabilidad para registrar la entrada del correo.
        try{
            CBK_Log.auditemail(email,envelope);
        }catch (Exception e){
            // Método sobrecargado para registrar errores en con el objeto Messaging.InboundEmail.
            CBK_Log.error(e, 'Error procesando el correo entrante. ' + 'CLASSNAME: ' + CLASSNAME + ' - METHODNAME: ' + methodname + ' - MSG ERROR: ' + e.getMessage(), email);
        }
        
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        result.success= false;
        
        EmailMessage emailMess = new EmailMessage();
        
        try{
            WrapperEmailResult wrapEmRes = new WrapperEmailResult();
                        
            String texto = email.htmlBody;
            if(String.isBlank(texto)){
                texto = email.plainTextBody;
            }
            
            String threadId = '';
            Boolean encontradoThread = false;
            
            // US682922 - TA646298 - Guardar la fecha original del mensaje entrante
            Datetime emailDate = SAC_Utils.recuperarFechaEmail(email);
            
            //Obtenemos el ThreadId del mensaje entrante en el formato correcto.
            if (String.isNotBlank(texto)){
                threadId = texto.substringAfter('ref:_').substringBefore(':ref');
                if(String.isNotBlank(threadId)){  
                    encontradoThread = true;
                }
                threadId = ('ref:_' + threadId + ':ref');
            }            
            
            List<Case> listaCaso = [SELECT id, RecordTypeId, Status, CaseNumber, OwnerId, SAC_AlertasPtes__c, SAC_Reclamacion__c,
                                    SAC_PretensionPrincipal__r.OwnerId, SAC_Reclamacion__r.OwnerId, CC_SuppliedUser__c, Description, recordType.DeveloperName,
                                    CC_SuppliedID__c, SuppliedEmail, Subject
                                    FROM Case WHERE RecordTypeId = :RECORDTYPECONSULTA AND CC_SuppliedID__c =: threadId LIMIT 1];

            /*
            Comprobar que el body del mail recibido tenga threadId y buscar un caso que lo tenga
            Si hay un caso con ese threadId, se añade el mail al caso
            Si no hay un caso con ese threadId, se crea uno nuevo
            Comrpobar en el nombre de la custom setting si coincide con el TO del email que entra.
            Si coinciden coger el resto de campos mapeados en la cs para crear el caso.
            */
            
            //Separar caso con thread id
            Case casoConThreadId = new Case();
            if (!listaCaso.isEmpty()) {
                casoConThreadId = listaCaso[0];
            }
            
            //Comprobar si el caso esta cerrado, rechazado, en SAC_014, en SAC_012, en SAC_013 o (si es consulta y esta en SAC_008) o (si es consulta sac y está en SAC_008) para abrir caso nuevo en lugar de vincular el email al caso.
            //En caso de que la query no haya devuelto nada, también hay que crear un caso nuevo
            Boolean abrirCasoNuevo = false;
            Boolean linkarEmailACasoExistente = false;
            if ((String.isNotBlank(casoConThreadId.Status) && 
                 (casoConThreadId.Status == 'Cerrado' || casoConThreadId.Status == 'Rechazado' || casoConThreadId.Status == 'SAC_014' || casoConThreadId.Status == 'SAC_012' || casoConThreadId.Status == 'SAC_013' || 
                  (casoConThreadId.recordTypeId == RECORDTYPECONSULTA && casoConThreadId.Status == 'SAC_008') || (casoConThreadId.recordTypeId == RECORDTYPECONSULTASAC && casoConThreadId.Status == 'SAC_008')
                 )
                ) || String.isBlank(casoConThreadId.Id)) {
                    abrirCasoNuevo = true;
                } else if (String.isNotBlank(casoConThreadId.Id)) { //De lo contrario, y si la lista no está vacía, significa que ha encontrado un thread id y debe linkarse el email al caso
                    linkarEmailACasoExistente = true;
                }

            if (abrirCasoNuevo) {
                //Comprobar parametrizaciones de custom settings para saber que caracteristicas debe tener el caso que debemos crear
                SAC_EmailService__c parametrizacion = SAC_Utils.comprobarCustomSettings(email, 'SAC_Consulta');

                //Guardar grupo de la parametrización
                List<CC_Grupo_Colaborador__c> grupos = new List<CC_Grupo_Colaborador__c>();
                Map<String, Id> mapaGruposIds = new Map<String, Id>();
                if (parametrizacion != null && String.isNotBlank(parametrizacion.SAC_GroupName__c)) {
                    grupos = [SELECT Id, SAC_DeveloperName__c FROM CC_Grupo_Colaborador__c WHERE SAC_DeveloperName__c = :parametrizacion.SAC_GroupName__c];
                }

                if (!grupos.isEmpty()) {
                    for (CC_Grupo_Colaborador__c grupo : grupos) {
                        mapaGruposIds.put(grupo.SAC_DeveloperName__c, grupo.Id);
                    }
                }
                
                //Recuperar cola
                QueueSobject cola = null;
                List<QueueSobject> colas = [SELECT QueueId FROM QueueSobject WHERE queue.DeveloperName = 'SAC_PendienteAsignar' AND SobjectType = 'Case' LIMIT 1];
                if(!colas.isEmpty()){
                    cola = colas[0];
                }
                
                //Crear caso
                Case consultaNueva = SAC_Utils.prepararCasosNuevos(parametrizacion, mapaGruposIds, email, cola, RECORDTYPECONSULTA);
                
                if (consultaNueva != null) {
                    Database.SaveResult resultado = null;
                    
                    //Hacer reglas de validacion antes del insert del caso
                    SAC_Utils.WrapperReglaClasificacion wrapRC = new SAC_Utils.WrapperReglaClasificacion();
                    wrapRC = SAC_Utils.determinarCR(email.fromAddress, email.toAddresses, email.ccAddresses, email.Subject, texto, consultaNueva.RecordTypeId);

                    if (String.isNotBlank(wrapRC.id)) {
                        consultaNueva.OS_ReglaUtilizada__c = wrapRC.id;
                    }

                    //caso.CC_AcuseRecibo__c = '1'; esta linea se ha comentado para que no se quede el acuse de recibo en 1. Al no introducir un valor, manda el acuse de recibo y se updatea a 2 (dia 7/11/22)
                    SAC_DatabaseDML.insertDML(consultaNueva, false);
                    //resultado = Database.insert(consultaNueva);
                    wrapEmRes = emailTask(consultaNueva.Id, email, RECORDTYPETAREA);
                    Map<String,Boolean> mapaResultadoEmailTask = wrapEmRes.mapaResultado;
                    emailMess = wrapEmRes.eMessage;
                    
                    result.success= mapaResultadoEmailTask.get('resultado');
                    consultaNueva.SourceId = [SELECT id FROM EmailMessage WHERE ParentId =: consultaNueva.id AND Incoming = true LIMIT 1].id;
                    consultaNueva.SAC_UltimaModificacionFichero__c = (mapaResultadoEmailTask.get('tieneAttachments')) ? emailDate : null;
                    SAC_DatabaseDML.updateDML(consultaNueva, false);
                    //resultado = Database.update(consultaNueva);    
                }
            } else if(linkarEmailACasoExistente) {
                if(casoConThreadId.RecordTypeId == RECORDTYPECONSULTA && (casoConThreadId.Status == 'SAC_008' || casoConThreadId.Status == 'SAC_012' || casoConThreadId.Status == 'SAC_013')){
                    casoConThreadId.Status='SAC_011';
                    casoConThreadId.SAC_StatusAuxiliar__c = casoConThreadId.Status;
                }
                
                Database.SaveResult resultado = null;
                SAC_DatabaseDML.updateDML(casoConThreadId, false);
                //resultado = Database.update(casoConThreadId);
                wrapEmRes = emailTask(casoConThreadId.Id, email, RECORDTYPETAREA);
                result.success = wrapEmRes.mapaResultado.get('resultado');
                emailMess = wrapEmRes.eMessage;
            }

            //Trazabilidad para registrar el procesamiento del correo.
            CBK_Log.ResultWrapper resultado = new CBK_Log.ResultWrapper();
            resultado.Status = (result.success) ? 'OK' : 'KO';
            resultado.Detail = (result.success) ? 'Envio correcto' : 'Error procesando el correo';
            resultado.CaseId = emailMess.ParentId;
            resultado.EmailMessageId = emailMess.Id;
            CBK_Log.auditemailResult(resultado, email);
            
        }catch(Exception e){
            // Método sobrecargado para registrar errores en con el objeto Messaging.InboundEmail.
            // Trazabilidad para registrar el procesamiento del correo.
            CBK_Log.error(e, 'Error procesando el correo entrante. ' + 'CLASSNAME: ' + CLASSNAME + ' - METHODNAME: ' + METHODNAME + ' - MSG ERROR: ' + e.getMessage(), email);

            CBK_Log.ResultWrapper resultado = new CBK_Log.ResultWrapper();
            resultado.Status = 'KO';
            resultado.Detail = 'Error procesando el correo: ' + e.getMessage()?.left(225);
            resultado.CaseId = emailMess.ParentId;
            resultado.EmailMessageId = emailMess.Id;
            CBK_Log.auditemailResult(resultado, email);
        }
        
        return result; 
    }
    
    /*****************************************************************
    * Proposito: Decide asociar el email al caso o crear un nuevo caso, asociando el email y el contacto o medio de contacto.
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US219261         Nicolás G.   15/06/21     Creación
    *****************************************************************/
    
    public static WrapperEmailResult emailTask(ID casoid, Messaging.InboundEmail email, Id taskTR){
        String methodname = 'emailTask';
        Boolean resultado = false;
        Boolean tieneAttachments = false;
        Map<String,Boolean> mapaResultado = new Map<String,Boolean>();
        WrapperEmailResult wrapEmailRes = new WrapperEmailResult();
        
        Integer maxLengthSubject = EmailMessage.Subject.getDescribe().getLength()-1;
        
        String plainTextBody;
        String htmlBody;
        String subject;
        
        if(String.isNotBlank(email.plainTextBody)){
            plainTextBody = email.plainTextBody.left(130000);
        }
        if(String.isNotBlank(email.htmlBody)){
            htmlBody = email.htmlBody.left(130000);
        }
        if(String.isNotBlank(email.subject)){
            subject = email.subject.left( maxLengthSubject );
        } 
        
        EmailMessage conEmailMessage = new EmailMessage();
        
        conEmailMessage.ParentId    = casoid;
        conEmailMessage.ToAddress   = (email.toAddresses != null)?String.join(email.toAddresses, ','):null;
        conEmailMessage.FromAddress = email.FromAddress;
        conEmailMessage.FromName    = email.FromName;
        conEmailMessage.Subject     = subject;
        conEmailMessage.HtmlBody    = htmlBody;
        conEmailMessage.Incoming    = true;
        conEmailMessage.TextBody    = plainTextBody;
        conEmailMessage.Status      = '3';
        conEmailMessage.Headers     = JSON.serialize(email.headers);
        if(email.ccAddresses != null){
            conEmailMessage.CcAddress=String.join(email.ccAddresses,',');
        }
        //Añadido US527358

        conEmailMessage.MessageIdentifier = email.messageId;
        conEmailMessage.CBK_sfdcMessageId__c = email.messageId?.left(255);
        conEmailMessage.ThreadIdentifier = email.inReplyTo;
        
        //Try
        try{
            SAC_DatabaseDML.insertDML(conEmailMessage, false);
            //Database.insert(conEmailMessage);
            resultado = true; 
        }catch(Exception e){
            CBK_Log.error(e, 'Error procesando el correo entrante. ' + 'CLASSNAME: ' + CLASSNAME + ' - METHODNAME: ' + methodname + ' - MSG ERROR: ' + e.getMessage(), email);
        }
        // Add Email Message Relation for id of the sender
        EmailMessageRelation emr = new EmailMessageRelation();
        emr.EmailMessageId = conEmailMessage.id;
        emr.RelationAddress = email.FromAddress;
        emr.RelationType = 'FromAddress';

        //Try
        try{
            if(Schema.sObjectType.EmailMessageRelation.isCreateable()){
                SAC_DatabaseDML.insertDML(emr, false);
                //Database.insert(emr);
            }
            if(resultado=true){
                createTask(casoid, email.Subject, TaskTR);
            }
        }catch(Exception e){
            CBK_Log.error(e, 'Error procesando el correo entrante. ' + 'CLASSNAME: ' + CLASSNAME + ' - METHODNAME: ' + methodname + ' - MSG ERROR: ' + e.getMessage(), email);
        }
        //Guardamos los attachments si hubiese alguno
        if(resultado=true){	
            Map<String, ContentVersion> attachmentsMap= handleAttachments(email);
            
            if ( !attachmentsMap.isEmpty() ) {
                try{
                    tieneAttachments = true;
                    List<ContentVersion> listaContents = attachmentsMap.values();
                    SAC_DatabaseDML.insertListDML(listaContents, true);
                    //Database.insert(listaContents, false);
                    
                    List<ContentVersion> listaContentsInsertados = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE ID IN: listaContents];
                    
                    List<ContentDocumentLink> contentLinks = new List<ContentDocumentLink>();
                    for(ContentVersion cv :listaContentsInsertados){
                        ContentDocumentLink cdl = new ContentDocumentLink(LinkedEntityId = conEmailMessage.id,
                                                                          ContentDocumentId = cv.ContentDocumentId,
                                                                          ShareType = 'V');
                        contentLinks.add(cdl);
                        
                        ContentDocumentLink cdlCaso = new ContentDocumentLink(LinkedEntityId = casoid,
                                                                              ContentDocumentId = cv.ContentDocumentId,
                                                                              ShareType = 'V');
                        
                        contentLinks.add(cdlCaso);
                    }
                    SAC_DatabaseDML.insertListDML(contentLinks, true);
                    //Database.insert(contentLinks);
                }catch(Exception e){
                    // Método sobrecargado para registrar errores en con el objeto Messaging.InboundEmail.
                    CBK_Log.error(e, 'Error procesando el correo entrante. ' + 'CLASSNAME: ' + CLASSNAME + ' - METHODNAME: ' + methodname + ' - MSG ERROR: ' + e.getMessage(), email);
                }
                
            }
            
            
            
            String imageURL = '/servlet/servlet.FileDownload?file=';
            //Incidecia PROD 12/04
            String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm() + imageURL;
            
            for ( String contentId : attachmentsMap.keySet() ) {
                
                String cid = contentId.replace( '<', '' ).replace( '>', '' );
                if (String.isNotBlank(attachmentsMap.get( contentId ).id)) {
                    String url = fullFileURL + String.valueOf( attachmentsMap.get( contentId ).id ).left( 15 );
                    
                    conEmailMessage.textBody = (String.isNotBlank(conEmailMessage.textBody))?conEmailMessage.textBody.replaceAll( 'cid:' + cid, url ).left(130000):conEmailMessage.textBody;
                    conEmailMessage.htmlBody = (String.isNotBlank(conEmailMessage.htmlBody))?conEmailMessage.htmlBody.replaceAll( 'cid:' + cid, url ).left(130000):conEmailMessage.htmlBody;
                }
            }
            //Try
            try{
                if(Schema.sObjectType.EmailMessage.isUpdateAble()){
                    SAC_DatabaseDML.updateDML(conEmailMessage, false);
                    //Database.update(conEmailMessage);
                    resultado = true; 
                }
            }catch(Exception e){
                CBK_Log.error(e, 'Error procesando el correo entrante. ' + 'CLASSNAME: ' + CLASSNAME + ' - METHODNAME: ' + methodname + ' - MSG ERROR: ' + e.getMessage(), email);
            }
        } 
        
        mapaResultado.put('resultado', resultado);
        mapaResultado.put('tieneAttachments', tieneAttachments);
        
        wrapEmailRes.mapaResultado = mapaResultado;
        wrapEmailRes.eMessage = conEmailMessage;
        
        return wrapEmailRes;
    }
    
    /*****************************************************************
* Proposito: Método para asociar los archivos adjuntos del email.
* 
* Historial
* -------
* VERSION        USER_STORY       AUTHOR         DATE         Description
* 1.0            US219261         Nicolás G   15/06/21     Creación
*****************************************************************/
    
    public static Map<String, ContentVersion> handleAttachments(Messaging.InboundEmail email){
        String methodname = 'handleAttachments';
        Integer contadorSinHeader = 0;
        Map<String, ContentVersion> attachments = new Map<String, ContentVersion>();
        if(email.textAttachments != null){
            for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) {
                String contentId = toString( tAttachment.headers, 'Content-ID', false );
                if ( String.isBlank( contentId ) ) {
                    contentId = 'no-content-id-header-' + contadorSinHeader++;
                }
                
                ContentVersion cv = new ContentVersion();
                cv.Title = tAttachment.fileName;
                cv.VersionData = Blob.valueOf(tAttachment.body);
                cv.PathOnClient = tAttachment.fileName;
                cv.origin = 'H';
                attachments.put(contentId, cv);
                
            }
        }
        if(email.binaryAttachments != null){
            for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {                
                String contentId = toString( bAttachment.headers, 'Content-ID', false );
                if ( String.isBlank( contentId ) ) {
                    contentId = 'no-content-id-header-' + contadorSinHeader++;
                }                
                
                ContentVersion cv = new ContentVersion();
                cv.Title = bAttachment.fileName;
                cv.VersionData = bAttachment.body;
                cv.PathOnClient = bAttachment.fileName;
                cv.origin = 'H';
                attachments.put(contentId, cv);
            }
        }
        return attachments;
    }
    
    /*****************************************************************
* Proposito: Método procesar los encabezados del email entrante y almacenarlos en una variable de tipo String, o recuperar el valor del content id del adjunto
* 
* Historial
* -------
* VERSION        USER_STORY       AUTHOR         DATE         Description
* 1.0            US219261         Nicolás G   15/06/21     Creación
*****************************************************************/
    private static String toString( List<Messaging.InboundEmail.Header> headers, String name, Boolean transform ) {
        
        String text = '';
        
        if ( headers != null ) {
            for ( Messaging.InboundEmail.Header header : headers ) {
                if(transform){      
                    text += header.name + '=' + header.value + '\n';
                }
                else if ( header.name == name ) {
                    text = header.value;
                    break;
                }
            }
        }
        return text;
    }
    
    /*****************************************************************
* Proposito: Método para crear una tarea de creación de email en el caso.
* 
* Historial
* -------
* VERSION        USER_STORY       AUTHOR         DATE         Description
* 1.0            US219261         Nicolás G   15/06/21     Creación
*****************************************************************/
    
    private static void createTask(String casoid, String subject, Id taskTR){
        String methodname = 'createTask';
        Task tarea= new Task();
        tarea.Type = 'Email';
        tarea.WhatId = casoid;
        tarea.Subject = subject.left(255).stripHtmlTags(); 
        tarea.Status = 'Completed';
        tarea.ActivityDate= system.today();
        tarea.RecordTypeId = TaskTR;
        if(Schema.sObjectType.Task.isCreateable()){
            SAC_DatabaseDML.insertDML(tarea, false);
            //Database.insert(tarea);
        }
    }
    
    public class WrapperEmailResult{
        public Map<String,Boolean> mapaResultado{get; set;}
        public Boolean result{get; set;}
        public EmailMessage eMessage{get; set;}
        
        public wrapperEmailResult() {
            this.mapaResultado = new Map<String,Boolean>();
            this.result = false;
            this.eMessage = new EmailMessage();
        }
    }
}