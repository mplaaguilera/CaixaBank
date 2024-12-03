/*****************************************************************
 * Name: SAC_EmailService
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
*****************************************************************/
public without sharing class SAC_EmailService implements Messaging.InboundEmailHandler {

    final static Id RECORDTYPETAREA = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('SAC_TareaMail').getRecordTypeId();
    final static String RECORDTYPERECLAMACION = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
    final static String RECORDTYPECONSULTA = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Consulta').getRecordTypeId();
    final static String RECORDTYPECONSULTASAC = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_ConsultaSAC').getRecordTypeId();
    final static String RECORDTYPEPRETENSION = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
    final static String RECORDTYPEGRUPORESPONSABLE = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoResponsableAccion').getRecordTypeId();
    final static string CLASSNAME = 'SAC_EmailService';
    
    /*****************************************************************
     * Proposito: Procesa el email para asociarlo a un caso existente o crear uno nuevo
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US219261         Nicolás G.   15/06/21     Creación
    *****************************************************************/
    public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {

        EmailMessage emailMess = new EmailMessage();
        try{
            CBK_log.auditemail(email, envelope);
            final String METHODNAME = 'handleInboundEmail';

            WrapperEmailResult wrapEmRes = new WrapperEmailResult();
            
            
            Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
            result.success= false;

            String texto = email.htmlBody;
            if(String.isBlank(texto)){
                texto = email.plainTextBody;
            }

            String threadId = '';
            Boolean encontradoThread = false;
            Boolean encontradoInteraccionTarea = false;
            Datetime now = system.now();
            //Obtenemos el ThreadId del mensaje entrante en el formato correcto.
            if (String.isNotBlank(texto)){
                threadId = texto.substringAfter('ref:_').substringBefore(':ref');
                if(String.isNotBlank(threadId)){  
                    encontradoThread = true;
                }
                threadId = ('ref:_' + threadId + ':ref');
            }

            if(encontradoThread){
                
                //Obtenemos el RecordTypeId y lo guardamos en una variable.
                Id recTypeInteraccion = Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Consulta').getRecordTypeId();
                Id recTypeMaestroAccion = Schema.SObjectType.SAC_Accion__c.getRecordTypeInfosByDeveloperName().get('SAC_MaestroDeTareas').getRecordTypeId();
                
                List<SAC_Interaccion__c> interacciones = [SELECT Id, SAC_Reclamacion__c,SAC_FechaRespuesta__c,SAC_EmailRespuesta__c,SAC_Estado__c,SAC_IndexedThreadId__c, RecordTypeId, SAC_Respuesta__c,
                                                        SAC_GrupoColaborador__r.SAC_DeveloperName__c
                                                        FROM SAC_Interaccion__c
                                                        WHERE RecordTypeId = :recTypeInteraccion AND SAC_IndexedThreadId__c = :threadID LIMIT 1];

                List<SAC_Accion__c> acciones = [SELECT Id, SAC_Reclamacion__c,SAC_Estado__c,SAC_IndexedThreadId__c, RecordTypeId
                                                        FROM SAC_Accion__c
                                                        WHERE RecordTypeId = :recTypeMaestroAccion AND SAC_IndexedThreadId__c = :threadID LIMIT 1];
                
                /* Comprobamos que la lista no este vacia, iteramos y assignamos los 
                * campos necesarios y finalmente updateamos la lista.
                */


                if (!interacciones.isEmpty()) {
                    encontradoInteraccionTarea = true;
                    Datetime fechaActual = Datetime.now();
                    String fechaFormateada = fechaActual.format('dd') + '/' + fechaActual.format('MM') + '/' + fechaActual.format('yyyy') + ' ' + fechaActual.format('kk:mm');
                    for (SAC_Interaccion__c interaccion : interacciones) {
                        //US632598 - Concatenar respuesta si ya tenemos una respuesta existente (consultas oficina)
                        if(interaccion.SAC_GrupoColaborador__r.SAC_DeveloperName__c == 'OFICINA'){
                            if(interaccion.SAC_Respuesta__c == null){
                                interaccion.SAC_Respuesta__c = '<b>Respuesta Email </b>' + fechaFormateada + '<br/><br/>' + texto.left(32200);
                            }else{
                                interaccion.SAC_Respuesta__c = interaccion.SAC_Respuesta__c + '<br/><br/><b>Respuesta Email </b>' + fechaFormateada + '<br/><br/>' + texto.left(32200);
                            }
                        }else{
                            interaccion.SAC_Respuesta__c = texto.left(32200);
                        }
                        
                        interaccion.SAC_FechaRespuesta__c = now;
                        interaccion.SAC_EmailRespuesta__c = email.fromAddress;
                        interaccion.SAC_Estado__c = 'SAC_Resuelta';               
                    } 

                    wrapEmRes = emailConsulta(interacciones[0].Id, email, interacciones[0].SAC_Reclamacion__c );
                    result.success = wrapEmRes.result;
                    emailMess = wrapEmRes.eMessage;

                    SAC_Utils.updateInteraccion(JSON.serialize(interacciones));

                    //Añadido US527358
                    CBK_Log.ResultWrapper wResult = new CBK_Log.ResultWrapper();
                    wResult.Status = 'OK';
                    wResult.Detail = 'Envio correcto';
                    wResult.CaseId = emailMess.RelatedToId;
                    wResult.EmailMessageId = emailMess.Id;
                    CBK_Log.auditemailResult(wResult, email);

                    return result;
                }

                if (!acciones.isEmpty()) {
                    encontradoInteraccionTarea = true;
                    for (SAC_Accion__c accion : acciones) {
                        accion.SAC_Comentarios2__c = texto.left(32200);
                        accion.SAC_Estado__c = 'SAC_Finalizada';
                        accion.OwnerId = UserInfo.getUserId();
                        accion.SAC_SaltarValidacion__c = true;               
                    } 

                    wrapEmRes = emailConsulta(acciones[0].Id, email, acciones[0].SAC_Reclamacion__c );
                    result.success = wrapEmRes.result;
                    emailMess = wrapEmRes.eMessage;

                    SAC_Utils.updateAlerta(JSON.serialize(acciones));

                    //Añadido US527358
                    CBK_Log.ResultWrapper wResult = new CBK_Log.ResultWrapper();
                    wResult.Status = 'OK';
                    wResult.Detail = 'Envio correcto';
                    wResult.CaseId = emailMess.RelatedToId;
                    wResult.EmailMessageId = emailMess.Id;
                    CBK_Log.auditemailResult(wResult, email);

                    return result;
                }
                
            }
            if(!encontradoInteraccionTarea){
                List<Case> listaCaso = [SELECT id, RecordTypeId, Status, CaseNumber, OwnerId, SAC_AlertasPtes__c, SAC_Reclamacion__c,
                                        SAC_PretensionPrincipal__r.OwnerId, SAC_Reclamacion__r.OwnerId, CC_SuppliedUser__c, Description
                                        FROM Case WHERE RecordTypeId IN (:RECORDTYPERECLAMACION, :RECORDTYPECONSULTA, :RECORDTYPECONSULTASAC, :RECORDTYPEPRETENSION) 
                                        AND CC_SuppliedID__c =: threadId LIMIT 1 ];
                /*
                Comprobar que el body del mail recibido tenga threadId y buscar un caso que lo tenga
                Si hay un caso con ese threadId, se añade el mail al caso
                Si no hay un caso con ese threadId, se crea uno nuevo
                Comrpobar en el nombre de la custom setting si coincide con el TO del email que entra.
                Si coinciden coger el resto de campos mapeados en la cs para crear el caso.
                */

                //Comprobar si el caso esta cerrado, rechazado o en SAC_014 para abrir caso nuevo en lugar de vincular el email al caso.
                Boolean abrirCasoNuevo = false;
                if ((!listaCaso.isEmpty() && String.isNotBlank(listaCaso[0].Status) && 
                    (listaCaso[0].Status == 'Cerrado' || listaCaso[0].Status == 'Rechazado' || listaCaso[0].Status == 'SAC_014' || listaCaso[0].Status == 'SAC_012' || listaCaso[0].Status == 'SAC_013' || 
                     (listaCaso[0].recordTypeId == RECORDTYPECONSULTA && listaCaso[0].Status == 'SAC_008') || (listaCaso[0].recordTypeId == RECORDTYPECONSULTASAC && listaCaso[0].Status == 'SAC_008')
                    )
                    ) || listaCaso.isEmpty()) {
                    abrirCasoNuevo = true;
                }
                if(listaCaso.isEmpty() || abrirCasoNuevo){
                    String mailCabecera = String.valueOf(envelope.toAddress);
                    if (!abrirCasoNuevo) {
                        wrapEmRes = caseRelated(email);
                        result.success = wrapEmRes.mapaResultado.get('resultado');
                        emailMess = wrapEmRes.eMessage;
                    }
                    if (!result.success || abrirCasoNuevo){
                        //Obtenemos la parametrización correspondiente a este caso del Custom Metadata Type correspondiente
                        List<SAC_EmailService__c> customSetting = SAC_EmailService__c.getAll().values();
                        SAC_EmailService__c parametrizacion;
                        for(SAC_EmailService__c paramAux : customSetting){
                            if((email.ccAddresses != null && email.ccAddresses.contains(paramAux.SAC_EmailEntrante__c)) || (email.toAddresses != null && email.toAddresses.contains(paramAux.SAC_EmailEntrante__c))){
                                parametrizacion = paramAux;
                            }
                            else{
                                for(Messaging.InboundEmail.Header header : email.headers){
                                    if(header.value.contains(paramAux.SAC_EmailEntrante__c)){
                                        parametrizacion = paramAux;
                                    }
                                }
                            }
                        }

                        Case caso = null;
                        if(Schema.sObjectType.QueueSobject.isAccessible()){ 
                            QueueSobject cola = null;
                            List<QueueSobject> colas = [SELECT QueueId FROM QueueSobject WHERE queue.DeveloperName = 'SAC_PendienteAsignar' AND SobjectType = 'Case' LIMIT 1];
                            if(!colas.isEmpty()){
                                cola = colas[0];
                            }

                            //Rellenamos el caso antes de comprobar la parametrización por si no hubiera parametrización encontrada
                            String subjectRecortado = '';
                            if (String.isNotBlank(email.subject)) {
                                subjectRecortado = email.subject.left(255).stripHtmlTags();
                            }
                            caso = new Case();
                            caso.Priority = 'Medium';
                            caso.Origin = 'Email';
                            caso.SuppliedEmail = email.fromAddress;
                            if (String.isNotBlank(subjectRecortado)) {
                                caso.Subject = subjectRecortado;
                            }
                            caso.OwnerId = cola.QueueId;
                            caso.RecordTypeId = RECORDTYPERECLAMACION;

                            if(parametrizacion != null){
                                caso.SAC_Naturaleza__c = parametrizacion.SAC_Naturaleza__c;
                                if(String.isNotBlank(parametrizacion.SAC_GroupName__c)){
                                    List<CC_Grupo_Colaborador__c> grupos = [SELECT Id FROM CC_Grupo_Colaborador__c 
                                                            WHERE SAC_DeveloperName__c = :parametrizacion.SAC_GroupName__c];
                                    if(!grupos.isEmpty()){
                                        caso.SEG_Grupo__c = grupos[0].Id;
                                    }
                                }
                                if(String.isNotBlank(parametrizacion.SAC_RecordTypeDeveloperName__c)){
                                    if(parametrizacion.SAC_RecordTypeDeveloperName__c == 'SAC_Reclamacion'){
                                        caso.RecordTypeId = RECORDTYPERECLAMACION;
                                    }else if(parametrizacion.SAC_RecordTypeDeveloperName__c == 'SAC_Consulta'){
                                        caso.RecordTypeId = RECORDTYPECONSULTA;
                                    }else{
                                    caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(parametrizacion.SAC_RecordTypeDeveloperName__c).getRecordTypeId();
                                }
                            }                  
                            }                  

                            if(email.htmlBody != null){ 
                                caso.Description = email.htmlBody.left(32000).stripHtmlTags(); 
                            }else if(email.plainTextBody != null){ 
                                caso.Description = email.plainTextBody.left(32000);
                            }
                            
                        }
                        
                        Database.SaveResult resultado = null;

                        //Hacer reglas de validacion antes del insert del caso
                        SAC_Utils.WrapperReglaClasificacion wrapRC = new SAC_Utils.WrapperReglaClasificacion();
                        wrapRC = SAC_Utils.determinarCR(email.fromAddress, email.toAddresses, email.ccAddresses, email.Subject, texto, caso.RecordTypeId);
                        if (String.isNotBlank(wrapRC.id)) {
                            caso.OS_ReglaUtilizada__c = wrapRC.id;
                        }

                        //caso.CC_AcuseRecibo__c = '1'; esta linea se ha comentado para que no se quede el acuse de recibo en 1. Al no introducir un valor, manda el acuse de recibo y se updatea a 2 (dia 7/11/22)
                        resultado = Database.insert(caso);

                        wrapEmRes = emailTask(caso.Id, email, RECORDTYPETAREA);
                        Map<String,Boolean> mapaResultadoEmailTask = wrapEmRes.mapaResultado;
                        emailMess = wrapEmRes.eMessage;
                        
                        result.success= mapaResultadoEmailTask.get('resultado');
                        caso.SourceId = [SELECT id FROM EmailMessage WHERE ParentId =: caso.id AND Incoming = true LIMIT 1].id;
                        caso.SAC_UltimaModificacionFichero__c = (mapaResultadoEmailTask.get('tieneAttachments')) ? System.now() : null;
                        resultado = Database.update(caso);     
                            
                    }
                }else{
                    List<SAC_WrapperAlerta> listaAlertas = new List<SAC_WrapperAlerta>();
                    for(Case casoAux: listaCaso ){
                        if(casoAux.RecordTypeId == RECORDTYPECONSULTA && (casoAux.Status == 'SAC_008' || casoAux.Status == 'SAC_012' || casoAux.Status == 'SAC_013')){
                            casoAux.Status='SAC_011';
                            casoAux.SAC_StatusAuxiliar__c = casoAux.Status;
                        }
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
                    }
                    
                    if (!listaAlertas.isEmpty()) {
                        SAC_EmailService.generarAlertasFuturo(JSON.serialize(listaAlertas));
                    } 
                    
                    //Añadido para recortar la description del caso
                    //listaCaso[0].Description = listaCaso[0].Description.left(32000);
                    Database.SaveResult resultado = null;
                    resultado = Database.update(listaCaso[0]);

                    wrapEmRes = emailTask(listaCaso[0].Id, email, RECORDTYPETAREA);
                    result.success = wrapEmRes.mapaResultado.get('resultado');
                    emailMess = wrapEmRes.eMessage;
                }
                //Añadido US527358
                CBK_Log.ResultWrapper wResult = new CBK_Log.ResultWrapper();
                wResult.Status = 'OK';
                wResult.Detail = 'Envio correcto';
                wResult.CaseId = emailMess.ParentId;
                wResult.EmailMessageId = emailMess.Id;
                CBK_Log.auditemailResult(wResult, email);

                return result;
            }
            //Añadido US527358
            CBK_Log.ResultWrapper wResult = new CBK_Log.ResultWrapper();
            wResult.Status = 'OK';
            wResult.Detail = 'Envio correcto';
            wResult.CaseId = emailMess.ParentId;
            wResult.EmailMessageId = emailMess.Id;
            CBK_Log.auditemailResult(wResult, email);

            return result;
        } catch (Exception e) {
            //Añadido US527358
            CBK_Log.error(e, 'Error en el envio de email', email);
            CBK_EmailExceptions_TRHan.handledEmailServiceException(e, email);
            throw e;
        }
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

        final String METHODNAME = 'emailConsulta';
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
        
        Database.insert(contentEmMes);
        resultado = true; 
        
        // Add Email Message Relation for id of the sender
        EmailMessageRelation emr = new EmailMessageRelation();
        emr.EmailMessageId = contentEmMes.id;
        emr.RelationAddress = email.FromAddress;
        emr.RelationType = 'FromAddress';
        if(Schema.sObjectType.EmailMessageRelation.isCreateable()){
            Database.insert(emr);
        }
        
        //Guardamos los attachments si hubiese alguno
        if(resultado=true){
            Map<String, ContentVersion> attachmentsMap= handleAttachments(email);
        
            if ( !attachmentsMap.isEmpty() ) {
                try{
                    List<ContentVersion> listaContents = attachmentsMap.values();
                    Database.insert(listaContents, false);
    
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
                    Database.insert(contentLinks);
                }catch(Exception e){
                    CBK_Log.error(e);
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
                Database.update(contentEmMes);
                resultado = true; 
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
     * 1.0            US219261         Nicolás G.   15/06/21     Creación
    *****************************************************************/

    public static WrapperEmailResult emailTask(ID casoid, Messaging.InboundEmail email, Id taskTR){
        final String METHODNAME = 'emailTask';
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
        
        Database.insert(conEmailMessage);
        resultado = true; 
        
        // Add Email Message Relation for id of the sender
        EmailMessageRelation emr = new EmailMessageRelation();
        emr.EmailMessageId = conEmailMessage.id;
        emr.RelationAddress = email.FromAddress;
        emr.RelationType = 'FromAddress';
        if(Schema.sObjectType.EmailMessageRelation.isCreateable()){
            Database.insert(emr);
        }

        if(resultado=true){
            createTask(casoid, email.Subject, TaskTR);
        }
        //Guardamos los attachments si hubiese alguno
        if(resultado=true){	
            Map<String, ContentVersion> attachmentsMap= handleAttachments(email);
        
            if ( !attachmentsMap.isEmpty() ) {
                try{
                    tieneAttachments = true;
                    List<ContentVersion> listaContents = attachmentsMap.values();
                    Database.insert(listaContents, false);
    
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
                    Database.insert(contentLinks);
                }catch(Exception e){
                    CBK_Log.error(e);
                }
                
            }

            

            String imageURL = '/servlet/servlet.FileDownload?file=';
            //Incidecia PROD 12/04
            String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm() + imageURL;
            
            for ( String contentId : attachmentsMap.keySet() ) {
                
                String cid = contentId.replace( '<', '' ).replace( '>', '' );
                String url = fullFileURL + String.valueOf( attachmentsMap.get( contentId ).id ).left( 15 );
                
                conEmailMessage.textBody = (String.isNotBlank(conEmailMessage.textBody))?conEmailMessage.textBody.replaceAll( 'cid:' + cid, url ).left(130000):conEmailMessage.textBody;
                conEmailMessage.htmlBody = (String.isNotBlank(conEmailMessage.htmlBody))?conEmailMessage.htmlBody.replaceAll( 'cid:' + cid, url ).left(130000):conEmailMessage.htmlBody;
            }
            
            if(Schema.sObjectType.EmailMessage.isUpdateAble()){
                Database.update(conEmailMessage);
                resultado = true; 
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
        final String METHODNAME = 'caseRelated';
        String caseID = null; 
        WrapperEmailResult wrapEmRes = new WrapperEmailResult();
        wrapEmRes.mapaResultado.put('resultado', false);

        caseID = Cases.getCaseIdFromEmailHeaders(email.headers);

        //Si existe ya un caso se añade el mail al hilo
        if(caseID != null){
            wrapEmRes = emailTask(caseID, email, RECORDTYPETAREA);
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
        final String METHODNAME = 'handleAttachments';
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
        final String METHODNAME = 'createTask';
        Task tarea= new Task();
        tarea.Type = 'Email';
        tarea.WhatId = casoid;
        tarea.Subject = subject.left(255).stripHtmlTags(); 
        tarea.Status = 'Completed';
        tarea.ActivityDate= system.today();
        tarea.RecordTypeId = TaskTR;
        if(Schema.sObjectType.Task.isCreateable()){
            Database.insert(tarea);
        }
    }

    /*****************************************************************
     * Proposito: Crear alertas
    */
    @future
    private static void generarAlertasFuturo(String jsonAlertas) {
        List<SAC_WrapperAlerta> lstAlertas = (List<SAC_WrapperAlerta>)Json.deserialize(jsonAlertas,List<SAC_WrapperAlerta>.class);
        try{
            SAC_Alertas.generarAlertas(lstAlertas);
        } catch (Exception e) {
            CBK_Log.error(e);
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