/*****************************************************************
 * Name: SAC_LCMP_RedaccionFinal
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Redacción final de la reclamación
 *  
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US227438        Luis Mesa      20/05/21      Creación
*****************************************************************/
public without sharing class SAC_LCMP_RedaccionFinal {

    private static Set<String> objetos = new Set<String>{'Case','SAC_Interaccion__c','SAC_TMECaso__c','SAC_MaestroTemas__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPERECLAMACION = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    private static final Id RECTYPEPRETENSION = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();
    private static final Id RECTYPECONSULTA = mapRTsObjects.get('Case').get('SAC_Consulta').getRecordTypeId();
    private static final Id RECTYPECONSULTASAC = mapRTsObjects.get('Case').get('SAC_ConsultaSAC').getRecordTypeId();
    private static final Id RECTYPEESCALADONV2 = mapRTsObjects.get('SAC_Interaccion__c').get('SAC_Escalado').getRecordTypeId();
    private static final Id RECTYPEESCALADONV3 = mapRTsObjects.get('SAC_Interaccion__c').get('SAC_EscaladoNV3').getRecordTypeId();
    private static final Id RECTYPETMETAREA = mapRTsObjects.get('SAC_TMECaso__c').get('SAC_TMETarea').getRecordTypeId();
    private static final Id RECTYPEMOTIVOSDEMORA = mapRTsObjects.get('SAC_MaestroTemas__c').get('SAC_MotivoDemora').getRecordTypeId();
    private static final Id RECTYPETIPOADJUNTOS = mapRTsObjects.get('SAC_MaestroTemas__c').get('SAC_TipoAdjuntos').getRecordTypeId();



    @AuraEnabled
    public static Boolean compruebaPDFs(String id){
        List<ContentDocumentLink> listacdl = [SELECT Id, LinkedEntityId, ContentDocument.LatestPublishedVersion.SAC_StringRedaccion_fileupload__c, Visibility, IsDeleted, ShareType,
                                                ContentDocument.Title, ContentDocument.createdDate, ContentDocument.FileType
                                                FROM ContentDocumentLink 
                                                WHERE LinkedEntityId = :id
                                                AND ContentDocument.LatestPublishedVersion.SAC_StringRedaccion_fileupload__c = 'ResolucionRedaccion'];
        return !listacdl.isEmpty() ? true : false;
    }

    @AuraEnabled
    public static void updateNombrePDF(List<String> archivos, String id, Boolean borrarAnterior){
        if(borrarAnterior){
            List<ContentVersion> contentVersions = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE SAC_StringRedaccion_fileupload__c = 'ResolucionRedaccion' AND FirstPublishLocationId =: id AND Id NOT IN: archivos];
            List<Id> ids = new List<Id>();
            for(ContentVersion cv : contentVersions){
                ids.add(cv.ContentDocumentId);
            }
            List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE Id IN: ids];
            SAC_DatabaseDML.updateListDML(contentDocuments, false);
        }
        else{
            List<ContentVersion> contentVersions = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE SAC_StringRedaccion_fileupload__c = 'ResolucionRedaccion' AND FirstPublishLocationId =: id AND Id IN: archivos];
            List<Id> ids = new List<Id>();
            for(ContentVersion cv : contentVersions){
                ids.add(cv.ContentDocumentId);
            }
            List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE Id IN: ids];
            SAC_DatabaseDML.updateListDML(contentDocuments, false);
        }
        
    }
     /*****************************************************************
    * Proposito: Query para caso
    *
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US248482         Luis Mesa      26/08/21     Creación
    *****************************************************************/ 
    @AuraEnabled
    public static Case devolverCaso(String id){
        return [SELECT Id, CC_Canal_Respuesta__c, OS_Fecha_Resolucion__c, SAC_SentidoResolucion__c, SAC_MotivoSentidoResolucion__c, OwnerId, Status, SAC_FechaRecepcion__c, SAC_Entidad_Afectada__c, SAC_EntidadProductora__c, CC_Oficina_Afectada_Lookup__c, CC_Oficina_Afectada_Lookup__r.CC_Email__c, SAC_Naturaleza__c, SAC_MotivoDemora__c, SAC_ComentarioDemora__c, SAC_MotivoInadmision__c, CC_Idioma__c, RecordType.DeveloperName FROM Case WHERE Id =: id LIMIT 1];
    }
    
    /*****************************************************************
    * Proposito: Guardar el contenido de los campos sentido resolucion y argumento resolucion.
    *
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US248482         Luis Mesa      26/08/21     Creación
    * 1.1                             Alex Perez     11/10/21     controlar escalado
    *****************************************************************/ 
    @AuraEnabled
    public static void guardarResolucionApex(String id, String sentido, String argumento, String motivoInad){
        if(!Schema.sObjectType.Case.isAccessible() || !Schema.sObjectType.Case.isUpdateable()){
            throw new AuraHandledException('No tienes permisos para visualizar o actualizar el registro.');
        }
                
        list<id> rtEscalado = new list<id>();
        rtEscalado.add(RECTYPEESCALADONV2);
        rtEscalado.add(RECTYPEESCALADONV3);

        Case casoActual = [SELECT Id, SAC_SentidoResolucion__c, SAC_MotivoSentidoResolucion__c, SAC_Importe_Resuelto__c FROM Case WHERE Id =: id LIMIT 1];
        
        /*if(casoActual.SAC_Importe_Resuelto__c != null) {
            list<SAC_Interaccion__c> escalados = [SELECT Id FROM SAC_Interaccion__c WHERE recordTypeId IN : rtEscalado 
                                                    AND SAC_ImporteAutorizado__c >= : casoActual.SAC_Importe_Resuelto__c 
                                                    AND SAC_CasoEscalado__c = : casoActual.Id AND SAC_Conclusion__c IN ('SAC_Autorizado', 'SAC_AutorizadoConModificaciones')
                                                    AND SAC_Estado__c = 'SAC_Atendida'];
            if(escalados.isEmpty()) {
            throw new AuraHandledException('El importe autorizado escalado es menor al importe resuelto de la reclamación.');
            }
        }*/
        //string error = SAC_Validaciones.validarEnvioTarea(null, id, false);
        string error = SAC_Validaciones.validarEscaladoEnvioTarea(null, id, 'Escalado');
        if(error != '') {
            throw new AuraHandledException(error);
        }
        casoActual.SAC_MotivoSentidoResolucion__c = argumento ;
        casoActual.SAC_SentidoResolucion__c = sentido;
        if(sentido == 'SAC_004'){
            casoActual.SAC_MotivoInadmision__c = motivoInad;
        }else{
            casoActual.SAC_MotivoInadmision__c = null;
        }
        // if(casoActual.SAC_MotivoSentidoResolucion__c == null){
               
        // }else{
        //     casoActual.SAC_MotivoSentidoResolucion__c = argumento + '\n\n' + casoActual.SAC_MotivoSentidoResolucion__c;   
        // }    

        SAC_DatabaseDML.updateDML(casoActual, false);
    }

    @AuraEnabled 
    public static user fetchUser(){
        User u = [select id,Name from User where id =: userInfo.getUserId()];
        return u;
    }

    @AuraEnabled 
    public static Boolean recuperarPermiso(Case reclamacion){
        Boolean permisoUsuario = false;
        String usuarioActual = UserInfo.getUserId();
        //Comprobar si el usuario de la reclamación es el mismo que está efectuando la acción
        if (reclamacion.OwnerId == usuarioActual) {
            permisoUsuario = true;
        } else {
            //Traer pretensiones hijas
            List<Case> listaPretensiones = [SELECT Id, OwnerId FROM Case WHERE RecordTypeId = :RECTYPEPRETENSION AND SAC_Reclamacion__c = :reclamacion.Id];
            //Comprobar que alguno de los owners de las pretensiones es el que ejecuta la acción
            for (Case caso : listaPretensiones) {
                if (caso.OwnerId == usuarioActual) {
                    permisoUsuario = true;
                }
            }
        }
        return permisoUsuario;
    }

    @AuraEnabled
    public static DateTime finalizarRedaccion(String id, Boolean envioMail, Boolean sinEnvio){
    /*****************************************************************
    * Proposito: Finalizar redacción de la reclamación.
    *
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US248482         Luis Mesa      05/08/21     Creación
    *****************************************************************/ 
        if(!Schema.sObjectType.Case.isAccessible() || !Schema.sObjectType.SAC_Accion__c.isAccessible() || !Schema.sObjectType.SAC_Accion__c.isUpdateable() || !Schema.sObjectType.Case.isUpdateable()){
            throw new AuraHandledException('No tienes privilegios para manipular la redacción.');
        }
        Case reclamacion = [SELECT Id, OS_Fecha_Resolucion__c, Status, SAC_Redaccion__c, OS_Email__c, CaseNumber, AccountId , CC_No_Identificado__c, SAC_SinEnvioComunicacion__c
                            FROM Case WHERE RecordTypeId =: RECTYPERECLAMACION AND Id =: id];
                            
        if(reclamacion.AccountId != null || reclamacion.CC_No_Identificado__c == true){
            List<Case> pretensiones = [SELECT Id, Status FROM Case WHERE RecordTypeId =: RECTYPEPRETENSION AND SAC_Reclamacion__c =: reclamacion.Id];
            if(reclamacion.OS_Fecha_Resolucion__c == null){
                reclamacion.OS_Fecha_Resolucion__c = system.now();
            }
            
            //lanzar el correo al reclamante
            //lanzarCorreo(reclamacion.SAC_Redaccion__c, reclamacion.OS_Email__c);
            //actualizar estados de tareas + notificacion a los equipos ejecutores
             
            List<SAC_Accion__c> tareas = [SELECT Id, OwnerId, SAC_Estado__c, SAC_Pretension__c, SAC_Reclamacion__c, Name, SAC_EquipoResponsable__c,
                                            SAC_Reclamacion__r.SAC_CasoEspecial__c, SAC_Reclamacion__r.SAC_Entidad_Afectada__c, SAC_Reclamacion__r.SEG_Grupo__c,
                                            SAC_ImporteResuelto__c, SAC_Reclamacion__r.CC_Importe_Reclamado__c, SAC_Reclamacion__r.SAC_Importe_Resuelto__c,
                                            SAC_MaestroAccionesReclamacion__r.Name, SAC_Oficina__c, SAC_Oficina__r.CC_Email__c, SAC_Comentarios__c
                                            FROM SAC_Accion__c WHERE SAC_Reclamacion__c =: id 
                                            AND (SAC_Estado__c != 'SAC_Finalizada' AND SAC_Estado__c != 'SAC_FinalizadaIncompleta' AND SAC_Estado__c != 'SAC_Descartada')];
             
            string errorValidar = SAC_Validaciones.validarEscaladoEnvioTarea(null, id, '');
             
            if(errorValidar != '') {
                throw new AuraHandledException(errorValidar);
            }
            if(sinEnvio){
                reclamacion.SAC_SinEnvioComunicacion__c = true;
            }
            if(envioMail){
                if(!tareas.isEmpty()){
                    reclamacion.Status = 'SAC_004';
                    reclamacion.SAC_StatusAuxiliar__c = 'SAC_004';
                    reclamacion.SAC_ValidarEnvioResolucion__c = true;
                    gestionarTareas(tareas, reclamacion.CaseNumber); //Las tareas cambian de estado                
                }
                else{//cuando viene del reenvio de la redacción final
                    reclamacion.Status = 'Cerrado';
                    reclamacion.SAC_StatusAuxiliar__c = 'Cerrado';
                    reclamacion.SAC_ValidarEnvioResolucion__c = true;
                }

                for(Case pretension : pretensiones){
                    if(pretension.Status != 'SAC_009') {
                        pretension.Status = 'Cerrado';
                        pretension.SAC_StatusAuxiliar__c = 'Cerrado';
                    }
                }
            }
            List<Case> listaCasosUpdatear = new List<Case>();
            listaCasosUpdatear.addAll(pretensiones);
            listaCasosUpdatear.add(reclamacion);
            SAC_DatabaseDML.updateListDML(listaCasosUpdatear, true);
        }else{
            throw new AuraHandledException('Para resolver es necesario informar el cliente.');
        }
        
        return reclamacion.OS_Fecha_Resolucion__c;
    }

    @AuraEnabled
    public static void gestionarTareas(List<SAC_Accion__c> acciones, String numCaso){
    /*****************************************************************
    * Proposito: Lanzar el email con la redacción al reclamante
    *
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR                DATE         Description
    * 1.0            US248482         Luis Mesa             06/08/21     Creación
      2.0            US496859         Jose Carlos Blanco    16/12/22     Modificación (envío mail en asíncrono)
    *****************************************************************/ 
        Group cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SAC_PendienteAsignar' LIMIT 1];
        List<Id> idListaGrupos = new List<Id>();
        List<Id> idListaOficinas = new List<Id>();

        List<SAC_Accion__c> listaTareas = new List<SAC_Accion__c>();
        List<SAC_Accion__c> listaTareasOficina = new List<SAC_Accion__c>();

        Map<Boolean, List<SAC_Accion__c>> mapTareas = new Map<Boolean, List<SAC_Accion__c>>();

        List<Messaging.SingleEmailMessage> listaResolucionTarea = new List<Messaging.SingleEmailMessage>();
        List<Messaging.SingleEmailMessage> listaResTareaOficina = new List<Messaging.SingleEmailMessage>();


        List<CC_Grupo_Colaborador__c> listaGrupos = new List<CC_Grupo_Colaborador__c>();
        List<Account> listaOficinas = new List<Account>();
        List<SAC_TMECaso__c> tmesTareas = new List<SAC_TMECaso__c>();
        Map<Id,String> mapaEstadosAnterioresT = new Map<Id,String>();

        List<SAC_Accion__History> historicoAcciones = [SELECT Id, OldValue, parentId, CreatedDate
                                                        FROM SAC_Accion__History 
                                                        WHERE parentId IN: acciones 
                                                        AND field = 'SAC_Estado__c' ORDER BY CreatedDate];
        
        for (SAC_Accion__History accHistorico : historicoAcciones) {
            mapaEstadosAnterioresT.put(accHistorico.parentId, String.valueOf(accHistorico.OldValue));
        }
        
        for(SAC_Accion__c accion : acciones){
            if(accion.SAC_Estado__c == 'SAC_StandBy'){
                accion.SAC_Estado__c = mapaEstadosAnterioresT.get(accion.Id);
            }
            
            else if(accion.SAC_Estado__c == 'SAC_PendienteEnviar'){
                accion.SAC_Estado__c = 'SAC_PendienteAsignar';
                accion.OwnerId = cola.Id;
                SAC_TMECaso__c tme = new SAC_TMECaso__c();
                tme.name = 'Resolución de la tarea'; 
                tme.RecordTypeId = RECTYPETMETAREA;
                tme.SAC_Accion__c= accion.id;
                tmesTareas.add(tme);

                if(accion.SAC_MaestroAccionesReclamacion__r.Name == 'GENERAL PARA OFICINAS'){
                    if(String.isBlank(accion.SAC_Oficina__c)){
                        AuraHandledException e = new AuraHandledException('Existen tarea/s "GENERAL PARA OFICINAS" sin una oficina informada.  Revíselo antes de continuar.');
                        e.setMessage('Existen tarea/s "GENERAL PARA OFICINAS" sin una oficina informada.  Revíselo antes de continuar.');
                        throw e;
                    }
                    if(String.isBlank(accion.SAC_Oficina__r.CC_Email__c)) {  
                        AuraHandledException e = new AuraHandledException('Existen tarea/s "GENERAL PARA OFICINAS" sin que la oficina tenga un email informado.  Revíselo antes de continuar.');
                        e.setMessage('Existen tarea/s "GENERAL PARA OFICINAS" sin que la oficina tenga un email informado.  Revíselo antes de continuar.');
                        throw e;
                    }
                    if(String.isBlank(accion.SAC_Comentarios__c)){
                        AuraHandledException e = new AuraHandledException('Existen tarea/s "GENERAL PARA OFICINAS" sin detallar un comentario. Revíselo antes de continuar.');
                        e.setMessage('Existen tarea/s "GENERAL PARA OFICINAS" sin detallar un comentario. Revíselo antes de continuar.');
                        throw e;
                    }
                    listaTareasOficina.add(accion);
                }
            }                  

            if(accion.SAC_MaestroAccionesReclamacion__r.Name != 'GENERAL PARA OFICINAS'){
                listaTareas.add(accion);
            }
        }

        if(!listaTareas.isEmpty()){
            mapTareas.put(false, listaTareas);
        }

        if(!listaTareasOficina.isEmpty()){
            mapTareas.put(true, listaTareasOficina);
        }
        DateTime dt = DateTime.now();
        Long dateInMilliseconds = dt.getTime();
        AsyncOptions options = new AsyncOptions();
        options.DuplicateSignature = QueueableDuplicateSignature.Builder().addId(UserInfo.getUserId()).addString(String.valueOf(dateInMilliseconds)).build();
        try {
            System.enqueueJob(new SAC_QueueableEnvioEmail(mapTareas, numCaso), options);    
        } catch (DuplicateMessageException ex) {  CBK_Log.error(ex);                 }    

        SAC_DatabaseDML.updateListDML(acciones, false);
        SAC_DatabaseDML.upsertListDML(tmesTareas, false);

    }


    @AuraEnabled
    public static ContentDocumentLink getDocument(String idCaso, List<string> idDoc){

        try {

         
            ContentDocumentLink cdl = new ContentDocumentLink();
            if(!idDoc.isEmpty()){
                
                ContentVersion cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE SAC_StringRedaccion_fileupload__c = 'ResolucionRedaccion' AND FirstPublishLocationId =: idCaso AND Id IN : idDoc];  
                List<ContentDocumentLink> listaSelect = new List<ContentDocumentLink>();

                listaSelect = [SELECT Id, LinkedEntityId, ContentDocumentId, Visibility, IsDeleted, ShareType,
                                                    ContentDocument.Title, ContentDocument.createdDate, ContentDocument.FileType
                                                    FROM ContentDocumentLink 
                                                    WHERE LinkedEntityId = :idCaso AND ContentDocumentId =: cv.ContentDocumentId
                                                    AND ContentDocument.LatestPublishedVersion.SAC_StringRedaccion_fileupload__c = 'ResolucionRedaccion' ];

                if(!listaSelect.isEmpty()){
                    cdl = listaSelect[0];
                }
    
            }else{
            
                List<ContentDocumentLink> listaSelect = new List<ContentDocumentLink>();
            
                listaSelect = [SELECT Id, LinkedEntityId, ContentDocumentId, Visibility, IsDeleted, ShareType,
                ContentDocument.Title, ContentDocument.createdDate, ContentDocument.FileType
                FROM ContentDocumentLink 
                WHERE LinkedEntityId = :idCaso
                AND ContentDocument.LatestPublishedVersion.SAC_StringRedaccion_fileupload__c = 'ResolucionRedaccion' ORDER BY  ContentDocument.LastModifiedDate LIMIT 1 ];
             
         
                if(!listaSelect.isEmpty()){
                    cdl = listaSelect[0];
                }

            }               
            return cdl;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
            
        }
    }

    @AuraEnabled
    public static List<plantillasWrapper> getPickListValuesIntoList(){
    /*****************************************************************
    * Proposito: Obtener los valores del picklist para mostrarlos por pantalla
    *
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US248482         Luis Mesa      04/08/21     Creación
    *****************************************************************/ 
        List<plantillasWrapper> pickListValuesList= new List<plantillasWrapper>();
         Schema.DescribeFieldResult fieldResult = Case.SAC_SentidoResolucion__c.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         for( Schema.PicklistEntry pickListVal : ple){
            plantillasWrapper wrapper = new plantillasWrapper(pickListVal.getValue(), pickListVal.getLabel());
            pickListValuesList.add(wrapper);
         }
         return pickListValuesList;
     }
     @AuraEnabled
     public static List<plantillasWrapper> getPickListMotivoInadmision(){
         List<plantillasWrapper> pickListValuesList= new List<plantillasWrapper>();
          Schema.DescribeFieldResult fieldResult = Case.SAC_MotivoInadmision__c.getDescribe();
          List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
          for( Schema.PicklistEntry pickListVal : ple){
             plantillasWrapper wrapper = new plantillasWrapper(pickListVal.getValue(), pickListVal.getLabel());
             pickListValuesList.add(wrapper);
          }
          return pickListValuesList;
      }

     public class PlantillasWrapper{

        @AuraEnabled public String idPlantilla{get; set;}
        @AuraEnabled public String nombrePlantilla{get; set;}   
        
        public plantillasWrapper(String id, String nombre){
            idPlantilla = id;
            nombrePlantilla = nombre;
        }
    }

    @AuraEnabled
    public static DatosEmailWrapper obtenerDatosEmail(String idCaso, Boolean soloEmail){
        
        try { 
            List<String> body = new List<String>();
            Case caso = [SELECT Id, SAC_DireccionPostalNotificacion__c, AccountId, Account.RecordTypeId, OS_Email__c, Origin, CC_Canal_Respuesta__c, 
                        Account.CC_Email__c, SAC_DireccionPostal__c, RecordTypeId, SuppliedEmail, SAC_MotivoInadmision__c, CaseNumber, Subject, Status, 
                        OwnerId, CC_Idioma__c, SAC_OrigenConsulta__c, CC_No_Identificado__c, recordType.Name, SAC_Reclamacion__r.OS_Email__c
                        FROM Case WHERE id =: idCaso LIMIT 1];
            EmailTemplate et = null;

            
            if(caso.RecordTypeId == RECTYPERECLAMACION && String.isBlank(caso.SAC_MotivoInadmision__c)){
                et =[SELECT Id, Body, HtmlValue FROM EmailTemplate WHERE Name = 'SAC_Redaccion' LIMIT 1]; 
            }else  if(caso.RecordTypeId == RECTYPERECLAMACION){
                id idPlantilla = obtenerPlantilla('SAC_Inadmision', caso.CC_Idioma__c);
                et=[SELECT Id, Body, HtmlValue FROM EmailTemplate WHERE id =:idPlantilla]; 
            }else  if(caso.RecordTypeId == RECTYPECONSULTA && soloEmail == false){
                et=[SELECT Id, Body, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'SAC_Consultas_COPS']; 
                
            }else {
                et=[SELECT Id, Body, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'SAC_PlantillaSAC']; 
                
                
                

            }             
             
            ContentDocument[] documentos = null;
            
            body.add(et.HtmlValue);
            String whoId = UserInfo.getUserId();
            String whatId = caso.Id;
            String stringFinal = '';

            Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(et.Id, whoId, idCaso);              
  
            String para = '';
            if(String.isNotBlank(caso.AccountId)){
                para = SAC_SeleccionDireccionRespuesta.getParaEmail(caso, caso.Account.RecordTypeId);
            }
            if(caso.RecordTypeId == RECTYPERECLAMACION || caso.RecordTypeId == RECTYPECONSULTASAC){ 
                if(soloEmail){
                    return new DatosEmailWrapper(caso.OS_Email__c, renderStored.getSubject(), renderStored.getHtmlBody(), '', caso, documentos);

                }
                if(String.isBlank(para)){
                    return new DatosEmailWrapper(caso.OS_Email__c, renderStored.getSubject(), renderStored.getHtmlBody(), '', caso, documentos);

                }
                else{
                    return new DatosEmailWrapper(para, renderStored.getSubject(), renderStored.getHtmlBody(), '', caso, documentos);

                }
            }else if(caso.RecordTypeId == RECTYPECONSULTA){
                if(soloEmail){
                    return new DatosEmailWrapper(caso.SuppliedEmail, renderStored.getSubject(), renderStored.getHtmlBody(), '', caso, documentos);

                } 
                if(String.isBlank(para)){
                    return new DatosEmailWrapper(caso.SuppliedEmail, renderStored.getSubject(), renderStored.getHtmlBody(), '', caso, documentos);

                }
                else{
                    return new DatosEmailWrapper(para, renderStored.getSubject(), renderStored.getHtmlBody(), '', caso, documentos);

                }
            }else{
                if(soloEmail){
                    return new DatosEmailWrapper(caso.SAC_Reclamacion__r.OS_Email__c, renderStored.getSubject(), renderStored.getHtmlBody(), '', caso, documentos);

                }
                if(String.isBlank(para)){
                    return new DatosEmailWrapper(caso.SAC_Reclamacion__r.OS_Email__c, renderStored.getSubject(), renderStored.getHtmlBody(), '', caso, documentos);

                }
                else{
                    return new DatosEmailWrapper(para, renderStored.getSubject(), renderStored.getHtmlBody(), '', caso, documentos);

                }
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class DatosEmailWrapper{
        /*****************************************************************
         * Name: DatosEmailWrapper
         * Copyright © 2021  CaixaBank
         *
         * Proposito: Clase Wrapper para mandar contenido formateado del controlador Apex al controlador JS para el correcto funcionamiento
         *  del componente aura SAC_EmailRedaccion.
         *
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR         DATE         Description
         * 1.0                     Luis Mesa     04/10/21      Creación Clase
        *****************************************************************/
    
        @AuraEnabled public String para {get; set;}
        @AuraEnabled public String asunto {get; set;}
        @AuraEnabled public String cuerpo {get; set;}
        @AuraEnabled public String copia {get; set;}
        @AuraEnabled public Case caso {get; set;}
        @AuraEnabled public ContentDocument[] adjuntos {get; set;}
        
        public DatosEmailWrapper(String paraM, String asuntoM, String cuerpoM, String copiaM, Case casoM, ContentDocument[] adjuntosM)
        {
        /*****************************************************************
         * Proposito: Método constructor de la clase Wrapper
         *
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR         DATE         Description
         * 1.0                     Luis Mesa    04/10/21       Creación Método
        *****************************************************************/
            para = paraM;
            asunto = asuntoM;     
            cuerpo = cuerpoM;   
            copia = copiaM;
            caso = casoM;
            adjuntos = adjuntosM;
        }
        
    }
    public class Validaciones{
    /*****************************************************************
     * Name: Validaciones
     * Copyright © 2021  CaixaBank
     *
     * Proposito: Clase Wrapper para comprobar todas las validaciones a la hora de efectuar la redaccion final. (Pretensiones y Escalados)
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0                            Luis Mesa     04/10/21      Creación Clase
    *****************************************************************/
        @AuraEnabled public Boolean pretension {get; set;}

        public Validaciones(Boolean pretensionM){
            pretension = pretensionM;
        }
    }

    @AuraEnabled
    public static Validaciones validacionRedaccion(String idCaso){
        if(!Schema.sObjectType.Case.isAccessible()){
            throw new AuraHandledException( 'Fallo al recuperar el caso.' );
        }

        List<Case> pretensiones = [SELECT Id, SuppliedCompany, SAC_Reclamacion__c, SAC_RedaccionFinal__c FROM Case WHERE RecordTypeId = :RECTYPEPRETENSION AND SAC_Reclamacion__c =: idCaso AND Status != 'SAC_009'];
        Boolean valPretension = true;
        if(!pretensiones.isEmpty()){
            for(Case pretension : pretensiones){
                if(!pretension.SAC_RedaccionFinal__c){
                    valPretension = false;
                }
            }
        }
        //Añadido US690907
        List<ContentVersion> listaCV = clasificarTipoAdjunto(idCaso);
        if (!listaCV.isEmpty() && String.isNotBlank(listaCV[0].SAC_TipoAdjunto__c)) {
            SAC_DatabaseDML.updateListDML(listaCV, false);
        }
        //Fin añadido US690907

        if(!Schema.sObjectType.SAC_Interaccion__c.isAccessible()){
            throw new AuraHandledException( 'Fallo al recuperar los escalados.');
        }
        Validaciones validacion = new Validaciones(valPretension);
        return validacion;
    }

    @AuraEnabled
    public static void borraDocumento(String idCaso){
        List<ContentVersion> contentVersions = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE SAC_StringRedaccion_fileupload__c = 'ResolucionRedaccion' AND FirstPublishLocationId =: idCaso];
        List<Id> ids = new List<Id>();
        for(ContentVersion cv : contentVersions){
            ids.add(cv.ContentDocumentId);
        }
        List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE Id IN: ids];
        SAC_DatabaseDML.deleteListDML(contentDocuments, false);
    }
	
    /*****************************************************************
         * Proposito: Obtener el Id de los Emailtemplates dependiendo del tipo
         *              de plantilla y el idioma
         *
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR         DATE         Description
         * 1.0             US271700      Marcela Neira    12/11/21       Creación Método
        *****************************************************************/
    public static Id obtenerPlantilla(String tipo, String idioma){
        Id idPlantilla;

        switch on idioma {
            when 'es' {	 
                idPlantilla = [SELECT id, SAC_PlantillaCastellanoId__c FROM SAC_PlantillaRedaccion__c WHERE  SAC_TipoPlantilla__c =:tipo LIMIT 1 ].SAC_PlantillaCastellanoId__c;   
            }	
            when 'ca' {	 
                idPlantilla = [SELECT id, SAC_PlantillaCatalanId__c FROM SAC_PlantillaRedaccion__c WHERE  SAC_TipoPlantilla__c =:tipo LIMIT 1].SAC_PlantillaCatalanId__c;     
            }
            when 'en' {	
                idPlantilla = [SELECT id, SAC_PlantillaInglesId__c FROM SAC_PlantillaRedaccion__c WHERE  SAC_TipoPlantilla__c =:tipo LIMIT 1].SAC_PlantillaInglesId__c;     
            }
            when 'va' {	
                idPlantilla = [SELECT id, SAC_PlantillaValencianoId__c FROM SAC_PlantillaRedaccion__c WHERE  SAC_TipoPlantilla__c =:tipo LIMIT 1].SAC_PlantillaValencianoId__c;     
            }
            when 'eu' {	
                idPlantilla = [SELECT id, SAC_PlantillaEuskeraId__c FROM SAC_PlantillaRedaccion__c WHERE  SAC_TipoPlantilla__c =:tipo LIMIT 1].SAC_PlantillaEuskeraId__c;     
            }
            when 'ga' {	
                idPlantilla = [SELECT id, SAC_PlantillaGallegoId__c FROM SAC_PlantillaRedaccion__c WHERE  SAC_TipoPlantilla__c =:tipo LIMIT 1].SAC_PlantillaGallegoId__c;     
            }
            when else {	
                idPlantilla = [SELECT id, SAC_PlantillaCastellanoId__c FROM SAC_PlantillaRedaccion__c WHERE  SAC_TipoPlantilla__c =:tipo LIMIT 1].SAC_PlantillaCastellanoId__c;
            }
        }
        return idPlantilla;
    }
    @AuraEnabled
    public static void finalizarRedaccionCartaPostal(String idCaso){
        try {
            finalizarRedaccion(idCaso, true, false);
        }  catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static ObjWrapper validacionEscalado(String idCaso) {

        Boolean validacionLlamada = true;
        List<Case> pretensiones = [SELECT Id, SAC_AcompanyaLlamada__c, SEG_Detalle__r.SAC_AcompanyaLlamada__c FROM Case WHERE RecordTypeId =: RECTYPEPRETENSION AND SAC_Reclamacion__c =: idCaso AND Status != 'SAC_009'];
        Integer numPretConMcc = 0;
        Integer numLlamadas = 0;
        for(Case pretension : pretensiones){
            if(pretension.SEG_Detalle__r.SAC_AcompanyaLlamada__c){
                numPretConMcc ++;
                if(String.isNotBlank(String.valueOf(pretension.SAC_AcompanyaLlamada__c))){
                   numLlamadas ++;
                }
            }
        }

        if(numLlamadas == 0 && numPretConMcc != 0){
            validacionLlamada=false;
        }

        ObjWrapper res = new ObjWrapper(validacionLlamada, SAC_Interaccion.validacionesEscalados(idCaso));
        return res;
    }


    /*****************************************************************
     * Proposito: Comprobar desde donde se carga el componente (mediante el record type) para mostrar unas opciones y otras
     *  
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US518130         Raúl Santos    25/01/2023   Creación
    *****************************************************************/
    @AuraEnabled
    public static Boolean comprobrarRecordType(String idCaso){

        Case caso = [SELECT Id, RecordTypeId FROM Case WHERE id =: idCaso LIMIT 1]; 

        if(caso.RecordTypeId == RECTYPERECLAMACION || caso.RecordTypeId == RECTYPEPRETENSION){ 
            return true; 
        }else{
            return false;
        } 
    }

    /***************************************************************** 
     * Proposito: Recuperar los grupos buscados dependiendo si necesitamos los grupos proveedores que permiten derivación o los que permiten
     * consultas. Retornando estos en una lista para ser mostrados
     *  
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US518130         Raúl Santos    25/01/2023   Creación
    *****************************************************************/
    @AuraEnabled
    public static List<CC_Grupo_Colaborador__c> buscarGrupos(String derivacionOconsulta){  

        List<CC_Grupo_Colaborador__c> listagrupos = new List<CC_Grupo_Colaborador__c>();

        if(derivacionOconsulta == 'derivar'){
            listagrupos = [SELECT Id, Name, SAC_PlantillaReclamacion__c, SAC_PlantillaConsulta__c, SAC_PlantillaReclamante__c, SAC_Email__c, SAC_Email2__c, SAC_Email3__c FROM CC_Grupo_Colaborador__c WHERE RecordType.DeveloperName = 'SAC_GrupoProveedores'
                        AND SAC_PermiteDerivacion__c = true ORDER BY Name ASC];
        }

        if(derivacionOconsulta == 'consulta'){
            listagrupos = [SELECT Id, Name, SAC_PlantillaReclamacion__c, SAC_PlantillaConsulta__c, SAC_PlantillaReclamante__c, SAC_Email__c, SAC_Email2__c, SAC_Email3__c FROM CC_Grupo_Colaborador__c WHERE SAC_PermiteConsultas__c = true ORDER BY Name ASC]; /* RecordType.DeveloperName = 'SAC_GrupoProveedores' AND */
        }
        
        return listagrupos; 
    }


    /***************************************************************** 
     * Proposito: Recuperar las pretensiones del caso 
     *  
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR           DATE         Description
     * 1.0            US392178      Sergio Martín    04/07/2023       Creación
    *****************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<Case> getPretensiones(String idCaso){
        List<Case> pretensionesCaso = new List<Case>();
        try {
            pretensionesCaso = [SELECT Id, CC_MCC_Tematica__r.name, CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__r.name, SEG_Detalle__r.Name FROM Case 
                                WHERE SAC_Reclamacion__c =: idCaso AND Status <> 'SAC_009' AND SAC_SentidoResolucion__c IN ('SAC_002','SAC_003')];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return pretensionesCaso;
    }


    /*****************************************************************
    * Proposito: Finalizar la redacción de la reclamación y entrar en la fase de negociación.
    *
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US392178      Sergio Martín    04/07/2023       Creación
    *****************************************************************/ 
    @AuraEnabled
    public static void finalizarRedaccionNegociacion(String idCaso, Boolean envioMail, List<Case> pretensionesNegociacion, Boolean sinEnvio){
        if(!Schema.sObjectType.Case.isAccessible() || !Schema.sObjectType.SAC_Accion__c.isAccessible() || !Schema.sObjectType.SAC_Accion__c.isUpdateable() || !Schema.sObjectType.Case.isUpdateable()){
            throw new AuraHandledException('No tienes privilegios para manipular la redacción.');
        }
        Map<Id, Case> pretensionesNegociacionMap = new Map<Id, Case>(pretensionesNegociacion);

        Case reclamacion = [SELECT Id, OS_Fecha_Resolucion__c, Status, SAC_Redaccion__c, OS_Email__c, CaseNumber, AccountId , CC_No_Identificado__c, SAC_SinEnvioComunicacion__c
                            FROM Case WHERE RecordTypeId =: RECTYPERECLAMACION AND Id =: idCaso];
                            
        if(reclamacion.AccountId != null || reclamacion.CC_No_Identificado__c == true){
            List<Case> pretensiones = [SELECT Id, Status FROM Case WHERE RecordTypeId =: RECTYPEPRETENSION AND SAC_Reclamacion__c =: reclamacion.Id];

            for(Case pretension : pretensiones){
                if(pretensionesNegociacionMap.containsKey(pretension.id)) {
                    pretension.Status = 'SAC_007';
                    pretension.SAC_StatusAuxiliar__c = 'SAC_007';
                } else if(pretension.Status != 'Cerrado' && pretension.Status != 'SAC_009') {
                    pretension.Status = 'Cerrado';
                    pretension.SAC_StatusAuxiliar__c = 'Cerrado';
                }
            }
            List<Case> listaCasosUpdatear = new List<Case>();
            if(sinEnvio){
                reclamacion.SAC_SinEnvioComunicacion__c = true;
                listaCasosUpdatear.add(reclamacion);
            }
            listaCasosUpdatear.addAll(pretensiones);
            SAC_DatabaseDML.updateListDML(listaCasosUpdatear, false);

        }else{
            throw new AuraHandledException('Para resolver es necesario informar el cliente.');
        }
    }

    /*****************************************************************
    * Proposito: Metodo para comprobar si en el momento de la redacción una reclamación tiene el SLA Regulatorio sobrepasado.
    *
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0             US352171      Raúl Santos    18/07/23        Creación
    *****************************************************************/ 
    @AuraEnabled
    public static Boolean comprobarSLARegulatorio(String idCaso){   

        Boolean slaSuperado = false;

        CaseMilestone milestoneData = [SELECT Id,MilestoneType.Name, TargetDate FROM CaseMilestone WHERE CaseId = :idCaso AND MilestoneType.Name = 'SLA Regulatorio'];

        if(milestoneData.TargetDate < System.now()){
            slaSuperado = true;
        }

        return slaSuperado;
    }

    /*****************************************************************
    * Proposito: Recuperar del maestro de temas los registros con record type SAC_MotivoDemora
    *
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0             US352171      Raúl Santos    18/07/23        Creación    
    *****************************************************************/ 
    @AuraEnabled
    public static  List<SAC_MaestroTemas__c> getMotivosDemora(){  

        List<SAC_MaestroTemas__c> listMotivosDemora = [SELECT Name FROM SAC_MaestroTemas__c WHERE RecordTypeId =:RECTYPEMOTIVOSDEMORA AND SAC_Activo__c = true ORDER BY Name ASC];

        return listMotivosDemora;
    }

    /*****************************************************************
    * Proposito: Actualizar en la reclamación los campos de motivo demora y comentarios sobre esta cuando son informados.
    *
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0             US352171      Raúl Santos    18/07/23        Creación              
    *****************************************************************/ 
    @AuraEnabled
    public static void actualizarMotivosDemora(String idCaso, List<String> motivoDemora, String comentarioDemora){  
        
        String cadenaMotivos = String.join(motivoDemora, ', ');

        Case casoActual = [SELECT Id FROM Case WHERE Id = :idCaso AND RecordTypeId =:RECTYPERECLAMACION LIMIT 1];
        casoActual.SAC_MotivoDemora__c = cadenaMotivos;
        casoActual.SAC_ComentarioDemora__c = comentarioDemora;

        SAC_DatabaseDML.updateDML(casoActual, false);
    }
    
    /*****************************************************************
    * Proposito: comprobar si la reclamación tiene contratos asociados a sus pretensiones
    *
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0             US662816      Raúl Santos    18/07/23        Creación     
    * 1.1             US1091686      Iria ANPC     23/12/24        Todas las pretensiones deben tener al menos un producto              
    *****************************************************************/ 
    @AuraEnabled
    public static Boolean getContratoPretension(String idCaso){  
        Boolean withoutProduct = false;
        Map<Id, SAC_ProductCase__c> mapPretensionProduct = new Map<Id, SAC_ProductCase__c>();
        List<Case> pretensiones = [SELECT Id FROM Case WHERE SAC_Reclamacion__c =: idCaso AND Status != 'SAC_009'];
        List<SAC_ProductCase__c> productos = [SELECT Id, SAC_Pretension__c FROM SAC_ProductCase__c WHERE SAC_Pretension__r.SAC_Reclamacion__c = :idCaso];
        for(SAC_ProductCase__c producto :productos){
            mapPretensionProduct.put(producto.SAC_Pretension__c, producto);
        }
        for(Case pretension :pretensiones){
            if(!mapPretensionProduct.containsKey(pretension.Id)){
                withoutProduct = true;
            }
        }
        return withoutProduct;
    }

    /*****************************************************************
     * Proposito: Comprueba si en una determinada reclamación se he enviado comunicación al cliente en la redacción
     *  
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US865650      Raúl Santos    26/04/24        Creación
    *****************************************************************/
    @AuraEnabled
    public static Boolean comprobarComunicacionRedaccionCliente(String id, String metodoEnvio){

        Boolean comunicacionEnviada = false;

        if(metodoEnvio == 'Email'){
            List<EmailMessage>  listEM = [SELECT id FROM EmailMessage WHERE ParentId = :id AND SAC_EnvioRedaccion__c = 'primerenvioredaccion' ORDER BY CreatedDate DESC LIMIT 1];

            comunicacionEnviada = !listEM.isEmpty() ? true : false;
            
        }else if(metodoEnvio == 'SAC_CartaPostal'){
            List<SAC_DocumentoEnvio__c> docGuardado = [SELECT Id FROM SAC_DocumentoEnvio__c WHERE SAC_Caso__c = :id AND SAC_TipoDocumento__c = 'redacción' ORDER by createdDate desc LIMIT 1];

            comunicacionEnviada = !docGuardado.isEmpty() ? true : false;
        }

        return comunicacionEnviada;
    }

    /*****************************************************************
     * Proposito: Método para recuperar el adjunto recien insertado en la fase 1 de la resolución
     * y añadirle el tipo de adjunto 'Resolución' en caso de que exista.
     *  
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US690907         CS             31/10/2023   Creación
    *****************************************************************/
    public static List<ContentVersion> clasificarTipoAdjunto(String idCaso) {
        List<ContentVersion> listaCV = new List<ContentVersion>();
        listaCV = [SELECT Id FROM ContentVersion WHERE SAC_StringRedaccion_fileupload__c = 'ResolucionRedaccion' AND FirstPublishLocationId = : idCaso ORDER BY createdDate DESC LIMIT 1];
        
        //Si se encuentra el fichero de redacción, claisifcarlo con su tipo adjunto
        if (!listaCV.isEmpty()) {
            List<SAC_MaestroTemas__c> maestroTema = [SELECT Id FROM SAC_MaestroTemas__c WHERE RecordTypeId = :RECTYPETIPOADJUNTOS AND SAC_DeveloperName__c = 'RESOLUCION' LIMIT 1];
            if (!maestroTema.isEmpty()) {
                listaCV[0].SAC_TipoAdjunto__c = maestroTema[0].Id;
                listaCV[0].SAC_Bloque__c = 'SAC_Respuesta';
            }
        }
        return listaCV;
    }


    public class ObjWrapper{

        @AuraEnabled public Boolean validacionLlamada{get; set;} 
        @AuraEnabled public SAC_Interaccion.ValidacionesEscalado validacionesEscalados{get; set;}
        
        public ObjWrapper(Boolean validacionLlamadaM, SAC_Interaccion.ValidacionesEscalado validacionesEscaladosM){
            this.validacionLlamada = validacionLlamadaM;
            this.validacionesEscalados = validacionesEscaladosM;
        }
    }

    /*****************************************************************
     * Proposito: Comprueba si existe un documento de envio en el caso que sea de Redacción
     *  
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US783324        Carlos       19/02/24         Creación
    *****************************************************************/
    @AuraEnabled
    public static Boolean compruebaDocumentoRedaccion(String id){

        List<SAC_DocumentoEnvio__c> docGuardado = [SELECT Id, SAC_Cuerpo__c, SAC_Header__c, SAC_Footer__c
                                                    FROM SAC_DocumentoEnvio__c
                                                    WHERE SAC_Caso__c = :id
                                                    AND SAC_TipoDocumento__c = 'redaccion' ORDER by createdDate desc LIMIT 1];

        return !docGuardado.isEmpty() ? true : false;
    }

    /*****************************************************************
    * Proposito: Obtener los ContentVersion clasificados en el bloque de Respuuestas y validados
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0                            Carlos Gómez    15/07/24     Creación
    *****************************************************************/ 
    @AuraEnabled
    public static List<ContentVersion> getCVRespuestas(Id recordId) {
        // Fetch ContentVersion records related to the given record ID
        List <ContentVersion> listaFicheros = [SELECT Id, Title FROM ContentVersion WHERE SAC_ValidadoCV__c = true AND FirstPublishLocationId =: recordId ];
        return listaFicheros;
    }


    /***********************************************************************************************************
    * Proposito: Validar si se permite resolver una reclamación complementaria en función de su sentido de resolución y de 
    *   si tiene una reclamación vinculada
    *
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0             US1094159      Álex Polo     21/01/25        Creación
    ***********************************************************************************************************/ 
    @AuraEnabled
    public static Boolean validarResolucionComplementaria(Id idCaso) {

        Case reclamacion = new Case();
        List<Case> listaCasos = [SELECT Id, SAC_Naturaleza__c, SAC_SentidoResolucion__c, CC_CasoRelacionado__c FROM Case WHERE Id = :idCaso];

        if(!listaCasos.isEmpty()){
            reclamacion = listaCasos[0];
            if(reclamacion.SAC_Naturaleza__c == 'SAC_007' && reclamacion.SAC_SentidoResolucion__c != 'SAC_004' && reclamacion.CC_CasoRelacionado__c == null){
                return false;   //Si es complementaria, y el sentido resolución no es inadmisión y no tiene una reclamación vinculada, no se puede resolver
            }else{
                return true;        
            }

        }else{
            return false;
        }



    }



 
}