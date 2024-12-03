global with sharing class CC_Accionistas_EmailService implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env){
        // Create an InboundEmailResult object for returning the result of the 
        EmailMessage crearEmailMessage = new EmailMessage();
        try {
            CBK_log.auditemail(email);
            Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
            String myPlainText= '';
            String sTipoNif = '';
            if (string.isNotBlank(email.plainTextBody)) {
                myPlainText = email.plainTextBody;
            } 
            else if (string.isNotBlank(email.htmlBody)) {
                myPlainText = email.htmlBody.stripHtmlTags();
            } 
            myPlainText=myPlainText.left(131072);
            String myPlainTextOrig = myPlainText;
            myPlainText=ajusteMensaje(myPlainText);  
            
            String idioma='';
            String emailOrigen= email.fromAddress;
            String emailDestino= env.toAddress;
            String vLastName = emailOrigen; 
            String vFirstName = ''; 
            String vName = '';
            String vPhone = ''; 
            String vNif ='';
            
            //Miramos si el correo entrante tiene una semilla que coincide con alguna actividad de un caso ya existente
            String referencia = CC_Metodos_EmailServices.referenciaCorreo(email);
            if (referencia != null){
                List<Task> tareaOrigen = [SELECT Id, WhatId, Type FROM Task WHERE CC_Referencia_Correo_Saliente__c = :referencia AND
                (RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task')) LIMIT 1];
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
                for ( CC_Portal_accionistas__mdt maillst:[Select Email__c ,Portal__c,Idioma__c from CC_Portal_accionistas__mdt LIMIT 100]) {
                    if ((maillst.Email__c==emailOrigen) && (maillst.Portal__c)){
                        map<String,String> parseo = new map<String,String>();
                        
                        parseo = parseoEmail(myPlainText);
                        //email
                        emailOrigen = validacionEmail(parseo.get('Email'));    
                        if ((emailOrigen=='') || (emailOrigen==null)){
                            Matcher m = Pattern.compile('[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+').matcher(myPlainText);
                            while (m.find()) {
                                emailOrigen=m.group();
                            }              
                        }
                        
                        idioma=maillst.Idioma__c;
                        //Phone
                        vPhone=parseo.get('Telefono');
                        //Nombre
                        vFirstName=parseo.get('Nombre'); 
                        //Apellidos
                        vLastName= (parseo.get('Primer apellido') != NULL? parseo.get('Primer apellido') : '')  + ' ' + (parseo.get('Segundo apellido') != NULL? parseo.get('Segundo apellido') : '') ; 
                        vLastName=vLastName.trim();
                        //NIF
                        vNif=validacionNif(parseo.get('Nif'));
                        vNif = vNif.trim().toUpperCase();
                        if (vNif==null) {vNif='';}
                        //Name
                        vName= vFirstName + ' ' + vLastName;
                        vName=vName.trim().toUpperCase();
                    } else if (emailDestino.contains(maillst.Email__c)) {
                        idioma=maillst.Idioma__c;
                    }
                }
                
                // New Task object to be created
                Case newCase = new Case();
                //Id ContactrecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
                //Id AccountrecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
                
                try {
                    //Búqueda de contacto por NIF
                    List<Contact> vCon = new List<Contact>();
                    
                    if (vNif!='') {
                        vCon = [SELECT Id, Name, Email,AccountId, Account.Id
                        FROM Contact
                        WHERE CC_Numero_Documento__c = :vNif 
                        ORDER BY CREATEDDATE DESC
                        LIMIT 1];
                    }
                    
                    //Búsqueda de contacto-email tipo buzón
                    if (vCon.size()==0) {
                        vCon = [SELECT Id, Name, Email,AccountId, Account.Id
                        FROM Contact
                        WHERE Email = :emailOrigen
                        AND LastName = :emailOrigen //Name
                        ORDER BY CREATEDDATE DESC
                        LIMIT 1];
                    }
                    //Validacion CIF/NIF y logica de creación Acc, Cont, Pers Acc.
                    if (vNif!=''){
                        sTipoNif = CC_MetodosUtiles.validarCIFNIF(vNif);
                    }
                    
                    /*
                    * Control antiguo para creación de cuenta/contacto Pre-PersonAccount 
                    */
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
                        Contacto.LastName=(vLastName != NULL ? vLastName : emailOrigen); 
                        Contacto.Phone=vPhone;
                        Contacto.CC_Numero_Documento__c = vNif + '';
                        Contacto.RecordTypeId=ContactrecordTypeId;
                        Contacto.AccountId=Cuenta.Id;
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
                    
                    // Nuevo control para Person Account
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
                            insert oAccountEmp;
                            
                            oContactEmp.Email = emailOrigen;
                            oContactEmp.FirstName = vFirstName;
                            oContactEmp.LastName = (vLastName != NULL ? vLastName : emailOrigen); 
                            oContactEmp.Phone = vPhone;
                            oContactEmp.CC_Numero_Documento__c = vNif + '';
                            oContactEmp.CC_Idioma__c = idioma;
                            oContactEmp.AccountId = oAccountEmp.Id;
                            oContactEmp.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
                            insert oContactEmp;
                        } else{
                            oContactEmp = vCon[0];
                            if (oContactEmp.AccountId == null) { 
                                oAccountEmp.Name=((vName.trim() != '' && vName != NULL)? vName : emailOrigen); 
                                oAccountEmp.CC_Numero_Documento__c = vNif + '';
                                oAccountEmp.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
                                insert oAccountEmp;
                                oContactEmp.AccountId = oAccountEmp.Id;
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
                            oPAccount.Phone = vPhone;
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
                                oPAccount.Phone = vPhone;
                                oPAccount.CC_Idioma__pc = idioma;
                                oPAccount.CC_Numero_Documento__c = vNif + '';
                                oPAccount.CC_Numero_Documento__pc = vNif + '';
                                oPAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
                                insert oPAccount;
                            }
                            else {
                                oPAccount = oContactEmp.Account;
                            }
                        }
                    }
                    
                    
                    newCase.Description =  myPlainText.left(32000);
                    //Controlar si es particular o empresa para informar contacto y cuenta o solo cuenta (PA)
                    if (sTipoNif == 'CIF'){
                        newCase.contactId = oContactEmp.id;
                        newCase.AccountId = oAccountEmp.id;
                    } else {
                        newCase.AccountId = oPAccount.id;
                        /*if (vCon.size()==0){
                            newCase.AccountId = oPAccount.id;
                            
                        }*/
                    }
                    //newCase.contactId = Contacto.id;
                    //newCase.AccountId = Contacto.AccountId;
                    String emailSubject = email.Subject;
                    if (emailSubject.length() > 255) {
                        emailSubject = emailSubject.left(255); 
                    }
                    newCase.Subject = emailSubject;
                    newCase.Origin ='Email';
                    newCase.CC_Idioma__c = idioma;
                    newCase.CC_Canal_Procedencia__c = 'Accionista';
                    newCase.CC_Numero_Documento__c = vNif + '';
                    newCase.CC_MailTelfNotif__c = emailOrigen;
                    newCase.CC_Fecha_Activo_Formulario__c = CC_SLA_Utils.calculo_Fecha_Activo('Accionista');
                    
                    try {
                        Group cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND Developername='CC_Inbound_Email_Accionistas' LIMIT 1];
                        newCase.OwnerId=cola.Id;
                    } catch (QueryException e) {
                        System.debug('Falta Cola: ' + e);
                    }
                    
                    //newCase.SourceId =  null;
                    insert newCase;
                    
                    // Save attachments, if any
                    List<Id> listaContentVersionIdEmail = new List<Id>();
                    EmailMessage crearEmailMessageV = crearEmailMessage(email,emailDestino ,newCase.id,null,myPlainTextOrig);
                    
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
                        insert listaContentVersion;
                        
                        //Recuperar ContentDocumentId de los registros Content Version insertados
                        List<Id> listaContentVersionId = new List<Id>();
                        for (ContentVersion cv : listaContentVersion) {
                            listaContentVersionId.add(cv.Id);
                            listaContentVersionIdEmail.add(cv.Id);
                        }
                        listaContentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :listaContentVersionId];
                        
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
                        listaContentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :listaContentVersionId];
                        
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
                    
                    //EmailMessage crearEmailMessage = crearEmailMessage(email, emailDestino, newCase.id,Contacto.id,myPlainTextOrig);
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
    
    public static EmailMessage crearEmailMessage(Messaging.inboundEmail email, String emailDestino, Id caseId, Id contactId, String myPlainText){
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        EmailMessage createEmail = new EmailMessage();
        try {
            
            //Si supera el tamaño del campo hay que recortar para que no falle
            String caseDescription = myPlainText;
            if (myPlainText.length() > 32000) {
                caseDescription = myPlainText.left(32000); 
            }
            
            Task createTask = new Task(
            Type='Correo no identificado'
            ,TaskSubtype   = 'Email'
            ,Subject      = 'Correo entrante accionistas' 
            ,ActivityDate = System.today()
            ,Status = 'Completed'
            ,Description = caseDescription
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
            //,ActivityId = createTask.Id // NOT WRITABLE !
            createEmail.Status = '1';
            if (email.ccAddresses!=null) {
                createEmail.CcAddress = string.join(email.ccAddresses,','); 
            }
            createEmail.FromAddress = email.fromAddress;
            createEmail.FromName = email.fromName;
            createEmail.ToAddress = emailDestino;
            createEmail.Headers = JSON.serialize( email.headers );
            //createEmail.HtmlBody = 'email.htmlBody';
            createEmail.TextBody = myPlainText;
            createEmail.Incoming = true;
            createEmail.MessageDate = DateTime.now();
            createEmail.ParentId = caseId;
            createEmail.MessageIdentifier = email.messageId;
            createEmail.CBK_sfdcMessageId__c = email.messageId?.left(255);
            createEmail.ThreadIdentifier = email.inReplyTo;
            
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
        if (vnifIn==null) {vnifOut='';}
        return vnifOut;
    }
    
    public string validacionEmail(String vemailIn){
        String vemailOut = vemailIn;
        //Por si hay varios mails  
        if (vemailIn!=null) {
            Matcher m = Pattern.compile('[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+').matcher(vemailIn);
            while (m.find()) {
                vemailOut=m.group();
            }              
        }
        
        return vemailOut;
    }
    
    //Ajuste por perdida de saltos de carro perdidos
    public string ajusteMensaje(string vtextin){
        String vtextout = vtextin;
        
        vtextout=vtextout.unescapeHtml4() ;
        vtextout=vtextout.replace('Nombre:', '\r\nNombre:');
        vtextout=vtextout.replace('Primer apellido:', '\r\nPrimer apellido:');
        vtextout=vtextout.replace('Segundo apellido:', '\r\nSegundo apellido:');     
        vtextout=vtextout.replace('Nif:', '\r\nNif:');
        vtextout=vtextout.replace('Email:', '\r\nEmail:');
        vtextout=vtextout.replace('Telefono:', '\r\nTelefono:');
        vtextout=vtextout.replace('Comentario:', '\r\nComentario:');
        
        return vtextout;
    }
    
}