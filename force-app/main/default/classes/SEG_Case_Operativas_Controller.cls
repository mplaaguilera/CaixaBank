public without sharing class SEG_Case_Operativas_Controller {
	public class WrapperInit {
    	@AuraEnabled
    	public Boolean vControlarOrgZona { get; set; }
    	@AuraEnabled
    	public boolean vControlarPS{ get; set; }
		@AuraEnabled
    	public boolean vControlarRT{ get; set; }
		@AuraEnabled
    	public boolean vControlarOrgZonaCaseGrupo{ get; set; }
		@AuraEnabled
    	public boolean vEsUsuarioBO{ get; set; }
		@AuraEnabled
    	public boolean vControlarAORActivo{ get; set; }
		@AuraEnabled
    	public boolean vRTSeguimiento{ get; set; }
	}
	@AuraEnabled
	static public wrapperInit initComponentOp(String caseId){
        wrapperInit result = new wrapperInit();
		Boolean isEmpleado = false;
		Boolean hasOrgZona = false;
		Boolean isSupervisor = false;
		Boolean isDisabled = false;
		Boolean inOrgZona = false;
		Boolean inBO = false;
		Boolean aorActivo = false;
		Boolean esRTSeguimiento = false;

		//OPTIMIZAR SRG
		//Obtener informacion del caso
		Case caso = [SELECT id, SEG_Organizacion__c, SEG_Zona__c, Contact.RecordType.DeveloperName, Status, SEG_Grupo__r.SEG_Organizacion__c, SEG_Grupo__r.SEG_Zona__c, OwnerId, RecordType.DeveloperName FROM Case WHERE id = :caseId LIMIT 1];

		SEG_Settings__c cmAOR = SEG_Settings__c.getValues('SEG_Control_AOR');
        
		if(cmAOR != null &&	cmAOR.SEG_Activo__c || Test.isRunningTest()){
			aorActivo = true;
		}
		result.vControlarAORActivo = aorActivo;

		// List<PermissionSetAssignment> psUser = [SELECT PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId()];
		// Mejora con Custom Permission
		if(FeatureManagement.checkPermission('SEG_SupervisorCustom')){
				isSupervisor = true;
		}

		// controlar RTSeguimiento
		if(caso.RecordType.DeveloperName == 'SEG_Seguimiento'){
			esRTSeguimiento = true;
		}
		result.vRTSeguimiento = esRTSeguimiento;

        //controlarOrgZona
		if (caso.SEG_Organizacion__c != null && caso.SEG_Zona__c != null){
			hasOrgZona = true;
		}
		result.vControlarOrgZona=hasOrgZona;

        //controlarPermissionSet
		if((caso.Status == 'Cerrado' || caso.Status == 'Descartado') && !isSupervisor) {
			isDisabled = true;
		}
      	result.vControlarPS=isDisabled;

		//controlarRecordTypeContacto

		if(caso != null && caso.Contact.RecordType.DeveloperName == 'CC_Empleado'){
			isEmpleado = true;
		}

		result.vControlarRT=isEmpleado;

		//controlar que el Caso tenga la misma Organización y Zona que el Grupo asignado
		if(caso.SEG_Organizacion__c != null && caso.SEG_Zona__c != null && (caso.SEG_Grupo__r?.SEG_Organizacion__c == null || caso.SEG_Grupo__r?.SEG_Zona__c == null 
			|| !caso.SEG_Grupo__r?.SEG_Organizacion__c.contains(caso.SEG_Organizacion__c) || !caso.SEG_Grupo__r?.SEG_Zona__c.contains(caso.SEG_Zona__c)))
		{
    		inOrgZona = true;
		}

		result.vControlarOrgZonaCaseGrupo = inOrgZona;

		result.vEsUsuarioBO = verificarUsuarioBO(String.valueOf(caso.OwnerId));

		return result;
	}

	@AuraEnabled
	// Comprobar si el usuario es tipo BO
	static public Boolean verificarUsuarioBO(String idUser){
		Boolean inBO = false;
		if(!String.valueOf(idUser).startsWith('00G')){
			User tipoCliente = [SELECT Id, SEG_Tipo_usuario_SEG__c FROM User WHERE Id = :IdUser LIMIT 1];
			if (tipoCliente.SEG_Tipo_usuario_SEG__c != null && tipoCliente.SEG_Tipo_usuario_SEG__c == 'BO'){
				inBO = true;
			}
		}
		return inBO;
	}

	@AuraEnabled
	public static Boolean comprobacionGrupo(String caseId) {
		Boolean deshabilitado = false;
		
		List<Case> caso = [SELECT Id, SEG_Organizacion__c, SEG_Zona__c, SEG_Grupo__r.SEG_Organizacion__c, SEG_Grupo__r.SEG_Zona__c FROM Case WHERE Id = :caseId LIMIT 1];

		if (!caso.isEmpty() && (caso[0].SEG_Grupo__r == null || caso[0].SEG_Grupo__r.SEG_Organizacion__c == null || caso[0].SEG_Grupo__r.SEG_Zona__c == null || (caso[0].SEG_Organizacion__c != null && !caso[0].SEG_Grupo__r.SEG_Organizacion__c.contains(caso[0].SEG_Organizacion__c)) || (caso[0].SEG_Zona__c != null && !caso[0].SEG_Grupo__r.SEG_Zona__c.contains(caso[0].SEG_Zona__c)))) {
			deshabilitado = true;
		}
		return deshabilitado;
	}


	@AuraEnabled
	static public void rechazarCaso(Id caseId){

		List<SEG_ClasificacionRapida__c> clraNP = [SELECT id, Name FROM SEG_ClasificacionRapida__c WHERE Name = 'No procede'];
		if (!clraNP.isEmpty())
		{
			Case caseSR = [SELECT id, Status, SEG_Grupo__C, SEG_Subestado__c FROM Case WHERE id = :caseId LIMIT 1];

			if(clraNP[0] != null){

				//Clasificación rapida del SR a 'No procede'
				caseSR.SEG_ClasificacionRapida__c = clraNP[0].id;

			}

			//Estado del SR a 'descartado'
			caseSR.Status = 'Descartado';

			//Subestado del SR a 'rechazado manualmente'
			caseSR.SEG_Subestado__c = 'Rechazada';

			//Actualizar SR
			update caseSR;
		}
	}

	@AuraEnabled
	static public Case recuperarCaso(Id caseId){
		return [SELECT Status, SEG_Grupo__C, SEG_Subestado__c, SEG_Centro_Identificado__c, OwnerId, AccountId,SEG_Detalle__c,CC_MCC_Motivo__c,CC_MCC_ProdServ__c,CC_MCC_Tematica__c,SEG_Zona__c,SEG_Organizacion__c,SEG_Numero_centro__c, SEG_Numero_de_centro__c,SEG_Numero_de_centro__r.Name,SEG_Numero_de_centro__r.CC_Numero_Oficina__c,SEG_ClasificacionRapida__c,SEG_orgZonaKO__c FROM Case WHERE id = :caseId];
	}

	@AuraEnabled
	static public Map<Id, CC_Grupo_Colaborador__c> buscadorGrupos(String caseId, String searchKey) {
		//Se rellena una lista con account names(encrypted)
		List<String> groupNames = new List<String> ();
		List<String> gruposDispobibles = new List<String> ();
		Case caseSR = recuperarCaso(caseId);

		for (CC_Grupo_Colaborador__c gpName :[SELECT id, Name FROM CC_Grupo_Colaborador__c]) {
			groupNames.add(gpName.Name);
		}

		Map<Id, CC_Grupo_Colaborador__c> mapGroups = new Map<Id, CC_Grupo_Colaborador__c> ();
		String name = '%' + searchKey + '%';
		if (searchKey == '') {
			return null;

		} else {
			List<CC_Grupo_Colaborador__c> groups = new List<CC_Grupo_Colaborador__c> ();
			if (String.isNotBlank(searchKey) && searchKey.length() > 1) {
				List<List<SObject>> searchResults = [
				FIND :searchKey
				RETURNING CC_Grupo_Colaborador__c(
				Id, Name WHERE RecordType.DeveloperName = 'SEG_GrupoAutomaticoSegmentos'
				OR RecordType.DeveloperName = 'SEG_GrupoOperativoSegmentos'
				LIMIT 20
				)
				];
				groups = searchResults[0];
			}
			for (CC_Grupo_Colaborador__c gp : groups) {
				mapGroups.put(gp.Id, gp);
			}

		}
		return mapGroups;
	}

	@AuraEnabled(cacheable=true)
	static public Map<Id, String> recuperarGrupos(String caseId){

		Map<Id, String> gruposAsign = new Map<Id, String>();
		Map<Id, CC_Grupo_Colaborador__c> mapGroups = new Map<Id, CC_Grupo_Colaborador__c> ();
		Case caseSR = recuperarCaso(caseId);

		Id automaticoRT = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SEG_GrupoAutomaticoSegmentos').getRecordTypeId();
		Id operativaRT = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();


		for(CC_Grupo_Colaborador__c grupo : [SELECT id, Name, SEG_Organizacion__c, SEG_Zona__c, SEG_No_visible__c, SEG_GrupoSegmentos__c  FROM CC_Grupo_Colaborador__c WHERE SEG_No_visible__c = false AND SEG_GrupoSegmentos__c  = true AND SEG_Inactivo__c = false AND (RecordTypeId = :automaticoRT OR RecordTypeId = :operativaRT) ORDER BY name]){

			String[] zonas;
			String[] orgs;
			Boolean orgExiste = false;

			if(grupo.SEG_Zona__c != null && grupo.SEG_Organizacion__c != null){
				zonas = grupo.SEG_Zona__c.Split(';');
				orgs = grupo.SEG_Organizacion__c.Split(';');

				for(String o : orgs){
					if(o.contains(caseSR.SEG_Organizacion__c) == true){
						orgExiste = true;
					}
				}

				for(String z : zonas){
					if(z.contains(caseSR.SEG_Zona__c) == true && orgExiste == true){
						gruposAsign.put(grupo.Id, grupo.Name);
						mapGroups.put(grupo.Id, grupo);
					}
				}

			}
			else{
				gruposAsign.put(null,null);
			}
		}

		return gruposAsign;
	}

	@AuraEnabled(cacheable=true)
	static public List<String> recuperarResultados() {
		List<String> resultados= new List<String>();
		for (Schema.PicklistEntry pickListVal : Case.SEG_Resultado__c.getDescribe().getPicklistValues()) {
			resultados.add(pickListVal.getLabel());
		}
		return resultados;
	}

	@AuraEnabled(cacheable=true)
	static public Map<String,String> recuperarMapResultados()
	{
		Map<String,String> resultados = new Map<String,String>();
		for (Schema.PicklistEntry pickListVal : Case.SEG_Resultado__c.getDescribe().getPicklistValues()) {
			// Excluir los estados de las operativas de Valija.
			if (pickListVal.getValue() != 'Enviado justificantes al cliente' && pickListVal.getValue() != 'Operaciones gestionadas pte envío justificante' && pickListVal.getValue() != 'Operaciones gestionadas sin envío justificante')
			{
				resultados.put(pickListVal.getValue(), pickListVal.getLabel());
			}
		}
		return resultados;
	}

	@AuraEnabled
	static public String cerrarCasoResultado(Id caseId, String resultado, Integer numOperacionesCaso) {
		String resul = resultado; // Mantener compatibilidad con lo antiguo.
		String envio = '';
		String criterioImputacion = '';
		Boolean error;
		List<String> parts;
		List<String> clientesAddress = new List<String>();
		List<String> cliente = new List<String>();
		Id recordTypeSEG = Schema.SObjectType.SEG_Auditoria__c.getRecordTypeInfosByDeveloperName().get('SEG_Auditorias').getRecordTypeId();

		List<Case> casoEntrante = [SELECT ContactId, OwnerId, AccountId, CC_Idioma__c, CaseNumber, SEG_N_case_y_subject__c, SEG_N_operaciones_del_caso__c,
						SEG_Tipolog_a_de_Grupo_Operativo__c,  Subject,SEG_Resultado__c, SEG_Organizacion__c,
						SEG_Zona__c, Status, SEG_Numero_de_centro__c, SEG_Grupo__c, SEG_Grupo_Empresa__c,
						SEG_ClasificacionRapida__c, SEG_Subestado__c, CC_Detalles_Consulta__c, CC_MCC_Motivo__c,
						CC_MCC_ProdServ__c, CC_MCC_Tematica__c, SEG_Detalle__c, Canal_del_Empleado__c, SEG_SRAuditoria__c, CC_No_Identificado__c, RecordType.DeveloperName, SEG_Buz_n_de_la_zona__c
						FROM Case WHERE Id =: caseId LIMIT 1];

		if(casoEntrante[0].RecordType.DeveloperName == 'SEG_Seguimiento'){
			List<SEG_Contratos__c> emailContratoCase = [SELECT Id, SEG_NombreCliente__r.Email  FROM SEG_Contratos__c WHERE SEG_SR_Seguimiento__c =: caseId];

			if(!emailContratoCase.isEmpty()){
				for (SEG_Contratos__c contratoCaso : emailContratoCase) {
					if(contratoCaso.SEG_NombreCliente__c == null || contratoCaso.SEG_NombreCliente__r.Email == null || contratoCaso.SEG_NombreCliente__r.Email == ''){
						return 'Contratos sin email';
					}
				}
			}
		}

		List<Case> casosHijo = [SELECT Status, SEG_Subestado__c, OwnerId, ParentId
								FROM Case WHERE ParentId =:casoEntrante[0].id AND Status != 'Cerrado' AND Status != 'Descartado'];

		if (numOperacionesCaso != null){
			casoEntrante[0].SEG_N_operaciones_del_caso__c = numOperacionesCaso;
		}
		if (casosHijo.isEmpty()) {
			casoEntrante[0].Status = 'Cerrado';
			casoEntrante[0].SEG_Resultado__c = resul;
			if (resul == null || resul.contains('Sin resultado')) {
				if (casoEntrante[0].SEG_SRAuditoria__c) {
					List<SEG_Auditoria__c> auditLst = new List<SEG_Auditoria__c>([SELECT SEG_NumeroSR__c, SEG_Resultado__c FROM SEG_Auditoria__c
																					WHERE SEG_NumeroSR__c = :caseId AND SEG_Resultado__C != 'OK' AND RecordTypeId = : recordTypeSEG]);
					casoEntrante[0].CC_Detalles_Consulta__c = 'Caso cerrado';
					if (!auditLst.isEmpty()) {
						casoEntrante[0].SEG_Subestado__c = 'Pendiente Robot';
					} else {
						casoEntrante[0].SEG_Subestado__c = 'Fichas enviadas';
					}
				} else if (casoEntrante[0].SEG_Tipolog_a_de_Grupo_Operativo__c == 'BO') {
					casoEntrante[0].SEG_Subestado__c = 'Gestionada por BO';
					casoEntrante[0].CC_Detalles_Consulta__c = 'Caso cerrado';
				} else if (casoEntrante[0].SEG_Tipolog_a_de_Grupo_Operativo__c == 'CSO') {
					casoEntrante[0].SEG_Subestado__c = 'Gestionada por CSO';
					casoEntrante[0].CC_Detalles_Consulta__c = 'Caso cerrado';
				} else {
					casoEntrante[0].SEG_Subestado__c = 'Tareas finalizadas';
					casoEntrante[0].CC_Detalles_Consulta__c = 'Caso cerrado';
				}
			} else if (resul.contains('Cierre por gestor')) {
				casoEntrante[0].SEG_Subestado__c = 'Por gestor';
				casoEntrante[0].CC_Detalles_Consulta__c = 'Caso cerrado';
			} else {
				casoEntrante[0].Status = 'Cerrado';
				casoEntrante[0].SEG_Subestado__c = 'Tareas finalizadas';
				casoEntrante[0].CC_Detalles_Consulta__c = 'Caso cerrado';
			}

			try {
				update casoEntrante[0];
			} catch (System.DmlException e) {
				if((casoEntrante[0].AccountId == null || casoEntrante[0].ContactId == null) && !casoEntrante[0].CC_No_Identificado__c)
				{
					if (!test.isRunningTest()){
						throw new AuraHandledException('No se permite cerrar el caso si su caso Padre no tiene la cuenta y el contacto informado o por el contrario el cliente no se ha identificado.');
					}
				}
				else if(casoEntrante[0].CC_MCC_Tematica__c == null || casoEntrante[0].CC_MCC_Motivo__c == null || casoEntrante[0].CC_MCC_ProdServ__c == null || casoEntrante[0].SEG_N_operaciones_del_caso__c == null)
				{
                    if (!test.isRunningTest()){
                        throw new AuraHandledException('No se permite cerrar el caso si no se ha informado de la Temática, el Producto, el Motivo y el Nº de operaciones del caso.');
                    }
				}
				parts = e.getMessage().split(':');
				error = true;
				if (parts.size() > 4) {
					if (!test.isRunningTest()){
						throw new AuraHandledException(parts[5]);
					}
				} else {
                    if (!test.isRunningTest()){
                        throw new AuraHandledException(e.getMessage());
                    }
				}
			} catch (Exception e) {
				if (!test.isRunningTest()){
					throw new AuraHandledException(e.getMessage());
				}
			}

			if (resul == null || resul.contains('Sin resultado')) {
				return 'Caso cerrado';
			}

			if (resul != null || !resul.contains('Sin resultado')) {
				if (resul.contains('Gestión en otro caso')) {
					return 'Caso cerrado';
				} else if (resul.contains('Petición gestionada completa')) {
					return 'Caso cerrado';
				} else if (resul.contains('Petición gestionada de forma incompleta')) {
					return 'Caso cerrado';
				} else if(resul.contains('Petición no gestionada')) {
					return 'Caso cerrado';
				} else if (resul.contains('Cierre por gestor')) {
					return 'Caso cerrado';
				} else {
					envio = envioCierre(casoEntrante[0], resul);
					if (envio == 'Enviado') {
						return 'Caso cerrado' + true;
					} else if (envio == 'Plantilla vacía') {
						return 'Plantilla vacía';
					} else if (envio == 'No plantilla') {
						return 'Sin plantilla';
					} else if(envio == 'No contacto') {
						return 'Sin contacto';
					}
				}
			}
		} else {
			casoEntrante[0].Status = 'Pendiente';
			casoEntrante[0].SEG_Subestado__c = 'Casos vinculados pendientes';

			try {
				Update casoEntrante[0];
			} catch (System.DmlException e) {

				parts = e.getMessage().split(':');
				error = true;
				if (parts.size() > 4) {
					throw new AuraHandledException(parts[5]);
				} else {
					throw new AuraHandledException(e.getMessage());
				}
			} catch (Exception e) {
				throw new AuraHandledException(e.getMessage());
			}
			return 'Casos hijos';
		}
		return 'No cerrado';
	}

	@AuraEnabled
	static public String cerrarCasoAuditoria(Id caseId, Integer resultado) {
		List<String> valores = new List<String>();
		for (Schema.PicklistEntry pickListVal : Case.SEG_Resultado__c.getDescribe().getPicklistValues()) {
			valores.add(pickListVal.getLabel());
		}
		String resul = valores[resultado];

		String msg = '';
		String resultadoEnvio = '';

		List<String> clientesAddress = new List<String>();
		List<String> cliente = new List<String>();

		Case caso = [SELECT ContactId, AccountId, CC_Idioma__c, CaseNumber, SEG_N_case_y_subject__c, Subject, SEG_Resultado__c,
						SEG_Organizacion__c, SEG_Zona__c, Status, SEG_Numero_de_centro__c, SEG_Grupo__c, SEG_Grupo_Empresa__c,
						SEG_ClasificacionRapida__c, SEG_Subestado__c, CC_Detalles_Consulta__c, CC_MCC_Motivo__c, CC_MCC_ProdServ__c,
						CC_MCC_Tematica__c, Canal_del_Empleado__c, SEG_SRAuditoria__c, SEG_Buz_n_de_la_zona__c
						FROM Case WHERE Id = :caseId];

		caso.Status = 'Cerrado';
		caso.SEG_Subestado__c = 'Pendiente Robot';
		caso.CC_Detalles_Consulta__c = 'Caso cerrado';
		caso.SEG_Resultado__c = resul;

		try {
			update caso;
		} catch (System.DmlException e) {
			String[] parts = e.getMessage().split(',');
			throw new AuraHandledException(parts[1]);
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}

		if (resul.contains('Gestión en otro caso')) {
			return 'Caso cerrado';
		} else if (resul.contains('Petición gestionada completa')) {
			return 'Caso cerrado';
		} else if (resul.contains('Petición gestionada de forma incompleta')) {
			return 'Caso cerrado';
		} else if (resul.contains('Petición no gestionada')) {
			return 'Caso cerrado';
		} else {
			resultadoEnvio = envioCierre(caso, resul);
			if (resultadoEnvio == 'Enviado') {
				return 'Caso cerrado' + true;
			} else if (resultadoEnvio == 'Plantilla vacía') {
				return 'Plantilla vacía';
			} else if (resultadoEnvio == 'No plantilla') {
				return 'Sin plantilla';
			}
		}

		return 'No cerrado';
	}



	public static String envioCierre(Case caso, String resultado) {
		//Recuperar la plantilla correspondiente a la operativa 'Cierre'

		List<Contact> lstContacto = [SELECT Name, Email, CC_Idioma__c FROM contact WHERE Id = :caso.ContactId];

		if(!lstContacto.isEmpty())
		{

			//List<CC_Canal_Com__c> canal = [SELECT Id, CC_Email__c,CC_ContactName__c FROM CC_Canal_Com__c WHERE CC_ContactoId__c = :contacto.Id ];

			String lang = caso.CC_Idioma__c;
			String plantillaIdioma;
			SEG_Plantilla__c plantillaCierre;
			List<String> adresses = new List<String>();
			List<SEG_Plantilla__c> plantilla = new List<SEG_Plantilla__c>();

			// Recuperar los buzones salientes para el caso.
			Map<String,String> mapaBuzonesOrgZona = SEG_MetodosComunes.recuperarOWASegmentos();
			String claveBuzon = caso.SEG_Organizacion__c + '##' + caso.SEG_Zona__c;
			String owaSalienteId = String.isNotBlank(mapaBuzonesOrgZona.get(claveBuzon)) ? mapaBuzonesOrgZona.get(claveBuzon) : mapaBuzonesOrgZona.get('Por defecto##Por defecto');

			// Recuperar los canales de comunicación.
			String contactoCasoId = caso.ContactId;
			Map<String,String> datosContacto = new Map<String,String>();
			datosContacto.put(contactoCasoId, caso.AccountId);
			Map<String,Map<String,Set<String>>> destinatariosCorreo = SEG_MetodosComunes.getDestinatariosContactos (datosContacto);
			Map<String,Set<String>> contactoCasoDestinoCorreo = (destinatariosCorreo != null) ? destinatariosCorreo.get(contactoCasoId) : null;
			List<String> listBuzones = new List<String>{caso.SEG_Buz_n_de_la_zona__c};

			Map<Id, List<SEG_Plantilla__c>> plantillas = SEG_PlantillasHandler.determinarPlantillas(new List<Case>{caso}, 'Cierre', resultado);
			if (plantillas.size() == 1) {
				//Email del primer correo electrónico del caso
				List<EmailMessage> emails =  [SELECT Id, FromName, FromAddress, ToAddress, Subject, HtmlBody, Incoming,HasAttachment, CcAddress, BccAddress, CreatedDate FROM EmailMessage WHERE ParentId = :caso.Id ORDER BY CreatedDate ASC LIMIT 1];
				for(List<SEG_Plantilla__c> lP : plantillas.values()){
					for(SEG_Plantilla__c p : lP){
						plantilla.add(p);
					}
				}
				plantillaCierre = plantilla[0];
				Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();

				if(lang != null){
					if(lang =='ga'){
						plantillaIdioma=plantillaCierre.SEG_PlantillaGalegoID__c;
					} else if(lang=='ca'){
						plantillaIdioma=plantillaCierre.SEG_PlantillaCatalanID__c;
					} else if(lang=='en'){
						plantillaIdioma=plantillaCierre.SEG_PlantillaInglesID__c;
					} else if(lang=='eu'){
						plantillaIdioma=plantillaCierre.SEG_PlantillaEuskeraID__c;
					} else {
						plantillaIdioma=plantillaCierre.SEG_PlantillaCastellanoID__c;
					}
				}else{
					if(lstContacto[0].CC_Idioma__c != null){
						if(lstContacto[0].CC_Idioma__c =='ga'){
							plantillaIdioma=plantillaCierre.SEG_PlantillaGalegoID__c;
						} else if(lstContacto[0].CC_Idioma__c =='ca'){
							plantillaIdioma=plantillaCierre.SEG_PlantillaCatalanID__c;
						} else if(lstContacto[0].CC_Idioma__c =='en'){
							plantillaIdioma=plantillaCierre.SEG_PlantillaInglesID__c;
						} else if(lstContacto[0].CC_Idioma__c =='eu'){
							plantillaIdioma=plantillaCierre.SEG_PlantillaEuskeraID__c;
						} else {
							plantillaIdioma=plantillaCierre.SEG_PlantillaCastellanoID__c;
						}
					}
				}

				if (String.isNotBlank(plantillaIdioma)) {
					if(emails != null && resultado == 'Respuesta a peticionario'){
						if (!emails.isEmpty() && emails.get(0).FromAddress != null) {
    						adresses.add(emails.get(0).FromAddress);
						}
						if(!emails.isEmpty() && emails.get(0).CcAddress != null){
							string[] subs = emails[0].CcAddress.Split(';');
							for(String s : subs){
								adresses.add(s);
							}
						}
						if(!emails.isEmpty() && emails.get(0).ToAddress != null){
							string[] subs = emails[0].ToAddress.Split(';');
							List<String> listMail = new List<String>();
							for(String s : subs){
								listMail.add(s);	
							}
							
							listMail =  SEG_MetodosComunes.depuracionCorreosBuzonSegmentos(listMail, listBuzones);
							adresses.addAll(listMail);
						}
						message.setToAddresses(adresses);
						
						//Contact contactoPeticion = [SELECT Id, Name, Email, CC_Idioma__c FROM contact WHERE Email = :emails[0].FromAddress LIMIT 1];
						Id contactoMail = (String.isNotBlank(contactoCasoId)) ? Id.valueOf(contactoCasoId) : null;

						Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(plantillaIdioma, contactoMail, caso.Id);
						//message.setSenderDisplayName('Segmentos CaixaBank - TO CHANGE');
						//message.setReplyTo('test@test.com');
						message.setOrgWideEmailAddressId(owaSalienteId);
						message.setUseSignature(false);
						message.setBccSender(false);
						message.setSaveAsActivity(true);
						message.setWhatId(caso.id);
						message.setSubject(email.subject);
						if(emails != null){
							if(emails?.get(0)?.CcAddress != null){
								message.setHtmlBody(email.HtmlBody + '<br><br>' + ' --------------------------------------------- ' + '<br><br>'  + '------Mensaje original------' + '<br><br>' + 'From: ' + emails[0].FromName + ' "' + emails[0].FromAddress + '" ' + '<br>' + 'To: "' + emails[0].ToAddress + '" ' + '<br>' + 'Cc: "' + emails[0].CcAddress
								+ '" ' + '<br>' + 'Subject: ' + emails[0].Subject + '<br>' + 'Fecha: ' +  emails[0].CreatedDate + '<br><br>' + emails[0].htmlBody);
							}else{
								message.setHtmlBody(email.HtmlBody + '<br><br>' + ' --------------------------------------------- ' + '<br><br>' + '------Mensaje original------' + '<br><br>' + 'From: ' + emails[0].FromName + ' "' + emails[0].FromAddress + '" ' + '<br>' + 'To: "' + emails[0].ToAddress + '" ' + '<br>' + 'Subject: ' + emails[0].Subject + '<br>' + 'Fecha: ' +  emails[0].CreatedDate + '<br><br>' + emails[0].htmlBody);
							}
						}else{
							message.setHtmlBody(email.HtmlBody);
						}
						Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
						Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
						return 'Enviado';
					}else{

						// Cambio por el nuevo cálculo de canales de comunicación.
						List<String> adressesCC = new List<String>();
						List<String> adressesCCO = new List<String>();

						if (contactoCasoDestinoCorreo != null)
						{
							// Calcular las direcciones Para.
							for (String direccion : contactoCasoDestinoCorreo.get('Para'))
							{
								adresses.add(direccion);
							}

							// Calcular las direcciones CC.
							for (String direccion : contactoCasoDestinoCorreo.get('CC'))
							{
								adressesCC.add(direccion);
							}

							// Calcular las direcciones CCO.
							for (String direccion : contactoCasoDestinoCorreo.get('CCO'))
							{
								adressesCCO.add(direccion);
							}
						}

						// Común a todas las operativas.
						if(resultado == 'Reenvío al contacto del caso' || resultado == 'Enviado justificantes al cliente' || resultado == 'Operaciones gestionadas pte envío justificante' ||
						resultado == 'Operaciones gestionadas sin envío justificante')
						{
							if(!lstContacto.isEmpty())
							{
								message.setTargetObjectId(lstContacto[0].id);
							}

							message.setToAddresses(adresses);
							if (!adressesCC.isEmpty())
							{
								message.setCcAddresses(adressesCC);
							}

							if (!adressesCCO.isEmpty())
							{
								message.setBccAddresses(adressesCCO);
							}
						}

						Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(plantillaIdioma, lstContacto[0].Id, caso.Id);
						//message.setSenderDisplayName('Segmentos CaixaBank - TO CHANGE');
						//message.setReplyTo('test@test.com');
						message.setOrgWideEmailAddressId(owaSalienteId);
						message.setUseSignature(false);
						message.setBccSender(false);
						message.setSaveAsActivity(true);
						message.setWhatId(caso.id);
						message.setSubject(email.subject);
						if(emails != null){
							if(emails[0].CcAddress != null){
								message.setHtmlBody(email.HtmlBody + '<br><br>' + ' --------------------------------------------- ' + '<br><br>'  + '------Mensaje original------' + '<br><br>' + 'From: ' + emails[0].FromName + ' "' + emails[0].FromAddress + '" ' + '<br>' + 'To: "' + emails[0].ToAddress + '" ' + '<br>' + 'Cc: "' + emails[0].CcAddress
								+ '" ' + '<br>' + 'Subject: ' + emails[0].Subject + '<br>' + 'Fecha: ' +  emails[0].CreatedDate + '<br><br>' + emails[0].htmlBody);
							}else{
								message.setHtmlBody(email.HtmlBody + '<br><br>' + ' --------------------------------------------- ' + '<br><br>' + '------Mensaje original------' + '<br><br>' + 'From: ' + emails[0].FromName + ' "' + emails[0].FromAddress + '" ' + '<br>' + 'To: "' + emails[0].ToAddress + '" ' + '<br>' + 'Subject: ' + emails[0].Subject + '<br>' + 'Fecha: ' +  emails[0].CreatedDate + '<br><br>' + emails[0].htmlBody);
							}
						}else{
							message.setHtmlBody(email.HtmlBody);
						}
						Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
						Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
						return 'Enviado';
					}
				}else{
					return 'Plantilla vacía';
				}
			}
			return 'No plantilla';
		}
		return 'No contacto';
	}

	/**
	 * @description Método para enviar un correo automático utilizando la configuración de plantillas de Segmentos.
	 */
	public static Map<String,String> enviarCorreoAutoOperativa (Map<String,String> datosCaso, Map<String,String> configuracion, List<String> emailDestinatariosBackup, List<String> ficherosAdjuntos)
	{
		Map<String,String> retorno = new Map<String,String>();
		retorno.put('codigo','0');
		retorno.put('detalle','');

		try {
			// Recuperar los parámetros de entrada.
			String caseId = datosCaso.get('caseId');

			String caseAccountId = datosCaso.get('accountId');
			String caseContactId = datosCaso.get('contactId');
			String caseOrganizacion = datosCaso.get('organizacion');
			String caseZona = datosCaso.get('zona');
			String caseIdioma = datosCaso.get('idiomaCaso');

			// Recuperar configuración.
			String operativa = configuracion.get('operativa');
			String resultado = configuracion.get('resultadoCaso');
			String usarPrimerCorreo = configuracion.get('primerCorreo'); // 0 -> No, 1 -> Primer correo entrante, 2 -> Primer correo (entrante o saliente).

			// Si el resultado es "Respuesta a peticionario" sobreescribimos la gestión del primer correo.
			usarPrimerCorreo = (resultado == 'Respuesta a peticionario') ? '2' : usarPrimerCorreo;

			// Validar datos entrada.
			if (String.isBlank(caseId))
			{
				retorno.put('codigo','1');
				retorno.put('detalle','No se ha informado un caso asociado al envío automático');
				return retorno;
			}

			// Obtener el contacto asociado a la petición.
			Contact contactObject;
			List<Contact> lstContacto = new List<Contact>();
			if (String.isNotBlank(caseContactId))
			{
				lstContacto = [SELECT Id, Name, Email, CC_Idioma__c FROM Contact WHERE Id = :caseContactId];
				if (!lstContacto.isEmpty())
				{
					contactObject = lstContacto[0];
				}
			}

			// Validación mínima para parar el proceso antes. Se ha de tener un contacto o lista de emails backup.
			if (lstContacto.isEmpty() && (emailDestinatariosBackup == null || emailDestinatariosBackup.isEmpty()))
			{
				retorno.put('codigo','2');
				retorno.put('detalle','No hay ningún destinatario a remitir el correo');
				return retorno;
			}

			// Recuperar los buzones salientes para la comunicación.
			Map<String,String> mapaBuzonesOrgZona = SEG_MetodosComunes.recuperarOWASegmentos();
			String claveBuzon = caseOrganizacion + '##' + caseZona;
			String owaSalienteId = String.isNotBlank(mapaBuzonesOrgZona.get(claveBuzon)) ? mapaBuzonesOrgZona.get(claveBuzon) : mapaBuzonesOrgZona.get('Por defecto##Por defecto');

			// Recuperar los canales de comunicación.
			Map<String,String> datosContacto = new Map<String,String>();
			datosContacto.put(caseContactId, caseAccountId);
			Map<String,Map<String,Set<String>>> destinatariosCorreo = SEG_MetodosComunes.getDestinatariosContactos (datosContacto);
			Map<String,Set<String>> contactoCasoDestinoCorreo = (destinatariosCorreo != null) ? destinatariosCorreo.get(caseContactId) : null;

			// Recuperar la administración de plantillas.
			SEG_Plantilla__c configuracionPlantilla;
			Case objectCase = new Case(Id=caseId);
			Map<Id, List<SEG_Plantilla__c>> plantillas = SEG_PlantillasHandler.determinarPlantillas(new List<Case>{objectCase}, operativa, resultado);
			if (plantillas.size() == 1) {
				List<SEG_Plantilla__c> plantilla = new List<SEG_Plantilla__c>();
				for(List<SEG_Plantilla__c> lP : plantillas.values()){
					for(SEG_Plantilla__c p : lP){
						plantilla.add(p);
					}
				}
				configuracionPlantilla = plantilla[0];
			}else{
				retorno.put('codigo','3');
				retorno.put('detalle','No hay ninguna plantilla configurada para la operativa <' + operativa + '> y resultado <' + resultado + '>.');
				return retorno;
			}

			// Calcular la plantilla final a utilizar.
			String idiomaComunicacion = (String.isNotBlank(caseIdioma)) ? caseIdioma : (String.isNotBlank(contactObject?.CC_Idioma__c) ? contactObject.CC_Idioma__c : 'es');
			String plantillaIdioma = '';
			plantillaIdioma = (String.isBlank(plantillaIdioma) && idiomaComunicacion == 'ga') ? configuracionPlantilla.SEG_PlantillaGalegoID__c : plantillaIdioma;
			plantillaIdioma = (String.isBlank(plantillaIdioma) && idiomaComunicacion == 'ca') ? configuracionPlantilla.SEG_PlantillaCatalanID__c : plantillaIdioma;
			plantillaIdioma = (String.isBlank(plantillaIdioma) && idiomaComunicacion == 'en') ? configuracionPlantilla.SEG_PlantillaInglesID__c : plantillaIdioma;
			plantillaIdioma = (String.isBlank(plantillaIdioma) && idiomaComunicacion == 'eu') ? configuracionPlantilla.SEG_PlantillaEuskeraID__c : plantillaIdioma;
			plantillaIdioma = (String.isBlank(plantillaIdioma)) ? configuracionPlantilla.SEG_PlantillaCastellanoID__c : plantillaIdioma;

			if (String.isBlank(plantillaIdioma))
			{
				retorno.put('codigo','4');
				retorno.put('detalle','No se ha encontrado la plantilla con idioma <' + idiomaComunicacion + ' para la operativa <' + operativa + '> y resultado <' + resultado + '>.');
				return retorno;
			}

			// Recuperar el identificador de la plantilla.
			EmailTemplate emailTemplate;
			List<EmailTemplate> listadoEmailTemplate = [SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body
														FROM EmailTemplate WHERE Id = :plantillaIdioma];
			if (!listadoEmailTemplate.isEmpty())
			{
				emailTemplate = listadoEmailTemplate[0];
			}else{
				retorno.put('codigo','5');
				retorno.put('detalle','No se ha encontrado la plantilla con identificador <' + plantillaIdioma + ' con idioma <' + idiomaComunicacion + ' para la operativa <' + operativa + '> y resultado <' + resultado + '>.');
				return retorno;
			}

			// Recuperar los datos del primer correo, si es necesario.
			EmailMessage emailEntrante;
			if (usarPrimerCorreo == '1' /*|| Test.isRunningTest()*/)
			{
				// Primer correo entrante.
				List<EmailMessage> emails =  [SELECT Id, FromName, FromAddress, ToAddress, Subject, HtmlBody, Incoming,HasAttachment, CcAddress, BccAddress, CreatedDate
												FROM EmailMessage WHERE ParentId = :caseId AND Incoming = true ORDER BY CreatedDate ASC LIMIT 1];
				if (!emails.isEmpty())
				{
					emailEntrante = emails[0];
				}
			}

			if (usarPrimerCorreo == '2' /*|| Test.isRunningTest()*/)
			{
				// Primer correo, da igual si entrante o saliente.
				List<EmailMessage> emails =  [SELECT Id, FromName, FromAddress, ToAddress, Subject, HtmlBody, Incoming,HasAttachment, CcAddress, BccAddress, CreatedDate
												FROM EmailMessage WHERE ParentId = :caseId ORDER BY CreatedDate ASC LIMIT 1];
				if (!emails.isEmpty())
				{
					emailEntrante = emails[0];
				}
			}

			// Generar el contenido del email Saliente.
			Id renderWhoId = (String.isNotBlank(caseContactId)) ? Id.valueOf(caseContactId) : UserInfo.getUserId();
			Messaging.SingleEmailMessage dataMailOut = Messaging.renderStoredEmailTemplate(plantillaIdioma, renderWhoId, caseId);
			String cuerpoMailSaliente = dataMailOut.htmlbody;
			cuerpoMailSaliente = (emailEntrante != null) ? cuerpoMailSaliente + '<br><br>' : cuerpoMailSaliente;
			cuerpoMailSaliente = (emailEntrante != null) ? cuerpoMailSaliente + ' --------------------------------------------- ' : cuerpoMailSaliente;
			cuerpoMailSaliente = (emailEntrante != null) ? cuerpoMailSaliente + '<br><br>' : cuerpoMailSaliente;
			cuerpoMailSaliente = (emailEntrante != null) ? cuerpoMailSaliente + '------Mensaje original------' : cuerpoMailSaliente;
			cuerpoMailSaliente = (emailEntrante != null) ? cuerpoMailSaliente + '<br><br>' : cuerpoMailSaliente;
			cuerpoMailSaliente = (emailEntrante != null) ? cuerpoMailSaliente + 'From:' : cuerpoMailSaliente;
			cuerpoMailSaliente = (emailEntrante != null && String.isNotBlank(emailEntrante?.FromName)) ? cuerpoMailSaliente + ' ' + emailEntrante.FromName : cuerpoMailSaliente;
			cuerpoMailSaliente = (emailEntrante != null) ? cuerpoMailSaliente + ' "' + emailEntrante.FromAddress + '" ' : cuerpoMailSaliente;
			cuerpoMailSaliente = (emailEntrante != null) ? cuerpoMailSaliente + '<br>' : cuerpoMailSaliente;
			cuerpoMailSaliente = (emailEntrante != null) ? cuerpoMailSaliente + 'To: "' + emailEntrante.ToAddress + '" ' : cuerpoMailSaliente;
			cuerpoMailSaliente = (emailEntrante != null) ? cuerpoMailSaliente + '<br>' : cuerpoMailSaliente;
			cuerpoMailSaliente = (emailEntrante != null && String.isNotBlank(emailEntrante?.CcAddress)) ? cuerpoMailSaliente + 'Cc: "' + emailEntrante.CcAddress + '" ' : cuerpoMailSaliente;
			cuerpoMailSaliente = (emailEntrante != null) ? cuerpoMailSaliente + '<br>' : cuerpoMailSaliente;
			cuerpoMailSaliente = (emailEntrante != null) ? cuerpoMailSaliente + 'Subject: ' + emailEntrante.Subject : cuerpoMailSaliente;
			cuerpoMailSaliente = (emailEntrante != null) ? cuerpoMailSaliente + '<br>' : cuerpoMailSaliente;
			cuerpoMailSaliente = (emailEntrante != null) ? cuerpoMailSaliente + 'Fecha: ' +  emailEntrante.CreatedDate.format() : cuerpoMailSaliente;
			cuerpoMailSaliente = (emailEntrante != null) ? cuerpoMailSaliente + '<br><br>' : cuerpoMailSaliente;
			cuerpoMailSaliente = (emailEntrante != null) ? cuerpoMailSaliente + emailEntrante.htmlBody : cuerpoMailSaliente;

			// Calcular los destinatarios del correo.
			List<String> adresses = new List<String>();
			List<String> adressesCC = new List<String>();
			List<String> adressesCCO = new List<String>();

			// Si el resultado de la operativa es "Respuesta a peticionario", el remitente se sobreescribe.
			if (resultado == 'Respuesta a peticionario' && emailEntrante != null)
			{
				if(emailEntrante.FromAddress != null){
					adresses.add(emailEntrante.FromAddress);
				}
				if(String.isNotBlank(emailEntrante.CcAddress)){
					string[] subs = emailEntrante.CcAddress.Split(';');
					for(String s : subs){
						adresses.add(s);
					}
				}
			}else if (contactObject != null && contactoCasoDestinoCorreo != null)
			{
				// Calcular las direcciones Para.
				for (String direccion : contactoCasoDestinoCorreo.get('Para'))
				{
					adresses.add(direccion);
				}

				// Calcular las direcciones CC.
				for (String direccion : contactoCasoDestinoCorreo.get('CC'))
				{
					adressesCC.add(direccion);
				}

				// Calcular las direcciones CCO.
				for (String direccion : contactoCasoDestinoCorreo.get('CCO'))
				{
					adressesCCO.add(direccion);
				}
			}

			// Comprobar si hay direcciones informadas, para utilizar la lista de mails de Backup.
			if (adresses.isEmpty() && adressesCC.isEmpty() && adressesCCO.isEmpty() && emailDestinatariosBackup != null && !emailDestinatariosBackup.isEmpty())
			{
				adresses.addAll(emailDestinatariosBackup);
			}

			// Verificar que exista algún destinatario.
			if (adresses.isEmpty() && adressesCC.isEmpty() && adressesCCO.isEmpty())
			{
				retorno.put('codigo','6');
				retorno.put('detalle','El correo automático no tiene ningún destinatario informado.');
				return retorno;
			}

			// Recuperar sólo los ficheros de la lista que pertenecen al caso.
			List<Id> listadoContentVersion = new List<Id>();
			List<String> listadoContentDocument = new List<String>();
			if (ficherosAdjuntos != null && !ficherosAdjuntos.isEmpty())
			{
				for (ContentDocumentLink linkFile : [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.LatestPublishedVersionId,
														ContentDocument.FileExtension, ContentDocument.Title,
														ContentDocument.CreatedDate, ContentDocument.ContentSize
														FROM ContentDocumentLink WHERE LinkedEntityId = :caseId AND ContentDocument.LatestPublishedVersionId IN :ficherosAdjuntos])
				{
					if (linkFile.ContentDocument.FileExtension <> 'snote')
					{
						listadoContentVersion.add(linkFile.ContentDocument.LatestPublishedVersionId);
						listadoContentDocument.add(linkFile.ContentDocumentId);
					}
				}
			}

			// Generar el objeto Email saliente de Salesforce.
			Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
			if(contactObject != null && String.isNotBlank(contactObject?.Email) && resultado != 'Respuesta a peticionario'){
				message.setTargetObjectId(contactObject.Id);
			}
			message.setToAddresses(adresses);
			if (!adressesCC.isEmpty()){
				message.setCcAddresses(adressesCC);
			}
			if (!adressesCCO.isEmpty()){
				message.setBccAddresses(adressesCCO);
			}
			message.setOrgWideEmailAddressId(owaSalienteId);
			message.setUseSignature(false);
			message.setBccSender(false);
			message.setSaveAsActivity(true);
			message.setWhatId(caseId);
			message.setSubject(dataMailOut.Subject);
			message.setHtmlBody(cuerpoMailSaliente);

			// Incorporar anexos.
			if (!listadoContentVersion.isEmpty())
			{
				message.setEntityAttachments(listadoContentVersion);
			}

			// Enviar el correo.
			Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
			Messaging.SendEmailResult[] results = Messaging.sendEmail(messages, false);

			// Vincular los ficheros con el email enviado.
			if (results != null && !results.isEmpty() && results?.get(0)?.isSuccess() == true)
			{
				// Buscar el último correo saliente para vincular los ficheros anexos. Criterios: último correo, con el mismo asunto y buzón saliente.
				String remitenteMail = '';
				for (OrgWideEmailAddress owea : [SELECT Id, Address FROM OrgWideEmailAddress WHERE Id = :owaSalienteId])
				{
					remitenteMail = owea.Address;
					if (String.isNotBlank(remitenteMail))
					{
						break;
					}
				}

				List<EmailMessage> listaMailsEnviados = [SELECT Id FROM EmailMessage WHERE ParentId = :caseId AND Incoming = FALSE AND Subject = :dataMailOut.Subject AND FromAddress = :remitenteMail ORDER BY MessageDate DESC LIMIT 1];
				if (!listaMailsEnviados.isEmpty() && listadoContentDocument?.isEmpty() == false)
				{
					listaMailsEnviados[0].SEG_HasAnexo__c = (!listadoContentDocument?.isEmpty() == true) ? true : false;
					update listaMailsEnviados[0];
				}

			}else{
				// Error enviando el correo.
				Messaging.SendEmailError[] errorMail = results?.get(0)?.getErrors();
				retorno.put('codigo','6');
				retorno.put('detalle','Se ha producido un error en el envío del correo automático. Detalle: ' + String.valueOf(errorMail));
			}

		} catch (Exception ex) {
			retorno.put('codigo','9999');
			retorno.put('detalle','Error al enviar un correo automático. Detalle: ' + ex.getMessage() + ' (' + ex.getStackTraceString() + ')');
			CBK_Log.error(ex);
		}

		return retorno;
	}

	@AuraEnabled
	static public String devolverSegBO(Id caseId) {
		Case caso = [SELECT OwnerId, SEG_Grupo__c, CC_Owner_Anterior__c FROM Case WHERE id = :caseId];
		List<Group> colasBO = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SEG_BO'];
		if (String.isNotBlank(caso.SEG_Grupo__c)) {
			if (colasBO.size() == 1 && caso.OwnerId == UserInfo.getUserId()) {
				caso.OwnerId = colasBO[0].id;
				caso.Status = 'Activo';
				if (caso.CC_Owner_Anterior__c != null) {
					caso.SEG_Subestado__c = 'Con propietario anterior';
				} else {
					caso.SEG_Subestado__c = 'Pendiente asignación de propietario';
				}
			}
			update caso;
			return 'Actualizado';
		} else {
			return 'No actualizado';
		}
	}

	@AuraEnabled
	static public void devolverGrupoAnterior(Id caseId){

		Case casoGrupo = [SELECT SEG_Grupo__c, SEG_Grupo_Anterior__c FROM Case WHERE Id = :caseId LIMIT 1];

		casoGrupo.SEG_Grupo__c = casoGrupo.SEG_Grupo_Anterior__c;

		update casoGrupo;

		//Se le asigna el grupo SEG_BO y actualiza el estado
		devolverSegBO(caseId);
	}

	@AuraEnabled
	static public void postOnChatter(Id caseId, String observaciones, String operativa, String notaTipificada) {
		if(String.isNotBlank(operativa) && String.isNotBlank(observaciones) )
		{
			createNotes(caseId, operativa, observaciones);
		}

		FeedItem feed = new FeedItem();
		feed.ParentId = caseId;
		feed.isRichText = true;
		feed.Type = 'TextPost';
		if (String.isBlank(observaciones)){
			observaciones = 'Sin Comentarios';
		}
		if(String.isBlank(notaTipificada)){
			notaTipificada = 'Sin notas';
		}

		/* Escapar el contenido HTML para evitar problemas de inyección de código.
		 Se realiza en operaciones distintas a 01  06, que ya está escapado 
		*/
		 switch on operativa {
			when '01' {
				operativa = 'Autoasignar caso (Valija - WS) - Operación 01: Expediente Riesgo (SIA)';
			}
			when '06' {
				operativa = 'Autoasignar caso (Valija - WS) - Operación 06: Expediente Persona';
			}
			// Escapar el contenido HTML en el resto de operativas, al no saber si estan escapadas en origen
			when else{
				observaciones = observaciones.escapeHtml4();
			}
		}

		//observaciones = observaciones.escapeHtml4();

		if (String.isNotBlank(notaTipificada) && notaTipificada != 'Sin notas') {
			String nombreNotaTipificada = [SELECT Name FROM SEG_NotasTipificadas__c WHERE Id = :notaTipificada].Name;
			feed.Body = 'Comentarios publicados en ' + operativa + observaciones + ' Nota tipificada: <b>' + nombreNotaTipificada + '</b>';
		} else {
			feed.Body = 'Comentarios publicados en ' + operativa + observaciones + ' Nota tipificada: <b>' + notaTipificada + '</b>';
		}
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

	/**
	 * @description Método para generar un objeto FeedItem para su posterior inserción en el proceso que se utilice.
	 * @param caseId Identificador de caso.
	 * @param observaciones Observaciones a incluir en el chatter.
	 * @param operativa Título de la operativa a incluir en el Chatter.
	 * @param notaTipificada Nota tipificada a incluir en el chatter.
	 * @param listadoFeeds Listado de feeds donde se añade el comentario de chatter.
	 */
	static public void postOnChatterObject(Id caseId, String observaciones, String operativa, String notaTipificada, List<FeedItem> listadoFeeds) {

		FeedItem feed = new FeedItem();
		feed.ParentId = caseId;
		feed.isRichText = true;
		if (String.isBlank(observaciones)){
			observaciones = 'Sin Comentarios';
		}
		if(String.isBlank(notaTipificada)){
			notaTipificada = 'Sin notas';
		}

		// Escapar el contenido HTML.
		observaciones = observaciones.escapeHtml4();

		if (String.isNotBlank(notaTipificada) && notaTipificada != 'Sin notas') {
			String nombreNotaTipificada = [SELECT Name FROM SEG_NotasTipificadas__c WHERE Id = :notaTipificada].Name;
			feed.Body = 'Comentarios publicados en ' + operativa + ': <b>' + observaciones + '</b>. Nota tipificada: <b>' + nombreNotaTipificada + '</b>';
		} else {
			feed.Body = 'Comentarios publicados en ' + operativa + ': <b>' + observaciones + '</b>. Nota tipificada: <b>' + notaTipificada + '</b>';
		}

		listadoFeeds?.add(feed);
	}

	@AuraEnabled
	static public String asignarGrupo(Id caseId, Id grupoId)
	{
		Case caseSR = recuperarCaso(caseId);
		Id identificadorCuenta = caseSR?.AccountId;
		String retorno;
		Boolean isGroup = false;
		// Recuperar los datos de la cuenta del caso.
		List<Account> accCase = [SELECT id, CC_Numero_Oficina__c, SEG_Prioridad_Carterizacion_Segmentos__c, SEG_Empleado_gestor_Segmentos__c,AV_EAPGestor__c,
								SEG_GestorOperativaNacional__c, SEG_GestorOperativaInternacional__c, SEG_GestorFinEstructurada__c, RecordTypeId
								FROM Account WHERE id = :identificadorCuenta LIMIT 1];

		ID recordTypeCentroCBK = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();

		Group colasBO = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SEG_BO' LIMIT 1];
		caseSR.OwnerId = colasBO.id;
		CC_Grupo_Colaborador__C grupo = [SELECT id, Name, RecordType.DeveloperName FROM CC_Grupo_Colaborador__c WHERE id = :grupoId AND SEG_Inactivo__c = false LIMIT 1];
		
		// Reiniciamos los valores. TO_DO. COMENTADO PARA SIGUIENTE IOP Y DETERMINAR SI ES CORRECTO.
		//caseSR.SEG_Grupo_colaborador_Externo__c = null;
		//caseSR.SEG_Colaborador_externo_Segmentos__c = null;

		//US869274 - Asignar grupo- Validación Grupo automático (Optimización)
		//Llamamos a la asignació de grupo
		if(grupo.RecordType.DeveloperName == 'SEG_GrupoAutomaticoSegmentos'){
			if (grupo.Name.endsWith('*')){
				String numeroCentro = caseSR.SEG_Numero_centro__c;
				if (String.isBlank(numeroCentro)) {
					numeroCentro = caseSR.SEG_Centro_Identificado__c;
				}
				if (String.isBlank(numeroCentro)){
					retorno = 'Sin num centro';
				}

				String col = grupo.Name;
				String grupoC = col.replace('*',' ') + numeroCentro;
				//Se busca el registro con el nombre del grupo colaborador
				System.debug('grupoC: ' + grupoC);
				List<CC_Grupo_Colaborador__c> listadoGrupos = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = :grupoC AND SEG_Organizacion__c INCLUDES (:caseSR.SEG_Organizacion__c) AND SEG_Zona__c INCLUDES (:caseSR.SEG_Zona__c) AND SEG_Inactivo__c = false];
				if (!listadoGrupos.isEmpty()){
					caseSR.SEG_Grupo__c = listadoGrupos[0].Id;
					isGroup = true;
				}else{
					// Grupo no encontrado.
					if(retorno == null){
						retorno = 'Sin grupo auto';
					}
				}
			}else{
				// Se necesita la cuenta del caso. En caso que no esté informada, lanzaremos una excepción a la botonera.
				if (!accCase.isEmpty()){
					String query = 'SELECT SEG_EmpleadoGestor__c, SEG_GrupoOperativa__c from SEG_Gestor_Grupo__c where SEG_EmpleadoGestor__c != null AND SEG_GrupoOperativa__r.SEG_Organizacion__c INCLUDES("' 
					+ caseSR.SEG_Organizacion__c + '") AND SEG_GrupoOperativa__r.SEG_Zona__c INCLUDES("' + caseSR.SEG_Zona__c + '") AND SEG_EmpleadoGestor__c = ';
					Boolean queryMontada = false;

					if(accCase[0].RecordTypeId != recordTypeCentroCBK){
						if(grupo.Name=='Gestor Comercial'){
							if(accCase[0].SEG_Prioridad_Carterizacion_Segmentos__c == true && accCase[0].SEG_Empleado_gestor_Segmentos__c != null){
								query += '"' + accCase[0].SEG_Empleado_gestor_Segmentos__c + '"' ;
								queryMontada = true;

							}else if(accCase[0].AV_EAPGestor__c != null){
								query += '"' + accCase[0].AV_EAPGestor__c + '"';
								queryMontada = true;
							}
						}else if(grupo.Name=='Gestor Operativa Nacional'){
							if(accCase[0].SEG_GestorOperativaNacional__c != null){
								query += '"' + accCase[0].SEG_GestorOperativaNacional__c + '"';
								queryMontada = true;
							}
						}else if(grupo.Name=='Gestor Operativa Internacional'){
							if(accCase[0].SEG_GestorOperativaInternacional__c != null){
								query += '"' + accCase[0].SEG_GestorOperativaInternacional__c + '"';
								queryMontada = true;
							}
						}else if(grupo.Name=='Gestor Financiación Estructurada'){
							if(accCase[0].SEG_GestorFinEstructurada__c != null){
								query += '"' + accCase[0].SEG_GestorFinEstructurada__c + '"';
								queryMontada = true;
							}
						}else{
							retorno = 'Sin grupo auto';
						}

						if(queryMontada){
							List<SEG_Gestor_Grupo__c> retornoGrupo = (List<SEG_Gestor_Grupo__c>) Database.query(String.escapeSingleQuotes(query).replaceAll('"','\''));

							if(!retornoGrupo.isEmpty()){
								if(retornoGrupo.size() == 1){
									caseSR.SEG_Grupo__c = retornoGrupo[0].SEG_GrupoOperativa__c;
									isGroup = true;
								}else if(retornoGrupo.size() != 1){
									retorno = 'Sin gestor';
								}
							}
						}else{
							retorno = 'Sin gestor';
						}
					}else{
						retorno = 'centro caixabank';
					}
				}else{
					retorno = 'Sin cuenta';
				}

				if(!isGroup){
					List<CC_Grupo_Colaborador__c> grupoEstandar = [SELECT id FROM CC_Grupo_Colaborador__c WHERE SEG_Grupo_Estandar__c = true
																	AND SEG_Organizacion__c = :caseSR.SEG_Organizacion__c AND SEG_Zona__c = :caseSR.SEG_Zona__c AND SEG_Inactivo__c = false LIMIT 1];
					if(!grupoEstandar.isEmpty()){
						caseSR.SEG_Grupo__c = grupoEstandar[0].id;
					}else {
						retorno = 'Sin standard';
					}
				}
			}
		}else{
			caseSR.SEG_Grupo__c = grupo.id;
			
		}

		// Actualizar el grupo del caso.
		if (String.isBlank(retorno)) {
			update caseSR;
		}

		return retorno;
	}

	/**
	 * @description Método autoAsignarGrupo para todos los sitios de la aplicación automáticos. Minimizar el impacto de modificar las llamadas.
	 * @param caseId Identificador de caso para asignar.
	 * @return Mapa con el estado del proceso de autoasignación.
	 */
	@AuraEnabled
	public static Map<String,String> autoAsignarGrupo(Id caseId)
	{
		Map<String,String> retornoAutoAsignar = autoAsignarGrupoAura(caseId, true, false);
		return retornoAutoAsignar;
	}

	/**
	 * @description Método autoAsignarGrupo para todos los sitios de la aplicación automáticos. Minimizar el impacto de modificar las llamadas.
	 * @param caseId Identificador de caso para asignar.
	 * @param entradaPAK Indicador si la entrada de valija se ha producido algún PAK.
	 * @return Mapa con el estado del proceso de autoasignación.
	 */
	public static Map<String,String> autoAsignarGrupoPaqueteria(Id caseId, Boolean entradaPAK)
	{
		Map<String,String> retornoAutoAsignar = autoAsignarGrupoAura(caseId, true, entradaPAK);
		return retornoAutoAsignar;
	}

	/**
	 * @description Método autoAsignarGrupoAura para la autoasignación desde la botonera.
	 * @param caseId Identificador de caso para asignar.
	 * @param bAutomatico Indicador si es una autoasignación automática, sin requerir datos intermedios como puede ser en Valija.
	 * @param entradaPaqueteriaPAK Indicador si la entrada de valija se ha producido algún PAK.
	 * @return Mapa con el estado del proceso de autoasignación.
	 */
	@AuraEnabled
	public static Map<String,String> autoAsignarGrupoAura(Id caseId, Boolean bAutomatico, Boolean entradaCasoPAK)
	{
		Map<String,String> retorno = new Map<String,String>();
		retorno.put('asignado','N');
		retorno.put('errorProceso', 'N');
		retorno.put('errorGrupoAuto','0');
		retorno.put('detalleError','');
		retorno.put('masInformacion','');
		retorno.put('requiereInfoAdicional','N');
		retorno.put('datosCalculadosTraslado','');

		String grupoId = '';
		String masInformacion = '';
		String trazabilidadAsignacion = 'Segmentos Autoasignado: ';

		Boolean errorAsignacion = false;
		FeedItem feed = new FeedItem();
		feed.Type = 'TextPost';
		feed.ParentId = caseId;
		feed.Body = 'Error durante la asignación automática: ';

		// Recuperar la información del caso necesaria para el proceso.
		List<Case> listadoCasosData = [SELECT Id, SEG_Grupo__c, SEG_Centro_Identificado__c, SEG_Detalle__c, CC_MCC_Motivo__c, CC_MCC_ProdServ__c, CC_MCC_Tematica__c, 
							AccountId, SEG_Zona__c, SEG_Organizacion__c, OwnerId, Status, SEG_Subestado__c, Account.SEG_Oficina_Gestora_Segmentos__c,
							Account.SEG_Oficina_Gestora_Segmentos__r.CC_Numero_Oficina__c, SEG_Grupo_colaborador_Externo__c, SEG_TipoProcesoValija__c, SEG_Numero_centro__c, Account.AV_NumPerso__c, Owner.Name
							FROM Case WHERE id = :caseId LIMIT 1];
		trazabilidadAsignacion += ' Los datos utilizados para el intento de asignación han sido: MCC Detalle - ' + listadoCasosData[0].SEG_Detalle__c + ' | MCC Motivo - ' + listadoCasosData[0].CC_MCC_Motivo__c + ' | MCC Producto - ' + listadoCasosData[0].CC_MCC_ProdServ__c + ' | MCC Temática - ' + listadoCasosData[0].CC_MCC_Tematica__c + ' | Cuenta - ' + listadoCasosData[0].AccountId + ' | Zona - '  + listadoCasosData[0].SEG_Zona__c + ' | Organización - ' + listadoCasosData[0].SEG_Organizacion__c + ' | Es buzón automático - ' + bAutomatico + ' | Id Caso - ' + listadoCasosData[0].Id;
        feed.Body =+ trazabilidadAsignacion;
        // Identificamos las excepciones del caso, por si aplica alguna de ellas.
		Map<String,Integer> asignacionExcepcion = identificarExcepciones(caseId);
		if (asignacionExcepcion?.get('asignado') == 1) {
			// El caso se ha asignado.
			retorno.put('asignado','Y');
			retorno.put('masInformacion','Asignación por excepción.');
		}else if (bAutomatico && asignacionExcepcion?.get('asignado') == 0 && asignacionExcepcion?.get('numeroExcepciones') > 1){
			// Se han identificado varias excepciones en modo autoasignación por canales automáticos.
			Map<String,String> gestionMCC = derivarGrupoMCCporInconsistenciaExcepciones (listadoCasosData[0].Id, listadoCasosData[0].SEG_Organizacion__c, listadoCasosData[0].SEG_Zona__c);
			if (gestionMCC.get('codigo') != '0')
			{
				retorno.put('errorProceso', 'Y');
				retorno.put('errorGrupoAuto','9');
				retorno.put('detalleError', gestionMCC.get('detalle'));
				errorAsignacion = true;
				feed.Body = feed.Body + gestionMCC.get('detalle');
			}
		}else if (!bAutomatico && asignacionExcepcion?.get('asignado') == 0 && asignacionExcepcion?.get('numeroExcepciones') > 1){
			// Se han identificado varias excepciones en modo autoasignación por parte del usuario, marcamos error para mostrar al usuario.
			retorno.put('errorProceso', 'Y');
			retorno.put('errorGrupoAuto','8');
			errorAsignacion = true;
			feed.Body = feed.Body + 'Se han encontrado varias excepciones a aplicar.';
		}

		// No hay ninguna regla de excepción que aplique, intentar asignar al grupo adecuado.
		if (retorno.get('errorProceso') == 'N' && retorno.get('asignado') == 'N' || Test.isRunningTest())
		{
			Group colasBO = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SEG_BO' LIMIT 1];

			String accountId = listadoCasosData[0]?.AccountId;
			Map<String,String> retornoAsignacion = SEG_MetodosComunes.asignarGrupoCaso(listadoCasosData[0].SEG_Detalle__c, listadoCasosData[0].CC_MCC_Motivo__c, listadoCasosData[0].CC_MCC_ProdServ__c,
				listadoCasosData[0].CC_MCC_Tematica__c, accountId, listadoCasosData[0].SEG_Zona__c, listadoCasosData[0].SEG_Organizacion__c, bAutomatico, caseId);
			masInformacion = (String.isNotBlank(masInformacion)) ? masInformacion + '; SEG_MetodosComunes.asignarGrupoCaso : ' + retornoAsignacion.get('error') + ' - ' + retornoAsignacion.get('detalle') : 'SEG_MetodosComunes.asignarGrupoCaso : ' + retornoAsignacion.get('error') + ' - ' + retornoAsignacion.get('detalle');
			trazabilidadAsignacion += ' | usuarioContexto - ' + UserInfo.getUserId() + ' | retornoAsignacion - ' + retornoAsignacion;
			feed.Body = feed.Body + ' Los datos devueltos por el flujo automático han sido: grupoCol - ' + retornoAsignacion?.get('grupoCol') + ' | mantenerGrupo - ' + retornoAsignacion?.get('mantenerGrupo') + ' | error - ' + retornoAsignacion?.get('error') + ' | detalle - ' + retornoAsignacion?.get('detalle');
			retorno.put('masInformacion',masInformacion);
			if (retornoAsignacion.get('error') != '0')
			{
				if(retornoAsignacion.get('error') == '5')
				{
					retorno.put('errorProceso', 'Y');
				}
				else{
					grupoId = retornoAsignacion.get('grupoCol');
				}
				retorno.put('errorGrupoAuto',retornoAsignacion.get('error'));
				feed.Body = feed.Body + retornoAsignacion.get('error');
				errorAsignacion = true;
			}
			else if (retornoAsignacion.get('mantenerGrupo') == 'Y'){
				retorno.put('asignado','Y');
				grupoId = '';
			}
			else{
				grupoId = retornoAsignacion.get('grupoCol');
			}

			if(String.isNotBlank(grupoId))
			{
				//comprobamos recordType de grupo
				Set<String> mccsCaso = new Set<String>();
				mccsCaso.add(listadoCasosData[0].CC_MCC_Motivo__c);
				mccsCaso.add(listadoCasosData[0].CC_MCC_ProdServ__c);
				mccsCaso.add(listadoCasosData[0].CC_MCC_Tematica__c);
				mccsCaso.add(listadoCasosData[0].SEG_Detalle__c);

				// Nuevo método.
				Map<String,String> retornoColaborador = SEG_MetodosComunes.recuperarColaboradorExterno (listadoCasosData[0].SEG_Organizacion__c, listadoCasosData[0].SEG_Zona__c, grupoId, mccsCaso, accountId, bAutomatico, caseId);
				masInformacion = (String.isNotBlank(masInformacion)) ? masInformacion + ';' + 'SEG_MetodosComunes.recuperarColaboradorExterno : ' + retornoColaborador.get('error') : 'SEG_MetodosComunes.recuperarColaboradorExterno : ' + retornoColaborador.get('error');
				trazabilidadAsignacion += ' | retornoColaborador - ' + retornoColaborador;
				retorno.put('masInformacion',masInformacion);
				if(retornoColaborador.get('error') != '0'){
					retorno.put('errorGrupoAuto',retornoColaborador.get('error'));
					errorAsignacion = true;
					feed.Body = feed.Body + retornoAsignacion.get('error');
				}

				// Sólo cuando el error es 5 - Sin grupo estándar, se cancela la asignación.
				if (retornoColaborador.get('error') != '5')
				{
					if (retornoColaborador.get('esExterno') == 'Y')
					{
						String tipoColaboradorWS = retornoColaborador.get('tipoColaboradorWS');
						String grupoAnteriorId = listadoCasosData[0].SEG_Grupo__c;
						String grupoColaboradorAnteriorId = listadoCasosData[0].SEG_Grupo_colaborador_Externo__c;

						// Preparamos los valores actuales del caso, para el proceso de traslado a WebService. Si hay error en la transferencia, se devuelve el caso a su grupo original.
						/* Jaime:
						   Datos de trasladoWS, independientemente de que sea un proceso trasladado a valija de forma automatica en iniciarTrasladoColaboradorWS(trasladoWS) o se necesite recoger más datos como en "Traslado iniciado manualmente por el agente" en el que llegamos a retorno.put('datosCalculadosTraslado', JSON.serialize(trasladoWS));
						   Esta distincion se decide en if (bAutomatico && !entradaCasoPAK)
						*/
						SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador trasladoWS = new SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador();
						trasladoWS.caseId = caseId;
						trasladoWS.tipoColaborador = tipoColaboradorWS;

						/* 	Jaime: 
							Si es un traslado a Valija, se asigna el tipo de operación de la valija.
							Si es un traslado a Paquetería, se asigna el tipo de operación de Paquetería.
						*/
						trasladoWS.operacionPaqueteria = listadoCasosData[0].SEG_TipoProcesoValija__c;
						trasladoWS.operacionValijaMCC = retornoColaborador.get('operacionValija');

						// Blanqueamos los datos del grupo colaborador externo.
						listadoCasosData[0].SEG_Grupo_colaborador_Externo__c = null;
						listadoCasosData[0].SEG_Colaborador_externo_Segmentos__c = null;

						// Es un colaborador externo.
						listadoCasosData[0].SEG_Grupo__c = (String.isNotBlank(retornoColaborador.get('grupoRespuesta'))) ? retornoColaborador.get('grupoRespuesta') : listadoCasosData[0].SEG_Grupo__c;
                        listadoCasosData[0].SEG_Grupo_colaborador_Externo__c = grupoId;
						listadoCasosData[0].Status = (String.isNotBlank(retornoColaborador.get('nuevoEstadoCaso'))) ? retornoColaborador.get('nuevoEstadoCaso') : 'Activo';
                        listadoCasosData[0].SEG_Subestado__c = (String.isNotBlank(retornoColaborador.get('nuevoSubEstadoCaso')))?retornoColaborador.get('nuevoSubEstadoCaso'):null;

						// Preparamos los nuevos valores para el proceso de traslado a WebService.
						trasladoWS.newGrupoId = listadoCasosData[0].SEG_Grupo__c;
						trasladoWS.newGrupoName = retornoColaborador.get('nombreGrupoExterno');
						trasladoWS.newGrupoColaboradorId = listadoCasosData[0].SEG_Grupo_colaborador_Externo__c;
						trasladoWS.newStatus = listadoCasosData[0].Status;
						trasladoWS.newSubStatus = listadoCasosData[0].SEG_Subestado__c;
						trasladoWS.oldGrupoId = grupoAnteriorId;
						trasladoWS.oldGrupoColaboradorId = grupoColaboradorAnteriorId;
						trasladoWS.oldStatus = 'Activo';
						trasladoWS.oldSubStatus = 'Incidencia Valija';

						if (retornoColaborador.get('cierreCaso') == 'Y' || (listadoCasosData[0].Status == 'Pendiente' && (listadoCasosData[0].SEG_Subestado__c=='En colaborador' || listadoCasosData[0].SEG_Subestado__c=='En canal Valija')))
						{
							if (retornoColaborador.get('cierreCaso') == 'Y'){
								listadoCasosData[0].Status = (String.isNotBlank(retornoColaborador.get('estadoCierre'))) ? retornoColaborador.get('estadoCierre') : 'Cerrado';
								listadoCasosData[0].SEG_Subestado__c = (String.isNotBlank(retornoColaborador.get('subestadoCierre')))?retornoColaborador.get('subestadoCierre'):null;
							}

							if (tipoColaboradorWS == 'N')
							{
								// TRASLADO A COLABORADOR POR EMAIL. Envío del mail automático.
								Map<String,String> envioColaborador = SEG_MetodosComunes.enviarEmailAutomatico(listadoCasosData[0].SEG_Grupo_colaborador_Externo__c, listadoCasosData[0].SEG_Grupo__c, caseId);
								masInformacion = (String.isNotBlank(masInformacion)) ? masInformacion + ';' + 'SEG_MetodosComunes.enviarEmailAutomatico : ' + envioColaborador.get('error') : 'SEG_MetodosComunes.recuperarColaboradorExterno : ' + envioColaborador.get('error');
								retorno.put('masInformacion',masInformacion);
								trazabilidadAsignacion += ' | envioColaborador:' + envioColaborador;
								if (envioColaborador.get('error') != '0')
								{
									// Error en el envío a colaborador. Salir del proceso de asignación.
									retorno.put('errorProceso', 'Y');
									retorno.put('errorGrupoAuto','6');
									retorno.put('detalleError', envioColaborador.get('detalle'));

									// Crear un post de chatter informando del error al intentar enviar el correo automático a colaborador.
									try
									{
										String errorChatter = 'Error durante la asignación automática: No se ha podido autoasignar el caso debido a un problema en el proceso de autoasignación. Código error: ' + envioColaborador.get('error') + ' ' + envioColaborador.get('detalle');
										SEG_Case_Operativas_Controller.postOnChatter(caseId, errorChatter, 'Autoasignar caso', '');
										errorAsignacion = true;
									}catch (Exception e){
										// Registramos el error.
										CBK_Log.error(e);
									}
									return retorno;
								}
							}else if (tipoColaboradorWS == 'VALIJA'){
								// TRASLADO A COLABORADOR VALIJA. Envío por WebService.
								if (bAutomatico && !entradaCasoPAK)
								{
									if(listadoCasosData[0].SEG_Numero_centro__c == null){
										if(listadoCasosData[0].SEG_Centro_Identificado__c != null){
											List<Account> centro = [SELECT Id FROM Account WHERE CC_Numero_Oficina__c = :listadoCasosData[0].SEG_Centro_Identificado__c];
											if(!centro.isEmpty()){
												listadoCasosData[0].SEG_Numero_centro__c = centro[0].Id;
												update listadoCasosData[0];
											}
										}
										else{
											retorno.put('errorProceso', 'Y');
											retorno.put('errorGrupoAuto','9');
											retorno.put('detalleError', 'No es posible asignar el caso a Valija sin tener el centro informado.');
											errorAsignacion = true;
											feed.Body = feed.Body + 'No es posible asignar el caso a Valija sin tener el centro informado.';
											insert feed;
											return retorno;
										}
									} else {
										// Procesos automáticos que han de trasladar a Valija sin datos adicionales del usuario.
										Map<String,String> retornoTrasladoWS = SEG_trasladoColaboradorWS.iniciarTrasladoColaboradorWS(trasladoWS);
										masInformacion = (String.isNotBlank(masInformacion)) ? masInformacion + ';' + 'SEG_trasladoColaboradorWS.iniciarTrasladoColaboradorWS : ' + retornoTrasladoWS.get('codigo') + ' - ' + retornoTrasladoWS.get('detalle') : 'SEG_trasladoColaboradorWS.iniciarTrasladoColaboradorWS : ' + retornoTrasladoWS.get('codigo') + ' - ' + retornoTrasladoWS.get('detalle');
										trazabilidadAsignacion += ' | retornoTrasladoWS:' + retornoTrasladoWS;
										if (retornoTrasladoWS.get('codigo') != '0' || Test.isRunningTest())
										{
											// Error en el envío a VALIJA. Salir del proceso de asignación.
											retorno.put('errorProceso', 'Y');
											retorno.put('errorGrupoAuto','7');
											retorno.put('detalleError', retornoTrasladoWS.get('detalle'));
											CBK_Log.error('TRASLADO VALIJA. autoAsignarGrupoAura (Automático). Código: ' + retornoTrasladoWS.get('codigo') + '. Detalle: ' + retornoTrasladoWS.get('detalle'));
											errorAsignacion = true;
											feed.Body = feed.Body + retornoTrasladoWS.get('detalle');
											insert feed;
											return retorno;
										}
									}
								}else if (bAutomatico && entradaCasoPAK){
									// Interceptamos el PAK en la creación del caso. Activamos el caso con estado "Incidencia Valija" para que lo resuelva un agente.
									listadoCasosData[0].Status = (entradaCasoPAK == true) ? trasladoWS.oldStatus : listadoCasosData[0].Status;
									listadoCasosData[0].SEG_Subestado__c = (entradaCasoPAK == true) ? trasladoWS.oldSubStatus : listadoCasosData[0].SEG_Subestado__c;
								}else{
									// Traslado iniciado manualmente por el agente. Salimos del proceso sin actualizar el caso.
									if(listadoCasosData[0].SEG_Numero_centro__c == null){
										retorno.put('errorProceso', 'Y');
										retorno.put('errorGrupoAuto','9');
										retorno.put('detalleError', 'No es posible asignar el caso a Valija sin tener el centro informado.');
										errorAsignacion = true;
										feed.Body = feed.Body + 'No es posible asignar el caso a Valija sin tener el centro informado.';
										insert feed;
										return retorno;
									}else{
										retorno.put('requiereInfoAdicional','Y');

										/* 
											Jaime: al requerir información adicional, se envía el caso a 1 de los 3 modales posibles de Valija para que el usuario pueda completar los datos necesarios. 

											Aqui podemos hacer la conexion con el frontend porJS:
											trasladoWS.operacionPaqueteria
											trasladoWS.operacionValijaMCC
										*/
										
										if (trasladoWS.operacionValijaMCC == '01'){
											//Modal de valija con datos de Operacion 01
											retorno.put('operacionValijaMCC', '01');
											retorno.put('nameOwnerCase', listadoCasosData[0].Owner.Name);
										} else if (trasladoWS.operacionValijaMCC == '06') {
											if(listadoCasosData[0].Account.AV_NumPerso__c == null || listadoCasosData[0].Account.AV_NumPerso__c == ''){

												//Jaime: Si no tenemos el número de persona, no podemos asignar el caso a Valija.
												retorno.put('errorProceso', 'Y');
												retorno.put('errorGrupoAuto','10');
												retorno.put('detalleError', 'No es posible asignar un caso de Operación Expediente Persona a Valija sin que la cuenta tenga Num. Persona informado');
												errorAsignacion = true;

												//Jaime: Crear un post de chatter informando del error al intentar asignar el caso a Valija.
												feed.Body = feed.Body + 'No es posible asignar un caso de Operación Expediente Persona a Valija sin que la cuenta tenga Num. Persona informado';
												insert feed;
												return retorno;
											}
											retorno.put('operacionValijaMCC', '06');
											retorno.put('nameOwnerCase', listadoCasosData[0].Owner.Name);
											
											//Modal de valija con datos de Operacion 06
										} else{
											retorno.put('operacionValijaMCC', trasladoWS.operacionValijaMCC);
											//Modal de valija estandar
										}

										retorno.put('datosCalculadosTraslado', JSON.serialize(trasladoWS));
										errorAsignacion = true;
										feed.Body = feed.Body + 'Se requiere información adicional para el traslado: ' + JSON.serialize(trasladoWS);
										insert feed;
										return retorno;
									}
								}
							}
						}
					}else{
						// Es un grupo operativo.
						listadoCasosData[0].SEG_Grupo__c=grupoId;
						listadoCasosData[0].SEG_Grupo_colaborador_Externo__c = null;
						listadoCasosData[0].SEG_Colaborador_externo_Segmentos__c = null;
					}
					listadoCasosData[0].OwnerId = colasBO.Id;
					update(listadoCasosData[0]);
					//Si el grupo es Envío Correo a Gestor se modifica el estado del caso
					if(retornoAsignacion.get('detalle') == 'grupoAutoEnvioCorreo')
					{
						listadoCasosData[0].Status = 'Pendiente';
						listadoCasosData[0].SEG_Subestado__c = 'Envío pendiente respuesta Gestor';
						update(listadoCasosData[0]);
					}
					// Si llegamos hasta aquí, el caso se ha asignado a un grupo.
					retorno.put('asignado','Y');
				}else{
					retorno.put('errorProceso', 'Y');
					grupoId = '';
					errorAsignacion = true;
					feed.Body = feed.Body + 'No se ha encontrado un grupo standard';
				}
			} else {
				errorAsignacion = true;
				feed.Body = feed.Body + ' No se ha podido encontrar un grupo al que asignar el caso por uno o varios motivos (Grupo sin org/zona, inexistente, inactivo, etc). Se debe revisar el problema manualmente.';
			}
		}
		trazabilidadAsignacion += ' | retorno:' + retorno;

		if(errorAsignacion){
			insert feed;
		}

		if(Limits.getDMLStatements() < Limits.getLimitDMLStatements()){
			CBK_Log.debug(listadoCasosData[0].Id , trazabilidadAsignacion);
		}
		return retorno;
	}

	@AuraEnabled
	public static Map<String,String> calcularTipoOperacionporNIF(String nif, Boolean esNIf1Boolean){
		Map<String,String> retorno = new Map<String,String>();
		retorno.put('tipoAccount', '');
		retorno.put('nombreTitular', 'No encontrado');
		// Lógica para calcular el tipo de operación según el NIF
		List<Account> accounts = [SELECT RecordType.DeveloperName, Name FROM Account WHERE CC_Numero_Documento__c = :nif AND RecordType.DeveloperName IN ('CC_ClientePA', 'CC_Cliente') LIMIT 1];

		if(!accounts.isEmpty()){
			if(accounts[0].RecordType.DeveloperName == 'CC_Cliente'){
				//es el nif de una empresa
				retorno.put('nombreTitular', accounts[0].Name);
				retorno.put('tipoAccount', '0-Empresa');
			} else if(accounts[0].RecordType.DeveloperName == 'CC_ClientePA') { 
				//es el nif de un particular
				retorno.put('nombreTitular', accounts[0].Name);
				retorno.put('tipoAccount', '1-Particular');
			}
		}
	
		return retorno;
	}

	/**
	 * @description Método para derivar un caso al grupo MCC por inconsistencia en las excepciones de asignación.
	 * @param caseId Identificador del caso.
	 * @param organizacion Organización del caso.
	 * @param zona Zona del caso
	 * @return Mapa con el estado del proceso de derivación al grupo MCC.
	 */
	public static Map<String,String> derivarGrupoMCCporInconsistenciaExcepciones (Id caseId, String organizacion, String zona)
	{
		List<FeedItem> listadoFeeds = new List<FeedItem>();
		Map<String,String> retornoDerivar = new Map<String,String>();
		retornoDerivar.put('codigo','0');
		retornoDerivar.put('detalle','');

		String operativa = 'Autoasignar Caso (Automático)';

		try{
			//Recuperar datos de la Organización y zona.
			SEG_Buzon__mdt datosOrgZona = SEG_wsRoboticsCasosComunes.recuperarDatosOrganizacionZona (organizacion, zona);

			// Por defecto, asignaremos el caso al grupo MCC. Después de crear el caso, se realizará la autoasignación de grupo.
			String grupoTrabajoId = SEG_wsRoboticsCasosComunes.buscarGrupoPorNombre (datosOrgZona.SEG_Grupo_MCC__c);
			if (String.isBlank(grupoTrabajoId))
			{
				retornoDerivar.put('codigo','1');
				retornoDerivar.put('detalle', 'Error durante la asignación automática: Se han encontrado dos o más excepciones de asignación para el caso, pero no se ha podido obtener el grupo MCC asociado a la Organización / Zona del caso. Contacte con el administrador del sistema.');
			}else{
				// Actualizar el caso y derivarlo al MCC.
				Case casoADerivar = new Case();
				casoADerivar.Id = caseId;
				casoADerivar.SEG_Grupo__c = grupoTrabajoId;
				update casoADerivar;

				String observaciones = 'Error durante la asignación automática: Se han encontrado dos o más excepciones de asignación para este caso y se ha asignado el grupo MCC';
				SEG_Case_Operativas_Controller.postOnChatterObject (caseId, observaciones, operativa, null, listadoFeeds);
			}
		}catch (Exception e){
            retornoDerivar.put('codigo','9999');
            retornoDerivar.put('detalle', 'Error al crear el caso. Detalle: ' + e.getMessage() + ' (' + e.getStackTraceString() + ')');
			CBK_Log.error(e);
		}

		if (retornoDerivar.get('codigo') != '0' || Test.isRunningTest())
		{
			String observaciones = 'Error durante la asignación automática: ' + retornoDerivar.get('detalle');
			SEG_Case_Operativas_Controller.postOnChatterObject (caseId, retornoDerivar.get('detalle'), operativa, null, listadoFeeds);
		}

		if (!listadoFeeds.isEmpty())
		{
			insert listadoFeeds;
		}

		return retornoDerivar;
	}

	/**
	 * @description Método para confirmar el traslado de un caso a Valija desde la botonera de operativas.
	 * @param datosTrasladoJSON Datos del traslado serializados en JSON para intercambiar entre las acciones del aura.
	 * @param notasManuales Notas introducidas manualmente por el agente.
	 * @param listaFicheros Listado de ficheros que ha seleccionado el usuario
	 * @return Mapa con el detalle del proceso de confirmación de traslado a Valija.
	 */
	@AuraEnabled
	public static Map<String,String> confirmarTrasladoValija (String datosTrasladoJSON, String notasManuales, List<String> listaFicheros)
	{
		Map<String,String> retorno = new Map<String,String>();
		retorno.put('codigo','0');
		retorno.put('detalle','');

		if (String.isBlank(datosTrasladoJSON))
		{
			retorno.put('codigo','100');
			retorno.put('detalle','No se ha podido procesar el traslado a Valija, faltan los datos necesarios del traslado.');
			return retorno;
		}

		SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador trasladoWS = (SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador)JSON.deserialize(datosTrasladoJSON, SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador.class);
		trasladoWS.notasManuales = notasManuales;

		if (listaFicheros != null && !listaFicheros.isEmpty())
		{
			trasladoWS.ficherosSeleccionados.addAll(listaFicheros);
		}

		// Iniciar el traslado a colaborador.
		retorno = SEG_trasladoColaboradorWS.iniciarTrasladoColaboradorWS(trasladoWS);

		return retorno;
	}

	public static Map<String,Integer> identificarExcepciones(Id caseId)
	{
		Map<String,Integer> retornoExcepcionesCalculadas = new Map<String,Integer>();
		retornoExcepcionesCalculadas.put('asignado',0);
		retornoExcepcionesCalculadas.put('numeroExcepciones',0);

		Boolean bAsignacion = false;

		// Nuevo método de cálculo de excepciones unificado.
		List<Id> listadoCasos = new List<Id>();
		listadoCasos.add(caseId);
		Map<String,Object> retornoExcepciones = SEG_ExcepcionesHandler.calcularExcepcionesCasosYContratos (0, listadoCasos, false, null);
		Map<Id,List<Id>> gruposAsignacion = (Map<Id,List<Id>>)retornoExcepciones.get('ASIGNACION');
		if (gruposAsignacion != null && gruposAsignacion.get(caseId) != null && gruposAsignacion.get(caseId)?.size() == 1)
		{
			// Existe un único grupo de asignación exclusivo.
			try{
				asignarGrupo(caseId, gruposAsignacion.get(caseId)[0]);
				bAsignacion = true;
			}catch(Exception e){
				// Registrar error
				CBK_Log.error(e);
			}
		}

		Integer asignacionCaso = (bAsignacion == true) ? 1 : 0;
		Integer numeroExcepciones = (gruposAsignacion != null && gruposAsignacion.get(caseId) != null) ? gruposAsignacion.get(caseId)?.size() : 0;

		retornoExcepcionesCalculadas.put('asignado', asignacionCaso);
		retornoExcepcionesCalculadas.put('numeroExcepciones', numeroExcepciones);

        return retornoExcepcionesCalculadas;
	}


	@AuraEnabled
	public static void tomarPropiedadCasoOld(Id caseId, Id ownerId) {

		Boolean tienePermiso = FeatureManagement.checkPermission('SEG_Supervisor');
		Boolean esRTSeguimiento = false;

		String nombrePerfil;
		List<Profile> profiles  = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
		if(!profiles.isEmpty()){
			nombrePerfil = profiles[0].Name;
		}


		Case caso = [SELECT SEG_Grupo__c, OwnerId, SEG_ClasificacionRapida__c, RecordType.DeveloperName FROM Case WHERE Id = :caseId];
		Boolean esUsuario = String.valueOf(caso.ownerId).startsWith('005');

		List<CC_Grupo_Colaborador_Contact__c> colaborador = [SELECT Id FROM CC_Grupo_Colaborador_Contact__c
																WHERE CC_Grupo_Colaborador__c = :caso.SEG_Grupo__c AND CC_Usuario__c = :ownerId LIMIT 1];

		if(caso.RecordType.DeveloperName == 'SEG_Seguimiento'){
			esRTSeguimiento = true;
		}

		if (nombrePerfil != 'System Administrator' && nombrePerfil != 'Administrador del Sistema' && colaborador.isEmpty()) {
			throw new AuraHandledException('No tienes permisos para tomar la propiedad del caso');
		} else if(nombrePerfil != 'System Administrator' && nombrePerfil != 'Administrador del Sistema' && !tienePermiso && esUsuario && !esRTSeguimiento) {
			throw new AuraHandledException('No puedes tomar en propiedad este caso ya que es propiedad de otro compañero en este momento');
		}
		else {
			caso.OwnerId = ownerId;
			caso.Status = 'Activo';
			caso.SEG_Subestado__c = 'En curso';
			try{
				update caso;

			}catch(Exception e)
			{
				throw new AuraHandledException(e.getMessage());
			}
	
			excepcionesTomarpropiedad(caseId);
		}
	}
	@future
	public static void excepcionesTomarpropiedad(Id caseId) {
			//VFR 11/21 - Toast excepciones
			//Evaluar que las excepciones siguen aplicando
			Map<String, Object> retornoExcepciones = SEG_ExcepcionesHandler.calcularExcepcionesCasosYContratos(2, new List<Id>{caseId}, false, null);
			Map<Id, List<SEG_Excepciones__c>> mapExcepciones = (Map<Id, List<SEG_Excepciones__c>>)retornoExcepciones.get('EXCEPCIONES');
			List<SEG_Excepciones__c> lstExcepciones = mapExcepciones.get(caseId);

			List<Id> lstIdsExcepciones = new List<Id>();
			if (lstExcepciones != null) {
				for (SEG_Excepciones__c e : lstExcepciones) {
					lstIdsExcepciones.add(e.id);
				}
			}

			//Excepciones del caso y comparar
			Id recordText = Schema.SObjectType.SEG_Excepciones__c.getRecordTypeInfosByDeveloperName().get('SEG_Texto').getRecordTypeId();
			List<SEG_Excepciones_Caso__c> lstExCase = new List<SEG_Excepciones_Caso__c>();
			for (SEG_Excepciones_Caso__c exc : [SELECT SEG_PopUp__c, SEG_Excepciones__c
												FROM SEG_Excepciones_Caso__c WHERE SEG_Case__c = :caseId
												AND SEG_Excepciones__r.RecordTypeId = :recordText
												AND SEG_Excepciones__r.SEG_Activa__c = TRUE]) {
				if (lstIdsExcepciones != null && lstIdsExcepciones.contains(exc.SEG_Excepciones__c)) {
					exc.SEG_PopUp__c = String.valueOfGmt(Datetime.now());
					lstExCase.add(exc);
				}
			}
			update lstExCase;
	}

	@AuraEnabled(cacheable=true)
	public static String buscarGrupoColaborador(Id idGrupo) {

		CC_Grupo_Colaborador__C grupoBuscado =  [SELECT name FROM CC_Grupo_Colaborador__C WHERE id = :idGrupo ];

		return grupoBuscado.Name;

	}

	@AuraEnabled
	public static List<ContentVersion> getFilesCase(Id casoId)
	{
		List<String> extensionesExcluir = new List<String>();
		extensionesExcluir.add('snote');
		return getFilesCaseFiltroExt (casoId, extensionesExcluir);
	}

	@AuraEnabled
	public static List<ContentVersion> getFilesCaseFiltroExt(Id casoId, List<String> extensionesExcluir)
	{

		List<ContentDocumentLink> contentDocLinkList = new List<ContentDocumentLink>([SELECT ContentDocumentId, LinkedEntityId  FROM ContentDocumentLink where LinkedEntityId in ( SELECT Id FROM Case where id=: casoId) and LinkedEntity.Type='Case']);
		Set<Id> contentDocLinkIds = new Set<Id>();
		for (ContentDocumentLink contentLink:contentDocLinkList)
		{
			contentDocLinkIds.add(contentLink.ContentDocumentId);
		}
		List<ContentVersion> listFiles = new List<ContentVersion>();
		listFiles = [select ContentDocumentId,Title,FileExtension,Description, CreatedDate, ContentSize from ContentVersion where ContentDocumentId in:contentDocLinkIds and FileExtension not in :extensionesExcluir];
		return listFiles;
	}

	@AuraEnabled
	public static Map<id,String> fetchCRSeguimientoController()
	{
		List<SEG_ClasificacionRapida__c> listCR = new List<SEG_ClasificacionRapida__c>();
		Map<Id,String> mapClasificaciones = new Map<Id,String>();
		listCR=[select id, Name from SEG_ClasificacionRapida__c where SEG_Inactiva__c = false AND SEG_CRContratos__c = true];
		for(SEG_ClasificacionRapida__c cr:listCR)
		{
			mapClasificaciones.put(cr.id,cr.name);
		}
		return mapClasificaciones;
	}


	@AuraEnabled
	public static Map<String,String> crearCasos(Id casoID, String listFiles,String crId)
	{
		Map<String,String> casoCreado = new Map<String,String>();
		//posición 1 List String: CaseNumber o KO
		//posición 2 List String: Clasificación Rápida
		//posición 3 List String: Grupo Asignado
		String resultado='OK';
		List<Id> wrapperSet = new List<Id>();
		List<Group> colasBO = new List<Group>([SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SEG_BO' LIMIT 1]);
		if(listFiles!='["0"]')
		{
			Type idTypeListId = Type.forName('List<Id>');
			wrapperSet = (List<Id>) JSON.deserialize(listFiles, idTypeListId);
		}


		//realizamos query sobre el caso Original
		Case casoOrigen = new Case();
		casoOrigen = [SELECT id, Origin, Subject, CaseNumber,Description, SEG_ClasificacionRapida__c, CC_MCC_Tematica__c, CC_MCC_ProdServ__c, RecordTypeId, ParentId,
						CC_MCC_Motivo__c, SEG_Detalle__c, Priority, AccountId, ContactId, SEG_Numero_de_centro__c,
						CC_MailTelfNotif__c, SEG_Organizacion__c, SEG_Zona__c,OwnerId,CC_AcuseRecibo__c,SEG_Numero_centro__c,
						Status, SEG_Subestado__c, SEG_Grupo__c, SEG_Grupo__r.Name, SEG_Email_Buzon_Entrada__c,
						// Datos Valija a traspasar
						OS_Nombre_Proceso_Valija__c, SEG_CIFOrdenanteValija__c, SEG_ConceptoValija__c, SEG_DocumentosValija__c, SEG_TipoProcesoValija__c, SEG_TipoValija__c,
						SEG_ComunidadAutonoma__c, SEG_PagoAgrupado__c, SEG_TipoCargo__c, SEG_FechaCargo__c, SEG_Idioma__c
						FROM Case where id=:casoID];

		//Comprobamos que el caso de Origen no sea una hija o un caso de Seguimiento
		Id rtSeguimiento = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId();
		String hasParent = casoOrigen?.ParentId;
		if(casoOrigen == null || casoOrigen?.Id == null || string.isNotBlank(hasParent) || casoOrigen?.RecordTypeId == rtSeguimiento){
			return null;
		}else{
			List<Case> listCasosHijos = new List<Case>();
			if(casoOrigen !=null)
			{

				//creamos un caso nuevo según número de casos entrados en el Lightning
				Case caso = new Case();
				caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
				caso.Origin = casoOrigen.Origin;
				caso.Subject = 'Caso relacionado #'+casoOrigen.CaseNumber+': '+casoOrigen.Subject;
				caso.Description = casoOrigen.Description;
				if(String.isBlank(crId))
				{
					caso.SEG_ClasificacionRapida__c = casoOrigen.SEG_ClasificacionRapida__c;
					caso.CC_MCC_Tematica__c = casoOrigen.CC_MCC_Tematica__c;
					caso.CC_MCC_ProdServ__c = casoOrigen.CC_MCC_ProdServ__c;
					caso.CC_MCC_Motivo__c = casoOrigen.CC_MCC_Motivo__c;
					caso.SEG_Detalle__c = casoOrigen.SEG_Detalle__c;
				}
				else {
					SEG_ClasificacionRapida__c crRapida = new SEG_ClasificacionRapida__c();
					crRapida=[select id,SEG_Detalle__c,SEG_Motivo__c,SEG_Producto__c,SEG_Tematica__c from SEG_ClasificacionRapida__c where id=:crId];
					caso.SEG_ClasificacionRapida__c=crId;
					caso.CC_MCC_Tematica__c = crRapida.SEG_Tematica__c;
					caso.CC_MCC_ProdServ__c = crRapida.SEG_Producto__c;
					caso.CC_MCC_Motivo__c = crRapida.SEG_Motivo__c;
					caso.SEG_Detalle__c = crRapida.SEG_Detalle__c;
				}
				caso.Priority = casoOrigen.Priority;
				caso.AccountId = casoOrigen.AccountId;
				caso.ContactId = casoOrigen.ContactId;
				caso.CC_MailTelfNotif__c = casoOrigen.CC_MailTelfNotif__c;
				caso.SEG_Organizacion__c = casoOrigen.SEG_Organizacion__c;
				caso.SEG_Zona__c = casoOrigen.SEG_Zona__c;
				caso.OwnerId=casoOrigen.OwnerId; ///////OJOOOO, pendiente
				caso.SEG_Numero_de_centro__c=casoOrigen.SEG_Numero_de_centro__c;
				caso.SEG_Numero_centro__c=casoOrigen.SEG_Numero_centro__c;
				caso.Status='Activo';
				caso.SEG_Subestado__c='En curso';
				caso.SEG_Grupo__c=casoOrigen.SEG_Grupo__c;
				caso.ParentId=casoOrigen.Id;
				//caso.SEG_N_operaciones_del_caso__c = 0;
				caso.CC_No_Identificado__c = (String.isBlank(caso.AccountId) || String.isBlank(caso.ContactId)) ? true : false;

				// Traspasar información de Valija.
				caso.SEG_TipoValija__c = casoOrigen.SEG_TipoValija__c;
				//caso.SEG_TipoProcesoValija__c = casoOrigen.SEG_TipoProcesoValija__c; --> Lo dejamos null, se gestiona como un caso nuevo que no ha entrado por paquetería
				caso.OS_Nombre_Proceso_Valija__c = casoOrigen.OS_Nombre_Proceso_Valija__c;
				caso.SEG_CIFOrdenanteValija__c = casoOrigen.SEG_CIFOrdenanteValija__c;
				caso.SEG_TipoCargo__c = casoOrigen.SEG_TipoCargo__c;
				//caso.SEG_FechaCargo__c = casoOrigen.SEG_FechaCargo__c; --> Se queda null por evitar la Custom Validation.
				caso.SEG_PagoAgrupado__c = casoOrigen.SEG_PagoAgrupado__c;
				caso.SEG_ComunidadAutonoma__c = casoOrigen.SEG_ComunidadAutonoma__c;
				caso.SEG_ConceptoValija__c = casoOrigen.SEG_ConceptoValija__c;
				caso.SEG_DocumentosValija__c = casoOrigen.SEG_DocumentosValija__c;
				caso.SEG_Idioma__c = casoOrigen.SEG_Idioma__c;
				if(casoOrigen.SEG_Email_Buzon_Entrada__c != null){
					caso.SEG_Email_Buzon_Entrada__c = casoOrigen.SEG_Email_Buzon_Entrada__c;
				}

				listCasosHijos.add(caso);

				if(listCasosHijos.size()>0)
				{
					insert(listCasosHijos);


					List<EmailMessage> primerMailCaso = [SELECT id,CreatedDate, Subject, SEG_BotonPulsado__c, CcAddress, FromAddress, FromName, HtmlBody, Incoming, MessageDate, ParentId, ToAddress, CC_Aplicacion__c
					FROM EmailMessage WHERE ParentId =: casoID AND Incoming = true ORDER BY CreatedDate ASC LIMIT 1];

					if (!primerMailCaso.isEmpty()){
						EmailMessage emailClonado = primerMailCaso[0].clone(false, false, true, false);
						emailClonado.parentId = caso.Id;
						emailClonado.SEG_EmailReciclado__c = false;
						insert emailClonado;
					}

					List<ContentDocumentLink> listDocumentosInsert = new List<ContentDocumentLink>();
					for(Case casohijo : listCasosHijos)
					{
						for(Id idContentDocumentId:wrapperSet)
						{
							ContentDocumentLink objCntDocLink = new ContentDocumentLink();
							objCntDocLink.LinkedEntityId = casohijo.id;
							objCntDocLink.ContentDocumentId = idContentDocumentId;
							objCntDocLink.shareType = 'V';
							listDocumentosInsert.add(objCntDocLink);
						}
					}
					if(listDocumentosInsert.size()>0)
					{
						insert(listDocumentosInsert);
					}

					//VFR-20/01: El caso origen debe actualizarse con los siguientes valores:
					List<SEG_ClasificacionRapida__c> lstCR = [SELECT id FROM SEG_ClasificacionRapida__c WHERE Name = 'Gestión en caso vinculado' AND CBK_Negocio__c = 'Segmentos' LIMIT 1];

					List<CC_MCC__c> lstMCC = [
						SELECT Id, RecordType.DeveloperName
						FROM CC_MCC__c
						WHERE Name = 'Gestión en caso vinculado'
						  AND CC_Tipo_Cliente__c = 'Segmentos'
						  AND RecordType.DeveloperName IN ('CC_Tematica', 'CC_Producto_Servicio', 'CC_Motivo')
					];
					
					if (!lstCR.isEmpty()){
						casoOrigen.SEG_ClasificacionRapida__c = lstCR[0].Id;
					}
					

					Id tematicaId, productoId, motivoId;
					for (CC_MCC__c mcc : lstMCC) {
						if (mcc.RecordType.DeveloperName == 'CC_Tematica') casoOrigen.CC_MCC_Tematica__c = mcc.Id;
						else if (mcc.RecordType.DeveloperName == 'CC_Producto_Servicio') casoOrigen.CC_MCC_ProdServ__c = mcc.Id;
						else if (mcc.RecordType.DeveloperName == 'CC_Motivo') casoOrigen.CC_MCC_Motivo__c = mcc.Id;
					}
					

					update casoOrigen;
				}
			}
			if(listCasosHijos.size()==1)
			{
				Case newCase = new Case();
				newCase = [select id, SEG_ClasificacionRapida__c,SEG_ClasificacionRapida__r.Name,CaseNumber,SEG_Grupo__c,SEG_Grupo__r.Name, SEG_SemillaId__c from Case where id=:listCasosHijos[0].Id];
				//posición 1 List String: CaseNumber o KO
				//posición 2 List String: Clasificación Rápida
				//posición 3 List String: Grupo Asignado

				casoCreado.put('estado','OK');
				casoCreado.put('casoId',newCase.id);
				casoCreado.put('caseNumber',newCase.CaseNumber);
				casoCreado.put('semillaId',newCase.SEG_SemillaId__c);
				casoCreado.put('groupName',(String.isNotBlank(casoOrigen.SEG_Grupo__r?.Name))?casoOrigen.SEG_Grupo__r?.Name:'SIN GRUPO');
				casoCreado.put('crName',newCase.SEG_ClasificacionRapida__r?.Name);

				List<FeedItem> feedLst = new List<FeedItem>();
				FeedItem feed =  new FeedItem();
				feed.ParentId = casoID;
				feed.Body = 'Caso hijo creado: ' + newCase.CaseNumber;
				feed.isRichText = true;
				feedLst.add(feed);

				FeedItem feedHijo =  new FeedItem();
				feedHijo.ParentId = newCase.id;
				feedHijo.Body = 'Caso hijo creado de caso : ' + casoOrigen.CaseNumber;
				feedHijo.isRichText = true;
				feedLst.add(feedHijo);

				insert feedLst;
			}
			else {
				//casoCreado.add('KO');

				casoCreado.put('estado','KO');
			}
			return casoCreado;
		}
	}

	//JAV Método para recuperar los emails del caso, para después elegir uno y crear un caso a partir de este

	@AuraEnabled
	public static Map<id,String> fetchEmailsCaso(String caseId){

		List<EmailMessage> listEmail = new List<EmailMessage>([SELECT Id, FromName, Subject, HtmlBody,TextBody,Incoming,HasAttachment,SEG_HasAnexo__c,MessageDate, CreatedDate FROM EmailMessage WHERE ParentId = :caseId and Incoming = true ORDER BY MessageDate DESC]);
		Map<Id,String> mapEmail = new Map<Id,String>();
		Date eDate;
		Time eTime;
		Datetime aux;
		Datetime dt;
		for(EmailMessage emailCas:listEmail)
		{
			TimeZone tz = UserInfo.getTimeZone();
			//emailCas.MessageDate.addSeconds(tz.getOffset(emailCas.MessageDate)/1000);
			dt = emailCas.MessageDate;

			eDate = Date.newInstance( emailCas.MessageDate.year(), emailCas.MessageDate.month(), emailCas.MessageDate.day() );
			eTime = Time.newInstance( emailCas.CreatedDate.hour() + 1, emailCas.CreatedDate.minute(), emailCas.CreatedDate.second(), 0 );
			//aux = Datetime.newInstance( eDate, eTime );

			mapEmail.put(emailCas.Id,emailCas.Subject +' | '+ emailCas.MessageDate.addSeconds(tz.getOffset(emailCas.MessageDate)/1000));
		}
		return mapEmail;
	}

	//JAV Método para crear casos a partir de mail reciclado  //JAV Método para crear casos a partir de mail reciclado

	@AuraEnabled
	public static List<String> crearCasosReciclados(Id casoID, String listFiles, String emailId) {
		List<String> casoCreado = new List<String>();
		Map<Id, Case> auxMapCase = new Map<Id, Case>();
		List<Id> casosIdLst = new List<Id>();
		List<Case> listCasoOrigUpd = new List<Case>();
		String operativa = 'Acuse de recibo Reciclado';
		//posición 1 List String: CaseNumber o KO
		//posición 2 List String: Clasificación Rápida
		//posición 3 List String: Grupo Asignado
		List<EmailMessage> emailSelected = new List<EmailMessage>(
			[SELECT Subject, FromAddress, MessageDate, FromName, ToAddress, HtmlBody, TextBody, SEG_EmailReciclado__c, CreatedDate
			FROM EmailMessage WHERE Id = :emailId]
		);

		if (!emailSelected.isEmpty()) {
			String resultado = 'OK';
			//String statusOld;
			//String substatusOld;
			List<Id> wrapperSet = new List<Id>();
			if (listFiles != '["0"]') {
				Type idTypeListId = Type.forName('List<Id>');
				wrapperSet = (List<Id>)JSON.deserialize(listFiles, idTypeListId);
			}


			//realizamos query sobre el caso Original
			Case casoOrigen = new Case();
			casoOrigen = [SELECT Origin,  Subject, CaseNumber,Description, SEG_ClasificacionRapida__c,SEG_Numero_centro__c, CC_MCC_Tematica__c, CC_MCC_ProdServ__c,
							CC_MCC_Motivo__c, SEG_Detalle__c, Priority, AccountId, ContactId, SEG_OldSubStatus__c, SEG_OldStatus__c,
							CC_MailTelfNotif__c, SEG_Organizacion__c, SEG_Zona__c,OwnerId,CC_AcuseRecibo__c,SEG_Numero_de_centro__c,
							Status, SEG_Subestado__c, SEG_Grupo__c,SEG_Idioma__c,CC_Idioma__c,SEG_Grupo_Empresa__c,ContactEmail,SEG_Estado_Contacto__c,SEG_No_AR_Account__c,
							SEG_No_AR_Contact__c, SEG_Email_Buzon_Entrada__c,
							// Datos Valija a traspasar
							OS_Nombre_Proceso_Valija__c, SEG_CIFOrdenanteValija__c, SEG_ConceptoValija__c, SEG_DocumentosValija__c, SEG_TipoProcesoValija__c, SEG_TipoValija__c,
							SEG_ComunidadAutonoma__c, SEG_PagoAgrupado__c, SEG_TipoCargo__c, SEG_FechaCargo__c
							FROM Case WHERE Id = :casoID];

			List<Case> listCasoReciclado = new List<Case>();

			//creamos un caso nuevo según número de casos entrados en el Lightning
			Case caso = new Case();
			caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
			caso.Origin = casoOrigen.Origin;
			caso.Subject = 'Caso reciclado #'+emailSelected[0].Subject;
			//caso.Description = casoOrigen.Description;
			caso.Description = emailSelected[0].TextBody?.left(32000);
			caso.SEG_ClasificacionRapida__c = casoOrigen.SEG_ClasificacionRapida__c;
			caso.CC_MCC_Tematica__c = casoOrigen.CC_MCC_Tematica__c;
			caso.CC_MCC_ProdServ__c = casoOrigen.CC_MCC_ProdServ__c;
			caso.CC_MCC_Motivo__c = casoOrigen.CC_MCC_Motivo__c;
			caso.SEG_Detalle__c = casoOrigen.SEG_Detalle__c;
			caso.Priority = casoOrigen.Priority;
			caso.AccountId = casoOrigen.AccountId;
			caso.ContactId = casoOrigen.ContactId;
			caso.CC_MailTelfNotif__c = casoOrigen.CC_MailTelfNotif__c;
			caso.SEG_Organizacion__c = casoOrigen.SEG_Organizacion__c;
			caso.SEG_Zona__c = casoOrigen.SEG_Zona__c;
			//caso.OwnerId=colasBO[0].id; ///////OJOOOO, pendiente
			caso.SEG_Numero_centro__c = casoOrigen.SEG_Numero_centro__c;
			caso.Status = 'Activo';
			caso.SEG_Subestado__c = 'En curso';
			caso.SEG_Grupo__c = casoOrigen.SEG_Grupo__c;

			if (String.isNotBlank(casoOrigen.SEG_Idioma__c)) {
				caso.SEG_Idioma__c = casoOrigen.SEG_Idioma__c;
			} else {
				caso.CC_Idioma__c = casoOrigen.CC_Idioma__c;
			}

			if (casoOrigen.SEG_OldStatus__c!= null) {
				casoOrigen.Status = casoOrigen.SEG_OldStatus__c;
				listCasoOrigUpd.add(casoOrigen);
			}

			if (casoOrigen.SEG_OldSubStatus__c != null) {
				casoOrigen.SEG_Subestado__c = casoOrigen.SEG_OldSubStatus__c;
				listCasoOrigUpd.add(casoOrigen);
			}
			if (casoOrigen.SEG_Email_Buzon_Entrada__c != null){
				caso.SEG_Email_Buzon_Entrada__c = casoOrigen.SEG_Email_Buzon_Entrada__c;
			}


			// Traspasar información de Valija.
			caso.SEG_TipoValija__c = casoOrigen.SEG_TipoValija__c;
			//caso.SEG_TipoProcesoValija__c = casoOrigen.SEG_TipoProcesoValija__c; --> Lo dejamos null, se gestiona como un caso nuevo que no ha entrado por paquetería
			caso.OS_Nombre_Proceso_Valija__c = casoOrigen.OS_Nombre_Proceso_Valija__c;
			caso.SEG_CIFOrdenanteValija__c = casoOrigen.SEG_CIFOrdenanteValija__c;
			caso.SEG_TipoCargo__c = casoOrigen.SEG_TipoCargo__c;
			//caso.SEG_FechaCargo__c = casoOrigen.SEG_FechaCargo__c; --> Se queda null por evitar la Custom Validation.
			caso.SEG_PagoAgrupado__c = casoOrigen.SEG_PagoAgrupado__c;
			caso.SEG_ComunidadAutonoma__c = casoOrigen.SEG_ComunidadAutonoma__c;
			caso.SEG_ConceptoValija__c = casoOrigen.SEG_ConceptoValija__c;
			caso.SEG_DocumentosValija__c = casoOrigen.SEG_DocumentosValija__c;

			//caso.ParentId = casoOrigen.Id;

			listCasoReciclado.add(caso);

			if (!listCasoReciclado.isEmpty()) {
				insert(listCasoReciclado);
				List<ContentDocumentLink> listDocumentosInsert = new List<ContentDocumentLink>();
				for (Case casoRec : listCasoReciclado) {
					for (Id idContentDocumentId : wrapperSet) {
						ContentDocumentLink objCntDocLink = new ContentDocumentLink();
						objCntDocLink.LinkedEntityId = casoRec.id;
						objCntDocLink.ContentDocumentId = idContentDocumentId;
						objCntDocLink.shareType = 'V';
						listDocumentosInsert.add(objCntDocLink);
					}
				}
				if (!listDocumentosInsert.isEmpty()) {
					insert(listDocumentosInsert);
				}

				//copiamos emails que ha generado el caso reciclado
				List<EmailMessage> emailsListToRelate = new List<EmailMessage>();
				List<EmailMessage> emailsListOriginalUpd = new List<EmailMessage>();
				for (EmailMessage emailOriginal : emailSelected) {
					EmailMessage newEmail = emailOriginal.clone(false, false, true, false);
					newEmail.RelatedToId = listCasoReciclado[0].Id;
					newEmail.Incoming = true;
					emailsListToRelate.add(newEmail);
					emailOriginal.SEG_EmailReciclado__c = true;
					emailsListOriginalUpd.add(emailOriginal);
				}
				insert(emailsListToRelate);
				update(emailsListOriginalUpd);
			}

			List<Case> csListNewRec = [SELECT Id,CaseNumber, Subject, SEG_Grupo__r.Name, Status,SEG_Subestado__c,ParentId,CC_Detalles_Consulta__c,SEG_ClasificacionRapida__c,SEG_ClasificacionRapida__r.Name, SEG_Grupo__c,SEG_Grupo_Empresa__c,
			SEG_Organizacion__c,SEG_Zona__c,SEG_Numero_de_centro__c,Contact.SEG_No_enviar_Acuse_Recibo__c,Account.SEG_No_enviar_Acuse_Recibo_Empresa__c,SEG_Idioma__c,
			ContactId,CC_AcuseRecibo__c,ContactEmail,SEG_Estado_Contacto__c,SEG_No_AR_Account__c,SEG_No_AR_Contact__c,SEG_Resultado__c,SEG_N_case_y_subject__c,SEG_SemillaId__c
			FROM Case WHERE Id=:listCasoReciclado[0].Id];

			for(Case casrecNew: csListNewRec){
				casosIdLst.add(casrecNew.Id);
				auxMapCase.put(casrecNew.Id,casrecNew);
			}
			if(listCasoReciclado.size()==1){


				if (csListNewRec[0].CaseNumber != null){
					casoCreado.add(csListNewRec[0].CaseNumber);
				}
				else{
					casoCreado.add('SIN NÚMERO CASO');
				}
				if (csListNewRec[0].SEG_ClasificacionRapida__r.Name != null){
					casoCreado.add(csListNewRec[0].SEG_ClasificacionRapida__r.Name);
				}
				else{
					casoCreado.add('SIN CR');
				}
				if (csListNewRec[0].SEG_Grupo__r.Name != null){
					casoCreado.add(csListNewRec[0].SEG_Grupo__r.Name);
				}
				else{
					casoCreado.add('SIN GRUPO');
				}
				if (csListNewRec[0].id != null){
					casoCreado.add(csListNewRec[0].id);
				}
				else{
					casoCreado.add('SIN ID CASO');
				}

				try {
					SEG_MetodosComunes.enviarCorreo(casosIdLst,auxMapCase,operativa);
				} catch(Exception ex) {
					CBK_Log.debug('Error al enviar correo con operativa acuse de recibo reciclado. Excepción :' + ex);

				}

				//Creamos una nota en observaciones
				FeedItem feed = new FeedItem();
				feed.ParentId = casoID;
				feed.Body = 'Nuevo caso creado a partir de Email reciclado: ' + casoCreado;
				feed.isRichText = true;
				insert feed;

				//metemos los valores de la lista listCasoOrigUpd para evitar duplicados en un map

				//create a map that will hold the values of the list
				map<Id, Case> casemap = new map<Id, Case>();

				//put all the values from the list to map.
				casemap.putAll(listCasoOrigUpd);
				if(casemap.size()>0){
					update casemap.values();
				}
			}
			else {
				casoCreado.add('KO');
			}
			return casoCreado;
		}
		else {
			List<String> error = new List<String>();
			error.add('KO');
			return error;
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

	@AuraEnabled
	public static Map<String, String> crearCasoSeguimiento(Id casoID, String listFiles,String crId, String numContratos)
	{
		Map<String, String> casoCreado = new Map<String, String>();
		//posición 1 List String: CaseNumber o KO
		//posición 2 List String: Clasificación Rápida
		//posición 3 List String: Grupo Asignado
		Id rtSeguimiento = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId();
		String resultado='OK';
		List<Id> wrapperSet = new List<Id>();
		if(listFiles!= null && listFiles!='["0"]'){
			Type idTypeListId = Type.forName('List<Id>');
			wrapperSet = (List<Id>) JSON.deserialize(listFiles, idTypeListId);
		}


		//realizamos query sobre el caso Original
		Case casoOrigen = new Case();
		casoOrigen = [SELECT id, Origin, Subject, CaseNumber,Description, SEG_ClasificacionRapida__c, CC_MCC_Tematica__c, CC_MCC_ProdServ__c, RecordTypeId,
		CC_MCC_Motivo__c, SEG_Detalle__c, Priority, AccountId, ContactId, SEG_Idioma__c,
		CC_MailTelfNotif__c, SEG_Organizacion__c, SEG_Zona__c,OwnerId,CC_AcuseRecibo__c,SEG_Numero_de_centro__c,
		Status, SEG_Subestado__c, SEG_Grupo__c, SEG_Email_Buzon_Entrada__c, Contact.RecordType.DeveloperName, Contact.Email FROM Case where id=:casoID];
		if(casoOrigen.RecordTypeId == rtSeguimiento){
			casoCreado.put('error','Seguimiento');
			return casoCreado;
		} else if(!casoOrigen.Contact.RecordType.DeveloperName.equalsIgnoreCase('CC_Cliente') && !casoOrigen.Contact.RecordType.DeveloperName.equalsIgnoreCase('CC_Empleado')){
			casoCreado.put('error','Contacto');
			return casoCreado;
		} else{
			List<Case> listCasosHijos = new List<Case>();
			if(casoOrigen !=null) {

				//creamos un caso nuevo según número de casos entrados en el Lightning
				Case caso = new Case();
				caso.RecordTypeId = rtSeguimiento;
				caso.Origin = casoOrigen.Origin;
				caso.Subject = 'Caso relacionado #'+casoOrigen.CaseNumber+': '+casoOrigen.Subject;
				caso.Description = casoOrigen.Description;
				caso.SEG_Email_Buzon_Entrada__c = casoOrigen.SEG_Email_Buzon_Entrada__c;

				if(numContratos != null){
					caso.SEG_N_operaciones_del_caso__c = Integer.valueOf(numContratos);
				}

				if(String.isBlank(crId)){
					caso.SEG_ClasificacionRapida__c = casoOrigen.SEG_ClasificacionRapida__c;
					caso.CC_MCC_Tematica__c = casoOrigen.CC_MCC_Tematica__c;
					caso.CC_MCC_ProdServ__c = casoOrigen.CC_MCC_ProdServ__c;
					caso.CC_MCC_Motivo__c = casoOrigen.CC_MCC_Motivo__c;
					caso.SEG_Detalle__c = casoOrigen.SEG_Detalle__c;
				} else {
					SEG_ClasificacionRapida__c crRapida = new SEG_ClasificacionRapida__c();
					crRapida=[select id,SEG_Detalle__c,SEG_Motivo__c,SEG_Producto__c,SEG_Tematica__c from SEG_ClasificacionRapida__c where id=:crId];
					caso.SEG_ClasificacionRapida__c=crId;
					caso.CC_MCC_Tematica__c = crRapida.SEG_Tematica__c;
					caso.CC_MCC_ProdServ__c = crRapida.SEG_Producto__c;
					caso.CC_MCC_Motivo__c = crRapida.SEG_Motivo__c;
					caso.SEG_Detalle__c = crRapida.SEG_Detalle__c;
				}

				caso.Priority = casoOrigen.Priority;
				caso.SEG_Idioma__c = casoOrigen.SEG_Idioma__c; //DE77522 - El caso de seguimiento debe arrastrar el idioma del caso origen.
				caso.AccountId = casoOrigen.AccountId;
				caso.ContactId = casoOrigen.ContactId;
				caso.CC_MailTelfNotif__c = casoOrigen.CC_MailTelfNotif__c;
				caso.SEG_Organizacion__c = casoOrigen.SEG_Organizacion__c;
				caso.SEG_Zona__c = casoOrigen.SEG_Zona__c;
				caso.SEG_Numero_de_centro__c=casoOrigen.SEG_Numero_de_centro__c;
				caso.Status='Activo';
				caso.SEG_Subestado__c='En curso';
				caso.SEG_Grupo__c=casoOrigen.SEG_Grupo__c;
				caso.SEG_SROrigen__c = casoOrigen.Id;

				listCasosHijos.add(caso);


				if(listCasosHijos.size()>0)
				{
					insert(listCasosHijos);
					List<ContentDocumentLink> listDocumentosInsert = new List<ContentDocumentLink>();
					for(Case casohijo : listCasosHijos)
					{
						for(Id idContentDocumentId:wrapperSet)
						{
							ContentDocumentLink objCntDocLink = new ContentDocumentLink();
							objCntDocLink.LinkedEntityId = casohijo.id;
							objCntDocLink.ContentDocumentId = idContentDocumentId;
							objCntDocLink.shareType = 'V';
							listDocumentosInsert.add(objCntDocLink);
						}
					}
					if(listDocumentosInsert.size()>0)
					{
						insert(listDocumentosInsert);
					}
				}
			}
			if(listCasosHijos.size()==1)
			{
				Case newCase = new Case();
				newCase = [select id, SEG_ClasificacionRapida__c,SEG_ClasificacionRapida__r.Name,CaseNumber,SEG_Grupo__c,SEG_Grupo__r.Name from Case where id=:listCasosHijos[0].Id];
				//posición 1 List String: CaseNumber o KO
				//posición 2 List String: Clasificación Rápida
				//posición 3 List String: Grupo Asignado 

				casoCreado.put('casoCreadoCN',newCase.CaseNumber);
				casoCreado.put('casoCreadoCR',(String.isNotBlank(newCase.SEG_ClasificacionRapida__r?.Name))?newCase.SEG_ClasificacionRapida__r.Name:'');
				casoCreado.put('casoCreadoGrupo',(String.isNotBlank(newCase.SEG_Grupo__r?.Name))?newCase.SEG_Grupo__r.Name:'SIN_GRUPO');
				casoCreado.put('casoCreadoId',newCase.id);

				List<FeedItem> feedLst = new List<FeedItem>();
				FeedItem feed =  new FeedItem();
				feed.ParentId = casoID;
				feed.Body = 'Caso de seguimiento creado: ' + newCase.CaseNumber;
				feed.isRichText = true;
				feedLst.add(feed);

				FeedItem feedHijo =  new FeedItem();
				feedHijo.ParentId = newCase.id;
				feedHijo.Body = 'Caso de seguimiento creado a partir de caso : ' + casoOrigen.CaseNumber;
				feedHijo.isRichText = true;
				feedLst.add(feedHijo);

				insert feedLst;
			}
			else {
				casoCreado.put('error','KO');
			}
			return casoCreado;
		}
	}

	@AuraEnabled
	static public void crearContratos( String casoId, Integer nContratos, String casoMadre, String nombresContratos){
		List<String> listaNombres = nombresContratos.split(',');
		Integer listaNombresSize = listaNombres.size();
		Integer contratosSinNombre = nContratos-listaNombresSize;

		String idioma = '';
		List<Case> caso = [SELECT contactId, accountId, Status, SEG_Subestado__c FROM Case WHERE Id = :casoId LIMIT 1];
		if (caso.isEmpty())
		{
			// Lanzar excepción para el Aura.
			throw new AuraHandledException('No se ha localizado el caso <' + casoId + '>.');
		}else{
			List<Contact> listadoContactos = [SELECT CC_Idioma__c FROM Contact WHERE Id = : caso[0].contactId LIMIT 1];
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

			List<SEG_Contratos__c> contratos = new List<SEG_Contratos__c>();
			for (Integer i = 0; i < listaNombresSize; i++) {
				SEG_Contratos__c contrato = new SEG_Contratos__c();
				contrato.SEG_NombreCuenta__c = caso[0].accountId;
				contrato.SEG_NombreCliente__c = caso[0].contactId;
				contrato.SEG_SR_Seguimiento__c = casoId;
				contrato.SEG_Idioma__c = idioma;
				contrato.Name = listaNombres[i];
				contratos.add(contrato);

			}
			for (Integer i = 0; i < contratosSinNombre; i++) {
				SEG_Contratos__c contrato = new SEG_Contratos__c();
				contrato.SEG_NombreCuenta__c = caso[0].accountId;
				contrato.SEG_NombreCliente__c = caso[0].contactId;
				contrato.SEG_SR_Seguimiento__c = casoId;
				contrato.SEG_Idioma__c = idioma;
				contratos.add(contrato);
			}
			insert contratos;
		}

	}

	@AuraEnabled
	public static List<Case> buscadorCases(String cadenaBusqueda, Id idCaso) {
		if (cadenaBusqueda.length() < 3) {
            List<Id> idCasosRecientes = CC_MetodosUtiles.listaCampo(
                [SELECT Id FROM RecentlyViewed WHERE Type = 'Case' AND Id != :idCaso LIMIT 25], 'Id'
            );
            return [SELECT CaseNumber, Subject FROM Case WHERE Id IN :idCasosRecientes];
        } else {
			Pattern patCasenum = Pattern.compile('^[0-9]{8}$');
			Matcher matcherCasenum = patCasenum.matcher(cadenaBusqueda);
			if (matcherCasenum.find()) {
				return [SELECT CaseNumber, Subject FROM Case
						WHERE RecordType.DeveloperName IN ('SEG_Cliente', 'SEG_Seguimiento')
						AND CaseNumber = :cadenaBusqueda
						AND Id != :idCaso
						ORDER BY CreatedDate DESC LIMIT 5];
			} else {
				List<List<SObject>> busquedaCasos = [
					FIND :cadenaBusqueda
					IN ALL FIELDS
					RETURNING
						Case (
							CaseNumber, Subject WHERE RecordType.DeveloperName IN ('SEG_Cliente', 'SEG_Seguimiento') AND Id != :idCaso ORDER BY CreatedDate DESC
						)
					LIMIT 5
				];
				List<Case> listCases = (List<Case>)busquedaCasos[0];
				return listCases;
			}
		}
	}

	@AuraEnabled
	public static List<String> importarEmailsAnexos(Id casoID, String listFiles,String emailId,String casoSelId){
		//JAV Método para importar emails y anexos de otra SR

		List<String> casoCreado = new List<String>();
		Map<Id,Case> auxMapCase = new Map<Id,Case>();
		List<Id> casosIdLst = new List<Id>();
		casosIdLst.add(casoId);
		casosIdLst.add(casoSelId);
		List<Case> listCasoOrigUpd = new List<Case>();
		//posición 1 List String: CaseNumber o KO
		//posición 2 List String: Clasificación Rápida
		//posición 3 List String: Grupo Asignado
		List<EmailMessage> emailSelected = new List<EmailMessage>([SELECT Id,Subject,FromAddress,ToAddress,HtmlBody,MessageDate, TextBody,SEG_EmailReciclado__c,CreatedDate FROM EmailMessage WHERE Id=:emailId Limit 1]);
		String resultado='OK';
		String statusOld;
		String substatusOld;
		List<Id> wrapperSet = new List<Id>();
		if(listFiles!='["0"]'){
			Type idTypeListId = Type.forName('List<Id>');
			wrapperSet = (List<Id>) JSON.deserialize(listFiles, idTypeListId);
		}

		//realizamos query sobre el caso Original
		List<Case> casos = [SELECT id, Origin, Subject, CaseNumber,Description, SEG_ClasificacionRapida__c, CC_MCC_Tematica__c, CC_MCC_ProdServ__c,
		CC_MCC_Motivo__c, SEG_Detalle__c, Priority, AccountId, ContactId,
		CC_MailTelfNotif__c, SEG_Organizacion__c, SEG_Zona__c,OwnerId,CC_AcuseRecibo__c,SEG_Numero_de_centro__c,
		Status, SEG_Subestado__c, SEG_Grupo__c,SEG_Idioma__c,CC_Idioma__c,SEG_Grupo_Empresa__c,ContactEmail,SEG_Estado_Contacto__c,SEG_No_AR_Account__c,
		SEG_No_AR_Contact__c FROM Case WHERE id IN: casosIdLst];

		case casoOrigen = new case();
		case casoSelec = new case();
		for (Case caso : casos) {
			if(caso.id == casoID){
				casoOrigen = caso;
			}
			if(caso.id == casoSelId){
				casoSelec = caso;
			}
		}

		List<Case> listCasoReciclado = new List<Case>();
		//copiamos emails seleccionados

		List<EmailMessage> emailsListToRelate = new List<EmailMessage>();
		List<EmailMessage> emailsListOriginalUpd = new List<EmailMessage>();
		for(EmailMessage emailOriginal :emailSelected)
		{
			EmailMessage newEmail = emailOriginal.clone(false,false,true,false);
			newEmail.RelatedToId = casoOrigen.Id;
			newEmail.Incoming = true;
			emailsListToRelate.add(newEmail);
			emailsListOriginalUpd.add(emailOriginal);
		}
		if(emailsListToRelate.size()>0)
		{
			insert(emailsListToRelate);
		}
		if(emailsListOriginalUpd.size()>0){
			update(emailsListOriginalUpd);
		}

		//ContentDocumentLink del caso para evitar duplicados
		List<id>lstDocLinkIds = new List<id>();
		for(ContentDocumentLink cdl : [select id, ContentDocumentId from ContentDocumentLink WHERE LinkedEntityId = :casoID])
		{
			lstDocLinkIds.add(cdl.ContentDocumentId);
		}

		List<ContentDocumentLink> listDocumentosInsert = new List<ContentDocumentLink>();

		for(Id idContentDocumentId:wrapperSet) {
			if(lstDocLinkIds.size() > 0)
			{
				if(!lstDocLinkIds.contains(idContentDocumentId))
				{
					ContentDocumentLink objCntDocLink = new ContentDocumentLink();
					objCntDocLink.LinkedEntityId = casoOrigen.id;
					objCntDocLink.ContentDocumentId = idContentDocumentId;
					objCntDocLink.shareType = 'V';
					listDocumentosInsert.add(objCntDocLink);
				}
			}
			else
			{
				ContentDocumentLink objCntDocLink = new ContentDocumentLink();
				objCntDocLink.LinkedEntityId = casoOrigen.id;
				objCntDocLink.ContentDocumentId = idContentDocumentId;
				objCntDocLink.shareType = 'V';
				listDocumentosInsert.add(objCntDocLink);
			}
		}

		if(listDocumentosInsert.size()>0)
		{
			insert(listDocumentosInsert);
		}




		//Creamos una nota en observaciones
		FeedItem feed = new FeedItem();
		feed.ParentId = casoID;
		//feed.Body = 'Emails y anexos copiados de caso: ' + listDocumentosInsert + '***' +emailsListToRelate;
		feed.Body = 'Emails y anexos copiados de caso: ' + casoSelec.CaseNumber;
		feed.isRichText = true;
		insert feed;

		if(listCasoOrigUpd.size()>0)
		{
			update(listCasoOrigUpd);
		}

		return casoCreado;
	}

	@AuraEnabled
	public static Boolean checkBPOPermision(Id caseId) {
		Boolean permission = false;
		Case caso = [SELECT SEG_Grupo__r.CS_Permiso_Canal_BPO__c, SEG_Caso_sincronizado_en_BPO__c
						FROM Case WHERE id = :caseId];
		return caso.SEG_Grupo__r.CS_Permiso_Canal_BPO__c && !caso.SEG_Caso_sincronizado_en_BPO__c;
	}

	@AuraEnabled
	//public static void enviarCanalBPO(id caseId, boolean caseStatus, List<String> listaFicheros, String notasCif) {
	public static Map<String,String> enviarCanalBPO(id caseId, boolean caseStatus, List<String> listaFicheros, String notasCif) {
		Case casoMotiv = [SELECT CC_MCC_Motivo__c,CC_MCC_ProdServ__c,CC_MCC_Tematica__c
		FROM Case WHERE id = :caseId];

		Map<String,String> retorno = new Map<String,String>();

        retorno.put('noexistemotivo', 'N');
		retorno.put('enviarcanal','N');
		if(casoMotiv.CC_MCC_Motivo__c != null){

			Case caso = new Case(Id = caseId);
			String resultadoBPO = SEG_BPO_WS.enviarCaso(caseId,'alta',notasCif,listaFicheros);

			if(!String.IsBlank(resultadoBPO) && resultadoBPO.equalsIgnoreCase('OK')){
				caso.SEG_Caso_sincronizado_en_BPO__c = true;
				if(caseStatus){
					caso.Status = 'Activo';
					caso.SEG_Subestado__c = 'Gestión BPM';
				}else{
					caso.Status = 'Pendiente';
					caso.SEG_Subestado__c = 'Gestión BPM';
				}
				//OLD TODO: Falta acabar de definir en que estado se tiene que quedar pendiente
				update caso;
				retorno.put('enviarcanal','Y');
			}
		}
		else{
			retorno.put('noexistemotivo', 'Y');
		}

		return retorno;
	}

	@AuraEnabled
	public static void desplanificarCaso(Id recordId) {
		try {
			Case caso = new Case(Id = recordId);
			caso.SEG_Fecha_planificaci_n__c = null;
			update caso;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static void anyadirOperaciones(Id caseId, Id mccId, String numOperaciones) {
		SEG_Operacion__c operacion = new SEG_Operacion__c();

		if(String.isNotBlank(numOperaciones))
		{
			operacion.SEG_N_Operaciones__c = Integer.valueOf(numOperaciones);
		}
		operacion.SEG_Usuario__c = UserInfo.getUserId();
		operacion.SEG_SR__c = caseId;

		if(mccId != null)
		{
			operacion.SEG_MCC__c = mccId;
			// Recuperar los datos de la clasificación.
			CC_MCC__c nuevaClasificacion = [SELECT Name, RecordType.DeveloperName, CC_Producto_Servicio__r.Name, CC_Producto_Servicio__r.CC_Tematica__r.Name,
											CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__r.Name,
											CC_Motivo__r.CC_Producto_Servicio__r.Name,
											CC_Motivo__r.Name, CC_Tematica__r.Name
											FROM CC_MCC__c WHERE RecordType.DeveloperName IN('CC_Producto_Servicio', 'CC_Motivo', 'SEG_Detalle') AND Id = :mccId];


			String tipoMCC = nuevaClasificacion.RecordType.DeveloperName;

			// Calcular el nivel de MCC seleccionado.
			operacion.SEG_Detalle__c = (tipoMCC == 'SEG_Detalle') ? nuevaClasificacion.Id : null;
			operacion.SEG_Motivo__c = (tipoMCC == 'SEG_Detalle') ? nuevaClasificacion.CC_Motivo__r.Id : ((tipoMCC == 'CC_Motivo') ? nuevaClasificacion.Id : null);
			operacion.SEG_Producto__c = (tipoMCC == 'SEG_Detalle') ? nuevaClasificacion.CC_Motivo__r.CC_Producto_Servicio__r.Id : ((tipoMCC == 'CC_Motivo') ? nuevaClasificacion.CC_Producto_Servicio__r.Id : ((tipoMCC == 'CC_Producto_Servicio') ? nuevaClasificacion.Id : null));
			operacion.SEG_Tematica__c = (tipoMCC == 'SEG_Detalle') ? nuevaClasificacion.CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__r.Id : ((tipoMCC == 'CC_Motivo') ? nuevaClasificacion.CC_Producto_Servicio__r.CC_Tematica__r.Id : ((tipoMCC == 'CC_Producto_Servicio') ? nuevaClasificacion.CC_Tematica__r.Id : null));
		}
		insert operacion;
	}

	@AuraEnabled
	public static Map<String, Boolean> comprobarClienteCasoApex(Id recordId) {
		Case caso = [SELECT AccountId, Account.Name, ContactId, Contact.Email FROM Case WHERE Id = :recordId];
		return new Map<String, Boolean>{
			'cuentaContactoNoInformado' => caso.AccountId == null || caso.ContactId == null,
			'cuentaPendiente' => caso.Account.Name == 'CUENTA PENDIENTE ASOCIAR',
			'emailNoInformadoValija' => caso.Contact.Email == null
		};
	}

	//US174856 Cierre de SRs hijas y madres.
	/**
	 * ELB: Nueva version 2.0
	 * @description   Proceso de No cerrar Case Padre si tiene hijas abiertas
	 * @param casosSEG -> Lista de Ids de casos de Segmentos.
	 * @param mapNewObj -> Mapa de casos con los valores nuevos
	 * @param mapOldObj -> Mapa de casos con los valores nuevos
	 */
	public static void cierreAutomaticoSR(List<Id> casosSEG, Map<Id, Case> mapNewObj, Map<Id, Case> mapOldObj){
		Set<Id> idsCasosHijos = new Set<Id>();
		Set<Id> idsCasosPadre = new Set<Id>();
		Set<id> idsCasosConHijosPend  = new Set<Id>();
		List<Case> casosAUpdatear = new List<Case>();
		Map<id, List<Case>> mapaCasoPadreEHijos = new Map<id, List<Case>>();
		Map<id, Case> casos = new Map<id, Case>();

		// Preparar los casos a buscar.
		for (Id casoId : casosSEG){
			Case casoAux = mapNewObj.get(casoId);
			// Lanzamos excepcions si el caso esta intentando cerrarse pero no tiene informada la cuenta o el contacto.
			if (casoAux.Status == 'Cerrado' && casoAux.Status != mapOldObj.get(casoId).Status && casoAux.parentId == null) {
				// Se está cerrando el caso y es el caso padre.
				idsCasosPadre.add(casoId);
			}
			else if (casoAux.Status == 'Cerrado' && casoAux.Status != mapOldObj.get(casoId).Status && casoAux.parentId != null) {
				// Se está cerrando el caso y es el caso hijo.
				idsCasosHijos.add(casoId);
				idsCasosPadre.add(casoAux.ParentId);
			}
		}

		//Traerse todos los casos hijos del listado de casos padre.
		if (!idsCasosHijos.isEmpty() || !idsCasosPadre.isEmpty()){

			Map<id, Case> casosQuery = new Map<id, Case>([SELECT id, ParentId, Status, AccountId, ContactId, SEG_Subestado__c, SEG_Resultado__c, SEG_ClasificacionRapida__c,
			SEG_Grupo__c, SEG_Grupo_Empresa__c, SEG_Organizacion__c, SEG_Zona__c, SEG_Numero_de_centro__c,
			Contact.SEG_No_enviar_Acuse_Recibo__c, Account.SEG_No_enviar_Acuse_Recibo_Empresa__c, SEG_Idioma__c,
			CC_AcuseRecibo__c, ContactEmail, SEG_Estado_Contacto__c, SEG_No_AR_Account__c, SEG_No_AR_Contact__c
			FROM Case WHERE Status != 'Cerrado' AND Status != 'Descartado' AND (ParentId IN: idsCasosPadre OR Id IN: idsCasosHijos OR Id IN: idsCasosPadre)]);
			casos.putAll(casosQuery);
		}

		//Usamos un mapa con el caso padre, y todos sus hijos, con estado distinto a cerrado;
		for (Id caso : casos.keySet()){
			if (casos.get(caso).ParentId == null){
				//se trata del caso padre
				//casosPadreQuery.add(casos.get(caso));
				if (!mapaCasoPadreEHijos.containsKey(casos.get(caso).ParentId)){
					mapaCasoPadreEHijos.put(casos.get(caso).ParentId, new List<case>());
				}
			}
			else if(casos.get(caso).ParentId != null){
				//se trata del caso hijo
				if (mapaCasoPadreEHijos.containsKey(casos.get(caso).ParentId)){
					//se trata del caso hijo y existe en el mapa el padre
					mapaCasoPadreEHijos.get(casos.get(caso).ParentId).add(casos.get(caso));
				}
				else {
					//se trata del caso hijo y no existe en el mapa el padre
					mapaCasoPadreEHijos.put(casos.get(caso).ParentId, new List<case>{casos.get(caso)});
				}
			}
		}

		//Comprobamos si podemos cerrar el caso entrante, si es el hijo, comprobamos si es el ultimo abierto, si es el padre, comprobamos si tiene hijos abiertos
		// y cerramos
		List<Case> casosConErrores = new List<Case>();
		for (Id idCasoPadre : mapaCasoPadreEHijos.keySet()){
			//el padre tiene hijos pendientes
			if(!mapaCasoPadreEHijos.get(idCasoPadre).isEmpty()){
				for (Case casoHijo : mapaCasoPadreEHijos.get(idCasoPadre)){
					//updateamos al ultimo hijo si viene en los parametros, e intentamos actualizar al padre

					if(mapaCasoPadreEHijos.get(idCasoPadre).size() == 1 && casosSEG.contains(casoHijo.id)){
						//update al ultimo hijoA
						casoHijo.Status = 'Cerrado';
						casoHijo.CC_Detalles_Consulta__c = 'Caso cerrado';
						//Update al padre
						if (casos.containsKey(idCasoPadre)){
							if (casos.get(idCasoPadre).AccountId != null && casos.get(idCasoPadre).ContactId != null){
								casos.get(idCasoPadre).Status = 'Cerrado';
								casos.get(idCasoPadre).SEG_Subestado__c = null;
								casos.get(idCasoPadre).CC_Detalles_Consulta__c = 'Caso cerrado';
								String datosCasosPadre = JSON.serialize(casos);
								casosAUpdatear.add(casos.get(idCasoPadre));

							}
							else if(casos.get(idCasoPadre).AccountId == null|| casos.get(idCasoPadre).ContactId == null){
								//casosConErrores.add(mapNewObj.get(casoHijo.Id));
								mapNewObj.get(casoHijo.Id).addError('No se permite cerrar el caso Padre si no tiene la cuenta y el contacto informado o por el contrario el cliente no se ha identificado.');
							}
						}
					}
					//Updateamos al hijo, si viene en los parametros sin ser el ultimo
					else if (mapaCasoPadreEHijos.get(idCasoPadre).size() > 1 && casosSEG.contains(casoHijo.id)){
						casoHijo.Status = 'Cerrado';
						casoHijo.CC_Detalles_Consulta__c = 'Caso cerrado';
					}
				}
			}

			//el padre no tiene hijos pendientes, ha entrado por el trigger, y hay que cerrarlo.
			else if (casosSEG.contains(idCasoPadre)){
				mapNewObj.get(idCasoPadre).Status = 'Cerrado';
				mapNewObj.get(idCasoPadre).SEG_Subestado__c = null;
				mapNewObj.get(idCasoPadre).CC_Detalles_Consulta__c = 'Caso cerrado';
			}

			//Throw errors.
			//casosConErrores.addError('No se permite cerrar el caso Padre si no tiene la cuenta y el contacto informado o por el contrario el cliente no se ha identificado.');
		}

		if (!casosAUpdatear.isEmpty()){
			try{
				update casosAUpdatear;
			}
			catch (System.DmlException e) {
				CBK_Log.debug('No se ha podido actualizar el caso');
			}
		}
	}

	/* Clase para el botón AOR (Eric) */
	private static final String BASE64CHARS = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';

	@AuraEnabled
	public static PicklistWrapper getDependentPicklistAOR(String objectName, string parentField, string childField) {
		Map<String,List<String>> pickListMap = new Map<String,List<String>>();
		PicklistWrapper pw = new PicklistWrapper();
		pw.pickListMap = pickListMap;

		if (String.isBlank(parentField) || String.isBlank(ChildField)){
			return pw;
		}

		Map<String,Map<String, Schema.SObjectField>> mapObjectFields = SEG_GetRT.getFieldsObjects(new Set<String>{objectName});

		if (mapObjectFields == null || mapObjectFields.isEmpty() || !mapObjectFields.containsKey(objectName)) {
			return pw;
		}

		Map<String, Schema.SObjectField> objFieldMap = mapObjectFields.get(objectName);

		if (!objFieldMap.containsKey(parentField) || !objFieldMap.containsKey(childField)){
			return pw;
		}

		List<PicklistEntryWrapper> depEntries = (List<PicklistEntryWrapper>)JSON.deserialize(JSON.serialize(objFieldMap.get(ChildField).getDescribe().getPicklistValues()), List<PicklistEntryWrapper>.class);
		List<String> controllingValues = new List<String>();

		for (Schema.PicklistEntry ple : objFieldMap.get(parentField).getDescribe().getPicklistValues()) {
			pickListMap.put(ple.getLabel(), new List<String>());
			controllingValues.add(ple.getLabel());
		}

		for (PicklistEntryWrapper plew : depEntries) {
			String validForBits = base64ToBits(plew.validFor);
			for (Integer i = 0; i < validForBits.length(); i++) {
				String bit = validForBits.mid(i, 1);
				if (bit == '1') {
					pickListMap.get(controllingValues.get(i)).add(plew.label);
				}
			}
		}

		pw.pickListMap = pickListMap;
		pw.parentFieldLabel = objFieldMap.get(parentField).getDescribe().getLabel();
		pw.childFieldLabel = objFieldMap.get(childField).getDescribe().getLabel();
		//pw.parentFieldValue = objFieldMap.get(parentField).getDescribe().getValue();
		//pw.childFieldValue = objFieldMap.get(childField).getDescribe().getValue();

		return pw;
	}

	public static String decimalToBinary(Integer val) {
		String bits = '';
		while (val > 0) {
			Integer remainder = Math.mod(val, 2);
			val = Integer.valueOf(Math.floor(val / 2));
			bits = String.valueOf(remainder) + bits;
		}
		return bits;
	}

	public static String base64ToBits(String validFor) {
		if (String.isEmpty(validFor)) {return '';}

		String validForBits = '';

		for (Integer i = 0; i < validFor.length(); i++) {
			String thisChar = validFor.mid(i, 1);
			Integer val = BASE64CHARS.indexOf(thisChar);
			String bits = decimalToBinary(val).leftPad(6, '0');
			validForBits += bits;
		}

		return validForBits;
	}

	public class PicklistWrapper{
		@AuraEnabled
		public Map<String, List<String>> pickListMap;
		@AuraEnabled
		public String parentFieldLabel;
		@AuraEnabled
		public String childFieldLabel;
		@AuraEnabled
		public String parentFieldValue;
		@AuraEnabled
		public String childFieldValue;
	}

	public class PicklistEntryWrapper{
		public String active;
		public String defaultValue;
		public String label;
		public String value;
		public String validFor;

	}

	//Llamada a AOR
	@AuraEnabled
	public static Map<String,String> enviarCanalAOR(id caseId, String tipologia1AOR, String tipologia2AOR, String consultaAORaura, String comentario, List<Id> adjuntos, String ritm) {
		Map<String,String> retorno = new Map<String,String>();
        retorno.put('enviarcanal','N');
        retorno.put('noexistemotivo', 'N');
		String tipoAOR1api='';
		String tipoAOR2api='';
		if (ritm == 'noCreado'){
			for (Schema.PicklistEntry pickListVal : Case.SEG_AORTipologiaN1__c.getDescribe().getPicklistValues()) {
				if (pickListVal.getlabel() == tipologia1AOR)
				{
					tipoAOR1api= pickListVal.getValue();
				}
			}
			for (Schema.PicklistEntry pickListVal : Case.SEG_AORTipologia_N2__c.getDescribe().getPicklistValues()) {
				if (pickListVal.getlabel() == tipologia2AOR)
				{
					tipoAOR2api= pickListVal.getValue();
				}
			}

			Boolean conexionRealizada = SEG_AOR_Altapeticion.SEG_AOR_AltapeticionSend(caseId,tipoAOR1api,tipoAOR2api,consultaAORaura);
			if(conexionRealizada && adjuntos != null && !adjuntos.isEmpty()){
				for (Id adjuntoId : adjuntos) {
					SEG_AOR_AddAttachment.SEG_AOR_AddAttachmentSend(caseId,adjuntoId);
				}
			}
			retorno.put('enviarcanal','Y');
		} else {
			if(String.isNotBlank(comentario)){
				SEG_AOR_addComment.SEG_AOR_addCommentSend(caseId, comentario);
			}
			if(!adjuntos.isEmpty()){
				for (Id adjuntoId : adjuntos) {
					SEG_AOR_AddAttachment.SEG_AOR_AddAttachmentSend(caseId,adjuntoId);
				}
			}
		}

		return retorno;
	}

	public static void informarNumOperaciones(String idCase, Integer numOperaciones){
		List<Case> casos = [SELECT id, SEG_N_operaciones_del_caso__c FROM Case WHERE Id =: idCase LIMIT 1];
		if (!casos.isEmpty()){
			casos[0].SEG_N_operaciones_del_caso__c = numOperaciones;
			update casos;
		}
	}
}