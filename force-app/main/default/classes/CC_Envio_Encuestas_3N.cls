public without sharing class CC_Envio_Encuestas_3N {
    @InvocableMethod
    public static void enviarEncuesta(List<Id> idsCasos) {
        List<CC_Lista_Valores__c> listaCanalResolucion = [SELECT CC_Valor__c, CC_Activa__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'Envío de Encuesta 3N - Canales de resolución'];
        Set<String> valoresCanales = new Set<String>();
        for (CC_Lista_Valores__c resolucion : listaCanalResolucion) {
            if(resolucion.CC_Activa__c){
                valoresCanales.add(resolucion.CC_Valor__c);
            }
        }
        //Comprobar que el valor de canal de resolucion este en la lista
        ////No enviar encuesta si es un caso de CSI Bankia
        
    	// List<Case> casosTelefonia = Database.query('SELECT Id, Origin, CaseNumber, CC_En_Tercer_Nivel__c, ContactId, CC_Canal_Resolucion__c, CC_Canal_Procedencia__c, CC_Idioma__c, CC_URL_Encuesta_3N__c, RecordTypeId, CC_Matricula_Empleado__c, CC_MCC_Tematica__c,CC_Tematica__c, CC_MCC_Tematica__r.Name, CC_MCC_Tematica__r.CC_IdCognitivo__c, RecordType.Name FROM Case WHERE Id IN :idsCasos AND RecordType.DeveloperName = \'CC_Empleado\' AND ContactId <> NULL AND Contact.Email <> NULL AND Origin = \'Phone\' AND AccountId <> NULL AND Account.CC_Tipo_Centro__c = \'OF\' AND Account.CC_SubTipo_Centro__c = \'BP\'');
    	List<Case> casosTelefonia = Database.query('SELECT Id, Origin, CaseNumber, CC_En_Tercer_Nivel__c, ContactId, CC_Canal_Resolucion__c, CC_Canal_Procedencia__c, CC_Idioma__c, CC_URL_Encuesta_3N__c, RecordTypeId, CC_Matricula_Empleado__c, CC_Grupo_Colaborador__c, CC_MCC_Tematica__c,CC_Tematica__c, CC_MCC_Tematica__r.Name, CC_MCC_Tematica__r.CC_IdCognitivo__c, RecordType.Name FROM Case WHERE Id IN :idsCasos AND RecordType.DeveloperName = \'CC_Empleado\' AND ContactId <> NULL AND Contact.Email <> NULL AND Origin = \'Phone\' AND AccountId <> NULL');
        if (casosTelefonia.size() > 0) {
            enviarEncuestaFuture(casosTelefonia, true);
        } else{
        	List<Case> casos = Database.query('SELECT Id, Origin, CaseNumber, ContactId, CC_En_Tercer_Nivel__c, CC_Canal_Resolucion__c, CC_Canal_Procedencia__c, CC_Idioma__c, CC_URL_Encuesta_3N__c, RecordTypeId, CC_Matricula_Empleado__c, CC_Grupo_Colaborador__c, CC_MCC_Tematica__c,CC_Tematica__c, CC_MCC_Tematica__r.Name, CC_MCC_Tematica__r.CC_IdCognitivo__c, RecordType.Name FROM Case WHERE Id IN :idsCasos AND CC_Canal_Resolucion__c IN :valoresCanales AND RecordType.DeveloperName  <> \'CC_CSI_Bankia\' AND ContactId <> NULL AND Contact.Email <> NULL');       
			if (casos.size() > 0) {
            	enviarEncuestaFuture(casos, false);
            }
        }
    }
    
    public static void enviarEncuestaFuture(List<Case> casos, Boolean casoTelefonia) {
        Set<Id> idsCasosSet = new Set<Id>();
        Set<Id> idsCasosEnvioEncuesta = new Set<Id>();
        //Solucion IN Too many Email Invocations: 11
        List<Messaging.SingleEmailmessage> oListMail = new List<Messaging.SingleEmailmessage>();
        
        if(casoTelefonia) {
            for (Case caso : casos) {
                idsCasosEnvioEncuesta.add(caso.Id);
            }
        } else {
            Map<Id, String> mapAgrupadores = new Map<Id, String>();        
            mapAgrupadores.put(CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Agrupador__c', 'CC_Seguimiento'), 'CC_Seguimiento');
            mapAgrupadores.put(CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Agrupador__c', 'CC_Comunicacion_Informativa'), 'CC_Comunicacion_Informativa');
            mapAgrupadores.put(CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Agrupador__c', 'CC_Comunicacion_Informativa_de_Campana'), 'CC_Comunicacion_Informativa_de_Campana');
            mapAgrupadores.put(CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Agrupador__c', 'CC_Incidencia'), 'CC_Incidencia');
            mapAgrupadores.put(CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Agrupador__c', 'CC_Masiva_Control'), 'CC_Masiva_Control');
            
            for (Case caso : casos) {
                idsCasosSet.add(caso.Id);
            }
            
            for(Task oTask : [SELECT Id, Type, status, Agrupador__c, WhatId FROM Task WHERE WhatId IN :idsCasosSet]){
                if((oTask.Type=='Traslado Tercer Nivel' && oTask.status != 'Rechazada') ||
                (oTask.Type=='Traslado Colaborador' && oTask.status != 'Rechazada') ||
                oTask.Type=='Traslado Incidencia' && mapAgrupadores.get(oTask?.Id) != 'CC_Seguimiento')
                {
                    idsCasosEnvioEncuesta.add(oTask.WhatId);
                }
            }
        }
        
        //Comprobar que hay un caso para enviar la encuesta
        if (idsCasosEnvioEncuesta.size() > 0) {
            
            List<Case> listCasos = new List<Case>();
            for (Case caso : casos) {
                if(idsCasosEnvioEncuesta.contains(caso?.Id)) {
                    listCasos.add(caso);
                }             
            }
            
            Map<String, Id> mapIdIdiomaPlantilla = new Map<String, Id>();
            List<EmailTemplate> emailPlantillas = [SELECT Id, htmlvalue, DeveloperName FROM EmailTemplate WHERE DeveloperName = 'Encuesta_Offline' OR DeveloperName = 'Enquesta_Offline'];
            for(EmailTemplate emailp : emailPlantillas){
                if(emailp.DeveloperName == 'Enquesta_Offline'){
                    mapIdIdiomaPlantilla.put('ca', emailp.Id);
                } else if (emailp.DeveloperName == 'Encuesta_Offline') {
                    mapIdIdiomaPlantilla.put('es', emailp.Id);
                }
            }

           String referencia;
           Map<Id, Case> mapReferenciaCasos = new Map<Id, Case>();
           Map<Id, String> encuesta = CC_MetodosUtiles.generarURLsLimeSurvey(listCasos);
               for(Case caso : listCasos){
                   referencia = CC_EmailMessage.generarReferenciaCorreoSaliente(caso.Id);
                    caso.CC_URL_Encuesta_3N__c = !encuesta.isEmpty() ? encuesta.get(caso.Id) : null;
                    caso.CC_Referencia_Correo_Saliente__c = referencia;
                    mapReferenciaCasos.put(caso.Id, caso);
                }
                update listCasos;
            
            
            List<Task> tasks = new List<Task>();          
            List<CC_Buzones_Por_Defecto__mdt> buzones = [SELECT CC_Direccion_Correo__c, CC_Canal_Procedencia__c FROM CC_Buzones_Por_Defecto__mdt
            WHERE (CC_Canal_Procedencia__c = 'Por defecto empleados' OR CC_Canal_Procedencia__c = 'Por defecto') AND CC_Idioma__c <> 'CSI'];
            Map<String, String> mapBuzonesDefecto = new Map<String, String> ();            
            for(CC_Buzones_Por_Defecto__mdt buzondefecto : buzones){
                mapBuzonesDefecto.put(buzondefecto.CC_Canal_Procedencia__c, buzondefecto.CC_Direccion_Correo__c);
            }
            
            List<OrgWideEmailAddress> remitentesEmails = [SELECT Id, Address FROM OrgWideEmailAddress];
            Map<String, Id> mapIdOrgWide = new Map<String, String> ();            
            for(OrgWideEmailAddress idOrgWide : remitentesEmails){
                mapIdOrgWide.put(idOrgWide.Address, idOrgWide.Id);
            }

            // Map<Id, Boolean> mapaResultados = new Map<Id, Boolean>();
            Map<Id, Boolean> mapaResultados = comprobarEncuesta(casos);
            
            for(Integer i = 0; i< listCasos.size(); i++){
                
                String remitente = mapBuzonesDefecto.get('Por defecto empleados');
                
                Id remitenteId;
                remitenteId = mapIdOrgWide.get(remitente);             

                //Si el caso es de FCO no se debe enviar la encuesta (US859756)
                if ((listCasos[i].CC_En_Tercer_Nivel__c && listCasos[i].CC_Canal_Procedencia__c != 'Formulario Consultas Operativas') || (!listCasos[i].CC_En_Tercer_Nivel__c && mapaResultados.get(listCasos[i].Id) == false || mapaResultados.isEmpty())) {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setSaveAsActivity(true);
                    mail.setWhatId(listCasos[i].Id);
                    
                    //Elegir idioma de la plantilla
                    if(listCasos[i].CC_Idioma__c != 'ca'){
                        mail.setTemplateId(mapIdIdiomaPlantilla.get('es'));
                    } else {
                        mail.setTemplateId(mapIdIdiomaPlantilla.get('ca'));
                    }
                    mail.setTargetObjectId(listCasos[i].ContactId);
                    mail.setTreatTargetObjectAsRecipient(true);
                    mail.setOrgWideEmailAddressId(remitenteId);
                    oListMail.add(mail);
                }
            }            
            
            // Lanzar las peticiones de mensajes a enviar.
            if (!oListMail.isEmpty()) {
                List<Messaging.SingleEmailmessage> oMaxEnvios = new List<Messaging.SingleEmailmessage>();
                Integer iMensaje = 0;
                Integer iTotalMsj = oListMail.size();
                
                for (Integer iMens = 0; iMens < iTotalMsj; iMens++) {
                    oMaxEnvios.add(oListMail[iMens]);
                    iMensaje = iMensaje + 1;
                    if (iMensaje == 10 || iMens == iTotalMsj-1){
                        // Enviar bloques de 10 mensajes máximo.
                        List<Messaging.SendEmailResult> oDataRes = Messaging.sendEmail(oMaxEnvios, false);
                        // Suponemos que el orden de devolución de resultados, es el orden de entrada de la lista de e-mails.
                        // Actualizamos estado en función de ello.
                        for (Integer iRes = 0; iRes<oDataRes.size(); iRes++) {
                            if (oDataRes[iRes].isSuccess()) {
                                for (Case caso : listCasos) {
                                    Task tarea = new Task();
                                    tarea.Status = 'Completed';
                                    if(casoTelefonia) {
                                        tarea.Type = 'Envío de petición encuesta Banca Privada C2C';
                                    } else {
                                        tarea.Type = 'Envío de petición encuesta 3N';
                                    }
                                    tarea.Subject = 'Email: Encuesta Satisfacción Contact Center Oficinas';
                                    tarea.WhatId = oMaxEnvios[iRes].getWhatId();
                                    tasks.add(tarea);
                                }
                            }
                        }
                        // Resetear variable de conteo y lista de envíos.
                        oMaxEnvios.clear();
                        iMensaje = 0;
                    }
                }
                //insert tasks;
                CC_Activity.crearActividades(tasks);
            }
        }
    }

    private static Map<Id, Boolean> comprobarEncuesta(List<Case> casos) {
        Map<Id, Boolean> mapResultado = new Map<Id, Boolean>();
        if (!casos.isEmpty()) {
            String plantillaCAS = CC_Settings__c.getValues('CC_Encuesta_CCO')?.CC_Configuracion_10__c;
            String plantillaCAT = CC_Settings__c.getValues('CC_Encuesta_CCO')?.CC_Configuracion_11__c;
            for (Case caso : casos) {
                mapResultado.put(caso.Id, false);
            }
            
            for (EmailMessage mail : [SELECT ParentId FROM EmailMessage WHERE ParentId IN :mapResultado.keySet() AND CC_Plantilla__c IN (:plantillaCAS,:plantillaCAT)]) {
                mapResultado.put(mail.parentId, true);
            }
        }
    return mapResultado;
    }
}