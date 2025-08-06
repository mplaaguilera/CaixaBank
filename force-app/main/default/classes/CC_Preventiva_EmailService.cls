global with sharing class CC_Preventiva_EmailService implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env){
        EmailMessage crearEmailMessage = new EmailMessage();
        try {
            CBK_log.auditemail(email);
            // Create an InboundEmailResult object for returning the result of the 
            Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
            String myPlainText= '';
            String sTipoNif = '';
            if (string.isNotBlank(email.plainTextBody)) {
                myPlainText = email.plainTextBody;
            } else if (string.isNotBlank(email.htmlBody)) {
                myPlainText = email.htmlBody.stripHtmlTags();
            } 
            myPlainText=myPlainText.left(131072);
            String myPlainTextOrig = myPlainText;
            myPlainText=ajusteMensaje(myPlainText);
            
            Map<String,Map<String,String>> oMapTipificacion = new Map<String,Map<String,String>>();
            String sTipificacion = '';
            String idioma='';
            String emailOrigen= email.fromAddress;
            String emailDestino= env.toAddress;
            String vLastName = emailOrigen;
            String vFirstName = '';
            String vName = '';
            String vApellido1 = '';
            String vApellido2 = '';
            String vOfice = '';
            String vNif ='';
            String vEmpleado ='';
            String vMotivo ='';
            String vProducto ='';
            String vAmbito ='';
            String vOrigen ='';
            String vDetalle ='';
            String vPropuesta ='';
            String vServicios ='';
            String vRiesgo ='';
            String vInterlocutor ='';
            Id grupoOficina;
            List<CC_Grupo_Colaborador__c> listGrupoOficina =  new List<CC_Grupo_Colaborador__c>();
            
            //Miramos si el correo entrante tiene una semilla que coincide con alguna actividad de un caso ya existente
            String referencia = CC_Metodos_EmailServices.referenciaCorreo(email);
            if (referencia != null){
                List<Task> tareaOrigen = [SELECT Id, WhatId, Type FROM Task WHERE CC_Referencia_Correo_Saliente__c = :referencia 
                AND (RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task'))  LIMIT 1];
                if (!tareaOrigen.isEmpty()) {
                    if (tareaOrigen[0].Type == 'Traslado Colaborador') {
                        //Respuesta entrante de grupo colaborador
                        CC_Metodos_EmailServices.respuestaTrasladoColaborador(email, tareaOrigen[0].WhatId, myPlainText, emailDestino);
                    } else if (tareaOrigen[0].Type == 'Solicitud Información') {
                        //Respuesta entrante de solicitud de información de cliente
                        CC_Metodos_EmailServices.respuestaSolicitudInfo(email, tareaOrigen[0].WhatId, myPlainText, emailDestino);
                    } else if (tareaOrigen[0].Type == 'Remitir Colaborador') {
                        //Respuesta entrante de remisión del caso a grupo colaborador
                        CC_Metodos_EmailServices.respuestaRemitirColaborador(email, tareaOrigen[0].WhatId, myPlainText, emailDestino);
                    }else if (tareaOrigen[0].Type == 'Responder a cliente') {
                        //Respuesta entrante de respuesta de cliente
                        CC_Metodos_EmailServices.respuestaCliente(email, tareaOrigen[0].WhatId, myPlainText, emailDestino);
                    }
                }
            } else {
                map<String,String> parseo = new map<String,String>();
                parseo = parseoEmail(myPlainText);
                //Oficina
                vOfice = parseo.get('Oficina');
                //Sacamos el grupo colaborador de la oficina si nos viene informada
                if (vOfice != null){
                    listGrupoOficina = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE CC_Cuenta__r.CC_Numero_Oficina__c =: vOfice  LIMIT 1];
                }
                for ( CC_Portal_accionistas__mdt maillst:[Select Email__c ,Portal__c,Idioma__c from CC_Portal_accionistas__mdt  LIMIT 100]) {
                    if (emailDestino.contains(maillst.Email__c)){
                        //Idioma
                        idioma = maillst.Idioma__c;
                        //Oficina
                        vOfice = parseo.get('Oficina');
                        
                        if(!listGrupoOficina.isEmpty()){
                            for (CC_Grupo_Colaborador__c oficinas : listGrupoOficina){
                                grupoOficina = oficinas.Id;
                            }
                        }
                        //Nombre
                        vFirstName = parseo.get('Nombre');
                        //Apellidos
                        vLastName = (parseo.get('Apellido1') != NULL? parseo.get('Apellido1') : '')  + ' ' + (parseo.get('Apellido2') != NULL? parseo.get('Apellido2') : '') ;
                        vLastName = vLastName.trim();
                        vApellido1 = parseo.get('Apellido1');
                        vApellido2 = parseo.get('Apellido2');
                        //NIF
                        vNif = validacionNif(parseo.get('NIF'));
                        if (vNif==null) {
                            vNif='';
                        }
                        //Name
                        vName = vFirstName + ' ' + vLastName;
                        vName = vName.trim().toUpperCase();
                        //Ambito
                        vAmbito = parseo.get('Ambito');
                        //Producto
                        vProducto = parseo.get('Producto');
                        //Motivo
                        vMotivo = parseo.get('Motivo');
                        //Origen
                        vOrigen = parseo.get('Origen');
                        //Detalle
                        vDetalle = parseo.get('Detalle');
                        //Interlocutor
                        vInterlocutor = parseo.get('Interlocutor');
                        //Servicios
                        vServicios = parseo.get('Servicios');
                        //vEmpleado
                        vEmpleado = parseo.get('Empleado');
                        //Propuesta
                        vPropuesta = parseo.get('Propuesta');
                        // VALIDACIONES PARA EL FORMULARIO WEB.
                        //if (vProducto == null || vAmbito == null || vMotivo == null) {
                            //return 'KO';
                            //} else if (vProducto.trim() == '' || vAmbito.trim() == '' || vMotivo.trim() == '') {
                                //return 'KO';
                                //} else{
                                    // Rellenar los campos internos para el tratamiento de la tipificación.
                                    sTipificacion = sTipificacion + 'MC' + '-';
                                    sTipificacion = sTipificacion + vMotivo.trim() + '-';
                                    sTipificacion = sTipificacion + vProducto.trim() + '-';
                                    sTipificacion = sTipificacion + vAmbito.trim();
                                    //}
                                    Set<String> oTipificacionWeb = new Set<String>();
                                    oTipificacionWeb.add(sTipificacion);
                                    // Recuperar conversiones MCC.
                                    if (!oTipificacionWeb.isEmpty()) {
                                        oMapTipificacion = getTipificacionesCaso(oTipificacionWeb);
                                    }
                                    oTipificacionWeb = null;
                                } else {
                                    idioma = maillst.Idioma__c;
                                }
                            }
                            
                            // New Task object to be created
                            Case newCase = new Case();
                            //Id ContactrecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
                            //Id AccountrecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
                            
                            // Preparar el contacto intermedio.
                            if (emailOrigen != null){
                                Integer iDelay = 1;
                                Integer iDelayAcuse = 1;
                                List<CC_ConfigNotifCliente__mdt> oConfigAcuse;
                                List<CC_ConfigNotifCliente__mdt> oConfigContInt;
                                if (!Test.isRunningTest()){
                                    oConfigContInt = [SELECT Id, CC_DelayMinAcuse__c 
                                    FROM CC_ConfigNotifCliente__mdt 
                                    WHERE DeveloperName = 'CC_Contacto_Intermedio_Preventivas_ES' AND CC_Proceso__c = 'CC_Contacto_Intermedio_Preventivas' 
                                    AND CC_Activa__c = true ];
                                    oConfigAcuse = [SELECT Id, CC_DelayMinAcuse__c 
                                    FROM CC_ConfigNotifCliente__mdt 
                                    WHERE DeveloperName = 'CC_AcuseRecibo' AND CC_Proceso__c = 'CC_AcuseRecibo' AND CC_Activa__c = true ];
                                }else{
                                    CC_ConfigNotifCliente__mdt oAux = new CC_ConfigNotifCliente__mdt();
                                    oAux.CC_DelayMinAcuse__c = 0;
                                    oConfigContInt = new List<CC_ConfigNotifCliente__mdt>();
                                    oConfigAcuse = new List<CC_ConfigNotifCliente__mdt>();
                                    oConfigContInt.add(oAux);
                                    oConfigAcuse.add(oAux);
                                }
                                if (!oConfigContInt.isEmpty()){
                                    if (oConfigContInt[0].CC_DelayMinAcuse__c != null){
                                        iDelay = Integer.valueOf(oConfigContInt[0].CC_DelayMinAcuse__c);
                                    }
                                    if (oConfigAcuse[0].CC_DelayMinAcuse__c != null){
                                        iDelayAcuse = Integer.valueOf(oConfigAcuse[0].CC_DelayMinAcuse__c);
                                    }
                                }
                                //Delay Contacto Intermedio
                                datetime oDelay = datetime.now();
                                oDelay = oDelay.addMinutes(iDelay);
                                newCase.CC_Cont_Interm_Delay__c = oDelay;
                                //Delay Acuse
                                datetime oDelayAcuse = datetime.now();
                                oDelayAcuse = oDelayAcuse.addMinutes(iDelayAcuse);
                                newCase.CC_AcuseDelay__c = oDelayAcuse;
                            }
                            
                            try {
                                //Búqueda de contacto por NIF
                                List<Contact> vCon = new List<Contact>();
                                
                                if (vNif!='') {
                                    vCon = [SELECT Id, Name, Email,AccountId FROM Contact WHERE CC_Numero_Documento__c = :vNif 
                                    ORDER BY CREATEDDATE DESC LIMIT 1];
                                }
                                
                                //Búsqueda de contacto-email tipo buzón
                                if (vCon.size()==0) {
                                    vCon = [SELECT Id, Name, Email,AccountId FROM Contact WHERE Email = :emailOrigen
                                    AND LastName = :emailOrigen  ORDER BY CREATEDDATE DESC LIMIT 1]; //Name 
                                }
                                //Validacion CIF/NIF y logica de creación Acc, Cont, Pers Acc.
                                if (vNif!=''){
                                    sTipoNif = CC_MetodosUtiles.validarCIFNIF(vNif);
                                }
                                
                                /*Contact Contacto = new Contact(); 
                                Account Cuenta = new Account(); 
                                Cuenta.RecordTypeId=AccountrecordTypeId;
                                //Si no existe un contacto con mismo email, sin documento --> Se crea
                                if (vCon.size()==0) {
                                    Cuenta.CC_Numero_Documento__c = vNif + '';
                                    Cuenta.Name=((vName.trim() != '' && vName != NULL)? vName : emailOrigen);
                                    insert Cuenta;
                                    
                                    Contacto.Email=emailOrigen;
                                    Contacto.FirstName = vFirstName;
                                    Contacto.LastName = (vLastName != NULL ? vLastName : emailOrigen); 
                                    Contacto.CC_Numero_Documento__c = vNif + '';
                                    Contacto.RecordTypeId = ContactrecordTypeId;
                                    Contacto.AccountId = Cuenta.Id;
                                    insert Contacto;
                                    //system.debug (Contacto.Id);
                                    
                                } else {
                                    Contacto = vCon[0];
                                    if (Contacto.AccountId == null) { 
                                        Cuenta.Name=((vName.trim() != '' && vName != NULL)? vName : emailOrigen); 
                                        Cuenta.CC_Numero_Documento__c = vNif + '';
                                        insert Cuenta;
                                        Contacto.AccountId = Cuenta.Id;
                                        update Contacto;
                                    }
                                }*/
                                
                                Contact oContactEmp = new Contact();
                                Account oAccountEmp = new Account();
                                Account oPAccount = new Account();
                                if (sTipoNif == 'CIF') {
                                    /*
                                    **GESTIÓN CLIENTES EMPRESAS
                                    */
                                    if (vCon.size()==0){
                                        // Separamos para la posible conversión de BusinessAccount <--> PersonAccount
                                        oAccountEmp.CC_Numero_Documento__c = vNif + '';
                                        oAccountEmp.Name = ((vName.trim() != '' && vName != NULL)? vName : emailOrigen);
                                        oAccountEmp.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
                                        
                                        if (!Schema.sObjectType.Account.fields.CC_Numero_Documento__c.isCreateable()) {
                                            CBK_log.debug('Faltan permisos de inserción sobre el objeto Account.');
                                        }
                                        
                                        insert oAccountEmp;
                                        
                                        oContactEmp.Email = emailOrigen;
                                        oContactEmp.FirstName = vFirstName;
                                        oContactEmp.LastName = (vLastName != NULL ? vLastName : emailOrigen);
                                        oContactEmp.CC_Numero_Documento__c = vNif + '';
                                        oContactEmp.CC_Idioma__c = idioma;
                                        oContactEmp.AccountId = oAccountEmp.Id;
                                        oContactEmp.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
                                        
                                        if (!Schema.sObjectType.Contact.fields.CC_Numero_Documento__c.isCreateable()) {
                                            CBK_log.debug('Faltan permisos de inserción sobre el objeto Contact.');
                                        }
                                        
                                        insert oContactEmp;
                                    } else{
                                        oContactEmp = vCon[0];
                                        if (oContactEmp.AccountId == null) { 
                                            oAccountEmp.Name=((vName.trim() != '' && vName != NULL)? vName : emailOrigen); 
                                            oAccountEmp.CC_Numero_Documento__c = vNif + '';
                                            oAccountEmp.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
                                            insert oAccountEmp;
                                            oContactEmp.AccountId = oAccountEmp.Id;
                                            
                                            if (!Schema.sObjectType.Contact.fields.CC_Numero_Documento__c.isUpdateable()) {
                                                CBK_log.debug('Faltan permisos de edición sobre el objeto Contact.');
                                            }
                                            
                                            update oContactEmp;
                                        }
                                    }     
                                } else {
                                    /*
                                    **GESTIÓN CLIENTES PARTICULARES
                                    */
                                    if (vCon.size()==0){
                                        oPAccount.CC_Email__c = emailOrigen;
                                        oPAccount.PersonEmail = emailOrigen;
                                        oPAccount.FirstName = vFirstName;
                                        oPAccount.LastName = (vLastName != NULL ? vLastName : emailOrigen);
                                        oPAccount.CC_Idioma__pc = idioma;
                                        oPAccount.CC_Numero_Documento__c = vNif + '';
                                        oPAccount.CC_Numero_Documento__pc = vNif + '';
                                        oPAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
                                        insert oPAccount;
                                    } else {
                                        oContactEmp = vCon[0];
                                        if (oContactEmp.AccountId == null) {
                                            oPAccount.CC_Email__c = emailOrigen;
                                            oPAccount.PersonEmail = emailOrigen;
                                            oPAccount.FirstName = vFirstName;
                                            oPAccount.LastName = (vLastName != NULL ? vLastName : emailOrigen);
                                            oPAccount.CC_Idioma__pc = idioma;
                                            oPAccount.CC_Numero_Documento__c = vNif + '';
                                            oPAccount.CC_Numero_Documento__pc = vNif + '';
                                            oPAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
                                            insert oPAccount;
                                        } 
                                    }
                                }
                                
                                newCase.Description =  (vDetalle + '\r\nPropuesta: ' + vPropuesta).left(32000);//myPlainText;
                                //newCase.AccountId = Contacto.AccountId;
                                //newCase.contactId = Contacto.id;
                                //Controlar si es empresa, crea cuenta y contacto, si es particular, solo crea cuenta (PA)
                                if (sTipoNif == 'CIF'){
                                    newCase.contactId = oContactEmp.id;
                                    newCase.AccountId = oAccountEmp.id;
                                } else {
                                    newCase.AccountId = oPAccount.id;
                                }
                                String emailSubject = email.Subject;
                                if (emailSubject.length() > 255) {
                                    emailSubject = emailSubject.left(255); 
                                }
                                newCase.Subject = emailSubject;
                                newCase.Origin = 'Email';
                                newCase.CC_Idioma__c = idioma;
                                newCase.CC_Canal_Procedencia__c = 'Oficina Preventiva';
                                newCase.CC_Tipo_Contacto__c = 'Pre-Queja';
                                newCase.CC_Numero_Documento__c = vNif + '';
                                newCase.CC_MailTelfNotif__c = emailOrigen;
                                newCase.CC_Oficina_afectada__c = vOfice;
                                newCase.CC_GrupoOficina__c = grupoOficina;
                                newCase.CC_AcuseRecibo__c = '1';
                                newCase.CC_SuppliedApp__c = 'FORMPREV';
                                // Tipificar el caso.
                                if (oMapTipificacion != null){
                                    if (oMapTipificacion.get(sTipificacion) != null){
                                        if (oMapTipificacion.get(sTipificacion).get('Tematica') != null){
                                            newCase.CC_MCC_Tematica__c = oMapTipificacion.get(sTipificacion).get('Tematica');    
                                        }
                                        if (oMapTipificacion.get(sTipificacion).get('Producto') != null){
                                            newCase.CC_MCC_ProdServ__c = oMapTipificacion.get(sTipificacion).get('Producto');
                                        }
                                        if (oMapTipificacion.get(sTipificacion).get('Motivo') != null){
                                            newCase.CC_MCC_Motivo__c = oMapTipificacion.get(sTipificacion).get('Motivo');
                                        }
                                        if (oMapTipificacion.get(sTipificacion).get('TematicaName') != null){
                                            newCase.CC_SuppliedMotivoDesc__c = oMapTipificacion.get(sTipificacion).get('TematicaName');
                                        }
                                        if (oMapTipificacion.get(sTipificacion).get('ProductoName') != null){
                                            newCase.CC_SuppliedProductoDesc__c = oMapTipificacion.get(sTipificacion).get('ProductoName');
                                        }
                                        if (oMapTipificacion.get(sTipificacion).get('MotivoName') != null){
                                            newCase.CC_SuppliedAmbitoDesc__c = oMapTipificacion.get(sTipificacion).get('MotivoName');
                                        }    
                                    }
                                }
                                newCase.SuppliedName = vFirstName;
                                newCase.CC_SuppliedApellido1__c = vApellido1;
                                newCase.CC_SuppliedApellido2__c = vApellido2;
                                newCase.CC_SuppliedNIF__c = vNif + '';
                                newCase.SuppliedEmail = emailOrigen;
                                newCase.CC_SuppliedIdioma__c = 'es';
                                newCase.CC_SuppliedApp__c = 'FORMTF';
                                newCase.CC_SuppliedUser__c = vEmpleado;
                                newCase.CC_SuppliedOficina__c = vOfice;
                                newCase.CC_SuppliedServicio__c = vServicios;
                                newCase.CC_SuppliedInterlocutor__c = vInterlocutor;
                                
                                try {
                                    Group cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'CC_Inbound_Email_Preventiva'  LIMIT 1];
                                    newCase.OwnerId=cola.Id;
                                } catch (QueryException e) {
                                    System.debug('Falta Cola: ' + e);
                                }
                                
                                if (!Schema.sObjectType.Case.fields.SuppliedName.isCreateable()) {
                                    CBK_log.debug('Faltan permisos de edición sobre el objeto Case.');
                                }
                                
                                insert newCase;
                                
                                // Save attachments, if any
                                List<Id> listaContentVersionIdEmail = new List<Id>();
                                EmailMessage crearEmailMessageV = crearEmailMessage(email,emailDestino,newCase.id,null,myPlainTextOrig);
                                
                                if (email.textAttachments != null) {
                                    //Insertar registros Content Version
                                    List<ContentVersion> listaContentVersion = new List<ContentVersion>();
                                    
                                    for (Messaging.Inboundemail.TextAttachment textAttachment : email.textAttachments) {
                                        ContentVersion cv = new ContentVersion();
                                        cv.ContentLocation = 'S';
                                        cv.PathOnClient = textAttachment.fileName;
                                        cv.Origin = 'H';
                                        cv.Title = textAttachment.fileName;
                                        cv.VersionData = Blob.valueOf(textAttachment.body);
                                        listaContentVersion.add(cv);
                                    }
                                    if (!Schema.sObjectType.ContentVersion.fields.ContentLocation.isCreateable()) {
                                        CBK_log.debug('Faltan permisos de edición sobre el objeto ContentVersion.');
                                    }
                                    insert listaContentVersion;
                                    
                                    //Recuperar ContentDocumentId de los registros Content Version insertados
                                    List<Id> listaContentVersionId = new List<Id>();
                                    for (ContentVersion cv : listaContentVersion) {
                                        listaContentVersionId.add(cv.Id);
                                        listaContentVersionIdEmail.add(cv.Id);
                                    }
                                    listaContentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :listaContentVersionId ];
                                    
                                    //Insertar registros ContentDocumentLink
                                    List<ContentDocumentLink> listaContentDocumentLink = new List<ContentDocumentLink>();
                                    for (ContentVersion cv : listaContentVersion) {
                                        ContentDocumentLink cdLink = new ContentDocumentLink();
                                        cdLink.LinkedEntityId = newCase.Id;
                                        cdLink.ContentDocumentId = cv.ContentDocumentId;
                                        cdLink.ShareType = 'I';
                                        listaContentDocumentLink.add(cdLink);
                                        //Insertar registros ContentDocumentLink asociados al email
                                        ContentDocumentLink cdLinkEmail = new ContentDocumentLink();
                                        cdLinkEmail.LinkedEntityId = crearEmailMessageV.Id;
                                        cdLinkEmail.ContentDocumentId = cv.ContentDocumentId;
                                        cdLinkEmail.ShareType = 'V';
                                        listaContentDocumentLink.add(cdLinkEmail);
                                    }
                                    if (!Schema.sObjectType.ContentDocumentLink.fields.LinkedEntityId.isCreateable()) {
                                        CBK_log.debug('Faltan permisos de edición sobre el objeto ContentDocumentLink.');
                                    }
                                    insert listaContentDocumentLink;
                                }
                                
                                //Save any Binary Attachment
                                if (email.binaryAttachments != null){
                                    //Insertar registros Content Version
                                    List<ContentVersion> listaContentVersion = new List<ContentVersion>();
                                    Map<String, String> mapaImagenes = new Map<String, String>();
                                    for (Messaging.Inboundemail.BinaryAttachment binaryAttachment : email.binaryAttachments) {
                                        ContentVersion cv = new ContentVersion();
                                        cv.ContentLocation = 'S';
                                        cv.PathOnClient = binaryAttachment.fileName;
                                        cv.Origin = 'H';
                                        cv.Title = binaryAttachment.fileName;
                                        cv.VersionData = binaryAttachment.body;
                                        
                                        //Se almacena el identificador de la imagen para poder realizar un reemplazo posterior
                                        if (binaryAttachment.headers != null) {
                                            for (Integer i = 0; i < binaryAttachment.headers.size(); i++) {
                                                
                                                if (binaryAttachment.headers[i].name == 'Content-Id') {
                                                    String headerValue = binaryAttachment.headers[i].value;
                                                    headerValue = headerValue.replaceAll('<', '').replaceAll('>', '');
                                                    cv.ExternalDocumentInfo1=headerValue;
                                                }
                                            }
                                        }
                                        listaContentVersion.add(cv);
                                    }
                                    insert listaContentVersion;
                                    
                                    
                                    //Recuperar ContentDocumentId de los registros Content Version insertados
                                    List<Id> listaContentVersionId = new List<Id>();
                                    for (ContentVersion cv : listaContentVersion) {
                                        listaContentVersionId.add(cv.Id);
                                        listaContentVersionIdEmail.add(cv.Id);
                                    }
                                    listaContentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :listaContentVersionId ];
                                    
                                    //Insertar registros ContentDocumentLink
                                    List<ContentDocumentLink> listaContentDocumentLink = new List<ContentDocumentLink>();
                                    for (ContentVersion cv : listaContentVersion) {
                                        ContentDocumentLink cdLink = new ContentDocumentLink();
                                        cdLink.LinkedEntityId = newCase.Id;
                                        cdLink.ContentDocumentId = cv.ContentDocumentId;
                                        cdLink.ShareType = 'I';
                                        listaContentDocumentLink.add(cdLink);
                                        //Insertar registros ContentDocumentLink asociados al email
                                        ContentDocumentLink cdLinkEmail = new ContentDocumentLink();
                                        cdLinkEmail.LinkedEntityId = crearEmailMessageV.Id;
                                        cdLinkEmail.ContentDocumentId = cv.ContentDocumentId;
                                        cdLinkEmail.ShareType = 'V';
                                        listaContentDocumentLink.add(cdLinkEmail);
                                    }
                                    insert listaContentDocumentLink;
                                } 
                                //Validación alfabético
                                List<ID> oCasosIdent = new List<ID>();
                                oCasosIdent.add(newCase.Id);
                                CC_IdentCliente_Future.identificarClientesAsync (oCasosIdent);
                                
                                //EmailMessage crearEmailMessage = crearEmailMessage(email,emailDestino,newCase.id,Contacto.id,myPlainTextOrig);
                                //Controlar si es particular o empresa para informar contacto o cuenta (PA)
                                if (sTipoNif == 'CIF'){
                                    crearEmailMessage = crearEmailMessage(email,emailDestino,newCase.id,oContactEmp.id,myPlainTextOrig);
                                } else {
                                    crearEmailMessage = crearEmailMessage(email,emailDestino,newCase.id,null,myPlainTextOrig);
                                }
                            } catch (QueryException e) {
                                System.debug('Query Issue: ' + e);
                            }
                            result.success = true;
                        }
                        CBK_Log.ResultWrapper wResult = new CBK_Log.ResultWrapper();
                        wResult.Status = 'OK';
                        wResult.Detail = 'Envio correcto';
                        wResult.CaseId = crearEmailMessage.RelatedToId;
                        wResult.EmailMessageId = crearEmailMessage.Id;
                        CBK_Log.auditemailResult(wResult, email);
                        return result;
                        
                    } catch (Exception e) {
                        CBK_Log.error(e, 'Error en el envio de email', email);
                        CBK_Log.ResultWrapper wResult = new CBK_Log.ResultWrapper();
                        wResult.Status = 'KO';
                        wResult.Detail = e.getMessage()?.left(255);
                        wResult.CaseId = crearEmailMessage.RelatedToId;
                        wResult.EmailMessageId = crearEmailMessage.Id;
                        CBK_Log.auditemailResult(wResult, email);            
                        return null;
                    }
                }
                
                public static EmailMessage crearEmailMessage(Messaging.inboundEmail email, String emailDestino, Id caseId,Id contactId, String myPlainText){
                    Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
                    EmailMessage createEmail = new EmailMessage();
                    try {
                        Task createTask = new Task(
                        Type='Correo no identificado'
                        ,TaskSubtype   = 'Email'
                        ,Subject      = 'Correo entrante Preventivas' 
                        ,ActivityDate = System.today()
                        ,Status = 'Completed'
                        ,Description = myPlainText.left(32000)
                        ,WhatId = caseId
                        ,WhoId = contactId
                        );
                        //insert createTask;
                        CC_Activity.crearActividad(createTask);
                        
                        String emailSubject = email.Subject;
                        if (emailSubject.length() > 3000) {
                            emailSubject = emailSubject.left(3000); 
                        }
                        createEmail.Subject  = emailSubject;
                        createEmail.Status = '1';
                        if (email.ccAddresses!=null) {
                            createEmail.CcAddress = string.join(email.ccAddresses,','); 
                        }
                        createEmail.FromAddress = email.fromAddress;
                        createEmail.FromName = email.fromName;
                        createEmail.Headers = JSON.serialize( email.headers );
                        //createEmail.HtmlBody = email.htmlBody;
                        createEmail.TextBody = myPlainText;
                        createEmail.Incoming = true;
                        createEmail.MessageDate = DateTime.now();
                        createEmail.ParentId = caseId;
                        createEmail.ToAddress = emailDestino;
                        createEmail.MessageIdentifier = email.messageId;
                        createEmail.CBK_sfdcMessageId__c = email.messageId?.left(255);
                        createEmail.ThreadIdentifier = email.inReplyTo;
                        if (!Schema.sObjectType.EmailMessage.fields.FromAddress.isCreateable()) {
                            CBK_log.debug('Faltan permisos de edición sobre el objeto EmailMessage.');
                        }
                        insert createEmail; 
                    } catch (QueryException e) {
                        System.debug('Query Issue: ' + e);
                    }
                    return createEmail;   
                }
                
                public map<String,String> parseoEmail(string vtext){
                    map<String,String> resultado = new map<String,String>();
                    integer i =-1;
                    String item ='';
                    String valor ='';
                    list<String> parse = new list<String>();
                    for (String linea : vtext.split('\n')) {
                        i=linea.indexof(':');
                        if (i>0){
                            parse=linea.split(':', 2);
                            item=parse[0].trim();
                            valor=parse[1].trim();
                            valor = valor.replaceAll('\u00A0', '');
                            resultado.put(item,valor);
                        } else {
                            if (item!=''){
                                valor=valor + '\n' + linea.trim();
                                resultado.put(item,valor);
                            }
                        }
                    }
                    return resultado;
                }
                
                public string validacionNif(String vnifIn){
                    String vnifOut = vnifIn;
                    if (vnifIn==null) {
                        vnifOut='';
                    }
                    return vnifOut;
                }
                
                //Ajuste por perdida de saltos de carro perdidos
                public string ajusteMensaje(string vtextin){      
                    String vtextout = vtextin;
                    
                    vtextout=vtextout.unescapeHtml4() ;      
                    vtextout=vtextout.replace('[Nombre]', '\r\nNombre:');
                    vtextout=vtextout.replace('[Apellido1]', '\r\nApellido1:');
                    vtextout=vtextout.replace('[Apellido2]', '\r\nApellido2:');        
                    vtextout=vtextout.replace('[NIF]', '\r\nNIF:');
                    vtextout=vtextout.replace('[Segmento]', '\r\nSegmento:');
                    vtextout=vtextout.replace('[Oficina]', '\r\nOficina:');
                    vtextout=vtextout.replace('[Empleado]', '\r\nEmpleado:');
                    vtextout=vtextout.replace('[Motivo]', '\r\nMotivo:');
                    vtextout=vtextout.replace('[Producto]', '\r\nProducto:');
                    vtextout=vtextout.replace('[Ambito]', '\r\nAmbito:');
                    vtextout=vtextout.replace('[Origen]', '\r\nOrigen:');
                    vtextout=vtextout.replace('[Detalle]', '\r\nDetalle:');
                    vtextout=vtextout.replace('[Propuesta]', '\r\nPropuesta:');
                    vtextout=vtextout.replace('[Inicio]', '\r\nInicio:');
                    vtextout=vtextout.replace('[Servicios]', '\r\nServicios:');
                    vtextout=vtextout.replace('[Riesgo]', '\r\nRiesgo:');
                    vtextout=vtextout.replace('[Interlocutor]', '\r\nInterlocutor:');
                    vtextout=vtextout.replace('[OTROS_DOCUMENTOS] ', '\r\nOTROS_DOCUMENTOS:');
                    
                    return vtextout;        
                }
                
                /*
                Recuperar el maestro de tipificaciones entre Formulario TF y Salesforce.
                */
                private static Map<String,Map<String,String>> getTipificacionesCaso (Set<String> oListaTip){
                    Map<String,Map<String,String>> oData = new Map<String,Map<String,String>>();
                    
                    if (oListaTip != null){
                        if (!oListaTip.isEmpty()){
                            String sRecordType = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_ConvMCCWeb').getRecordTypeId();
                            List<CC_MCC__c> oMCC = [SELECT Id, CC_Equivalencia_Formulario__c, CC_WebMCCTematica__c, CC_WebMCCProducto__c, 
                            CC_WebMCCMotivo__c, CC_WebMCCTematica__r.Name,  CC_WebMCCProducto__r.Name, CC_WebMCCMotivo__r.Name,
                            CC_WebTipoContacto__c
                            FROM CC_MCC__c WHERE CC_Equivalencia_Formulario__c IN :oListaTip AND CC_Activo__c = true
                            AND RecordTypeId = :sRecordType ];
                            for (CC_MCC__c oAux : oMCC){
                                Map<String,String> oTipoSF = new Map<String,String>();
                                oTipoSF.put('Tematica', oAux.CC_WebMCCTematica__c);
                                oTipoSF.put('Producto', oAux.CC_WebMCCProducto__c);
                                oTipoSF.put('Motivo', oAux.CC_WebMCCMotivo__c);
                                oTipoSF.put('TematicaName', oAux.CC_WebMCCTematica__r.Name);
                                oTipoSF.put('ProductoName', oAux.CC_WebMCCProducto__r.Name);
                                oTipoSF.put('MotivoName', oAux.CC_WebMCCMotivo__r.Name);
                                
                                oData.put(oAux.CC_Equivalencia_Formulario__c, oTipoSF);
                            }
                        }
                    }
                    return oData;
                }
            }