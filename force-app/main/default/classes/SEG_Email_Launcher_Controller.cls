public class SEG_Email_Launcher_Controller {

    public class WrapperInit {
    	@AuraEnabled
    	public Case vGetCaso { get; set; }
    	@AuraEnabled
    	public List<EmailMessage> vCargarEmails { get; set; }
    	@AuraEnabled
    	public boolean vGetPropietario { get; set; }
    	@AuraEnabled
    	public List<String> vCargarFechaEmails { get; set; }
        @AuraEnabled
    	public String vGetDynamicUrlToApex { get; set; }
        @AuraEnabled
        public emailMessage vMostrarEmailReciente { get; set; }
        @AuraEnabled
        public Contact vMostrarContact { get; set; }
    }

	@AuraEnabled
	static public wrapperInit initComponent(String caseId){
        wrapperInit result = new wrapperInit();

        //getCaso
		result.vGetCaso=recuperarCaso(caseId);
        //cargarEmails
      	result.vCargarEmails=recuperarEmails(caseId);
        //esPropietario
      	result.vGetPropietario=esPropietario(caseId);
        //recuperarFechaEmails
      	result.vCargarFechaEmails=recuperarFechaEmails(caseId);
        //getDynamicUrlToApex
      	result.vGetDynamicUrlToApex=getDynamicUrl();
        //mostrarEmailReciente
      	result.vMostrarEmailReciente=mostrarEmailReciente(caseId);
        //mostrarContact
      	result.vMostrarContact=mostrarContact(result.vMostrarEmailReciente);

        return result;
	}



    @AuraEnabled(cacheable=true)
	static public String defaultIdioma(String caseId){

		return [SELECT SEG_Idioma__c FROM Case WHERE id = :caseId LIMIT 1].SEG_Idioma__c;
	}

	@AuraEnabled
	static public boolean esPropietario(String caseId){

		boolean propietario = false;

		String ownerId = [SELECT OwnerId FROM Case WHERE id = :caseId LIMIT 1].OwnerId;

		if(ownerId == UserInfo.getUserId())
		{
			propietario = true;
		}

		return propietario;
	}

	@AuraEnabled
	static public List<EmailMessage> recuperarEmails(String caseId) {
		return [SELECT FromName, CcAddress, Subject, HtmlBody, Incoming,HasAttachment,SEG_HasAnexo__c,SEG_EmailReciclado__c,SEG_BotonPulsado__c FROM EmailMessage WHERE ParentId = :caseId ORDER BY MessageDate DESC];
	}

	@AuraEnabled
	static public List<String> recuperarFechaEmails(String caseId) {
		List<String> fechasEmail = new List<String>();
		for (EmailMessage correo : [SELECT MessageDate, CreatedDate FROM EmailMessage
									WHERE ParentId = :caseId ORDER BY MessageDate DESC]) {
			Datetime fecha = Datetime.newInstance(
				Date.newInstance(correo.MessageDate.year(), correo.MessageDate.month(), correo.MessageDate.day()),
				Time.newInstance(correo.MessageDate.hour(), correo.MessageDate.minute(), correo.MessageDate.second(), 0)
			);
			fechasEmail.add(fecha.format('dd/MM/yy HH:mm:ss'));
		}
		return fechasEmail;
	}

	@AuraEnabled
	static public Case recuperarCaso(String caseId){
		List<Case> caso = [SELECT Subject, SEG_Idioma__c, Status, SEG_Grupo__c FROM Case WHERE id = :caseId LIMIT 1];
		return caso[0];

	}

	@AuraEnabled
	static public EmailMessage mostrarEmail(String emailId, String caseId) {
		Case casoVinculado = [SELECT id, caseNumber FROM Case WHERE id =: caseId];
		List<EmailMessage> mensaje = [SELECT FromName, CcAddress, FromAddress, ToAddress, BccAddress, HtmlBody, LastModifiedById, CreatedDate, Subject, MessageDate FROM EmailMessage WHERE id = :emailId LIMIT 1];
		EmailMessage newMessage = new EmailMessage();
		String subject ;
		if (!mensaje.isEmpty()){
			if(string.isNotBlank(mensaje[0].Subject) && !mensaje[0].subject.contains(casoVinculado.caseNumber)){
				subject = mensaje[0].Subject;
				subject = (casoVinculado.caseNumber +' - ' + subject);
				newMessage = mensaje[0];
				newMessage.subject = subject;
				return newMessage;
			}
			else{
				return mensaje[0];
			}
		}
		else{
			return null;
		}
	}

    @AuraEnabled
	static public EmailMessage mostrarEmailReciente(String caseId) {
		List<EmailMessage> correos = [SELECT FromName, CcAddress, FromAddress, ToAddress, HtmlBody, LastModifiedById, MessageDate, CreatedDate, Subject, incoming FROM EmailMessage WHERE ParentId = :caseId AND incoming = true ORDER BY MessageDate DESC LIMIT 1];
		Case casoVinculado = [SELECT id, caseNumber FROM Case WHERE id =: caseId];
		EmailMessage newMessage = new EmailMessage();
		String subject ;


		if (!correos.isEmpty()){
			if(string.isNotBlank(correos[0].Subject) && !correos[0].subject.contains(casoVinculado.caseNumber)){
				subject = correos[0].Subject;
				subject = (casoVinculado.caseNumber +' - ' + subject);
				newMessage = correos[0];
				newMessage.subject = subject;
				return correos.isEmpty() ? null : newMessage;
			}
			else{
				return correos.isEmpty() ? null : correos[0];
			}
		}
		else{
			return null;
		}

	}

	@AuraEnabled(cacheable=true)
	static public Contact mostrarContact(EmailMessage email) {
		Contact selectedContact = new Contact();
		if (email != null){
			List<Contact> contactos = [SELECT Name, RecordTypeId, Email, SEG_Estado__c FROM Contact WHERE Email = :email.FromAddress];
			if(!contactos.isEmpty()){
				if(contactos.size() == 1){
					selectedContact = contactos[0];
				}
				if(contactos.size() > 1){
					for (Contact c : contactos){
						if(c.SEG_Estado__c != 'Inactivo'){
							selectedContact = c;
						}
					}
				}
			}
		}

		return selectedContact;
	}

	@AuraEnabled(cacheable=true)
	static public List<ContentVersion> getFilesEmail(String emailId) {
		Id idemailid = emailId;
		//   Id idemailid = [SELECT Id FROM EmailMessage where id = :emailid];

		List<ContentDocumentLink> contentDocLinkList = new List<ContentDocumentLink>([SELECT ContentDocumentId, LinkedEntityId  FROM ContentDocumentLink where LinkedEntityId in ( SELECT Id FROM EmailMessage where id=: idemailid) and LinkedEntity.Type='EmailMessage']);

		Set<Id> contentDocLinkIds = new Set<Id>();
		for (ContentDocumentLink contentLink:contentDocLinkList)
		{
			contentDocLinkIds.add(contentLink.ContentDocumentId);
		}
		List<ContentVersion> listFiles = new List<ContentVersion>();
		listFiles = [select Id,	ContentUrl,ContentDocumentId,Title,FileExtension,CreatedDate,ContentSize from ContentVersion where ContentDocumentId in:contentDocLinkIds and FileExtension<>'snote'];
		return listFiles;
	}

	@AuraEnabled
	static public List<ContentVersion> getFilesEmailReciente(String caseId){
		List<ContentVersion> listaFicheros = new List<ContentVersion>();
		//List<EmailMessage> email = [SELECT FromName, CcAddress, FromAddress, ToAddress, HtmlBody, LastModifiedById, MessageDate FROM EmailMessage WHERE ParentId = :caseId ORDER BY MessageDate DESC LIMIT 1];
		List<EmailMessage> email = [SELECT Id FROM EmailMessage WHERE ParentId = :caseId ORDER BY MessageDate DESC LIMIT 1];

		// Id idemailid = [SELECT Id FROM EmailMessage where id = :emailid];
		if (!email.isEmpty()){
			List<ContentDocumentLink> contentDocLinkList = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: email[0].id AND LinkedEntity.Type='EmailMessage'];
			if (!contentDocLinkList.isEmpty()){
				Set<Id> contentDocLinkIds = new Set<Id>();
				for (ContentDocumentLink contentLink:contentDocLinkList)
				{
					contentDocLinkIds.add(contentLink.ContentDocumentId);
				}
				if (contentDocLinkIds.isEmpty()){
					List<ContentVersion> listFiles = [SELECT Id, ContentUrl,ContentDocumentId,Title,FileExtension,CreatedDate,ContentSize FROM ContentVersion WHERE ContentDocumentId IN:contentDocLinkIds AND FileExtension<>'snote'];
					listaFicheros.addAll(listFiles);
				}
			}
		}

		return listaFicheros;

	}
	/****************************************************************************
	* Proposito: Clase Wrapper para pasar los listados de emails para, cc, cco al
	* controlador java.
	* -------------------------------------------------------------------------
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
		* -------------------------------------------------------------------------
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
	* Proposito: Metodo para obetener la lista de emails relacionados con el
	* ultimo email entrante del caso y obtener los valores del remitente, así
	* como los correos de sus canales de comunicación
	*
	* -------------------------------------------------------------------------
	* Historial
	* -------
	* VERSION        USER_STORY       AUTHOR         DATE         Description
	* 1.0            US278049         Esteve Llaó    11/10/21     Creación
	**************************************************************************/

	@AuraEnabled
	static public ListadoEmailsWrapper getResponderPara(String emailsPara, String caseId){

		List<CC_Canal_Com__c> canalComunicacion = new List<CC_Canal_Com__c>();
		List<String> emails = new List<String>();
		List<String> emailsComPara = new List<String>();
		List<String> emailsComCc = new List<String>();
		List<String> emailsComCco = new List<String>();
		Set<String> emailsComSetPara = new Set<String>();
		Set<String> emailsComSetCc = new Set<String>();
		Set<String> emailsComSetCco = new Set<String>();
		List<String> emailsListado = new List<String>();
		List<String> listadoCorrecto = new List<String>();

		if (emailsPara != null) {
			emailsListado.addAll(emailsPara.split(';'));
		}
		system.debug('emailspara '+ emailsListado);
		for (String email : emailsListado) {
			listadoCorrecto.add(email.replaceAll('\\s+',''));
		}
		system.debug('emailspara ord '+ listadoCorrecto);

		List<Case> caso = [SELECT id, AccountId, SEG_Email_Buzon_Entrada__c, SEG_Buz_n_de_la_zona__c  FROM Case WHERE id =: caseId];
		List<Contact> lstContactoRelacionado = [SELECT id, name, Email, SEG_Estado__c FROM Contact WHERE Email IN: listadoCorrecto];
		List<Contact> lstContact = new List<Contact>();

		if(!lstContactoRelacionado.isEmpty())
		{
			if(lstContactoRelacionado.size() > 1)
			{
				for(Contact c : lstContactoRelacionado)
				{
					if(c.SEG_Estado__c != 'Inactivo')
					{
						lstContact.add(c);
					}
				}
			}
			if(lstContact.isEmpty())
			{
				lstContact.add(lstContactoRelacionado[0]);
			}
		}
		if(!lstContact.isEmpty())
		{
			canalComunicacion = [SELECT id, CC_ContactoId__c,CC_Email__c,SEG_ParaCC__c,CC_CuentaId__c FROM CC_Canal_Com__c WHERE CC_ContactoId__c =: lstContact[0].id];
		}

		emailsComSetPara.addAll(listadoCorrecto);

		for (CC_Canal_Com__c canalesCom : canalComunicacion) {
			if(canalesCom.CC_CuentaId__c == caso[0].AccountId){
				if (canalesCom.SEG_ParaCC__c == 'Para' && emailsComSetPara != null){
					emailsComSetPara.add(' ' + canalesCom.CC_EMail__c);
				}
				else if (canalesCom.SEG_ParaCC__c == 'Para' && emailsComSetPara == null){
					emailsComSetPara.add(canalesCom.CC_EMail__c);
				}
				if (canalesCom.SEG_ParaCC__c == 'CC' && emailsComSetCc != null){
					emailsComSetCc.add(' ' + canalesCom.CC_EMail__c);
				}
				else if (canalesCom.SEG_ParaCC__c == 'CC' && emailsComSetCc == null){
					emailsComSetCc.add(canalesCom.CC_EMail__c);
				}
				if (canalesCom.SEG_ParaCC__c == 'CCO' && emailsComSetCco != null){
					emailsComSetCco.add(' ' + canalesCom.CC_EMail__c);
				}
				else if (canalesCom.SEG_ParaCC__c == 'CCO' && emailsComSetCco == null){
					emailsComSetCco.add(canalesCom.CC_EMail__c);
				}
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

		// Eliminar los buzones compartidos de segmentos en cualquiera de las listas.
		// Buzon entrada
		emailsComPara = SEG_MetodosComunes.depuracionCorreosBuzonSegmentos(emailsComPara, caso[0].SEG_Email_Buzon_Entrada__c);
		emailsComCc = SEG_MetodosComunes.depuracionCorreosBuzonSegmentos(emailsComCc, caso[0].SEG_Email_Buzon_Entrada__c);
		emailsComCco = SEG_MetodosComunes.depuracionCorreosBuzonSegmentos(emailsComCco, caso[0].SEG_Email_Buzon_Entrada__c);
		// Buzon de la zona
		emailsComPara = SEG_MetodosComunes.depuracionCorreosBuzonSegmentos(emailsComPara, caso[0].SEG_Buz_n_de_la_zona__c );
		emailsComCc = SEG_MetodosComunes.depuracionCorreosBuzonSegmentos(emailsComCc, caso[0].SEG_Buz_n_de_la_zona__c );
		emailsComCco = SEG_MetodosComunes.depuracionCorreosBuzonSegmentos(emailsComCco, caso[0].SEG_Buz_n_de_la_zona__c );

		/*emailsComPara = SEG_MetodosComunes.depuracionCorreosBuzonSegmentos(emailsComPara);
		emailsComCc = SEG_MetodosComunes.depuracionCorreosBuzonSegmentos(emailsComCc);
		emailsComCco = SEG_MetodosComunes.depuracionCorreosBuzonSegmentos(emailsComCco);*/

		ListadoEmailsWrapper listadoAuxiliar = new ListadoEmailsWrapper(emailsComPara,emailsComCc,emailsComCco);

		return listadoAuxiliar;
	}

	/**************************************************************************
	* Proposito: Metodo para obetener la lista de emails relacionados con el
	* ultimo email entrante del caso y obtener los valores del campo copia, así
	* como los correos de sus canales de comunicación.
	*
	* -------------------------------------------------------------------------
	* Historial
	* -------
	* VERSION        USER_STORY       AUTHOR         DATE         Description
	* 1.0            US278049         Esteve Llaó    11/10/21     Creación
	**************************************************************************/

	@AuraEnabled
	static public List<String> getResponderMultipleCc (String caseId, String direccionesCc /*, String direccionesTo*/){
		String emailQuery;
		List<String> emailsListado = new List<String>();
		List<String> listadoFormateado = new List<String>();
		Set<Id> setContactosFiltrados = new Set<id>();
		List<String> listadoCorrecto = new List<String>();
		List<String> emailsCc = new List<String>();
		Set<String> emailsCcSet = new Set<String>();

		Case caso = [SELECT id, AccountId, SEG_Email_Buzon_Entrada__c, SEG_Buz_n_de_la_zona__c FROM Case WHERE id =: caseId];

		if (direccionesCc != null) {
			emailsListado.addAll(direccionesCc.split(';'));
		}
		for (String email : emailsListado) {
			listadoCorrecto.add(email.replaceAll('\\s+',''));
		}

		List<Contact> contactosRelacionados = [SELECT id, name, Email, AccountId, SEG_Estado__c FROM Contact WHERE Email IN: listadoCorrecto];

		if(!contactosRelacionados.isEmpty())
		{
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
		}
		/*
		for (Contact contacto : contactosRelacionados) {
			if (contacto.AccountId != null) {
				setContactosFiltrados.add(contacto.Id);
			}
		}
		*/
		List<CC_Canal_Com__c> canalComunicacion = [SELECT id, CC_ContactoId__c,CC_Email__c, CC_CuentaId__c FROM CC_Canal_Com__c WHERE CC_ContactoId__c IN :setContactosFiltrados];
		if (!emailsListado.isEmpty()) {
			emailsCcSet.addAll(emailsListado);
		}
		if (!canalComunicacion.isEmpty()) {
			for (CC_Canal_Com__c canalesCom : canalComunicacion) {
				if (caso.AccountId == canalesCom.CC_CuentaId__c){
					emailsCcSet.add(' ' + canalesCom.CC_EMail__c);
				}
			}
		}
		/*if (direccionesTo != null) {
			emailsCcSet.addAll(direccionesTo.split(';'));
		}*/

		for (String email : emailsCcSet) {
			if (emailsCc == null){
				emailsCc.add(email);
			}
			else{
				emailsCc.add(' ' + email);
			}
		}

    // Eliminar los buzones compartidos de segmentos en cualquiera de las listas.
    emailsCc = SEG_MetodosComunes.depuracionCorreosBuzonSegmentos(emailsCc, caso.SEG_Email_Buzon_Entrada__c);
	emailsCc = SEG_MetodosComunes.depuracionCorreosBuzonSegmentos(emailsCc, caso.SEG_Buz_n_de_la_zona__c);

	//emailsCc = SEG_MetodosComunes.depuracionCorreosBuzonSegmentos(emailsCc);
		return emailsCc;
	}

	/**************************************************************************
	* Proposito: Metodo para obetener la lista de emails relacionados con el
	* ultimo email entrante del caso y obtener los valores del campo copia
	* oculta, así como los correos de sus canales de comunicación.
	*
	* -------------------------------------------------------------------------
	* Historial
	* -------
	* VERSION        USER_STORY       AUTHOR         DATE         Description
	* 1.0            US278049         Esteve Llaó    11/10/21     Creación
	**************************************************************************/

	@AuraEnabled
	static public List<String> getResponderMultipleCco (String caseId, String direccionesCco){
		String emailQuery;
		List<String> emailsListado = new List<String>();
		List<String> listadoFormateado = new List<String>();
		Set<Id> setContactosFiltrados = new Set<id>();
		List<String> listadoCorrecto = new List<String>();
		List<String> emailsCco = new List<String>();
		Set<String> emailsCcoSet = new Set<String>();

		Case caso = [SELECT id, AccountId, SEG_Email_Buzon_Entrada__c, SEG_Buz_n_de_la_zona__c FROM Case WHERE id =: caseId];
		if (direccionesCco != null) {
			emailsListado.addAll(direccionesCco.split(';'));
		}
		for (String email : emailsListado) {
			listadoCorrecto.add(email.replaceAll('\\s+',''));
		}

		List<Contact> contactosRelacionados = [SELECT id, name, Email, AccountId, SEG_Estado__c FROM Contact WHERE Email IN: listadoCorrecto];

		if(!contactosRelacionados.isEmpty())
		{
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
		}

		List<CC_Canal_Com__c> canalComunicacion = [SELECT id, CC_ContactoId__c,CC_Email__c, CC_CuentaId__c FROM CC_Canal_Com__c WHERE CC_ContactoId__c IN :setContactosFiltrados];
		if (!emailsListado.isEmpty()) {
			emailsCcoSet.addAll(emailsListado);
		}
		if (!canalComunicacion.isEmpty()) {
			for (CC_Canal_Com__c canalesCom : canalComunicacion) {
				if (caso.AccountId == canalesCom.CC_CuentaId__c){
					emailsCcoSet.add(' ' + canalesCom.CC_EMail__c);
				}
			}
		}
		emailsCco.addAll(emailsCcoSet);

    // Eliminar los buzones compartidos de segmentos en cualquiera de las listas.
   	emailsCco = SEG_MetodosComunes.depuracionCorreosBuzonSegmentos(emailsCco, caso.SEG_Email_Buzon_Entrada__c);
	emailsCco = SEG_MetodosComunes.depuracionCorreosBuzonSegmentos(emailsCco, caso.SEG_Buz_n_de_la_zona__c);

	//emailsCco = SEG_MetodosComunes.depuracionCorreosBuzonSegmentos(emailsCco);
		return emailsCco;
	}

	/**************************************************************************
	* Proposito: Metodo para obtener la url de la org dinamicamente
	*
	* -------------------------------------------------------------------------
	* Historial
	* -------
	* VERSION        USER_STORY       AUTHOR         DATE         Description
	* 1.0            US278049         Esteve Llaó    11/10/21     Creación
	**************************************************************************/
	@AuraEnabled
	static public string getDynamicUrl (){
		String prefix = URL.getSalesforceBaseURL().toExternalForm().replace('https://', '').split('\\.')[0];
		prefix = prefix.removeEnd('--c');
		String url = 'https://' + prefix.toLowerCase() + '.lightning.force.com';
		return url;
	}

	@AuraEnabled
	public static Boolean controlarContactyOrgZona(Id caseId) {
		return ![SELECT Id FROM Case WHERE Id = :caseId AND (ContactId = NULL OR SEG_Organizacion__c = NULL OR SEG_Zona__c = NULL)].isEmpty();
	}
}