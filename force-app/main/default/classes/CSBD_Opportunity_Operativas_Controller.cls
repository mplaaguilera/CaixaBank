public with sharing class CSBD_Opportunity_Operativas_Controller {

	@AuraEnabled(cacheable=true)
	public static Map<String, Boolean> checkPSResponsable() {
		return new Map<String, Boolean>{
			'esResponsable' => FeatureManagement.checkPermission('CSBD_Responsable'),
			'esAdministrador' => ![SELECT Id FROM GroupMember
									WHERE UserOrGroupId = :UserInfo.getUserId() AND Group.Name = 'CSBD Administrador'
									LIMIT 1].isEmpty()
		};
	}

	@AuraEnabled(cacheable=true)
	public static Boolean checkCDP(Id opportunityId) {
		return [SELECT RecordType.DeveloperName FROM Opportunity WHERE Id = :opportunityId].RecordType.DeveloperName == 'CSBD_PROAutomatica';
	}

	@AuraEnabled
	public static Boolean actualizarOwnerOportunidad(Id idOpportunity, Id ownerId) {
		List<CSBD_Gestor_Oportunidad__c> gestor = [SELECT OwnerId FROM CSBD_Gestor_Oportunidad__c
													WHERE CSBD_Oportunidad__c = :idOpportunity AND CSBD_Estado__c = 'Activo'
													AND Owner.Type = 'User' AND OwnerId != :ownerId LIMIT 1];
		if (!gestor.isEmpty()) {
			CSBD_Opportunity.actualizarPropietarioOportunidadOmnichannel(new Map<Id, Id>{idOpportunity => gestor[0].OwnerId});
			return true;
		}
		return false;
	}

	@AuraEnabled(cacheable=true)
	public static List<Folder> subdirectorios(String rutaDevName) {
		//Devuelve la lista de carpetas dentro de la carpeta indicada
		List<Folder> retorno = new List<Folder>();
		List<Folder> directorios = [SELECT Id FROM Folder WHERE DeveloperName = :rutaDevName];
		if (!directorios.isEmpty()) {
			for (Folder directorio : [SELECT Name, DeveloperName FROM Folder WHERE TYPE = 'EmailTemplate' AND ParentId = :directorios[0].Id]) {
				retorno.add(directorio);
			}
		}
		return retorno;
	}

	@AuraEnabled(cacheable=true)
	public static List<EmailTemplate> plantillas(String rutaDevName) {
		//Devuelve la lista de plantillas dentro de la carpeta indicada
		List<EmailTemplate> retorno = new List<EmailTemplate>();

		List<Folder> directorios = [SELECT Id FROM Folder WHERE DeveloperName = :rutaDevName];
		if (!directorios.isEmpty()) {
			for (EmailTemplate plantilla : [SELECT Name, DeveloperName FROM EmailTemplate WHERE FolderId = :directorios[0].Id]) {
				retorno.add(plantilla);
			}
		}
		return retorno;
	}

	@AuraEnabled(cacheable=true)
	public static String plantillaCuerpo(String developerName, Boolean convertirATextoPlano, Id sObjectId) {
		//Devuelve el cuerpo de la plantilla indicada
		String cuerpo = [SELECT HtmlValue FROM EmailTemplate WHERE developerName = :developerName].HtmlValue;

		//Si se ha indicado que se devuelva en texto plano se quitan los tags HTML
		if (convertirATextoPlano) {
			cuerpo = cuerpo.stripHtmlTags();
		}
		//Convertir campos parametrizados del template
		Id whoId = UserInfo.getUserId();
		Id whatId = sObjectId;
		List<String> emailTemplateBody = new List<String>{cuerpo};
		List<Messaging.RenderEmailTemplateBodyResult> renderedEmailTemplateLista = Messaging.renderEmailTemplate(whoId, whatId, emailTemplateBody);
		if(!renderedEmailTemplateLista.isEmpty()) cuerpo = renderedEmailTemplateLista[0].getMergedBody();

		return cuerpo;
	}

	@AuraEnabled
	public static EmailTemplate prepararOportunidadParaEnvioCorreo(Id idOpportunity, String developerNamePlantilla, Boolean informarReferenciaCorreo, Boolean pendienteCliente) {
		try {
			return CSBD_Opportunity.prepararOportunidadParaEnvioCorreo(idOpportunity, developerNamePlantilla, informarReferenciaCorreo, pendienteCliente);
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled(cacheable=true)
	public static Map<String, String> numeroOportunidadesAnteriores(Id idAccount, String recordTypeDevName) {
		try {
			Map<String, String> retorno = new Map<String, String>();
			//Título
			retorno.put('titulo', pluralRecordTypeName(recordTypeDevName) + ' recientes');
			//Mensaje
			String mensaje = 'Solicitados en los últimos 365 días: ' + [SELECT Count() FROM Opportunity WHERE AccountId = :idAccount
																			AND RecordType.DeveloperName = :recordTypeDevName AND CloseDate = LAST_N_DAYS:365];
			mensaje += '\nDenegados últimos 365 días: ' + [SELECT Count() FROM Opportunity WHERE AccountId = :idAccount
																AND RecordType.DeveloperName = :recordTypeDevName AND CloseDate = LAST_N_DAYS:365 AND StageName = 'Perdida'];
			mensaje += '\nDenegados últimos 30 días: ' + [SELECT Count() FROM Opportunity WHERE AccountId = :idAccount
																AND RecordType.DeveloperName = :recordTypeDevName AND CloseDate = LAST_N_DAYS:30 AND StageName = 'Perdida'];
			retorno.put('mensaje', mensaje);
			return retorno;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@TestVisible
	private static String pluralRecordTypeName(String recordTypeDevName) {
		switch on recordTypeDevName {
			//El plurar es el mimso que el singular
			when 'CSBD_CMN', 'CSBD_CMB', 'CSBD_Compra_Estrella', 'CSBD_TPV' {
				return CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('Opportunity', recordTypeDevName);
			}
			when 'CSBD_Accion_Comercial' {
				return 'Acciones comerciales';
			}
			//Por defecto el plural es el singular + 's'
			when else {
				return CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('Opportunity', recordTypeDevName) + 's';
			}
		}
	}

	@AuraEnabled
	public static Opportunity cerrarOportunidad(Id recordId, String nombreEtapaVentas, String resolucion) {
		try {
			return CSBD_Opportunity.cerrarOportunidad(recordId, nombreEtapaVentas, resolucion);
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static Opportunity cerrarOportunidad(Id recordId, String nombreEtapaVentas, String resolucion, Map<String, Object> campos) {
		try {
			return CSBD_Opportunity.cerrarOportunidad(recordId, nombreEtapaVentas, resolucion, campos);
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static Opportunity cerrarOportunidad(Id recordId, String nombreEtapaVentas, String resolucion, String campos) {
		try {
			Map<String, Object> camposMap = (Map<String, Object>) JSON.deserializeUntyped(campos);
			return cerrarOportunidad(recordId,  nombreEtapaVentas,  resolucion, camposMap);
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static Opportunity reactivarOportunidad(Id recordId, String nombreEtapaVentas) {
		try {
			return CSBD_Opportunity.reactivarOportunidad(recordId, nombreEtapaVentas);
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	/*
	@AuraEnabled(cacheable=true)
	public static List<OT_Picklist> etapasProcesoVentas(Id recordId, String nombreEtapaVentas) {
		List<OT_Picklist> etapas = new List<OT_Picklist>();
		return etapas;
	}
	*/

	@AuraEnabled
	public static String enviarNotificacinPushSMS(Id sObjectId, String destinatario, String texto) {
		try {
			return CC_Push_SMS.enviarNotificacionPush(sObjectId, destinatario, texto);
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static Event agendarFirmaApex(Id recordId, Boolean tipoFirma, Datetime startDateTime) {
		try {
			return CSBD_Opportunity.agendarFirma(recordId, tipoFirma, startDateTime);
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static Event cancelarFirmaApex(Id recordId) {
		try {
			return CSBD_Opportunity.cancelarFirma(recordId);
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}


	@AuraEnabled
	public static Event programarCita(Id recordId, Boolean asignacionAuto, Boolean comprobarContacto, Id idPropietario, Datetime startDateTime) {
		try {
			return CSBD_Opportunity.programarCita(recordId, asignacionAuto, comprobarContacto, idPropietario, startDateTime);
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static Event desprogramarCita(Id recordId) {
		try {
			return CSBD_Opportunity.finalizarCita(recordId, 'Cancelado', 'Desprogramado por el propietario de la oportunidad', true);
		} catch (Exception error) {
			throw new AuraHandledException(error.getMessage());
		}
	}

	@AuraEnabled
	public static void solicitarAltaOmnichannel(Id idOportunidad) {
		try {
			CSBD_GestorOportunidad.activarGestorOportunidad(idOportunidad);
		} catch (Exception error) {
			throw new AuraHandledException(error.getMessage());
		}
	}

	@AuraEnabled
	public static void solicitarBajaOmnichannel(Id idOportunidad) {
		try {
			CSBD_GestorOportunidad.desactivarGestorOportunidad(idOportunidad);
		} catch (Exception error) { throw new AuraHandledException(error.getMessage());
		}
	}

	@AuraEnabled
	public static void actualizarDatosRiesgoContacto(Id idOportunidad) {
		try {
			Opportunity oportunidad = [SELECT CSBD_Contact__c, CSBD_Now_Presolicitud__c FROM Opportunity WHERE Id = :idOportunidad];
			CSBD_SIR.actualizarDatosRiesgoCliente(oportunidad.CSBD_Contact__c, oportunidad);
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static Opportunity duplicarOportunidad(Opportunity oportunidad, String recordTypeDeveloperName, String empresa) {
		try {
			Opportunity oportunidadDestino = CSBD_Opportunity.duplicarOportunidad(oportunidad, recordTypeDeveloperName, empresa);
			return oportunidadDestino;
		} catch (Exception e) { throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled(cacheable=true)
	public static List<Map<String, String>> recordTypesOportunidadCSBD() {
		List<Map<String, String>> recordTypes = new List<Map<String, String>>();
		for (RecordType recordType: [SELECT DeveloperName, Name FROM RecordType
										WHERE SobjectType = 'Opportunity' AND DeveloperName LIKE 'CSBD_%']) {
			Map<String, String> rt = new Map<String, String>();
			rt.put('Name', recordType.Name);
			rt.put('DeveloperName', recordType.DeveloperName);
			recordTypes.add(rt);
		}
		return recordTypes;
	}

	/*
	@AuraEnabled(cacheable=true)
	public static List<OT_Picklist.Item> getMotivosPendienteInterno() {
		return OT_Picklist.picklistCampo('Opportunity', 'CSBD_Motivo_Pendiente_Interno__c');
	}

	@AuraEnabled(cacheable=true)
	public static Boolean comprobarPublicGroup() {
		return ![SELECT Id FROM GroupMember WHERE UserOrGroupId = :UserInfo.getUserId() AND Group.Name = 'CSBD Administrador' LIMIT 1].isEmpty();
	}
	*/

	@AuraEnabled
	public static void trasladoImaginBank(Id idOportunidad, String nombreEtapaVentas, String resolucion) {
		CSBD_Opportunity.cerrarOportunidad(idOportunidad, nombreEtapaVentas, resolucion);
	}

	@AuraEnabled(cacheable=true)
	public static Boolean obtenerOportunidadesHijas(Id idOportunidad){
		return CSBD_ProductoOportunidadHija.obtenerOportunidadesHijasAbiertas(idOportunidad);
	}

	@AuraEnabled
	public static Datetime ampliarVencimiento(id idOportunidad, Datetime fechaVencimiento) {
		Opportunity oportunidad = new Opportunity(Id = idOportunidad);
		oportunidad.CSBD_Fecha_vencimiento_alta__c = fechaVencimiento.addMonths(1);
		oportunidad.CloseDate = oportunidad.CSBD_Fecha_vencimiento_alta__c.date();
		update oportunidad;
		return oportunidad.CSBD_Fecha_vencimiento_alta__c;
	}

	@AuraEnabled(cacheable=true)
	public static List<String> obtenerResoluciones(String producto, String nombreRecordType, String etapa) {
		return CSBD_Utils.listaCampo([SELECT CC_Lista__r.Name FROM CC_Lista_Valores__c WHERE RecordType.Name = 'Valor' AND Name = :producto
										AND CC_Lista__r.CSBD_Tipo_de_oportunidad__c INCLUDES (:nombreRecordType)
										AND CC_Lista__r.CSBD_Etapa_Resolucion__c INCLUDES (:etapa) ORDER BY CC_Lista__r.Name], 'CC_Lista__r.Name');
	}

	@AuraEnabled(cacheable=true)
	public static List<String> obtenerEntidades() {
		return CSBD_Utils.listaCampo([SELECT Name FROM CC_Lista_Valores__c WHERE RecordType.Name = 'Valor'
										AND CC_Lista__r.Name = 'CSBD: Entidades competencia' ORDER BY Name], 'Name');
	}

    @AuraEnabled
    public static Opportunity crearTareaGestor(String recordId, String numeroGestor, String idGestor, String comentarios) {

		List<Opportunity> oportunidad = [SELECT ContactId, AccountId, AV_PF__c, Account.AV_EAPGestor__r.Account.CC_Numero_Oficina__c, AV_Comentarios__c, Account.AV_OficinaPrincipal__r.CC_Numero_Oficina__c, Account.AV_OfficeManager__r.CC_Numero_Oficina__c
										FROM Opportunity WHERE Id = :recordId];

		List<User> gestorCliente = new List<User>();
		List<Contact> contactoGestor = new List<Contact>();

		if (String.isNotBlank(numeroGestor) && String.isNotBlank(idGestor)) {
			if (!numeroGestor.startsWith('U01')) {
				numeroGestor = 'U01' + numeroGestor;
			}
			gestorCliente = [SELECT Id FROM User WHERE AV_ExternalID__c = :numeroGestor LIMIT 1];
		} else{
			gestorCliente = [SELECT Id FROM User WHERE AV_ExternalID__c = '000000' LIMIT 1];

			contactoGestor = [SELECT Id, CC_Matricula__c FROM Contact WHERE CC_Matricula__c = '000000' LIMIT 1];

			if(!contactoGestor.isEmpty()){
				idGestor = contactoGestor[0].Id;
			}
		}

		String centro = CSBD_MetodosComunes.buscarCentro(oportunidad[0], numeroGestor);

		Opportunity opp = new Opportunity();
		opp.recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('AV_AlertaComercial').getRecordTypeId();
		opp.AV_Center__c = centro;
		opp.AV_ExternalID__c = recordId;
		opp.AV_FechaAlta__c = Date.today();
		opp.AV_FechaFinAccionComercial__c = Date.today().addDays(30);
		opp.AV_Gestor__c = idGestor;
		opp.AV_OrigenApp__c = 'AV_NowIn';
		opp.AV_Potencial__c = 'A' ;
		opp.CloseDate = Date.today().addDays(30);
		opp.Name = 'Rema Gestor - CSBD';
		opp.AccountId = oportunidad[0].AccountId;

		if(!gestorCliente.isEmpty()){
			opp.OwnerId = gestorCliente[0].Id;
		}

		opp.StageName = 'Potencial';
		opp.AV_PF__c = oportunidad[0].AV_PF__c;
		opp.AV_Comentarios__c = comentarios;

		insert opp;
		return opp;
	}

	/*
	@AuraEnabled
	public static void crearTareaGestor(String recordId, String numeroGestor, String idGestor, String comentarios) {
		Opportunity opp	= [SELECT Account.AV_EAPGestor__r.Account.CC_Numero_Oficina__c,
							Account.AV_OficinaPrincipal__r.CC_Numero_Oficina__c, AV_PF__c,
							AccountId FROM Opportunity WHERE Id = :recordId];

		String gestor = String.isNotBlank(numeroGestor) && String.isNotBlank(idGestor) ? ('U01' + numeroGestor.removeStart('U01')) : '000000';

		Opportunity oppTareaGestor = new Opportunity();
		oppTareaGestor.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('AV_AlertaComercial').getRecordTypeId();
		oppTareaGestor.OwnerId = [SELECT Id FROM User WHERE AV_ExternalID__c = :gestor LIMIT 1]?.Id ?? null;
		oppTareaGestor.AV_Center__c = opp.Account.AV_EAPGestor__r.Account.CC_Numero_Oficina__c ?? opp.Account.AV_OficinaPrincipal__r.CC_Numero_Oficina__c;
		oppTareaGestor.AV_ExternalID__c = recordId;
		oppTareaGestor.AV_FechaAlta__c = Date.today();
		oppTareaGestor.AV_FechaFinAccionComercial__c = Date.today().addDays(30);
		oppTareaGestor.AV_Gestor__c = idGestor;
		oppTareaGestor.AV_OrigenApp__c = 'AV_NowIn';
		oppTareaGestor.AV_Potencial__c = 'A' ;
		oppTareaGestor.CloseDate = Date.today().addDays(30);
		oppTareaGestor.Name = 'Rema Gestor - CSBD';
		oppTareaGestor.AccountId = opp.AccountId;
		oppTareaGestor.StageName = 'Potencial';
		oppTareaGestor.AV_PF__c = opp.AV_PF__c;
		oppTareaGestor.AV_Comentarios__c = comentarios;
		insert oppTareaGestor;
	}
	*/

	@AuraEnabled
	public static Opportunity convertirOportunidad(Opportunity oportunidad, String recordTypeDeveloperName) {
		try {
			return CSBD_Opportunity.convertirOportunidad(oportunidad, recordTypeDeveloperName);
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}
}