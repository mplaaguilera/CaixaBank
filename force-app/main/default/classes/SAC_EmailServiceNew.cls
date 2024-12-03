/*****************************************************************
* Name: SAC_EmailServiceNew
* Copyright © 2021  CaixaBank
* 
* Proposito: Tratar los emails entrantes mediante el Email Service
* 
* Historial
* -------
* VERSION        USER_STORY       AUTHOR         DATE         Description
* 1.0            US219261       Nicolás García   15/06/21      Creación 
* 1.1            US277103       Marcela Neira    09/11/2021    Modificación para que se compruebe en el body
*                                                              del Email si contiene el el ThreadId y relacionarlo con el caso correspondiente
* 1.2            US927972       Alex Pérez       20/06/2024    Modificación para desviar casos que son prerechazados y evitar enviarlos a la IA
*****************************************************************/
public without sharing class SAC_EmailServiceNew implements Messaging.InboundEmailHandler {
    private static Set<String> objetos = new Set<String>{'Task','Case', 'CC_Grupo_Colaborador__c', 'SAC_Interaccion__c', 'SAC_Accion__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);
    
    final static Id RECORDTYPETAREA = mapRTsObjects.get('Task').get('SAC_TareaMail').getRecordTypeId();
    final static String RECORDTYPERECLAMACION = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    final static String RECORDTYPECONSULTA = mapRTsObjects.get('Case').get('SAC_Consulta').getRecordTypeId();
    final static String RECORDTYPECONSULTASAC = mapRTsObjects.get('Case').get('SAC_ConsultaSAC').getRecordTypeId();
    final static String RECORDTYPEPRETENSION = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();
    final static String RECORDTYPEGRUPORESPONSABLE = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SAC_GrupoResponsableAccion').getRecordTypeId();
    final static String RECORDTYPEINTERACCION = mapRTsObjects.get('SAC_Interaccion__c').get('SAC_Consulta').getRecordTypeId();
    final static String RECORDTYPEACCION = mapRTsObjects.get('SAC_Accion__c').get('SAC_MaestroDeTareas').getRecordTypeId();
    final static string CLASSNAME = 'SAC_EmailServiceNew';
    


    public static Map<String, String> obtenerValoresPicklist(String nombreObjeto, String nombreCampo){
        Map<String, String> mapaValoresPicklist = new Map<String, String>();
        List<Schema.DescribeSobjectResult> resultados = Schema.describeSObjects(new List<String>{nombreObjeto});
        for(Schema.DescribeSobjectResult result: resultados){
            for(Schema.PicklistEntry unValor: result.fields.getMap().get(nombreCampo).getDescribe().getPicklistValues()){
                if(unValor.isActive()){
                    if(!mapaValoresPicklist.containsKey(unValor.getValue())){
                        mapaValoresPicklist.put(unValor.getValue(), unValor.getLabel());
                    }
                }
            }
        }

        return mapaValoresPicklist;


    }

    /*****************************************************************
    * Proposito: Procesa el email para asociarlo a un caso existente o crear uno nuevo
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US219261         Nicolás G.   15/06/21     Creación
    *****************************************************************/
    public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {        
        


        // Trazabilidad para registrar la entrada del correo.
        try{
            CBK_Log.auditemail(email,envelope);
        }catch (Exception e){
            // Método sobrecargado para registrar errores en con el objeto Messaging.InboundEmail.
            CBK_Log.error(e,'Error registrando entrada correo',email);
        }
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        result.success= false;
        
        EmailMessage emailMess = new EmailMessage();
        WrapperEmailResult wrapEmRes = new WrapperEmailResult();
        List<SAC_Interaccion__c> lstInteracciones = new List<SAC_Interaccion__c>();
        List<SAC_Accion__c> lstAcciones = new List<SAC_Accion__c>();
        
        try{
            
            String texto = email.htmlBody;
            if(String.isBlank(texto)){
                texto = email.plainTextBody;
            }
            
            String threadId = '';
            Boolean encontradoThread = false;
            Boolean encontradoInteraccionTarea = false;
            
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
            
            if(encontradoThread){
               
                lstInteracciones = [SELECT Id, SAC_Reclamacion__c,SAC_FechaRespuesta__c,SAC_EmailRespuesta__c,SAC_Estado__c,SAC_IndexedThreadId__c, RecordTypeId, SAC_Respuesta__c,
                                                          SAC_GrupoColaborador__r.SAC_DeveloperName__c
                                                          FROM SAC_Interaccion__c
                                                          WHERE RecordTypeId = :RECORDTYPEINTERACCION AND SAC_IndexedThreadId__c = :threadID LIMIT 1];
                
                lstAcciones = [SELECT Id, SAC_Reclamacion__c,SAC_Estado__c,SAC_IndexedThreadId__c, RecordTypeId
                                                FROM SAC_Accion__c
                                                WHERE RecordTypeId = :RECORDTYPEACCION AND SAC_IndexedThreadId__c = :threadID LIMIT 1];
                
                /* Comprobamos que la lista no este vacia, iteramos y assignamos los 
                * campos necesarios y finalmente updateamos la lista.
                */
                if (!lstInteracciones.isEmpty()) {
                    encontradoInteraccionTarea = true;
                    String fechaFormateada = emailDate.format('dd') + '/' + emailDate.format('MM') + '/' + emailDate.format('yyyy') + ', ' + emailDate.format('kk:mm');
                    for (SAC_Interaccion__c interaccion : lstInteracciones) {
                        //US632598 - Concatenar respuesta si ya tenemos una respuesta existente (consultas oficina)
                        if(interaccion.SAC_GrupoColaborador__r.SAC_DeveloperName__c == 'OFICINA'){
                            if(interaccion.SAC_Respuesta__c == null){
                                interaccion.SAC_Respuesta__c = '<b>Respuesta Email </b>' + fechaFormateada + '<br/><br/>' + texto.left(32200);
                            }else{
                                interaccion.SAC_Respuesta__c = interaccion.SAC_Respuesta__c + '<br/><br/><b>Respuesta Email </b>' + fechaFormateada + '<br/><br/>' + texto.left(32200);
                            }
                            interaccion.SAC_Motivo_Devolucion__c = 'SAC_RespondidaPorEmail';
                        }else{
                            interaccion.SAC_Respuesta__c = texto.left(32200);
                        }
                        interaccion.SAC_FechaRespuesta__c = emailDate;
                        interaccion.SAC_EmailRespuesta__c = email.fromAddress;
                        interaccion.SAC_Estado__c = 'SAC_Resuelta';               
                    } 
                    
                    wrapEmRes = emailConsulta(lstInteracciones[0].Id, email, lstInteracciones[0].SAC_Reclamacion__c );
                    result.success = wrapEmRes.result;
                    emailMess = wrapEmRes.eMessage;
                    
                    SAC_Utils.updateInteraccion(JSON.serialize(lstInteracciones));
                    
                }
                
                if (!lstAcciones.isEmpty()) {
                    encontradoInteraccionTarea = true;
                    for (SAC_Accion__c accion : lstAcciones) {
                        accion.SAC_Comentarios2__c = texto.left(32200);
                        accion.SAC_Estado__c = 'SAC_Finalizada';
                        accion.OwnerId = UserInfo.getUserId();
                        accion.SAC_SaltarValidacion__c = true;               
                    } 
                    
                    wrapEmRes = emailConsulta(lstAcciones[0].Id, email, lstAcciones[0].SAC_Reclamacion__c );
                    result.success = wrapEmRes.result;
                    emailMess = wrapEmRes.eMessage;
                    
                    SAC_Utils.updateAlerta(JSON.serialize(lstAcciones));
                    
                }
                
            }
            if(!encontradoInteraccionTarea){
                String subjectRecortado = '';
                if (String.isNotBlank(email.subject)) {
                    subjectRecortado = email.subject.left(255).stripHtmlTags();
                }
                String emailFromAddress = '';
                if (String.isNotBlank(email.fromAddress)) {
                    emailFromAddress = email.fromAddress;
                }
                List<Case> listaCaso = [SELECT id, RecordTypeId, Status, CaseNumber, OwnerId, SAC_AlertasPtes__c, SAC_Reclamacion__c,
                                        SAC_PretensionPrincipal__r.OwnerId, SAC_Reclamacion__r.OwnerId, CC_SuppliedUser__c, Description, recordType.DeveloperName,
                                        CC_SuppliedID__c, SuppliedEmail, Subject
                                        FROM Case WHERE RecordTypeId IN (:RECORDTYPERECLAMACION, :RECORDTYPECONSULTASAC, :RECORDTYPEPRETENSION)
                                        AND CC_SuppliedID__c =: threadId LIMIT 1];
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
                    //Comprobar parametrizaciones de custom settings para saber si el email entrante debe crear un tipo de caso u otro (reclamación, consulta COPS)
                    SAC_EmailService__c parametrizacion = SAC_Utils.comprobarCustomSettings(email, 'SAC_Reclamacion');
                    
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
                    //cola usada en caso de que la reclamación se "prerechace" y le tocase tratarse por IA
                    QueueSobject colaStandard = null;
                    //List<QueueSobject> colas = [SELECT QueueId FROM QueueSobject WHERE queue.DeveloperName = 'SAC_PendienteAsignar' AND SobjectType = 'Case' LIMIT 1];
                    //string resultCola = SAC_GenialUtils.randomizador();
                    
                    //list<string> colaSpliteada = SAC_GenialUtils.randomizador().split(';');
                    list<string> colaSpliteada = SAC_GenialUtils.randomizador('Email').split(';');
                    string nombreCola = colaSpliteada[0];
                    List<QueueSobject> colas = new list<QueueSobject>();
                    if(Schema.sObjectType.QueueSobject.isAccessible() && 
                    Schema.sObjectType.QueueSobject.fields.QueueId.isAccessible() &&
                    Schema.sObjectType.Group.fields.DeveloperName.isAccessible()) {

                        colas = [SELECT QueueId, queue.DeveloperName FROM QueueSobject WHERE (queue.DeveloperName = : nombreCola OR queue.DeveloperName = 'SAC_PendienteAsignar') 
                                                AND SobjectType = 'Case' LIMIT 2];
                    }
                    
                    for(QueueSobject co : colas) {
                        if(nombreCola == co.queue.DeveloperName){
                            cola = co;
                        } else {
                            colaStandard = co;
                        }
                    } 
                    /*if(!colas.isEmpty()){
                        cola = colas[0];
                    }*/    
                    
                    //Crear caso
                    Case reclamacionNueva = SAC_Utils.prepararCasosNuevos(parametrizacion, mapaGruposIds, email, cola, RECORDTYPERECLAMACION);
                    
                    
                    if (reclamacionNueva != null) {
                        boolean bIA = false;
                        Database.SaveResult resultado = null;
                        if(colaSpliteada.size() == 2){
                            reclamacionNueva.SAC_GenialEstado__c = 'SAC_005';
                            bIA = true;
                        }
                        reclamacionNueva.OwnerId = cola.QueueId;
                        
                        //Hacer reglas de validacion antes del insert del caso
                        SAC_Utils.WrapperReglaClasificacion wrapRC = new SAC_Utils.WrapperReglaClasificacion();
                        wrapRC = SAC_Utils.determinarCR(email.fromAddress, email.toAddresses, email.ccAddresses, email.Subject, texto, reclamacionNueva.RecordTypeId);

                        if (String.isNotBlank(wrapRC.id)) {
                            reclamacionNueva.OS_ReglaUtilizada__c = wrapRC.id;
                            //comprobamos si ya ha sido rechazada previamente para no enviarla a la IA
                            if((wrapRC.estado == 'Rechazado' || wrapRC.estado == 'SAC_013')){
                                reclamacionNueva.SAC_GenialEstado__c = null;
                                bIA = false;
                                if(colaStandard != null){
                                    reclamacionNueva.OwnerId = colaStandard.queueId;
                                }
                            }
                        }
                        
                        //caso.CC_AcuseRecibo__c = '1'; esta linea se ha comentado para que no se quede el acuse de recibo en 1. Al no introducir un valor, manda el acuse de recibo y se updatea a 2 (dia 7/11/22)
                        resultado = Database.insert(reclamacionNueva);
                        
                        wrapEmRes = emailTask(reclamacionNueva.Id, email, RECORDTYPETAREA, '', reclamacionNueva.RecordTypeId);
                        Map<String,Boolean> mapaResultadoEmailTask = wrapEmRes.mapaResultado;
                        emailMess = wrapEmRes.eMessage;
                        
                        result.success= mapaResultadoEmailTask.get('resultado');
                        reclamacionNueva.SourceId = [SELECT id FROM EmailMessage WHERE ParentId =: reclamacionNueva.id AND Incoming = true LIMIT 1].id;
                        reclamacionNueva.SAC_UltimaModificacionFichero__c = (mapaResultadoEmailTask.get('tieneAttachments')) ? emailDate : null;
                        resultado = Database.update(reclamacionNueva);

                        //si la reclamacion esta en database correctamente enviar a IA
                        if (resultado.isSuccess() && bIA){
                            String idReclamacion = resultado.getId();
                            //SAC_GenialSendAzure.sendToIA(idReclamacion, reclamacionNueva.Description);
                            SAC_GenialUtils.balanceador(idReclamacion, 'Email', reclamacionNueva.Description);
                        }
                    }
                } else if(linkarEmailACasoExistente) {
                    //Preparar alerta de email entrante
                    List<SAC_WrapperAlerta> listaAlertas = prepararAlertas(casoConThreadId);
                    String statusLlegadaMail = casoConThreadId.Status; //Almacena el estado del caso al momento de llegada del mail
           

                    if(casoConThreadId.RecordTypeId == RECORDTYPECONSULTA && (casoConThreadId.Status == 'SAC_008' || casoConThreadId.Status == 'SAC_012' || casoConThreadId.Status == 'SAC_013')){
                        casoConThreadId.Status='SAC_011';
                        casoConThreadId.SAC_StatusAuxiliar__c = casoConThreadId.Status;
                    }
                    

                    if (!listaAlertas.isEmpty()) {
                        SAC_EmailServiceNew.generarAlertasFuturo(JSON.serialize(listaAlertas));
                    }
                    
                    //Añadido para recortar la description del caso
                    //listaCaso[0].Description = listaCaso[0].Description.left(32000);
                    Database.SaveResult resultado = null;
                    resultado = Database.update(casoConThreadId);
                    
                    wrapEmRes = emailTask(casoConThreadId.Id, email, RECORDTYPETAREA, statusLlegadaMail, casoConThreadId.RecordTypeId);
                    result.success = wrapEmRes.mapaResultado.get('resultado');
                    emailMess = wrapEmRes.eMessage;
                }
                
            }
        }catch(Exception e){
            // Método sobrecargado para registrar errores en con el objeto Messaging.InboundEmail.
            CBK_Log.error(e,'Error procesando el correo entrante',email);
        }
        
        // Trazabilidad para registrar el procesamiento del correo.
        //Añadido US527358
        try{
            CBK_Log.ResultWrapper resultado = new CBK_Log.ResultWrapper();
            resultado.Status = (result.success) ? 'OK' : 'KO';
            resultado.Detail = (result.success) ? 'Envio correcto' : 'Error procesando el correo';
            if (!lstInteracciones.isEmpty() || !lstAcciones.isEmpty()) {
                resultado.CaseId = emailMess.RelatedToId;
            }else{
               resultado.CaseId = emailMess.ParentId; 
            }
            resultado.EmailMessageId = emailMess.Id;
            CBK_Log.auditemailResult(resultado, email);
        }catch (Exception e){
            // Método sobrecargado para registrar errores en con el objeto Messaging.InboundEmail.
            CBK_Log.error(e,'Error registrando procesamiento correo',email);
        }
        
        return result;
        
    }
    
    /*************************************************************************
    * Proposito: Metodo para asociar el email a la Consulta
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US219270         Esteve Llaó    09/07/2021   Creación
    **************************************************************************/
    public static WrapperEmailResult emailConsulta(Id idConsulta, Messaging.InboundEmail email, Id idReclamacion ){
        
        Boolean resultado = false;
        WrapperEmailResult wrappEmResult = new WrapperEmailResult();
        
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
        
        EmailMessage contentEmMes = new EmailMessage();
        
        
        contentEmMes.RelatedToId    = idConsulta;
        //contentEmMes.ParentId       = idConsulta;
        contentEmMes.ToAddress      = (email.toAddresses != null)?String.join(email.toAddresses, ','):null;
        contentEmMes.FromAddress    = email.FromAddress;
        contentEmMes.FromName       = email.FromName;
        contentEmMes.Subject        = subject;
        contentEmMes.HtmlBody       = htmlBody;
        contentEmMes.Status         = '3';
        contentEmMes.Incoming       = true;
        contentEmMes.TextBody       = plainTextBody;
        contentEmMes.Headers        = JSON.serialize(email.headers);
        contentEmMes.CC_Aplicacion__c = 'SAC';
        //Añadido US527358
        contentEmMes.MessageIdentifier = email.messageId;
        contentEmMes.CBK_sfdcMessageId__c = email.messageId?.left(255);
        contentEmMes.ThreadIdentifier = email.inReplyTo;
        
        //Try
        try{
            if(email.ccAddresses != null){
                contentEmMes.CcAddress=String.join(email.ccAddresses,',');
            }
            
            SAC_DatabaseDML.insertDML(contentEmMes, false);
            resultado = true; 
            
            // Add Email Message Relation for id of the sender
            EmailMessageRelation emr = new EmailMessageRelation();
            emr.EmailMessageId = contentEmMes.id;
            emr.RelationAddress = email.FromAddress;
            emr.RelationType = 'FromAddress';
            if(Schema.sObjectType.EmailMessageRelation.isCreateable()){
                SAC_DatabaseDML.insertDML(emr, false);
            }
        }catch(Exception e){
            CBK_Log.error(e,'Error procesando el correo entrante',email);
        }

        //Guardamos los attachments si hubiese alguno
        if(resultado=true){
            Map<String, ContentVersion> attachmentsMap= handleAttachments(email);
            
            if ( !attachmentsMap.isEmpty() ) {
                try{
                    List<ContentVersion> listaContents = attachmentsMap.values();
                    SAC_DatabaseDML.insertListDML(listaContents, false);
                    
                    List<ContentVersion> listaContentsInsertados = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE ID IN: listaContents];
                    
                    List<ContentDocumentLink> contentLinks = new List<ContentDocumentLink>();
                    for(ContentVersion cv :listaContentsInsertados){
                        ContentDocumentLink cdl = new ContentDocumentLink(LinkedEntityId = contentEmMes.id,
                                                                          ContentDocumentId = cv.ContentDocumentId,
                                                                          ShareType = 'V');
                        contentLinks.add(cdl);
                        
                        ContentDocumentLink cdlCaso = new ContentDocumentLink(LinkedEntityId = idConsulta,
                                                                              ContentDocumentId = cv.ContentDocumentId,
                                                                              ShareType = 'V');
                        
                        contentLinks.add(cdlCaso);
                    }
                    SAC_DatabaseDML.insertListDML(contentLinks, false);
                }catch(Exception e){
                    // Método sobrecargado para registrar errores en con el objeto Messaging.InboundEmail.
                    CBK_Log.error(e,'Error procesando el correo entrante',email);
                }
                
            }
            
            String imageURL = '/servlet/servlet.FileDownload?file=';
            String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm() + imageURL;
            
            for ( String contentId : attachmentsMap.keySet() ) {
                
                if (String.isNotBlank(attachmentsMap.get( contentId ).id)) {
                    String cid = contentId.replace( '<', '' ).replace( '>', '' );
                    String url = fullFileURL + String.valueOf( attachmentsMap.get( contentId ).id ).left( 15 );
                    
                    contentEmMes.textBody = (String.isNotBlank(contentEmMes.textBody))?contentEmMes.textBody.replaceAll( 'cid:' + cid, url ):contentEmMes.textBody;
                    if(String.isNotBlank(contentEmMes.textBody)){
                        contentEmMes.textBody = contentEmMes.textBody.left(130000);
                    }
                    contentEmMes.htmlBody = (String.isNotBlank(contentEmMes.htmlBody))?contentEmMes.htmlBody.replaceAll( 'cid:' + cid, url ):contentEmMes.htmlBody;
                    if(String.isNotBlank(contentEmMes.htmlBody)){
                        contentEmMes.htmlBody = contentEmMes.htmlBody.left(130000);
                    }
                }
                
            }
            //Try
            try{
                if(Schema.sObjectType.EmailMessage.isUpdateAble()){
                    SAC_DatabaseDML.updateDML(contentEmMes, false);
                    resultado = true; 
                }
            }catch(Exception e){
                CBK_Log.error(e,'Error procesando el correo entrante',email);
            }
        }  
        wrappEmResult.result = resultado;
        wrappEmResult.eMessage = contentEmMes;
        return wrappEmResult;
    }
    
    /*****************************************************************
    * Proposito: Decide asociar el email al caso o crear un nuevo caso, asociando el email y el contacto o medio de contacto.
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US219261         Nicolás G.   15/06/21         Creación
    * 1.1           US751370          Álex          11/11/2024      Añadido recoger el estado de la reclamación
    *****************************************************************/
    //public static WrapperEmailResult emailTask(ID casoid, Messaging.InboundEmail email, Id taskTR)
    public static WrapperEmailResult emailTask(ID casoid, Messaging.InboundEmail email, Id taskTR, String estadoCaso, Id casoRecordType){
        Boolean resultado = false;
        Boolean tieneAttachments = false;
        Map<String,Boolean> mapaResultado = new Map<String,Boolean>();
        WrapperEmailResult wrapEmailRes = new WrapperEmailResult();
        

        Integer maxLengthSubject = EmailMessage.Subject.getDescribe().getLength()-1;
        
        String plainTextBody;
        String htmlBody;
        String subject;
        
        //Obtener valores picklist de status
        Map<String, String> mapaValoresPicklistStatus = new Map<String, String>();
        mapaValoresPicklistStatus = obtenerValoresPicklist('Case', 'Status');

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
        conEmailMessage.Headers     = JSON.serialize(email.headers).left(32000);
        if(email.ccAddresses != null){
            conEmailMessage.CcAddress=String.join(email.ccAddresses,',');
        }
        //Añadido US527358
        conEmailMessage.MessageIdentifier = email.messageId;
        conEmailMessage.CBK_sfdcMessageId__c = email.messageId?.left(255);
        conEmailMessage.ThreadIdentifier = email.inReplyTo;

        //Añadido US751370-> No se recoge el estado si es un estado que cierra la reclamación
        if(mapaValoresPicklistStatus.containsKey(estadoCaso) && casoRecordType == RECORDTYPERECLAMACION && estadoCaso != 'Closed' && estadoCaso != 'SAC_008' && estadoCaso != 'SAC_014' && estadoCaso != 'Cerrado' && estadoCaso != 'Rechazado'){
            conEmailMessage.SAC_CaseStatus__c = mapaValoresPicklistStatus.get(estadoCaso);
        }

        //Try
        try{
        SAC_DatabaseDML.insertDML(conEmailMessage, false);

        resultado = true; 
        }catch(Exception e){
            CBK_Log.error(e,'Error procesando el correo entrante',email);
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
            }
            if(resultado=true){
                createTask(casoid, email.Subject, TaskTR);
            }
        }catch(Exception e){
            CBK_Log.error(e,'Error procesando el correo entrante',email);
        }

        //Guardamos los attachments si hubiese alguno
        if(resultado=true){	
            Map<String, ContentVersion> attachmentsMap= handleAttachments(email);
            
            if ( !attachmentsMap.isEmpty() ) {
                try{
                    tieneAttachments = true;
                    List<ContentVersion> listaContents = attachmentsMap.values();
                    SAC_DatabaseDML.insertListDML(listaContents, false);
                    
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
                    SAC_DatabaseDML.insertListDML(contentLinks, false);
                }catch(Exception e){
                    // Método sobrecargado para registrar errores en con el objeto Messaging.InboundEmail.
                    CBK_Log.error(e,'Error procesando el correo entrante',email);
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
            
            try{
                if(Schema.sObjectType.EmailMessage.isUpdateAble()){
                    SAC_DatabaseDML.updateDML(conEmailMessage, false);
                    resultado = true; 
                }
            }catch(Exception e){
                CBK_Log.error(e,'Error procesando el correo entrante',email);
            }
        } 
        
        mapaResultado.put('resultado', resultado);
        mapaResultado.put('tieneAttachments', tieneAttachments);
        
        wrapEmailRes.mapaResultado = mapaResultado;
        wrapEmailRes.eMessage = conEmailMessage;
        
        return wrapEmailRes;
    }
    
    /*****************************************************************
    * Proposito: Determina si existe un caso relacionado por threadId y de haberlo, asocia el caso al email.
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US219261         Nicolás G   15/06/21     Creación
    *****************************************************************/
    public static WrapperEmailResult caseRelated(Messaging.InboundEmail email){
        String caseID = null; 
        WrapperEmailResult wrapEmRes = new WrapperEmailResult();
        wrapEmRes.mapaResultado.put('resultado', false);
        
        caseID = Cases.getCaseIdFromEmailHeaders(email.headers);
        
        //Si existe ya un caso se añade el mail al hilo
        if(caseID != null){
            wrapEmRes = emailTask(caseID, email, RECORDTYPETAREA, '', '');
            return wrapEmRes;
        }else{
            return wrapEmRes;
        }
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
        Task tarea= new Task();
        tarea.Type = 'Email';
        tarea.WhatId = casoid;
        tarea.Subject = subject.left(255).stripHtmlTags(); 
        tarea.Status = 'Completed';
        tarea.ActivityDate= system.today();
        tarea.RecordTypeId = TaskTR;
        if(Schema.sObjectType.Task.isCreateable()){
            SAC_DatabaseDML.insertDML(tarea, false);
        }
    }
    
    /*****************************************************************
    * Proposito: Crear alertas
    */
    @future
    public static void generarAlertasFuturo(String jsonAlertas) {
        List<SAC_WrapperAlerta> lstAlertas = (List<SAC_WrapperAlerta>)Json.deserialize(jsonAlertas,List<SAC_WrapperAlerta>.class);
        try{
            SAC_Alertas.generarAlertas(lstAlertas);
        } catch (Exception e) {
            CBK_Log.error(e);
        }  
    }
    
    private static List<SAC_WrapperAlerta> prepararAlertas(Case casoAux) {
        List<SAC_WrapperAlerta> listaAlertas = new List<SAC_WrapperAlerta>();
        /*
        Dependiendo del estado del caso, se mandará una alerta de:
        Nuevo correo asociado a la reclamación
        Respuesta a la subsanación (SAC_006)
        Respuesta a la negociación (SAC_007)
        */
        if (casoAux.Status == 'SAC_006') {
            //Si el campo SAC_Reclamacion__c está en blanco, significa que es una reclamación
            if (String.isBlank(casoAux.SAC_Reclamacion__c)) {
                SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(casoAux.Id, 'SAC_001', 'La reclamación número ' + casoAux.CaseNumber +' ha recibido un correo.', casoAux.OwnerId, '', '', '');
                wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + casoAux.Id;
                //Añadido. Si el CC_SuppliedUser__c es Let, la envio al letrado
                if (String.isNotBlank(casoAux.CC_SuppliedUser__c) && casoAux.CC_SuppliedUser__c == 'Let' && String.isNotBlank(casoAux.SAC_PretensionPrincipal__r.OwnerId)) {
                    wrapAlerta.idUsuarioDestinatario = casoAux.SAC_PretensionPrincipal__r.OwnerId;
                }
                listaAlertas.add(wrapAlerta);    
            } else { //De lo contrario, es una pretensión
                SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(casoAux.SAC_Reclamacion__c, 'SAC_001', 'La pretensión número ' + casoAux.CaseNumber +' ha recibido un correo.', casoAux.OwnerId, casoAux.Id, '', '');
                wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + casoAux.Id;
                //Añadido. Si el CC_SuppliedUser__c es Ges, la envio al gestor
                if (String.isNotBlank(casoAux.CC_SuppliedUser__c) && casoAux.CC_SuppliedUser__c == 'Ges' && String.isNotBlank(casoAux.SAC_Reclamacion__r.OwnerId)) {
                    wrapAlerta.idUsuarioDestinatario = casoAux.SAC_Reclamacion__r.OwnerId;
                }
                listaAlertas.add(wrapAlerta);
            }
        } else if (casoAux.Status == 'SAC_007') {
            //Si el campo SAC_Reclamacion__c está en blanco, significa que es una reclamación
            if (String.isBlank(casoAux.SAC_Reclamacion__c)) {
                SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(casoAux.Id, 'SAC_002', 'La reclamación número ' + casoAux.CaseNumber +' ha recibido un correo.', casoAux.OwnerId, '', '', '');
                wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + casoAux.Id;
                //Añadido. Si el CC_SuppliedUser__c es Let, la envio al letrado
                if (String.isNotBlank(casoAux.CC_SuppliedUser__c) && casoAux.CC_SuppliedUser__c == 'Let' && String.isNotBlank(casoAux.SAC_PretensionPrincipal__r.OwnerId)) {
                    wrapAlerta.idUsuarioDestinatario = casoAux.SAC_PretensionPrincipal__r.OwnerId;
                }
                listaAlertas.add(wrapAlerta);
            } else { //De lo contrario, es una pretensión
                SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(casoAux.SAC_Reclamacion__c, 'SAC_002', 'La pretensión número ' + casoAux.CaseNumber +' ha recibido un correo.', casoAux.OwnerId, casoAux.Id, '', '');
                wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + casoAux.Id;
                //Añadido. Si el CC_SuppliedUser__c es Ges, la envio al gestor
                if (String.isNotBlank(casoAux.CC_SuppliedUser__c) && casoAux.CC_SuppliedUser__c == 'Ges' && String.isNotBlank(casoAux.SAC_Reclamacion__r.OwnerId)) {
                    wrapAlerta.idUsuarioDestinatario = casoAux.SAC_Reclamacion__r.OwnerId;
                }
                listaAlertas.add(wrapAlerta);
            }
        } else {
            //Si el campo SAC_Reclamacion__c está en blanco, significa que es una reclamación
            if (String.isBlank(casoAux.SAC_Reclamacion__c)) {
                SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(casoAux.Id, 'SAC_006', 'La reclamación número ' + casoAux.CaseNumber +' ha recibido un correo.', casoAux.OwnerId, '', '', '');
                wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + casoAux.Id;
                //Añadido. Si el CC_SuppliedUser__c es Let, la envio al letrado
                if (String.isNotBlank(casoAux.CC_SuppliedUser__c) && casoAux.CC_SuppliedUser__c == 'Let' && String.isNotBlank(casoAux.SAC_PretensionPrincipal__r.OwnerId)) {
                    wrapAlerta.idUsuarioDestinatario = casoAux.SAC_PretensionPrincipal__r.OwnerId;
                }
                listaAlertas.add(wrapAlerta);
            } else { //De lo contrario, es una pretensión
                SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(casoAux.SAC_Reclamacion__c, 'SAC_006', 'La pretensión número ' + casoAux.CaseNumber +' ha recibido un correo.', casoAux.OwnerId, casoAux.Id, '', '');
                wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + casoAux.Id;
                //Añadido. Si el CC_SuppliedUser__c es Ges, la envio al gestor
                if (String.isNotBlank(casoAux.CC_SuppliedUser__c) && casoAux.CC_SuppliedUser__c == 'Ges' && String.isNotBlank(casoAux.SAC_Reclamacion__r.OwnerId)) {
                    wrapAlerta.idUsuarioDestinatario = casoAux.SAC_Reclamacion__r.OwnerId;
                }
                listaAlertas.add(wrapAlerta);
            }
        }
        
        return listaAlertas;
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