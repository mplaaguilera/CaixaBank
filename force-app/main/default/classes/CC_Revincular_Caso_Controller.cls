//Comentario pasa de with a without
public without sharing class CC_Revincular_Caso_Controller {
    @AuraEnabled
    public static Map<String, Object> getCaso(Id recordId) {

        Map<String, Object> retorno = new Map<String, Object>();

        Boolean operativaHabilitada = false;
        Boolean esRecTypeCC = false;
        String mensaje = 'Este caso no puede ser asociado a otro.';

        Case caso = [SELECT CaseNumber, ContactId, RecordType.DeveloperName, CC_CasoRelacionado__c, CC_ContactoRelacionado__c, CC_Canal_Procedencia__c, Subject, Description, CC_Cola_Procedencia__c, OwnerId, Origin
                    FROM Case WHERE Id = :recordId];

        if (caso.CC_ContactoRelacionado__c == null) {
            caso.CC_ContactoRelacionado__c = caso.ContactId;
        }
        //Saber si es recordType de CC
            esRecTypeCC = caso.RecordType.DeveloperName.startsWith('CC_');
      
        //Si el canal de entrada es chat y de tipo empleado
        if (caso.RecordType.DeveloperName == 'CC_Empleado'|| caso.RecordType.DeveloperName == 'CC_Cliente' || caso.RecordType.DeveloperName == 'HDT_Empleado' || (caso.Origin == 'Chat' && caso.RecordType.DeveloperName == 'CC_CSI_Bankia')) {
            operativaHabilitada = true;
        } else if (caso.CC_Cola_Procedencia__c != '') {
            List<CC_Fusion_Casos__mdt> procedencias = [SELECT Id FROM CC_Fusion_Casos__mdt WHERE MasterLabel = :caso.CC_Cola_Procedencia__c];
            operativaHabilitada = !procedencias.isEmpty();
        } 

        /*if (caso.CC_Canal_Procedencia__c == 'Atención al Cliente') {
            operativaHabilitada = true;
        }*/
        
        if (String.valueOf(caso.OwnerId).startsWith('00G')) {
            operativaHabilitada = false;
            mensaje = 'Para poder fusionar este caso acepte primero su propiedad.';
        }

        retorno.put('CASOSCONTACTO', getCasosContacto(caso.CC_ContactoRelacionado__c, caso.Id));
        retorno.put('CASO', caso);
        retorno.put('HABILITADO', operativaHabilitada);
        retorno.put('MENSAJE', mensaje);
        retorno.put('RECORDTYPECC', esRecTypeCC);
        return retorno;
    }

    @AuraEnabled
    public static List<Case> getCasosContacto(String contactId, String recordId) {
        List<Case> casosContacto = new List<Case>();
        if (String.isNotBlank(contactId)) {
            return [SELECT CaseNumber, Subject, Description, CreatedDate FROM Case
                    WHERE ContactId = :contactId AND Id != :recordId ORDER BY CreatedDate DESC LIMIT 20];
        }
        return casosContacto;
    }

    @AuraEnabled
    public static String mergeCase(Id masterCaseId, Id mergeCaseId) {
        try {
            Case masterCase = [SELECT CC_Ultima_Interaccion__c, Status, CC_Cola_Procedencia__c, CC_Fecha_Ultima_Interaccion__c, CC_Canal_Procedencia__c,
                                    CC_Fecha_Activo_Formulario__c, CC_Fecha_Traslado_Colaborador__c, Origin, CC_MailTelfNotif__c, CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c
                                FROM Case WHERE Id = :masterCaseId];

            Case mergeCase = [SELECT CC_Ultima_Interaccion__c, Status, CC_Cola_Procedencia__c, CC_Fecha_Ultima_Interaccion__c, CC_Canal_Procedencia__c,
                                    CC_Fecha_Activo_Formulario__c, CC_Fecha_Traslado_Colaborador__c, Origin, CC_MailTelfNotif__c, CreatedDate, RecordType.DeveloperName
                                FROM Case WHERE Id = :mergeCaseId];
                                
            List<Task> listaTareasOrigen = [SELECT Type FROM Task WHERE WhatId = :mergeCaseId AND CC_Referencia_Correo_Saliente__c != ''
                                            AND Status = 'Open' AND Type IN ('Solicitud Información', 'Traslado Colaborador', 'Remitir Colaborador')];

            String resultado;
            //Solo se actualiza acción si existe solo una actividad abierta en espera de respuesta
            if (listaTareasOrigen.size() == 1) {
                //CONTROL DE COLA ENTRANTE PARA PROCESADO DE LOGICA DE EMAIL ENTRANTE (RÉPLICA DEL TRIGGER)
                List<String> colasIncomingMail = new List<String>();
                for (CC_Fusion_Casos__mdt oConfig : [SELECT MasterLabel FROM CC_Fusion_Casos__mdt WHERE CC_Tipo__c = 'Mail Cliente entrante']) {
                    colasIncomingMail.add(oConfig.MasterLabel);
                }

                List<EmailMessage> listaMails = [SELECT TextBody, ParentId, CC_Interno__c FROM EmailMessage WHERE ParentId = :mergeCase.Id AND Incoming = true];

                if (colasIncomingMail.indexOf(mergeCase.CC_Cola_Procedencia__c) > -1 && listaMails.size() == 1) {
                    if (listaTareasOrigen[0].Type == 'Traslado Colaborador') {
                        //Respuesta entrante de grupo colaborador
                        respuestaTrasladoColaborador(listaMails[0], masterCase, mergeCase, listaTareasOrigen[0]);
                    } else if (listaTareasOrigen[0].Type == 'Solicitud Información') {
                        //Respuesta entrante de solicitud de información de cliente
                        respuestaSolicitudInfo(listaMails[0], masterCase, mergeCase, listaTareasOrigen[0]);
                    } else if (listaTareasOrigen[0].Type == 'Remitir Colaborador') {
                        //Respuesta entrante de remisión del caso a grupo colaborador
                        respuestaRemitirColaborador(listaMails[0], masterCase, mergeCase, listaTareasOrigen[0]);
                    }
                }
            }

            //Clonado previo de tareas cerradas --> Workarround para el Merge
            Id recordtypeIdTask = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
            List<Task> mergeClosedTasklst = Database.query('SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('Task').getDescribe().fields.getMap().keySet()), ',') + ' FROM Task WHERE WhatId = :mergeCaseId AND RecordTypeId = :recordtypeIdTask');
            List<Task> masterClosedTasklst = new List<Task>();
            
            CBK_Activity_Extension__c extTask;
            map<Id,CBK_Activity_Extension__c> mapExtension = new map<Id,CBK_Activity_Extension__c>();
            
            //recuperamos los IDs de las tareas a hacer merge/eliminar
            Set<Id> mergeClosedTasklstIds = (new Map<Id,Task>(mergeClosedTasklst)).keySet();

            list<CBK_Activity_Extension__c> lstExtension =  [Select Id,AV_ActivityId__c,CBK_Eliminable__c from CBK_Activity_Extension__c where AV_ActivityId__c in :mergeClosedTasklstIds];
            Set<Id> setExtensionIds = new Set<Id>();
            for (CBK_Activity_Extension__c x : lstExtension){
                setExtensionIds.add(x.AV_ActivityId__c);
            }
                
            
            for (Task tk: mergeClosedTasklst) {
                Task newRecord = tk.clone(false);
                newRecord.WhatId = masterCaseId;
                masterClosedTasklst.add(newRecord);
//                tk.CBK_Eliminable__c = true;
//  				list<CBK_Activity_Extension__c> lstExt = [Select Id from CBK_Activity_Extension__c where AV_ActivityId__c = :tk.Id];              
	            //creación de extensión que no existen, para poder eliminar las tasks
            if (!(setExtensionIds.contains(tk.Id))){        
                    extTask = new CBK_Activity_Extension__c();
			        extTask.AV_ActivityId__c=tk.id;
                    extTask.CBK_Eliminable__c=true;                           
        			lstExtension.add(extTask);                    
                } 
            }

            //marcamos las tareas a eliminar            
            for (CBK_Activity_Extension__c tk: lstExtension) {
                tk.CBK_Eliminable__c=true;                           
            }   
            upsert lstExtension; 
			

            if (OT_Proyectos.registroProyecto(mergeCaseId) == 'OS') {

                
                Set<Id> setMergedId = new Set<Id>();
                setMergedId.add(mergeCaseId);
                List<ContentDocumentLink> archivosCaso = [SELECT LinkedEntityId, ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId IN :setMergedId];

                if (!archivosCaso.isEmpty()) {
                    List<ContentDocumentLink> listaContentDocumentLink = new List<ContentDocumentLink>();
                    for (ContentDocumentLink cdl : archivosCaso) {
                        ContentDocumentLink nuevoCdl = cdl.clone();
                        nuevoCdl.LinkedEntityId = masterCaseId;
                        listaContentDocumentLink.add(nuevoCdl);
                    }
                    delete archivosCaso;
                    insert listaContentDocumentLink;
                }
                
            }
            
            //Update para poder realizar el delete
            update mergeClosedTasklst;
            delete mergeClosedTasklst;
            
            //insert masterClosedTasklst;
            CC_Activity.crearActividades(masterClosedTasklst);

            //Campos del Caso que deben traspasarse
            if (mergeCase.CC_MailTelfNotif__c != '' && mergeCase.CC_MailTelfNotif__c != null) {
                masterCase.CC_MailTelfNotif__c = mergeCase.CC_MailTelfNotif__c;
            }

            merge masterCase mergeCase;
            resultado = 'Ok';
		
           //Tarea para el mastercase
           Task createTask = new Task();
           createTask.Type = 'Fusionado'; 
           createTask.Subject = 'Fusión de caso';
           createTask.ActivityDate = System.today();
           createTask.Status = 'Completed';
            
            //Para CC los casos no se borran tras fusionarlos así que se recupera y se pone a cerrado
            Boolean recordTypeCC = Schema.SObjectType.Case.getRecordTypeInfosById().get(mergeCase.RecordTypeId).getDeveloperName().startsWith('CC_');
            if (recordTypeCC){
                undelete mergeCase;
                Case trasFusion = [SELECT Id, CC_Cerrado_Operativa__c, Status, CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c, Origin, CaseNumber
                                        FROM Case WHERE Id = :mergeCaseId];
                trasFusion.Status = 'Cerrado';
                trasFusion.CC_Cerrado_Operativa__c = System.now();
                //clasificamos para poder cerrar el caso en caso de que sea el canal de entrada pedido
            /*    if (trasFusion.Origin == 'Email - Revisar'){
                    System.debug ('Origen correcto');
                    if (masterCase.CC_MCC_Tematica__c != null && masterCase.CC_MCC_ProdServ__c != null && masterCase.CC_MCC_Motivo__c != null){
                        System.debug('Entra al IF');
                        
                        //se cambia el case origin para poder cerrarlo
                        //trasFusion.Origin = masterCase.Origin;

                        trasFusion.CC_MCC_Tematica__c = masterCase.CC_MCC_Tematica__c ; 
                        trasFusion.CC_MCC_ProdServ__c = masterCase.CC_MCC_ProdServ__c ; 
                        trasFusion.CC_MCC_Motivo__c = masterCase.CC_MCC_Motivo__c ;
                    }
                    else {
                        System.debug('Entra al ELSE');
                         //se envía un mensaje de error si el caso master no está clasificado
                        List<CC_Aviso_Case__e> avisos = new List<CC_Aviso_Case__e>();         
                        String tipoToast = 'error';
                        String mensaje = 'El caso al que intentas asociar debe estar clasificado ()';
                        System.debug('Crea el aviso');
                        avisos.add(new CC_Aviso_Case__e(Mensaje__c = mensaje, Case_Id__c = Id.valueOf(mergeCaseId),  Tipo__c = tipoToast));  
                        System.debug('Aviso añadido');              
                        EventBus.publish(avisos);
                        System.debug('Aviso publicado');
                    }
                    
                } */
                
                update trasFusion;
                
                createTask.Description = 'El número del caso asociado es '+trasFusion.CaseNumber;

            }
            else {
                createTask.Description = '';
            }
            
            createTask.WhatId = masterCase.Id;
            //insert createTask;
			CC_Activity.crearActividad(createTask);
            
            return resultado; 

           
        
        } catch (Exception e) {
            System.Debug('Mensaje '+e.getMessage());
            System.Debug('Causa '+e.getCause());
            System.Debug('StrackTraceString '+e.getStackTraceString());
            //System.debug('Account fields that affected this error: ' + e.getFields());

           

            throw new AuraHandledException(e.getMessage());
        }
    }

    public static void respuestaSolicitudInfo(EmailMessage correo, Case caso, Case mergeCase, Task listaTareasOrigen) {

        if (caso.Status == 'Pendiente Cliente') {
            caso.Status = 'Activo';
            caso.CC_Ultima_Interaccion__c = 'Respuesta de solicitud de información';
            caso.CC_Fecha_Ultima_Interaccion__c = System.now();

            //Controlamos cuando se hace la devolución y se pone Activo para report de FormWeb.
            if (caso.CC_Canal_Procedencia__c == 'Caixabank Talks' || caso.CC_Canal_Procedencia__c == 'Formulario web' || caso.CC_Canal_Procedencia__c == 'Soporte Clientes CompraEstrella' || caso.CC_Canal_Procedencia__c == 'Soporte Empleados CompraEstrella') {
                caso.CC_Fecha_Activo_Formulario__c = Datetime.valueOf(System.now());
            }

            //Controlamos cuando se hace la devolución y se pone Activo para report de Accionista.
            if (caso.CC_Canal_Procedencia__c == 'Accionista') {
                caso.CC_Fecha_Activo_Formulario__c = CC_SLA_Utils.calculo_Fecha_Activo('Accionista');
            }

            //Cierre de la actividad de envío
            CC_Activity.finalizarActividadCaso(caso.Id, 'Solicitud Información', null, null);
        } else if (caso.Status == 'Cerrado') {
            //Para solicitudes info se reabre el caso aunque se hubiera cerrado
            CC_Case.reapertura(caso.Id, correo.TextBody);
        }
    }

    public static void respuestaTrasladoColaborador(EmailMessage correo, Case caso, Case mergeCase, Task lsttareaOrigen) {
        correo.CC_Interno__c = true;

        //Cambio de estado del caso
        if (caso.Status == 'Pendiente Colaborador') {
            caso.Status = 'Activo';
            caso.CC_Ultima_Interaccion__c = 'Respuesta de colaborador';
            caso.CC_Fecha_Ultima_Interaccion__c = System.now();
            //Controlamos cuando se hace la devolución y se pone Activo para report de FormWeb.
            if (caso.CC_Canal_Procedencia__c == 'Caixabank Talks' || caso.CC_Canal_Procedencia__c == 'Formulario web' || caso.CC_Canal_Procedencia__c == 'Soporte Clientes CompraEstrella' || caso.CC_Canal_Procedencia__c == 'Soporte Empleados CompraEstrella') {
                caso.CC_Fecha_Activo_Formulario__c = Datetime.valueOf(System.now());
            }

            //Informamos la fecha de respuesta para el report de Stores
            if (caso.Origin == 'Comentarios Stores') {
                caso.CC_Fecha_Traslado_Colaborador__c = Datetime.valueOf(System.now());
            }

            //Controlamos cuando se hace la devolución y se pone Activo para report de FormWeb.
            if (caso.CC_Canal_Procedencia__c == 'Caixabank Talks' || caso.CC_Canal_Procedencia__c == 'Formulario web' || caso.CC_Canal_Procedencia__c == 'Soporte Clientes CompraEstrella' || caso.CC_Canal_Procedencia__c == 'Soporte Empleados CompraEstrella') {
                caso.CC_Fecha_Activo_Formulario__c = Datetime.valueOf(System.now());
            }

            //Controlamos cuando se hace la devolución y se pone Activo para report de Accionista.
            if (caso.CC_Canal_Procedencia__c == 'Accionista') {
                caso.CC_Fecha_Activo_Formulario__c = CC_SLA_Utils.calculo_Fecha_Activo('Accionista');
            }

            //Informamos la fecha de respuesta para el report de Stores
            //if (caso.Origin == 'Comentarios Stores') {
                caso.CC_Fecha_Respuesta_Colaborador__c = Datetime.valueOf(System.now());
            //}

            //Cierre de la actividad de envío del traslado a grupo colaborador
            CC_Activity.finalizarActividadCaso(caso.Id, 'Traslado Colaborador', null, null);
        }
    }

    public static void respuestaRemitirColaborador(EmailMessage correo, Case caso, Case mergeCase, Task lsttareaOrigen) {

        correo.CC_Interno__c = true;

        //Cambio de estado del caso
        if (caso.Status == 'Pendiente Colaborador') {
            caso.Status = 'Activo';
            //Cierre de la actividad de envío del traslado a grupo colaborador
            CC_Activity.finalizarActividadCaso(caso.Id, 'Remitir Colaborador', null, null);
        }
    }

    @AuraEnabled
    public static List<Case> getlstCaso(String sRecordId, String sIgnoreId) {
        List<Case> olstCaso = New List<Case>();
        if (sRecordId != '' && sRecordId != null) {
            olstCaso = [SELECT CaseNumber, Subject, Description,CreatedDate FROM Case
                        WHERE ContactId = :sRecordId AND Id != :sIgnoreId ORDER BY CreatedDate DESC LIMIT 20];
        }
        
        return olstCaso;
    }
    
    @AuraEnabled
    public static String getParentIdRecordTypeDeveloperName(Case caso){
        String developerName = '';
        List<Case> casoParent = [SELECT RecordTypeId, RecordType.DeveloperName, Id FROM Case WHERE ID = :caso.ParentId];
        if (!casoParent.isEmpty()) {
            developerName = casoParent.get(0).RecordType.DeveloperName;
        }
        return developerName;
    }


    @AuraEnabled
    public static Boolean comprobarRecordType(Id recordTypeId){
        /*****************************************************************
         * Proposito: Método para comprobar que el record type es CC al crear un nuevo caso y salga el mensaje correcto de aviso
         * 
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR           DATE            Description
         * 1.0            US145644         Jorge Argente    18/02/22        Creación Método
        *****************************************************************/
        //system.debug('recId ' + recordTypeId);
        List<RecordType> recordTypeActual = [SELECT DeveloperName FROM RecordType WHERE Id =: recordTypeId LIMIT 1];
        //system.debug('rec ' + recordTypeActual);
        return recordTypeActual[0].DeveloperName.startsWith('CC_') ? true : false;
    }

    public static void devolverCasoAlSAC(String motivo, Case casoContactCenter){
        try {
            List<Case> casos = new List<Case>();
            Case casoSAC = [SELECT Id, CaseNumber, Status, CC_Motivo__c, OwnerId FROM Case WHERE Id =: casoContactCenter.ParentId LIMIT 1];

            List<CaseHistory> listadoHistoricoCaso = new List<CaseHistory>();
            Integer resta = 0;
            if (!Test.isRunningTest())
            {
                listadoHistoricoCaso = [SELECT Id, OldValue FROM CaseHistory WHERE CaseId =: casoSAC.Id AND Field = 'Status' ORDER BY CreatedDate desc];
            }

            List<Integer> pos = new List<Integer>();

            if (listadoHistoricoCaso.size() > 0 || Test.isRunningTest())
            {
                for (CaseHistory historicoCaso : listadoHistoricoCaso){ 
                    if (historicoCaso.OldValue == 'Cerrado' || historicoCaso.OldValue == 'SAC_006')
                    { 
                        Integer posicion = listadoHistoricoCaso.indexOf(historicoCaso); pos.add(posicion); 
                    } 
                }
                for (Integer posicion : pos)
                { 
                    listadoHistoricoCaso.remove(posicion - resta); resta = resta + 1;
                }
            }
            if (Test.isRunningTest()) 
            {
                casoSAC.Status = 'SAC_001';
                casoSAC.SAC_StatusAuxiliar__c = 'SAC_001';
                casoSAC.CC_Motivo__c = motivo;
               // Comentado para las pruebas de funcionamiento: casoSAC.SAC_MotivoReabrir__c = motivo;
               casoSAC.SAC_MotivoReabrir__c = motivo;


            } else 
            {
                casoSAC.Status = listadoHistoricoCaso[0].OldValue.toString();
                casoSAC.SAC_StatusAuxiliar__c = listadoHistoricoCaso[0].OldValue.toString();
                casoSAC.CC_Motivo__c = motivo;
                // Comentado para las pruebas de funcionamiento: casoSAC.SAC_MotivoReabrir__c = motivo;
                casoSAC.SAC_MotivoReabrir__c = motivo;
            }
            
            Case casoCC = new Case();
            casoCC.Id = casoContactCenter.Id;
            casoCC.RecordTypeId = casoContactCenter.RecordTypeId;
            casoCC.CC_Motivo__c = motivo;
            casoCC.SAC_MotivoReabrir__c = motivo;
            casoCC.Status = 'Cerrado';
            casoCC.CC_Cerrado_Operativa__c = System.now();
            casos.add(casoCC);

            //Creación ActividadCC 'Devolver a SAC' 
            Task tareaCC = new Task();
            tareaCC.WhatId = casoContactCenter.Id;
            tareaCC.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
            tareaCC.Subject = 'Devuelto a SAC';
            tareaCC.Type = 'Automática';
            tareaCC.Description = motivo;
            tareaCC.ActivityDate = System.today();
            tareaCC.Status = 'Completed';
            //Comentarios = motivo
            insert tareaCC;
            
            casos.add(casoSAC);
            update casos;
            System.debug('Pablo: casos '+casos);
            SAC_Notificacion.enviarNotificacion(casoSAC.OwnerId, casoSAC.Id, 'Reclamación reabierta', 'La reclamación ' + casoSAC.CaseNumber + ' ha sido reabierta desde CC.');
             
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    //INI - LMG - 04/07/2022 -> Reducción complejidad en código + añadir adjuntos y emails al registro enviado a SAC.

    public static void derivarCasoAlSAC(Case casoContactCenter, String motivo) {
        //Comprobar permisos
        if(!Schema.sObjectType.ContentDocumentLink.isAccessible() || !Schema.sObjectType.ContentVersion.isAccessible() || !Schema.sObjectType.EmailMessage.isAccessible()){
            throw new AuraHandledException('Sin acceso a los objetos ContentDocumentLink, ContentVersion o EmailMessage');
        }
        else if(!Schema.sObjectType.Case.isCreateable() || !Schema.sObjectType.Task.isCreateable()){
            throw new AuraHandledException('Sin permisos de creación sobre el objeto Case, Task, ContentVersion o EmailMessage');
        }
        else{
            //Obtención archivos adjuntos
            List<ContentDocumentLink> cdlist = [SELECT id, LinkedEntityId, ContentDocumentID FROM ContentDocumentLink WHERE LinkedEntityId =: casoContactCenter.Id];
            Set<Id> fileId = new Set<Id>();
            for(ContentDocumentLink cl:cdlist){
                fileId.add(cl.ContentDocumentId);
                //System.debug('lista de adjuntos marca 2 id: ' + cl.ContentDocumentId);
            }
            List<ContentVersion> adjuntosParaSAC = [SELECT Id, Title, VersionData, PathOnClient, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN: fileId];
            //System.debug('lista de adjuntos ' + adjuntosParaCC);
            
            //Obtencion de Emails del cliente
            //List<EmailMessage> emailsParaSAC = [SELECT Status, Incoming, MessageDate, FromAddress, FromName, CcAddress, Subject, HtmlBody, ToAddress, ValidatedFromAddress, BccAddress FROM EmailMessage WHERE ParentId =: casoContactCenter.Id];    
        

        
            // Creación del caso de SAC
            Case casoSac = new Case();
            casoSac.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId(); 
            casoSac.Origin = 'CC'; 
            casoSac.Subject = casoContactCenter.Subject; 
            casoSac.CC_Idioma__c = casoContactCenter.CC_Idioma__c;
            casoSac.Description = casoContactCenter.Description; 
            casoSac.AccountId = casoContactCenter.AccountId; 
            casoSac.ContactId = casoContactCenter.ContactId; 
            casoSac.Status = 'SAC_001'; 
            casoSac.SAC_StatusAuxiliar__c = 'SAC_001';
            casoSac.CC_CasoRelacionado__c = casoContactCenter.Id;
            casoSac.ParentId = casoContactCenter.Id;
            casoSac.SAC_FechaRecepcion__c = casoContactCenter.createddate;
            casoSac.CC_Motivo__c = motivo;
            casoSac.OwnerId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SAC_PendienteAsignar' LIMIT 1].Id;
            insert casoSac;

            //Creación ActividadCC 'Derivado a SAC' 
            Task tareaCC = new Task();
            tareaCC.WhatId = casoContactCenter.Id;
            tareaCC.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
            tareaCC.Subject = 'Derivado a SAC';
            tareaCC.Type = 'Automática';
            tareaCC.Description = 'Derivado a SAC';
            tareaCC.ActivityDate = System.today();
            tareaCC.Status = 'Completed';
            insert tareaCC;
            
            Case casoCC = new Case();
            casoCC.Id = casoContactCenter.Id;
            casoCC.CC_Motivo__c = motivo;
            casoCC.Status = 'Cerrado';
            casoCC.CC_Cerrado_Operativa__c = System.now();
            update casoCC;

            addAdjuntos(casoSac, adjuntosParaSAC/*, emailsParaSAC*/);

            

            //insert listadoAuxiliarRegistro;
        }
    }

    public static void addAdjuntos(Case casoSac, List<ContentVersion> adjuntosParaSAC/*, List<EmailMessage> emailsParaSAC*/) {
        List<SObject> listadoAuxiliarRegistro = new List<SObject>();
        if(!adjuntosParaSAC.isEmpty()){
            for(ContentVersion cv: adjuntosParaSAC){
                /*ContentVersion cvCopy = new ContentVersion(
                    Title= cv.Title, 
                    PathOnClient = cv.PathOnClient,
                    VersionData = cv.VersionData,
                    FirstPublishLocationId = casoSac.Id
                );
                listadoAuxiliarRegistro.add(cvCopy);*/
                ContentDocumentLink cl = new ContentDocumentLink(LinkedEntityId = casoSac.Id, ContentDocumentId = cv.ContentDocumentId, ShareType = 'I');
                listadoAuxiliarRegistro.add(cl);
            }

        }
        /*if(!emailsParaSAC.isEmpty()){
            for(EmailMessage em : emailsParaSAC){
                EmailMessage emailMsg = new EmailMessage(); // Created a EmailMessage and copy all details from above.
                emailMsg.ToAddress = em.ToAddress;
                emailMsg.Subject = em.Subject;
                emailMsg.HtmlBody = em.HtmlBody;
                emailMsg.MessageDate = em.MessageDate;
                emailMsg.Status = em.Status;
                emailMsg.FromAddress = em.FromAddress;
                emailMsg.CcAddress = em.CcAddress;
                emailMsg.BccAddress = em.BccAddress;
                emailMsg.FromName = em.FromName;
                emailMsg.ParentId = casoSac.Id;
                emailMsg.Incoming = em.Incoming;
                //listadoAuxiliarRegistro.add(emailMsg);
            }
        }        */    

        // Strip fields that are not creatable
        SObjectAccessDecision decision = Security.stripInaccessible(
            AccessType.CREATABLE,
            listadoAuxiliarRegistro);
        try{
            // get field where user has access to insert
            insert decision.getRecords();
        }catch(NoAccessException e){
            throw new AuraHandledException('Sin permisos de creación sobre el objeto ContentVersion o EmailMessage');
        }
    }

}