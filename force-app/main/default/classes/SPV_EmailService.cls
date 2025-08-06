public with sharing class SPV_EmailService implements Messaging.InboundEmailHandler {

    private static Set<String> objetos = new Set<String>{'Case', 'CC_Grupo_Colaborador__c', 'SAC_Interaccion__c', 'SAC_Accion__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);
    
    final static String RECORDTYPERECLAMACION = mapRTsObjects.get('Case').get('SPV_Reclamacion').getRecordTypeId();
    final static String RECORDTYPEPRETENSION = mapRTsObjects.get('Case').get('SPV_Pretension').getRecordTypeId();
    final static String RECORDTYPEGRUPORESPONSABLE = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SPV_GrupoDeTareas').getRecordTypeId();
    final static String RECORDTYPEINTERACCION = mapRTsObjects.get('SAC_Interaccion__c').get('SPV_Consulta').getRecordTypeId();
    final static String RECORDTYPEINTERACCION_TAREA = mapRTsObjects.get('SAC_Interaccion__c').get('SPV_ConsultaTarea').getRecordTypeId();
    final static String RECORDTYPEACCION = mapRTsObjects.get('SAC_Accion__c').get('SPV_MaestroDeTareas').getRecordTypeId();
    
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

        try {
            String texto = email.htmlBody;
            if(String.isBlank(texto)){
                texto = email.plainTextBody;
            }
            
            String threadId = '';
            Boolean encontradoThread = false;
            Boolean encontradoInteraccionTarea = false;
            
            //Guardar la fecha original del mensaje entrante
            Datetime emailDate = recuperarFechaEmail(email);

            //Obtenemos el ThreadId del mensaje entrante en el formato correcto.
            if (String.isNotBlank(texto)){
                threadId = texto.substringAfter('ref:_').substringBefore(':ref');
                if(String.isNotBlank(threadId)){  
                    encontradoThread = true;
                }
                threadId = ('ref:_' + threadId + ':ref');
            }
            
            if(encontradoThread){
                //Búsqueda de interacciones
                lstInteracciones = [SELECT Id, SAC_Reclamacion__c,SAC_FechaRespuesta__c,SAC_EmailRespuesta__c,SAC_Estado__c,SAC_IndexedThreadId__c, RecordTypeId, SAC_Respuesta__c,
                                                          SAC_GrupoColaborador__r.SAC_DeveloperName__c
                                                          FROM SAC_Interaccion__c
                                                          WHERE RecordTypeId IN (:RECORDTYPEINTERACCION, :RECORDTYPEINTERACCION_TAREA) AND SAC_IndexedThreadId__c = :threadID LIMIT 1];
                //Búsqueda de acciones
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
                        //Concatenar respuesta si ya tenemos una respuesta existente (consultas oficina)
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
                    
                    SPV_DatabaseDML.updateListDML(lstInteracciones, false);
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
                    
                    SPV_DatabaseDML.updateListDML(lstAcciones, false);
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
                                        CC_SuppliedID__c, SuppliedEmail, Subject, SEG_Subestado__c
                                        FROM Case WHERE RecordTypeId IN (:RECORDTYPERECLAMACION, :RECORDTYPEPRETENSION)
                                        AND CC_SuppliedID__c =: threadId LIMIT 1];
                /*
                Comprobar que el body del mail recibido tenga threadId y buscar un caso que lo tenga
                Si hay un caso con ese threadId, se añade el mail al caso
                */
                //Separar caso con thread id
                Case casoConThreadId = new Case();
                if (!listaCaso.isEmpty()) {
                    casoConThreadId = listaCaso[0];
                
                    //Preparar alerta de email entrante
                    List<SAC_WrapperAlerta> listaAlertas = prepararAlertas(casoConThreadId);
                    if (!listaAlertas.isEmpty()) {
                        SAC_EmailServiceNew.generarAlertasFuturo(JSON.serialize(listaAlertas));
                    }
                    
                    /*Database.SaveResult resultado = null;
                    resultado = Database.update(casoConThreadId);*/
                    
                    wrapEmRes = asociarEmailCaso(casoConThreadId.Id, email);
                    result.success = wrapEmRes.mapaResultado.get('resultado');
                    emailMess = wrapEmRes.eMessage;
                }
            }
        } catch (Exception e) {
            // Método sobrecargado para registrar errores en con el objeto Messaging.InboundEmail.
            CBK_Log.error(e,'Error procesando el correo entrante',email);
        }

        //Trazabilidad para registrar el procesamiento del correo.
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

    /**
	 * Método para recuperar la fecha original del mensaje entrante
	 */
    public static Datetime recuperarFechaEmail(Messaging.InboundEmail email) {

		String fechaEmail = '';
        Datetime emailDate;
       
		// Recuperar la fecha en la que se envió el email
		for(Messaging.InboundEmail.Header header : email.headers){
			if (header.name == 'Date') {
				fechaEmail = header.value;
			}
		}

		// Separar la cadena en sus componentes, formato que se recoge la fecha -> Ejemplo: Wed, 13 Sep 2023 08:43:40 +0000
		List<String> parts = fechaEmail.split(' ');  

		if (parts.size() >= 5) {
			// Mapear el mes a su equivalente numérico
			Map<String, String> monthMap = new Map<String, String>{
				'Jan' => '01', 'Feb' => '02', 'Mar' => '03', 'Apr' => '04', 'May' => '05', 'Jun' => '06',
				'Jul' => '07', 'Aug' => '08', 'Sep' => '09', 'Oct' => '10', 'Nov' => '11', 'Dec' => '12'
			};
		
			// Explicación -> parts[1] = dia, parts[2] mes, parts[3] año, parts[4] hora(global), timeParts[0] hora, timeParts[1] minutos, timeParts[2] segundo
			String[] timeParts = parts[4].split(':');
		
			// Convertir la fecha en un objeto Datetime
			try {
				emailDate = Datetime.newInstanceGmt(Integer.valueOf(parts[3]), Integer.valueOf(monthMap.get(parts[2])), Integer.valueOf(parts[1]), Integer.valueOf(timeParts[0]), Integer.valueOf(timeParts[1]), Integer.valueOf(timeParts[2]));
			} catch (Exception e) {
				CBK_Log.error('Error al convertir la fecha: ' + e.getMessage());
			}
		}else{
			emailDate = System.now();
		}

        return emailDate;
    }

    /*************************************************************************
    * Proposito: Metodo para asociar el email a la Consulta
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            --------
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
        
        if(email.ccAddresses != null){
            contentEmMes.CcAddress=String.join(email.ccAddresses,',');
        }
        
        SPV_DatabaseDML.insertDML(contentEmMes, false);
        resultado = true; 
        
        // Add Email Message Relation for id of the sender
        EmailMessageRelation emr = new EmailMessageRelation();
        emr.EmailMessageId = contentEmMes.id;
        emr.RelationAddress = email.FromAddress;
        emr.RelationType = 'FromAddress';
        if(Schema.sObjectType.EmailMessageRelation.isCreateable()){
            SPV_DatabaseDML.insertDML(emr, false);
        }
        
        //Guardamos los attachments si hubiese alguno
        if(resultado=true){
            Map<String, ContentVersion> attachmentsMap= handleAttachments(email);
            
            if ( !attachmentsMap.isEmpty() ) {
                try{
                    List<ContentVersion> listaContents = attachmentsMap.values();
                    SPV_DatabaseDML.insertListDML(listaContents, false);
                    
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
                    SPV_DatabaseDML.insertListDML(contentLinks, false);
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
            if(Schema.sObjectType.EmailMessage.isUpdateAble()){
                SPV_DatabaseDML.updateDML(contentEmMes, false);
                resultado = true; 
            }
        }  
        wrappEmResult.result = resultado;
        wrappEmResult.eMessage = contentEmMes;
        return wrappEmResult;
    }

    /*****************************************************************
    * Proposito: Método para asociar los archivos adjuntos del email.
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            --------
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
    * 1.0            --------
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
    * Proposito: Decide asociar el email al caso o crear un nuevo caso, asociando el email y el contacto o medio de contacto.
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            --------
    *****************************************************************/
    public static WrapperEmailResult asociarEmailCaso(ID casoid, Messaging.InboundEmail email){
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
        conEmailMessage.Headers     = JSON.serialize(email.headers).left(32000);
        if(email.ccAddresses != null){
            conEmailMessage.CcAddress=String.join(email.ccAddresses,',');
        }
        conEmailMessage.MessageIdentifier = email.messageId;
        conEmailMessage.CBK_sfdcMessageId__c = email.messageId?.left(255);
        conEmailMessage.ThreadIdentifier = email.inReplyTo;
        
        SPV_DatabaseDML.insertDML(conEmailMessage, false);
        resultado = true;
        
        // Add Email Message Relation for id of the sender
        EmailMessageRelation emr = new EmailMessageRelation();
        emr.EmailMessageId = conEmailMessage.id;
        emr.RelationAddress = email.FromAddress;
        emr.RelationType = 'FromAddress';
        if(Schema.sObjectType.EmailMessageRelation.isCreateable()){
            SPV_DatabaseDML.insertDML(emr, false);
        }
        
        //Guardamos los attachments si hubiese alguno
        if(resultado=true){	
            Map<String, ContentVersion> attachmentsMap= handleAttachments(email);
            
            if ( !attachmentsMap.isEmpty() ) {
                try{
                    tieneAttachments = true;
                    List<ContentVersion> listaContents = attachmentsMap.values();
                    SPV_DatabaseDML.insertListDML(listaContents, false);
                    
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
                    SPV_DatabaseDML.insertListDML(contentLinks, false);
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
            
            if(Schema.sObjectType.EmailMessage.isUpdateAble()){
                SPV_DatabaseDML.updateDML(conEmailMessage, false);
                resultado = true; 
            }
        } 
        
        mapaResultado.put('resultado', resultado);
        mapaResultado.put('tieneAttachments', tieneAttachments);
        
        wrapEmailRes.mapaResultado = mapaResultado;
        wrapEmailRes.eMessage = conEmailMessage;
        
        return wrapEmailRes;
    }

    private static List<SAC_WrapperAlerta> prepararAlertas(Case casoAux) {
        List<SAC_WrapperAlerta> listaAlertas = new List<SAC_WrapperAlerta>();
        /*
        Dependiendo del estado del caso, se mandará una alerta de:
        Nuevo correo asociado a la reclamación
        Respuesta a la negociación (SEG_Subestado__c = 'Negociacion')
        */
        if (casoAux.SEG_Subestado__c == 'Negociacion') {
            //Si el campo SAC_Reclamacion__c está en blanco, significa que es una reclamación
            if (String.isBlank(casoAux.SAC_Reclamacion__c)) {
                SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(casoAux.Id, 'SPV_022', 'La reclamación ' + casoAux.CaseNumber +' ha recibido un correo.', casoAux.OwnerId, '', '', '');
                wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + casoAux.Id;
                //Añadido. Si el CC_SuppliedUser__c es Let, la envio al letrado
                if (String.isNotBlank(casoAux.CC_SuppliedUser__c) && casoAux.CC_SuppliedUser__c == 'Let' && String.isNotBlank(casoAux.SAC_PretensionPrincipal__r.OwnerId)) {
                    wrapAlerta.idUsuarioDestinatario = casoAux.SAC_PretensionPrincipal__r.OwnerId;
                }
                listaAlertas.add(wrapAlerta);
            }
        } else {
            //Si el campo SAC_Reclamacion__c está en blanco, significa que es una reclamación
            if (String.isBlank(casoAux.SAC_Reclamacion__c)) {
                SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(casoAux.Id, 'SPV_023', 'La reclamación ' + casoAux.CaseNumber +' ha recibido un correo.', casoAux.OwnerId, '', '', '');
                wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + casoAux.Id;
                //Añadido. Si el CC_SuppliedUser__c es Let, la envio al letrado
                if (String.isNotBlank(casoAux.CC_SuppliedUser__c) && casoAux.CC_SuppliedUser__c == 'Let' && String.isNotBlank(casoAux.SAC_PretensionPrincipal__r.OwnerId)) {
                    wrapAlerta.idUsuarioDestinatario = casoAux.SAC_PretensionPrincipal__r.OwnerId;
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