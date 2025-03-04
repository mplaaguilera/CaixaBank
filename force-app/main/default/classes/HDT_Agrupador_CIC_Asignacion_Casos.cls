public with sharing class HDT_Agrupador_CIC_Asignacion_Casos {
   
    @InvocableMethod
    public static void asociarCasosAComunicacionInformativa(List<Id> idsCasos) {

        DateTime dt = DateTime.now();
		Long dateInMilliseconds = dt.getTime();
		
		AsyncOptions options = new AsyncOptions();
		options.DuplicateSignature = QueueableDuplicateSignature.Builder()
		.addId(UserInfo.getUserId())
						.addString(String.valueOf(dateInMilliseconds))
						.build();

		try {
			asociarCasosCausaAComunicacionInformativaQueueable asociarCasosCIC = new asociarCasosCausaAComunicacionInformativaQueueable();
            List<Id> idsCasosList = idsCasos;
		    asociarCasosCIC.setParams(idsCasosList);
		    System.enqueueJob(asociarCasosCIC, options);

		} catch (DuplicateMessageException ex) {
			//Exception is thrown if there is already an enqueued job with the same signature
            CBK_log.debug('CC_Agrupador_CIC_Asignacion_Casos.asociarCasosCampanaAComunicacionInformativa: ' + ex);
        }
	}

    public class asociarCasosCausaAComunicacionInformativaQueueable implements Queueable {

        
       private List<Id> idsCasos;
		
		public void setParams(List<Id> idsCasos) {
			this.idsCasos = idsCasos;
		}

		public void execute(QueueableContext context) {
            asociarCasosCausaAComunicacionInformativaNoFuture(idsCasos);
    	}
	}
    
    public static void asociarCasosCausaAComunicacionInformativaNoFuture(List<Id> idsCasos) {

        Set<Id> idsCampanasNuevosAgrupadores = new Set<Id>();

        List<Case> casosActualizar = new List<Case>();
        List<Case> lstCasos = new List<Case>();
        List<Case> lstCasosConMismaCausa = new List<Case>();
        List<Case> lstCasosCombinados = new List<Case>();

        String recordTypeDeveloperName = 'HDT_Comunicacion_Informativa';
        
        // Recogemos el aviso del primer umbral para recoger los casos de los ultimos 15 mins.
        String umbralTiempoCasos = [SELECT CC_Valor__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'HDT - Aviso Comunicaciones Informativas' 
        AND Name = 'Comunicación Informativa de Caso - Umbral de tiempo'].CC_Valor__c;

         //Convertimos a numero para operar - de momento 15 mins por defecto pero es parametrizable
         Integer umbralPrimerAviso = Integer.valueOf(umbralTiempoCasos);

       // Recogemos el aviso del primer umbral. En este caso que sean más de 3 casos.
       String umbralNumeroCasos = [SELECT CC_Valor__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'HDT - Aviso Comunicaciones Informativas' 
       AND Name = 'Comunicación Informativa de Caso - Umbral primer aviso'].CC_Valor__c;

       //Convertimos a numero para operar. Por defecto son 3 casos.
       Integer umbralCasos= Integer.valueOf(umbralNumeroCasos);

        // Recogemos el tiempo para validar cuando enviar el nuevo email pasado 15 mins.
       String umbralTiempoEnvioNuevo = [SELECT CC_Valor__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'HDT - Aviso Comunicaciones Informativas' 
       AND Name = 'Comunicación Informativa de Caso - Umbral Envio de Emails'].CC_Valor__c;

       //Convertimos a numero para operar. Por defecto son 3 casos.
       Integer umbralTiempoEnvio = Integer.valueOf(umbralTiempoEnvioNuevo);

       // Obtener la hora actual y calcular el límite de 15 minutos atrás
       DateTime fechaHoraActual = DateTime.now();


        // Calcular el límite de tiempo dinámico
        DateTime limiteMinutos = fechaHoraActual.addMinutes(-umbralPrimerAviso);

       
        //Recogemos el caso actual para tratarlo
        if (!idsCasos.isEmpty()) {

            /*
            //Recogemos los casos recibidos en la actualización
            lstCasos = [SELECT CaseNumber,CC_MCC_Tematica__r.Name,Status,ContactId,CC_MCC_Motivo__c,CC_MCC_ProdServ__c,CC_MCC_Tematica__c,CC_Causa__c,Id, CC_Comunicacion_Informativa__c, CC_Admin__c,CC_MCC_Causa__c,CC_MCC_Causa__r.Name,CC_Campana__c, CC_Campana__r.Name 
                        FROM Case    
                        WHERE Id IN :idsCasos
                        AND RecordType.DeveloperName = 'HDT_Empleado'
                        WITH SECURITY_ENFORCED];*/
        
            //Recogemos los casos anteriores que no se haya enviado email
            lstCasosConMismaCausa = [SELECT CC_Repetitivo__c,CaseNumber,CC_MCC_Tematica__r.Name,Status,ContactId,CC_MCC_Motivo__c,CC_MCC_ProdServ__c,CC_MCC_Tematica__c,CC_Causa__c,Id, CC_Comunicacion_Informativa__c, CC_Admin__c,CC_MCC_Causa__c,CC_MCC_Causa__r.Name,CC_Campana__c, CC_Campana__r.Name 
            FROM Case 
            WHERE   CreatedDate >= :limiteMinutos
                    AND CC_MCC_Tematica__c != null 
                    AND CC_MCC_Causa__c != null 
                    AND CC_MCC_ProdServ__c != null 
                    AND CC_MCC_Motivo__c != null 
                    //AND Id NOT IN :idsCasos
                    AND RecordType.DeveloperName = 'HDT_Empleado'
            WITH SECURITY_ENFORCED];
                    }

            
        system.debug('xxxxx Todos los casos a analizar de los ultimos 15 mins son estos : '+ lstCasosCombinados.size());

        /*
        // Comprobamos que el campo CC_Causa__c sea igual antes de añadir a la lista combinada
        for (Case caso : lstCasos) {
            for (Case casoConMismaCausa : lstCasosConMismaCausa) {
                if (caso.CC_Causa__c == casoConMismaCausa.CC_Causa__c && caso.CC_MCC_Tematica__c == casoConMismaCausa.CC_MCC_Tematica__c && caso.CC_MCC_ProdServ__c == casoConMismaCausa.CC_MCC_ProdServ__c ) {
                    lstCasosCombinados.add(caso);
                    lstCasosCombinados.add(casoConMismaCausa);
                }
            }
        }

        system.debug('0000000 Casos a analizar : '+ lstCasosCombinados.size());*/
        
        
        // Si esta vacio salimos
        if(lstCasosConMismaCausa.isEmpty()){
            return;
        }

        Map<String, List<Case>> mapCasosAgrupados = new Map<String, List<Case>>();
        
        // Agrupar casos por la combinación de campos
        for (Case caso : lstCasosConMismaCausa) {
            String key = caso.CC_MCC_Tematica__c + '|' + 
                         caso.CC_MCC_ProdServ__c + '|' + 
                         caso.CC_MCC_Motivo__c + '|' + 
                         caso.CC_MCC_Causa__c;
            if (!mapCasosAgrupados.containsKey(key)) {
                mapCasosAgrupados.put(key, new List<Case>());
            }
            mapCasosAgrupados.get(key).add(caso);
        }


        // Identificar grupos con 3 o más casos
        for (String key : mapCasosAgrupados.keySet()) {
            List<Case> casosGrupo = mapCasosAgrupados.get(key);
            if (casosGrupo.size() >= umbralCasos) {
                for (Case caso : casosGrupo) {
                    
                        caso.CC_Repetitivo__c = true;
                        casosActualizar.add(caso);
                    
                   
                }
            }
        }

        // Actualizar los casos en Salesforce
        if (!casosActualizar.isEmpty()) {
            system.debug('111111111 Casos que vamos a actualizar su campo repetitivo a true son : '+ casosActualizar.size());
            update casosActualizar;
        }

        // Actualizar los casos en Salesforce
        if (!casosActualizar.isEmpty()) {
            enviarCorreoNotificacion(casosActualizar);
        }


        

    }

    public static void enviarCorreoNotificacion(List<Case> casosActualizar) {

        system.debug('Entramos a 888888888888888888');
        //*************************************************************** */
        //Envio del correo electronico para el aviso 
        //*************************************************************** */

        String apiNamePlantillas = 'HDT_Comunicacion_Informativa';
        if(!casosActualizar.isEmpty()){
            //Obtenemos el custom setting de HDT Parametros para obtener el Id y la URL de la encuesta (Configuracion_1: Id Encuesta, Configuracion_2: URL)
            List<HDT_Parametros__c> linkEncuestaEmpleado =[SELECT  HDT_Configuracion_1__c, HDT_Configuracion_2__c FROM HDT_Parametros__c WHERE Name = 'HDT_Envio_Encuesta' LIMIT 1];

            //Custom setting para los destinatarios donde se va a enviar el email
            List<HDT_Parametros__c> emailsComunicacionInformativa =[SELECT  HDT_Configuracion_1__c, HDT_Configuracion_2__c FROM HDT_Parametros__c WHERE Name = 'HDT_Comuniciones_Informativas' LIMIT 1];
            
            String[] toAddresses = new String[] {};
            if (!emailsComunicacionInformativa.isEmpty()) {
                HDT_Parametros__c parametros = emailsComunicacionInformativa[0];
                if (parametros.HDT_Configuracion_1__c != null) {
                    toAddresses.add(parametros.HDT_Configuracion_1__c);
                }
                if (parametros.HDT_Configuracion_2__c != null) {
                    toAddresses.add(parametros.HDT_Configuracion_2__c);
                }
            }

            // Construcción del contenido del correo
            String cuerpoEmail = 'Se han identificado los siguientes casos repetitivos:\n\n';
            for (Case caso : casosActualizar) {
                cuerpoEmail += '- Caso ID: ' + caso.Id + '\n'
                            + '  Causa: ' + (caso.CC_MCC_Causa__r != null ? caso.CC_MCC_Causa__r.Name : 'Sin temática') + '\n'
                            + '  Número de Caso: ' + caso.CaseNumber + '\n\n';
            }

    // Construcción del correo electrónico
     //Recogemos el Custom Setting para obtener las direcciones de correo de respuesta
     HDT_Parametros__c emailRespuesta = HDT_Parametros__c.getInstance('HDT_Email_Respuesta_Empleados_New');

    //Recogemos los Ids del remitente ordenadas alfabeticamente por la direccion (0: Catalan, 1 Castellano) en el caso de que existan los 2
    List <OrgWideEmailAddress> remitentesId = [SELECT Id FROM OrgWideEmailAddress WHERE Address IN (: emailrespuesta.HDT_Configuracion_1__c, : emailrespuesta.HDT_Configuracion_2__c) ORDER BY Address];

    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setSubject('Resumen de Casos Repetitivos');
    mail.setOrgWideEmailAddressId(remitentesId[0].Id); // Usa el remitente configurado
    mail.setToAddresses(toAddresses); // Destinatarios
    mail.setPlainTextBody(cuerpoEmail); // Cuerpo del mensaje
    

    try {
        // Enviar el correo electrónico
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }, false);
    } catch (Exception e) {
        CBK_Log.error(e, 'Error en el envío de email consolidado');
    }


            
            /*
            if(!linkEncuestaEmpleado.isEmpty()){
                Map<Id, Case> mapInfoCasos = new Map<Id, Case>([SELECT Origin, CaseNumber, Contact.Email, CC_Idioma__c, CC_URL_Encuesta_3N__c,CC_Matricula_Empleado__c, CC_MCC_Tematica__r.name, CC_MCC_Tematica__r.CC_idCognitivo__c, CC_MCC_Tematica__c FROM Case WHERE Id IN :casosActualizar]);
                List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();

                //Recogemos el Custom Setting para obtener las direcciones de correo de respuesta
                HDT_Parametros__c emailRespuesta = HDT_Parametros__c.getInstance('HDT_Email_Respuesta_Empleados_New');

                //Recogemos los Ids del remitente ordenadas alfabeticamente por la direccion (0: Catalan, 1 Castellano) en el caso de que existan los 2
                List <OrgWideEmailAddress> remitentesId = [SELECT Id FROM OrgWideEmailAddress WHERE Address IN (: emailrespuesta.HDT_Configuracion_1__c, : emailrespuesta.HDT_Configuracion_2__c) ORDER BY Address];

                List <EmailTemplate> plantillas = [SELECT Id,DeveloperName FROM EmailTemplate WHERE DeveloperName LIKE : apiNamePlantillas ORDER BY DeveloperName];
                
                Case casoFiltrado = casosActualizar[0];
                //for(Case casoFiltrado : casosActualizar){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    //mail.setSubject('Asunto del correo');
                    mail.setTemplateId(plantillas[0].Id);
                    mail.setOrgWideEmailAddressId(remitentesId[0].Id);
                    mail.setSaveAsActivity(true);
                    //mail.setWhatId(casosActualizar[0].Id);
                    mail.setTargetObjectId(casoFiltrado.ContactId);
                   // mail.setTargetObjectId(toAddresses);
                    mail.setTreatTargetObjectAsRecipient(false);

                    //String[] toAddresses = new String[] {mapInfoCasos.get(casoFiltrado.Id).Contact.Email};
                    
                    mail.setToAddresses(toAddresses);
                    allmsg.add(mail);
                //}

                try {
                    // Enviar el correo electrónico y manejar errores si los hay
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(allmsg, false);
                } catch (Exception e) {
                    CBK_Log.error(e, 'Error en el envio de email');
                }
            }*/
        }
        
    }


}