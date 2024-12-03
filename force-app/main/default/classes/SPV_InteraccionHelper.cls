public with sharing class SPV_InteraccionHelper {
    //Obtención record types
    private static Set<String> objetos = new Set<String>{'Case', 'SAC_Accion__c', 'SAC_Interaccion__c', 'SAC_MaestroAccionesReclamacion__c','CC_Grupo_Colaborador__c','SAC_MaestroTemas__c'}; //,'SAC_TMECaso__c'
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPERECLAMACION =  mapRTsObjects.get('Case').get('SPV_Reclamacion').getRecordTypeId();
    private static final Id RECTYPEPRETENSION =  mapRTsObjects.get('Case').get('SPV_Pretension').getRecordTypeId();
    private static final Id RECTYPEMAESTROTAREAS = mapRTsObjects.get('SAC_Accion__c').get('SPV_MaestroDeTareas').getRecordTypeId();
    private static final Id RECTYPEMAESTROACCIONESREC = mapRTsObjects.get('SAC_MaestroAccionesReclamacion__c').get('SPV_MaestroAcciones').getRecordTypeId();
    private static final Id RECTYPEESCALADO = mapRTsObjects.get('SAC_Interaccion__c').get('SPV_Escalado').getRecordTypeId();
    private static final Id RECTYPECONSULTA = mapRTsObjects.get('SAC_Interaccion__c').get('SPV_Consulta').getRecordTypeId();
    private static final Id RECTYPGRUPOTAREAS = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SPV_GrupoDeTareas').getRecordTypeId();
    private static final Id RECORDTYPEBLACKLIST = mapRTsObjects.get('SAC_MaestroTemas__c').get('SPV_BlackListEmails').getRecordTypeId();

    // private static final Id RECTYPETMECONSULTA = mapRTsObjects.get('SAC_TMECaso__c').get('SAC_Consulta').getRecordTypeId();

    /*****************************************************************
     * Proposito: Filtrar las interacciones entrantes para quedarnos únicamente con los de SPV
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0               ---         Sergio Martín  01/08/2024        Creación
     *****************************************************************/
    public static List<SAC_Interaccion__c> filtrarInteraccionesSPV(List<SAC_Interaccion__c> lstInteracciones) {

        List<SAC_Interaccion__c> interaccionesSPV = new List<SAC_Interaccion__c>();

        for (SAC_Interaccion__c interaccion : lstInteracciones) {
            if (interaccion.RecordTypeId == RECTYPEESCALADO || interaccion.RecordTypeId == RECTYPECONSULTA) {
                interaccionesSPV.add(interaccion);
            }
        }
        
        return interaccionesSPV;
    }

    
    /*********************************************************************************************
     * Proposito: Cuando un escalado pasa a resuelto, entonces la reclamación ya no estará pendiente de 
     *  resolución. En este método se establece el campo "Pendiente de resolución de Escalado" a false
     * de las reclamaciones cuyo escalado se haya resuelto
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE          Description
     * 1.0             US997688       Álex Polo    04/09/2024        Creación    
    *********************************************************************************************/
    public static void actualizarPendienteEscaladoReclamacion(List<SAC_Interaccion__c> listaEscaladosConsulta, Map<Id, SAC_Interaccion__c> mapOldObj, Map<Id, Case> mapaCasosActualizar){

        List<SAC_Interaccion__C> listaEscaladosNew = new List<SAC_Interaccion__c>();
        Set<Id> idsReclamaciones = new Set<Id>();
        List<Case> listaReclamaciones = new List<Case>();
        Map<Id, Case> mapaReclamaciones = new Map<Id, Case>();


        //Primero se hace una lista de escalados que hayan sido resueltos o que hayan vuelto a estar pendientes de ser enviados
        for(SAC_Interaccion__c interaccion : listaEscaladosConsulta){
            if(interaccion.RecordTypeId == RECTYPEESCALADO){
                if(mapOldObj.containsKey(interaccion.Id) && mapOldObj.get(interaccion.Id).SAC_Estado__c == 'SAC_PendienteRespuesta' && (interaccion.SAC_Estado__c == 'SAC_Resuelta' || interaccion.SAC_Estado__c == 'SPV_PendienteEnviar')){ //Si el estado anterior es pendiente,  y el nuevo es resuelta o pendiente de enviar, se ha resuelto
                    listaEscaladosNew.add(interaccion);
                }
            }
        }
    
        //Se obtienen los id de las reclamaciones cuyo escalado haya sido resuelto
        if(!listaEscaladosNew.isEmpty()){
            for(SAC_Interaccion__C interaccion : listaEscaladosNew){
                idsReclamaciones.add(interaccion.SAC_CasoEscalado__c);
            }
        }

        //Se obtienen las reclamaciones que correspondan a los escalados resueltos

        if(!idsReclamaciones.isEmpty()){
            listaReclamaciones = [SELECT Id, SPV_Pendiente_Escalado__c FROM Case WHERE Id IN :idsReclamaciones];

        }

        //A todas estas reclamaciones, se le pondrá el campo "Pendiente resolución escalado" a false, pues ya han sido resueltos
        if(!listaReclamaciones.isEmpty()){
            for(Case reclamacion : listaReclamaciones){
                if(mapaCasosActualizar.containsKey(reclamacion.Id)){
                    mapaCasosActualizar.get(reclamacion.Id).SPV_Pendiente_Escalado__c = false;
                }else{
                    reclamacion.SPV_Pendiente_Escalado__c = false;
                    mapaCasosActualizar.put(reclamacion.Id, reclamacion);
                }



            }

        }
    }


    /*********************************************************************************************
     * Proposito: CAl enviar un escalado, la reclamación afectada debe tener el campo
     * "Pendiente resolución de escalado" a true.
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE          Description
     * 1.0             US997688       Álex Polo    04/09/2024        Creación    
    *********************************************************************************************/
    public static void actualizarReclamacionAlEnviarEscalado(List<SAC_Interaccion__c> listaEscaladosConsulta, Map<Id, SAC_Interaccion__c> mapOldObj, Map<Id, Case> mapaCasosActualizar){

        List<SAC_Interaccion__C> listaEscaladosNew = new List<SAC_Interaccion__c>();
        Set<Id> idsReclamaciones = new Set<Id>();
        List<Case> listaReclamaciones = new List<Case>();
        Map<Id, Case> mapaReclamaciones = new Map<Id, Case>();

            //Primero se hace una lista de escalados que hayan sido enviados
            for(SAC_Interaccion__c interaccion : listaEscaladosConsulta){
                if(interaccion.RecordTypeId == RECTYPEESCALADO){
                    if(mapOldObj.containsKey(interaccion.Id) && mapOldObj.get(interaccion.Id).SAC_Estado__c != 'SAC_PendienteRespuesta' && interaccion.SAC_Estado__c == 'SAC_PendienteRespuesta'){ //Si el nuevo estado es pendiente de respuesta, se almacena el escalado
                        listaEscaladosNew.add(interaccion);
                    }
                }
            }


            //Se obtienen los id de las reclamaciones cuyo escalado haya sido resuelto
            if(!listaEscaladosNew.isEmpty()){
                for(SAC_Interaccion__C interaccion : listaEscaladosNew){
                    idsReclamaciones.add(interaccion.SAC_CasoEscalado__c);
                }
            }

            //Se obtienen las reclamaciones que correspondan a los escalados resueltos
            if(!idsReclamaciones.isEmpty()){
                listaReclamaciones = [SELECT Id, SPV_Pendiente_Escalado__c FROM Case WHERE Id IN :idsReclamaciones];

            }




            //A todas estas reclamaciones, se le pondrá el campo "Pendiente resolución escalado" a false, pues ya han sido resueltos
            if(!listaReclamaciones.isEmpty()){
                for(Case reclamacion : listaReclamaciones){
                    if(mapaCasosActualizar.containsKey(reclamacion.Id)){
                        mapaCasosActualizar.get(reclamacion.Id).SPV_Pendiente_Escalado__c = true;
                    }else{
                        reclamacion.SPV_Pendiente_Escalado__c = true;
                        mapaCasosActualizar.put(reclamacion.Id, reclamacion);
                    }
                }
            }


    }

    /*********************************************************************************************
     * Proposito: Método que cambia de estado la consulta cuando se informa el campo pregunta e informa la fecha de vencimiento y/o enviar email si es necesario
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE          Description
     * 1.0             US975885     Raúl Santos    17/07/2024         Creación    
    *********************************************************************************************/
    public static void informarPreguntaConsulta(List<SAC_Interaccion__c> listaConsultasSPV, Map<Id, SAC_Interaccion__c> mapOldObj){

        Set<Id> setIdsConsultas = new Set<Id>();
        List<SAC_Interaccion__c> consultasFechaVenciiento = new List<SAC_Interaccion__c>();
        List<SAC_Interaccion__c> consultasEnvioMail = new List<SAC_Interaccion__c>();
        Map<Id, date> mapFechaVencimiento = new Map<Id, date>();

        List<Group> cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SPV_PendienteAsignar' LIMIT 1];
        
        for(SAC_Interaccion__c consulta : listaConsultasSPV){ 
            if(consulta.SAC_Pregunta__c != mapOldObj.get(consulta.Id).SAC_Pregunta__c && String.isBlank(mapOldObj.get(consulta.Id).SAC_Pregunta__c)){ 
                consulta.SAC_Estado__c = 'SAC_PendienteRespuesta';

                if(consulta.SAC_GrupoColaborador__r.SAC_Externo__c == false && consulta.SAC_GrupoColaborador__r.SAC_DeveloperName__c != 'OFICINA'){
                    consulta.OwnerId = cola[0].Id;
                }

                setIdsConsultas.add(consulta.Id);
            }
        }

        if(!setIdsConsultas.isEmpty()){    
            SAC_Interaccion__c consulta = [SELECT Id, SAC_Fecha_Vencimiento__c, SAC_GrupoColaborador__r.SAC_PeriodoConsulta__c, SAC_Oficina__c, SAC_EmailOficina__c, SAC_EmailCC__c, SAC_EmailCCO__c, SAC_GrupoColaborador__r.SAC_Externo__c, SAC_GrupoColaborador__r.SAC_Email__c , SAC_GrupoColaborador__r.SAC_Email2__c , SAC_GrupoColaborador__r.SAC_Email3__c FROM SAC_Interaccion__c WHERE RecordTypeId = :RECTYPECONSULTA AND Id IN: setIdsConsultas LIMIT 1]; 
           
            if(consulta.SAC_GrupoColaborador__r.SAC_PeriodoConsulta__c != null && consulta.SAC_Fecha_Vencimiento__c == null){
                calculoFechaVencimientoConsulta(listaConsultasSPV, consulta);
            }

            if(consulta.SAC_GrupoColaborador__r.SAC_Externo__c != true){
                enviarEmailConsultaInternaAndOficina(listaConsultasSPV, consulta);
            }
        }
    }

    /**************************************************************************
     * Proposito: Calcular los dias de vencimiento teniendo en cuenta el calendario laboral de SPV dependiendo de periodo consulta configurado en el grupo asignado
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US975885      Raúl Santos    17/07/2024       Creación    
    **************************************************************************/ 
    public static void calculoFechaVencimientoConsulta(List<SAC_Interaccion__c> listaConsultasSPV, SAC_Interaccion__c consulta){

        BusinessHours bh = [SELECT id FROM BusinessHours WHERE name = 'SPV_Calendario' LIMIT 1];

        if(bh != null){

            Date fechaVencimiento = BusinessHours.add(bh.Id, datetime.now(), integer.valueof(consulta.SAC_GrupoColaborador__r.SAC_PeriodoConsulta__c*86400*1000)).date();
           
            for (SAC_Interaccion__c interaccion : listaConsultasSPV) {
                if (interaccion.Id == consulta.Id) {
                    interaccion.SAC_Fecha_Vencimiento__c = fechaVencimiento;
                    break;
                }
            }
        }
    }

    public static void enviarEmailConsultaInternaAndOficina(List<SAC_Interaccion__c> listaConsultasSPV,SAC_Interaccion__c consulta) {

        //Recuperación plantillas
        if(!Schema.sObjectType.EmailTemplate.isAccessible()){ throw new AuraHandledException( 'Fallo al recuperar las plantillas' ); }
        List<EmailTemplate> listaTemplates = [SELECT Id, Name, Subject, HtmlValue, RelatedEntityType, DeveloperName FROM EmailTemplate WHERE DeveloperName = 'SPV_ConsultaOficina' OR DeveloperName = 'SPV_ConsultaInterna'];

        //Recupero los emails no validos de envio (emails en la blackList)
        List<SAC_MaestroTemas__c> listEmailsNoValidos = [SELECT Name FROM SAC_MaestroTemas__c WHERE RecordTypeId =: RECORDTYPEBLACKLIST AND SAC_Activo__c = true];

        String whoId = UserInfo.getUserId();
        Boolean errorMessage = false;
        String emailsNoValidosEncontrados = '';

        if(String.isNotBlank(consulta.SAC_Oficina__c)){

            String para = '';
            String emailCC = '';
            String emailCCO = '';
            
            if (String.isNotBlank(consulta.SAC_EmailOficina__c)) {
                para = consulta.SAC_EmailOficina__c;    
            }
            if (String.isNotBlank(consulta.SAC_EmailCC__c)) {
                emailCC = consulta.SAC_EmailCC__c;    
            }
            if (String.isNotBlank(consulta.SAC_EmailCCO__c)) {
                emailCCO = consulta.SAC_EmailCCO__c;    
            }

            //Compruebo las direcciones de envio con las de la blackList
            emailsNoValidosEncontrados = SPV_Utils.comprobarEmailsBlackList(listEmailsNoValidos, para, emailCC, emailCCO);

            //Si las direcciones de envio son válidas (no está en la blackList), continuo el proceso
            if(emailsNoValidosEncontrados == ''){
                EmailTemplate plantillaOficina;
                //Recuperar la plantilla
                for(EmailTemplate em : listaTemplates){
                    if(em.DeveloperName == 'SPV_ConsultaOficina'){
                        plantillaOficina = em;
                    }
                }
                Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(plantillaOficina.Id, whoId, consulta.Id);                      
                TemplateWrapper plantilla = new TemplateWrapper(plantillaOficina.Id, plantillaOficina.Name, renderStored.getSubject(), renderStored.getHtmlBody(), '');

                // Metodo para recuperar los adjuntos y enviar el mail
                if(String.isNotBlank(para) && plantilla != null) {
                    consulta.SAC_Titulo__c = plantilla.subjectTemplate;
                    recuperarAdjuntos(consulta.Id, para, emailCC, emailCCO, plantilla);
                }
            }else{
                //Si las direcciones de envio no son válidas (están en la blackList), notifico al usuario
                // consulta.addError('No está permitido el envío de emails a la dirección: ' + emailsNoValidosEncontrados + ' de correo electrónico, por favor elimínela para proceder al envío');
                errorMessage = true;
            }

        }else{                 
            List<String> listaDireccionesPara = new List<String>();

            if (String.isNotBlank(consulta.SAC_GrupoColaborador__r.SAC_Email__c)) {
                listaDireccionesPara.add(consulta.SAC_GrupoColaborador__r.SAC_Email__c);   
            }
            if (String.isNotBlank(consulta.SAC_GrupoColaborador__r.SAC_Email2__c)) {
                listaDireccionesPara.add(consulta.SAC_GrupoColaborador__r.SAC_Email2__c);  
            }
            if (String.isNotBlank(consulta.SAC_GrupoColaborador__r.SAC_Email3__c)) {
                listaDireccionesPara.add(consulta.SAC_GrupoColaborador__r.SAC_Email3__c);  
            } 

            List<String> emailsValidos = SPV_Utils.comprobarEmailsBlackListAuto(listEmailsNoValidos, listaDireccionesPara);

            //Si las direcciones de envio son válidas (no está en la blackList), continuo el proceso
            if(!emailsValidos.isEmpty()){
                EmailTemplate plantillaInterna;
                //Recuperar la plantilla
                for(EmailTemplate em : listaTemplates){
                    if(em.DeveloperName == 'SPV_ConsultaInterna'){
                        plantillaInterna = em;
                    }
                }
                Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(plantillaInterna.Id, whoId, consulta.Id);                      
                TemplateWrapper plantilla = new TemplateWrapper(plantillaInterna.Id, plantillaInterna.Name, renderStored.getSubject(), renderStored.getHtmlBody(), '');

                // Metodo para recuperar los adjuntos y enviar el mail
                if(plantilla != null) {
                    String para = '';

                    for(String email : emailsValidos){
                        if(para == ''){
                            para = email;
                        }else{
                            para = para + ';' + email;
                        }
                    }

                    consulta.SAC_Titulo__c = plantilla.subjectTemplate;
                    recuperarAdjuntos(consulta.Id, para, '', '', plantilla);
                }
            }else{
                //Si las direcciones de envio no son válidas (están en la blackList), notifico al usuario
                String para = '';

                //Si no hay ninguna dirección válida, no se envía email, pero si la consulta en sf
                // for(String email : listaDireccionesPara){
                //     if(para == ''){
                //         para = email;
                //     }else{
                //         para = para + ';' + email;
                //     }
                // }
                // consulta.addError('No está permitido el envío de emails a la dirección: ' + para + ' de correo electrónico, por favor elimínela para proceder al envío');
            }
        }

        // Si se encontró un error, agregarlo al registro correspondiente en la lista del trigger
        if (errorMessage) {
            for (SAC_Interaccion__c interaccion : listaConsultasSPV) {
                if (interaccion.Id == consulta.Id) {
                    interaccion.addError('No está permitido el envío de emails a la dirección: ' + emailsNoValidosEncontrados + ' de correo electrónico, por favor elimínela para proceder al envío');
                    break;
                }
            }
        }
    }

    public static void recuperarAdjuntos(Id idConsulta, String para, String emailCC, String emailCCO, TemplateWrapper plantillaEmail){

        List<ContentVersion> adjuntos = recuperaAdjuntos(idConsulta); 

        Set<Id> idContentDocument = new Set<Id>();

        for(ContentVersion cv : adjuntos){
            if(cv.SAC_Oculto__c == false){  // No recuperamos los adjuntos ocultos (SAC_Oculto__c = true), ya que estos no debemos mandarlos.
                idContentDocument.add(cv.ContentDocumentId);
            }
        }

        List<ContentDocument> documentos = new List<ContentDocument>();
        if(!idContentDocument.isEmpty()){
            if(!Schema.sObjectType.ContentDocument.isAccessible()){ throw new AuraHandledException( 'Fallo al acutalizar.' ); }
            documentos = [SELECT Id FROM ContentDocument WHERE id IN: idContentDocument]; 
        }

        Set<Id> idAdjuntos = new Set<Id>();
        for(ContentDocument doc : documentos){
            idAdjuntos.add(doc.Id);
        }

        SPV_LCMP_GestionEmails.enviarEmail(idConsulta, para, emailCC, emailCCO, plantillaEmail.htmlValueTemplate, plantillaEmail.subjectTemplate, JSON.serialize(idAdjuntos), null);
    }

    public static ContentVersion[] recuperaAdjuntos(String id){

        Map<Id, Boolean> contentOculto = new Map<Id, Boolean>();
        List<Id> idsDocumentLink = new List<Id>();

        try {
        List<ContentDocumentLink> cdL = [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId =: id AND ContentDocument.FileType != 'SNOTE'];  
        

            for(ContentDocumentLink recordCdL : cdL){

                idsDocumentLink.add(recordCdL.ContentDocumentId);
            }

            List<ContentVersion> cv = [SELECT Id, ContentDocumentId, Title, SAC_Oculto__c, CreatedDate, SAC_TipoAdjunto__c, SAC_TipoAdjunto__r.Name, SAC_Bloque__c, SAC_ValidadoCV__c FROM ContentVersion WHERE ContentDocumentId IN: idsDocumentLink ORDER BY CreatedDate ASC];

            for(ContentVersion recordCv : cv){
                contentOculto.put(recordCv.id, recordCv.SAC_Oculto__c);
            }

            ContentVersion[] resultado =  new List<ContentVersion>();
            for(ContentDocumentLink record : cdL){

                if(contentOculto.get(record.id) != null){

                    resultado.add(new ContentVersion (ContentDocumentId=record.ContentDocumentId, Title=record.ContentDocument.Title, SAC_Oculto__c=contentOculto.get(record.id)));

                }else{resultado.add(new ContentVersion (ContentDocumentId=record.ContentDocumentId, Title=record.ContentDocument.Title, SAC_Oculto__c=false));}
            }

            return cv;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**************************************************************************
     * Proposito: Crear TME al crear una Interaccion de tipo consulta
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US975885      Raúl Santos    17/07/2024       Creación    
    **************************************************************************/ 
    // public static void insertarTME(List<SAC_Interaccion__c> listConsultas) {

    //     List<SAC_TMECaso__c> listaTMEs = new List<SAC_TMECaso__c>();
        
        // for(SAC_Interaccion__c consulta : listConsultas) {

        //     SAC_TMECaso__c tme = new SAC_TMECaso__c();
        //     tme.name = 'TMO Consulta';
        //     tme.RecordTypeId = RECTYPETMECONSULTA;
        //     tme.SAC_Interaccion__c= consulta.id;
        //     listaTMEs.add(tme);
        // }

        // SAC_DatabaseDML.insertListDML(listaTMEs, true);
    // }

    /**************************************************************************
     * Proposito: Añade al campo SAC_InedexedThreadId el compuesto con los ID acotados de la Organizacion y de la Consulta.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US975885      Raúl Santos    17/07/2024       Creación    
    **************************************************************************/ 
    public static void crearThreadId(List<SAC_Interaccion__c> listConsultas) {

        List<SAC_Interaccion__C> consultasUpdatear = new List<SAC_Interaccion__C>();

        for(SAC_Interaccion__c consulta : listConsultas) {
             
            String threadId = SPV_Utils.creacionThreadID(consulta.Id);
            SAC_Interaccion__c consultaSPV = new SAC_Interaccion__c();
            consultaSPV.Id = consulta.Id;
            consultaSPV.SAC_IndexedThreadId__c = threadId;
            consultasUpdatear.add(consultaSPV);
        }  
        
        SPV_DatabaseDML.updateListDML(consultasUpdatear, true);
    }

    /**************************************************************************
     * Proposito: Rellenar los campos SAC_NIF__c y SAC_NombreReclamante__c en el before insert del trigger
     * para poder utilizar los campos en los email templates
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US975885      Raúl Santos    17/07/2024       Creación    
    **************************************************************************/  
    public static void rellenarNifYNombreReclamante(List<SAC_Interaccion__c> listNewInteraccion) {
        List<Id> listaIdsCasoRelacionado = new List<Id>();
        for (SAC_Interaccion__c interaccion : listNewInteraccion) {
            if (String.IsNotBlank(interaccion.SAC_Reclamacion__c)) {
                listaIdsCasoRelacionado.add(interaccion.SAC_Reclamacion__c);
            }
        }

        Map<Id, Case> mapaCasos = new Map<Id, Case>([SELECT Id, AccountId, Account.name, Account.CC_Numero_Documento__c, CC_Oficina_Afectada_Lookup__c 
                                                    FROM Case 
                                                    WHERE RecordTypeId = :RECTYPERECLAMACION AND Id IN :listaIdsCasoRelacionado]);

        for (SAC_Interaccion__c interaccion : listNewInteraccion) {
            if (mapaCasos.containsKey(interaccion.SAC_Reclamacion__c)) {
                interaccion.SAC_DNI__c = mapaCasos.get(interaccion.SAC_Reclamacion__c).Account.CC_Numero_Documento__c;
                interaccion.SAC_Reclamante__c = mapaCasos.get(interaccion.SAC_Reclamacion__c).Account.Name;
            }
        }
    }  

    /**************************************************************************
     * Proposito: Rellenar el campo SAC_GrupoCreador__c
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US975885      Raúl Santos    17/07/2024       Creación    
    **************************************************************************/  
    public static void rellenarGrupoCreador (List<SAC_Interaccion__c> listNewInteraccion) {
        id userid = userinfo.getUserId();
        user userCreador = [SELECT SAC_GruposPerteneciente__c FROM User WHERE Id =:userid LIMIT 1];
        List<String> idList = new List<String>();

        List<Id> listaIdsCasoRelacionado = new List<Id>();
        for (SAC_Interaccion__c interaccion : listNewInteraccion) {
            if (String.IsNotBlank(interaccion.SAC_Reclamacion__c)) {
                listaIdsCasoRelacionado.add(interaccion.SAC_Reclamacion__c);
            }
        }

        Map<Id, Case> mapaCasos = new Map<Id, Case>([SELECT Id, SEG_Grupo__c, RecordTypeId, SAC_PretensionPrincipal__r.OwnerId, OwnerId, SAC_GrupoLetrado__c
                                                        FROM Case WHERE RecordTypeId =:RECTYPERECLAMACION AND OwnerId =:userid AND Id IN :listaIdsCasoRelacionado]);

        if(String.isnotBlank(userCreador.SAC_GruposPerteneciente__c)){
            idList = userCreador.SAC_GruposPerteneciente__c.split(';');
        }

        for (SAC_Interaccion__c interaccion : listNewInteraccion) {
            if(idList.size() == 1 && idList != null){
                interaccion.SAC_GrupoCreador__c = idList[0];
             
            }else if(idList.size() > 1 && idList != null){
                if (mapaCasos.containsKey(interaccion.SAC_Reclamacion__c)) {
                    if(mapaCasos.get(interaccion.SAC_Reclamacion__c).SAC_PretensionPrincipal__r.OwnerId == userid && String.isnotBlank(mapaCasos.get(interaccion.SAC_Reclamacion__c).SAC_PretensionPrincipal__r.OwnerId)){
                   
                        interaccion.SAC_GrupoCreador__c = mapaCasos.get(interaccion.SAC_Reclamacion__c).SAC_GrupoLetrado__c;

                    }else if(mapaCasos.get(interaccion.SAC_Reclamacion__c).OwnerId == userid && String.isnotBlank(mapaCasos.get(interaccion.SAC_Reclamacion__c).OwnerId)){
                   
                        interaccion.SAC_GrupoCreador__c =  mapaCasos.get(interaccion.SAC_Reclamacion__c).SEG_Grupo__c;

                    }else{
                        interaccion.SAC_GrupoCreador__c = idList[0];
                    }
                }
            
            }     
        }  
    }   

    /**************************************************************************
     * Proposito: Informar el valor SAC_Oficina__c de la consulta el grupo de esta es un grupo de oficina, se recupera el valor de la oficina afectada
     * de la reclamación padre (CC_Oficina_Afectada_Lookup__c). Si es distinto de oficina, se limpia el campo SAC_Oficina__c
     * de la consulta. En el momento en el que trae la oficina de la reclamación para ponerla en la interacción, también trae
     * el email de la oficina de la reclamación para añadirlo al campo SAC_EmailOficina__c
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US975885      Raúl Santos    17/07/2024       Creación    
    **************************************************************************/  
    public static void informarOficinaConsulta(List<SAC_Interaccion__c> listNewInteraccion) {

        //Guardar ids de los grupos y las reclamaciones
        Set<Id> setIdsReclamaciones = new Set<Id>();
        Set<Id> setIdsGrupos = new Set<Id>();

        for (SAC_Interaccion__c consulta : listNewInteraccion) {
            setIdsReclamaciones.add(consulta.SAC_Reclamacion__c);
            setIdsGrupos.add(consulta.SAC_GrupoColaborador__c);
        }

        //Buscar los casos padre
        if(Schema.sObjectType.Case.isAccessible() && Schema.sObjectType.CC_Grupo_Colaborador__c.isAccessible()){
            List<Case> listaCasos = [SELECT Id, CC_Oficina_Afectada_Lookup__c, CC_Oficina_Afectada_Lookup__r.CC_Email__c FROM Case WHERE RecordTypeId = :RECTYPERECLAMACION AND Id IN :setIdsReclamaciones];   
            List<CC_Grupo_Colaborador__c> listaGrupos = [SELECT Id, SAC_DeveloperName__c, SAC_Externo__c, SAC_TienePropietario__c FROM CC_Grupo_Colaborador__c WHERE RecordTypeId = :RECTYPGRUPOTAREAS AND Id IN :setIdsGrupos];

            if(!listaCasos.isEmpty() && !listaGrupos.isEmpty()) {
                //Guardar resultado de las búsquedas en mapas
                Map<Id, CC_Grupo_Colaborador__c> mapaGrupos = new Map<Id, CC_Grupo_Colaborador__c>(listaGrupos);
                Map<Id, Case> mapaCasos = new Map<Id, Case>(listaCasos);

                //Poner la oficina de la reclamación en la consulta
                for (SAC_Interaccion__c consulta : listNewInteraccion) {
                    //Si el grupo de la consulta es oficina y la reclamación tiene una oficina informada, llevamos la oficina de la reclamación a la consulta
                    if (mapaGrupos.containsKey(consulta.SAC_GrupoColaborador__c) && mapaGrupos.get(consulta.SAC_GrupoColaborador__c).SAC_DeveloperName__c == 'OFICINA' 
                        && mapaCasos.containsKey(consulta.SAC_Reclamacion__c) && String.isNotBlank(mapaCasos.get(consulta.SAC_Reclamacion__c).CC_Oficina_Afectada_Lookup__c)) {
                        consulta.SAC_Oficina__c = mapaCasos.get(consulta.SAC_Reclamacion__c).CC_Oficina_Afectada_Lookup__c;
                        if(String.isNotBlank(mapaCasos.get(consulta.SAC_Reclamacion__c).CC_Oficina_Afectada_Lookup__r.CC_Email__c)) {
                            consulta.SAC_EmailOficina__c = mapaCasos.get(consulta.SAC_Reclamacion__c).CC_Oficina_Afectada_Lookup__r.CC_Email__c;
                        }
                    //Si el grupo de la consulta es distinto al de la oficina y el campo oficina está informado, limpiamos el campo oficina de la interacción
                    } else if(mapaGrupos.containsKey(consulta.SAC_GrupoColaborador__c) && mapaGrupos.get(consulta.SAC_GrupoColaborador__c).SAC_DeveloperName__c != 'OFICINA'
                    && String.isNotBlank(consulta.SAC_Oficina__c)) {
                        consulta.SAC_Oficina__c = null;
                        if (String.isNotBlank(consulta.SAC_EmailOficina__c)) {
                            consulta.SAC_EmailOficina__c = null;
                        }
                    }
                }
            }
        }
    }

    /*********************************************************************************************
     * Proposito: Método que detecta el cambio de oficina en una consulta y posteriormente informa el campo SAC_EmailOficina__c
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE          Description
     * 1.0             US975885     Raúl Santos    17/07/2024         Creación    
    *********************************************************************************************/
    public static void cambiarOficinaConsulta(List<SAC_Interaccion__c> listaConsultasSPV, Map<Id, SAC_Interaccion__c> mapOldObj){

        Set<Id> setIdsOficinas = new Set<Id>();
        
        for(SAC_Interaccion__c consulta : listaConsultasSPV){ 
            if(consulta.SAC_Oficina__c != mapOldObj.get(consulta.Id).SAC_Oficina__c){ 
                if (String.isNotBlank(consulta.SAC_Oficina__c)) {
                    setIdsOficinas.add(consulta.SAC_Oficina__c);
                } else {
                    //Si el campo oficina viene vacio, limpamos el email
                    consulta.SAC_EmailOficina__c = null;
                }
            }
        }

        //Recuperar oficinas
        List<Account> listaOfis = new List<Account>();
        if (!setIdsOficinas.isEmpty() && Schema.sObjectType.Account.isAccessible()) {
            listaOfis = [SELECT Id, CC_Email__c FROM Account WHERE Id IN :setIdsOficinas];
        }

        //Pasar listaOfis a mapa
        Map<Id, Account> mapaOfis = new Map<Id, Account>();
        for (Account ofi : listaOfis) {
            mapaOfis.put(ofi.Id, ofi);
        }

        //Añadir correos de las oficinas a las consultas
        if (!mapaOfis.isEmpty()) {
            for (SAC_Interaccion__c consulta : listaConsultasSPV) {
                if (String.isNotBlank(consulta.SAC_Oficina__c) && mapaOfis.containsKey(consulta.SAC_Oficina__c) && String.isNotBlank(mapaOfis.get(consulta.SAC_Oficina__c).CC_Email__c)) {
                    consulta.SAC_EmailOficina__c = mapaOfis.get(consulta.SAC_Oficina__c).CC_Email__c;
                }
            }   
        }
    }

    /*****************************************************************
    * Proposito: Controlar el lanzamiento de alertas de Interacciones
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            --             Raúl Santos    25/09/24         Creacion
    *****************************************************************/
    public static void lanzarAlertasInteraccion(List<SAC_Interaccion__c> listInteraccionesSPV, Map<Id, SAC_Interaccion__c> mapOldObj) {
        List<SAC_WrapperAlerta> listaWrapperAlerta = new List<SAC_WrapperAlerta>();
        List<SAC_Interaccion__c> listConsultasPteRespuesta = new List<SAC_Interaccion__c>();
        // List<Group> cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SPV_PendienteAsignar' LIMIT 1];
        Boolean hacerQuery = false;
        Set<Id> setIdsInteraccion = new Set<Id>();
        List<SAC_Interaccion__c> listaInteraccionSelect = new List<SAC_Interaccion__c>();
        Map<Id, SAC_Interaccion__c> mapEscalados = new Map<Id, SAC_Interaccion__c>();

        for (SAC_Interaccion__c interaccion : listInteraccionesSPV) {
            if (interaccion.RecordTypeId == RECTYPEESCALADO && interaccion.SAC_Estado__c == 'SPV_PendienteEnviar' && mapOldObj == null) {
                setIdsInteraccion.add(interaccion.Id);
                hacerQuery = true;
            }
        }

        if(hacerQuery && Schema.sObjectType.SAC_Interaccion__c.isAccessible()) {
            listaInteraccionSelect = [SELECT Id, RecordTypeId, SAC_GrupoColaborador__c, SAC_GrupoColaborador__r.SAC_Email__c, SAC_GrupoColaborador__r.SAC_Email2__c, SAC_GrupoColaborador__r.SAC_Email3__c
                                        FROM SAC_Interaccion__c
                                        WHERE RecordTypeId = :RECTYPEESCALADO AND Id IN :setIdsInteraccion];

            for (SAC_Interaccion__c interaccion : listaInteraccionSelect) {
                if(interaccion.RecordTypeId == RECTYPEESCALADO) {
                    mapEscalados.put(interaccion.Id, interaccion);
                }
            }
        }

        for (SAC_Interaccion__c interaccion : listInteraccionesSPV) {

            //Si es una consulta
            if (interaccion.RecordTypeId == RECTYPECONSULTA) {

                //Si la consulta pasa a estado 'Pendiente Respuesta'
                if (mapOldObj.get(interaccion.Id).SAC_Estado__c != interaccion.SAC_Estado__c && interaccion.SAC_Estado__c == 'SAC_PendienteRespuesta') {
                    //Añadirla a la lista para posteriormente llamar al método
                    listConsultasPteRespuesta.add(interaccion);
                }
                //Si la consulta ha sido respondida
                else if (mapOldObj.get(interaccion.id).SAC_Estado__c != interaccion.SAC_Estado__c && interaccion.SAC_Estado__c == 'SAC_Resuelta') {
                    //Preparar una alerta
                    SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(interaccion.SAC_Reclamacion__c,
                                                                        'SPV_005',
                                                                        'La consulta ' + interaccion.Name + ' ha sido respondida. Ya puede revisarla.',
                                                                        interaccion.CreatedById,
                                                                        '',
                                                                        '',
                                                                        interaccion.Id);
                                                                        wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + interaccion.Id;
                                                                        wrapAlerta.proyecto = 'SPV';
                    //Añadirla a la lista para posteriormente llamar al método
                    listaWrapperAlerta.add(wrapAlerta);
                    
                }
            }else if(interaccion.RecordTypeId == RECTYPEESCALADO) { //Si es un escalado

                //Si es un escalado que se acaba de crear
                if(interaccion.SAC_Estado__c == 'SPV_PendienteEnviar' && mapOldObj == null && mapEscalados.containsKey(interaccion.Id)){

                    // Obtener el objeto SAC_Interaccion__c del mapa usando la clave interaccion.Id
                    SAC_Interaccion__c escalado = mapEscalados.get(interaccion.Id);

                    List<String> listaEmails = new List<String>();

                    if (escalado.SAC_GrupoColaborador__r.SAC_Email__c != null) {
                        listaEmails.add(escalado.SAC_GrupoColaborador__r.SAC_Email__c);
                    }
                    if (escalado.SAC_GrupoColaborador__r.SAC_Email2__c != null) {
                        listaEmails.add(escalado.SAC_GrupoColaborador__r.SAC_Email2__c);
                    }
                    if (escalado.SAC_GrupoColaborador__r.SAC_Email3__c != null) {
                        listaEmails.add(escalado.SAC_GrupoColaborador__r.SAC_Email3__c);
                    }

                    //Preparar una alerta
                    SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(interaccion.SAC_CasoEscalado__c,
                                                                        'SPV_006',
                                                                        'El escalado ' + interaccion.Name + ' ha sido creado. Ya puede revisarlo.',
                                                                        null,
                                                                        '',
                                                                        '',
                                                                        interaccion.Id);
                                                                        wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + interaccion.Id;
                                                                        wrapAlerta.listaEmailsGrupo = listaEmails;
                                                                        wrapAlerta.idGrupoColaborador = escalado.SAC_GrupoColaborador__c;
                                                                        wrapAlerta.proyecto = 'SPV';
                    //Añadirla a la lista para posteriormente llamar al método
                    listaWrapperAlerta.add(wrapAlerta);
                }
                else if(mapOldObj != null){
                    //Si el escalado ha sido respondido
                    if(mapOldObj.get(interaccion.Id).SPV_TipoRespuesta__c != interaccion.SPV_TipoRespuesta__c){
                        //Preparar una alerta
                        SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(interaccion.SAC_CasoEscalado__c,
                                                                            'SPV_007',
                                                                            'El escalado ' + interaccion.Name + ' ha sido atendido. Ya puede revisarlo.',
                                                                            interaccion.CreatedById,
                                                                            '',
                                                                            '',
                                                                            interaccion.Id);
                                                                            wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + interaccion.Id;
                                                                            wrapAlerta.proyecto = 'SPV';
                        //Añadirla a la lista para posteriormente llamar al método
                        listaWrapperAlerta.add(wrapAlerta);
                    }
                }
            }
        }

        //Si tenemos consultas pendiente respuesta, debemos crear el pending process para la ejecucion de sus alertas
        if (!listConsultasPteRespuesta.isEmpty()) {
            scheduleAlertaConsulta24h(listConsultasPteRespuesta);
        }

        //Si tenemos alertas que enviar, se llama al método que las envía
        if (!listaWrapperAlerta.isEmpty()) {
            SAC_Alertas.generarAlertas(listaWrapperAlerta);
        }
    }

    /**************************************************************************
     * Proposito: Crea un registro de pendingProcess para lanzar una clase schedulable al cabo de 24 horas.
     * La clase schedulable creará una alerta si la consulta sigue en estado pendiente de asignar.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --             Raúl Santos    25/09/24         Creacion
    **************************************************************************/  
    public static void scheduleAlertaConsulta24h(List<SAC_Interaccion__c> listConsultasPteRespuesta) {
        List<CBK_SCH_PendingProcess__c> listaPendingProcess = new List<CBK_SCH_PendingProcess__c>();

        for (SAC_Interaccion__c consulta : listConsultasPteRespuesta) {
            CBK_SCH_PendingProcess__c pendingProcessConsulta = new CBK_SCH_PendingProcess__c();
            pendingProcessConsulta.recordId__c = consulta.Id;
            // pendingProcessConsulta.Schedule_Time__c = system.now().addHours(24);
            pendingProcessConsulta.className__c = 'SAC_SchedulableAlertas';

            //Si es una consulta de oficina la primera alerta es a las 24 horas. Sino, es a las 48 horas.
            if(String.isNotBlank(consulta.SAC_Oficina__c)){
                pendingProcessConsulta.Schedule_Time__c = system.now().addHours(24);
                pendingProcessConsulta.Param1__c = '24';
            }else{
                pendingProcessConsulta.Schedule_Time__c = system.now().addHours(48);
                pendingProcessConsulta.Param1__c = '48';
            }

            listaPendingProcess.add(pendingProcessConsulta);
        }

        if (!listaPendingProcess.isEmpty()) {
            // if (!Schema.sObjectType.CBK_SCH_PendingProcess__c.isCreateable()) { throw new AuraHandledException( 'No tienes permisos para realziar esta accion.' ); }
            SPV_DatabaseDML.insertListDML(listaPendingProcess, true);
        }
    } 

    public class TemplateWrapper{

        @AuraEnabled public String idTemplate{get; set;}
        @AuraEnabled public String nameTemplate{get; set;}
        @AuraEnabled public String subjectTemplate{get; set;}
        @AuraEnabled public String htmlValueTemplate{get; set;}
        @AuraEnabled public String paraTemplate{get; set;}
        
        public TemplateWrapper(String idTemplate, String nameTemplate, String subjectTemplate, String htmlValueTemplate, String paraTemplate){
            this.idTemplate = idTemplate;
            this.nameTemplate = nameTemplate;
            this.subjectTemplate = subjectTemplate;
            this.htmlValueTemplate = htmlValueTemplate;
            this.paraTemplate = paraTemplate;
        }
    }


    /***********************************************************************************************************
     * Proposito: Detectar la creación de un escalado a AJ para la suma de un día natural en el SLA Análisis
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US942879     Sergio Martín   02/10/24         Creacion
    ***********************************************************************************************************/  
    public static void sumaSLAEscaladoAJ(List<SAC_Interaccion__c> listEscalados) {
        List<Id> listaIdsCasoRelacionado = new List<Id>();
        List<Case> listaCasoActualizar = new List<Case>();

        Id idAsesoriaJuridica = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE SAC_DeveloperName__c = 'SPV_AJ'].Id;

        for (SAC_Interaccion__c interaccion : listEscalados) {
            if(interaccion.SAC_GrupoColaborador__c == idAsesoriaJuridica) {
                Case caso = new Case();
                caso.Id = interaccion.SAC_CasoEscalado__c;
                caso.SPV_EscaladoAJ__c = true;
                listaCasoActualizar.add(caso);
            }
        }

        if(!listaCasoActualizar.isEmpty() && Schema.sObjectType.Case.isUpdateable()) {
            SPV_DatabaseDML.updateListDML(listaCasoActualizar, true);
        }
    } 
}