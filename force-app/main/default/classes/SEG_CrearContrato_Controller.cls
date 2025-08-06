public with sharing class SEG_CrearContrato_Controller {


	/*
	@AuraEnabled
	static public String getLCVista(String urlpath) {
		// String hostVal  = ApexPages.currentPage().getHeaders().get('Host');
		//String urlVal = Apexpages.currentPage().getUrl();
		//String URLL = 'https://' + hostVal+ urlVal;

		//String currentURl = Site.getCurrentSiteUrl();

		////System.debug(hostVal + 'HOST VAL');
		////System.debug(urlVal + 'URL VAL');
		////System.debug(currentURl + 'CURRENT URL VAL');
		String keyPrefix = Case.SObjectType.getDescribe().getKeyPrefix();
		String caseId;

		List<String> splitPath = urlpath.replace('/', ' ').replace('%', ' ').split(' ');
		for (String s : splitPath) {
			//System.debug(s);
			if (s instanceOf Id && s.startsWith(keyPrefix)) caseId = s;
		}
		//System.debug(caseId);
		//System.debug(keyPrefix);
		return caseId;
	}
	*/

	@AuraEnabled
	public static string getCaseNum(String caseid) {
		List<Case> caso = [SELECT caseNumber FROM Case WHERE Id = :caseid LIMIT 1];
		return caso[0].caseNumber;
	}

	@AuraEnabled
	static public Map<Id, Account> buscadorAccounts(String searchKey) {

		//Se rellena una lista con account names(encrypted)
		List<String> accountNames = new List<String> ();
		Id rtClienteSegSS = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
		Id rtClienteSeg = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
		Id rtClienteSegPA = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();


		for (Account accName :[SELECT id, Name FROM Account])
		{
			accountNames.add(accName.Name);
		}

		Map<Id, Account> mapAccounts = new Map<Id, Account> ();
		String name = '%' + searchKey + '%';
		if (searchKey == '') {
			return null;

		} else {
			//System.debug('Buscando... ' + searchKey);
			List<Account> accounts = new List<Account> ();
			if (String.isNotBlank(searchKey) && searchKey.length() > 1) {
				List<List<SObject>> searchResults = [
				                                     FIND :searchKey
				                                     RETURNING Account(
				                                                       Id, Name WHERE RecordTypeId = :rtClienteSeg
																	   OR RecordTypeId = :rtClienteSegSS OR RecordTypeId = :rtClienteSegPA
				                                                       LIMIT 6
				)
				                                    ];
				accounts = searchResults[0];
			}
			for (Account account : accounts) {
				mapAccounts.put(account.Id, account);
				//System.debug('PUT ' + account);
			}

			// mapAccounts = new Map<Id, SEG_Plantilla__c>([SELECT id, Name FROM Account WHERE Name LIKE :name LIMIT 6]);
		}
		//System.debug('RETURN VALUE' + mapAccounts.size());
		//System.debug(mapAccounts);
		return mapAccounts;
	}

	@AuraEnabled
	static public Map<Id, Contact> buscadorContacts(String searchKey, String relatedAccount) {

		//Se rellena una lista con contact names(encrypted)
		List<String> contactNames = new List<String> ();
		Id rtCliente = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();

		for (Contact conName :[SELECT id, Name FROM Contact])
		{
			contactNames.add(conName.Name);
		}

		Map<Id, Contact> mapContacts = new Map<Id, Contact> ();
		String name = '%' + searchKey + '%';
		if (searchKey == '') {
			return null;

		} else {
			//System.debug('Buscando... ' + searchKey);
			List<Contact> contacts = new List<Contact> ();
			if (String.isNotBlank(searchKey) && searchKey.length() > 1) {
				List<List<SObject>> searchResults = [
				                                     FIND :searchKey
				                                     RETURNING Contact(
				                                                       Id, Name WHERE AccountId = :relatedAccount AND recordtypeId = :rtCliente
				                                                       LIMIT 6
				)
				                                    ];
				contacts = searchResults[0];
			}
			for (Contact contact : contacts) {
				mapContacts.put(contact.Id, contact);
				//System.debug('PUT ' + contact);
			}

		}
		//System.debug('RETURN VALUE' + mapContacts.size());
		//System.debug(mapcontacts);
		return mapContacts;
	}

	//Buscador dinámico de Clasificaciones Rápidas
	@AuraEnabled
	static public Map<Id, SEG_ClasificacionRapida__c> buscadorCR(String searchKey) {
		Map<Id, SEG_ClasificacionRapida__c> mapCRs = new Map<Id, SEG_ClasificacionRapida__c> ();
		if (searchKey == '') {
			return null;
		} else {
			//System.debug('Buscando... ' + searchKey);
			List<SEG_ClasificacionRapida__c> CRs = new List<SEG_ClasificacionRapida__c> ();
			if (String.isNotBlank(searchKey) && searchKey.length() > 1) {
				List<List<SObject>> searchResults = [
				                                     FIND :searchKey
				                                     RETURNING SEG_ClasificacionRapida__c(
				                                                                          Id, Name WHERE SEG_CRContratos__c = true
				                                                                          LIMIT 6
				)
				                                    ];
				CRs = searchResults[0];
			}
			for (SEG_ClasificacionRapida__c cr : CRs) {
				mapCRs.put(cr.Id, cr);
				//System.debug('PUT ' + cr);
			}
		}
		//System.debug('RETURN VALUE' + mapCRs.size());
		//System.debug(mapCRs);
		return mapCRs;
	}


	@AuraEnabled
	static public String crearSR(String crId, Integer numeroOps, String accountId, String contactId) {

		String idioma = 'es'; // Idioma por defecto.
		Contact contacto;
		List<Contact> listadoContactos = [SELECT CC_Idioma__c FROM Contact WHERE Id = :contactId LIMIT 1];
		if (!listadoContactos.isEmpty())
		{
			contacto = listadoContactos[0];
			idioma = listadoContactos[0].CC_Idioma__c;
		}

		SEG_ClasificacionRapida__c clasificacionRapida;
		List<SEG_ClasificacionRapida__c> clasificaciones = [SELECT Id, SEG_Detalle__c, SEG_Motivo__c, SEG_Producto__c, SEG_Tematica__c, SEG_Prioridad__c, SEG_Canaldeentrada__c
		                                                    FROM SEG_ClasificacionRapida__c WHERE Id = :crId LIMIT 1];
		if (!clasificaciones.isEmpty())
		{
			clasificacionRapida = clasificaciones[0];
		}

		Account cuenta;
		List<Account> cuentas = [SELECT SEG_Zona__c, SEG_Organizacion__c, CC_Numero_Oficina__c, RecordTypeId, AV_OficinaPrincipal__c,
		                         AV_OficinaPrincipal__r.CC_Numero_Oficina__c, 
		                         SEG_Oficina_Gestora_Segmentos__r.CC_Numero_Oficina__c, SEG_Oficina_Gestora_Segmentos__c, SEG_N_centro__c
		                         FROM Account WHERE Id = :accountId LIMIT 1];
		if (!cuentas.isEmpty())
		{
			cuenta = cuentas[0];
		}

		Group colasBO = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SEG_BO' LIMIT 1];

		Id recordTypeSeguimiento = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId();

		Case caso = new Case();
		caso.RecordTypeId = recordTypeSeguimiento;
		caso.SEG_ClasificacionRapida__c = clasificacionRapida?.Id;
		caso.OS_Numero_Operaciones__c = numeroOps;
		caso.AccountId = cuenta?.Id;
		caso.ContactId = contacto?.Id;
		caso.SEG_Idioma__c = idioma;

		caso.CC_MCC_Tematica__c = clasificacionRapida?.SEG_Tematica__c;
		caso.CC_MCC_ProdServ__c = clasificacionRapida?.SEG_Producto__c;
		caso.CC_MCC_Motivo__c = clasificacionRapida?.SEG_Motivo__c;
		caso.SEG_Detalle__c = clasificacionRapida?.SEG_Detalle__c;
		caso.Origin = clasificacionRapida?.SEG_Canaldeentrada__c;
		caso.Priority = clasificacionRapida?.SEG_Prioridad__c;

		caso.SEG_Organizacion__c = cuenta?.SEG_Organizacion__c;
		caso.SEG_Zona__c = cuenta?.SEG_Zona__c;
		caso.SEG_Numero_de_centro__c = accountId;
		caso.OwnerId = colasBO.id;

		if (cuenta?.CC_Numero_Oficina__c != null && cuenta?.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId()) {
			caso.SEG_Numero_de_centro__c = cuenta?.Id;
			caso.SEG_Numero_centro__c = cuenta?.CC_Numero_Oficina__c;
		}
		else {
			if (cuenta?.SEG_Oficina_Gestora_Segmentos__c != null) {
				caso.SEG_Numero_centro__c = cuenta?.SEG_Oficina_Gestora_Segmentos__r.CC_Numero_Oficina__c;
				caso.SEG_Numero_de_centro__c = cuenta?.SEG_Oficina_Gestora_Segmentos__c;
			} else if (cuenta?.AV_OficinaPrincipal__c != null) {
				caso.SEG_Numero_centro__c = cuenta?.AV_OficinaPrincipal__r.CC_Numero_Oficina__c;
				caso.SEG_Numero_de_centro__c = cuenta?.AV_OficinaPrincipal__c;
			}
			else {
				caso.SEG_Numero_centro__c = cuenta?.SEG_N_centro__c;
			}
		}

		insert caso;

		String observacion = 'Grupo automática SR Seguimiento';
		SEG_Case_Operativas_Controller.autoAsignarGrupo(caso.Id);

		return caso.Id;
	}
	@AuraEnabled
	static public String crearContrato(String descripcion, String contractId, Date FechaRecepcion, Date FechaContrato, String casoId, String estado) {
		try {
            String idioma = '';
			List<Case> caso = [SELECT contactId, accountId, SEG_Grupo__c, SEG_Organizacion__c, SEG_Zona__c, Account.Name, Account.CC_Numero_Documento__c, SEG_Grupo_Empresa__c, SEG_ClasificacionRapida__c FROM Case WHERE Id = :casoId LIMIT 1];
            if (!caso.isEmpty())
            {
                List<Contact> listadoContactos = [SELECT CC_Idioma__c FROM Contact WHERE Id = :caso[0].contactId LIMIT 1];
                if (!listadoContactos.isEmpty())
                {
                    idioma = (String.isNotBlank(listadoContactos[0].CC_Idioma__c) && listadoContactos[0].CC_Idioma__c == 'ca') ? 'Catalán' : idioma;
                    idioma = (String.isNotBlank(listadoContactos[0].CC_Idioma__c) && listadoContactos[0].CC_Idioma__c == 'es') ? 'Castellano' : idioma;
                    idioma = (String.isNotBlank(listadoContactos[0].CC_Idioma__c) && listadoContactos[0].CC_Idioma__c == 'eu') ? 'Euskera' : idioma;
                    idioma = (String.isNotBlank(listadoContactos[0].CC_Idioma__c) && listadoContactos[0].CC_Idioma__c == 'ga') ? 'Gallego' : idioma;
                    idioma = (String.isNotBlank(listadoContactos[0].CC_Idioma__c) && listadoContactos[0].CC_Idioma__c == 'en') ? 'Inglés' : idioma;
                }

                // Idioma por defecto.
                idioma = (String.isBlank(idioma)) ? 'Castellano' : idioma;

                SEG_Contratos__c contrato = new SEG_Contratos__c();
                contrato.SEG_NombreCuenta__c = caso[0].accountId;
                contrato.Name = contractId;
                contrato.SEG_NombreCliente__c = caso[0].contactId;
                contrato.SEG_Descripcion__c = descripcion;
                contrato.SEG_Fecha_Contrato__c = FechaContrato;
                contrato.SEG_Fecha_Recepcion_Original__c = FechaRecepcion;
                contrato.SEG_SR_Seguimiento__c = casoId;
                contrato.SEG_Idioma__c = idioma;
                contrato.SEG_Estado__c = estado;
                insert contrato;

                return contrato.Id;
            }else{
                throw new AuraHandledException('No se ha generado el contrato, ya que no existe un caso de seguimiento asociado.');
            }
		} catch(System.DmlException ex) {
			if(ex.getMessage().contains('There are not reclamaciones')){
				throw new AuraHandledException('No hay reclamaciones');
			}else{
				throw ex;
			}
		}
	}
}