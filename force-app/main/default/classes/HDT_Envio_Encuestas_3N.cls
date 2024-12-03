public with sharing class HDT_Envio_Encuestas_3N {
    @InvocableMethod
    public static void enviarEncuesta(List<Id> idsCasos) {
       
        List<CC_Lista_Valores__c> listaCanalResolucion = [SELECT Name,CC_Valor__c, CC_Activa__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'HDT - Envío de Encuesta 3N - Canales de resolución'];

		Set<String> valoresCanales = new Set<String>();
        for (CC_Lista_Valores__c resolucion : listaCanalResolucion) {
            if(resolucion.CC_Activa__c){
                valoresCanales.add(resolucion.Name);
            }
        }

        //Comprobar que el valor de canal de resolucion este en la lista             
        ////No enviar encuesta si es un caso de CSI Bankia            
        List<Case> casos = Database.query('SELECT Id, Origin, CaseNumber, ContactId, CC_Canal_Resolucion__c, CC_Canal_Procedencia__c, CC_Idioma__c, CC_URL_Encuesta_3N__c, RecordTypeId, CC_Matricula_Empleado__c, CC_MCC_Tematica__c, CC_MCC_Tematica__r.Name, CC_MCC_Tematica__r.CC_IdCognitivo__c, RecordType.Name FROM Case WHERE Id IN :idsCasos AND CC_Canal_Resolucion__c IN :valoresCanales AND RecordType.DeveloperName  <> \'CC_CSI_Bankia\' AND ContactId <> NULL AND Contact.Email <> NULL');       
      
        if (casos.size() > 0) {
        	enviarEncuestaFuture(casos);
        }
    }
    
    public static void enviarEncuestaFuture(List<Case> casos){

        if(!casos.isEmpty()){

            List<CC_Lista_Valores__c> listaCanalResolucion = [SELECT Name,CC_Valor__c, CC_Activa__c FROM CC_Lista_Valores__c WHERE CC_Valor__c = 'No EDG' AND CC_Lista__r.Name = 'HDT - Envío de Encuesta 3N - Canales de resolución'];

            Set<String> canalesResolucionPrimeros = new Set<String>();
            for (CC_Lista_Valores__c resolucion : listaCanalResolucion) {
                if(resolucion.CC_Activa__c){
                    canalesResolucionPrimeros.add(resolucion.Name);
                }
            }

            List<CC_Lista_Valores__c> listaCanalResolucionEDG = [SELECT Name,CC_Valor__c, CC_Activa__c FROM CC_Lista_Valores__c WHERE CC_Valor__c = 'EDG' AND CC_Lista__r.Name = 'HDT - Envío de Encuesta 3N - Canales de resolución'];

            Set<String> canalesResolucionEdG = new Set<String>();
            for (CC_Lista_Valores__c resolucion : listaCanalResolucionEDG) {
                if(resolucion.CC_Activa__c){
                    canalesResolucionEdG.add(resolucion.Name);
                }
            }

            //Recogemos las plantillas
            String apiNamePlantillas = 'HDT_Encuesta_Offline_Notificacion_%';
            String apiNamePlantillasEdG = 'HDT_Encuesta_Offline_Notificacion_EDG_%';

            //Traemos las Emails Templates para utilizarlas
            List <EmailTemplate> plantillasNoEdG = [SELECT Id, DeveloperName FROM EmailTemplate WHERE DeveloperName = 'HDT_Survey_Offline_Notificacion_IN' OR DeveloperName = 'HDT_Encuesta_Offline_Notificacion_ES' OR DeveloperName = 'HDT_Enquesta_Offline_Notificacion_CA'];
            List <EmailTemplate> plantillasEdG =  [SELECT Id,DeveloperName FROM EmailTemplate WHERE DeveloperName LIKE : apiNamePlantillasEdG ORDER BY DeveloperName];
                

            Set<Id> idsCasosSet = new Set<Id>();
            Set<Id> idsCasosEnvioEncuesta = new Set<Id>();
            //Solucion IN Too many Email Invocations: 11
            List<Messaging.SingleEmailmessage> oListMail = new List<Messaging.SingleEmailmessage>();

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
            
            //Comprobar que hay un caso para enviar la encuesta
            if (idsCasosEnvioEncuesta.size() > 0) {
                List <EmailTemplate> plantillas;
                //Recogemos el Custom Setting para obtener las direcciones de correo de respuesta
                HDT_Parametros__c emailRespuesta = HDT_Parametros__c.getInstance('HDT_Email_Respuesta_Empleados_New');
                //Recogemos los Ids del remitente ordenadas alfabeticamente por la direccion (0: Catalan, 1 Castellano) en el caso de que existan los 2
                List <OrgWideEmailAddress> remitentesId = [SELECT Id FROM OrgWideEmailAddress WHERE Address IN (: emailrespuesta.HDT_Configuracion_1__c, : emailrespuesta.HDT_Configuracion_2__c) ORDER BY Address];
                Map<String, Id> mapIdIdiomaPlantilla = new Map<String, Id>();
                List<Case> listCasos = new List<Case>();

                for (Case caso : casos) {
                    if(idsCasosEnvioEncuesta.contains(caso?.Id)) {
                        listCasos.add(caso);
                        //Primero comprobamos el canal de procedecencia del caso para saber si es EDG o NO. Y recoger unas plantillas u otras.
                         //Comprobamos que plantillas tenemos que recoger. Si es EdG o no. 
                        if (canalesResolucionPrimeros.contains(caso.CC_Canal_Resolucion__c)) {      //Caso para NO EDG's
                            //Utiilzamos las plantillas para no EdG
                            plantillas = plantillasNoEdG;

                            //Ahora buscamos el idioma del caso y la plantilla a utilizar
                            for(EmailTemplate emailp : plantillas){

                                if(emailp.DeveloperName == 'HDT_Enquesta_Offline_Notificacion_CA'){
                                    mapIdIdiomaPlantilla.put('ca', emailp.Id);
                                }
                                
                                if(emailp.DeveloperName == 'HDT_Encuesta_Offline_Notificacion_ES'){
                                    mapIdIdiomaPlantilla.put('es', emailp.Id);
                                }

                                if(emailp.DeveloperName == 'HDT_Survey_Offline_Notificacion_IN'){
                                    mapIdIdiomaPlantilla.put('en', emailp.Id);
                                }
                            }
                        }

                        if (canalesResolucionEdG.contains(caso.CC_Canal_Resolucion__c)) {      //Caso para las  EDG's
                            //Utiilzamos las plantillas para no EdG
                            plantillas = plantillasEdG;

                            //Ahora buscamos el idioma del caso y la plantilla a utilizar
                            for(EmailTemplate emailp : plantillas){

                                if(emailp.DeveloperName == 'HDT_Encuesta_Offline_Notificacion_EDG_CA'){
                                    mapIdIdiomaPlantilla.put('ca', emailp.Id);
                                }
                                
                                if(emailp.DeveloperName == 'HDT_Encuesta_Offline_Notificacion_EDG_ES'){
                                    mapIdIdiomaPlantilla.put('es', emailp.Id);
                                }

                                if(emailp.DeveloperName == 'HDT_Encuesta_Offline_Notificacion_EDG_IN'){
                                    mapIdIdiomaPlantilla.put('en', emailp.Id);
                                }
                            }
                        }
                    }             
                }

                //Aqui tenemos que traer los datos del Custom Settings
                //Obtenemos el custom setting de HDT Parametros para obtener el Id y la URL de la encuesta (Configuracion_1: Id Encuesta, Configuracion_2: URL)
                List<HDT_Parametros__c> linkEncuestaEmpleado =[SELECT  HDT_Configuracion_1__c, HDT_Configuracion_2__c FROM HDT_Parametros__c WHERE Name = 'HDT_Envio_Encuesta_3N' LIMIT 1];
                List<HDT_Parametros__c> linkEncuestaEmpleadoEdG =[SELECT  HDT_Configuracion_1__c, HDT_Configuracion_2__c,HDT_Activo__c FROM HDT_Parametros__c WHERE Name = 'HDT_Envio_Encuesta_3N_EDG' LIMIT 1];
            

                if(!linkEncuestaEmpleado.isEmpty() || !linkEncuestaEmpleadoEdG.isEmpty()){
                    String surveyInvitationLink;
                    //Actualizar URL de la encuesta en el caso
                    for(Case caso : listCasos){
                        caso.CC_Admin__c = true;
                        if(caso.Origin != 'Chat'){
                            //Casos cuando el origen es Teléfono
                            //Ahora comprobamos si es EDG o no EDG

                            if (canalesResolucionEDG != null && canalesResolucionEDG.contains(caso.CC_Canal_Resolucion__c)) { 
                                if (!linkEncuestaEmpleadoEdG.isEmpty() && linkEncuestaEmpleadoEdG[0].HDT_Activo__c == true) {   
                                    String tematicaName = caso.CC_MCC_Tematica__r != null ? caso.CC_MCC_Tematica__r.Name.replace(' ', '_') : '';
                                    /*
                                    caso.CC_URL_Encuesta_3N__c = (String)linkEncuestaEmpleadoEdG[0].HDT_Configuracion_2__c + 
                                                                  'sid=' + linkEncuestaEmpleadoEdG[0].HDT_Configuracion_1__c + 
                                                                  '&lang=' + caso.CC_Idioma__c + 
                                                                  '&empresa=' + caso.CC_Canal_Resolucion__c + 
                                                                  '&userid=' + caso.CC_Matricula_Empleado__c + 
                                                                  '&ticketid=' + caso.CaseNumber + 
                                                                  '&idet=' + caso.CC_MCC_Tematica__c + 
                                                                  '&et=' + tematicaName + 
                                                                  '&newtest=Y';*/
                                    caso.CC_URL_Encuesta_3N__c = HDT_CaseTriggerHelper.generarUrlEncuesta(
                                                                    (String)linkEncuestaEmpleadoEdG[0].HDT_Configuracion_2__c,
                                                                    linkEncuestaEmpleadoEdG[0].HDT_Configuracion_1__c,
                                                                    caso.CC_Idioma__c,
                                                                    caso.CC_Canal_Resolucion__c, // empresa
                                                                    caso.CC_Matricula_Empleado__c,
                                                                    caso.CaseNumber,
                                                                    caso.CC_MCC_Tematica__c,
                                                                    tematicaName
                                                                );
                                }
                            }
                            
                            //Caso en el canal de procedencia NO ES uno de las edgs
                            /*
                            if(canalesResolucionPrimeros.contains(caso.CC_Canal_Resolucion__c)){         
                                caso.CC_URL_Encuesta_3N__c = (String)linkEncuestaEmpleado[0].HDT_Configuracion_2__c+'sid='+linkEncuestaEmpleado[0].HDT_Configuracion_1__c+'&lang='+
                                caso.CC_Idioma__c+'&userid='+caso.CC_Matricula_Empleado__c+'&ticketid='+caso.CaseNumber+'&idet='+caso.CC_MCC_Tematica__c+'&et='+ caso.CC_MCC_Tematica__r.name.replace(' ', '_')+'&newtest=Y';
                            }*/
                            if (canalesResolucionPrimeros.contains(caso.CC_Canal_Resolucion__c)) {         
                                caso.CC_URL_Encuesta_3N__c = HDT_CaseTriggerHelper.generarUrlEncuesta(
                                    (String)linkEncuestaEmpleado[0].HDT_Configuracion_2__c,
                                    linkEncuestaEmpleado[0].HDT_Configuracion_1__c,
                                    caso.CC_Idioma__c,
                                    null, // No se pasa empresa ya que no está en este caso
                                    caso.CC_Matricula_Empleado__c,
                                    caso.CaseNumber,
                                    caso.CC_MCC_Tematica__c,
                                    caso.CC_MCC_Tematica__r.name.replace(' ', '_')
                                );
                            }
                      }
                        /*
                        else if(caso.Origin == 'Chat'){
                            caso.CC_URL_Encuesta_3N__c = (String)linkEncuestaEmpleado[0].HDT_Configuracion_2__c+'sid='+(String)linkEncuestaEmpleado[0].HDT_Configuracion_1__c+'&lang='+
                            caso.CC_Idioma__c+'&userid='+caso.CC_Matricula_Empleado__c+'&ticketid='+caso.CaseNumber+'&idet='+caso.CC_MCC_Tematica__c+'&et='+ caso.CC_MCC_Tematica__r.name.replace(' ', '_')+'&newtest=Y';
                        }*/
                        else if (caso.Origin == 'Chat') {
                            caso.CC_URL_Encuesta_3N__c = HDT_CaseTriggerHelper.generarUrlEncuesta(
                                (String)linkEncuestaEmpleado[0].HDT_Configuracion_2__c,
                                linkEncuestaEmpleado[0].HDT_Configuracion_1__c,
                                caso.CC_Idioma__c,
                                null, // No se pasa empresa ya que no aplica para chat
                                caso.CC_Matricula_Empleado__c,
                                caso.CaseNumber,
                                caso.CC_MCC_Tematica__c,
                                caso.CC_MCC_Tematica__r.name.replace(' ', '_')
                            );
                        }
                        


                    }
                    update listCasos;
                }

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
                            
                for(Integer i = 0; i< listCasos.size(); i++){
                    
                    String remitente = mapBuzonesDefecto.get('Por defecto empleados');
                    
                    Id remitenteId;
                    remitenteId = mapIdOrgWide.get(remitente);             
                    
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setSaveAsActivity(true);
                    mail.setWhatId(listCasos[i].Id);
                    
                    //Elegir idioma de la plantilla
                    if(listCasos[i].CC_Idioma__c == 'ca'){
                        mail.setTemplateId(mapIdIdiomaPlantilla.get('ca'));
                    }
                    
                    if(listCasos[i].CC_Idioma__c == 'es'){
                        mail.setTemplateId(mapIdIdiomaPlantilla.get('es'));
                    }

                    if(listCasos[i].CC_Idioma__c == 'en'){
                        mail.setTemplateId(mapIdIdiomaPlantilla.get('en'));
                    }

                                                  
                    mail.setTargetObjectId(listCasos[i].ContactId);
                    mail.setTreatTargetObjectAsRecipient(true);
                    mail.setOrgWideEmailAddressId(remitenteId);
                    oListMail.add(mail);               
                }            
                
                // Lanzar las peticiones de mensajes a enviar.
                if (!oListMail.isEmpty()){
                    List<Messaging.SingleEmailmessage> oMaxEnvios = new List<Messaging.SingleEmailmessage>();
                     // Enviar bloques de 10 mensajes máximo.
                     List<Messaging.SendEmailResult> oDataRes = Messaging.sendEmail(oMaxEnvios, false);     
                     
                    Integer iMensaje = 0;
                    Integer iTotalMsj = oListMail.size();
                
                    for (Integer iMens = 0; iMens < iTotalMsj; iMens++) {
                        oMaxEnvios.add(oListMail[iMens]);
                        iMensaje = iMensaje + 1;
                        if (iMensaje == 10 || iMens == iTotalMsj-1){
                                  
                            // Suponemos que el orden de devolución de resultados, es el orden de entrada de la lista de e-mails.
                            // Actualizamos estado en función de ello.
                            for (Integer iRes = 0; iRes<oDataRes.size(); iRes++){
                                if (oDataRes[iRes].isSuccess()){
                                    Task tarea = new Task();
                                    tarea.Status = 'Completed';
                                    tarea.Type = 'Envío de petición encuesta 3N';
                                    tarea.Subject = 'Email: Encuesta Satisfacción Contact Center Oficinas';
                                    tarea.WhatId = oMaxEnvios[iRes].getWhatId();
                                    tasks.add(tarea);
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
    }
}