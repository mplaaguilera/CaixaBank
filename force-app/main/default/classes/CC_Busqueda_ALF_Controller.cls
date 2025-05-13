public with sharing class CC_Busqueda_ALF_Controller {

	@AuraEnabled
	public static Map<String, Object> getIdentidad(String tipoBusqueda, String valorBusqueda) {
		return CC_IdentCliente_Future.IdentificarPersALFSync_CC(tipoBusqueda, valorBusqueda, true);
	}

	public class ContratoPicklistItemWrapper {
		@AuraEnabled
		public String value {get;set;}
		@AuraEnabled
		public String label {get;set;}
	}

	public class RepresentanteOrContactoWrapper {
		@AuraEnabled
		public Boolean representante {get;set;}
		@AuraEnabled
		public String idContacto {get;set;}
		@AuraEnabled
		public String idRepresentante {get;set;}
		@AuraEnabled
		public String idJunction {get;set;}
		@AuraEnabled
		public String nombre {get;set;}
		@AuraEnabled
		public String nombreCuenta {get;set;}
		@AuraEnabled
		public String nombreContrato {get;set;}
		@AuraEnabled
		public String tipoRepresentante {get;set;}
		@AuraEnabled
		public String cargoRepresentante {get;set;}
		@AuraEnabled
		public String idCuenta {get;set;}
		@AuraEnabled
		public String tipoPersonaCliente {get;set;}
	}

	/*@AuraEnabled(cacheable=true)
	public static List<ContratoPicklistItemWrapper> getContratosCliente(String sRepresentanteOrContactoId, String sTipoRegistro) {
		List<ContratoPicklistItemWrapper> oContratos = new List<ContratoPicklistItemWrapper>();
		String sClienteId = '';
		if (sTipoRegistro == 'Representante') {
			sClienteId = [SELECT CC_ClienteRepresentante__c FROM CC_Representante_Contrato__c
							WHERE Id = :sRepresentanteOrContactoId].CC_ClienteRepresentante__c;
		} else if (sTipoRegistro == 'Contacto') {
			sClienteId = [SELECT AccountId FROM Contact
							WHERE Id = :sRepresentanteOrContactoId].AccountId;
		}

		for (CC_Representante_Contrato__c contrato : [SELECT CC_Contrato__c FROM CC_Representante_Contrato__c
														WHERE RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Representante_Contrato__c', 'CC_Contrato')
														AND CC_ClienteContrato__c = :sClienteId]) {
			ContratoPicklistItemWrapper contratoPicklistItem = new ContratoPicklistItemWrapper();
			contratoPicklistItem.value = contrato.Id;
			contratoPicklistItem.label = contrato.CC_Contrato__c + ' - ' + 'Descripción del contrato';
			oContratos.add(contratoPicklistItem);
		}
		return oContratos;
	}*/

	/*@AuraEnabled
	public static void asociarContratoAlCaso(String sContratoId, String sCasoId) {
		if (String.isNotBlank(sContratoId) && String.isNotBlank(sCasoId)) {
			Case caso = new Case(Id = sCasoId);
			caso.CC_Contrato__c = sContratoId;
			update caso;
		}
	}*/

	@AuraEnabled(cacheable=true)
	public static List<RepresentanteOrContactoWrapper> getRepresentantesOrContactosCliente(String sCliente) {
		List<RepresentanteOrContactoWrapper> oRepresentantesOrContactos = new List<RepresentanteOrContactoWrapper>();
		// Si no hay datos, salir.
		if (String.isBlank(sCliente)) {
			return null;
		}

		List<Account> cuenta = [SELECT RecordType.DeveloperName, CC_Tipo_Persona__c, CC_Edad__pc FROM Account WHERE Id = :sCliente];

        String sTipoPersona = cuenta[0].CC_Tipo_Persona__c;
		Decimal edad = cuenta[0].CC_Edad__pc ;

		// Buscar los representantes de la cuenta.
		if (sTipoPersona == 'J') {
			/*for (Contact representante : [SELECT CC_CuentaRepresentada__c, CC_CuentaRepresentada__r.Name, FirstName, LastName, CC_CargoRepresentante__c FROM Contact
											WHERE CC_CuentaRepresentada__c = :sCliente AND CC_CuentaRepresentada__r.CC_NumPerso__c <> null
											AND RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Representante')]) {
				RepresentanteOrContactoWrapper representanteWrapper = new RepresentanteOrContactoWrapper();
				representanteWrapper.representante = true;
				representanteWrapper.tipoPersonaCliente = sTipoPersona;
				representanteWrapper.idRepresentante = representante.Id;
				representanteWrapper.nombre = representante.FirstName + ' ' +  representante.LastName;
				representanteWrapper.nombreCuenta = representante.CC_CuentaRepresentada__r.Name;
				representanteWrapper.idCuenta = representante.CC_CuentaRepresentada__c;
				representanteWrapper.cargoRepresentante = representante.CC_CargoRepresentante__c;
				oRepresentantesOrContactos.add(representanteWrapper);
			}*/

            for (Contact representante : [SELECT Account.Name, FirstName, LastName, CC_CargoRepresentante__c FROM Contact
											WHERE AccountId = :sCliente AND RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CIBE_Apoderado')]) {
				RepresentanteOrContactoWrapper representanteWrapper = new RepresentanteOrContactoWrapper();
				representanteWrapper.representante = true;
				representanteWrapper.tipoPersonaCliente = sTipoPersona;
				representanteWrapper.idRepresentante = representante.Id;
				representanteWrapper.nombre = representante.FirstName + ' ' +  representante.LastName;
				representanteWrapper.nombreCuenta = representante.Account.Name;
				representanteWrapper.idCuenta = representante.AccountId;
				representanteWrapper.cargoRepresentante = 'Apoderado';
				oRepresentantesOrContactos.add(representanteWrapper);
			}

		} else if (sTipoPersona == 'F' && edad >=18) {
			for (CC_Representante_Contrato__c representante : [SELECT CC_RepresentanteAsociado__r.CC_ClienteRepresentante__c, CC_RepresentanteAsociado__c, CC_RepresentanteAsociado__r.CC_Nombre__c, CC_RepresentanteAsociado__r.CC_Apellido1__c, CC_RepresentanteAsociado__r.CC_Apellido2__c, CC_RepresentanteAsociado__r.CC_TipoRepresentante__c, CC_ContratoAsociado__r.Name
																FROM CC_Representante_Contrato__c WHERE CC_RepresentanteAsociado__r.CC_ClienteRepresentante__r.Id = :sCliente
																AND CC_RepresentanteAsociado__r.CC_ClienteRepresentante__r.CC_NumPerso__c <> null
																AND RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Representante')]) {
				RepresentanteOrContactoWrapper representanteWrapper = new RepresentanteOrContactoWrapper();
				representanteWrapper.representante = true;
				representanteWrapper.tipoPersonaCliente = sTipoPersona;
				representanteWrapper.idJunction = representante.Id;
				representanteWrapper.idRepresentante = representante.CC_RepresentanteAsociado__c;
				representanteWrapper.nombre = representante.CC_RepresentanteAsociado__r.CC_Nombre__c + ' ' + representante.CC_RepresentanteAsociado__r.CC_Apellido1__c + ' ' + representante.CC_RepresentanteAsociado__r.CC_Apellido2__c;
				representanteWrapper.nombreContrato = representante.CC_ContratoAsociado__r.Name;
				representanteWrapper.idCuenta = representante.CC_RepresentanteAsociado__r.CC_ClienteRepresentante__c;
				representanteWrapper.tipoRepresentante = representante.CC_RepresentanteAsociado__r.CC_TipoRepresentante__c;
				oRepresentantesOrContactos.add(representanteWrapper);
			}
		} else if (sTipoPersona == 'F' && edad <18) {
			for (CC_Representante_Contrato__c representante : [SELECT CC_Representante__c, CC_Representante__r.Name, CC_ClienteRepresentante__c, CC_ClienteRepresentante__r.Name, CC_TipoRepresentante__c, CC_ContratoAsociado__r.Name
																FROM CC_Representante_Contrato__c WHERE CC_ClienteRepresentante__c = :sCliente
																AND CC_ClienteRepresentante__r.CC_NumPerso__c <> null
																AND RecordType.DeveloperName =:'CC_Representante']) {
				RepresentanteOrContactoWrapper representanteWrapper = new RepresentanteOrContactoWrapper();
				representanteWrapper.representante = true;
				representanteWrapper.tipoPersonaCliente = sTipoPersona;
				representanteWrapper.idJunction = representante.Id;
				representanteWrapper.idRepresentante = representante.CC_ClienteRepresentante__c;
				representanteWrapper.nombre = representante.CC_Representante__r.Name;
				representanteWrapper.nombreContrato = representante.CC_ContratoAsociado__r.Name;
				representanteWrapper.idCuenta = representante.CC_ClienteRepresentante__c;
				representanteWrapper.tipoRepresentante = representante.CC_TipoRepresentante__c;
				oRepresentantesOrContactos.add(representanteWrapper);
			}
		}

		// Si la cuenta no tiene representantes, buscar sus contactos.
		if (oRepresentantesOrContactos.isEmpty()) {
			oRepresentantesOrContactos = getContactosCliente(sCliente);
		}
		return oRepresentantesOrContactos;
	}

	@AuraEnabled(cacheable=true)
	public static List<RepresentanteOrContactoWrapper> getContactosCliente(String sCliente) {
		List<RepresentanteOrContactoWrapper> oContactos = new List<RepresentanteOrContactoWrapper>();
		for (Contact contacto : [SELECT AccountId, Name, Account.Name FROM Contact
									WHERE Account.Id = :sCliente AND Account.CC_NumPerso__c <> null
									AND (RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente') OR RecordTypeId = null)]) {
			RepresentanteOrContactoWrapper contactoWrapper = new RepresentanteOrContactoWrapper();
			contactoWrapper.representante = false;
			contactoWrapper.idContacto = contacto.Id;
			contactoWrapper.nombre = contacto.Name;
			contactoWrapper.nombreCuenta = contacto.Account.Name;
			contactoWrapper.idCuenta = contacto.AccountId;
			oContactos.add(contactoWrapper);
		}
		return oContactos;
	}

	@AuraEnabled
	public static String setClienteCaso(String sID, String sTipo, String sCasoId) {

		Map<String, Object> oRes = new Map<String, Object>();

		if (String.isBlank(sID) || String.isBlank(sTipo)) {
			return 'No se ha seleccionado un registro válido';
		} else if (String.isBlank(sCasoId)) {
			return 'No hay un caso vinculado';
		}
		//Preparar los datos de cuenta y contacto para actualizar en el caso.
		String sRepresentanteId = '';
		String sContactId = '';
		String sCuentaId = '';
		String sContratoId = '';
		if (sTipo == 'Representante') {
            if (String.valueOf(Id.valueOf(sID)?.getSObjectType()) == 'Contact'){
				sContactId = sID;
				Contact oContacto = [SELECT CC_CuentaRepresentada__c FROM Contact WHERE Id = :sID];
					if (oContacto.CC_CuentaRepresentada__c != null) {
						sCuentaId = oContacto.CC_CuentaRepresentada__c;
					}
			}else{
			// PENDIENTE PERSONAS REPRESENTANTES LEGALES PERSONAS FÍSICAS.
			CC_Representante_Contrato__c oRepresentante = [SELECT RecordTypeId, CC_Representante__c, CC_RepresentanteAsociado__c, CC_ContratoAsociado__c, CC_ClienteRepresentante__c, CC_RepresentanteAsociado__r.CC_ClienteRepresentante__c FROM CC_Representante_Contrato__c WHERE Id = :sID];
            //String sRepresentanteContratoRecordTypeId = Schema.SObjectType.CC_Representante_Contrato__c.getRecordTypeInfosByDeveloperName().get('CC_RepresentanteContrato').getRecordTypeId();
			String sRepresentanteRecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Representante_Contrato__c', 'CC_Representante');

            /*if (oRepresentante.RecordTypeId == sRepresentanteContratoRecordTypeId && oRepresentante.CC_RepresentanteAsociado__c != null && oRepresentante.CC_RepresentanteAsociado__r.CC_ClienteRepresentante__c != null) {
				sRepresentanteId = oRepresentante.CC_RepresentanteAsociado__c;
				sContratoId = oRepresentante.CC_ContratoAsociado__c;
				sCuentaId = oRepresentante.CC_RepresentanteAsociado__r.CC_ClienteRepresentante__c;
			} else */
			if(oRepresentante.RecordTypeId == sRepresentanteRecordTypeId && oRepresentante.CC_ClienteRepresentante__c != null) {
				sRepresentanteId = sID;
				sCuentaId = oRepresentante.CC_ClienteRepresentante__c;
				if(oRepresentante.CC_Representante__c != null){
					Contact oContacto = [SELECT Id FROM Contact WHERE AccountId = :oRepresentante.CC_Representante__c LIMIT 1];
					if (oContacto != null) {
						sContactId = oContacto.Id;
					}

				}
				if (sCuentaId == ''){
					sContactId = sID;
					// Buscamos el cliente asociado al contacto.
					Contact oContacto = [SELECT CC_CuentaRepresentada__c FROM Contact WHERE Id = :sContactId];
					if (oContacto.CC_CuentaRepresentada__c != null) {
						sCuentaId = oContacto.CC_CuentaRepresentada__c;
					}
				}
			}
		}


		} else if (sTipo == 'Contacto') {
			sContactId = sID;
			// Buscamos el cliente asociado al contacto.
			Contact oContacto = [SELECT AccountId FROM Contact WHERE Id = :sContactId];
			if (oContacto.AccountId != null) {
				sCuentaId = oContacto.AccountId;
			}
		} else {
			sCuentaId = sID;
			//FUSIÓN	if (sContMantener != '')
			//FUSIÓN	sContactId = sContMantener;

			// Mientras no está activa la fusión (a revisar si se activa este trozo de código).
			// Actualizar si sólo existe un contacto asociado a la cuenta.

			List<Contact> oContactos = [SELECT Id FROM Contact WHERE AccountId = :sID];
			if (oContactos.size() == 1) {
				sContactId = oContactos[0].Id;
			}
		}

		// Actualizamos el caso con los datos facilitados por el usuario.
		Case oCaseUpd = new Case(Id = sCasoId);

		if (sRepresentanteId != '') {
			oCaseUpd.CC_Representante__c = sRepresentanteId;
		}/* else {
			oCaseUpd.CC_Representante__c = null;
		}*/

		/*if (sContratoId != '') {
			oCaseUpd.CC_Contrato__c = sContratoId;
		} else {
			oCaseUpd.CC_Contrato__c = null;
		}*/

		if (sContactId != '') {
			oCaseUpd.ContactId = sContactId;
		} else {
			oCaseUpd.ContactId = null;
		}

		if (sCuentaId != '') {
			oCaseUpd.AccountId = sCuentaId;
		} else {
			oCaseUpd.AccountId = null;
		}

		if (oCaseUpd.AccountId == null && oCaseUpd.ContactId == null && oCaseUpd.CC_Representante__c == null) {
			oCaseUpd.CC_No_Identificado__c = true;
			oCaseUpd.CC_IdentCliente__c = '0'; //Sin datos ALF
		} else {
			oCaseUpd.CC_No_Identificado__c = false;
			oCaseUpd.CC_IdentCliente__c = '2'; // Alfabetico manual
		}
		update oCaseUpd;
		return '';
	}

	@AuraEnabled
	public static String setClienteOpportunity(String sID, String sTipo, Id recordId) {
		try {
			String nombreCuenta = '';

			if (String.isBlank(sID) || String.isBlank(sTipo)) {
				return 'No se ha seleccionado un registro válido.';
			}

			Opportunity oportunidad = new Opportunity(Id = recordId);
			List<Contact> contactos = new List<Contact>();
			if (sTipo == 'Contacto') {
				contactos = [SELECT AccountId, Account.Name, Phone, Email FROM Contact WHERE Id = :sID];
			} else if (sTipo == 'Cuenta') {
				contactos = [SELECT Account.Name, Phone, Email FROM Contact WHERE AccountId = :sID LIMIT 1];
			}

			if (contactos.size() == 1) {
				oportunidad.AccountId = contactos[0]?.AccountId;
				oportunidad.CSBD_Contact__c = contactos[0]?.Id;
				update oportunidad;
				nombreCuenta = contactos[0].Account.Name;
			}
			return nombreCuenta;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled(cacheable=true)
	public static String getContactoAsoc(String sCuenta) {
		return [SELECT Id FROM Contact WHERE AccountId = :sCuenta].Id;
	}

	@AuraEnabled
	public static String setClienteLlamada(String sID, String sTipo, String sLlamadaId) {
		Map<String, Object> oRes = new Map<String, Object>();

		// Si no hay datos, salir.
		if (sID == '' || sID == null || sTipo == '' || sTipo == null) {
			return 'No se ha seleccionado un registro válido';
		}

		if (sLlamadaId == '' || sLlamadaId == null) {
			return 'No hay una llamada vinculada';
		}

		// Preparar los datos de cuenta y contacto para actualizar en el caso.
		String sContactId = '';
		String sCuentaId = '';
		String sRepresentanteId = '';
		if (sTipo == 'Representante') {
			/* PENDIENTE PERSONAS REPRESENTANTES LEGALES PERSONAS FÍSICAS.
			 * CC_Representante_Contrato__c oRepresentante = [SELECT RecordTypeId, CC_RepresentanteAsociado__c, CC_ContratoAsociado__c, CC_ClienteRepresentante__c, CC_RepresentanteAsociado__r.CC_ClienteRepresentante__c FROM CC_Representante_Contrato__c WHERE Id = :sID];
			String sRepresentanteContratoRecordTypeId = Schema.SObjectType.CC_Representante_Contrato__c.getRecordTypeInfosByDeveloperName().get('CC_RepresentanteContrato').getRecordTypeId();
			String sRepresentanteRecordTypeId = Schema.SObjectType.CC_Representante_Contrato__c.getRecordTypeInfosByDeveloperName().get('CC_Representante').getRecordTypeId();
			if (oRepresentante.RecordTypeId == sRepresentanteContratoRecordTypeId && oRepresentante.CC_RepresentanteAsociado__c != null && oRepresentante.CC_RepresentanteAsociado__r.CC_ClienteRepresentante__c != null) {
				sRepresentanteId = oRepresentante.CC_RepresentanteAsociado__c;
				sContratoId = oRepresentante.CC_ContratoAsociado__c;
				sCuentaId = oRepresentante.CC_RepresentanteAsociado__r.CC_ClienteRepresentante__c;
			} else if (oRepresentante.RecordTypeId == sRepresentanteRecordTypeId && oRepresentante.CC_ClienteRepresentante__c != null) {
				sRepresentanteId = sID;
				sCuentaId = oRepresentante.CC_ClienteRepresentante__c;
			}*/

			CC_Representante_Contrato__c oRepresentante = [SELECT RecordTypeId,CC_Representante__c, CC_RepresentanteAsociado__c, CC_ContratoAsociado__c, CC_ClienteRepresentante__c, CC_RepresentanteAsociado__r.CC_ClienteRepresentante__c FROM CC_Representante_Contrato__c WHERE Id = :sID];
			String sRepresentanteRecordTypeId = Schema.SObjectType.CC_Representante_Contrato__c.getRecordTypeInfosByDeveloperName().get('CC_Representante').getRecordTypeId();

			if(oRepresentante.RecordTypeId == sRepresentanteRecordTypeId && oRepresentante.CC_ClienteRepresentante__c != null) {
				sRepresentanteId = sID;
				sCuentaId = oRepresentante.CC_ClienteRepresentante__c;
                if(oRepresentante.CC_Representante__c != null){
					Contact oContacto = [SELECT Id FROM Contact WHERE AccountId = :oRepresentante.CC_Representante__c LIMIT 1];
					if (oContacto != null) {
						sContactId = oContacto.Id;
					}

				}
			}
			if(sCuentaId == ''){
				sContactId = sID;
				// Buscamos el cliente asociado al contacto.
				Contact oContacto = [SELECT CC_CuentaRepresentada__c FROM Contact WHERE Id = :sContactId];
				if (oContacto.CC_CuentaRepresentada__c != null) {
					sCuentaId = oContacto.CC_CuentaRepresentada__c;
				}
			}

			/* sContactId = sID;

			// Buscamos el cliente asociado al contacto.
			Contact oContacto = [SELECT CC_CuentaRepresentada__c FROM Contact WHERE Id = :sContactId];
			if (oContacto.CC_CuentaRepresentada__c != null) {
				sCuentaId = oContacto.CC_CuentaRepresentada__c;
			}*/
		} else if (sTipo == 'Contacto') {
			sContactId = sID;

			// Buscamos el cliente asociado al contacto.
			Contact oContacto = [SELECT AccountId FROM Contact WHERE Id = :sContactId];
			if (oContacto.AccountId != null) {
				sCuentaId = oContacto.AccountId;
			}
		} else {
			sCuentaId = sID;
			// Actualizar si sólo existe un contacto asociado a la cuenta.

			List<Contact> oContactos = [SELECT Id FROM Contact WHERE AccountId = :sID];
			if (oContactos.size() == 1) {
				sContactId = oContactos[0].Id;
			}
		}

		// Actualizamos el caso con los datos facilitados por el usuario.
		CC_Llamada__c oLlamadaUpd = new CC_Llamada__c(Id = sLlamadaId);

        if (sRepresentanteId != '') {
			oLlamadaUpd.CC_Representante__c = sRepresentanteId;
		}

		if (sContactId != '') {
			oLlamadaUpd.CC_Contacto__c = sContactId;
		} else {
			oLlamadaUpd.CC_Contacto__c = null;
		}

		if (sCuentaId != '') {
			oLlamadaUpd.CC_Cuenta__c = sCuentaId;
		} else {
			oLlamadaUpd.CC_Cuenta__c = null;
		}

		if (oLlamadaUpd.CC_Contacto__c == null && oLlamadaUpd.CC_Cuenta__c == null) {
			oLlamadaUpd.CC_No_Identificado__c = true;
			oLlamadaUpd.CC_IdentCliente__c = '0'; // Sin datos ALF
		} else {
			oLlamadaUpd.CC_No_Identificado__c = false;
			oLlamadaUpd.CC_IdentCliente__c = '2'; // Alfabetico manual
		}
		update oLlamadaUpd;
		return '';
	}

	@AuraEnabled(cacheable=true)
	public static List<DataTableWrapper> buscarCasos(Id personId) {
		List<Id> oSPList = new List<Id>();
		for (SocialPost socialPost : [SELECT ParentId FROM SocialPost WHERE PersonaId = :personId AND ParentId != null]) {
			oSPList.add(socialPost.ParentId);
		}

		List<Case> casos = [SELECT CaseNumber, Status, Origin, SourceId, OwnerId, Subject
								FROM Case WHERE Id IN :oSPList];

		List<DataTableWrapper> response = new List<DataTableWrapper>();
		for (Case caso : casos) {
			DataTableWrapper obj = new DataTableWrapper();
			obj.caseId = caso.Id;
			obj.caseNumber = caso.CaseNumber;
			obj.caseNumberUrl = '/' + caso.Id;
			obj.status = caso.Status;
			obj.subject = caso.Subject;
			obj.origin = caso.Origin;
			response.add(obj);
		}
		return response;
	}

	private class DataTableWrapper {
		@AuraEnabled
		public Id caseId {get;set;}
		@AuraEnabled
		public String caseNumber {get;set;}
		@AuraEnabled
		public String caseNumberUrl {get;set;}
		@AuraEnabled
		public String status {get;set;}
		@AuraEnabled
		public String subject {get;set;}
		@AuraEnabled
		public String origin {get;set;}
	}

	@AuraEnabled(cacheable=true)
	public static SocialPersona buscarSocialPersona(Id caseId) {
		Case oidSP = [SELECT CC_Social_Persona__c FROM Case WHERE Id = :caseId];
		List<SocialPersona> oSP = [SELECT Name, RealName FROM SocialPersona WHERE Id = :oidSP.CC_Social_Persona__c];
		if (oSP.isEmpty()) {
			return null;
		} else {
			return oSP[0];
		}
	}

	@AuraEnabled
	public static Boolean getEsPropietarioCaso(Id recordId) {
		//Comparamos el usuario logado con el propietario del registro y devolvemos si coinciden o no
		String objectApiName = recordId.getSObjectType().getDescribe().getName();
		if (objectApiName == 'Case') {
			return [SELECT OwnerId FROM Case WHERE Id = :recordId].OwnerId == UserInfo.getUserId();
		} else if (objectApiName == 'CC_Llamada__c') {
			return [SELECT OwnerId FROM CC_Llamada__c WHERE Id = :recordId].OwnerId == UserInfo.getUserId();
		} else if (objectApiName == 'Opportunity') {
			return [SELECT OwnerId FROM Opportunity WHERE Id = :recordId].OwnerId == UserInfo.getUserId();
		}
		return false;
	}

	@AuraEnabled
	public static List<RepresentanteOrContactoWrapper> actualizarIdentificacion(Id recordId, Boolean noIdentificado, String tipoRegistro, String sCliente) {
		if (tipoRegistro == 'CC_Llamada__c') {
			CC_Llamada__c llamada = new CC_Llamada__c(Id = recordId);
			llamada.CC_No_Identificado__c = noIdentificado;
			llamada.CC_Identificado_Manualmente__c = !noIdentificado;
			if (noIdentificado) {
				llamada.CC_Cuenta__c = null;
				llamada.CC_Contacto__c = null;
				llamada.CC_IdentCliente__c = '0'; // Sin datos ALF
			}
			update llamada;
		} else if (tipoRegistro == 'Case') {
			Case caso = new Case(Id = recordId);
			caso.CC_No_Identificado__c = noIdentificado;
			if (noIdentificado) {
				caso.AccountId = null;
				caso.ContactId = null;
				caso.CC_Representante__c = null;
				caso.CC_IdentCliente__c = '0'; // Sin datos ALF
			}
			update caso;
		}
		List<RepresentanteOrContactoWrapper> oRepresentantesOrContactos = new List<RepresentanteOrContactoWrapper>();
		if (sCliente != null) {
			oRepresentantesOrContactos = getRepresentantesOrContactosCliente(sCliente);
		}

		return oRepresentantesOrContactos;
	}

	@AuraEnabled
	public static List<CC_Llamada__c> datosLlamada(String recordId) {
		return [SELECT CC_No_Identificado__c, CC_Fecha_Fin__c FROM CC_Llamada__c WHERE Id = :recordId];
	}

	@AuraEnabled
	public static List<Case> datosCaso(String recordId) {
		return [SELECT CC_No_Identificado__c, ContactId, AccountId FROM Case WHERE Id = :recordId];
	}

	/*
	@AuraEnabled
	public static SObject datosRegistro(String sObjectName, Id recordId) {
		if (sObjectName == 'CC_Llamada__c') {
			return [SELECT CC_No_Identificado__c, CC_Fecha_Fin__c FROM CC_Llamada__c WHERE Id = :recordId];
		} else if (sObjectName == 'Opportunity') {
			return [SELECT AccountId, CSBD_Contact__c FROM Opportunity WHERE Id = :recordId];
		} else {
			return [SELECT CC_No_Identificado__c, AccountId, ContactId FROM Case WHERE Id = :recordId];
		}
	}
	*/

	@AuraEnabled
	public static SObject datosRegistro(Id recordId) {
		String objectApiName = recordId.getSObjectType().getDescribe().getName();
		if (objectApiName == 'CC_Llamada__c') {
			return [SELECT CC_No_Identificado__c, CC_Fecha_Fin__c FROM CC_Llamada__c WHERE Id = :recordId];
		} else if (objectApiName == 'Opportunity') {
			return [SELECT AccountId, CSBD_Contact__c FROM Opportunity WHERE Id = :recordId];
		} else {
			return [SELECT CC_No_Identificado__c, AccountId, ContactId, RecordType.DeveloperName, CC_Representante__c, Contact.RecordType.DeveloperName FROM Case WHERE Id = :recordId];
		}
	}
}