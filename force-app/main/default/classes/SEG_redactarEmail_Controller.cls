public with sharing class SEG_redactarEmail_Controller {
	
	@AuraEnabled(cacheable=true)
    public static Contact getNombreEmailContacto(Id idContacto) {
        List<Contact> contactos = [SELECT Name, Email 
									FROM Contact WHERE Id = :idContacto];
        
		if (contactos.isEmpty()) {
			return null;
		} else {
            // Depurar posible buzón de segmentos.
            List<String> listaEmails = new List<String>();
            listaEmails.add(contactos[0].Email);
            //listaEmails = SEG_MetodosComunes.depuracionCorreosBuzonSegmentos(listaEmails);
            if (listaEmails.isEmpty()) {
                return null;
            } else {
				return contactos[0];
            }
		}
    }
	
	@TestVisible
	private class GetEmailTemplateRetorno {
		@AuraEnabled
		public String asunto {get;set;}
		@AuraEnabled
		public String cuerpo {get;set;}
		@AuraEnabled
		public Boolean plantilla {get;set;}

		public GetEmailTemplateRetorno() {
			this.asunto = '';
			this.cuerpo = '';
			this.plantilla = false;
		}
	}
	
	@AuraEnabled(cacheable=true)
	static public GetEmailTemplateRetorno getEmailTemplate(String caseId, EmailMessage dataEmail, String idPlanIdi, String idPlanOrg, String idPlan, String finalParaTemplateName, Boolean bNuevo) {
		
		GetEmailTemplateRetorno retorno = new GetEmailTemplateRetorno(); //retorno

		List<String> idsPlantilla = new List<String>();
		List<String> grupoIds = new List<String>();
		Messaging.SingleEmailMessage email;
		Messaging.SingleEmailMessage firma;
		SEG_Plantilla__c pFirma;
		String plantillaId = '';
		
		//Get notas
		Case notasCaso = [SELECT Id, Subject, SEG_Organizacion__c, SEG_Zona__c,CaseNumber,SEG_SemillaId__c, SEG_NotasEmpresa__c, SEG_NotasGrupoEN__c, SEG_NotasGrupoES__c, SEG_NotasGrupoCAT__c, SEG_NotasGrupoEU__c, SEG_NotasGrupoGL__c,
							Account.AV_OficinaPrincipal__r.SEG_NotaCentroPlantillasEN__c, //SEG_NotasCentroEN__c, 
							Account.AV_OficinaPrincipal__r.SEG_NotaCentroPlantillasES__c, //SEG_NotasCentroES__c, 
							Account.AV_OficinaPrincipal__r.SEG_NotaCentroPlantillasCAT__c, //SEG_NotasCentroCAT__c, 
							Account.AV_OficinaPrincipal__r.SEG_NotaCentroPlantillasEU__c, //SEG_NotasCentroEU__c, 
							Account.AV_OficinaPrincipal__r.SEG_NotaCentroPlantillasGL__c, //SEG_NotasCentroGL__c,
							SEG_Resultado__c, SEG_Numero_de_centro__c, AccountId, SEG_ClasificacionRapida__c, SEG_Grupo_Empresa__c, //Campos necesarios para poder filtrar las plantillas 
							ContactId, SEG_Grupo__c
							FROM Case WHERE Id = :caseId];
		
		//Semilla en el cuerpo del correo
		String stringSaliente = '';
		String mensajeSemilla;
		Datetime fechaHoraNoForm;
		String fechaHora;
		
		if (dataEmail != null) {
			fechaHoraNoForm = Datetime.newInstance(
				Date.newInstance(dataEmail.MessageDate.year(), dataEmail.MessageDate.month(), dataEmail.MessageDate.day()),
				Time.newInstance(dataEmail.MessageDate.hour() , dataEmail.MessageDate.minute(), dataEmail.MessageDate.second(), 0)	
			);
			fechaHora = fechaHoraNoForm.format('YYYY-MM-dd HH:mm:ss');
			
			if (bNuevo) {
				mensajeSemilla = '<br><br><br>' + 'NO BORRAR EL IDENTIFICADOR:<br>' + notasCaso.SEG_SemillaId__c + '<br><br><br>' + '------------------------------------------------------------------------------<br><br><br><br><br>';
			}
			
			else if(dataEmail.CcAddress != null){
				mensajeSemilla = '<br><br><br>' + 'NO BORRAR EL IDENTIFICADOR:<br>' + notasCaso.SEG_SemillaId__c + '<br><br><br>' + '------------------------------------------------------------------------------<br><br>'
				+ '------Mensaje original------' + '<br><br>' + 'From: ' + dataEmail.FromName + ' "' + dataEmail.FromAddress + '" ' + '<br>' + 'To: "' + dataEmail.ToAddress + '" ' + '<br>' + 'Cc: "' + dataEmail.CcAddress
				+ '" ' + '<br>' + 'Subject: ' + dataEmail.Subject + '<br>' + 'Fecha/Hora: ' +  fechaHora + '<br><br><br>';
			}
			else{
				mensajeSemilla = '<br><br><br>' + 'NO BORRAR EL IDENTIFICADOR:<br>' + notasCaso.SEG_SemillaId__c + '<br><br><br>' + '------------------------------------------------------------------------------<br><br>'
				+ '------Mensaje original------' + '<br><br>' + 'From: ' + dataEmail.FromName + ' "' + dataEmail.FromAddress + '" ' + '<br>' + 'To: "' + dataEmail.ToAddress + '" ' + '<br>' + 'Subject: ' + dataEmail.Subject + '<br>' + 'Fecha/Hora: ' + fechaHora + '<br><br><br>';
			}
		} else{
			mensajeSemilla = '<br><br><br>' + 'NO BORRAR EL IDENTIFICADOR:<br>' + notasCaso.SEG_SemillaId__c + '<br><br><br>' + '------------------------------------------------------------------------------<br><br>';
		}
		
		//Guarda el id de la plantilla entrante
		if (idPlan != null) {
			plantillaId = idPlan;
		}
		else if (idPlanOrg != null) {
			plantillaId = idPlanOrg;
		}

		List<String> plantillasOrgZona = new List<String>(); 
		List<SEG_ExcepcionesGrupo__c> relacionGrupos =[ SELECT SEG_Plantilla__c, SEG_Plantilla__r.SEG_Organizacion__c, SEG_Plantilla__r.SEG_Zona__c, SEG_GrupoTrabajoTexto__c FROM SEG_ExcepcionesGrupo__c  WHERE SEG_GrupoTrabajoTexto__c  != null 
														AND SEG_Plantilla__r.SEG_Organizacion__c includes(:notasCaso.SEG_Organizacion__c) AND SEG_Plantilla__r.SEG_Zona__c includes(:notasCaso.SEG_Zona__c)];
		
		for (SEG_ExcepcionesGrupo__c gp : relacionGrupos){	
			if (gp.SEG_GrupoTrabajoTexto__c == notasCaso.SEG_Grupo__c){
				idsPlantilla.add(gP.SEG_Plantilla__c);
			}
			plantillasOrgZona.add(gp.SEG_Plantilla__c);
		}

		//List<SEG_Plantilla__c> plantillasFirmas = new List<SEG_Plantilla__c>();
		Map<Id, SEG_Plantilla__c> plantillasFirmasMap = new Map<Id, SEG_Plantilla__c>();
		//Hay plantillas de firmar para el grupo, seleccionamos la correspondiente por Org y zona.
		if(!idsPlantilla.isEmpty()){
			plantillasFirmasMap = new Map<Id, SEG_Plantilla__c>([SELECT SEG_PlantillaCastellanoID__c,SEG_PlantillaCatalanID__c,SEG_PlantillaEuskeraID__c,SEG_PlantillaGalegoID__c,SEG_PlantillaInglesID__c FROM SEG_Plantilla__c WHERE id IN :idsPlantilla  AND SEG_TipoOperativa__c = 'Firma']);
		}
		//US807544 - En el caso de buscar una plantilla genérica estas deben de ser filtradas
		//No hay plantillas para el grupo correspondiente, seleccionamos la generica
		else{
			plantillasFirmasMap = SEG_MetodosComunes.determinarPlantillaExclusiva(notasCaso, 'Firma');
			//plantillasFirmas = [SELECT SEG_PlantillaCastellanoID__c,SEG_PlantillaCatalanID__c,SEG_PlantillaEuskeraID__c,SEG_PlantillaGalegoID__c,SEG_PlantillaInglesID__c,SEG_Activa__c,SEG_Organizacion__c,SEG_Zona__c FROM SEG_Plantilla__c WHERE SEG_TipoOperativa__c = 'Firma' AND SEG_Activa__c = true AND SEG_Organizacion__c includes(:notasCaso.SEG_Organizacion__c) AND SEG_Zona__c includes(:notasCaso.SEG_Zona__c) AND id NOT IN:plantillasOrgZona];
		}

		//Hay plantillas de firma de grupo, pero no para el grupo en question. Se busca la plantilla generica
		if (plantillasFirmasMap.isEmpty()){ 
			plantillasFirmasMap = new Map<Id, SEG_Plantilla__c>([SELECT Name, SEG_PlantillaCastellanoID__c,SEG_PlantillaCatalanID__c,SEG_PlantillaEuskeraID__c,SEG_PlantillaGalegoID__c,SEG_PlantillaInglesID__c,SEG_Activa__c,SEG_Organizacion__c,SEG_Zona__c FROM SEG_Plantilla__c WHERE SEG_TipoOperativa__c = 'Firma' AND SEG_Activa__c = true AND SEG_Organizacion__c includes(:notasCaso.SEG_Organizacion__c) AND SEG_Zona__c includes(:notasCaso.SEG_Zona__c) AND id NOT IN:plantillasOrgZona]);
		}

		/////PLANTILLA EMAIL Y FIRMA/////
		String templateId = '';
		String firmaId = '';
		String notasGrupo = '';
		String notasCentro = '';
		String notasEmpresa = '';
		if (notasCaso.SEG_NotasEmpresa__c != null){
			notasEmpresa = notasCaso.SEG_NotasEmpresa__c;
		}

		if (idPlanIdi == 'en') {
			if (String.isNotBlank(plantillaId)) {
				templateId = [SELECT SEG_PlantillaInglesID__c FROM SEG_Plantilla__c WHERE id = :plantillaId LIMIT 1].SEG_PlantillaInglesID__c;
			}
			if (!plantillasFirmasMap.isEmpty()) {
				pFirma = new List<SEG_Plantilla__c> (plantillasFirmasMap.values())[0];
				if(pFirma != null && pFirma.SEG_PlantillaInglesID__c != null){
					firmaId = [SELECT SEG_PlantillaInglesID__c FROM SEG_Plantilla__c WHERE id = :pFirma.id LIMIT 1].SEG_PlantillaInglesID__c;
				}
			}
			if(notasCaso.SEG_NotasGrupoEN__c != null){
				notasGrupo = notasCaso.SEG_NotasGrupoEN__c;
			}

			notasCentro = (String.isNotBlank(notasCaso?.Account?.AV_OficinaPrincipal__r?.SEG_NotaCentroPlantillasEN__c)) ? notasCaso.Account.AV_OficinaPrincipal__r.SEG_NotaCentroPlantillasEN__c : '';
		}
		else if(idPlanIdi == 'es'){
			if(String.isNotBlank(plantillaId)){
				templateId = [SELECT SEG_PlantillaCastellanoID__c FROM SEG_Plantilla__c WHERE id = :plantillaId LIMIT 1].SEG_PlantillaCastellanoID__c;
			}
			if(!plantillasFirmasMap.isEmpty()){
				pFirma = new List<SEG_Plantilla__c> (plantillasFirmasMap.values())[0];
				if(pFirma != null && pFirma.SEG_PlantillaCastellanoID__c != null)
				{
					firmaId = [SELECT SEG_PlantillaCastellanoID__c FROM SEG_Plantilla__c WHERE id = :pFirma.id LIMIT 1].SEG_PlantillaCastellanoID__c;
				}
			}
			
			if(notasCaso.SEG_NotasGrupoES__c != null){
				notasGrupo = notasCaso.SEG_NotasGrupoES__c;
			}

			notasCentro = (String.isNotBlank(notasCaso?.Account?.AV_OficinaPrincipal__r?.SEG_NotaCentroPlantillasES__c)) ? notasCaso.Account.AV_OficinaPrincipal__r.SEG_NotaCentroPlantillasES__c : '';
		}
		else if(idPlanIdi == 'ca'){
			if(String.isNotBlank(plantillaId)){
				templateId = [SELECT SEG_PlantillaCatalanID__c FROM SEG_Plantilla__c WHERE id = :plantillaId LIMIT 1].SEG_PlantillaCatalanID__c;
			}
			if(!plantillasFirmasMap.isEmpty()){
				pFirma = new List<SEG_Plantilla__c> (plantillasFirmasMap.values())[0];
				if(pFirma != null && pFirma.SEG_PlantillaCatalanID__c != null)
				{
					firmaId = [SELECT SEG_PlantillaCatalanID__c FROM SEG_Plantilla__c WHERE id = :pFirma.id LIMIT 1].SEG_PlantillaCatalanID__c;
				}
			}
			if(notasCaso.SEG_NotasGrupoCAT__c != null){
				notasGrupo = notasCaso.SEG_NotasGrupoCAT__c;
			}

			notasCentro = (String.isNotBlank(notasCaso?.Account?.AV_OficinaPrincipal__r?.SEG_NotaCentroPlantillasCAT__c)) ? notasCaso.Account.AV_OficinaPrincipal__r.SEG_NotaCentroPlantillasCAT__c : '';
		}
		else if(idPlanIdi == 'eu'){
			if(String.isNotBlank(plantillaId)){
				templateId = [SELECT SEG_PlantillaEuskeraID__c FROM SEG_Plantilla__c WHERE id = :plantillaId LIMIT 1].SEG_PlantillaEuskeraID__c;
			}
			if(!plantillasFirmasMap.isEmpty()){
				pFirma = new List<SEG_Plantilla__c> (plantillasFirmasMap.values())[0];
				if(pFirma != null && pFirma.SEG_PlantillaEuskeraID__c != null){
					firmaId = [SELECT SEG_PlantillaEuskeraID__c FROM SEG_Plantilla__c WHERE id = :pFirma.id LIMIT 1].SEG_PlantillaEuskeraID__c;
				}
			}
			if(notasCaso.SEG_NotasGrupoEU__c != null){
				notasGrupo = notasCaso.SEG_NotasGrupoEU__c;
			}

			notasCentro = (String.isNotBlank(notasCaso?.Account?.AV_OficinaPrincipal__r?.SEG_NotaCentroPlantillasEU__c)) ? notasCaso.Account.AV_OficinaPrincipal__r.SEG_NotaCentroPlantillasEU__c : '';
		}
		else if(idPlanIdi == 'ga'){
			if(String.isNotBlank(plantillaId)){
				templateId = [SELECT SEG_PlantillaGalegoID__c FROM SEG_Plantilla__c WHERE id = :plantillaId LIMIT 1].SEG_PlantillaGalegoID__c;
			}
			if(!plantillasFirmasMap.isEmpty()){
				pFirma = new List<SEG_Plantilla__c> (plantillasFirmasMap.values())[0];
				if(pFirma != null && pFirma.SEG_PlantillaGalegoID__c != null){
					firmaId = [SELECT SEG_PlantillaGalegoID__c FROM SEG_Plantilla__c WHERE id = :pFirma.id LIMIT 1].SEG_PlantillaGalegoID__c;
				}
			}
			if(notasCaso.SEG_NotasGrupoGL__c != null){
				notasGrupo = notasCaso.SEG_NotasGrupoGL__c;
			}

			notasCentro = (String.isNotBlank(notasCaso?.Account?.AV_OficinaPrincipal__r?.SEG_NotaCentroPlantillasGL__c)) ? notasCaso.Account.AV_OficinaPrincipal__r.SEG_NotaCentroPlantillasGL__c : '';
		}

		//Render email/firma
		if (String.isNotBlank(templateId)) {
			retorno.plantilla = true;
			if (finalParaTemplateName != null){
				if (String.isNotBlank(finalParaTemplateName)){
					email = Messaging.renderStoredEmailTemplate(templateId, finalParaTemplateName, caseId);
				}
			}
			else{
				if (notasCaso.ContactId != null) {
					email = Messaging.renderStoredEmailTemplate(templateId, notasCaso.ContactId, caseId);
				}
			}
		}
		
		if (String.isNotBlank(firmaId)){
			firma = Messaging.renderStoredEmailTemplate(firmaId, UserInfo.getUserId(), caseId);
			
		}
		
		// STRING SALIENTE BUILDER
		if (email != null){
			stringSaliente = stringSaliente + email.htmlbody;
		}

		if(firma != null){
			stringSaliente = stringSaliente + '</br></br>' + firma.htmlbody;
		}

		if(String.isNotBlank(notasGrupo)){
			stringSaliente = stringSaliente + '</br>' + notasGrupo;
		}

		if(String.isNotBlank(notasCentro)){
			stringSaliente = stringSaliente + '</br>' + notasCentro;
		}
		
		if(String.isNotBlank(mensajeSemilla)){
			stringSaliente = stringSaliente + '</br>' + mensajeSemilla;
		}
		retorno.cuerpo = stringSaliente;

		if (email != null) {
			if (String.isEmpty(email.Subject)) {
				List<EmailMessage> mails = [SELECT Subject FROM EmailMessage
											WHERE Incoming = TRUE AND ParentId = :caseId
											ORDER BY CreatedDate DESC LIMIT 1];			
				if (!mails.isEmpty()) {
					if (!mails[0].Subject.contains(notasCaso.CaseNumber)){
						retorno.asunto = (notasCaso.CaseNumber +' - ' + mails[0].Subject);
					}
					else{
						retorno.asunto = mails[0].Subject;
					}
				}
				else {
					if (!email.Subject.contains(notasCaso.CaseNumber)){
						retorno.asunto = (notasCaso.CaseNumber +' - ' + email.Subject);
					}
					else{
						retorno.asunto = email.Subject;
					}
				}
			}
			else {
				if (!email.Subject.contains(notasCaso.CaseNumber)){
					retorno.asunto = (notasCaso.CaseNumber +' - ' + email.Subject);
				}
				else{
					retorno.asunto = email.Subject;
				}
			}
		}
		else {
			if (notasCaso.Subject != null && !notasCaso.Subject.contains(notasCaso.CaseNumber)){
				retorno.asunto = (notasCaso.CaseNumber +' - ' + notasCaso.Subject);
			}
			else{
				retorno.asunto = notasCaso.Subject;
			}
		}
		return retorno;
	}
	
	@AuraEnabled
	public static Map<String, Object> enviarCorreo(String caseId, EmailMessage dataEmail, String emailBody, String subject,
		List<String> paraList, List<String> copiaList, /*String cambioPara,*/ Boolean bRemitir,
		Boolean bNuevo, List<String> listaAnexos, String recordId, Boolean cerrar,  String asunto, Datetime revision,
		String boton, Boolean newDestino, List<String> bccList) {
		
        Map<String, Object> retorno = new Map<String, Object>{'emailMessage' => null, 'planificado' => false, 'casoPadre'=> false};

		Datetime plan = null;

		//Se añade separación entre correos
		if (!bNuevo || emailBody != null && bNuevo) {
			emailBody += '-----------------------------------------------------------------------------</br></br></br>';
		}

		// Gestionar las imágenes que vienen inline.
		emailBody = gestionarImagenesInlineRedactarMail(caseId, emailBody);
		
		Case caso = [SELECT AccountId, SEG_Email_Buzon_Entrada__c, SEG_Subestado__c,SEG_Organizacion__c, Status, SEG_Zona__c, SEG_Detalle__c, CC_MCC_Motivo__c, CC_MCC_ProdServ__c, CC_MCC_Tematica__c, SEG_N_operaciones_del_caso__c, SEG_Buz_n_de_la_zona__c
						FROM Case WHERE Id = :caseId];

		// Rellenar campo revision
		if(revision != null){
			caso.SEG_Fecha_planificaci_n__c = revision;
	   }
		
		List<OrgWideEmailAddress> buzonSalida;

		List<SEG_Buzon__mdt> datosBuzon = new List<SEG_Buzon__mdt>();
			datosBuzon = [SELECT SEG_Correo_de_procedencia__c FROM SEG_Buzon__mdt
							WHERE SEG_Organizacion__c = :caso.SEG_Organizacion__c AND SEG_Zona__c = :caso.SEG_Zona__c LIMIT 1];
		if (!datosBuzon.isEmpty()) {
			buzonSalida = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :datosBuzon[0].SEG_Correo_de_procedencia__c LIMIT 1];
		} else {
			List<SEG_Buzon__mdt> datosBuzonDefault = new List<SEG_Buzon__mdt>();
			if (!Test.isRunningTest()) {
				datosBuzonDefault = [SELECT SEG_Correo_de_procedencia__c FROM SEG_Buzon__mdt WHERE SEG_Organizacion__c = 'Por defecto' AND SEG_Zona__c = 'Por defecto' AND DeveloperName = 'Buz_n_por_defecto' LIMIT 1];
				buzonSalida = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :datosBuzonDefault[0].SEG_Correo_de_procedencia__c LIMIT 1];
			} else {
				datosBuzonDefault = [SELECT SEG_Correo_de_procedencia__c FROM SEG_Buzon__mdt WHERE SEG_Organizacion__c = 'Por defecto' AND SEG_Zona__c = 'Por defecto' AND DeveloperName = 'BUZON_TEST' LIMIT 1];
			}
		}

		
		Messaging.SingleEmailMessage correo = new Messaging.SingleEmailMessage();
		
		//List<String> lstMails = new List<String>{caso.SEG_Email_Buzon_Entrada__c, caso.SEG_Buz_n_de_la_zona__c};

		List<String> lstMails = new List<String>{caso.SEG_Buz_n_de_la_zona__c};

		paraList =  SEG_MetodosComunes.depuracionCorreosBuzonSegmentos(paraList, lstMails);
		copiaList = SEG_MetodosComunes.depuracionCorreosBuzonSegmentos(copiaList, lstMails);
		bccList = SEG_MetodosComunes.depuracionCorreosBuzonSegmentos(bccList, lstMails);

		correo.setToAddresses(paraList);
		correo.setCcAddresses(copiaList);
		correo.setBccAddresses(bccList);
		
		if (Test.isRunningTest()) {
			correo.setSenderDisplayName('Segmentos CaixaBank - TO CHANGE');
			correo.setReplyTo('test@test.com');
		} else {
			correo.setOrgWideEmailAddressId(buzonSalida.get(0).Id);
		}
		correo.setWhatId(caseId);
		correo.setUseSignature(false);
		correo.setBccSender(false);
		correo.setSaveAsActivity(true);
		correo.setHtmlBody(emailBody);
		correo.setSubject(subject);

		if (listaAnexos != null && !listaAnexos.isEmpty()) {
			List<String> listadoAttachments = SEG_redactarEmail_Controller.getAttachments(listaAnexos);
			if (!listadoAttachments.isEmpty()) {
				correo.setEntityAttachments(getAttachments(listaAnexos));
				//correo.setFileAttachments(getAttachments(listaAnexos));
			}
		}

		Messaging.SendEmailResult resultadoEnvio;

		try {
			resultadoEnvio = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{correo})[0];
		} catch (Exception e) {
			String mensajeError = e.getMessage();
			System.debug(mensajeError);
			if(!String.isEmpty(mensajeError)){
				if (mensajeError.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
						mensajeError = mensajeError.remove('SendEmail failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, ').trim();
						mensajeError = mensajeError.removeEnd(': []');

						throw new AuraHandledException(mensajeError);

				}else if (mensajeError.contains('INVALID_EMAIL_ADDRESS')) {
					System.debug(mensajeError);
					if (mensajeError.contains('toAddresses')) {
						// Expresión regular para detectar un correo electrónico en el mensaje de error
						Pattern emailPattern = Pattern.compile('[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}');
						Matcher matcher = emailPattern.matcher(mensajeError);

						// Si encontramos un email en el mensaje de error, lo incluimos en la excepción
						if (matcher.find()) {
							String emailInvalido = matcher.group(0);
							throw new AuraHandledException('Dirección de correo errónea: ' + emailInvalido);
						} else {
							throw new AuraHandledException('Dirección de correo errónea.');
						}
					} else {
						throw new AuraHandledException('Error detectado: ' + mensajeError);
					}

				}else if(mensajeError.contains('REQUIRED_FIELD_MISSING')) {
					throw new AuraHandledException('Es obligatorio poner un Para en la dirección de envío de email');
				}
				
				if (!Test.isRunningTest()) {
					throw new AuraHandledException('Error detectado: ' + mensajeError);
				}
			}else {
				throw new AuraHandledException('Error detectado: ' + mensajeError);
			}
		}

		if (resultadoEnvio.isSuccess()) {
			EmailMessage emailEnviado = [SELECT Subject, FromAddress, FromName, ToAddress, CcAddress, HtmlBody, MessageDate, CreatedDate
										FROM EmailMessage WHERE ParentId = :caseId AND Incoming = FALSE
										ORDER BY MessageDate DESC LIMIT 1];
            retorno.put('emailMessage', emailEnviado);
			if (boton == 'botonNuevo') {
				emailEnviado.SEG_BotonPulsado__c = 'Nuevo';
			} else if (boton == 'botonReenviar') {
				emailEnviado.SEG_BotonPulsado__c = 'Reenviar';
			} else if (boton == 'RespUnico') {
				emailEnviado.SEG_BotonPulsado__c = 'Responder';
			} else if (boton == 'RespMultiple') {
				emailEnviado.SEG_BotonPulsado__c = 'ResponderTodos';
			}
			
			if (!listaAnexos.isEmpty()) {
				if (listaAnexos[0] != '0') {
					emailEnviado.SEG_HasAnexo__c = true;
				}
			}
			update emailEnviado;
		}
		
		if (resultadoEnvio.isSuccess() && String.isNotBlank(recordId)) {
			//actualizamos los estados del caso dependiendo el destinatario del email
			String sobjectName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();

			List<Contact> contacto = [SELECT RecordTypeId FROM Contact WHERE Id = :recordId];
			List<CC_Grupo_Colaborador_Contact__c> gc = [SELECT Id FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Contacto__r.Id = :recordId];
			List<CC_Grupo_Colaborador__C> grupoCollst = [SELECT Id FROM CC_Grupo_Colaborador__C WHERE Id = :recordId];
			
			Id idRtCliente = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
			Id idRtEmpleado = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
			Id idRtColaborador = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
				
			if (sobjectName == 'CC_Grupo_Colaborador__c') {
				//estados e informo el grupo de colaborador y actualizo el grupo respuesta según esté informado en grupo respuesta del grupo
				caso.Status = 'Pendiente';
				caso.SEG_Subestado__c = 'En Gestor Operativo de la empresa';
				//caso.SEG_Subestado__c = caso.SEG_Caso_sincronizado_en_BPO__c ? 'Gestión BPM': 'En Gestor Operativo de la empresa';
				Set<Id> setMCC = new Set<Id>();
				if (String.isNotBlank(caso.SEG_Detalle__c)) {
					setMCC.add(caso.SEG_Detalle__c);
				}
				if (String.isNotBlank(caso.CC_MCC_Motivo__c)) {
					setMCC.add(caso.CC_MCC_Motivo__c);
				}
				if (String.isNotBlank(caso.CC_MCC_ProdServ__c)) {
					setMCC.add(caso.CC_MCC_ProdServ__c);
				}
				if (String.isNotBlank(caso.CC_MCC_Tematica__c)) {
					setMCC.add(caso.CC_MCC_Tematica__c);
				}
				
				List<CC_MCC_Grupo_Colaborador__c> grupoColab = [SELECT CC_Grupo_Colaborador__c, SEG_Grupo_respuesta__c FROM CC_MCC_Grupo_Colaborador__c
																WHERE CC_MCC__c IN :setMCC AND CC_Grupo_Colaborador__c = :recordId LIMIT 1];
				
				if (grupoColab.size() == 1 && String.isNotBlank(grupoColab[0].SEG_Grupo_respuesta__c)) {
					caso.SEG_Grupo__c = grupoColab[0].SEG_Grupo_respuesta__c;
					caso.SEG_Grupo_colaborador_Externo__c = recordId;
					caso.Status = 'Pendiente';
					caso.SEG_Subestado__c = 'En colaborador';
					//caso.SEG_Subestado__c = caso.SEG_Caso_sincronizado_en_BPO__c ? 'Gestión BPM': 'En colaborador';
				}
			} else {
				if (!contacto.isEmpty()) {
					if (contacto[0].RecordTypeId == idRtCliente) {
						caso.Status = 'Pendiente';
						caso.SEG_Subestado__c = 'Envío pendiente respuesta Cliente';
						//caso.SEG_Subestado__c = caso.SEG_Caso_sincronizado_en_BPO__c ? 'Gestión BPM': 'Envío pendiente respuesta Cliente';
					} else if (contacto[0].RecordTypeId == idRtEmpleado) {

						caso.Status = 'Pendiente';
						caso.SEG_Subestado__c = 'Envío pendiente respuesta Gestor';
						//caso.SEG_Subestado__c = caso.SEG_Caso_sincronizado_en_BPO__c ? 'Gestión BPM':'Envío pendiente respuesta Gestor *';
					} else if (contacto[0].RecordTypeId == idRtColaborador) {
						caso.Status = 'Pendiente';
						caso.SEG_Colaborador_externo_Segmentos__c = recordId;
						caso.SEG_Subestado__c = 'Envío pendiente respuesta Colaborador';
						//caso.SEG_Subestado__c = caso.SEG_Caso_sincronizado_en_BPO__c ? 'Gestión BPM': 'Envío pendiente respuesta Colaborador';
					}
				} else if (!gc.isEmpty() || !grupoCollst.isEmpty()) {
					caso.Status = 'Cerrado';
					caso.SEG_Colaborador_externo_Segmentos__c = recordId;
					caso.SEG_Subestado__c = 'Envío cierre Colaborador';
				}
			}

			if (plan == null && !cerrar) {
				//Sin cierre ni fecha de planificación
				if (!contacto.isEmpty()) {
					if (contacto[0].RecordTypeId == idRtCliente) {
						caso.Status = 'Pendiente';
						caso.SEG_Subestado__c = 'Envío pendiente respuesta Cliente';
						//caso.SEG_Subestado__c = caso.SEG_Caso_sincronizado_en_BPO__c ? 'Gestión BPM': 'Envío pendiente respuesta Cliente';
					} else if (contacto[0].RecordTypeId == idRtEmpleado) {
						caso.Status = 'Pendiente';
						caso.SEG_Subestado__c = 'Envío pendiente respuesta Gestor';
						//caso.SEG_Subestado__c = caso.SEG_Caso_sincronizado_en_BPO__c ? 'Gestión BPM': 'Envío pendiente respuesta Gestor *';
					} else if (contacto[0].RecordTypeId == idRtColaborador) {
						caso.Status = 'Pendiente';
						caso.SEG_Subestado__c = 'Envío pendiente respuesta Colaborador';
						//caso.SEG_Subestado__c = caso.SEG_Caso_sincronizado_en_BPO__c ? 'Gestión BPM': 'Envío pendiente respuesta Colaborador';
					} else {
						caso.Status = 'Pendiente';
						caso.SEG_Subestado__c = 'Envío pendiente respuesta otros';
						//caso.SEG_Subestado__c = caso.SEG_Caso_sincronizado_en_BPO__c ? 'Gestión BPM': 'Envío pendiente respuesta otros';
					}
				} else if (!gc.isEmpty() || !grupoCollst.isEmpty()) {
					caso.Status = 'Pendiente';
					caso.SEG_Subestado__c = 'Envío pendiente respuesta Colaborador';
					//caso.SEG_Subestado__c = caso.SEG_Caso_sincronizado_en_BPO__c ? 'Gestión BPM': 'Envío pendiente respuesta Colaborador';
					caso.SEG_Grupo_colaborador_Externo__c = recordId;
				}
			}
		}
		if (caso.Status == 'Cerrado' && (caso.CC_MCC_Tematica__c == null || caso.CC_MCC_Motivo__c == null || caso.CC_MCC_ProdServ__c == null || caso.SEG_N_operaciones_del_caso__c == null))
		{
			if (!test.isRunningTest()) {
				throw new AuraHandledException('No se permite cerrar el caso si no se ha informado de la Temática, el Producto, el Motivo y el Nº de operaciones del caso.');
			}
		}
		if (caso.Status == 'Cerrado' && caso.AccountId != null) {
			List<Account> caseAccount = [SELECT Id FROM Account WHERE Id = :caso.AccountId AND Name = 'CUENTA PENDIENTE ASOCIAR' LIMIT 1];
			if (!caseAccount.isEmpty()) {
				if (!test.isRunningTest()) {
					throw new AuraHandledException('No se puede cerrar el caso si la cuenta está pendiente de asociar');
				}
			}
		}	
		try {
			if (cerrar) {
				String retornoCierre = SEG_Case_Operativas_Controller.cerrarCasoResultado(caseId, null, null);
				if (retornoCierre == 'Casos hijos'){
					retorno.put('casoPadre', true);
				}
			}else{
				update caso;
			}
		} catch (Exception e) {
            if (!test.isRunningTest()){
                throw new AuraHandledException(e.getMessage());
            }
		}
		return retorno;
	}

	/**
	 * @description Método para cambiar las imágenes inline privadas a URLs públicas
	 * @param caseId Identificador del caso
	 * @param emailBody Cuerpo del mensaje
	 * @return Nuevo cuerpo del mensaje con las imágenes inline en formato público.
	 */
	public static String gestionarImagenesInlineRedactarMail(String caseId, String emailBody) {
		String cuerpoEmailParseado = emailBody;

		try{
			if (String.isNotBlank(caseId) && String.isNotBlank(emailBody)) {
                //System.debug('EmialBody',emailBody);

				Pattern patronURLs = Pattern.compile('src=\\"https:\\/\\/caixabankcc([a-zA-Z0-9-=?&;%]|\\.|\\\\|:|\\/)+\\"');		
				// AQA - 21/06 - Se añade un segundo patrón tras el cambio de nombre de dominios de SF - http:///sfc/servlet.shepherd/version/download/0685r0000020TItAAM
				//Pattern patronURLsDominio = Pattern.compile('<img src="\\/sfc\\/servlet.shepherd\\/version\\/download\\/068[a-zA-Z0-9]+?">');	
				//Prueba otro pattern - '<img src="\\/sfc\\/servlet.shepherd\\/version\\/download\\/068[A-Za-z0-9]{12,15}">' 
				
				Pattern patronURLconDominio = Pattern.compile('src="(.{0,100})?\\/sfc\\/servlet\\.shepherd\\/version\\/download\\/068[A-Za-z0-9]{12,15}"');
				Pattern patronURLchatter = Pattern.compile('src="https:\\/\\/(.{0,100})?\\/sfc\\/servlet\\.shepherd\\/version\\/renditionDownload.{0,200}"');

				// Expresión regular para buscar el ID del ContentVersion de la URL.
				Pattern patronCV = Pattern.compile('\\/068[a-zA-Z0-9]+\\?');
				// // AQA - 21/06 - Se añade un segundo patrón de Ids tras el cambio de nombre de dominios de SF
				Pattern patronCVDominio = Pattern.compile('\\/068[a-zA-Z0-9]+');
				Pattern patronChatter = Pattern.compile('068[a-zA-Z0-9]{12}');
                
				// Preparar mapa de URLs de reemplazo.
				Map<String,String> mapaReemplazoUrls = new Map<String,String>();
				Set<String> setContentVersions = new Set<String>();
				Set<String> setContentVersionsUpperCase = new Set<String>();
                String orgId = UserInfo.getOrganizationId();
                orgId = orgId.substring(0,orgId.length()-3);

				// Parsear el correo saliente.
				Matcher matcherCorreo = patronURLs.matcher(emailBody);
				while (matcherCorreo.find()) {
					String urlImagen = matcherCorreo.group();

					// Comprobar que no sea una URL pública.
					boolean urlPublica = esUrlPublica(urlImagen);
                    
					if (!urlPublica)
					{
						// Parsear la url privada para encontrar el Identificador del fichero.
						Matcher matcherCV = patronCV.matcher(urlImagen);
						if (matcherCV.find()) {							
							String fileId = matcherCV.group();
							fileId = fileId.substring(1,fileId.length()-1);
							mapaReemplazoUrls.put(urlImagen, fileId);
							setContentVersions.add(fileId);
							setContentVersionsUpperCase.add(fileId.toUpperCase());
						}
					}
				}
                
                // Nuevo Matcher
                Matcher matcherCorreoconDominio = patronURLconDominio.matcher(emailBody);
				while (matcherCorreoconDominio.find()) {
					String urlImagen = matcherCorreoconDominio.group();
                    
					// Comprobar si la URL es pública
					boolean urlPublica = esUrlPublica(urlImagen);
                    
					if (!urlPublica) {
						// Parsear la url privada para encontrar el Identificador del fichero.
						Matcher matcherCV = patronCVDominio.matcher(urlImagen);
						if (matcherCV.find()) {
							String fileId = matcherCV.group();
							String fileIdShort = matcherCV.group();
							fileIdShort = fileIdShort.substring(1,fileIdShort.length()-3);
							fileId = fileId.substring(1,fileId.length()-1);
							mapaReemplazoUrls.put(urlImagen, fileIdShort);
							setContentVersions.add(fileIdShort);
							setContentVersionsUpperCase.add(fileIdShort.toUpperCase());
						}
					}
				}
                
				// Nuevo Matcher
				Matcher matcherCorreoChatter = patronURLchatter.matcher(emailBody);

				while (matcherCorreoChatter.find()) {
					String urlImagen = matcherCorreoChatter.group();
                    
					// Comprobar si la URL es pública
					boolean urlPublica = esUrlPublica(urlImagen);
                    
					if (!urlPublica) {
						// Parsear la url privada para encontrar el Identificador del fichero.
						//Matcher matcherCV = patronCVDominio.matcher(urlImagen);
						Matcher matcherCVchatter = patronChatter.matcher(urlImagen);
						if (matcherCVchatter.find() == true) {
							String fileId = matcherCVchatter.group();
							fileId = fileId.substring(0,fileId.length());
							mapaReemplazoUrls.put(urlImagen, fileId);
							setContentVersions.add(fileId);
							setContentVersionsUpperCase.add(fileId.toUpperCase());
						}
					}
				}
                
				// Mapa final por cada fichero con su URL pública.
				Map<String,String> mapaFilePublicURL = new Map<String,String>();
				// Recuperar todos los links públicos, tanto los existentes como los generados en la transacción.
				if (!setContentVersions.isEmpty()) {

					List<ContentAsset> lstContentAsset = new List<ContentAsset>();
					List<ContentVersion> lstContentVersion = new List<ContentVersion>();

					List<ContentVersion> contestLimpios = new List<ContentVersion>();
					List<ContentVersion> lstVersion = [SELECT Id, ContentDocumentId, ContentDocument.ContentAssetId, ContentDocument.ContentAsset.DeveloperName  FROM ContentVersion WHERE Id IN :setContentVersions];

					Map<String, List<ContentVersion>> mapContentRepetidos = juntarRepeticiones(lstVersion);

					for (String idContentVersion : mapContentRepetidos.keySet()) {
						if (mapContentRepetidos.get(idContentVersion).size() == 1) {
							contestLimpios.add(mapContentRepetidos.get(idContentVersion)[0]);
						}
					}

					Map<String, Id> mapAssetDocument = new Map<String, Id>();
					Map<String, String> mapAssetContentVer = new Map<String, String>();
					
					for(ContentVersion contentVersion : contestLimpios){
						if(contentVersion.ContentDocumentId != null){
							String developerNameFinal;
							String idConVer = String.valueOf(contentVersion.Id);
							if (contentVersion.ContentDocument.ContentAssetId == null ) {
								String randomUuid = UUID.randomUUID().toString().remove('-').left(18);
								developerNameFinal = 'SEG_' + contentVersion.id + randomUuid;
								ContentAsset assetId = new ContentAsset();
								assetId.DeveloperName = developerNameFinal;
								assetId.IsVisibleByExternalUsers = true;
								assetId.MasterLabel = developerNameFinal;
								lstContentVersion.add(contentVersion);
								lstContentAsset.add(assetId);
								mapAssetContentVer.put(developerNameFinal,idConVer.substring(0,idConVer.length()-3));
								mapAssetDocument.put(developerNameFinal, contentVersion.ContentDocumentId);
							} else if(contentVersion.ContentDocument.ContentAsset.DeveloperName != null){
								developerNameFinal = contentVersion.ContentDocument.ContentAsset.DeveloperName;
								mapaFilePublicURL.put(idConVer.substring(0,idConVer.length()-3),'https://'+ DomainCreator.getContentHostname() + '/file-asset-public/' + developerNameFinal + '?oid=' + orgId);
							}
						}
					}

					if(!lstContentAsset.isEmpty()){
						List<Database.SaveResult> resultadoInsercion = Database.insert(lstContentAsset,false);
						for (Database.SaveResult resInser : resultadoInsercion) {
							if (!resInser.isSuccess()) {
								for(Database.Error err : resInser.getErrors()){
									//CBK_log.debug('SEG_redactarEmail_Controller: Error en la inserción de ContentAsset: ' + err.getStatusCode() + ' - ' + err.getMessage(), LoggingLevel.ERROR);
								 	CBK_Log.addError(null, null, 'SEG_redactarEmail_Controller: Error en la inserción de ContentAsset: ' + err.getStatusCode() + err.getMessage(), null, null);
								}
							}
						}

						//Se insertan los CBK_Logs
            			CBK_Log.insertDML();

						List<ContentDocument> lstContentDocument = new List<ContentDocument>();

						for (ContentAsset asset : lstContentAsset) {
							if (asset.Id != null) {
								mapaFilePublicURL.put(mapAssetContentVer.get(asset.DeveloperName),'https://'+ DomainCreator.getContentHostname() + '/file-asset-public/' + asset.DeveloperName + '?oid=' + orgId);
								ContentDocument cntDocument = new ContentDocument();
								cntDocument.Id = mapAssetDocument.get(asset.DeveloperName);
								cntDocument.ContentAssetId = asset.Id;
								lstContentDocument.add(cntDocument);
							}
						}

						if(!lstContentDocument.isEmpty()){
							List<Database.SaveResult> resultadoUpdate = Database.update(lstContentDocument,false);
							for (Database.SaveResult resUpdt : resultadoUpdate) {
								if (!resUpdt.isSuccess()) {
									for(Database.Error err : resUpdt.getErrors()){
										// CBK_log.debug('SEG_redactarEmail_Controller: Error en la actualización de ContentDocument: ' + err.getStatusCode() + ' - ' + err.getMessage(), LoggingLevel.ERROR);
										CBK_Log.addError(null, null, 'SEG_redactarEmail_Controller: Error en la actualización de ContentDocument: ' + err.getStatusCode() + err.getMessage(), null, null);
									}
								}
							}

						//Se insertan los CBK_Logs
            			CBK_Log.insertDML();
						}
					}
				}

				// Reemplazar el contenido del email con los links públicos.
				for (String urlPrivadaCorreo : mapaReemplazoUrls.keySet()) {
					String ficheroURL;
					String nuevaURL;
					if (mapaReemplazoUrls.containsKey(urlPrivadaCorreo)) {
						ficheroURL = mapaReemplazoUrls.get(urlPrivadaCorreo);
					}
					if (!String.isBlank(ficheroURL) && mapaFilePublicURL.containsKey(ficheroURL)) {
						nuevaURL = mapaFilePublicURL.get(ficheroURL);
					}
					if (!String.isBlank(nuevaURL) && String.isNotBlank(nuevaURL)) {
						emailBody = emailBody.replace(urlPrivadaCorreo, 'src="' + nuevaURL + '"');
					}
				}

				cuerpoEmailParseado = emailBody;
			}
		}catch (Exception e){
			// Registramos error, pero no se impide la operativa del usuario.
			CBK_Log.error(e);
			cuerpoEmailParseado = emailBody;
		}

		return cuerpoEmailParseado;
	}

	@TestVisible 
	private static Map<String, List<ContentVersion>> juntarRepeticiones (List<ContentVersion> listContent){
		Map<String, List<ContentVersion>> mapContentRepetidos = new Map<String, List<ContentVersion>>();
		for (ContentVersion contentVersion : listContent) {
			String idString = String.valueOf(contentVersion.Id);
			List<ContentVersion> lstContent = new List<ContentVersion>();
			if (mapContentRepetidos.containsKey(idString.left(15))) {
				lstContent = mapContentRepetidos.get(idString.left(15));
				lstContent.add(contentVersion);
				mapContentRepetidos.put(idString.left(15),lstContent);
			} else {
				lstContent.add(contentVersion);
				mapContentRepetidos.put(idString.left(15),lstContent);
			}
		}
		return mapContentRepetidos;
	}

	public static boolean esUrlPublica(String urlImagen) {
		// Comprobar si la URL es pública
		if (urlImagen.contains('/sfc/dist/version/download') && 
			urlImagen.contains('oid=') && 
			urlImagen.contains('ids=') && 
			urlImagen.contains('&d=')) {
			return true;
		}
	
		// Comprobar si la URL corresponde a un asset público
		if (urlImagen.contains('/file-asset-public') && urlImagen.contains('oid=')) {
			return true;
		}
	
		return false; // La URL no es pública
	}

	
	public static List<String> getAttachments(List<String> contentDocumentIds) {
		
		List<String> attachments = new List<String>{};
		List<ContentVersion> documents = new List<ContentVersion>{};
		
		documents.addAll([SELECT id FROM ContentVersion WHERE isLatest = true AND ContentDocumentId IN :contentDocumentIds]);
		

		for (ContentVersion document: documents) {
			String attachment;
			attachment = document.id;
			attachments.add(attachment);
		}

		return attachments;
	}
	
	@AuraEnabled
	static public List<ContentVersion> getFilesCase(Id casoId){
		List<EmailMessage> relatedEmails = [SELECT id, relatedToId FROM emailMessage WHERE relatedToId =:casoId];
		List<Id> idsEmails = new List<Id>();
		for (EmailMessage emailId : relatedEmails) {
			idsEmails.add(emailId.id);
		}

		List<ContentDocumentLink> contentDocLinkList = new List<ContentDocumentLink>([SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink 
																					  WHERE (LinkedEntityId =: casoId 
																					  AND LinkedEntity.Type='Case') OR LinkedEntityId IN: idsEmails]);
		Set<Id> contentDocLinkIds = new Set<Id>();
		
		for (ContentDocumentLink contentLink:contentDocLinkList){
			contentDocLinkIds.add(contentLink.ContentDocumentId);
		}
		
		List<ContentVersion> listFiles = new List<ContentVersion>();
		listFiles = [SELECT Id,ContentUrl,ContentDocumentId,Title,FileExtension,CreatedDate,ContentSize FROM ContentVersion WHERE ContentDocumentId IN:contentDocLinkIds AND FileExtension<>'snote' ORDER BY CreatedDate DESC];
		return listFiles;
	}
	
	@AuraEnabled
	// Fecha de revisión - US475671 - ARS --- SEG_Fecha_planificaci_n__c
	static public Case getFPlanificacion(String casoId){
		return [SELECT SEG_Fecha_planificaci_n__c, SEG_limiteToAddress__c, SEG_toAddressNoAnadidos__c FROM Case WHERE id = :casoId LIMIT 1];
	}

	@AuraEnabled
	public static void identificarDestinatario(String caseId, String correo){
		Case caso = [SELECT id, AccountId, Status, SEG_Subestado__c, SEG_N_operaciones_del_caso__c FROM Case WHERE id = :caseId LIMIT 1];
		Account cuenta = [SELECT id, AV_EAPGestor__c, SEG_Empleado_gestor_Segmentos__c, SEG_GestorFinEstructurada__c, SEG_GestorOperativaInternacional__c, SEG_GestorOperativaNacional__c FROM Account WHERE id =: caso.AccountId LIMIT 1];
		List<Contact> ctEmail = [SELECT id, name, RecordTypeId, Email, SEG_Estado__c FROM Contact WHERE Email =:correo];
		List<Contact> ct = new List<Contact>();

        if(ctEmail.size() > 1)
        {
            for (Contact contacto : ctEmail) 
            {
                if(contacto.SEG_Estado__c != 'Inactivo')
                {
                    ct.add(contacto);
                }
            }
        }
        if(ct.isEmpty())
        {
            for (Contact contacto : ctEmail) 
            {
                ct.add(contacto);
            }                
        }

		id recordTypesContacto = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
		id recordTypeColaborador = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
		if(!ct.isEmpty()){
			if(ct[0].id == cuenta.AV_EAPGestor__c || ct[0].id == cuenta.SEG_Empleado_gestor_Segmentos__c || ct[0].id == cuenta.SEG_GestorFinEstructurada__c || ct[0].id == cuenta.SEG_GestorOperativaInternacional__c || ct[0].id == cuenta.SEG_GestorOperativaNacional__c){
				caso.Status = 'Cerrado';
				caso.SEG_Subestado__c = 'Por gestor';
				update caso;
			}
			else if(ct[0].RecordTypeId == recordTypesContacto){
				caso.Status = 'Cerrado';
				caso.SEG_Subestado__c = 'Envío cierre Cliente';
				update caso;
			}
			else if(ct[0].RecordTypeId  == recordTypeColaborador){
				caso.Status = 'Pendiente';
				caso.SEG_Subestado__c = 'Envío pendiente respuesta Colaborador';
				update caso;
			}
		}
		else{
			System.debug('No se ha encontrado el Contacto');
		}
	}
	
	/****************************************************************************
	* Proposito: Clase Wrapper para pasar los listados de emails para, cc, cco al
	* controlador java.
	*  ----------------------------------------------------------------------------
	* Historial
	* -------
	* VERSION        USER_STORY       AUTHOR         DATE         Description
	* 1.0            US278049         Esteve Llaó    04/11/21     Creación Clase
	*****************************************************************************/
	
	public class ListadoEmailsWrapper{
		@AuraEnabled public List<String> listadoPara {get; set;}
		@AuraEnabled public List<String> listadoCc {get; set;}
		@AuraEnabled public List<String> listadoCco {get; set;}
		
		/***************************************************************************
		* Proposito: Método constructor de la clase Wrapper
		*  ----------------------------------------------------------------------------
		* Historial
		* -------
		* VERSION        USER_STORY       AUTHOR         DATE         Description
		* 1.0            US278049         Esteve Llaó    04/11/21     Creación Clase
		****************************************************************************/
		
		public ListadoEmailsWrapper(List<String> listadoParaWrap, List<String> listadoCcWrap,List<String> listadoCcoWrap){
			listadoPara = listadoParaWrap;
			listadoCc = listadoCcWrap;
			listadoCco = listadoCcoWrap;
		}
	}
	
	/**************************************************************************
	* Proposito: Metodo para obetener la lista de emails entrados manualmente,
	* el o los canales de comunicación vinculados al caso.
	*  ----------------------------------------------------------------------------
	* Historial
	* -------
	* VERSION        USER_STORY       AUTHOR         DATE         Description
	* 1.0            US278049         Esteve Llaó    11/10/21     Creación
	**************************************************************************/
	@AuraEnabled
	static public ListadoEmailsWrapper getCanalesComunicacionManuales (String caseId, String emails, Boolean noContactos, String idBotonEntrada){
		List<String> emailsListado = new List<String>();
		List<String> listadoFormateado = new List<String>();
		Set<Id> setContactosFiltrados = new Set<id>();
		List<String> listadoCorrecto = new List<String>();
		List<String> emailsComPara = new List<String>();
		List<String> emailsComCc = new List<String>();
		List<String> emailsComCco = new List<String>();
		List<ListadoEmailsWrapper> listadoFinal = new List<ListadoEmailsWrapper>();
		Set<String> emailsComSet = new Set<String>();
		Set<String> emailsComSetPara = new Set<String>();
		Set<String> emailsComSetCc = new Set<String>();
		Set<String> emailsComSetCco = new Set<String>();
		
		Case caso = [SELECT id, AccountId, SEG_Buz_n_de_la_zona__c FROM Case WHERE id =: caseId];
		
		if (noContactos == false){
			
			if (emails != null) {
				emailsListado.addAll(emails.split(','));
			}

			emailsListado = SEG_MetodosComunes.depuracionCorreosBuzonSegmentos(emailsListado, caso.SEG_Buz_n_de_la_zona__c);

			for (String email : emailsListado) {
				listadoCorrecto.add(email.replaceAll('\\s+',''));
			}
			
			List<Contact> contactosRelacionados = [SELECT Id, SEG_Estado__c FROM Contact WHERE Email IN: listadoCorrecto];

            if(contactosRelacionados.size() > 1)
            {
                for (Contact contacto : contactosRelacionados) 
                {
                    if(contacto.SEG_Estado__c != 'Inactivo')
                    {
                        setContactosFiltrados.add(contacto.Id);
                    }
                }
            }
            if(setContactosFiltrados.isEmpty())
            {
                for (Contact contacto : contactosRelacionados) 
                {
                    setContactosFiltrados.add(contacto.Id);
                }                
            }

			List<CC_Canal_Com__c> canalComunicacion = [SELECT CC_Email__c, SEG_ParaCC__c FROM CC_Canal_Com__c
														WHERE CC_ContactoId__c IN :setContactosFiltrados
														AND (CC_CuentaId__c = NULL OR CC_CuentaId__c = :caso.AccountId)];
			
			if (!listadoCorrecto.isEmpty()) {
				emailsComSetPara.addAll(listadoCorrecto);
			}
			
			if (!canalComunicacion.isEmpty()) {
				for (CC_Canal_Com__c canalesCom : canalComunicacion) {
					if (canalesCom.SEG_ParaCC__c == 'Para') {
						if(emailsComSetPara.isEmpty()){
							emailsComSetPara.add(canalesCom.CC_EMail__c);
						}
						else{
							emailsComSetPara.add(' ' + canalesCom.CC_EMail__c);
						}
					}
				}
				for (CC_Canal_Com__c canalesCom : canalComunicacion) {
					if (canalesCom.SEG_ParaCC__c == 'CC') {
						if(emailsComSetCc.isEmpty()){
							emailsComSetCc.add(canalesCom.CC_EMail__c);
						}
						else{
							emailsComSetCc.add(' ' + canalesCom.CC_EMail__c);
						}
					}
				}
				for (CC_Canal_Com__c canalesCom : canalComunicacion) {
					if (canalesCom.SEG_ParaCC__c == 'CCO') {
						if(emailsComSetCco.isEmpty()){
							emailsComSetCco.add(canalesCom.CC_EMail__c);
						}
						else{
							emailsComSetCco.add(' ' + canalesCom.CC_EMail__c);
						}
					}
				}
			}
		}
		
		else{
			if (emails != null) {
				emailsListado.addAll(emails.split(','));
			}
			for (String email : emailsListado) {
				listadoCorrecto.add(email.replaceAll('\\s+',''));
			}
			if (!listadoCorrecto.isEmpty() && idBotonEntrada == 'BotonPara') {
				emailsComSetPara.addAll(listadoCorrecto);
			}
			else if (!listadoCorrecto.isEmpty() && idBotonEntrada == 'BotonCc') {
				emailsComSetCc.addAll(listadoCorrecto);
			}
			else if (!listadoCorrecto.isEmpty() && idBotonEntrada == 'BotonCco') {
				emailsComSetCco.addAll(listadoCorrecto);
			}
		}
		
		if(emailsComSetPara != null){
			emailsComPara.addAll(emailsComSetPara);
		}
		if(emailsComSetCc != null){
			emailsComCc.addAll(emailsComSetCc);
		}
		if(emailsComSetCco != null){
			emailsComCco.addAll(emailsComSetCco);
		}
		ListadoEmailsWrapper listadoAuxiliar = new ListadoEmailsWrapper(emailsComPara,emailsComCc,emailsComCco);
		
		return listadoAuxiliar;
	}
	
	@AuraEnabled
	static public void postOnChatter(Id caseId, String observaciones, String operativa, String notaTipificada) {

		if(String.isNotBlank(operativa)){
			createNotes(caseId, operativa, observaciones);
		}

		FeedItem feed = new FeedItem();
		feed.ParentId = caseId;
		feed.isRichText = true;

		if (!String.isNotBlank(observaciones)){
			observaciones = 'Sin Comentarios';
		}

		if (String.isNotBlank(notaTipificada) && !notaTipificada.equalsIgnoreCase('Sin notas')) {
			notaTipificada = [SELECT Name FROM SEG_NotasTipificadas__c WHERE Id = :notaTipificada LIMIT 1].Name;
		} else {
			notaTipificada = 'Sin notas';
		}

		feed.Body = 'Comentarios publicados en ' + operativa + ': <b>' + observaciones + '</b>. Nota tipificada: <b>' + notaTipificada + '</b>';

		insert feed;
	}

	@AuraEnabled
	static public void createNotes(Id caseId, String titulo, String texto) {
		
		ContentNote nota = new ContentNote();
		nota.Title = titulo;
		nota.Content = Blob.valueOf(texto);
		insert nota;

		if(nota != null)
		{
			ContentDocumentLink cdLink = new ContentDocumentLink();
			cdLink.ContentDocumentId = nota.id;
			cdLink.LinkedEntityId = caseId;
			insert cdLink;
		}
	}
	
	//recuperar notas tipificadas
	@AuraEnabled(cacheable=true)
	public static Map<Id, String> fetchNotasTipificadas(String caseId) {
		Map<Id, String> notasTipificadas = new Map<Id, String>();
		//Notas tipificadas asociadas a la clasificación rápida del caso
		Case caseSR = [SELECT SEG_ClasificacionRapida__c FROM Case WHERE Id = :caseId];
		for (SEG_CRNotasTipificadas__c notaTipificadaCR : [SELECT SEG_NotasTipificadas__c, SEG_NotasTipificadas__r.Name FROM SEG_CRNotasTipificadas__c
		WHERE SEG_CR__c = :caseSR.SEG_ClasificacionRapida__c]) {
			notasTipificadas.put(notaTipificadaCR.SEG_NotasTipificadas__c, notaTipificadaCR.SEG_NotasTipificadas__r.Name);
		}
		//Notas tipificadas no asociadas a ninguna clasificación rápida (estas se pueden usar en cualquier Case)
		for (SEG_NotasTipificadas__c notaTipificada : [SELECT Name FROM SEG_NotasTipificadas__c
		WHERE Id NOT IN (SELECT SEG_NotasTipificadas__c FROM SEG_CRNotasTipificadas__c)]) {
			notasTipificadas.put(notaTipificada.Id, notaTipificada.Name);
		}
		return notasTipificadas;
	}

	@AuraEnabled(cacheable=true)
	static public List<String> recuperarResultados() {
		List<String> resultados= new List<String>();
		for (Schema.PicklistEntry pickListVal : Case.SEG_Resultado__c.getDescribe().getPicklistValues()) {
			resultados.add(pickListVal.getLabel());
		}
		return resultados;
	}
	//Se llama al Operativas controller puesto que está en without sharing y devemos overridear permisos operativos.
	@AuraEnabled
	static public void informarNumOperacionesCaso(String caseId, Integer numeroOperaciones, Integer numOperacionesOld){
		if (caseId != null && (numeroOperaciones != numOperacionesOld)){
			SEG_Case_Operativas_Controller.informarNumOperaciones(caseId, numeroOperaciones);
		}
		else {
			return;
		}
	}	
}