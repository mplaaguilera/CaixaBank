public with sharing class SEG_Detector_Idioma
{
    /**
     *  @description clase que lanza ws contra cognitive para detectar idioma
     *  @param casoId -> listado de casos a detecta el idioma
     *  @return void
     */
    @future(callout=true)
    public static void setIdiomaCaso(List<Id> casoId, String email, String subject, String body) {
        boolean idiomaChanged = false;
        List<CC_TrazaInt__c> oListTrazas = new List<CC_TrazaInt__c>();
        List<Case> listCase = [SELECT Description, SEG_Idioma__c, ContactId, Contact.CC_Idioma__c, AccountId,
                                Contact.Account.AV_Idioma__c, ContactEmail, SEG_Organizacion__c, SEG_Zona__c,
                                Account.AV_Idioma__c, Account.SEG_No_enviar_Acuse_Recibo_Empresa__c, Contact.SEG_No_enviar_Acuse_Recibo__c,
                                SEG_Estado_Contacto__c, CC_AcuseRecibo__c, SEG_NO_AR_Account__c,
                                SEG_No_AR_Contact__c, SEG_SemillaId__c, CaseNumber,SEG_Email_Buzon_Entrada__c
                                FROM Case
                                WHERE Id IN :casoId];                   
        for (Case caso : listCase) {
            String cuerpoAnalisis;
            if (String.isBlank(caso.Description)) {
                cuerpoAnalisis = '';
            } else {
                cuerpoAnalisis = caso.Description;

                Integer indexLabel = cuerpoAnalisis.indexOf(System.Label.SEG_ExclusionEmails);

                if(indexLabel != -1){
                    cuerpoAnalisis = cuerpoAnalisis.substring(indexLabel + String.valueOf(System.Label.SEG_ExclusionEmails).length());
                }

                if(cuerpoAnalisis.length() >= 150) {
                    cuerpoAnalisis = cuerpoAnalisis.substring(0, 150);
                }
            }

            cuerpoAnalisis=cuerpoAnalisis.replaceAll('\r\n|\n|\r',' ');
            SEG_DETIDI__mdt paramDETIDI = getParamtersDETIDI();

            CC_TrazaInt__c oTraza = new CC_TrazaInt__c();
            String sDescError = '';
            String sDetalleError = '';

            String idioma;
            String txtconfianza;
            Decimal confianza;
            
            // Custom Setting
            String intSetting = 'SEG_DETIDI';

            //Generamos el body
            String cuerpo = '{"text":"' + cuerpoAnalisis + '"}';

            try {

                // Crear HEADER
                Map<String,string> mHeaders =  new  Map<String,string>();
                mHeaders.put('Content-Type', 'application/json;charset=UTF-8');

                CBK_HttpServiceIntegration.RequestWapper requestWrp = new CBK_HttpServiceIntegration.RequestWapper();
                requestWrp.intSetting = intSetting;
                requestWrp.method = 'POST';
                requestWrp.mHeaders = mHeaders;
                requestWrp.mUriParams = null;
                requestWrp.mQueryParams = null;

                HttpRequest request = CBK_HttpServiceIntegration.getRequest(requestWrp);

                HttpResponse response = CBK_HttpServiceIntegration.callHttpService(request, intSetting, intSetting);
              
                    // Incorporar los datos preconfigurados.
                        oTraza.Name = 'DETIDI_Segmentos';
                        oTraza.CC_FechaInicio__c = datetime.now();
                    
                    
                    oTraza.CC_MensajeEntrada__c = String.valueOf(request + ' ' + cuerpo);
                        
                    if (response.getStatusCode() == 200) {
                        Object results = (Object) JSON.deserializeUntyped(response.getBody());
                        oTraza.CC_MensajeSalida__c = String.valueOf(results);
                        Map<String, Object> agencymap = (Map<String, Object>)results;
                        txtconfianza=(String)agencymap.get((String)agencymap.get('language'));
                        if(!Test.isRunningTest()){
                        	confianza=Decimal.valueOf(txtconfianza.replaceAll('[^.\\d]',''));
                        }
                        if (confianza>paramDETIDI.SEG_Sensibilidad__c) {
                            idioma=(String)agencymap.get('language');
                            if (idioma=='cat') {idioma='ca';}
                            if (idioma=='esp') {idioma='es';}
                            if (idioma=='eng') {idioma='en';}
                        } else {
                            if (String.isNotBlank(caso.Contact.CC_Idioma__c)) {
                                idioma=caso.Contact.CC_Idioma__c;
                            } else if(String.isNotBlank(caso.Contact.Account.AV_Idioma__c)){
                                if(caso.Contact.Account.AV_Idioma__c=='002') {idioma='es';} 
                                if(caso.Contact.Account.AV_Idioma__c=='001') {idioma='ca';}
                                if(caso.Contact.Account.AV_Idioma__c=='003') {idioma='eu';}
                                if(caso.Contact.Account.AV_Idioma__c=='004') {idioma='ga';}
                                if(caso.Contact.Account.AV_Idioma__c=='010') {idioma='en';}
                            }else{
                                //ES por defecto
                                idioma = 'es';
                            }
                        }
                    } else {
                        sDescError = 'Error comunicaciones.';
                        sDetalleError = response.getStatusCode() + ':' + response.getBody();
                        idioma = 'es';
                    }
                
            } catch(Exception e) {
                // Error comunicaciones.
                sDescError = 'Error comunicaciones.';
                sDetalleError = e.getMessage();
            }

            // Finalizar traza.

                    oTraza.CC_FechaFin__c = datetime.now();
                    // No hay mensaje de salida. Solo devuelve 200 - OK.

                    if (sDescError != '') {
                        oTraza.CC_FinOK__c = false;
                        oTraza.CC_TipoError__c = sDescError;
                        oTraza.CC_DetalleError__c = sDetalleError;
                    } else {
                        oTraza.CC_FinOK__c = true;
                    }


            if (oTraza != null) {
                oListTrazas.add(oTraza);
            }

            //return idioma;
            if (idioma != 'no confiable') {
                caso.SEG_Idioma__c = idioma;
                idiomaChanged = true;
            } else if (caso.SEG_Idioma__c == null){
                caso.SEG_Idioma__c = 'es';
            }
        }
        if (!oListTrazas.isEmpty()) {
            Database.insert(oListTrazas, false);
        }

        if (!listCase.isEmpty()) {
            update listCase;
        }
        obtenerAccountYContact(listCase, email, subject, body);
        lanzarAcuseRecibo(listCase, email);
    }

    /*
    public static String getIdiomaCuerpo(string cuerpo)
    {
        List<CC_TrazaInt__c> oListTrazas = new List<CC_TrazaInt__c>();
        CC_InterfaceSettings__mdt oConfig = getConfigDETIDI ('CC_DETIDI');
        SEG_DETIDI__mdt paramDETIDI = getParamtersDETIDI();


        CC_TrazaInt__c oTraza;
        String sDescError = '';
        String sDetalleError = '';

        String idioma;
        String txtconfianza;
        Decimal confianza;
        cuerpo=cuerpo.replaceAll('\r\n|\n|\r',' ');
        try{
            if (oConfig != null){
                // Incorporar los datos preconfigurados.
                if (oConfig.CC_TrazaActiva__c || Test.isRunningTest()){
                    oTraza = new CC_TrazaInt__c();
                    oTraza.Name = 'DETIDI_Segmentos';
                    oTraza.CC_FechaInicio__c = datetime.now();
                }
                System.debug('Antes de llamada a webservice');
                System.debug('Cuerpo:'+cuerpo);
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(oConfig.CC_EndPoint__c );
                request.setMethod('POST');
                request.setHeader('Content-Type', 'application/json;charset=UTF-8');
                request.setClientCertificateName(oConfig.CC_Certificado__c);
                request.setBody('{"text":"' + cuerpo + '"}');
                HttpResponse response = http.send(request);
                System.debug('Despues de llamada a webservice');
                if (oConfig != null){
                    if (oConfig.CC_TrazaEntrada__c){
                        oTraza.CC_MensajeEntrada__c = String.valueOf(request);
                    }
                }

                if (response.getStatusCode() == 200) {
                    Object results = (Object) JSON.deserializeUntyped(response.getBody());
                    Map<String, Object> agencymap = (Map<String, Object>)results;
                    System.debug(agencymap);
                    txtconfianza=(String)agencymap.get((String)agencymap.get('language'));
                    confianza=Decimal.valueOf(txtconfianza.replaceAll('[^.\\d]',''));
                    System.debug('confianza:'+confianza);
                    if (confianza>paramDETIDI.SEG_Sensibilidad__c) {
                        idioma=(String)agencymap.get('language');
                        if(idioma=='cat')
                        {
                            idioma='ca';
                        }
                        if(idioma=='esp')
                        {
                            idioma='es';
                        }
                        if(idioma=='eng')
                        {
                            idioma='en';
                        }
                    }
                    else {
                       idioma='no confiable';
                    }


                } else {
                    sDescError = 'Error comunicaciones.';
                    sDetalleError = response.getStatusCode() + ':' + response.getBody();
                }
                System.debug('idioma:'+idioma);
            }
        }catch(Exception e) {
            // Error comunicaciones.
            sDescError = 'Error comunicaciones.';
            sDetalleError = e.getMessage();
        }

        // Finalizar traza.
            if (oConfig != null){
                if ((oConfig.CC_TrazaActiva__c || Test.isRunningTest()) && oTraza != null){
                    oTraza.CC_FechaFin__c = datetime.now();
                    // No hay mensaje de salida. Solo devuelve 200 - OK.

                    if (sDescError != ''){
                        oTraza.CC_FinOK__c = false;
                        oTraza.CC_TipoError__c = sDescError;
                        oTraza.CC_DetalleError__c = sDetalleError;
                    }else{
                        oTraza.CC_FinOK__c = true;
                    }
                }
            }

            if (oTraza != null){
                oListTrazas.add(oTraza);
            }




            if (!oListTrazas.isEmpty()){
                Database.SaveResult[] oResultTrazas = Database.insert(oListTrazas, false);
            }
            return idioma;
    }
    */

    /*
        Recuperar configuración de la integración.
    */

    static private SEG_DETIDI__mdt getParamtersDETIDI() {
        SEG_DETIDI__mdt parameter;
        List<SEG_DETIDI__mdt> oConfig = [SELECT SEG_Sensibilidad__c	, SEG_WS_Activo__c FROM SEG_DETIDI__mdt WHERE DeveloperName = 'Parametros'];
        if (oConfig.size()==1){
            parameter = oConfig[0];
        }
        return parameter;
    }


    //Queda deprecado por el cambio a framework de integraciones
    
   /* static private CC_InterfaceSettings__mdt getConfigDETIDI(String sInterfaz)
    {
        if (sInterfaz == null){
            return null;
        }

        if (sInterfaz == ''){
            return null;
        }

        CC_InterfaceSettings__mdt oInterfaz;

        List<CC_InterfaceSettings__mdt> oConfig = [SELECT CC_EndPoint__c, CC_Certificado__c, CC_TrazaActiva__c, CC_TrazaEntrada__c, CC_Activa__c
                                                    FROM CC_InterfaceSettings__mdt WHERE DeveloperName = :sInterfaz];
        if (oConfig.size() == 1)
        {
            if (oConfig[0] != null)
            {
                oInterfaz = oConfig[0];
            }
        }

        return oInterfaz;
    }
*/
	public static void lanzarAcuseRecibo(List<Case> lstCases, String direccionCorreo)
    {
		// Este método está controlado en su llamada para ejecutarse o no, en base a las condiciones de enviar acuse de recibo.

		//comprobamos si el check de Acuse Recibo está marcado y que el disparador del trigger ha sido realizado por un cambio en el cambio idioma
		//TODO: comprobar que no es necesario enviar acuse de recibo
		//TODO: comprobar si el correo recibido está en lista negra o gris
		//TODO: idioma del caso
        Case caso;
        if (lstCases.isEmpty() || String.isBlank(direccionCorreo)) {
            return;
        } else {
            caso = lstCases[0];
        }

		List<String> listaOrganizacion = new List<String>();
        if (String.isNotBlank(caso.SEG_Organizacion__c))
        {
            listaOrganizacion.add(caso.SEG_Organizacion__c);
        }
        
        List<String> listaZonas = new List<String>();
        if (String.isNotBlank(caso.SEG_Zona__c))
        {
            listaZonas.add(caso.SEG_Zona__c);
        }

        String idContacto = caso.ContactId;
        
        if (idContacto == null)
        {
            List<Contact> contactos = [SELECT Id
                                        FROM Contact
                                        WHERE Email = :direccionCorreo
                                        LIMIT 1];
            if (!contactos.isEmpty())
            {
                idContacto = contactos[0].Id;
            }
        }

		//Preparar los datos del mail saliente. Modo Bulk.
		Map<String, String> mapaBuzones = new Map<String, String>(); 
        //JAV: AÑADIR dirección de email para que se envie el AR desde el correo correcto por si existiese más de 1 buzón por zona
		for (SEG_Buzon__mdt datosBuzon : [SELECT SEG_Correo_de_procedencia__c, SEG_Organizacion__c, SEG_Zona__c
                                            FROM SEG_Buzon__mdt WHERE SEG_Organizacion__c IN :listaOrganizacion AND SEG_Zona__c IN :listaZonas AND SEG_Correo_de_procedencia__c =:lstCases[0].SEG_Email_Buzon_Entrada__c ])
        {
			String claveMap = datosBuzon.SEG_Organizacion__c + '##' + datosBuzon.SEG_Zona__c;
			if (String.isNotBlank(datosBuzon.SEG_Correo_de_procedencia__c))
            {
                mapaBuzones.put(claveMap, datosBuzon.SEG_Correo_de_procedencia__c);
			}
		}

		//Incorporar el buzón por defecto.
		List<SEG_Buzon__mdt> datosBuzonDefault = [SELECT SEG_Correo_de_procedencia__c, SEG_Organizacion__c, SEG_Zona__c FROM SEG_Buzon__mdt WHERE SEG_Organizacion__c = 'Por defecto' and SEG_Zona__c = 'Por defecto' LIMIT 1];
		if (!datosBuzonDefault.isEmpty())
        {
			String claveMap = datosBuzonDefault[0].SEG_Organizacion__c + '##' + datosBuzonDefault[0].SEG_Zona__c;
			if (String.isNotBlank(datosBuzonDefault[0].SEG_Correo_de_procedencia__c))
            {
				mapaBuzones.put(claveMap, datosBuzonDefault[0].SEG_Correo_de_procedencia__c);
			}
		}
        if (!caso.SEG_No_AR_Account__c && !caso.SEG_No_AR_Contact__c)
        {
            try
            {
                // Recuperar la dirección a enviar.
                String direccionSaliente = '';
                String claveAddress = caso.SEG_Organizacion__c + '##' + caso.SEG_Zona__c;
                if (mapaBuzones.get(claveAddress) != null)
                {
                    direccionSaliente = mapaBuzones.get(claveAddress);
                } else {
                    claveAddress = 'Por defecto##Por defecto';
                    direccionSaliente = mapaBuzones.get(claveAddress);
                }

                //Creación y envío del acuse
                Map<Id, List<SEG_Plantilla__c>> configuracionesPlantilla = SEG_PlantillasHandler.determinarPlantillas(new List<Case>{caso}, 'Acuse de recibo');
                if (!configuracionesPlantilla.isEmpty())
                {
                    Id idPlantilla = getIdPlantillaIdioma(configuracionesPlantilla.get(caso.Id)[0], caso);
                    if (String.isNotBlank(idPlantilla)) {

                        Messaging.SingleEmailMessage acuseRecibo = Messaging.renderStoredEmailTemplate(idPlantilla, idContacto, caso.Id);

                        String body = acuseRecibo.htmlbody + '<br><br><br>NO BORRAR EL IDENTIFICADOR:<br>' + caso.SEG_SemillaId__c + '<br><br><br>';
                        String subject;

                        if (!acuseRecibo.subject.contains(caso.CaseNumber)) {
                            subject = caso.caseNumber + ' - ' + acuseRecibo.subject;
                        } else {
                            subject = acuseRecibo.subject;
                        }

                        //Histórico de correos
                        String concatEmails = '';
                        for (EmailMessage emailfromCase : [SELECT HtmlBody FROM EmailMessage WHERE RelatedToId = :caso.Id]) {
                            if (String.isBlank(concatEmails)) {
                                concatEmails = '_________________________________________ <br><br>';
                            }
                            concatEmails += emailfromCase.HtmlBody + '<br>';
                            concatEmails += '_________________________________________ <br>';
                        }
                        body += concatEmails.length() > 32000 ? concatEmails.left(32000) : concatEmails;

                        //Buzón de salida
                        Map<String, String> relacionOwa = new Map<String, String>();
                        for (OrgWideEmailAddress owa : [SELECT Address
                                                        FROM OrgWideEmailAddress
                                                        WHERE Address = :mapaBuzones.values()]) {
                            relacionOwa.put(owa.Address, owa.Id);
                        }

                        Id direccionSalienteId = relacionOwa.get(direccionSaliente);
                        List<SEG_Buzon__mdt> datosBuzon = [SELECT SEG_Correo_de_procedencia__c
                                                            FROM SEG_Buzon__mdt
                                                            WHERE SEG_Organizacion__c = :caso.SEG_Organizacion__c AND SEG_Zona__c = :caso.SEG_Zona__c LIMIT 1];
                        List<OrgWideEmailAddress> listaOwa;
                        if (!datosBuzon.isEmpty()) {
                            listaOwa = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :datosBuzon[0].SEG_Correo_de_procedencia__c];
                        } else {
                            listaOwa = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :datosBuzonDefault[0].SEG_Correo_de_procedencia__c];
                        }
                        Messaging.SingleEmailMessage acuseRecibofinal = new Messaging.SingleEmailMessage();
                        List<String> listEmails = new List<String>();
                        listEmails.add(direccionCorreo);
                        //acuseRecibofinal.setTargetObjectId(idContacto);
                        if (Test.isRunningTest()) {
                            acuseRecibofinal.setSenderDisplayName('Segmentos CaixaBank - isRunningTest');
                            acuseRecibofinal.setReplyTo('test@test.com');
                        } else {
                            acuseRecibofinal.setOrgWideEmailAddressId(listaOwa.get(0).Id);
                        }
                        acuseRecibofinal.setOrgWideEmailAddressId(direccionSalienteId);
                        acuseRecibofinal.setUseSignature(false);
                        acuseRecibofinal.setBccSender(false);
                        acuseRecibofinal.setSaveAsActivity(true);
						body = SEG_redactarEmail_Controller.gestionarImagenesInlineRedactarMail(caso.Id , body);
                        acuseRecibofinal.setHtmlBody(body);
                        acuseRecibofinal.setToAddresses(listEmails);
                        acuseRecibofinal.setWhatId(caso.Id);
                        acuseRecibofinal.setSubject(subject);
                        //acuseRecibo.ToAddresses = new List<String>{emailEntrante};
                        if (!Test.isRunningTest()) {
                            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{acuseRecibofinal});
                        }
                    }
                }
            } catch (Exception e) {
                CBK_Log.error(e);
            }
        }
	}

    @TestVisible
    private static Id getIdPlantillaIdioma(SEG_Plantilla__c configuracionPlantilla, Case caso) {
        if (String.isNotBlank(caso.SEG_Idioma__c)) {
			if (caso.SEG_Idioma__c == 'ga') {
				return configuracionPlantilla.SEG_PlantillaGalegoID__c;
			} else if (caso.SEG_Idioma__c == 'ca') {
				return configuracionPlantilla.SEG_PlantillaCatalanID__c;
			} else if (caso.SEG_Idioma__c == 'en') {
				return configuracionPlantilla.SEG_PlantillaInglesID__c;
			} else if (caso.SEG_Idioma__c == 'eu') {
				return configuracionPlantilla.SEG_PlantillaEuskeraID__c;
			}
		} else if (String.isNotBlank(caso.Contact.CC_Idioma__c)) {
			if (caso.Contact.CC_Idioma__c == 'ga') {
				return configuracionPlantilla.SEG_PlantillaGalegoID__c;
			} else if (caso.Contact.CC_Idioma__c == 'ca') {
				return configuracionPlantilla.SEG_PlantillaCatalanID__c;
			} else if (caso.Contact.CC_Idioma__c == 'en') {
				return configuracionPlantilla.SEG_PlantillaInglesID__c;
			} else if (caso.Contact.CC_Idioma__c == 'eu') {
				return configuracionPlantilla.SEG_PlantillaEuskeraID__c;
			}
		} else if (String.isNotBlank(caso.Account.AV_Idioma__c)) {
			if (caso.Account.AV_Idioma__c == '004') {
				return configuracionPlantilla.SEG_PlantillaGalegoID__c;
			} else if (caso.Account.AV_Idioma__c == '001') {
				return configuracionPlantilla.SEG_PlantillaCatalanID__c;
			} else if (caso.Account.AV_Idioma__c == '010') {
				return configuracionPlantilla.SEG_PlantillaInglesID__c;
			} else if (caso.Account.AV_Idioma__c == '003') {
				return configuracionPlantilla.SEG_PlantillaEuskeraID__c;
			}
		}
		return configuracionPlantilla.SEG_PlantillaCastellanoID__c;
    }

    public static void obtenerAccountYContact(List<Case> casos, String email, String subject, String body){
        //TODO: Añadir posteo en chatter para advertir de posibles fallos.
        if(!casos.isEmpty()){
            if (casos[0].contactId == null || casos[0].accountId == null){
                Map<Account, List<Contact>> mapaCuentasContactos = SEG_EmailService.identificarCliente(email, body, subject);
                
                if (!mapaCuentasContactos.isEmpty()) {
                    List<FeedItem> lstFeed = new List<FeedItem>();
                    for (Account accountIdentificada : mapaCuentasContactos.keySet()) {
                        if (mapaCuentasContactos.get(accountIdentificada) != null){
                            for (Contact contacto : mapaCuentasContactos.get(accountIdentificada)) {
                                if ((casos[0].seg_zona__c == accountIdentificada.seg_zona__c) && (casos[0].seg_organizacion__c == accountIdentificada.seg_organizacion__c)){
                                    casos[0].contactid = contacto.id;
                                    casos[0].accountId = contacto.AccountId;
                                }
                                
                            }	
                        }
                        if (casos[0].Contactid != null && casos[0].accountId != null){
                            FeedItem feed = new FeedItem();
                            feed.ParentId = casos[0].Id;
                            feed.isRichText = true;
                            feed.Body = 'No se ha podido identificar correctamente el contacto y la cuenta. Por favor, identifíquelo manualmente';
                            lstFeed.add(feed);
                            break;
                        }
                    }
                    if(!lstFeed.isEmpty()){
                        insert lstFeed;
                    }
                }
                update casos;
            } 
        }
    }
}