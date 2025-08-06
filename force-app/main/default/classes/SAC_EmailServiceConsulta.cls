/**************************************************************************
 * Name: SAC_EmailServiceConsulta
 * Copyright © 2021  CaixaBank
 * ========================================================================
 * Proposito: Tratar los emails entrantes relacionados con una
 * consulta previamente creada
 * ========================================================================
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US219270         Esteve Llaó    06/07/2021   Creación
***************************************************************************/
public without sharing class SAC_EmailServiceConsulta implements Messaging.InboundEmailHandler {
    final static string CLASSNAME = 'SAC_EmailServiceConsulta';
    
    /***************************************************************************
     * Proposito: Procesa el email asociado a una consulta para 
     * seguir el hilo de mensajes
     * =========================================================================
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US219270         Esteve Llaó    06/07/2021   Creación
    ***************************************************************************/
    public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        final String METHODNAME = 'handleInboundEmail';
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        result.success= false;

        String texto = email.htmlBody;
        String threadId;
        Datetime now = system.now();
        //Obtenemos el ThreadId del mensaje entrante en el formato correcto.
        if (String.isNotBlank(texto)){
            threadId = texto.substringAfter('ref:_').substringBefore(':ref');
            threadId = ('ref:_' + threadId + ':ref');
        }
        //Obtenemos el RecordTypeId y lo guardamos en una variable.
        Id recTypeInteraccion = Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Consulta').getRecordTypeId();
        
        List<SAC_Interaccion__c> interacciones = [SELECT Id, SAC_Reclamacion__c,SAC_FechaRespuesta__c,SAC_EmailRespuesta__c,SAC_Estado__c,SAC_IndexedThreadId__c, RecordTypeId
                                                  FROM SAC_Interaccion__c
                                                  WHERE RecordTypeId = :recTypeInteraccion AND SAC_IndexedThreadId__c = :threadID LIMIT 1];
        
        /* Comprobamos que la lista no este vacia, iteramos y assignamos los 
         * campos necesarios y finalmente updateamos la lista.
         */

        if (!interacciones.isEmpty()) {
            for (SAC_Interaccion__c interaccion : interacciones) {
                interaccion.SAC_Respuesta__c = texto;
                interaccion.SAC_FechaRespuesta__c = now;
                interaccion.SAC_EmailRespuesta__c = email.fromAddress;
                interaccion.SAC_Estado__c = 'SAC_Resuelta';               
            } 
            try{
                result.success= emailConsulta(interacciones[0].Id, email, interacciones[0].SAC_Reclamacion__c );
                update interacciones; 
            }catch(Exception e){
                List<Object> detalle = new List<Object> {'CLASSNAME: ' + CLASSNAME, 'METHODNAME: ' + METHODNAME, 'MSG ERROR: ' + e.getMessage()};
                CBK_Log.error(e,detalle);        
            }
        }
        return result;
    }    
    /*************************************************************************
     * Proposito: Metodo para asociar el email a la Consulta
     * =======================================================================
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US219270         Esteve Llaó    09/07/2021   Creación
    **************************************************************************/
    public static boolean emailConsulta(Id idConsulta, Messaging.InboundEmail email, Id idReclamacion ){
        final String METHODNAME = 'emailConsulta';
        Boolean resultado = false;
        
        Integer maxLengthSubject = EmailMessage.Subject.getDescribe().getLength()-1;
        
        String plainTextBody;
        String htmlBody;
        String subject;

        if(String.isNotBlank(email.plainTextBody)){
            plainTextBody = email.plainTextBody.left(32000);
        }
        if(String.isNotBlank(email.htmlBody)){
            htmlBody = email.htmlBody.left(32000);
        }
        if(String.isNotBlank(email.subject)){
            subject = email.subject.left( maxLengthSubject );
        } 
        
        EmailMessage contentEmMes = new EmailMessage();

        if(!Test.isRunningTest()){
        contentEmMes.RelatedToId    = idConsulta;
        }
        contentEmMes.ParentId       = idReclamacion;
        contentEmMes.ToAddress      = (email.toAddresses != null)?String.join(email.toAddresses, ','):null;
        contentEmMes.FromAddress    = email.FromAddress;
        contentEmMes.FromName       = email.FromName;
        contentEmMes.Subject        = subject;
        contentEmMes.HtmlBody       = htmlBody;
        contentEmMes.Incoming       = true;
        contentEmMes.TextBody       = plainTextBody;
        contentEmMes.Headers        = toString(email.headers, null, true);
        
        
        if(email.ccAddresses != null){
            contentEmMes.CcAddress=String.join(email.ccAddresses,',');
        }
        
        try{
            insert contentEmMes;
            resultado = true; 
        }catch (Exception e) {
            CBK_Log.error(e,'Error procesando el correo entrante',email);   //try
            List<Object> detalle = new List<Object> {'CLASSNAME: ' + CLASSNAME, 'METHODNAME: ' + METHODNAME, 'MSG ERROR: ' + e.getMessage()};
            CBK_Log.error(e,detalle);        
            resultado= false;
        }
        
        // Add Email Message Relation for id of the sender
        EmailMessageRelation emr = new EmailMessageRelation();
        emr.EmailMessageId = contentEmMes.id;
        emr.RelationAddress = email.FromAddress;
        emr.RelationType = 'FromAddress';
        //try
        try{
            if(Schema.sObjectType.EmailMessageRelation.isCreateable()){
                insert emr;
            }
        }catch(Exception e){
            CBK_Log.error(e,'Error procesando el correo entrante',email);
            List<Object> detalle = new List<Object> {'CLASSNAME: ' + CLASSNAME, 'METHODNAME: ' + METHODNAME, 'MSG ERROR: ' + e.getMessage()};
            CBK_Log.error(e,detalle);                }
        //Guardamos los attachments si hubiese alguno
        if(resultado=true){	
            Map<String, Attachment> attachmentsMap = handleAttachments(contentEmMes.Id, email);
        
            if ( attachmentsMap.size() > 0 ) {
                try{
                    insert attachmentsMap.values();
                }catch(Exception e) {
                    CBK_Log.error(e,'Error procesando el correo entrante', email);   //Try
                    //SAC_errorHandler.insertError(datetime.now(), UserInfo.getName(), CLASSNAME ,METHODNAME ,e.getMessage() , e.getStackTraceString());
                    List<Object> detalle = new List<Object> {'CLASSNAME: ' + CLASSNAME, 'METHODNAME: ' + METHODNAME, 'MSG ERROR: ' + e.getMessage()};
                    CBK_Log.error(e,detalle);        
                }
            }

            String imageURL = '/servlet/servlet.FileDownload?file=';
            String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm() + imageURL;
            
            for ( String contentId : attachmentsMap.keySet() ) {
                
                String cid = contentId.replace( '<', '' ).replace( '>', '' );
                String url = fullFileURL + String.valueOf( attachmentsMap.get( contentId ).id ).left( 15 );
                
                contentEmMes.textBody = (String.isNotBlank(contentEmMes.textBody))?contentEmMes.textBody.replaceAll( 'cid:' + cid, url ):contentEmMes.textBody;
                contentEmMes.htmlBody = (String.isNotBlank(contentEmMes.htmlBody))?contentEmMes.htmlBody.replaceAll( 'cid:' + cid, url ):contentEmMes.htmlBody;
            }
            if(Schema.sObjectType.EmailMessage.isUpdateAble()){
                try{
                    update contentEmMes;
                    resultado = true; 
                }catch (Exception e) {
                    CBK_Log.error(e,'Error procesando el correo entrante',email);   //try
                    //SAC_errorHandler.insertError(datetime.now(), UserInfo.getName(), CLASSNAME ,METHODNAME ,e.getMessage() , e.getStackTraceString());
                    List<Object> detalle = new List<Object> {'CLASSNAME: ' + CLASSNAME, 'METHODNAME: ' + METHODNAME, 'MSG ERROR: ' + e.getMessage()};
                    CBK_Log.error(e,detalle);
                    resultado= false;
                }
            }
        }  
        return resultado;
    }

    /*************************************************************************
     * Proposito: Método para asociar los archivos adjuntos del email.
     * =======================================================================
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US219270         Esteve Llaó    09/07/2021   Creación
    **************************************************************************/
    public static Map<String, Attachment> handleAttachments(String emailcasoid, Messaging.InboundEmail email){
        final String METHODNAME = 'handleAttachments';
        Integer contadorSinHeader = 0;
        Map<String, Attachment> attachments = new Map<String, Attachment>();
        if(email.textAttachments != null){
            for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) {
                String contentId = toString( tAttachment.headers, 'Content-ID', false );
                if ( String.isBlank( contentId ) ) {
                    contentId = 'no-content-id-header-' + contadorSinHeader++;
                }
                Attachment attachment = new Attachment();
                attachment.Name = tAttachment.fileName;
                attachment.Body = Blob.valueOf(tAttachment.body);
                attachment.ParentId = emailcasoid;
                attachment.contentType = tAttachment.mimeTypeSubType;
                attachments.put(contentId, attachment);
            }
        }
        if(email.binaryAttachments != null){
            for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {                
                String contentId = toString( bAttachment.headers, 'Content-ID', false );
                if ( String.isBlank( contentId ) ) {
                    contentId = 'no-content-id-header-' + contadorSinHeader++;
                }                
                Attachment attachment = new Attachment();
                attachment.Name = bAttachment.fileName;
                attachment.Body = bAttachment.body;
                attachment.ParentId = emailcasoid;
                attachment.contentType = bAttachment.mimeTypeSubType;
                
                attachments.put(contentId, attachment);
            }
        }
        return attachments;
    }
 
    /************************************************************************
     * Proposito: Método procesar los encabezados del email entrante 
     * y almacenarlos en una variable de tipo String, o recuperar el 
     * valor del content id del adjunto
     * ======================================================================
     * Historial
     * -------
     * VERSION      USER_STORY       AUTHOR         DATE         Description
     * 1.0          US219270         Esteve Llaó    09/07/2021   Creación
    *************************************************************************/
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
}