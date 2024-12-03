public with sharing class CC_Configuracion_Reclamaciones_Auto {
    
    @AuraEnabled
    public static List<Folder> getCarpetas(String carpetaDeveloperName, String idReclamacion) {
        
        List<CC_Configuracion_Reclamacion__c> configRecAuto = [SELECT OS_Negocio__c FROM CC_Configuracion_Reclamacion__c WHERE Id = :idReclamacion WITH SECURITY_ENFORCED];
        
        List<Folder> carpetas = new List<Folder>();
        
        Id parentId;
        if (carpetaDeveloperName == null) {
            if (configRecAuto.size() > 0 && configRecAuto[0].OS_Negocio__c == 'COPS') {
                parentId = [SELECT Id FROM Folder WHERE DeveloperName = 'OS_Reclamaciones_Automaticas'].Id;        
            } 
            else if (configRecAuto.size() > 0 && configRecAuto[0].OS_Negocio__c == 'CSI_Bankia') {
                parentId = [SELECT Id FROM Folder WHERE DeveloperName = 'CC_Reclamaciones_Automaticas_CSI_Bankia'].Id;        
            } 
            else if (configRecAuto.size() > 0 && configRecAuto[0].OS_Negocio__c == 'CAM') {
                parentId = [SELECT Id FROM Folder WHERE DeveloperName = 'AM_Reclamaciones_Automaticas'].Id;        
            }
            else if (configRecAuto.size() > 0 && configRecAuto[0].OS_Negocio__c == 'SACH') {
                parentId = [SELECT Id FROM Folder WHERE DeveloperName = 'SACH_Reclamaciones_Automaticas'].Id;        
            }
            else if (configRecAuto.size() > 0 && configRecAuto[0].OS_Negocio__c == 'HDT') {
                parentId = [SELECT Id FROM Folder WHERE DeveloperName = 'HDT_Reclamaciones_Automaticas'].Id;        
            }
            else if (configRecAuto.size() > 0 && configRecAuto[0].OS_Negocio__c == 'GRR') {
                parentId = [SELECT Id FROM Folder WHERE DeveloperName = 'GRR_Reclamaciones_Automaticas'].Id;        
            }
            else {
                parentId = [SELECT Id FROM Folder WHERE DeveloperName = 'CC_Reclamaciones_Automaticas'].Id;    
            }        
        } else {
            parentId = [SELECT Id FROM Folder WHERE DeveloperName = :carpetaDeveloperName].Id;
        }
        
        for (Folder carpeta : [SELECT Name, DeveloperName FROM Folder WHERE TYPE = 'EmailTemplate' AND ParentId = :parentId WITH SECURITY_ENFORCED]) {
            carpetas.add(carpeta);
        }
        
        return carpetas;
    }
    
    @AuraEnabled
    public static List<EmailTemplate> getPlantillas(String carpeta) {
        List<EmailTemplate> opcionesPlantilla = new List<EmailTemplate>();
        
        Id carpetaId = [SELECT Id FROM Folder WHERE DeveloperName = :carpeta].Id;
        
        List<EmailTemplate> plantillas = [SELECT Name, DeveloperName FROM EmailTemplate WHERE FolderId = :carpetaId WITH SECURITY_ENFORCED ORDER BY Name ASC];
        for (EmailTemplate plantilla : plantillas) {
            opcionesPlantilla.add(plantilla);
        }
        
        return opcionesPlantilla;
    }
    
    @AuraEnabled
    public static void guardar(CC_Configuracion_Reclamacion__c confRec) {
        upsert confRec;    
    }
    
    public static void informarFechasReclamacionesAuto(Task actividad) {
        //Cálculo de las fechas en que se programan las reclamaciones automáticas de la Tarea (ya sea traslado a Colaborador, solicitud de información, etc) -- Por el momento sólo desarrollado para Traslado a Colaborador
        DateTime hoy = System.today();
        String horas1aRec;
        String horas2aRec;
        String horas3aRec;
        String horasFinRec;
        
        //Recupera el grupo colaborador al que se ha Trasladado el Caso
        CC_Grupo_Colaborador__c grupoColab = [SELECT CC_Reclamacion_Automatica__c FROM CC_Grupo_Colaborador__c WHERE Id = :actividad.CC_Grupo_Colaborador_Id__c];
        
        //Recupera la configuración de reclamaciones automática asociada al grupo colaborador
        CC_Configuracion_Reclamacion__c[] configRecAuto = [SELECT CC_1a_Reclamacion_Activa__c, CC_2a_Reclamacion_Activa__c, CC_3a_Reclamacion_Activa__c, CC_Fecha_Activacion_1a_Rec__c, 
        CC_Fecha_Activacion_2a_Rec__c, CC_Fecha_Activacion_3a_Rec__c, CC_Fecha_Desactivacion_1a_Rec__c, CC_Fecha_Desactivacion_2a_Rec__c, 
        CC_Fecha_Desactivacion_3a_Rec__c, CC_Horas_1a_Reclamacion__c, CC_Horas_2a_Reclamacion__c, CC_Horas_3a_Reclamacion__c, 
        CC_Plantilla_1_Rec_Colab_Cast__c, CC_Plantilla_1_Rec_Colab_Cat__c, CC_Plantilla_2_Rec_Colab_Cast__c, 
        CC_Plantilla_2_Rec_Colab_Cat__c, CC_Plantilla_3_Rec_Colab_Cast__c, CC_Plantilla_3_Rec_Colab_Cat__c, CC_Calendario__c,
        OS_Fin_Reclamacion_Activa__c, OS_Fecha_Activacion_Fin_Rec__c, OS_Fecha_Desactivacion_Fin_Rec__c, OS_Horas_Fin_Reclamacion__c
        FROM CC_Configuracion_Reclamacion__c WHERE Id = :grupoColab.CC_Reclamacion_Automatica__c];
        
        //En función de la configuración de reclamaciones automáticas, se informan en la Task las fechas en que se reclamará el traslado a colaborador, si aplica
        if (!configRecAuto.isEmpty()) {           
            //Si la configuración de la reclamación tiene activada la primera reclamación, la fecha de activación es inferior a hoy y 
            //la de desactivación es superior a hoy o nula, entonces se deberá realizar la primera reclamación
            if (configRecAuto[0].CC_1a_Reclamacion_Activa__c == true && hoy >= configRecAuto[0].CC_Fecha_Activacion_1a_Rec__c && 
            (hoy <= configRecAuto[0].CC_Fecha_Desactivacion_1a_Rec__c || configRecAuto[0].CC_Fecha_Desactivacion_1a_Rec__c == null)) {
                //El cálculo de cuándo se hará la primera reclamación depende de las horas y del calendario configurados
                horas1aRec = configRecAuto[0].CC_Horas_1a_Reclamacion__c;
                Long horas1aRecLong = Long.valueof(horas1aRec) * 60 * 60 * 1000;
                actividad.CC_Fecha_1_Reclamacion_Auto__c = BusinessHours.add(configRecAuto[0].CC_Calendario__c, System.now(), horas1aRecLong);
            }
            
            //Si la configuración de la reclamación tiene activada la segunda reclamación, la fecha de activación es inferior a hoy y 
            //la de desactivación es superior a hoy o nula, entonces se deberá realizar la segunda reclamación
            if (configRecAuto[0].CC_2a_Reclamacion_Activa__c ==  true && hoy >= configRecAuto[0].CC_Fecha_Activacion_2a_Rec__c && 
            (hoy <= configRecAuto[0].CC_Fecha_Desactivacion_2a_Rec__c || configRecAuto[0].CC_Fecha_Desactivacion_2a_Rec__c == null)) {
                //El cálculo de cuándo se hará la segunda reclamación depende de las horas y del calendario configurados
                horas2aRec = configRecAuto[0].CC_Horas_2a_Reclamacion__c;
                Long horas2aRecLong = Long.valueof(horas2aRec) * 60 * 60 * 1000;
                actividad.CC_Fecha_2_Reclamacion_Auto__c = BusinessHours.add(configRecAuto[0].CC_Calendario__c, System.now(), horas2aRecLong);
            }
            
            //Si la configuración de la reclamación tiene activada la tercera reclamación, la fecha de activación es inferior a hoy y 
            // de desactivación es superior a hoy o nula, entonces se deberá realizar la tercera reclamación
            if (configRecAuto[0].CC_3a_Reclamacion_Activa__c ==  true && hoy >= configRecAuto[0].CC_Fecha_Activacion_3a_Rec__c && 
            (hoy <= configRecAuto[0].CC_Fecha_Desactivacion_3a_Rec__c || configRecAuto[0].CC_Fecha_Desactivacion_3a_Rec__c == null)) {
                //El cálculo de cuándo se hará la tercera reclamación depende de las horas y del calendario configurados
                horas3aRec = configRecAuto[0].CC_Horas_3a_Reclamacion__c;
                Long horas3aRecLong = Long.valueof(horas3aRec) * 60 * 60 * 1000;
                actividad.CC_Fecha_3_Reclamacion_Auto__c = BusinessHours.add(configRecAuto[0].CC_Calendario__c, System.now(), horas3aRecLong);
            } 
            
            //Si la configuración de la reclamación tiene activada Fin de reclamación, la fecha de activación es inferior a hoy y 
            // de desactivación es superior a hoy o nula, entonces se deberá realizar el Fin de reclamación
            if (configRecAuto[0].OS_Fin_Reclamacion_Activa__c ==  true && hoy >= configRecAuto[0].OS_Fecha_Activacion_Fin_Rec__c && 
            (hoy <= configRecAuto[0].OS_Fecha_Desactivacion_Fin_Rec__c || configRecAuto[0].OS_Fecha_Desactivacion_Fin_Rec__c == null)) {
                //El cálculo de cuándo se hará el Fin de reclamación depende de las horas y del calendario configurados
                horasFinRec = configRecAuto[0].OS_Horas_Fin_Reclamacion__c;
                Long horasFinRecLong = Long.valueof(horasFinRec) * 60 * 60 * 1000;                
                actividad.OS_Fecha_Fin_Reclamacion_Auto__c = BusinessHours.add(configRecAuto[0].CC_Calendario__c, System.now(), horasFinRecLong);
            }
        }
    }
    
    @InvocableMethod(label='Envío Rec. Auto Traslado Colab.' description='Envío Rec. Auto Traslado Colab.')
    public static void sendMailRecTrasladoColab(List<Id> tareasId) {
        //Lista de las tareas que nos llegan como input
        List<Task> listaTareas = [SELECT CC_Grupo_Colaborador_Id__c, IsClosed, WhatId, RecordtypeId,
        CC_Fecha_1_Reclamacion_Auto__c, CC_Fecha_2_Reclamacion_Auto__c, CC_Fecha_3_Reclamacion_Auto__c, CC_Correo_Asociado_Id__c, OS_Fecha_Fin_Reclamacion_Auto__c
        FROM Task WHERE Id IN :tareasId AND IsClosed = false];
        
        //Lista de las tareas que nos llegan como input
        List<Task> listaTraslados = [SELECT CC_Grupo_Colaborador_Id__c, IsClosed, WhatId,
        CC_Fecha_1_Reclamacion_Auto__c, CC_Fecha_2_Reclamacion_Auto__c, CC_Fecha_3_Reclamacion_Auto__c, CC_Correo_Asociado_Id__c, OS_Fecha_Fin_Reclamacion_Auto__c
        FROM Task WHERE Id IN :tareasId AND Type = 'Traslado Colaborador' AND Status = 'Open'];
        if(!listaTareas.isEmpty()){                    
            //Guardamos los Ids de los casos de las tareas.
            Set<Id> casosIds = new Set<Id>();
            Set<Id> tareasIds = new Set<Id>();
            //Set<Id> gruposColaboradoresIds = new Set<Id>();
            Map<Id, Id> mapTareaGrupoId = new Map<Id, Id>();
            Map<Id, Case> mapTareaCaso = new Map<Id, Case>();
            Map<Id, EmailMessage> mapTareaEmailMessage = new Map<Id, EmailMessage>();
            for (Task tarea : listaTareas) {
                mapTareaCaso.put(tarea.WhatId, null);
                mapTareaGrupoId.put(tarea.Id, tarea.CC_Grupo_Colaborador_Id__c);
                mapTareaEmailMessage.put(tarea.CC_Correo_Asociado_Id__c, null);
                //tareasIds.add(tarea.Id);                
                //gruposColaboradoresIds.add(tarea.CC_Grupo_Colaborador_Id__c);
            }    
            
            if(!mapTareaCaso.isEmpty() && !mapTareaGrupoId.isEmpty()){          
                //Buscamos los casos que están en pendiente colaborador y que su tarea no esté cerrada
                List<Case> listaCasos = [SELECT CC_Buzon_Salida__c, Contact.Email, Status, CC_Idioma__c, CC_Tipo_Cliente__c, ContactId, CaseNumber, CC_Numero_Reclamaciones_Tras_Colab__c, OwnerId, CC_Ultima_Interaccion__c, CC_Detalles_Consulta__c, CC_Detalles_Solucion__c, RecordType.DeveloperName, CC_Canal_Operativo__c
                FROM Case WHERE Id IN :mapTareaCaso.keySet() AND Status = 'Pendiente Colaborador' WITH SECURITY_ENFORCED];                                                                      
                
                for (Case caso : listaCasos) {
                    mapTareaCaso.put(caso.Id, caso);    
                }
                
                //Recorrer lista de EmailMessage que referenciados con el caso  
                Set<Id> setEmailIDs = new Set<Id>();
                Map<Id, List<Id>> mapCaseEmailMessage = new Map<Id, List<Id>>();
                for (EmailMessage eMessage : [SELECT Id, RelatedToId FROM EmailMessage WHERE RelatedToId IN :mapTareaCaso.keySet() WITH SECURITY_ENFORCED]) {
                    setEmailIDs.add(eMessage.Id);
                    if (mapCaseEmailMessage.containsKey(eMessage.RelatedToId)) {
                        List<Id> lstEmails = mapCaseEmailMessage.get(eMessage.RelatedToId);
                        lstEmails.add(eMessage.Id);
                        mapCaseEmailMessage.put(eMessage.RelatedToId,lstEmails);
                    } else {
                        mapCaseEmailMessage.put(eMessage.RelatedToId, new List<Id> {eMessage.Id});
                    }  
                }
                //Recoger id de ContentDocumentLink de los ids referenciados al EmailMessage
                Set<Id> setContentDocumentLinkIDs = new Set<Id>();
                Map<Id, List<Id>> mapEmailContentDocument = new Map<Id, List<Id>>();    
                for (ContentDocumentLink cDocumentLink : [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :setEmailIDs WITH SECURITY_ENFORCED]) {
                    setContentDocumentLinkIDs.add(cDocumentLink.ContentDocumentId);
                    if (mapEmailContentDocument.containsKey(cDocumentLink.LinkedEntityId)) {
                        List<Id> lstContentDocuments = mapEmailContentDocument.get(cDocumentLink.LinkedEntityId);
                        lstContentDocuments.add(cDocumentLink.ContentDocumentId);
                        mapEmailContentDocument.put(cDocumentLink.LinkedEntityId,lstContentDocuments);
                    } else {
                        mapEmailContentDocument.put(cDocumentLink.LinkedEntityId, new List<Id> {cDocumentLink.ContentDocumentId});
                    } 
                }
                
                //Recorrer el ContentVersion para enviar el attachment
                Map<Id, List<ContentVersion>> mapContentDocumentVersion = new Map<Id, List<ContentVersion>>();
                for (ContentVersion cVersion : [SELECT Title, VersionData, FileExtension, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :setContentDocumentLinkIDs WITH SECURITY_ENFORCED]) {
                    if (mapContentDocumentVersion.containsKey(cVersion.ContentDocumentId)) {
                        List<ContentVersion> lstContentDocuments = mapContentDocumentVersion.get(cVersion.ContentDocumentId);
                        lstContentDocuments.add(cVersion);
                        mapContentDocumentVersion.put(cVersion.ContentDocumentId,lstContentDocuments);
                    } else {
                        mapContentDocumentVersion.put(cVersion.ContentDocumentId, new List<ContentVersion> {cVersion});
                    }
                }
                
                Map<Id, List<ContentVersion>> mapCaseContentVersion = new Map<Id, List<ContentVersion>>();
                for (Case caso : listaCasos) {
                    if(mapCaseEmailMessage.containsKey(caso.Id)){
                        for (Id emailsMessage : mapCaseEmailMessage.get(caso.Id)) {
                            if(mapEmailContentDocument.containsKey(emailsMessage)){
                                for (Id documentLink : mapEmailContentDocument.get(emailsMessage)) {
                                    if(mapContentDocumentVersion.containsKey(documentLink)){
                                        for (ContentVersion conVersion : mapContentDocumentVersion.get(documentLink)) {
                                            if (mapCaseContentVersion.containsKey(caso.Id)) {
                                                List<ContentVersion> lstContentVersion = mapCaseContentVersion.get(caso.Id);
                                                lstContentVersion.add(conVersion);
                                                mapCaseContentVersion.put(caso.Id,lstContentVersion);
                                            } else {
                                                mapCaseContentVersion.put(caso.Id, new List<ContentVersion> {conVersion});
                                            } 
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                List<CC_Grupo_Colaborador__c> gruposColaboradores = [SELECT CC_Reclamacion_Automatica__r.CC_Plantilla_1_Rec_Colab_Cast__c, 
                CC_Reclamacion_Automatica__r.CC_Plantilla_1_Rec_Colab_Cat__c, 
                CC_Reclamacion_Automatica__r.CC_Plantilla_1_Rec_Cliente_Cast__c, 
                CC_Reclamacion_Automatica__r.CC_Plantilla_1_Rec_Cliente_Cat__c, 
                CC_Reclamacion_Automatica__r.CC_Email_Cliente_1a_Rec__c,
                CC_Reclamacion_Automatica__r.CC_Plantilla_2_Rec_Colab_Cast__c, 
                CC_Reclamacion_Automatica__r.CC_Plantilla_2_Rec_Colab_Cat__c, 
                CC_Reclamacion_Automatica__r.CC_Plantilla_2_Rec_Cliente_Cast__c, 
                CC_Reclamacion_Automatica__r.CC_Plantilla_2_Rec_Cliente_Cat__c, 
                CC_Reclamacion_Automatica__r.CC_Email_Cliente_2a_Rec__c,
                CC_Reclamacion_Automatica__r.CC_Plantilla_3_Rec_Colab_Cast__c, 
                CC_Reclamacion_Automatica__r.CC_Plantilla_3_Rec_Colab_Cat__c,
                CC_Reclamacion_Automatica__r.CC_Plantilla_3_Rec_Cliente_Cast__c, 
                CC_Reclamacion_Automatica__r.CC_Plantilla_3_Rec_Cliente_Cat__c, 
                CC_Reclamacion_Automatica__r.CC_Email_Cliente_3a_Rec__c,
                CC_Reclamacion_Automatica__r.OS_EstadoCaso__c,
                CC_Reclamacion_Automatica__r.OS_Asignar_Propietario__c,
                CC_Reclamacion_Automatica__r.OS_Asignar_Usuario__c,
                CC_Reclamacion_Automatica__r.OS_Asignar_GrupoTrabajo__c,
                CC_Reclamacion_Automatica__r.OS_Fin_Reclamacion_Activa__c,
                (SELECT CC_Para_CC__c, CC_Email__c, CC_Reclamacion_1__c, CC_Reclamacion_2__c, CC_Reclamacion_3__c FROM Colaboradores__r) colaboradores
                FROM CC_Grupo_Colaborador__c WHERE Id IN :mapTareaGrupoId.values() WITH SECURITY_ENFORCED LIMIT 1];            
                
                String[] ccAddresses = new String[] {};
                
                Map<String, EmailTemplate> mapPlantilla = new Map<String, EmailTemplate>();
                Map<Id, CC_Grupo_Colaborador__c> mapGrupo = new Map<Id, CC_Grupo_Colaborador__c>();
                for (CC_Grupo_Colaborador__c grupo : gruposColaboradores) {
                    mapGrupo.put(grupo.Id, grupo);
                    mapPlantilla.put(grupo.CC_Reclamacion_Automatica__r.CC_Plantilla_1_Rec_Colab_Cast__c, null);
                    mapPlantilla.put(grupo.CC_Reclamacion_Automatica__r.CC_Plantilla_1_Rec_Colab_Cat__c, null);
                    mapPlantilla.put(grupo.CC_Reclamacion_Automatica__r.CC_Plantilla_1_Rec_Cliente_Cast__c, null);
                    mapPlantilla.put(grupo.CC_Reclamacion_Automatica__r.CC_Plantilla_1_Rec_Cliente_Cat__c, null);                
                    mapPlantilla.put(grupo.CC_Reclamacion_Automatica__r.CC_Plantilla_2_Rec_Colab_Cast__c, null);
                    mapPlantilla.put(grupo.CC_Reclamacion_Automatica__r.CC_Plantilla_2_Rec_Colab_Cat__c, null);
                    mapPlantilla.put(grupo.CC_Reclamacion_Automatica__r.CC_Plantilla_2_Rec_Cliente_Cast__c, null);
                    mapPlantilla.put(grupo.CC_Reclamacion_Automatica__r.CC_Plantilla_2_Rec_Cliente_Cat__c, null);                
                    mapPlantilla.put(grupo.CC_Reclamacion_Automatica__r.CC_Plantilla_3_Rec_Colab_Cast__c, null);
                    mapPlantilla.put(grupo.CC_Reclamacion_Automatica__r.CC_Plantilla_3_Rec_Colab_Cat__c, null);
                    mapPlantilla.put(grupo.CC_Reclamacion_Automatica__r.CC_Plantilla_3_Rec_Cliente_Cast__c, null);
                    mapPlantilla.put(grupo.CC_Reclamacion_Automatica__r.CC_Plantilla_3_Rec_Cliente_Cat__c, null);               
                }
                
                //Plantillas
                if(!mapPlantilla.isEmpty()) {
                    List<EmailTemplate> plantillas = [SELECT HtmlValue, Subject, DeveloperName
                    FROM EmailTemplate WHERE DeveloperName IN :mapPlantilla.keySet() WITH SECURITY_ENFORCED];           
                    
                    for (EmailTemplate plantilla : plantillas) {
                        mapPlantilla.put(plantilla.DeveloperName, plantilla);      
                    }
                    
                    if(!mapTareaEmailMessage.isEmpty()) {
                        //Email anterior, para arrastrarlo en el nuevo email de reclamación automática
                        List<String> listaFromAddress = new List<String>();
                        List<EmailMessage> emails = [SELECT HtmlBody, ToAddress, CcAddress, Subject, FromAddress, HasAttachment
                        FROM EmailMessage WHERE Id IN :mapTareaEmailMessage.keySet()];      
                        
                        if(!emails.isEmpty()){                              
                            for (EmailMessage email : emails) {
                                mapTareaEmailMessage.put(email.Id, email);
                                listaFromAddress.add(email.FromAddress);
                            }
                            
                            List <OrgWideEmailAddress> owa = [SELECT DisplayName, Address FROM OrgWideEmailAddress WHERE Address IN :listaFromAddress LIMIT 1];
                            
                            Map<String, Id> buzonesSalidaCliente = new Map<String, Id>();
                            for (OrgWideEmailAddress correoOwa : [SELECT Address FROM OrgWideEmailAddress]) {
                                buzonesSalidaCliente.put(correoOwa.Address, correoOwa.Id);
                            }
                            
                            //Lista de nuevos mensajes a enviar
                            List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();            
                            List<Task> tareasActualizar = new List<Task>();
                            List<Case> casosActualizar = new List<Case>();
                            List<Task> actividadesReclamacion = new List<Task>();
                            for (Task tarea : listaTareas){
                                if (mapGrupo.containskey(tarea.CC_Grupo_Colaborador_Id__c) && mapTareaCaso.containskey(tarea.WhatId)) {  //LOG: no se ha encontrado G.C. o Caso
                                    CC_Grupo_Colaborador__c grupo = mapGrupo.get(tarea.CC_Grupo_Colaborador_Id__c);
                                    Case caso = mapTareaCaso.get(tarea.WhatId);
                                    //Actualización del caso
                                    Case casoActualizar = new Case();
                                    casoActualizar.Id = caso.Id;
                                    
                                    //Actualización de la tarea
                                    Task tareaActualizar = new Task();
                                    tareaActualizar.Id = tarea.Id;
                                    
                                    Decimal numReclamaciones;
                                    if (caso.CC_Numero_Reclamaciones_Tras_Colab__c == null) {
                                        numReclamaciones = Decimal.valueOf(0);
                                    } else {
                                        numReclamaciones =  caso.CC_Numero_Reclamaciones_Tras_Colab__c;   
                                    }
                                    
                                    EmailTemplate plantillaColaborador;
                                    EmailTemplate plantillaCliente;
                                    Boolean envioCliente = false;
                                    Boolean envioColaborador = false;
                                    Boolean creacionTarea = false;
                                    String numeroReclamacion;
                                    String textoError = '';
                                    if (tarea.CC_Fecha_1_Reclamacion_Auto__c != null) {
                                        if (caso.CC_Idioma__c.equals('ca')  && mapPlantilla.containsKey(grupo.CC_Reclamacion_Automatica__r.CC_Plantilla_1_Rec_Colab_Cat__c)) {
                                            plantillaColaborador = mapPlantilla.get(grupo.CC_Reclamacion_Automatica__r.CC_Plantilla_1_Rec_Colab_Cat__c);
                                            creacionTarea = true;
                                            envioColaborador = true;
                                        } else if (mapPlantilla.containsKey(grupo.CC_Reclamacion_Automatica__r.CC_Plantilla_1_Rec_Colab_Cast__c)) {
                                            plantillaColaborador = mapPlantilla.get(grupo.CC_Reclamacion_Automatica__r.CC_Plantilla_1_Rec_Colab_Cast__c);
                                            creacionTarea = true;
                                            envioColaborador = true;
                                        }
                                        
                                        if (grupo.CC_Reclamacion_Automatica__r.CC_Email_Cliente_1a_Rec__c && caso.CC_Idioma__c.equals('ca')
                                        && mapPlantilla.containskey(grupo.CC_Reclamacion_Automatica__r.CC_Plantilla_1_Rec_Cliente_Cat__c)) {
                                            plantillaCliente = mapPlantilla.get(grupo.CC_Reclamacion_Automatica__r.CC_Plantilla_1_Rec_Cliente_Cat__c);
                                            envioCliente = true;
                                        } else if (grupo.CC_Reclamacion_Automatica__r.CC_Email_Cliente_1a_Rec__c
                                        && mapPlantilla.containskey(grupo.CC_Reclamacion_Automatica__r.CC_Plantilla_1_Rec_Cliente_Cast__c)) {
                                            plantillaCliente = mapPlantilla.get(grupo.CC_Reclamacion_Automatica__r.CC_Plantilla_1_Rec_Cliente_Cast__c);
                                            envioCliente = true;
                                        }
                                        
                                        for (CC_Grupo_Colaborador_Contact__c contacto : grupo.Colaboradores__r) {
                                            if (contacto.CC_Reclamacion_1__c && contacto.CC_Para_CC__c == 'Solo reclamación') {
                                                ccAddresses.add(contacto.CC_Email__c);
                                            }
                                        }
                                        numeroReclamacion = '1';
                                        
                                        //vaciar CC_Fecha_1_Reclamacion_Auto__c
                                        tareaActualizar.CC_Fecha_1_Reclamacion_Auto__c = null;                    
                                        //Actualizar numero de reclamaciones
                                        casoActualizar.CC_Numero_Reclamaciones_Tras_Colab__c = numReclamaciones + Decimal.valueOf(1);                                        
                                        
                                    } else if (tarea.CC_Fecha_2_Reclamacion_Auto__c != null) {
                                        if (caso.CC_Idioma__c.equals('ca') && mapPlantilla.containskey(grupo.CC_Reclamacion_Automatica__r.CC_Plantilla_2_Rec_Colab_Cat__c)) {
                                            plantillaColaborador = mapPlantilla.get(grupo.CC_Reclamacion_Automatica__r.CC_Plantilla_2_Rec_Colab_Cat__c);
                                            creacionTarea = true;
                                            envioColaborador = true;
                                        } else if (mapPlantilla.containskey(grupo.CC_Reclamacion_Automatica__r.CC_Plantilla_2_Rec_Colab_Cast__c)) {
                                            plantillaColaborador = mapPlantilla.get(grupo.CC_Reclamacion_Automatica__r.CC_Plantilla_2_Rec_Colab_Cast__c);
                                            creacionTarea = true;
                                            envioColaborador = true;
                                        }
                                        
                                        if (grupo.CC_Reclamacion_Automatica__r.CC_Email_Cliente_2a_Rec__c && caso.CC_Idioma__c.equals('ca')
                                        && mapPlantilla.containskey(grupo.CC_Reclamacion_Automatica__r.CC_Plantilla_2_Rec_Cliente_Cat__c)) {
                                            plantillaCliente = mapPlantilla.get(grupo.CC_Reclamacion_Automatica__r.CC_Plantilla_2_Rec_Cliente_Cat__c);
                                            envioCliente = true;
                                        } else if (grupo.CC_Reclamacion_Automatica__r.CC_Email_Cliente_2a_Rec__c
                                        && mapPlantilla.containskey(grupo.CC_Reclamacion_Automatica__r.CC_Plantilla_2_Rec_Cliente_Cast__c)) {
                                            plantillaCliente = mapPlantilla.get(grupo.CC_Reclamacion_Automatica__r.CC_Plantilla_2_Rec_Cliente_Cast__c);
                                            envioCliente = true;
                                        }
                                        
                                        for (CC_Grupo_Colaborador_Contact__c contacto : grupo.Colaboradores__r) {
                                            if (contacto.CC_Reclamacion_2__c  && contacto.CC_Para_CC__c == 'Solo reclamación') {
                                                ccAddresses.add(contacto.CC_Email__c);
                                            }
                                        }
                                        numeroReclamacion = '2';
                                        //vaciar CC_Fecha_2_Reclamacion_Auto__c
                                        tareaActualizar.CC_Fecha_2_Reclamacion_Auto__c = null;                    
                                        //Actualizar numero de reclamaciones
                                        casoActualizar.CC_Numero_Reclamaciones_Tras_Colab__c = numReclamaciones + Decimal.valueOf(1);     
                                    } else if (tarea.CC_Fecha_3_Reclamacion_Auto__c != null) {
                                        if (caso.CC_Idioma__c.equals('ca') && mapPlantilla.containskey(grupo.CC_Reclamacion_Automatica__r.CC_Plantilla_3_Rec_Colab_Cat__c)) {
                                            plantillaColaborador = mapPlantilla.get(grupo.CC_Reclamacion_Automatica__r.CC_Plantilla_3_Rec_Colab_Cat__c);
                                            creacionTarea = true;
                                            envioColaborador = true;
                                        } else if (mapPlantilla.containskey(grupo.CC_Reclamacion_Automatica__r.CC_Plantilla_3_Rec_Colab_Cast__c)) {
                                            plantillaColaborador = mapPlantilla.get(grupo.CC_Reclamacion_Automatica__r.CC_Plantilla_3_Rec_Colab_Cast__c);
                                            creacionTarea = true;
                                            envioColaborador = true;
                                        }
                                        
                                        if (grupo.CC_Reclamacion_Automatica__r.CC_Email_Cliente_3a_Rec__c && caso.CC_Idioma__c.equals('ca') 
                                        && mapPlantilla.containskey(grupo.CC_Reclamacion_Automatica__r.CC_Plantilla_3_Rec_Cliente_Cat__c)) {
                                            plantillaCliente = mapPlantilla.get(grupo.CC_Reclamacion_Automatica__r.CC_Plantilla_3_Rec_Cliente_Cat__c);
                                            envioCliente = true;
                                        } else if (grupo.CC_Reclamacion_Automatica__r.CC_Email_Cliente_3a_Rec__c
                                        && mapPlantilla.containskey(grupo.CC_Reclamacion_Automatica__r.CC_Plantilla_3_Rec_Cliente_Cast__c)) {
                                            plantillaCliente = mapPlantilla.get(grupo.CC_Reclamacion_Automatica__r.CC_Plantilla_3_Rec_Cliente_Cast__c);
                                            envioCliente = true;
                                        }
                                        
                                        for (CC_Grupo_Colaborador_Contact__c contacto : grupo.Colaboradores__r) {
                                            if (contacto.CC_Reclamacion_3__c && contacto.CC_Para_CC__c == 'Solo reclamación') {
                                                ccAddresses.add(contacto.CC_Email__c);
                                            }
                                        }
                                        numeroReclamacion = '3';
                                        
                                        //vaciar CC_Fecha_1_Reclamacion_Auto__c
                                        tareaActualizar.CC_Fecha_3_Reclamacion_Auto__c = null;                    
                                        //Actualizar numero de reclamaciones
                                        casoActualizar.CC_Numero_Reclamaciones_Tras_Colab__c = numReclamaciones + Decimal.valueOf(1);
                                    } else if (tarea.OS_Fecha_Fin_Reclamacion_Auto__c != null) {
                                        //cambiar propietario del caso al indicado ()
                                        if (grupo.CC_Reclamacion_Automatica__r.OS_Asignar_Usuario__c != null) {
                                            casoActualizar.OwnerId = grupo.CC_Reclamacion_Automatica__r.OS_Asignar_Usuario__c;
                                            
                                        } else if (grupo.CC_Reclamacion_Automatica__r.OS_Asignar_GrupoTrabajo__c != null) {
                                            List <CC_Grupo_Colaborador__c> grupoDeTrabajo = [SELECT Id, Name, OS_GrupoTrabajo__c FROM CC_Grupo_Colaborador__c  WHERE Id = :grupo.CC_Reclamacion_Automatica__r.OS_Asignar_GrupoTrabajo__c WITH SECURITY_ENFORCED LIMIT 1];
                                            List <Group> publicGroup = new List <Group> ();
                                            
                                            if (!grupoDeTrabajo.isEmpty()) {
                                                publicGroup = [SELECT Id, Name, DeveloperName FROM Group WHERE Type = 'Regular' AND Name LIKE :('%' + grupoDeTrabajo[0].OS_GrupoTrabajo__c + '%')  WITH SECURITY_ENFORCED LIMIT 1];
                                            }
                                            
                                            if (!publicGroup.isEmpty()) {
                                                casoActualizar.OwnerId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = :publicGroup[0].DeveloperName WITH SECURITY_ENFORCED LIMIT 1].Id;
                                            } 
                                        }    
                                        
                                        casoActualizar.CC_Ultima_Interaccion__c = 'Fin reclamación';
                                        
                                        //cambiar estado del caso al indicado (OS_EstadoCaso__c)
                                        if (grupo.CC_Reclamacion_Automatica__r.OS_EstadoCaso__c != null) {
                                            Id rtCaseEmpleado = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
                                            if(grupo.CC_Reclamacion_Automatica__r.OS_EstadoCaso__c == 'Cerrado' && caso.RecordTypeId == rtCaseEmpleado) {
                                                casoActualizar.CC_Admin__c = true;
                                                casoActualizar.CC_Cerrado_Operativa__c = Datetime.Now();
                                                if(String.isEmpty(caso.CC_Detalles_Consulta__c)){
                                                    casoActualizar.CC_Detalles_Consulta__c = 'Cierre automático por falta de respuesta del empleado.';
                                                }
                                                if (String.isEmpty(caso.CC_Detalles_Solucion__c)) {
                                                    casoActualizar.CC_Detalles_Solucion__c = 'Cierre automático por falta de respuesta del empleado.'; 
                                                }
                                            }
                                            casoActualizar.Status = grupo.CC_Reclamacion_Automatica__r.OS_EstadoCaso__c;
                                        }
                                        
                                        creacionTarea = true;
                                        //vaciar OS_Fecha_Fin_Reclamacion_Auto__c
                                        tareaActualizar.OS_Fecha_Fin_Reclamacion_Auto__c = null; 
                                        
                                        List<Task> tareaTraslado = [SELECT Id, Status, RecordType.DeveloperName FROM Task WHERE WhatId = :caso.Id AND Type = 'Traslado Colaborador' AND Status = 'Open' WITH SECURITY_ENFORCED LIMIT 1];
                                        if (!tareaTraslado.isEmpty()) {
                                            tareaActualizar.Status = 'Rechazada';
                                            Id rtTareaCC = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
                                            if(tareaTraslado[0].RecordTypeId == rtTareaCC) {
                                                if(caso.CC_Canal_Operativo__c == null) {
                                                    casoActualizar.CC_Canal_Operativo__c = 'Oficina';
                                                }
                                                tareaActualizar.Status = 'Completed';
                                                casoActualizar.CC_Fin_Pendiente_Colaborador__c = Datetime.Now();
                                                casoActualizar.CC_NoRespondido__c = true;
                                            }
                                        }            
                                    }
                                    
                                    if (envioColaborador) {
                                        //LOG: si no entra, no se ha encontrado la plantilla
                                        EmailMessage emailAnterior = new EmailMessage();
                                        if (mapTareaEmailMessage.containskey(tarea.CC_Correo_Asociado_Id__c)) {
                                            emailAnterior = mapTareaEmailMessage.get(tarea.CC_Correo_Asociado_Id__c);
                                        }                      
                                        //Generamos el email a enviar. Debe mantener el cuerpo del email anterior y agregar el cuerpo de la plantilla recuperada
                                        //También debe mantener el asunto del email anterior junto con el nuevo asunto
                                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                                        if (emailAnterior != null) {
                                            email.setHtmlBody(plantillaColaborador.HtmlValue + '<br />' + '-------------------------------------------------------------------------------------------------------------------' 
                                            + '<br />' + '<br />' + emailAnterior.HtmlBody);
                                        } else {
                                            email.setHtmlBody(plantillaColaborador.HtmlValue);
                                        }
                                        email.setSaveAsActivity(true);
                                        email.setTreatBodiesAsTemplate(true);
                                        email.setWhatId(caso.Id); 
                                        email.setTargetObjectId(caso.ContactId);
                                        email.setTreatTargetObjectAsRecipient(false);                        
                                        if (!owa.isEmpty()){
                                            email.setOrgWideEmailAddressId(owa[0].Id);
                                        }                    
                                        email.subject = plantillaColaborador.Subject;
                                        
                                        //Recorrer tareas para buscar tarea de traslado colaborador en estado pendiente
                                        Set<Id> setTaskIDs = new Set<Id>();
                                        for (Task taskTraslado : [SELECT CC_Correo_Asociado_Id__c 
                                        FROM Task WHERE WhatId = :caso.Id AND Type = 'Traslado Colaborador' AND Status = 'Open' WITH SECURITY_ENFORCED]) {
                                            setTaskIDs.add(taskTraslado.CC_Correo_Asociado_Id__c);
                                        }
                                        //Recoger id de ContentDocumentLink de los ids referenciados al EmailMessage asociado a la tarea   
                                        Set<Id> setContentDocumentLinkIDsTraslado = new Set<Id>();           
                                        for (ContentDocumentLink cDocumentLink : [SELECT ContentDocumentId, LinkedEntityId
                                        FROM ContentDocumentLink WHERE LinkedEntityId IN :setTaskIDs WITH SECURITY_ENFORCED]) {
                                            setContentDocumentLinkIDsTraslado.add(cDocumentLink.ContentDocumentId);
                                        }
                                        
                                        //Recorrer el ContentVersion para enviar el attachment
                                        if (mapCaseContentVersion.containsKey(caso.Id)) {
                                            List<Messaging.EmailFileAttachment> attachmentsEmailsCaso = new List<Messaging.EmailFileAttachment>();
                                            for (ContentVersion cVersion : mapCaseContentVersion.get(caso.Id)) {
                                                if(setContentDocumentLinkIDsTraslado.contains(cVersion.ContentDocumentId)){
                                                    //Rellenar contenido del adjunto
                                                    Blob bfile = cVersion.VersionData;
                                                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();                        
                                                    efa.setFileName(cVersion.Title + '.' + cVersion.FileExtension);
                                                    efa.setBody(bfile);
                                                    attachmentsEmailsCaso.add(efa);
                                                    //email.setFileAttachments(new Messaging.EmailFileAttachment[]{efa});
                                                }
                                                
                                            }
                                            email.setFileAttachments(attachmentsEmailsCaso);
                                        }
                                        //También debe mantener los destinatarios del To del email anterior  
                                        if (emailAnterior != null) {
                                            List<String> destinatariosToAddress;
                                            if (emailAnterior.ToAddress != null && emailAnterior.ToAddress != '') {
                                                destinatariosToAddress = emailAnterior.ToAddress.split(';');
                                            }   
                                            
                                            List<String> destinatariosCcAddress;
                                            if (emailAnterior.CcAddress != null && emailAnterior.CcAddress != '') {
                                                destinatariosCcAddress = emailAnterior.CcAddress.split(';');
                                                ccAddresses.addAll(destinatariosCcAddress);    
                                            }
                                            email.setToAddresses(destinatariosToAddress);                        
                                        }
                                        email.setCcAddresses(ccAddresses);
                                        allmsg.add(email); 
                                    }
                                    
                                    //Generamos el email a enviar al Cliente en caso que aplique
                                    if (envioCliente) {
                                        //LOG: Si grupo.CC_Reclamacion_Automatica__r.CC_Email_Cliente_3a_Rec__c = TRUE y envioCliente = FALSE, falta la plantilla
                                        String[] toContactAddresses = new String[]{};
                                        toContactAddresses.add(caso.Contact.Email);
                                        Messaging.SingleEmailMessage emailCliente = new Messaging.SingleEmailMessage();
                                        emailCliente.setToAddresses(toContactAddresses);
                                        emailCliente.setTemplateId(plantillaCliente.Id);
                                        emailCliente.setSaveAsActivity(true);
                                        emailCliente.setWhatId(caso.Id); 
                                        emailCliente.setTargetObjectId(caso.ContactId);
                                        if (buzonesSalidaCliente.containskey(caso.CC_Buzon_Salida__c)) {
                                            emailCliente.setOrgWideEmailAddressId(buzonesSalidaCliente.get(caso.CC_Buzon_Salida__c));
                                        }
                                        allmsg.add(emailCliente);
                                    }
                                    
                                    //Tratamiento de mensajes de errores en mapas
                                    if (!envioCliente && (grupo.CC_Reclamacion_Automatica__r.CC_Email_Cliente_1a_Rec__c||
                                    grupo.CC_Reclamacion_Automatica__r.CC_Email_Cliente_2a_Rec__c||grupo.CC_Reclamacion_Automatica__r.CC_Email_Cliente_3a_Rec__c)) {
                                        
                                        textoError = textoError + 'No se ha encontrado la plantilla de cliente. ';
                                    }
                                    if (!envioColaborador && (tarea.CC_Fecha_1_Reclamacion_Auto__c != null || 
                                    tarea.CC_Fecha_2_Reclamacion_Auto__c != null || tarea.CC_Fecha_3_Reclamacion_Auto__c != null)) {
                                        textoError = textoError + 'No se ha encontrado la plantilla de colaborador. ';
                                    } 
                                    
                                    if (creacionTarea || textoError != '') {
                                        //Generamos tarea para la reclamación o para registrar el error en el envío del email
                                        Task actividadReclamacion = new Task();
                                        //actividadReclamacion.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task');
                                        actividadReclamacion.recordTypeId = tarea.RecordTypeId;
                                        actividadReclamacion.Type = 'Reclamación Traslado Colaborador';
                                        if (numeroReclamacion != null && textoError == '') {
                                            actividadReclamacion.Subject = numeroReclamacion + 'ª Reclamación Traslado Colaborador';
                                        } else if (textoError == '') {
                                            actividadReclamacion.Subject = 'Fin Reclamación Traslado Colaborador';
                                        } else {
                                            actividadReclamacion.Subject = 'Error en el envío de Reclamación';
                                            actividadReclamacion.Description = textoError;
                                        }
                                        actividadReclamacion.WhatId = caso.Id;
                                        actividadReclamacion.Status = 'Completed';
                                        actividadReclamacion.CC_Grupo_Colaborador_Id__c = grupo.Id;
                                        actividadReclamacion.ActivityDate = System.today();
                                        
                                        actividadesReclamacion.add(actividadReclamacion);
                                    }
                                    
                                    tareasActualizar.add(tareaActualizar);
                                    casosActualizar.add(casoActualizar);
                                }
                            }
                            //Enviamos todos los mensajes
                            if (!allmsg.isEmpty()) {
                                //Omitir validación trigger
                                CSBD_Bypass_Trigger.bypass('OS_EmailMessage_BI_TRHan_ValidarDestinatario');
                                try {
                                    Messaging.SendEmailResult[] r = Messaging.sendEmail(allmsg, false); 
                                    for (Messaging.SendEmailResult sr : r) {
                                        if (!sr.isSuccess()) {
                                            for (Database.Error err : sr.getErrors()) {
                                                CBK_log.debug(err.getStatusCode() + ': ' + err.getMessage());
                                                CBK_log.debug('Fields that affected this error: ' + err.getFields());
                                            }
                                        }
                                    }  
                                }
                                finally {
                                    CSBD_Bypass_Trigger.undoBypass('OS_EmailMessage_BI_TRHan_ValidarDestinatario');
                                }                 
                            }
                            //Creamos tareas para las reclamaciones
                            if (!actividadesReclamacion.isEmpty() && Schema.sObjectType.Task.fields.Status.isCreateable()) {
                                insert actividadesReclamacion;                   
                            }
                            
                            //DataBase Update para la lista de Tasks.
                            if(!tareasActualizar.isEmpty() && Schema.sObjectType.Task.fields.Status.isUpdateable()){
                                Database.update(tareasActualizar, false);   
                            }
                            
                            //Update caso para contar las reclamaciones realizadas al colaborador
                            if(!casosActualizar.isEmpty() && Schema.sObjectType.Case.fields.Status.isUpdateable()){
                                Database.update(casosActualizar, false);    
                            }
                        }
                    }
                }
            }
        }
    }
    
    public static void fechasPendingProcess(Case caso, Task actividad){
        //Método para recoger las fechas de las reclamaciones e ir insertándolas una a una.
        Set <Datetime> fechasReclamaciones = new Set<Datetime>();
        
        if(actividad.CC_Fecha_1_Reclamacion_Auto__c != null){
            fechasReclamaciones.add(actividad.CC_Fecha_1_Reclamacion_Auto__c);
        }
        if(actividad.CC_Fecha_2_Reclamacion_Auto__c != null){
            fechasReclamaciones.add(actividad.CC_Fecha_2_Reclamacion_Auto__c);
        }
        if(actividad.CC_Fecha_3_Reclamacion_Auto__c != null){
            fechasReclamaciones.add(actividad.CC_Fecha_3_Reclamacion_Auto__c);
        }
        if(actividad.OS_Fecha_Fin_Reclamacion_Auto__c != null){
            fechasReclamaciones.add(actividad.OS_Fecha_Fin_Reclamacion_Auto__c);
        }        
        insertarPendingProcess(fechasReclamaciones, actividad, caso);
    }
    
    public static void insertarPendingProcess(Set<Datetime> fechasRecl, Task actividad, Case caso){
        //Método para insertar registros en el objeto PendingProcess para que nos devuelva una "alerta" a la hora de las reclamaciones.
        List<CBK_SCH_PendingProcess__c> listPendProcess = new List<CBK_SCH_PendingProcess__c>();
        
        for(Datetime fecha : fechasRecl){
            CBK_SCH_PendingProcess__c pendingProcessRecl = new CBK_SCH_PendingProcess__c();
            pendingProcessRecl.RecordId__c = caso.Id;
            pendingProcessRecl.Schedule_Time__c = fecha;
            pendingProcessRecl.ClassName__c = 'CBK_SCH_Reclamaciones_Auto';
            //insert pendingProcessCita;
            listPendProcess.add(pendingProcessRecl);
        }
        insert listPendProcess;
    }    
}