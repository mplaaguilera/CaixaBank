public with sharing class SAC_LCMP_EnvioResolucionCorreoPostal {
    //Test class: SAC_EnvioResolucionCorreoPostal_Test

    private static Set<String> objetos = new Set<String>{'SAC_MaestroTemas__c', 'SAC_MaestroAccionesReclamacion__c', 'SAC_Accion__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private static final Id RECORDTYPEBLACKLIST = mapRTsObjects.get('SAC_MaestroTemas__c').get('SAC_BlackListEmails').getRecordTypeId();

    private static final Id RECTYPERECLAMACION = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
    private static final Id RECTYPEMAESTROACCIONESREC = mapRTsObjects.get('SAC_MaestroAccionesReclamacion__c').get('SAC_MaestroAcciones').getRecordTypeId();
    private static final Id RECTYPEMAESTROTAREAS = mapRTsObjects.get('SAC_Accion__c').get('SAC_MaestroDeTareas').getRecordTypeId();

    
    @AuraEnabled
    public static WrappedInfoCartas buscaCartaPrevia(Id caseId, String tipoCarta) {
        Id idCarta;
        
        if(!Schema.sObjectType.SAC_DocumentoEnvio__c.isAccessible()){ throw new AuraHandledException( 'Fallo al recuperar el documento de envio.' ); }
        List<SAC_DocumentoEnvio__c> carta = [SELECT id, SAC_CP__c, SAC_Direccion__c, SAC_Pais__c, SAC_Poblacion__c, SAC_Provincia__c, SAC_Cuerpo__c FROM SAC_DocumentoEnvio__c WHERE  SAC_Caso__c =:caseId  AND SAC_TipoDocumento__c =:tipoCarta LIMIT 1];
        if(!Schema.sObjectType.Case.isAccessible()){ throw new AuraHandledException( 'Fallo al recuperar el caso.' ); }
        Case caso = [SELECT SAC_DireccionContacto__c, SAC_CodigoPostalContacto__c, SAC_PoblacionContacto__c, SAC_ProvinciaContacto__c, SAC_PaisContacto__c, SAC_NombreContacto__c FROM Case WHERE Id =: caseId LIMIT 1];

        //Recuperar el ContentDocumentLink
        List<ContentDocumentLink> cdL = [SELECT Id, ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId =: caseId AND ContentDocument.FileType != 'SNOTE']; 

        Set<Id> idsDocumentLink = new Set<Id>();
        for(ContentDocumentLink recordCdL : cdL){
            idsDocumentLink.add(recordCdL.ContentDocumentId);
        }

        if(!Schema.sObjectType.ContentVersion.isAccessible()){ throw new AuraHandledException( 'Fallo al recuperar el content version.' ); }
        List<ContentVersion> cv = [SELECT Id, VersionData, ContentDocumentId FROM ContentVersion WHERE SAC_StringRedaccion_fileupload__c = 'ResolucionRedaccion' AND ContentDocumentId IN: idsDocumentLink LIMIT 1];

        // if(!Schema.sObjectType.ContentDocument.isAccessible()){ throw new AuraHandledException( 'Fallo al recuperar el content document.' ); }
        // List<ContentDocument> cd = [SELECT Id, Title FROM ContentDocument WHERE Id =: cv[0].ContentDocumentId LIMIT 1];

        List<plantillasWrapper> paises = getPickListValuesIntoList();

        if(carta.isEmpty()){
            WrappedInfoCartas myInfo = new WrappedInfoCartas('', caso.SAC_DireccionContacto__c, caso.SAC_CodigoPostalContacto__c, caso.SAC_PoblacionContacto__c, caso.SAC_ProvinciaContacto__c, '', cv[0].ContentDocumentId, cv[0], paises);
            return myInfo;
        }
        else{
            WrappedInfoCartas myInfo = new WrappedInfoCartas(carta[0].Id, carta[0].SAC_Direccion__c, carta[0].SAC_CP__c, carta[0].SAC_Poblacion__c, carta[0].SAC_Provincia__c, carta[0].SAC_Pais__c, cv[0].ContentDocumentId, cv[0], paises);    
            return myInfo;
        }        
    }

    @AuraEnabled
    public static List<plantillasWrapper> getPickListValuesIntoList(){
        List<plantillasWrapper> pickListValuesList= new List<plantillasWrapper>();
         Schema.DescribeFieldResult fieldResult = SAC_DocumentoEnvio__c.SAC_Pais__c.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         for( Schema.PicklistEntry pickListVal : ple){
            plantillasWrapper wrapper = new plantillasWrapper(pickListVal.getValue(), pickListVal.getLabel());
            pickListValuesList.add(wrapper);
         }
         return pickListValuesList;
     }

    
    //Modificación: US723742 - Raúl Santos - 05/03/2024 - Añadir lógica envio emails blackList
    @AuraEnabled
    public static String finalizarRedaccionCartaPostal(String caseId, String para, String copia, String copiaOculta, String cuerpo, String asunto, String idAdjuntos) {

        Case casoActual = [SELECT Id, SAC_FechaVencimientoSLA__c, SAC_MotivoDemora__c, SAC_ComentarioDemora__c, SuppliedEmail, Origin, CC_Canal_Respuesta__c, CC_Idioma__c FROM Case WHERE Id = :caseId AND RecordTypeId = :RECTYPERECLAMACION LIMIT 1];
        String emailsInvalidos = '';

        //Añadido comprobar el target date del caseMilestone en lugar del campo SAC_FechaVencimientoSLA__c del caso
        List<CaseMilestone> listaCM = [SELECT Id, TargetDate FROM CaseMilestone WHERE CaseId = :caseId AND MilestoneType.Name = 'SLA Regulatorio'];
        if(/*casoActual.SAC_FechaVencimientoSLA__c*/!listaCM.isEmpty() && listaCM[0].TargetDate != null && listaCM[0].TargetDate < System.now() && casoActual.SAC_MotivoDemora__c == null){
            throw new AuraHandledException( 'El SLA Regulatorio esta sobrepasado, debe informar los motivos de la demora mediante el botón "Resolver Reclamación" antes de continuar.' );
        }else{
            //Recupero los emails no validos de envio (emails en la blackList)
            List<SAC_MaestroTemas__c> listEmailsNoValidos = [SELECT Name FROM SAC_MaestroTemas__c WHERE RecordTypeId =: RECORDTYPEBLACKLIST AND SAC_Activo__c = true];
            if(String.isNotBlank(para)){
                //Compruebo la dirección de envio con las de la blackList
                String emailsNoValidosEncontrados = SAC_Utils.comprobarEmailsBlackList(listEmailsNoValidos, para, '', '');

                //Si la dirección de envio es válida (no está en la blackList), continuo el proceso
                if(emailsNoValidosEncontrados == ''){
                    SAC_LCMP_GestionEmails.enviarEmail(caseId, para, copia, copiaOculta, cuerpo, asunto, idAdjuntos, '');
                }else{
                    //Sino, devuelvo una cadena con los emails no válidos para informar al usuario
                    emailsInvalidos = emailsNoValidosEncontrados;
                }
                
            }
            // Si el canal de entrada es email, en TF9 no tiene email y el canal de respuesta es Carta postal se tiene que enviar un email indicando que se ha enviado la resolución del caso
            if(String.isNotBlank(casoActual.SuppliedEmail) && casoActual.Origin == 'Email' && casoActual.CC_Canal_Respuesta__c == 'SAC_CartaPostal') {  
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
                    //Compruebo la dirección de envio con las de la blackList
                    List<String> listaDireccionesPara = new List<String>{ casoActual.SuppliedEmail };
                    List<String> emailsValidos = SAC_Utils.comprobarEmailsBlackListAuto(listEmailsNoValidos, listaDireccionesPara);

                    //Si la dirección de envio es válida (no está en la blackList), continuo el proceso
                    if(!emailsValidos.isEmpty()){
                        comunicarResolucion(casoActual);
                    }
                }
            }

            SAC_LCMP_EnvioResolucionCorreoPostal.generarTareaAutomaticaRedaccionPostal(caseId, idAdjuntos);
            SAC_LCMP_RedaccionFinal.finalizarRedaccionCartaPostal(caseId);
    
            FeedItem post = new FeedItem();
            post.ParentId = caseId;
            post.Body = 'Envío redacción final carta postal';
            post.Title = 'Fin Redacción';
            if (!Schema.sObjectType.FeedItem.isCreateable()) { throw new AuraHandledException( 'No tienes permisos para realizar esta accion, no puede insertar el FeedItem.' ); }
            SAC_DatabaseDML.insertDML(post, false);
            //Database.insert(post);
        }    
        
        return emailsInvalidos;
    }


    /**
    * Proposito: Envio Comunicación Resolución Mail
    */
    public static void comunicarResolucion(Case casoActual){
        List<String> body = new List<String>();
        Id idPlantillaAviso = null;
        List<SAC_PlantillaRedaccion__c> lstPlantillas = [SELECT Id, SAC_PlantillaCatalanId__c, SAC_PlantillaCastellanoId__c, SAC_PlantillaInglesId__c, SAC_PlantillaEuskeraId__c, SAC_PlantillaGallegoId__c, SAC_PlantillaValencianoId__c FROM SAC_PlantillaRedaccion__c WHERE SAC_TipoPlantilla__c = 'SAC_AvisoResolucionCartaPostal'];

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

            SAC_LCMP_GestionEmails.enviarEmail(casoActual.id, casoActual.SuppliedEmail, '', '', renderStored.getHtmlBody(), renderStored.getSubject(), '', 'primerenvioinformarredaccion');
        }
    }

    @AuraEnabled
    public static DatosEmailWrapper obtenerDatosEmail(String idCaso, Boolean soloEmail){
        try {
            List<String> body = new List<String>();
            if(!Schema.sObjectType.Case.isAccessible()){ throw new AuraHandledException( 'Fallo al recuperar el caso.' ); }
            Case caso = [SELECT Id, SAC_DireccionPostalNotificacion__c, AccountId, Account.RecordTypeId, OS_Email__c, Origin, CC_Canal_Respuesta__c,
                        Account.CC_Email__c, SAC_DireccionPostal__c, RecordTypeId, SuppliedEmail, SAC_MotivoInadmision__c, CaseNumber, Subject, Status,
                        OwnerId, CC_Idioma__c, SAC_OrigenConsulta__c, CC_No_Identificado__c, recordType.Name, SAC_Reclamacion__r.OS_Email__c,
                        CC_Oficina_Afectada_Lookup__c, CC_Oficina_Afectada_Lookup__r.CC_Email__c
                        FROM Case WHERE id =: idCaso LIMIT 1];

            EmailTemplate et = null;

            if(!Schema.sObjectType.EmailTemplate.isAccessible()){ throw new AuraHandledException( 'Fallo al recuperar el Email Template.' ); }
            if(caso.RecordTypeId == RECTYPERECLAMACION){
                et =[SELECT Id, Body, HtmlValue FROM EmailTemplate WHERE Name = 'SAC_Redaccion' LIMIT 1];
            }else {
                et=[SELECT Id, Body, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'SAC_PlantillaSAC'];
            }         
            
            ContentDocument[] documentos = null;
            
            body.add(et.HtmlValue);
            String whoId = UserInfo.getUserId();
            String whatId = caso.Id;
            String stringFinal = '';
            Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(et.Id, whoId, idCaso);  

            if(String.isNotBlank(caso.CC_Oficina_Afectada_Lookup__r.CC_Email__c)){
                return new DatosEmailWrapper(caso.CC_Oficina_Afectada_Lookup__r.CC_Email__c, renderStored.getSubject(), renderStored.getHtmlBody(), '', caso, documentos);
            }
            else{
                return new DatosEmailWrapper('', renderStored.getSubject(), renderStored.getHtmlBody(), '', caso, documentos);
            }
          
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<CC_Grupo_Colaborador__c> obtenerGrupos(String caseId){

        List<CC_Grupo_Colaborador__c> listagrupos = new List<CC_Grupo_Colaborador__c>();
        
         listagrupos = [SELECT Id, Name FROM CC_Grupo_Colaborador__c WHERE RecordType.DeveloperName = 'SAC_GrupoResponsableAccion'
                        AND SAC_PermiteTareas__c = true ORDER BY Name ASC];
        

        if(!listagrupos.isEmpty()){
            return listagrupos;  
        }else{
            return null;
        }
    }

    @AuraEnabled
    public static void generarTareaAutomaticaRedaccionPostal(String caseId, String listaAdjuntos) {
       
        string maestroTarea = '';
        Set<Id> idsSeleccionados = new Set<Id>();

        if(String.isNotBlank(listaAdjuntos) && listaAdjuntos != '[]'){
            Set<Id> idsAdjuntos = (Set<Id>)JSON.deserialize(listaAdjuntos, Set<Id>.class);
            for (Id adj : idsAdjuntos) {
                if (adj != null) {
                    idsSeleccionados.add(adj);
                }
            }
        }

        Case caso = [SELECT Id, SAC_CasoEspecial__c, CC_Canal_Procedencia__c FROM Case WHERE Id =: caseId];

        if(caso.SAC_CasoEspecial__c == 'SAC_Presidencia'){
            maestroTarea = 'SAC_ImprimirCartasAD';
        }else if(caso.CC_Canal_Procedencia__c == 'Castilla la Mancha' || caso.CC_Canal_Procedencia__c == 'Junta Andalucia'){
            maestroTarea = 'SAC_ImprimirCartasJACM';
        }else{
            maestroTarea = 'SAC_ImprimirCartasOrdinario';
        }
        //US1101520 crear tarea al subsanar por carta postal
        List<ContentVersion> listaCV = [SELECT Id, ContentDocumentId  FROM ContentVersion WHERE ContentDocumentId IN: idsSeleccionados ];
        SAC_MaestroAccionesReclamacion__c maestroTareaAutomatica = [SELECT Id, Name FROM SAC_MaestroAccionesReclamacion__c WHERE RecordTypeId = :RECTYPEMAESTROACCIONESREC AND SAC_Activo__c = true AND SAC_DeveloperName__c = :maestroTarea LIMIT 1];  

        // SAC_MaestroAccionesReclamacion__c maestroTareaAutomatica = [SELECT Id, Name FROM SAC_MaestroAccionesReclamacion__c WHERE RecordTypeId = :RECTYPEMAESTROACCIONESREC AND SAC_Activo__c = true AND SAC_DeveloperName__c = 'SAC_ImprimirCartasOrdinario' LIMIT 1];  

        if(maestroTareaAutomatica != null) {
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
            List<ContentDocumentLink> listaAdjuntosTarea = new List<ContentDocumentLink>();

            for(ContentVersion cv : listaCV) {

                ContentDocumentLink cdl = new ContentDocumentLink();

                cdl.ContentDocumentId = cv.ContentDocumentId;
                cdl.LinkedEntityId = tarea.Id;
                cdl.ShareType = 'I';
                listaAdjuntosTarea.add(cdl);

            }
            SAC_DatabaseDML.insertListDML(listaAdjuntosTarea, true);
        }
    }


    public class WrappedInfoCartas{
        @AuraEnabled public String idCarta {get; set;}
        @AuraEnabled public String direccion {get; set;}
        @AuraEnabled public String cp {get; set;}
        @AuraEnabled public String poblacion {get; set;}
        @AuraEnabled public String provincia {get; set;}
        @AuraEnabled public String pais {get; set;}
        @AuraEnabled public String documentoRedaccion {get; set;}
        @AuraEnabled public ContentVersion versionRedaccion {get; set;}
        @AuraEnabled public List<plantillasWrapper> opcionesPais{get; set;}
        

        public WrappedInfoCartas(String idM, String direccionM, String cpM, String poblacionM, String provinciaM, String paisM, String documentoRedaccionM, ContentVersion versionM, List<plantillasWrapper> opcionesM){
            idCarta = idM;
            direccion = direccionM;
            cp = cpM;
            poblacion = poblacionM;
            provincia = provinciaM;
            pais = paisM;
            documentoRedaccion = documentoRedaccionM;
            versionRedaccion = versionM;
            this.opcionesPais = opcionesM;
        }
    }

    public class plantillasWrapper{

        @AuraEnabled public String idPlantilla{get; set;}
        @AuraEnabled public String nombrePlantilla{get; set;}   
        
        public plantillasWrapper(String id, String nombre){
            idPlantilla = id;
            nombrePlantilla = nombre;
        }
    }

    public class DatosEmailWrapper{
        @AuraEnabled public String para {get; set;}
        @AuraEnabled public String asunto {get; set;}
        @AuraEnabled public String cuerpo {get; set;}
        @AuraEnabled public String copia {get; set;}
        @AuraEnabled public Case caso {get; set;}
        @AuraEnabled public ContentDocument[] adjuntos {get; set;}
        
        public DatosEmailWrapper(String paraM, String asuntoM, String cuerpoM, String copiaM, Case casoM, ContentDocument[] adjuntosM)
        {
            para = paraM;
            asunto = asuntoM;    
            cuerpo = cuerpoM;  
            copia = copiaM;
            caso = casoM;
            adjuntos = adjuntosM;
        }
    }
}