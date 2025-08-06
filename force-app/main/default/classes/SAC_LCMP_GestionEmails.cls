public without sharing class SAC_LCMP_GestionEmails {

    private static Set<String> objetos = new Set<String>{'Case','SAC_MaestroTemas__c', 'SAC_Interaccion__c','SAC_Accion__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    final static Id RECTYPERECLAMACION = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    final static Id RECTYPECONSULTA = mapRTsObjects.get('Case').get('SAC_Consulta').getRecordTypeId();
    final static Id RECTYPECONSULTASAC = mapRTsObjects.get('Case').get('SAC_ConsultaSAC').getRecordTypeId();
    final static Id RECTYPEPRETENSION = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();
    final static Id RECORDTYPEBLACKLIST = mapRTsObjects.get('SAC_MaestroTemas__c').get('SAC_BlackListEmails').getRecordTypeId();
    final static Id RECORDTYPECONSULTA = mapRTsObjects.get('SAC_Interaccion__c').get('SAC_Consulta').getRecordTypeId();
    final static Id RECORDTYPEESCALADON2 = mapRTsObjects.get('SAC_Interaccion__c').get('SAC_Escalado').getRecordTypeId();
    final static Id RECORDTYPEESCALADON3 = mapRTsObjects.get('SAC_Interaccion__c').get('SAC_EscaladoNV3').getRecordTypeId();
    final static Id RECORDTYPEMAESTROTAREA = mapRTsObjects.get('SAC_Accion__c').get('SAC_MaestroDeTareas').getRecordTypeId();
    final static Id RECORDTYPEOTRASTAEAS = mapRTsObjects.get('SAC_Accion__c').get('SAC_OtrasTareas').getRecordTypeId();
    final static Id RECTYPERECLAMACIONSPV = mapRTsObjects.get('Case').get('SPV_Reclamacion').getRecordTypeId();


    /**
    * Proposito: Envio Mail + comunicacion equipos + mover estado caso + mover estado acciones
    * Modificación: US723742 - Raúl Santos - 05/03/2024 - Añadir lógica envio emails blackList
    * Modificación: US776301 - Raúl Santos - 18/11/2024 - No enviar la comunicacion de resolución cuando no coincide el mail de correo web con el del caso si el web email es un correo de los dominios en la black list (SAC_BlacklistDominioEmail__mdt).
    *                                                     Tampoco se tiene que enviar cuando en el canal de entrada o de respuesta esta indicado "carta postal".
    *                                                     Sí enviar cuando el correo del caso este en blanco y el correo web cumplimentado se envié el aviso automático (si no esta en la blacklist de dominios)
    */
    @AuraEnabled
    public static void finalizarRedaccion(String id, String para, String copia, String copiaOculta, String cuerpo, String asunto, String idAdjuntos){
        Case casoActual = [SELECT Id, SAC_FechaVencimientoSLA__c, SAC_MotivoDemora__c, SAC_ComentarioDemora__c, OS_Email__c, SuppliedEmail, CC_Idioma__c, Origin, CC_Canal_Respuesta__c FROM Case WHERE Id = :id AND RecordTypeId = :RECTYPERECLAMACION LIMIT 1];

        //Añadido comprobar el target date del caseMilestone en lugar del campo SAC_FechaVencimientoSLA__c del caso
        List<CaseMilestone> listaCM = [SELECT Id, TargetDate FROM CaseMilestone WHERE CaseId = :id AND MilestoneType.Name = 'SLA Regulatorio'];
        if(/*casoActual.SAC_FechaVencimientoSLA__c*/!listaCM.isEmpty() && listaCM[0].TargetDate != null && listaCM[0].TargetDate < System.now() && casoActual.SAC_MotivoDemora__c == null){
            throw new AuraHandledException( 'El SLA Regulatorio esta sobrepasado, debe informar los motivos de la demora mediante el botón "Resolver Reclamación" antes de continuar.' );
        }else{
            enviarEmail(id, para, copia, copiaOculta, cuerpo, asunto, idAdjuntos, 'primerenvioredaccion');
            SAC_LCMP_RedaccionFinal.finalizarRedaccion(id, true, false);
            
            // Si el email del caso es distinto al web email se tiene que enviar un email indicando que se ha enviado la resolución del caso al email del caso
            if(casoActual.OS_Email__c != casoActual.SuppliedEmail && String.isNotBlank(casoActual.SuppliedEmail) && casoActual.Origin != 'SAC_CartaPostal' && casoActual.CC_Canal_Respuesta__c != 'SAC_CartaPostal') {  

                Boolean continuarProceso = true;

                //Recuperar los dominios activos en el metadata SAC_BlacklistDominioEmail__mdt
                List<SAC_BlacklistDominioEmail__mdt> listDominiosBloqueados = [SELECT SAC_DominioEmail__c FROM SAC_BlacklistDominioEmail__mdt WHERE SAC_DominioActivo__c = true];

                if(!listDominiosBloqueados.isEmpty()){
                    Set<String> dominiosBloqueados = new Set<String>();

                    for(SAC_BlacklistDominioEmail__mdt dominio : listDominiosBloqueados) {
                        dominiosBloqueados.add(dominio.SAC_DominioEmail__c);
                    }

                    String webEmail = casoActual.SuppliedEmail;
                    String dominioWebEmail = '@' + webEmail.substringAfter('@');

                    //Si el dominio del web email, esta contenido en los dominios activos de la blacklist de dominios, no se envia la comunicación
                    if(dominiosBloqueados.contains(dominioWebEmail)){
                        continuarProceso = false;
                    }
                }

                if(continuarProceso){
                //Recupero los emails no validos de envio (emails en la blackList)
                List<SAC_MaestroTemas__c> listEmailsNoValidos = [SELECT Name FROM SAC_MaestroTemas__c WHERE RecordTypeId =: RECORDTYPEBLACKLIST AND SAC_Activo__c = true];

                //Compruebo la dirección de envio con las de la blackList
                List<String> listaDireccionesPara = new List<String>{ casoActual.SuppliedEmail };
                List<String> emailsValidos = SAC_Utils.comprobarEmailsBlackListAuto(listEmailsNoValidos, listaDireccionesPara);

                //Si la dirección de envio es válida (no está en la blackList), continuo el proceso
                if(!emailsValidos.isEmpty()){
                    comunicarResolucion(casoActual);
                }
            }
        }     
    }
    }


    /**
    * Proposito: Envio Comunicación Resolución Mail
    */
    public static void comunicarResolucion(Case casoActual){
        List<String> body = new List<String>();
        Id idPlantillaAviso = null;
        List<SAC_PlantillaRedaccion__c> lstPlantillas = [SELECT Id, SAC_PlantillaCatalanId__c, SAC_PlantillaCastellanoId__c, SAC_PlantillaInglesId__c, SAC_PlantillaEuskeraId__c, SAC_PlantillaValencianoId__c, SAC_PlantillaGallegoId__c FROM SAC_PlantillaRedaccion__c WHERE SAC_TipoPlantilla__c = 'SAC_AvisoResolucion'];

        if(lstPlantillas != null && !lstPlantillas.isEmpty()){
            for(SAC_PlantillaRedaccion__c plantilla : lstPlantillas){
                if(casoActual.CC_Idioma__c == 'es'){
                    idPlantillaAviso = plantilla.SAC_PlantillaCastellanoId__c;
                } else if(casoActual.CC_Idioma__c == 'ca'){
                    idPlantillaAviso = plantilla.SAC_PlantillaCatalanId__c;
                } else if(casoActual.CC_Idioma__c == 'en'){
                    idPlantillaAviso = plantilla.SAC_PlantillaInglesId__c;
                } else if(casoActual.CC_Idioma__c == 'eu'){
                    idPlantillaAviso = plantilla.SAC_PlantillaEuskeraId__c;
                } else if(casoActual.CC_Idioma__c == 'va'){
                    idPlantillaAviso = plantilla.SAC_PlantillaValencianoId__c;
                } else if(casoActual.CC_Idioma__c == 'ga'){
                    idPlantillaAviso = plantilla.SAC_PlantillaGallegoId__c;
                }else {
                    idPlantillaAviso = plantilla.SAC_PlantillaCastellanoId__c;
                }   
            }
        }

        if(idPlantillaAviso != null){
            EmailTemplate templateEmail = new EmailTemplate();
            templateEmail = [SELECT Id, Name, Subject, HtmlValue FROM EmailTemplate WHERE Id =: idPlantillaAviso];

            body.add(templateEmail.HtmlValue);
            String whoId = UserInfo.getUserId();
            String whatId = casoActual.Id;
            Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(templateEmail.Id, whoId, whatId); 

            enviarEmail(casoActual.id, casoActual.SuppliedEmail, '', '', renderStored.getHtmlBody(), renderStored.getSubject(), '', 'primerenvioinformarredaccion');
        }
    }


    /**
    * Proposito: Envio Mail
    * Modificación: US709215 - Raúl Santos - 03/04/2024 - Añadir para las consultas a grupos externos la concatenación de los emails messages enviados
    */ 
    @AuraEnabled
    public static void enviarEmail(Id id, String para, String copia, String copiaOculta, String cuerpo, String asunto, String idAdjuntos, String tipoEnvio){
        System.System.debug('Kevin id: ' + id);
        System.System.debug('Kevin para: ' + para);
        System.System.debug('Kevin copia: ' + copia);
        System.System.debug('Kevin copiaoculta: ' + copiaOculta);
        System.System.debug('Kevin cuerpo: ' + cuerpo);
        System.System.debug('Kevin asunto: ' + asunto);
        System.System.debug('Kevin idadjuntos ' + idAdjuntos);
        System.System.debug('Kevin tipoEnvio ' + tipoEnvio);
        Schema.SObjectType expectedCase = Schema.Case.getSObjectType();
        Schema.SObjectType expectedInteraccion = Schema.SAC_Interaccion__c.getSObjectType();
        Schema.SObjectType expectedAccion = Schema.SAC_Accion__c.getSObjectType();
        Schema.SObjectType tipoObjeto = id.getsobjecttype();

        List<ContentVersion> lstCV = new List<ContentVersion>();
        List<ContentDocumentLink> cdlist  = new List<ContentDocumentLink>();
        Set<Id> fileId = new Set<Id>();
        List<Id> lstIdCV = new List<Id>();
        Case caso = new Case();
        SAC_CaseReclamante__c reclamantePrincipal = new SAC_CaseReclamante__c();
        CBK_Case_Extension__c caseExtension  = new CBK_Case_Extension__c();
        SAC_Interaccion__c interaccion = new SAC_Interaccion__c();
        SAC_Accion__c accion = new SAC_Accion__c();
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        Boolean actualizarReclamante = false;

        if(tipoObjeto == expectedCase){
            caso = [SELECT Id, CaseNumber, CC_SuppliedID__c, RecordTypeId, Status, SAC_M2P__c, SAC_Reclamacion__r.SAC_M2P__c, CC_Idioma__c, CC_Oficina__c, ContactId, AccountId FROM Case WHERE RecordTypeId IN (:RECTYPERECLAMACION, :RECTYPECONSULTA, :RECTYPECONSULTASAC, :RECTYPEPRETENSION, :RECTYPERECLAMACIONSPV) AND Id =: id  LIMIT 1];

            if(caso.RecordTypeId == RECTYPERECLAMACIONSPV){
                

                caseExtension = [SELECT Id, SPV_ReclamantePrincipalEmail__c
                                            FROM CBK_Case_Extension__c  
                                            WHERE Case_Id__c  = :id
                                            LIMIT 1];

                if(caseExtension.SPV_ReclamantePrincipalEmail__c){
                    reclamantePrincipal = [SELECT Id, SAC_Contact__c,SAC_Account__c, SAC_Account__r.CC_Idioma__pc, SAC_ReclamantePrincipal__c, SAC_Account__r.AV_OfficeManager__c
                                            FROM SAC_CaseReclamante__c 
                                            WHERE SAC_ReclamantePrincipal__c = true AND SAC_Case__c = :id 
                                            LIMIT 1];

                    caso.CC_Idioma__c = reclamantePrincipal.SAC_Account__r.CC_Idioma__pc;
                    caso.CC_Oficina__c = reclamantePrincipal.SAC_Account__r.AV_OfficeManager__c;         
                    caso.AccountId = reclamantePrincipal.SAC_Account__c;
                    caso.ContactId = reclamantePrincipal.SAC_Contact__c;

                    caseExtension.SPV_ReclamantePrincipalEmail__c = false;

                    actualizarReclamante = true;


                }
            }          


        }else if(tipoObjeto == expectedInteraccion){
            interaccion = [SELECT Id, SAC_IndexedThreadId__c, SAC_Oficina__c, SAC_Reclamacion__c, SAC_GrupoColaborador__c, SAC_DNI__c, SAC_Reclamante__c, SAC_Respuesta__c, RecordTypeId, SAC_GrupoColaborador__r.SAC_Externo__c, SAC_Reclamacion__r.SAC_M2P__c
                                FROM SAC_Interaccion__c WHERE RecordTypeId IN (:RECORDTYPECONSULTA, :RECORDTYPEESCALADON2, :RECORDTYPEESCALADON3) AND Id =: id LIMIT 1];
                                 
        }else if(tipoObjeto == expectedAccion){
            accion = [SELECT Id, SAC_IndexedThreadId__c, SAC_Oficina__c, SAC_Reclamacion__c, SAC_EquipoResponsable__c, SAC_Reclamacion__r.SAC_M2P__c
                                FROM SAC_Accion__c WHERE RecordTypeId IN (:RECORDTYPEMAESTROTAREA, :RECORDTYPEOTRASTAEAS) AND Id =: id LIMIT 1];
        }
        
        if(String.isNotBlank(idAdjuntos) && idAdjuntos != '[]'){
            Set<Id> idsAdjuntos = (Set<Id>)JSON.deserialize(idAdjuntos, Set<Id>.class);
            Set<Id> idsAdjuntosFinal = new Set<Id>();
            for (Id adj : idsAdjuntos) {
                if (adj != null) {
                    idsAdjuntosFinal.add(adj);
                }
            }
             
            /**if (!idsAdjuntosFinal.isEmpty()) {
                cdlist = [SELECT id, LinkedEntityId, ContentDocumentId, ContentDocument.LatestPublishedVersionId FROM ContentDocumentLink WHERE ContentDocumentId IN: idsAdjuntosFinal];  
            }
            for(ContentDocumentLink cl :cdlist){
                fileId.add(cl.ContentDocumentId); 
            }*/

            if(!idsAdjuntosFinal.isEmpty()){
                lstCV = [SELECT Id, ContentDocumentId, VersionData, SAC_Enviado__c FROM ContentVersion WHERE ContentDocumentId IN: idsAdjuntosFinal AND SAC_BloqueoTotalVisibilidad__c = false];  
            }
       
            if(!lstCV.isEmpty()){
                for(ContentVersion contentVersion :lstCV){
                    lstIdCV.add(contentVersion.Id);
                    Blob versionDataBlob = contentVersion.VersionData;
                    String versionData = EncodingUtil.base64Encode(versionDataBlob);
                }
            }
        }

        if(String.isNotBlank(para)){
            message = completarPara(message, para);
        }

        if(String.isNotBlank(copia)){
            message = completarCopia(message, copia);
        }

        if(String.isNotBlank(copiaOculta)){
            message = completarCopiaOculta(message, copiaOculta);
        }

        message.optOutPolicy = 'FILTER';
        message.Subject = asunto;

        String cuerpoConcatenado = '';

        if(tipoObjeto == expectedCase){
            cuerpoConcatenado = '<div style="display:none;">' + caso.CC_SuppliedID__c + ' </div>' + cuerpo;
        }
        else if(tipoObjeto == expectedInteraccion){
            if(interaccion.RecordTypeId == RECORDTYPECONSULTA && interaccion.SAC_GrupoColaborador__r.SAC_Externo__c == true){
                String htmlArrastrarEmails = '';

                List<EmailMessage> listEmailMessages = [SELECT Id, FromAddress, ToAddress, CcAddress, BccAddress, MessageDate, Subject, HtmlBody FROM EmailMessage WHERE RelatedToId =: interaccion.Id ORDER BY CreatedDate DESC LIMIT 1];

                if(!listEmailMessages.isEmpty()){
                    htmlArrastrarEmails = arrastrarEmailsFormato(listEmailMessages[0]);
                }

                cuerpoConcatenado = cuerpo + htmlArrastrarEmails;
            }else{
                cuerpoConcatenado = cuerpo;
            }
        }
        else if(tipoObjeto == expectedAccion){
            cuerpoConcatenado = cuerpo;
        }

        //DE106853 - Raúl Santos - 20/11/2024 - Gestionar las imágenes que vienen inline.
		String cuerpoFinal = SAC_Utils.gestionarImagenesInlineRedactarMail(cuerpoConcatenado);

        message.setHtmlBody(cuerpoFinal);

        if(!lstIdCV.isEmpty()){
            message.setEntityAttachments(lstIdCV);
        }

        OrgWideEmailAddress orgwideaddress = new OrgWideEmailAddress();
        //US575200 31/03/2023 Se cambió el buzón de las consultas SAC al mismo que las reclamaciones y dejar el buzón de consulta solo para consultas cops
        //US777526 22/05/2024 Se cambió el buzón dependiendo de si la reclamación es money to pay.
        orgwideaddress = asignarOWA(caso, interaccion, accion);

        message.setOrgWideEmailAddressId(orgwideaddress.Id);

        
        if(tipoObjeto == expectedCase){
            message.setWhatId(caso.Id);
        }
        else if(tipoObjeto == expectedInteraccion){
            message.setWhatId(interaccion.Id);
        }
        else if(tipoObjeto == expectedAccion){
            message.setWhatId(accion.Id);
        }

        //Mandamos el mail
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};

        try{
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            
            List<ContentDocumentLink> lstContentDocument = new List<ContentDocumentLink>();
            List<ContentVersion> listCvAct = new List<ContentVersion>();
            Date fechaActual = Date.today();
            List<EmailMessage> lstEmailMessage = [SELECT id FROM EmailMessage WHERE parentId = :caso.Id AND Subject = :asunto AND Incoming = false ORDER BY createdDate DESC LIMIT 1];
            if(!lstEmailMessage.isEmpty()){
                EmailMessage emailRecuperado = lstEmailMessage[0];
                List<ContentDocumentLink> lstContentDocumentlink = [SELECT Id FROM ContentDocumentLink WHERE LINKEDENTITYID =: emailRecuperado.id];
                if(lstContentDocumentlink.isEmpty()) {
                    if(!lstCV.isEmpty()){
                        for(ContentVersion contentVersion : lstCV){
                            ContentDocumentLink contentLink = new ContentDocumentLink();
                            contentLink.LinkedEntityId = lstEmailMessage[0].Id;
                            contentLink.ContentDocumentId = contentVersion.ContentDocumentId;
                            lstContentDocument.add(contentLink);
                            
                            if(!contentVersion.SAC_Enviado__c){
                                listCvAct.add(new ContentVersion(Id=contentVersion.Id,SAC_Enviado__c=true));
                            }
                        }
                    }

                    if(!lstContentDocument.isEmpty()){
                        SAC_DatabaseDML.insertListDML(lstContentDocument, true);
                    }
                }else{
                    if(!lstCV.isEmpty()){
                        for(ContentVersion contentVersion : lstCV){                            
                            if(!contentVersion.SAC_Enviado__c){
                                listCvAct.add(new ContentVersion(Id=contentVersion.Id,SAC_Enviado__c=true));
                            }
                        }
                    }
                }

                if(!listCvAct.isEmpty()){
                    SAC_DatabaseDML.updateListDML(listCvAct, true);
                }

                //Si el EmailMessage es de la redaccion final de una reclamación, actualizamos el campo SAC_EnvioRedaccion__c del EmailMessage
                if(caso.RecordTypeId == RECTYPERECLAMACION && caso.Status == 'SAC_003' && (tipoEnvio != '' || tipoEnvio != null)){
                    emailRecuperado.SAC_EnvioRedaccion__c = tipoEnvio;
                    emailRecuperado.SAC_IDAdjuntos__c = idAdjuntos;
                    SAC_DatabaseDML.updateDML(emailRecuperado, true);
                }

                if(actualizarReclamante){

                    SAC_DatabaseDML.updateDML(caso, true);

                    SAC_DatabaseDML.updateDML(caseExtension, true);
                }


            }     
            
        }catch (Exception e){
            CBK_Log.error(e);
            String emailDestinoInvalido = completaEmailNoValido(para, copia, copiaOculta);

            if(emailDestinoInvalido != '' && emailDestinoInvalido != null){
                throw new AuraHandledException('La dirección/es de destino ' + '"' + emailDestinoInvalido.trim() + '"' + ' no es válida/s.');
            }else{
                String messageError = e.getMessage();

                if(messageError.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                    Pattern regex = Pattern.compile('FIELD_CUSTOM_VALIDATION_EXCEPTION,(.*)');

                    Matcher matcher = regex.matcher(messageError);

                    if (matcher.find()) {
                        messageError = matcher.group(1);
                    }
                }

                throw new AuraHandledException('Error en el envío: ' + messageError);
            }
        }
    }

    /**
    * Proposito: US709215 - Raúl Santos - 03/04/2024 - Dar formato al email message anterior para enviar al usuario
    */ 
    public static String arrastrarEmailsFormato(EmailMessage emailMessage){

        String textoFormateado = '<hr><br><span><strong>De: </strong>' + emailMessage.FromAddress + '</span><br>' +
                                 '<span><strong>Enviado el: </strong>' + formatearFecha(emailMessage.MessageDate) + '</span><br>' +
                                 '<span><strong>Para: </strong>' + emailMessage.ToAddress + '</span><br>' +
                                 (emailMessage.CCAddress != null && emailMessage.CCAddress != '' ? '<span><strong>CC: </strong>' + emailMessage.CCAddress + '</span><br>' : '') +
                                 '<span><strong>Asunto: </strong>' + emailMessage.Subject + '</span><br><br>' +
                                 '<span>' + emailMessage.HtmlBody + '</span><br>';
        

        return textoFormateado;
    }

    /**
    * Proposito: US709215 - Raúl Santos - 03/04/2024 - Formatear la fecha para pasar de '2024-04-03 10:51:57' a 'DiaSemana, dia de mes de año hh:mm'
    */ 
    public static String formatearFecha(DateTime fecha) {
        
        List<String> dias = new List<String>{'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'};
        List<String> meses = new List<String>{'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'};
        
        Integer diaDeLaSemana = Integer.valueOf(fecha.format('u')) - 1;
        String dia = dias[diaDeLaSemana];
        String mes = meses[fecha.month() - 1];
        Integer anio = fecha.year();
        Integer diaDelMes = fecha.day();
        String hora = fecha.format('HH:mm');
        
        return dia + ', ' + diaDelMes + ' de ' + mes + ' de ' + anio + ' ' + hora;
    }

    @AuraEnabled
    public static ContentVersion[] obtieneAdjuntos(String id){
        try {
            List<ContentVersion> cv = [SELECT Id, ContentDocumentId, Title FROM ContentVersion WHERE 
                                    FirstPublishLocationId =: id AND SAC_BloqueoTotalVisibilidad__c = false];
            
            ContentVersion[] resultado =  new List<ContentVersion>();
            for(ContentVersion record : cv){
                resultado.add(record);
            }

            return resultado;
        } catch (Exception e) {throw new AuraHandledException(e.getMessage());}
    }

    @AuraEnabled
    public static ContentVersion[] eliminaRegistro(String id){
        try {
            ContentVersion cv = [SELECT Id, ContentDocumentId, FirstPublishLocationId FROM ContentVersion WHERE Id =: id LIMIT 1];
            ContentDocument cd = [SELECT Id FROM ContentDocument WHERE Id =: cv.ContentDocumentId LIMIT 1];
            Id casoId = cv.FirstPublishLocationId;
            SAC_DatabaseDML.deleteDML(cd, false); 
            //Database.delete(cd);

            List<ContentVersion> cvs = [SELECT Id, Title FROM ContentVersion WHERE 
                                    FirstPublishLocationId =: casoId];

            ContentVersion[] resultado =  new List<ContentVersion>();
            for(ContentVersion record : cvs){
                resultado.add(record);
            }
            return resultado;

        } catch (Exception e) {throw new AuraHandledException(e.getMessage());}
    }

    @AuraEnabled
    public static ContentVersion[] recuperaAdjuntos(Id id){
        try {
            Set<Id> idList = new Set<Id>();
            idList.add(id);            

            ContentVersion[] resultado = new List<ContentVersion>();

            if(!String.isBlank(id)){
                List<ContentDocumentLink> lstCDL = [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.Title, ContentDocument.LatestPublishedVersion.SAC_Bloque__c FROM ContentDocumentLink WHERE LinkedEntityId IN: idList AND ContentDocument.LatestPublishedVersion.SAC_BloqueoTotalVisibilidad__c = false];

                if(!lstCDL.isEmpty()){
                    for(ContentDocumentLink record : lstCDL){
                        resultado.add(new ContentVersion (ContentDocumentId=record.ContentDocumentId, Title=record.ContentDocument.Title, SAC_Bloque__c=record.ContentDocument.LatestPublishedVersion.SAC_Bloque__c));
                    }
                }
                 
                return resultado;
            }else{
                return resultado;
            }
        } catch (Exception e) {throw new AuraHandledException(e.getMessage());}
    }
    @AuraEnabled
    public static void eliminaContentDocument(String id){
        try {
            ContentDocument cd = [SELECT Id FROM ContentDocument WHERE Id =: id LIMIT 1];
            SAC_DatabaseDML.deleteDML(cd, false); 
            //Database.delete(cd);

        } catch (Exception e) {throw new AuraHandledException(e.getMessage());}
    }

    @AuraEnabled
    public static Case recogerCaso(String caseId){
        try {
            Case caso = [SELECT Id FROM Case WHERE Id = :caseId LIMIT 1];
            return caso;
        } catch (Exception e) {throw new AuraHandledException(e.getMessage());}
    }

    @AuraEnabled
    public static List<ContentVersion> getDocumentRedaccion(String id){
        // List<ContentVersion> documentos = [SELECT Id, Title, ContentDocumentId, SAC_ValidadoCV__c FROM ContentVersion WHERE SAC_Bloque__c INCLUDES ('SAC_Respuesta')  AND FirstPublishLocationId =: id];
        // return documentos;

        Map<Id, Boolean> contentOculto = new Map<Id, Boolean>();
        List<Id> idsDocumentLink = new List<Id>();

        try {
            List<ContentDocumentLink> cdL = [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId =: id AND ContentDocument.FileType != 'SNOTE'];  

            for(ContentDocumentLink recordCdL : cdL){
                idsDocumentLink.add(recordCdL.ContentDocumentId);
            }

            List<ContentVersion> cv = [SELECT Id, ContentDocumentId, Title, SAC_Oculto__c, CreatedDate, SAC_TipoAdjunto__c, SAC_TipoAdjunto__r.Name, SAC_Bloque__c, SAC_ValidadoCV__c, SAC_Numero_Prestamo__c FROM ContentVersion WHERE SAC_Bloque__c INCLUDES ('SAC_Respuesta') AND ContentDocumentId IN: idsDocumentLink AND SAC_BloqueoTotalVisibilidad__c = false ORDER BY CreatedDate ASC];

            return cv;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Proposito: Método para prorrogar y enviar mail prorrogar
    */
    @AuraEnabled
    public static void prorrogarCaso(String id, String para, String copia, String copiaOculta, String cuerpo, String asunto, String idAdjuntos){

        enviarEmail(id, para, copia, copiaOculta, cuerpo, asunto, idAdjuntos, '');
        SAC_LCMP_UpdateStatus.prorroga(id);

    }

    /**
     * Método para actualizar el campo SAC_UltimaModificacionFichero__c del caso cada vez que se inserte un fichero nuevo.
     * En caso de ser desde la pretensión, lo actualiza tanto en esta como en su reclamación padre. En este caso, además inserta
     * contentDocumentLink que apunten a los ficheros insertados y a la reclamación, para que puedan ser seleccionados desde esta.
     */
    @AuraEnabled
    public static void rellenarUltimaModFichero(String caseId, List<String> ficheros, Boolean marcarRespuesta) {
        List<Case> caso = [SELECT Id, RecordTypeId, SAC_Reclamacion__c FROM Case WHERE (RecordTypeId = :RECTYPERECLAMACION OR RecordTypeId = :RECTYPEPRETENSION)
                            AND Id = :caseId];

        List<Case> listaCasosUpdatear = new List<Case>();
        List<ContentDocumentLink> listaCDLs = new List<ContentDocumentLink>();

        if (!caso.isEmpty()) {
            //Se modifica el campo SAC_UltimaModificacionFichero__c
            caso[0].SAC_UltimaModificacionFichero__c = system.now();
            listaCasosUpdatear.add(caso[0]);

            //Si es pretensión, se modifica el campo SAC_UltimaModificacionFichero__c de la reclamación padre además de el de la pretensión
            //Además, se añade el content document link a la reclamación padre
            if (caso[0].RecordTypeId == RECTYPEPRETENSION) {
                //Reclamación padre
                Case reclamacionPadre = new Case();
                reclamacionPadre.Id = caso[0].SAC_Reclamacion__c;
                reclamacionPadre.SAC_UltimaModificacionFichero__c = system.now();
                listaCasosUpdatear.add(reclamacionPadre);
                //ContentDocumentLink a la reclamación y a los ficheros
                if (!ficheros.isEmpty()) {
                    for (String ficheroId : ficheros) {
                        ContentDocumentLink cdl = new ContentDocumentLink();
                        cdl.LinkedEntityId = caso[0].SAC_Reclamacion__c;
                        cdl.ContentDocumentId = ficheroId;
                        listaCDLs.add(cdl);
                    }
                }
            }    
        }
        
        //Update de los casos
        if (!listaCasosUpdatear.isEmpty()) {
            SAC_DatabaseDML.updateListDML(listaCasosUpdatear, true);
        }
        //Insert de los contentDocumentLink
        if (!listaCDLs.isEmpty()) {
            SAC_DatabaseDML.insertListDML(listaCDLs, true);
        }

        // Añadido para updatear el campo SAC_Bloque__c del contentVersion con el valor SAC_Tramitacion
        List<ContentVersion> listaCV = [
            SELECT Id, ContentDocumentId, Title
            FROM ContentVersion
            WHERE ContentDocumentId IN :ficheros
            ORDER BY CreatedDate DESC
        ];

        if (!listaCV.isEmpty()) {
            for (ContentVersion cv : listaCV) {
                if (marcarRespuesta) {
                    cv.SAC_Bloque__c = 'SAC_Respuesta';
                } else {
                    cv.SAC_Bloque__c = 'SAC_Tramitacion';
                }
            }
            SAC_DatabaseDML.updateListDML(listaCV, false);
        }
        // Fin añadido
    }

    public static Messaging.SingleEmailMessage completarPara(Messaging.SingleEmailMessage message, String para){
        List<String> listaDirecciones = new List<String>();
            String direccion = '';

            Integer i=0;
            do{
                if(i<para.length()){

                    if(para.substring(i,i+1) != ';'){
                        direccion += para.substring(i,i+1);
                    }
                    else{
                        listaDirecciones.add(direccion);
                        direccion = '';
                    }
                    
                }
                i=i+1;
            }while(i < para.length());

            listaDirecciones.add(direccion);
            message.toAddresses = listaDirecciones;

            return message;
    }

    public static Messaging.SingleEmailMessage completarCopia(Messaging.SingleEmailMessage message, String copia){
        List<String> listaDireccionesCopia = new List<String>();
        String direccionCopia = '';

        Integer i=0;
        do{
            if(i<copia.length()){

                if(copia.substring(i,i+1) != ';'){
                    direccionCopia += copia.substring(i,i+1);
                }
                else{
                    listaDireccionesCopia.add(direccionCopia);
                    direccionCopia = '';
                }
                
            }
            i=i+1;
        }while(i < copia.length());
        listaDireccionesCopia.add(direccionCopia);

        message.CcAddresses = listaDireccionesCopia;

        return message;
    }

    public static Messaging.SingleEmailMessage completarCopiaOculta(Messaging.SingleEmailMessage message, String copiaOculta){
        List<String> listaDireccionesCopiaOculta = new List<String>();
        String direccionCopiaOculta = '';

        Integer i=0;
        do{
            if(i<copiaOculta.length()){

                if(copiaOculta.substring(i,i+1) != ';'){
                    direccionCopiaOculta += copiaOculta.substring(i,i+1);
                }
                else{
                    listaDireccionesCopiaOculta.add(direccionCopiaOculta);
                    direccionCopiaOculta = '';
                }
                
            }
            i=i+1;
        }while(i < copiaOculta.length());
        listaDireccionesCopiaOculta.add(direccionCopiaOculta);

        message.BccAddresses = listaDireccionesCopiaOculta;

        return message;
    }

    public static String completaEmailNoValido(String para, String copia, String copiaOculta){
        
        List<String> buzonesSalidaInvalidos = new List<String>();
        for (Buzon_SAC__mdt buzonPorDefecto : [SELECT SAC_DireccionCorreo__c FROM Buzon_SAC__mdt WHERE SAC_Activo__c = true]) {
            buzonesSalidaInvalidos.add(buzonPorDefecto.SAC_DireccionCorreo__c);
        }

        String mails = '' + para + ';' + copia + ';' + copiaOculta;
        String[] emailsDestino = mails.split(';');
        String emailDestinoInvalido = '';
        Integer j = 0;

        for(Integer i = 0; i < emailsDestino.size(); i++){
            String emailDestino = emailsDestino[i].trim();
            if(buzonesSalidaInvalidos.contains(emailDestino)){
                if(j == 0){
                    emailDestinoInvalido = emailDestinoInvalido + ' ' + emailDestino;
                }else{
                    emailDestinoInvalido = emailDestinoInvalido + ', ' + emailDestino;
                }
                j++;  
            }
        }

        return emailDestinoInvalido;
    }

    @AuraEnabled
    public static void actualizarSACBloqueField(Id fileId) {
        ContentVersion cv = [SELECT Id, SAC_Bloque__c FROM ContentVersion WHERE ContentDocumentId = :fileId ORDER BY CreatedDate DESC LIMIT 1];
        boolean valueChanged = false;
    
        if (cv != null && String.isBlank(cv.SAC_Bloque__c)) {
            cv.SAC_Bloque__c = 'SAC_Respuesta';
            valueChanged = true;
        } else {
            if (cv != null && String.isNotBlank(cv.SAC_Bloque__c) && !cv.SAC_Bloque__c.contains('SAC_Respuesta')) {
                cv.SAC_Bloque__c = cv.SAC_Bloque__c + ';SAC_Respuesta';
                valueChanged = true;
            }
        }
        
        if (valueChanged) {
            SAC_DatabaseDML.updateDML(cv, false);
        }
    }

    /*****************************************************************
    * Proposito: Recuperar los emails de la blackList y pasar al SAC_Utils.comprobarEmailsBlackList las direcciones de envio. Aqui comprobará si son válidas
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0             US723742      Raúl Santos   05/03/2024       Creación
    *****************************************************************/
    @AuraEnabled
    public static String comprobarEmailsEnvio(String para, String copia, String copiaOculta) {

        //Recupero los emails no validos de envio (emails en la blackList)
        List<SAC_MaestroTemas__c> listEmailsNoValidos = [SELECT Name FROM SAC_MaestroTemas__c WHERE RecordTypeId =: RECORDTYPEBLACKLIST AND SAC_Activo__c = true];

        //Compruebo las direcciones de envio con las de la blackList
        String emailsNoValidosEncontrados = SAC_Utils.comprobarEmailsBlackList(listEmailsNoValidos, para, copia, copiaOculta);

        //Devuelvo las direcciones de envio no válidas encontradas (están en la blackList) o si las direcciones son válidas devuelvo ''
        return emailsNoValidosEncontrados;
    }

    /*****************************************************************
    * Proposito: Retorna una owa u otra dependiendo de:
    * Si es una consulta cops, debe llevar la owa Consulta Caixabank SAC.
    * Si es una consulta sac, debe llevar la owa Servicio Atención Cliente M2P o CaixaBank SAC dependiendo de si tiene el check SAC_M2P__c
    * Si es una reclamación, debe llevar la owa Servicio Atención Cliente M2P o CaixaBank SAC dependiendo de si tiene el check SAC_M2P__c
    * Si es una pretensión, debe llevar la owa Servicio Atención Cliente M2P o CaixaBank SAC dependiendo de si la reclamación padre tiene el check SAC_M2P__c
    * Si es una interacción, debe llevar la owa Servicio Atención Cliente M2P o CaixaBank SAC dependiendo de si la reclamación padre tiene el check SAC_M2P__c
    * Si es una acción, debe llevar la owa Servicio Atención Cliente M2P o CaixaBank SAC dependiendo de si la reclamación padre tiene el check SAC_M2P__c
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US777526         CS             22/05/2024   Creación
    *****************************************************************/
    public static OrgWideEmailAddress asignarOWA(Case caso, SAC_Interaccion__c interaccion, SAC_Accion__c accion) {
        OrgWideEmailAddress orgwideaddress = new OrgWideEmailAddress();

        //Si no esta en blanco el caso, significa que es un email de caso y hay que buscar la OWA
        if (String.isNotBlank(caso.Id)) {
            //OWA de consulta COPS
            if (caso.RecordTypeId == RECTYPECONSULTA) {
                orgwideaddress = [SELECT Id, Address FROM OrgWideEmailAddress WHERE displayname = 'Consulta Caixabank SAC' LIMIT 1];
            }
            //OWA de consulta SAC dependiendo de si el check SAC_M2P__c está activado
            else if (caso.RecordTypeId == RECTYPECONSULTASAC) {
                if (caso.SAC_M2P__c) {
                    orgwideaddress = [SELECT Id, Address FROM OrgWideEmailAddress WHERE displayname = 'Servicio Atención Cliente M2P' LIMIT 1];
                } else {
                    orgwideaddress = [SELECT Id, Address FROM OrgWideEmailAddress WHERE displayname = 'CaixaBank SAC' LIMIT 1];
                }
            }
            //OWA de reclamación dependiendo de si el check SAC_M2P__c está activado
            else if (caso.RecordTypeId == RECTYPERECLAMACION) {
                if (caso.SAC_M2P__c) {
                    orgwideaddress = [SELECT Id, Address FROM OrgWideEmailAddress WHERE displayname = 'Servicio Atención Cliente M2P' LIMIT 1];
                } else {
                    orgwideaddress = [SELECT Id, Address FROM OrgWideEmailAddress WHERE displayname = 'CaixaBank SAC' LIMIT 1];
                }
            }
            //OWA de pretensión dependiendo de si el check SAC_M2P__c de la reclamación padre está activado
            else if (caso.RecordTypeId == RECTYPEPRETENSION) {
                if (caso.SAC_Reclamacion__r.SAC_M2P__c) {
                    orgwideaddress = [SELECT Id, Address FROM OrgWideEmailAddress WHERE displayname = 'Servicio Atención Cliente M2P' LIMIT 1];
                } else {
                    orgwideaddress = [SELECT Id, Address FROM OrgWideEmailAddress WHERE displayname = 'CaixaBank SAC' LIMIT 1];
                }
            }
        }
        //Si no esta en blanco la interacción, significa que es un email de interacción y hay que buscar la OWA
        else if (String.isNotBlank(interaccion.Id)) {
            //OWA de interacción dependiendo de si el check SAC_M2P__c de la reclamación padre está activado
            if (String.isNotBlank(interaccion.SAC_Reclamacion__c) && interaccion.SAC_Reclamacion__r.SAC_M2P__c) {
                orgwideaddress = [SELECT Id, Address FROM OrgWideEmailAddress WHERE displayname = 'Servicio Atención Cliente M2P' LIMIT 1];
            } else {
                orgwideaddress = [SELECT Id, Address FROM OrgWideEmailAddress WHERE displayname = 'CaixaBank SAC' LIMIT 1];
            }
        }
        //Si no esta en blanco la acción, significa que es un email de acción y hay que buscar la OWA
        else if (String.isNotBlank(accion.Id)) {
            //OWA de acción dependiendo de si el check SAC_M2P__c de la reclamación padre está activado
            if (String.isNotBlank(accion.SAC_Reclamacion__c) && accion.SAC_Reclamacion__r.SAC_M2P__c) {
                orgwideaddress = [SELECT Id, Address FROM OrgWideEmailAddress WHERE displayname = 'Servicio Atención Cliente M2P' LIMIT 1];
            } else {
                orgwideaddress = [SELECT Id, Address FROM OrgWideEmailAddress WHERE displayname = 'CaixaBank SAC' LIMIT 1];
            }
        }

        return orgwideaddress;
    }

    @AuraEnabled
    public static void validarFichero(id idFichero){
        try {
            ContentVersion fichero = [SELECT Id, Title, SAC_ValidadoCV__c, FirstPublishLocationId, SAC_StringRedaccion_fileupload__c FROM ContentVersion WHERE ContentDocumentId = :idFichero];
            Case caso = [SELECT caseNumber FROM Case WHERE id = :fichero.FirstPublishLocationId];
            fichero.Title = caso.caseNumber + ' ' + fichero.Title;
            fichero.SAC_ValidadoCV__c = true;
            fichero.SAC_StringRedaccion_fileupload__c = 'ResolucionRedaccion';
            SAC_DatabaseDML.updateDML(fichero, true);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void linkFileToConsulta(String consultaId, List<String> fileIds){

        List<ContentDocumentLink> newCdL = new List<ContentDocumentLink>();

        if(!fileIds.isEmpty()){
            for(String fileId : fileIds){
                ContentDocumentLink newLink = new ContentDocumentLink(
                    ContentDocumentId = fileId,
                    LinkedEntityId = consultaId,
                    ShareType = 'V' 
                );

                newCdL.add(newLink);
            }
        }

        if(!newCdL.isEmpty()){
            SAC_DatabaseDML.insertListDML(newCdL, true);
        }
    }

    @AuraEnabled
    public static void checkAdjuntoConsulta(String consultaId, String fileId){

        List<ContentDocumentLink> cdL = [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId =:consultaId AND ContentDocument.FileType != 'SNOTE' AND ContentDocumentId = :fileId LIMIT 1];

        if(cdL.isEmpty()){
            List<String> listId = new List<String>();
            listId.add(fileId);
            linkFileToConsulta(consultaId, listId);
        }
    }

    @AuraEnabled
    public static void deleteFileConsulta(String consultaId, String fileId){

        List<ContentDocumentLink> cdL = [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId =:consultaId AND ContentDocument.FileType != 'SNOTE' AND ContentDocumentId = :fileId LIMIT 1];

        if(!cdL.isEmpty()){
            SAC_DatabaseDML.deleteListDML(cdL, true);
        }
    }
}