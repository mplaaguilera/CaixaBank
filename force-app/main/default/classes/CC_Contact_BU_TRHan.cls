public with sharing class CC_Contact_BU_TRHan extends CC_TriggerHandlerBase {

	public override void mainEntry(CC_TriggerParameters tp) {
		process((Map<Id, Contact>)tp.oldMap, (Map<Id, Contact>)tp.newMap, (List<Contact>)tp.newList);
	}

	private void process(Map<Id, Contact> mapOldObj, Map<Id, Contact> mapNewObj, List<Contact> listNewObj) {

		


		//CSBD
		Id idRecordTypeTitularHipoteca = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CSBD_TitularHipoteca').getRecordTypeId();
		Map<Id, Contact> mapNewTitularesCsbd = new Map<Id, Contact>();
		for (Contact contacto : listNewObj) {
			if (contacto.RecordTypeId == idRecordTypeTitularHipoteca) {
				mapNewTitularesCsbd.put(contacto.Id, contacto);
			}
		}
		if (!mapNewTitularesCsbd.isEmpty()) {
			informarCampoPrioridad(mapNewTitularesCsbd, mapOldObj);
		}


		//COPS
		if (FeatureManagement.checkPermission('OS_CP_Responsable')) {
			evitarDuplicadosCOPS(listNewObj, mapNewObj, mapOldObj);
		}


		//CC
		if (AdminSettings__c.getInstance().Validaciones__c) { //Custom Setting para deshabilitar esta compribación (Cargas de Datos)
			Id idRtColaborador = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
			List<Contact> colaboradoresCorreoModificado = new List<Contact>();
			Set<String> correosModificados = new Set<String>();
			for (Contact contacto : listNewObj) {
				if (contacto.RecordTypeId == idRtColaborador && mapOldObj.get(contacto.Id).Email != contacto.Email) {
					colaboradoresCorreoModificado.add(contacto);
					correosModificados.add(contacto.Email);
				}
			}
			if (!correosModificados.isEmpty()) {
				List<String> correosDup = CC_MetodosUtiles.listaCampo([SELECT Email FROM Contact WHERE Email IN :correosModificados
																		AND RecordTypeId = :idRtColaborador], 'Email', true);
				for (Contact colaborador : colaboradoresCorreoModificado) { //Ahora busco cuáles de los nuevos contactos tienen alguno de los emails repetidos
					if (correosDup.contains(colaborador.Email)) { //sobre esos, lanzo un error
						colaborador.addError('Ya existe un colaborador con la misma dirección de correo');
					}
				}
			}
		}

		//CONFIDENCIALES
		vaciarContactoConfidencial(listNewObj);
	}

	private static void evitarDuplicadosCOPS(List<Contact> newContacts, Map<Id, Contact> mapIdContacts, Map<Id, Contact> mapOldObj) {
		Id idRecordTypeBuzonContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('OS_Buzon_Contact').getRecordTypeId();
		Set<String> emails = new Set<String>();
		for (Contact contacto : newContacts) {
			if (contacto.RecordTypeId == idRecordTypeBuzonContact && mapOldObj.get(contacto.Id).Email != mapIdContacts.get(contacto.Id).Email) {
				emails.add(contacto.email);
			}
		}

		if (!emails.isEmpty()) {
			Map<String, List<Id>> mapaEmailRT = new Map<String, List<Id>>();
			for (Contact contactoDuplicado : [SELECT Email, RecordTypeId FROM Contact WHERE Email IN :emails AND RecordType.DeveloperName = 'OS_Buzon_Contact']) {
				if (mapaEmailRT.containsKey(contactoDuplicado.Email)) {
					mapaEmailRT.get(contactoDuplicado.Email).add(contactoDuplicado.RecordTypeId);
				} else {
					mapaEmailRT.put(contactoDuplicado.Email, new List<Id>{contactoDuplicado.RecordTypeId});
				}
			}

			//Ahora busco cuáles de los nuevos contactos tienen alguno de los emails repetidos, y sobre esos, lanzo un error.
			for (Contact contacto : newContacts) {
				if (mapaEmailRT.keySet().contains(contacto.Email)) {
					if (contacto.RecordTypeId == idRecordTypeBuzonContact && (mapaEmailRT.get(contacto.Email).contains(idRecordTypeBuzonContact))) {
						contacto.addError('Ya existe un Contacto con el mismo Email.');
					}
				}
			}
		}
	}

	public static void informarCampoPrioridad(Map<Id, Contact> mapNewTitularesCsbd, Map<Id, Contact> mapOldObj) {
		Map<Id, Contact> titularesCambioPrioridad = new Map<Id, Contact>();
		for (Id idTitularNew : mapNewTitularesCsbd.keySet()) {
			Contact titularOld = mapOldObj.get(idTitularNew);
			Contact titularNew = mapNewTitularesCsbd.get(idTitularNew);
			if (titularOld.CSBD_Profesion__c != titularNew.CSBD_Profesion__c
			|| titularOld.CSBD_ClienteCaixabank__c != titularNew.CSBD_ClienteCaixabank__c) {
				titularesCambioPrioridad.put(titularNew.Id, titularNew);
			}
		}

		if (!titularesCambioPrioridad.isEmpty()) {
			List<Opportunity> oportunidades = new List<Opportunity>([SELECT RecordTypeId, CSBD_Tasacion__c, CSBD_Urgencia__c, CSBD_UsoVivienda2__c, Amount, CSBD_ContactoTitular1__c, CSBD_ContactoTitular2__c, CSBD_Datos_Calculo_DTI__c, CSBD_AportacionInicial__c, CSBD_TipoOperacion2__c, CSBD_PrecioInmueble__c, CSBD_Now_Plazo__c, CSBD_TIN_Inicial__c, CSBD_PorcentajeBonificacion__c
																		FROM Opportunity WHERE RecordType.DeveloperName = 'CSBD_Hipoteca' AND IsClosed = FALSE
																		AND CSBD_ContactoTitular1__c IN :titularesCambioPrioridad.keySet()]);
			if (!oportunidades.isEmpty()) {
				CSBD_Hipoteca.informarCampoPrioridad(oportunidades, titularesCambioPrioridad);
				update oportunidades;
			}
		}
	}

	private void vaciarContactoConfidencial(List<Contact> contactos) {

		for (Contact contacto : contactos) {
			if (contacto.CC_Confidencial__c == true) {
				contacto.Birthdate = null;
				contacto.CC_CuentaFacebook__c = '';
				contacto.CC_CuentaTwitter__c = '';
				contacto.CC_EmpleadoGestorId__c = null;
				contacto.CC_FechaNac__c = null;
				contacto.CC_Identificador_CBKNow__c = '';
				contacto.CC_Idioma__c = null;
				contacto.CC_OficinaGestoraId__c = null;
				contacto.CC_Segmento__c = '';
				contacto.CC_Sexo__c = null;
				contacto.Email = '';
				contacto.FirstName = '';
				contacto.LastName = 'CONFIDENCIAL';
				contacto.MailingCity = null;
				contacto.MailingCountry = null;
				contacto.MailingPostalCode = null;
				contacto.MailingState = null;
				contacto.MailingStreet = null;
				contacto.MobilePhone = '';
				contacto.Phone = '';
				contacto.Salutation = null;

			}
		}
	}
}