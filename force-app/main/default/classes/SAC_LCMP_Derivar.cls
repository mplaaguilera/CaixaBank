/*****************************************************************
 * Name: SAC_LCMP_Derivar
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Controller del componente SAC_Derivar
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US289217         Carlos Solis   04/11/21      Creación
 * 1.1            US545410         Raúl Santos    25/04/23      Modificación: añadir la funcionalidad necesaria para el buscador de oficinas
*****************************************************************/
public without sharing class SAC_LCMP_Derivar {

    private static Set<String> objetos = new Set<String>{'SAC_MaestroTemas__c', 'SAC_MaestroAccionesReclamacion__c', 'SAC_Accion__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    final static Id RECORDTYPEBLACKLIST = mapRTsObjects.get('SAC_MaestroTemas__c').get('SAC_BlackListEmails').getRecordTypeId();
    private static final Id RECTYPEMAESTROACCIONES = mapRTsObjects.get('SAC_MaestroAccionesReclamacion__c').get('SAC_MaestroAcciones').getRecordTypeId();
    private static final Id RECTYPEMAESTROTAREAS = mapRTsObjects.get('SAC_Accion__c').get('SAC_MaestroDeTareas').getRecordTypeId();


    /*****************************************************************
     * Proposito: Retorna el caso en el que se encuentra el componente
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US289217         Carlos Solis   04/11/21      Creación
    *****************************************************************/
    @AuraEnabled
    public static Case getCaso(String caseId){
        Case caso = new Case();
        if(!Schema.sObjectType.Case.isAccessible()){ throw new AuraHandledException( 'Fallo al recuperar el caso.' ); }
        caso = [SELECT Id, AccountId, Account.Name, Account.BillingCity, Account.BillingStreet, Account.BillingPostalCode, RecordType.DeveloperName, CaseNumber, CC_Canal_Respuesta__c, Status FROM Case WHERE (RecordType.DeveloperName = 'SAC_Reclamacion' OR RecordType.DeveloperName = 'SAC_Consulta' OR RecordType.DeveloperName = 'SAC_ConsultaSAC')
                    AND Id = :caseId LIMIT 1];

        return caso;
    }

    /*****************************************************************
     * Proposito: Buscar los grupos proveedores que permitan derivación y retornarlos 
     * en una lista para ser mostrados en un picklist
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US289217         Carlos Solis   04/11/21      Creación
    *****************************************************************/
    @AuraEnabled
    public static List<CC_Grupo_Colaborador__c> buscarGrupos(){
        List<CC_Grupo_Colaborador__c> listagrupos = new List<CC_Grupo_Colaborador__c>();
        if(!Schema.sObjectType.CC_Grupo_Colaborador__c.isAccessible()){ throw new AuraHandledException( 'Fallo al recuperar los grupos.' ); }
        listagrupos = [SELECT Id, Name, SAC_PlantillaReclamacion__c, SAC_PlantillaConsulta__c, SAC_PlantillaReclamante__c, SAC_DeveloperName__c FROM CC_Grupo_Colaborador__c WHERE RecordType.DeveloperName = 'SAC_GrupoProveedores'
                        AND SAC_PermiteDerivacion__c = true ORDER BY Name ASC];

        return listagrupos;
    }

    /*****************************************************************
     * Proposito: Buscar las oficinas de la org y retornarlos 
     * en una lista para ser mostrados en un buscador/selector
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US545410         Raúl Santos    24/04/23     Creación
    *****************************************************************/
    @AuraEnabled
    public static List<Account> buscarOficina(String idOficina){

        List<Account> listaOficinas = new List<Account>();
        if(!Schema.sObjectType.Account.isAccessible()){ throw new AuraHandledException( 'Fallo al recuperar las oficinas.' ); }
        listaOficinas = [SELECT Id, Name, CC_Email__c FROM Account WHERE Id =: idOficina];

        return listaOficinas;
    }
    


    /*****************************************************************
     * Proposito: Retorna las plantillas del grupo seleccionado en el picklist del componente
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US289217         Carlos Solis   04/11/21      Creación
    *****************************************************************/
    @AuraEnabled
    public static templateWrapper getPlantillas(String grupoSeleccionado, String caseRecordType, Id caseId){

        String whoId = UserInfo.getUserId();
        //Busco el grupo que se ha seleccionado para traerlo con los campos que nos interesan (plantillas)
        CC_Grupo_Colaborador__c grupo = new CC_Grupo_Colaborador__c();
        grupo = [SELECT Id, Name, SAC_Email__c, SAC_PlantillaReclamacionId__c, SAC_PlantillaConsultaId__c FROM CC_Grupo_Colaborador__c WHERE RecordType.DeveloperName = 'SAC_GrupoProveedores'
                AND Id = :grupoSeleccionado LIMIT 1];
                
        //Guardo las ids de los EmailTemplates en una variable cada una
        String plantillaReclamacion = grupo.SAC_PlantillaReclamacionId__c;
        String plantillaConsulta = grupo.SAC_PlantillaConsultaId__c;
        String emailPara = grupo.SAC_Email__c;

        List<EmailTemplate> listaTemplate = new List<EmailTemplate>();
        
        if (caseRecordType == 'SAC_Reclamacion') {
            if(!Schema.sObjectType.EmailTemplate.isAccessible()){ throw new AuraHandledException( 'Fallo al recuperar las plantillas.' ); }
            listaTemplate = [SELECT Id, Name, Subject, HtmlValue, RelatedEntityType FROM EmailTemplate WHERE Id = :plantillaReclamacion];
        } else if (caseRecordType == 'SAC_Consulta' || caseRecordType == 'SAC_ConsultaSAC') {
            if(!Schema.sObjectType.EmailTemplate.isAccessible()){ throw new AuraHandledException( 'Fallo al recuperar las plantillas.' ); }
            listaTemplate = [SELECT Id, Name, Subject, HtmlValue, RelatedEntityType FROM EmailTemplate WHERE Id = :plantillaConsulta];
        }

        Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(listatemplate[0].Id, whoId, caseId);              

        TemplateWrapper tempWrapper = new TemplateWrapper('','','','','',grupo.Name,grupo.Id);
        if (String.isNotBlank(emailPara)) {
            tempWrapper.paraTemplate = emailPara;
        }
        if (!listatemplate.isEmpty()) {
            tempWrapper.idTemplate = listatemplate[0].Id;
            tempWrapper.nameTemplate = listatemplate[0].Name;
            tempWrapper.subjectTemplate = renderStored.getSubject();
            tempWrapper.htmlValueTemplate = renderPlantilla(caseId, listatemplate[0].HtmlValue, listatemplate[0].RelatedEntityType);
        }

        return tempWrapper;
    }
    public static String renderPlantilla (Id caseId, String cuerpo, String relatedEntityType){
        List<String> body = new List<String>();
        body.add(cuerpo);
        String whoId = UserInfo.getUserId();
        String whatId = caseId;
        String stringFinal = '';

        List<Messaging.RenderEmailTemplateBodyResult> resList = Messaging.renderEmailTemplate(whoId, whatId, body);
        if(!resList.isEmpty()){
            stringFinal = resList[0].getMergedBody();
        }

        if(!Schema.sObjectType.EmailMessage.isAccessible()){ throw new AuraHandledException( 'Fallo al recuperar el Email Message.' ); }
        List <EmailMessage> msgOriginal = [SELECT HtmlBody, textBody  from EmailMessage where Id IN (SELECT SourceId FROM Case WHERE id =: caseId ) ORDER BY CreatedDate ];

        if (msgOriginal.isEmpty()){
            stringFinal = stringFinal.replace('---Original Message---', '');
        }
        else {
            String emailMSG;
            if (msgOriginal[0].HtmlBody != null)
            {
                emailMSG= msgOriginal[0].HtmlBody.replace('\r\n', ' ');
            }
            else {
                emailMSG= msgOriginal[0].textBody.replace('\r\n', ' ');
            }
            emailMSG = emailMSG.replace('\n', ' ');
            emailMSG = emailMSG.replace('\r', ' ');
            stringFinal = stringFinal.replace('---Original Message---', emailMSG);
        }

        return stringFinal;

    }

    /*****************************************************************
     * Proposito: Retorna la plantilla de reclamante del grupo seleccionado en el picklist del componente
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US289217         Carlos Solis   04/11/21      Creación
    *****************************************************************/
    @AuraEnabled
    public static templateWrapper getPlantillaReclamante(String grupoSeleccionado, String caseId){
        String whoId = UserInfo.getUserId();
        Case caso = [SELECT Id, AccountId, Account.PersonEmail, RecordType.DeveloperName, CC_Idioma__c,
                        Origin, OS_Email__c, SAC_DireccionPostal__c, CC_Canal_Respuesta__c, SuppliedEmail, Account.CC_Email__c, Account.RecordTypeId, SAC_DireccionPostalNotificacion__c
                        FROM Case 
                        WHERE (RecordType.DeveloperName = 'SAC_Reclamacion' OR RecordType.DeveloperName = 'SAC_Consulta' OR RecordType.DeveloperName = 'SAC_ConsultaSAC')
                            AND Id = :caseId LIMIT 1];

        //Guardo el email del cliente
        String emailPara = SAC_SeleccionDireccionRespuesta.getParaEmail(caso, caso.Account.RecordTypeId);

        //Busco el grupo que se ha seleccionado para traerlo con los campos que nos interesan (plantillas)
        CC_Grupo_Colaborador__c grupo = new CC_Grupo_Colaborador__c();
        grupo = [SELECT Id, Name, SAC_Email__c, SAC_PlantillaReclamante__c, SAC_PlantillaReclamante__r.SAC_PlantillaCastellanoId__c, SAC_PlantillaReclamante__r.SAC_PlantillaCatalanId__c,SAC_PlantillaReclamante__r.SAC_PlantillaInglesId__c
                FROM CC_Grupo_Colaborador__c WHERE RecordType.DeveloperName = 'SAC_GrupoProveedores'
                AND Id = :grupoSeleccionado LIMIT 1];
     
        //Guardo la id de el objeto plantillaRedaccion en una variable
        String plantillaRedReclamante = grupo.SAC_PlantillaReclamante__c;

        List<EmailTemplate> listatemplate = new List<EmailTemplate>();
        //Si ha encontrado una plantilla para el reclamante
        if (String.isNotBlank(plantillaRedReclamante)) {
            //compruebo idioma
            if (caso.CC_Idioma__c == 'es') {//Castellano
                listatemplate = [SELECT Id, Name, Subject, HtmlValue FROM EmailTemplate WHERE Id = :grupo.SAC_PlantillaReclamante__r.SAC_PlantillaCastellanoId__c];
            } else if (caso.CC_Idioma__c == 'ca') {//Catalán
                listatemplate = [SELECT Id, Name, Subject, HtmlValue FROM EmailTemplate WHERE Id = :grupo.SAC_PlantillaReclamante__r.SAC_PlantillaCatalanId__c];
            } else if (caso.CC_Idioma__c == 'en') {//Inglés
                listatemplate = [SELECT Id, Name, Subject, HtmlValue FROM EmailTemplate WHERE Id = :grupo.SAC_PlantillaReclamante__r.SAC_PlantillaInglesId__c];
            }
        }

        Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(listatemplate[0].Id, whoId, caseId);              

        TemplateWrapper tempWrapper = new TemplateWrapper('','','','','',grupo.Name,grupo.Id);
        if (String.isNotBlank(emailPara)) {
            tempWrapper.paraTemplate = emailPara;
        }
        if (!listatemplate.isEmpty()) {
            tempWrapper.idTemplate = listatemplate[0].Id;
            tempWrapper.nameTemplate = listatemplate[0].Name;
            tempWrapper.subjectTemplate = renderStored.getSubject();
            tempWrapper.htmlValueTemplate = renderStored.getHtmlBody();
        }

        return tempWrapper;
    }

    /*****************************************************************
     * Proposito: Lanza todos los métodos que se ejecutan cuando se finaliza la derivación de un caso
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US289217         Carlos Solis   08/11/21      Creación
    *****************************************************************/
    @AuraEnabled
    public static void finalizarDerivacion(String caseId, String para, String copia, String copiaOculta, String cuerpo, String asunto, String idsAdjuntos, String grupoSeleccionado){
        //Cerrar las acciones asociadas al caso
        cerrarAcciones(caseId);
        //Cambiar reclamación a estado derivada y sus pretensiones (si tiene) a estado baja
        cerrarCasos(caseId, grupoSeleccionado);
        //Mandar email para el grupo
        SAC_LCMP_GestionEmails.enviarEmail(caseId, para, copia, copiaOculta, cuerpo, asunto, idsAdjuntos, null);
    }

    /*****************************************************************
     * Proposito: Llama a SAC_LCMP_GestionEmails.enviarEmail para enviar el email que se le manda al cliente del caso
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US289217         Carlos Solis   08/11/21      Creación
    *****************************************************************/
    @AuraEnabled
    public static void enviarEmailCliente(String caseId, String paraCliente, String copiaCliente, String copiaClienteOculta, String cuerpoCliente, String asuntoCliente, String idsAdjuntos){
        //Mandar email para el cliente
        SAC_LCMP_GestionEmails.enviarEmail(caseId, paraCliente, copiaCliente, copiaClienteOculta, cuerpoCliente, asuntoCliente, idsAdjuntos, null);
    }

    /*****************************************************************
     * Proposito: Cambia el estado de las acciones asociadas al caso a 'SAC_FinalizadaIncompleta'
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US289217         Carlos Solis   08/11/21      Creación
    *****************************************************************/
    @AuraEnabled
    public static void cerrarAcciones(String caseId){
        List<SAC_Accion__c> listaAcciones = new List<SAC_Accion__c>();
        List<SAC_Accion__c> listaAccionesUpdatear = new List<SAC_Accion__c>();
        if(!Schema.sObjectType.SAC_Accion__c.isAccessible()){ throw new AuraHandledException( 'Fallo al recuperar las oficinas.' ); }
        listaAcciones = [SELECT Id, SAC_Reclamacion__c, SAC_Estado__c, SAC_SaltarValidacion__c FROM SAC_Accion__c WHERE (RecordType.DeveloperName = 'SAC_MaestroDeTareas'
                        OR RecordType.DeveloperName = 'SAC_OtrasTareas')
                        AND SAC_Reclamacion__c = :caseId];

        if (!listaAcciones.isEmpty()) {
            for (SAC_Accion__c accion : listaAcciones) {
                if (accion.SAC_Estado__c != 'SAC_Finalizada' && accion.SAC_Estado__c != 'SAC_FinalizadaIncompleta' && accion.SAC_Estado__c != 'SAC_Descartada') {
                    accion.SAC_Estado__c = 'SAC_FinalizadaIncompleta';
                    accion.SAC_SaltarValidacion__c = true;
                    listaAccionesUpdatear.add(accion);
                }
            }
            //Se upatea el cambio de estado con el check para saltarnos las validation rules
            if (!Schema.sObjectType.SAC_Accion__c.isUpdateable()) { throw new AuraHandledException( 'No tienes permisos para realziar esta accion.' ); }
            if (!listaAccionesUpdatear.isEmpty()) {
                Database.update(listaAccionesUpdatear);    

                //Se vuelven a poner en falso los checks de saltar validación y se vuelve a updatear
                for (SAC_Accion__c accion : listaAccionesUpdatear) {
                    accion.SAC_SaltarValidacion__c = false;
                }
                Database.update(listaAccionesUpdatear);
            }
        }
    }

    /*****************************************************************
     * Proposito: Cambia el estado de la reclamación a derivada y de sus pretensiones hijas (si las hay)
     * a estado baja
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US289217         Carlos Solis   08/11/21      Creación
     * 1.1            US994116         Raúl Santos    27/09/24      Modificación: Envio del acuse automático cuando la reclamación sale de 'Alta' y no se ha enviado previamente.
    *****************************************************************/
    @AuraEnabled
    public static void cerrarCasos(String caseId, String grupoSeleccionado){
        List<Case> listaCasos = new List<Case>();
        Case reclamacion = new Case();
        Boolean enviarAcuse = false;
        
        listaCasos = [SELECT Id, Status, RecordType.DeveloperName, CC_Canal_Respuesta__c, SAC_DireccionContacto__c, SAC_CodigoPostalContacto__c, SAC_PoblacionContacto__c, SAC_ProvinciaContacto__c, SAC_PaisContacto__c,SuppliedEmail, OS_Email__c, 
                            SAC_NombreContacto__c, CreatedDate, CaseNumber, SAC_M2P__c, CC_Idioma__c, CC_AcuseRecibo__c, Origin
                        FROM Case WHERE (RecordType.DeveloperName = 'SAC_Reclamacion' OR RecordType.DeveloperName = 'SAC_Pretension' OR RecordType.DeveloperName = 'SAC_Consulta' OR RecordType.DeveloperName = 'SAC_ConsultaSAC')
                        AND (Id = :caseId OR SAC_Reclamacion__c = :caseId)];

        if (!listaCasos.isEmpty()) {
            for (Case caso : listaCasos) {
                if (caso.RecordType.DeveloperName == 'SAC_Reclamacion') {
                    reclamacion = caso;

                    if(caso.CC_AcuseRecibo__c != '2' && caso.Status == 'SAC_001'){
                        if(caso.CC_Canal_Respuesta__c == 'SAC_CartaPostal' && (caso.SAC_DireccionContacto__c == null || caso.SAC_CodigoPostalContacto__c == null || caso.SAC_PoblacionContacto__c == null || caso.SAC_ProvinciaContacto__c == null || caso.SAC_PaisContacto__c == null)){
                            throw new AuraHandledException('Revise que están informados todos los campos de la dirección de contacto del reclamante para que se pueda crear la carta postal del acuse de recibo.');
                        }else if(caso.CC_Canal_Respuesta__c == 'Email' && (caso.SuppliedEmail == null && caso.OS_Email__c == null)){
                            throw new AuraHandledException('Revise que hay informado un correo asociado al reclamante para que se pueda realizar el envío del acuse de recibo.');
                        }else{
                            enviarAcuse = true;
                            caso.CC_AcuseRecibo__c = '2';
                        }
                    }
                    caso.Status = 'SAC_008';
                    caso.SAC_StatusAuxiliar__c = 'SAC_008';
                    caso.SAC_DerivadoA__c = grupoSeleccionado;
                    caso.SAC_MotivoReabrir__c = '';
                } else if (caso.RecordType.DeveloperName == 'SAC_Pretension') {
                    caso.Status = 'SAC_009';
                    caso.SAC_StatusAuxiliar__c = 'SAC_009';
                } else if (caso.RecordType.DeveloperName == 'SAC_Consulta' || caso.RecordType.DeveloperName == 'SAC_ConsultaSAC') {
                    caso.Status = 'SAC_008';
                    caso.SAC_StatusAuxiliar__c = 'SAC_008';
                    caso.SAC_DerivadoA__c = grupoSeleccionado;
                    caso.SAC_MotivoReabrir__c = '';
                }
            }
            if (!Schema.sObjectType.Case.isUpdateable()) { throw new AuraHandledException( 'No tienes permisos para realziar esta accion.' ); }
            Database.update(listaCasos);
        }

        //Si se debe enviar el acuse automático se llama al método que lo hace
        if(enviarAcuse){
            enviarAcuseReciboAuto(reclamacion);
        }
    }

    public static void enviarAcuseReciboAuto(Case caso){
        if(caso.CC_Canal_Respuesta__c == 'SAC_CartaPostal'){
            String pais = '';

            if(caso.SAC_PaisContacto__c.trim().toLowerCase().contains('españa')){
                pais = '011';
            }else{
                pais = '000';
            }

            SAC_LCMP_AcuseReciboCartaPostal.envioCartaPostal(caso, caso.SAC_DireccionContacto__c, caso.SAC_CodigoPostalContacto__c, caso.SAC_PoblacionContacto__c, caso.SAC_ProvinciaContacto__c, pais);

        }else if(caso.CC_Canal_Respuesta__c == 'Email'){
            List<Case> casos = new List<Case>();
            casos.add(caso);
            Map<Id, Case> mapa = new Map<Id, Case>();
            SAC_AcuseRecibo_Email.envioAcuseRecibo(casos, mapa);
        }else{
            Case casoAcusePte = new Case(Id = caso.Id, CC_AcuseRecibo__c = '1');
            SAC_DatabaseDML.updateDML(casoAcusePte, true);
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
    * Proposito: Convierte en content version la carta para la comunicación con el cliente mediante carta Postal
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0                             Carlos Gómez   15/01/2025       Creación
    *****************************************************************/
    @AuraEnabled
    public static String crearCartaPostalCV(String caseId) {
        Case caso = [SELECT Id, SAC_CasoEspecial__c, CC_Canal_Procedencia__c FROM Case WHERE Id =: caseId];
        string maestroTarea = '';
        SAC_DocumentoEnvio__c carta = [SELECT id FROM SAC_DocumentoEnvio__c WHERE  SAC_Caso__c =:caseId  AND SAC_Documento__c = null AND SAC_TipoDocumento__c = 'derivación' order by CreatedDate DESC  LIMIT 1]; 

        String vfHostname = DomainCreator.getVisualforceHostname(null);
        String urlVF = 'https://' + vfHostname + '/apex/SAC_CartaPDF?id=' + carta.Id;
        SAC_GeneracionCartas.adjuntarPDFaCaso2(urlVF, caseId, 'derivación');

        if(caso.SAC_CasoEspecial__c == 'SAC_Presidencia'){
            maestroTarea = 'SAC_ImprimirCartasAD';
        }else if(caso.CC_Canal_Procedencia__c == 'Castilla la Mancha' || caso.CC_Canal_Procedencia__c == 'Junta Andalucia'){
            maestroTarea = 'SAC_ImprimirCartasJACM';
        }else{
            maestroTarea = 'SAC_ImprimirCartasOrdinario';
        }
        //US1101520 crear tarea al subsanar por carta postal
        SAC_MaestroAccionesReclamacion__c maestroTareaAutomatica = [SELECT Id, Name FROM SAC_MaestroAccionesReclamacion__c WHERE RecordTypeId = :RECTYPEMAESTROACCIONES AND SAC_Activo__c = true AND SAC_DeveloperName__c = :maestroTarea LIMIT 1];  

        SAC_Accion__c tarea = new SAC_Accion__c();

        tarea.SAC_MaestroAccionesReclamacion__c = maestroTareaAutomatica.Id;
        tarea.RecordTypeId = RECTYPEMAESTROTAREAS;
        tarea.SAC_Reclamacion__c = caseId;
        
        try {
            if (!Schema.sObjectType.SAC_Accion__c.isCreateable()) { throw new AuraHandledException( 'No tienes permisos para realizar esta accion.' ); }
            SAC_DatabaseDML.insertDML(tarea, true);
        } catch (Exception e) {
            CBK_log.error(e);
        }

        // FALLA POR List has more than 1 row for assignment to SObject ya que recupera la carta del acuse de recibo y la del envio de subsanacion
        ContentVersion cv = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE FirstPublishLocationId =: caseId order by CreatedDate DESC LIMIT 1];
        ContentDocumentLink cdl = new ContentDocumentLink();

        cdl.ContentDocumentId = cv.ContentDocumentId;
        cdl.LinkedEntityId = tarea.Id;
        cdl.ShareType = 'I';

        SAC_DatabaseDML.insertDML(cdl, true);

        return tarea.Id;

    }

    /*****************************************************************
     * Proposito: Clase wrapper para recoger los valores de las plantillas
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US289217         Carlos Solis   04/11/21      Creación
    *****************************************************************/
    public class TemplateWrapper{

        @AuraEnabled public String idTemplate{get; set;}
        @AuraEnabled public String nameTemplate{get; set;}
        @AuraEnabled public String subjectTemplate{get; set;}
        @AuraEnabled public String htmlValueTemplate{get; set;}
        @AuraEnabled public String paraTemplate{get; set;}
        @AuraEnabled public String nombreGrupo{get; set;}
        @AuraEnabled public String idGrupo{get; set;}
        
        public TemplateWrapper(String idTemplate, String nameTemplate, String subjectTemplate, String htmlValueTemplate, String paraTemplate, String nombreGrupo, String idGrupo){
            this.idTemplate = idTemplate;
            this.nameTemplate = nameTemplate;
            this.subjectTemplate = subjectTemplate;
            this.htmlValueTemplate = htmlValueTemplate;
            this.paraTemplate = paraTemplate;
            this.nombreGrupo = nombreGrupo;
            this.idGrupo = idGrupo;
        }
    }
}