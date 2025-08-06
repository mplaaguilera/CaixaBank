public with sharing class SPV_LCMP_GestionEmails {

    private static Set<String> objetos = new Set<String>{'SAC_MaestroTemas__c','SAC_Interaccion__c','Case','SAC_Accion__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    final static Id RECORDTYPEBLACKLIST = mapRTsObjects.get('SAC_MaestroTemas__c').get('SPV_BlackListEmails').getRecordTypeId();
    final static Id RECORDTYPEESCALADO = mapRTsObjects.get('SAC_Interaccion__c').get('SPV_Escalado').getRecordTypeId();
    final static Id RECORDTYPECONSULTA = mapRTsObjects.get('SAC_Interaccion__c').get('SPV_Consulta').getRecordTypeId();
    final static Id RECORDTYPECONSULTA_TAREA = mapRTsObjects.get('SAC_Interaccion__c').get('SPV_ConsultaTarea').getRecordTypeId();
    final static Id RECTYPERECLAMACION = mapRTsObjects.get('Case').get('SPV_Reclamacion').getRecordTypeId();
    final static Id RECTYPEPRETENSION = mapRTsObjects.get('Case').get('SPV_Pretension').getRecordTypeId();
    final static Id RECTYPETAREAS = mapRTsObjects.get('SAC_Accion__c').get('SPV_Acciones').getRecordTypeId();
    final static Id RECTYPEMAESTROTAREAS = mapRTsObjects.get('SAC_Accion__c').get('SPV_MaestroDeTareas').getRecordTypeId();

    
    @AuraEnabled
    public static ContentVersion[] obtieneAdjuntos(String id){
        try {
            List<ContentVersion> cv = [SELECT Id, ContentDocumentId, Title FROM ContentVersion WHERE 
                                    FirstPublishLocationId =: id];
            
            ContentVersion[] resultado =  new List<ContentVersion>();
            for(ContentVersion record : cv){
                resultado.add(record);
            }

            return resultado;
        } catch (Exception e) {throw new AuraHandledException(e.getMessage());}
    }

    /*****************************************************************
     * Proposito: Recuperar los emails de la blackList y pasar al SPV_Utils.comprobarEmailsBlackList las direcciones de envio. Aqui comprobará si son válidas
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US945746     Raúl Santos     23/07/24         Creación
    *****************************************************************/
    @AuraEnabled
    public static String comprobarEmailsEnvio(String para, String copia, String copiaOculta) {

        //Recupero los emails no validos de envio (emails en la blackList)
        List<SAC_MaestroTemas__c> listEmailsNoValidos = [SELECT Name FROM SAC_MaestroTemas__c WHERE RecordTypeId =: RECORDTYPEBLACKLIST AND SAC_Activo__c = true];

        //Compruebo las direcciones de envio con las de la blackList
        String emailsNoValidosEncontrados = SPV_Utils.comprobarEmailsBlackList(listEmailsNoValidos, para, copia, copiaOculta);

        //Devuelvo las direcciones de envio no válidas encontradas (están en la blackList) o si las direcciones son válidas devuelvo ''
        return emailsNoValidosEncontrados;
    }

    /*****************************************************************
     * Proposito: Envio de emails con los parametros pasados
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US945746     Raúl Santos     23/07/24         Creación
    *****************************************************************/
    @AuraEnabled
    public static void enviarEmail(Id id, String para, String copia, String copiaOculta, String cuerpo, String asunto, String idAdjuntos, String tipoEnvio){

        Schema.SObjectType expectedCase = Schema.Case.getSObjectType();
        Schema.SObjectType expectedInteraccion = Schema.SAC_Interaccion__c.getSObjectType();
        Schema.SObjectType expectedAccion = Schema.SAC_Accion__c.getSObjectType();
        Schema.SObjectType tipoObjeto = id.getsobjecttype();

        List<ContentVersion> lstCV = new List<ContentVersion>();
        List<Id> lstIdCV = new List<Id>();
        Case caso = new Case();
        SAC_Interaccion__c interaccion = new SAC_Interaccion__c();
        SAC_Accion__c accion = new SAC_Accion__c();
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();

        if(tipoObjeto == expectedCase){
            caso = [SELECT Id, CaseNumber, CC_SuppliedID__c, RecordTypeId, Status, SAC_M2P__c, SAC_Reclamacion__r.SAC_M2P__c FROM Case WHERE RecordTypeId IN (:RECTYPERECLAMACION, :RECTYPEPRETENSION) AND Id =: id  LIMIT 1];
        }else if(tipoObjeto == expectedInteraccion){
            interaccion = [SELECT Id, SAC_IndexedThreadId__c, SAC_Oficina__c, SAC_Reclamacion__c, SAC_GrupoColaborador__c, SAC_DNI__c, SAC_Reclamante__c, SAC_Respuesta__c, RecordTypeId, SAC_GrupoColaborador__r.SAC_Externo__c, SAC_Reclamacion__r.SAC_M2P__c
                                FROM SAC_Interaccion__c WHERE RecordTypeId IN (:RECORDTYPECONSULTA, :RECORDTYPECONSULTA_TAREA, :RECORDTYPEESCALADO) AND Id =: id LIMIT 1];
                                 
        }else if(tipoObjeto == expectedAccion){
            accion = [SELECT Id, SAC_IndexedThreadId__c, SAC_Oficina__c, SAC_Reclamacion__c, SAC_EquipoResponsable__c, SAC_Reclamacion__r.SAC_M2P__c
                                FROM SAC_Accion__c WHERE RecordTypeId IN (:RECTYPETAREAS, :RECTYPEMAESTROTAREAS) AND Id =: id LIMIT 1];
        }
        
        if(String.isNotBlank(idAdjuntos) && idAdjuntos != '[]'){
            Set<Id> idsAdjuntos = (Set<Id>)JSON.deserialize(idAdjuntos, Set<Id>.class);
            Set<Id> idsAdjuntosFinal = new Set<Id>();
            for (Id adj : idsAdjuntos) {
                if (adj != null) {
                    idsAdjuntosFinal.add(adj);
                }
            }

            if(!idsAdjuntosFinal.isEmpty()){
                lstCV = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN: idsAdjuntosFinal];  
            }
       
            if(!lstCV.isEmpty()){
                for(ContentVersion contentVersion :lstCV){
                    lstIdCV.add(contentVersion.Id);
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
            if((interaccion.RecordTypeId == RECORDTYPECONSULTA || interaccion.RecordTypeId == RECORDTYPECONSULTA_TAREA) && interaccion.SAC_GrupoColaborador__r.SAC_Externo__c == true){
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

        //Raúl Santos - 08/04/2025 - Gestionar las imágenes que vienen inline.
		String cuerpoFinal = SPV_Utils.gestionarImagenesInlineRedactarMail(cuerpoConcatenado);

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
            List<EmailMessage> lstEmailMessage = [Select id from EmailMessage where parentId = :caso.Id and Subject = :asunto and Incoming = false order by createdDate desc];
            if(!lstEmailMessage.isEmpty()){
                EmailMessage emailRecuperado = lstEmailMessage.get(0);
                List<ContentDocumentLink> lstContentDocumentlink = [SELECT Id FROM ContentDocumentLink WHERE LINKEDENTITYID =: emailRecuperado.id];
                if(lstContentDocumentlink.isEmpty()) {
                    if(!lstCV.isEmpty()){
                        for(ContentVersion contentVersion : lstCV){
                            ContentDocumentLink contentLink = new ContentDocumentLink();
                            contentLink.LinkedEntityId = lstEmailMessage.get(0).Id;
                            contentLink.ContentDocumentId = contentVersion.ContentDocumentId;
                            lstContentDocument.add(contentLink);
                            
                        }
                    }

                    if(!lstContentDocument.isEmpty()){
                        SPV_DatabaseDML.insertListDML(lstContentDocument, true);
                    }
                }

                //Si el EmailMessage es de la redaccion final de una reclamación, actualizamos el campo SAC_EnvioRedaccion__c del EmailMessage
                if(caso.RecordTypeId == RECTYPERECLAMACION && caso.Status == 'SAC_003' && (tipoEnvio != '' || tipoEnvio != null)){
                    emailRecuperado.SAC_EnvioRedaccion__c = tipoEnvio;
                    emailRecuperado.SAC_IDAdjuntos__c = idAdjuntos;
                    SPV_DatabaseDML.updateDML(emailRecuperado, true);
                }
            }     
            
        }catch (Exception e){
            CBK_Log.error(e);
        }
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

    public static String arrastrarEmailsFormato(EmailMessage emailMessage){

        String textoFormateado = '<hr><br><span><strong>De: </strong>' + emailMessage.FromAddress + '</span><br>' +
                                 '<span><strong>Enviado el: </strong>' + formatearFecha(emailMessage.MessageDate) + '</span><br>' +
                                 '<span><strong>Para: </strong>' + emailMessage.ToAddress + '</span><br>' +
                                 (emailMessage.CCAddress != null && emailMessage.CCAddress != '' ? '<span><strong>CC: </strong>' + emailMessage.CCAddress + '</span><br>' : '') +
                                 '<span><strong>Asunto: </strong>' + emailMessage.Subject + '</span><br><br>' +
                                 '<span>' + emailMessage.HtmlBody + '</span><br>';
        

        return textoFormateado;
    }

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

    /*****************************************************************
    * Proposito: Retorna una owa u otra dependiendo de:
    * Si es una reclamación, debe llevar la owa CaixaBank SPV
    * Si es una pretensión, debe llevar la owa CaixaBank SPV
    * Si es una interacción, debe llevar la owa CaixaBank SPV
    * Si es una acción, debe llevar la owa CaixaBank SPV
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
            //OWA de reclamación
            if (caso.RecordTypeId == RECTYPERECLAMACION) {
                orgwideaddress = [SELECT Id, Address FROM OrgWideEmailAddress WHERE displayname = 'CaixaBank SPV' LIMIT 1];
            }
            //OWA de pretensión
            else if (caso.RecordTypeId == RECTYPEPRETENSION) {
                orgwideaddress = [SELECT Id, Address FROM OrgWideEmailAddress WHERE displayname = 'CaixaBank SPV' LIMIT 1];
            }
        }
        //Si no esta en blanco la interacción, significa que es un email de interacción y hay que buscar la OWA
        else if (String.isNotBlank(interaccion.Id)) {
            //OWA de interacción
            orgwideaddress = [SELECT Id, Address FROM OrgWideEmailAddress WHERE displayname = 'CaixaBank SPV' LIMIT 1];
        }
        //Si no esta en blanco la acción, significa que es un email de acción y hay que buscar la OWA
        else if (String.isNotBlank(accion.Id)) {
            //OWA de acción
            orgwideaddress = [SELECT Id, Address FROM OrgWideEmailAddress WHERE displayname = 'CaixaBank SPV' LIMIT 1];
        }

        return orgwideaddress;
    }
}