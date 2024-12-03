/*****************************************************************
 * Name: SAC_AcuseRecibo_Email
 * Copyright © 2021  CaixaBank
 * ***************************************************************
 * Proposito: Clase que contiene los métodos para recuperar y enviar las plantilla de acuse de recibo
 *              
 * ***************************************************************
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0                             Daniel Benito   06/04/22      Creación
*****************************************************************/

public with sharing class SAC_AcuseRecibo_Email {

    private static Set<String> objetos = new Set<String>{'SAC_MaestroTemas__c','Case'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    final static Id RECORDTYPEBLACKLIST = mapRTsObjects.get('SAC_MaestroTemas__c').get('SAC_BlackListEmails').getRecordTypeId();
    final static Id RECORDTYPERECLAMACION = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();

    
    /*****************************************************************
    * Proposito: Clase wrapper para recoger los valores de las plantillas
    * ***************************************************************
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0                           Daniel Benito   06/04/22      Creación
    *****************************************************************/
    public class TemplateWrapper{

        public String idTemplate{get; set;}
        public String nameTemplate{get; set;}
        public String subjectTemplate{get; set;}
        public String htmlValueTemplate{get; set;}
        public Id caseId{get; set;}
        public String caseNumber{get; set;}
        public String suppliedEmail{get; set;}
        
        public TemplateWrapper(String idTemplate, String nameTemplate, String subjectTemplate, String htmlValueTemplate, Id caseId, String caseNumber, String suppliedEmail){
            this.idTemplate = idTemplate;
            this.nameTemplate = nameTemplate;
            this.subjectTemplate = subjectTemplate;
            this.htmlValueTemplate = htmlValueTemplate;
            this.caseId = caseId;            
            this.caseNumber = caseNumber;
            this.suppliedEmail = suppliedEmail;
        }
    }

    /*****************************************************************
    * Proposito: Método para recuperar la plantilla de acuse de recibo 
    * ***************************************************************
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR                DATE         Description
    * 1.0                             Daniel Benito         06/04/22     Creación
    * 1.1            US688660         Jose Carlos Blanco    29/09/23     Modificación idioma plantillas
    * 1.2            US994116         Raúl Santos           12/09/24     Modificación: Añadir las plantillas de valenciano, euskera y gallego
    *****************************************************************/

    public static List<templateWrapper> getPlantillaAcuseRecibo(List<Case> newCases, Map<Id, Case> mapaDatosCasosActualizar){

        List<templateWrapper> templateList = new List<templateWrapper>();
        List<String> origins = new List<String>();
        Map<String, Case> mapaOrigenCaso = new Map<String, Case>();

        if(!Schema.sObjectType.SAC_PlantillaRedaccion__c.isAccessible() || !Schema.sObjectType.EmailTemplate.isAccessible()){ throw new AuraHandledException( 'Fallo al acutalizar.' ); }
        String whoId = UserInfo.getUserId();

        for(Case caso : newCases){

            //caso.CC_AcuseRecibo__c = '2';
             
            mapaOrigenCaso.put(caso.Origin, caso);
            
            if(mapaDatosCasosActualizar.containsKey(caso.Id)){
                mapaDatosCasosActualizar.get(caso.Id).CC_AcuseRecibo__c = '2';
            }
            else{
                Case casoCopia = new Case(Id = caso.Id, CC_AcuseRecibo__c = '2');
                mapaDatosCasosActualizar.put(caso.Id, casoCopia);
            }

            if(!origins.contains(caso.Origin)){

                origins.add(caso.Origin); 
            }
        }

        Id idPlantillaEmail = null;
        Id idPlantillaFormulario = null;
        Id idPlantillaCartaPostal = null;
        Id idPlantillaManual = null;
        Id idPlantillaFormularioOficina = null;

        List<SAC_PlantillaRedaccion__c> maestroPlantillas = new List<SAC_PlantillaRedaccion__c>();
        maestroPlantillas = [SELECT Id, SAC_PlantillaCatalanId__c, SAC_PlantillaCastellanoId__c, SAC_PlantillaInglesId__c, SAC_PlantillaEuskeraId__c, SAC_PlantillaValencianoId__c, SAC_PlantillaGallegoId__c, SAC_Origen__c FROM SAC_PlantillaRedaccion__c WHERE SAC_TipoPlantilla__c =: 'SAC_AcuseDeRecibo' AND SAC_Origen__c IN: origins];
    
        if(!maestroPlantillas.isEmpty()){
            for(SAC_PlantillaRedaccion__c maestroPlantilla : maestroPlantillas){

                if(maestroPlantilla.SAC_Origen__c == 'Email'){
                    //Añadida funcionalidad idioma
                    for(Case caso : newCases){
                        if(caso.CC_Idioma__c == 'es'){
                            idPlantillaEmail = maestroPlantilla.SAC_PlantillaCastellanoId__c;
                        } else if(caso.CC_Idioma__c == 'ca'){
                            idPlantillaEmail = maestroPlantilla.SAC_PlantillaCatalanId__c;
                        } else if(caso.CC_Idioma__c == 'en'){
                            idPlantillaEmail = maestroPlantilla.SAC_PlantillaInglesId__c;
                        } else if(caso.CC_Idioma__c == 'eu'){
                            idPlantillaEmail = maestroPlantilla.SAC_PlantillaEuskeraId__c;
                        } else if(caso.CC_Idioma__c == 'va'){
                            idPlantillaEmail = maestroPlantilla.SAC_PlantillaValencianoId__c;
                        } else if(caso.CC_Idioma__c == 'ga'){
                            idPlantillaEmail = maestroPlantilla.SAC_PlantillaGallegoId__c;
                        } else {
                            idPlantillaEmail = maestroPlantilla.SAC_PlantillaCastellanoId__c;
                        }   
                    }    
                }else if(maestroPlantilla.SAC_Origen__c == 'SAC_Formulario'){
                    //Añadida funcionalidad idioma
                    for(Case caso : newCases){
                        if(caso.CC_Idioma__c == 'es'){
                            idPlantillaFormulario = maestroPlantilla.SAC_PlantillaCastellanoId__c;
                        } else if(caso.CC_Idioma__c == 'ca'){
                            idPlantillaFormulario = maestroPlantilla.SAC_PlantillaCatalanId__c;
                        } else if(caso.CC_Idioma__c == 'en'){
                            idPlantillaFormulario = maestroPlantilla.SAC_PlantillaInglesId__c;
                        } else if(caso.CC_Idioma__c == 'eu'){
                            idPlantillaFormulario = maestroPlantilla.SAC_PlantillaEuskeraId__c;
                        } else if(caso.CC_Idioma__c == 'va'){
                            idPlantillaFormulario = maestroPlantilla.SAC_PlantillaValencianoId__c;
                        } else if(caso.CC_Idioma__c == 'ga'){
                            idPlantillaFormulario = maestroPlantilla.SAC_PlantillaGallegoId__c;
                        } else {
                            idPlantillaFormulario = maestroPlantilla.SAC_PlantillaCastellanoId__c;
                        }   
                    }
    
                }else if(maestroPlantilla.SAC_Origen__c == 'SAC_CartaPostal'){
                    //Añadida funcionalidad idioma
                    for(Case caso : newCases){
                        if(caso.CC_Idioma__c == 'es'){
                            idPlantillaCartaPostal = maestroPlantilla.SAC_PlantillaCastellanoId__c;
                        } else if(caso.CC_Idioma__c == 'ca'){
                            idPlantillaCartaPostal = maestroPlantilla.SAC_PlantillaCatalanId__c;
                        } else if(caso.CC_Idioma__c == 'en'){
                            idPlantillaCartaPostal = maestroPlantilla.SAC_PlantillaInglesId__c;
                        } else if(caso.CC_Idioma__c == 'eu'){
                            idPlantillaCartaPostal = maestroPlantilla.SAC_PlantillaEuskeraId__c;
                        } else if(caso.CC_Idioma__c == 'va'){
                            idPlantillaCartaPostal = maestroPlantilla.SAC_PlantillaValencianoId__c;
                        } else if(caso.CC_Idioma__c == 'ga'){
                            idPlantillaCartaPostal = maestroPlantilla.SAC_PlantillaGallegoId__c;
                        } else {
                            idPlantillaCartaPostal = maestroPlantilla.SAC_PlantillaCastellanoId__c;
                        }   
                    }
                
                }else if(maestroPlantilla.SAC_Origen__c == 'SAC_Manual'){
                    //Añadida funcionalidad idioma
                    for(Case caso : newCases){
                        if(caso.CC_Idioma__c == 'es'){
                            idPlantillaManual = maestroPlantilla.SAC_PlantillaCastellanoId__c;
                        } else if(caso.CC_Idioma__c == 'ca'){
                            idPlantillaManual = maestroPlantilla.SAC_PlantillaCatalanId__c;
                        } else if(caso.CC_Idioma__c == 'en'){
                            idPlantillaManual = maestroPlantilla.SAC_PlantillaInglesId__c;
                        } else if(caso.CC_Idioma__c == 'eu'){
                            idPlantillaManual = maestroPlantilla.SAC_PlantillaEuskeraId__c;
                        } else if(caso.CC_Idioma__c == 'va'){
                            idPlantillaManual = maestroPlantilla.SAC_PlantillaValencianoId__c;
                        } else if(caso.CC_Idioma__c == 'ga'){
                            idPlantillaManual = maestroPlantilla.SAC_PlantillaGallegoId__c;
                        } else {
                            idPlantillaManual = maestroPlantilla.SAC_PlantillaCastellanoId__c;
                        }   
                    }
                
                }else if(maestroPlantilla.SAC_Origen__c == 'SAC_FormularioOficina'){
                    //Añadida funcionalidad idioma
                    for(Case caso : newCases){
                        if(caso.CC_Idioma__c == 'es'){
                            idPlantillaFormularioOficina = maestroPlantilla.SAC_PlantillaCastellanoId__c;
                        } else if(caso.CC_Idioma__c == 'ca'){
                            idPlantillaFormularioOficina = maestroPlantilla.SAC_PlantillaCatalanId__c;
                        } else if(caso.CC_Idioma__c == 'en'){
                            idPlantillaFormularioOficina = maestroPlantilla.SAC_PlantillaInglesId__c;
                        } else if(caso.CC_Idioma__c == 'eu'){
                            idPlantillaFormularioOficina = maestroPlantilla.SAC_PlantillaEuskeraId__c;
                        } else if(caso.CC_Idioma__c == 'va'){
                            idPlantillaFormularioOficina = maestroPlantilla.SAC_PlantillaValencianoId__c;
                        } else if(caso.CC_Idioma__c == 'ga'){
                            idPlantillaFormularioOficina = maestroPlantilla.SAC_PlantillaGallegoId__c;
                        } else {
                            idPlantillaFormularioOficina = maestroPlantilla.SAC_PlantillaCastellanoId__c;
                        }   
                    }
                }
            }
        }
        
        if(idPlantillaEmail != null){
            
            EmailTemplate templateEmail = new EmailTemplate();
            templateEmail = [SELECT Id, Name, Subject, HtmlValue FROM EmailTemplate WHERE Id =: idPlantillaEmail];

            for(Case caso : newCases){

                if(caso.Origin == 'Email'){
                    Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(idPlantillaEmail, whoId, caso.id); 
                    if(String.isNotBlank(caso.SuppliedEmail)){
                        TemplateWrapper tempWrapper = new TemplateWrapper(templateEmail.Id, templateEmail.Name, renderStored.getSubject(), renderStored.getHtmlBody(), caso.Id, caso.CaseNumber, caso.SuppliedEmail);
                        templateList.add(tempWrapper);
                    }
                    else{
                        TemplateWrapper tempWrapper = new TemplateWrapper(templateEmail.Id, templateEmail.Name, renderStored.getSubject(), renderStored.getHtmlBody(), caso.Id, caso.CaseNumber, caso.OS_Email__c);
                        templateList.add(tempWrapper);
                    }
                } 
            }
        }

        if(idPlantillaFormulario != null){
            EmailTemplate templateFormulario = new EmailTemplate(); 
            templateFormulario = [SELECT Id, Name, Subject, HtmlValue FROM EmailTemplate WHERE Id =: idPlantillaFormulario];

            for(Case caso : newCases){

                if(caso.Origin == 'SAC_Formulario'){
                    Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(idPlantillaFormulario, whoId, caso.id);        
                    if(String.isNotBlank(caso.SuppliedEmail)){
                        TemplateWrapper tempWrapper = new TemplateWrapper(templateFormulario.Id, templateFormulario.Name, renderStored.getSubject(), renderStored.getHtmlBody(), caso.Id, caso.CaseNumber, caso.SuppliedEmail);
                        templateList.add(tempWrapper);
                    }
                    else{
                        TemplateWrapper tempWrapper = new TemplateWrapper(templateFormulario.Id, templateFormulario.Name, renderStored.getSubject(), renderStored.getHtmlBody(), caso.Id, caso.CaseNumber, caso.OS_Email__c);
                        templateList.add(tempWrapper);
                    }
                } 
            }
        }

        if(idPlantillaCartaPostal != null){
            
            EmailTemplate templateCartaPostal = new EmailTemplate();
            templateCartaPostal = [SELECT Id, Name, Subject, HtmlValue FROM EmailTemplate WHERE Id =: idPlantillaCartaPostal];

            for(Case caso : newCases){

                if(caso.Origin == 'SAC_CartaPostal'){

                    Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(idPlantillaCartaPostal, whoId, caso.id);              
                    
                    if(String.isNotBlank(caso.SuppliedEmail)){
                        TemplateWrapper tempWrapper = new TemplateWrapper(templateCartaPostal.Id, templateCartaPostal.Name, renderStored.getSubject(), renderStored.getHtmlBody(), caso.Id, caso.CaseNumber, caso.SuppliedEmail);
                        templateList.add(tempWrapper);
                    }
                    else{
                        TemplateWrapper tempWrapper = new TemplateWrapper(templateCartaPostal.Id, templateCartaPostal.Name, renderStored.getSubject(), renderStored.getHtmlBody(), caso.Id, caso.CaseNumber, caso.OS_Email__c);
                        templateList.add(tempWrapper);
                    }   
                } 
            }
        }

        if(idPlantillaManual != null){

            EmailTemplate templateManual = new EmailTemplate();
            templateManual = [SELECT Id, Name, Subject, HtmlValue FROM EmailTemplate WHERE Id =: idPlantillaManual];

            for(Case caso : newCases){

                if(caso.Origin == 'SAC_Manual'){
                    
                    Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(idPlantillaManual, whoId, caso.id);              

                    if(String.isNotBlank(caso.SuppliedEmail)){
                        TemplateWrapper tempWrapper = new TemplateWrapper(templateManual.Id, templateManual.Name, renderStored.getSubject(), renderStored.getHtmlBody(), caso.Id, caso.CaseNumber, caso.SuppliedEmail);
                        templateList.add(tempWrapper);
                    }
                    else{
                        TemplateWrapper tempWrapper = new TemplateWrapper(templateManual.Id, templateManual.Name, renderStored.getSubject(), renderStored.getHtmlBody(), caso.Id, caso.CaseNumber, caso.OS_Email__c);
                        templateList.add(tempWrapper);
                    }
                } 
            }
        }

        if(idPlantillaFormularioOficina != null){
            
            EmailTemplate templateFormularioOficina = new EmailTemplate();
            templateFormularioOficina = [SELECT Id, Name, Subject, HtmlValue FROM EmailTemplate WHERE Id =: idPlantillaFormularioOficina];

            for(Case caso : newCases){

                if(caso.Origin == 'SAC_FormularioOficina'){

                    Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(idPlantillaFormularioOficina, whoId, caso.id);            

                    if(String.isNotBlank(caso.SuppliedEmail)){
                        TemplateWrapper tempWrapper = new TemplateWrapper(templateFormularioOficina.Id, templateFormularioOficina.Name, renderStored.getSubject(), renderStored.getHtmlBody(), caso.Id, caso.CaseNumber, caso.SuppliedEmail);
                        templateList.add(tempWrapper);
                    }
                    else{
                        TemplateWrapper tempWrapper = new TemplateWrapper(templateFormularioOficina.Id, templateFormularioOficina.Name, renderStored.getSubject(), renderStored.getHtmlBody(), caso.Id, caso.CaseNumber, caso.OS_Email__c);
                        templateList.add(tempWrapper);
                    }
                } 
            }
        }
        return templateList;
    }

    /*****************************************************************
    * Proposito: Método encargado de enviar el email de acuse de recibo
    * ***************************************************************
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0                           Daniel Benito   06/04/22      Creación
    * 1.1             US723742       Raúl Santos    05/03/24      Modificación: añadir lógica envio emails blackList
    * 1.2             US777526          CS          24/05/24      Modificación: añadido no reply de M2P
    * 1.3             US994116       Raúl Santos    12/09/24      Modificación: Si la dirección de envío del acuse esta en la lista negra, marcar la reclamación como 'Pte envío acuse de recibo'
    *****************************************************************/

    public static void envioAcuseRecibo(List<Case> newCases, Map<Id, Case> mapaDatosCasosActualizar){
        //Recuperar las owas no reply y almacenarlas en mapa
        Map<String, String> mapaOwas = new Map<String, String>();
        List<OrgWideEmailAddress> listaOwas = [SELECT Id,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'SAC Noreply' OR DisplayName = 'M2P Noreply'];
        for (OrgWideEmailAddress owa : listaOwas) {
            mapaOwas.put(owa.DisplayName, owa.Id);
        }
        //Crear mapa de los casos que entran.
        Map<Id, Case> mapaCasos = new Map<Id, Case>();
        for (Case caso : newCases) {
            mapaCasos.put(caso.Id, caso);
        }

        List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
        List<TemplateWrapper> emailTemplates = getPlantillaAcuseRecibo(newCases, mapaDatosCasosActualizar); 

        List<String> buzonesSalidaValidos = new List<String>();
        
        for (Buzon_SAC__mdt buzonPorDefecto : [SELECT SAC_DireccionCorreo__c FROM Buzon_SAC__mdt WHERE SAC_Activo__c = true]) {
            buzonesSalidaValidos.add(buzonPorDefecto.SAC_DireccionCorreo__c);
        }

        //Recupero los emails no validos de envio (emails en la blackList)
        List<SAC_MaestroTemas__c> listEmailsNoValidos = [SELECT Name FROM SAC_MaestroTemas__c WHERE RecordTypeId =: RECORDTYPEBLACKLIST AND SAC_Activo__c = true];
        Boolean errorEnvioAcuseRecibo = false;
        List<String> idCasosConAcuseNoEnviado = new List<String>();
        
        for(TemplateWrapper emailTemplate : emailTemplates){

            if(emailTemplate.SuppliedEmail != null){
                //Compruebo las direcciones de envio con las de la blackList
                List<String> listaDireccionesPara = new List<String>{ emailTemplate.SuppliedEmail };
                List<String> emailsValidos = SAC_Utils.comprobarEmailsBlackListAuto(listEmailsNoValidos, listaDireccionesPara);

                //Si existen direcciones válidas, continuo el proceso
                if(!emailsValidos.isEmpty() && (!buzonesSalidaValidos.contains(emailTemplate.SuppliedEmail))){
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();

                    if (mapaOwas.containsKey('SAC Noreply')) {
                        message.setOrgWideEmailAddressId(mapaOwas.get('SAC Noreply'));
                    }
                    if (mapaCasos.containsKey(emailTemplate.caseId) && mapaCasos.get(emailTemplate.caseId).SAC_M2P__c) {
                        message.setOrgWideEmailAddressId(mapaOwas.get('M2P Noreply'));
                    }
                    message.setToAddresses( emailsValidos );
                    if(Test.isRunningTest()) {
                        message.htmlBody = 'test';
                    }else{
                        message.htmlBody = emailTemplate.htmlValueTemplate;
                    }
                    message.setWhatId(emailTemplate.caseId);
                    //message.setTargetObjectId(acnt.PersonContactId);
                    message.optOutPolicy = 'FILTER';
                    //message.saveAsActivity = false;
                    message.subject = emailTemplate.subjectTemplate;
                    messageList.add(message);
                    //Savepoint sp = Database.setSavepoint();
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messageList);
                }else{
                    errorEnvioAcuseRecibo = true;
                    idCasosConAcuseNoEnviado.add(emailTemplate.caseId);
                }
            }else{
                errorEnvioAcuseRecibo = true;
                idCasosConAcuseNoEnviado.add(emailTemplate.caseId);
            }
        }  
        
        if(errorEnvioAcuseRecibo){
            List<Case> listaCasosSinAcuse = [SELECT Id, CC_AcuseRecibo__c FROM Case WHERE RecordTypeId = :RECORDTYPERECLAMACION AND Id IN :idCasosConAcuseNoEnviado];

            if(!listaCasosSinAcuse.isEmpty()){
                for(Case caso : listaCasosSinAcuse){
                    caso.CC_AcuseRecibo__c = '1';
                }

                SAC_DatabaseDML.updateListDML(listaCasosSinAcuse, true);
            }
        }
    }

    /*****************************************************************
    * Proposito: Método encargado de enviar el email de acuse de recibo manual
    * ***************************************************************
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0                                                         Creación
    * 1.1             US723742       Raúl Santos    05/03/24      Modificación: añadir lógica envio emails blackList
    * 1.2             US777526          CS          24/05/24      Modificación: añadido no reply de M2P
    *****************************************************************/
    public static void envioAcuseReciboManual(List<Case> newCases, Map<Id, Case> mapaDatosCasosActualizar){
        //Recuperar las owas no reply y almacenarlas en mapa
        Map<String, String> mapaOwas = new Map<String, String>();
        List<OrgWideEmailAddress> listaOwas = [SELECT Id,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'SAC Noreply' OR DisplayName = 'M2P Noreply'];
        for (OrgWideEmailAddress owa : listaOwas) {
            mapaOwas.put(owa.DisplayName, owa.Id);
        }
        //Crear mapa de los casos que entran.
        Map<Id, Case> mapaCasos = new Map<Id, Case>();
        for (Case caso : newCases) {
            mapaCasos.put(caso.Id, caso);
        }

        List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();

        List<TemplateWrapper> emailTemplates = getPlantillaAcuseRecibo(newCases, mapaDatosCasosActualizar);

        List<String> buzonesSalidaValidos = new List<String>();

        for (Buzon_SAC__mdt buzonPorDefecto : [SELECT SAC_DireccionCorreo__c FROM Buzon_SAC__mdt WHERE SAC_Activo__c = true]) {
            buzonesSalidaValidos.add(buzonPorDefecto.SAC_DireccionCorreo__c);
        }

        //Recupero los emails no validos de envio (emails en la blackList)
        List<SAC_MaestroTemas__c> listEmailsNoValidos = [SELECT Name FROM SAC_MaestroTemas__c WHERE RecordTypeId =: RECORDTYPEBLACKLIST AND SAC_Activo__c = true];
        
        for(TemplateWrapper emailTemplate : emailTemplates){
            //Compruebo la dirección de envio con las de la blackList
            String emailsNoValidosEncontrados = SAC_Utils.comprobarEmailsBlackList(listEmailsNoValidos, emailTemplate.SuppliedEmail, '', '');

            //Si la dirección de envio es válida (no está en la blackList), continuo el proceso
            if(emailsNoValidosEncontrados == ''){
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();

                if (mapaOwas.containsKey('SAC Noreply')) {
                    message.setOrgWideEmailAddressId(mapaOwas.get('SAC Noreply'));
                }
                if (mapaCasos.containsKey(emailTemplate.caseId) && mapaCasos.get(emailTemplate.caseId).SAC_M2P__c) {
                    message.setOrgWideEmailAddressId(mapaOwas.get('M2P Noreply'));
                }
                message.setToAddresses(new String[] { emailTemplate.SuppliedEmail });
                if(Test.isRunningTest()) {
                    message.htmlBody = 'test';
                }else{
                    message.htmlBody = emailTemplate.htmlValueTemplate;
                }
                message.setWhatId(emailTemplate.caseId);
                //message.setTargetObjectId(acnt.PersonContactId);
                message.optOutPolicy = 'FILTER';
                //message.saveAsActivity = false;
                message.subject = emailTemplate.subjectTemplate;
                messageList.add(message);
    
                if(String.isNotBlank(emailTemplate.suppliedEmail) && buzonesSalidaValidos.contains(emailTemplate.SuppliedEmail)){
                    throw new AuraHandledException('La dirección de destino ' + '"' + emailTemplate.SuppliedEmail + '"' + ' no es válida.');
                }
                else{
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messageList); 
    
                }
            }else{
                //Si la dirección de envio no es válida (está en la blackList), notifico al usuario
                throw new AuraHandledException('No está permitido el envío de emails a esta dirección: ' + emailsNoValidosEncontrados + ' de correo electrónico, por favor elimínela para proceder al envío');
            }
        }
    }
}