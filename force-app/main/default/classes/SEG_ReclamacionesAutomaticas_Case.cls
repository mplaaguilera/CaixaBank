/**
 *   @description SEG_ReclamacionesAutomaticas_Case
*/
public with Sharing class SEG_ReclamacionesAutomaticas_Case {

	public static Set<Id> casosConError = new Set<Id>();
	public static List<Case> casosUpd = new List<Case>();

	private static Map<String, String> mapLangFields = new Map<String, String> {
		'ga' => 'SEG_PlantillaGalegoID__c',
		'ca' => 'SEG_PlantillaCatalanID__c',
		'en' => 'SEG_PlantillaInglesID__c',
		'eu' => 'SEG_PlantillaEuskeraID__c',
		'es' => 'SEG_PlantillaCastellanoID__c'
	};
	private static Map<String, String> mapPlantillaFields = new Map<String, String> {
		'1ª Reclamación' => 'SEG_Fecha_1a_Reclamacion_Proceso__c',
		'2ª Reclamación' => 'SEG_Fecha_2a_Reclamacion_Proceso__c',
		'3ª Reclamación' => 'SEG_Fecha_3a_Reclamacion_Proceso__c',
		'Reclamaciones Agotadas' => 'SEG_Fecha_Envio_Gestor_Proceso__c'
	};

	public class CaseWrapper
	{
		Case cs { get; set; }
		Contact cliente { get; set; }
		List<String> colaboradores { get; set; }
		Map<String, ContractWrapper> contractWrapperMap { get; set; }
	}
	
	public class ContractWrapper
	{
		List<SEG_Contratos__c> lstContractos { get; set; }
		Map<Id,Account> mapaContratoCuenta { get; set; }
		Map<Id,Contact> mapaContratoContact { get; set; }
		String plantillaIdioma { get; set; }
		List<Messaging.EmailFileAttachment> attachments { get; set; }
		List<ContentVersion> contentVersionData {get; set; }
	}

	public class EmailWrapper
	{
		String plantillaIdioma { get; set; }
		String caseId { get; set; }
		Contact contacto {get;set;}
		String colabEmail {get;set;}
		List<SEG_Contratos__c> listaContratos {get;set;}
		List<Messaging.EmailFileAttachment> attachments {get;set;}
		List<ContentVersion> contentVersionData {get; set; }
		Map<String,String> mapaBuzonesOrgaZona {get;set;}
	}
    
    public void procesarCasos(set<String> setCaseId) {
        try{
            Date todayDate = date.today();
            list<SEG_Contratos__c> scope =[SELECT Id, CreatedById, CreatedDate, Name, OwnerId, LastModifiedById,SEG_1a_Reclamacion_ejecutada_manualmente__c, 
                                            SEG_2a_Reclamacion_ejecutada_manualmente__c, SEG_3a_Reclamacion_ejecutada_manualmente__c, SEG_Centro__c, SEG_CIF__c,
                                            SEG_Descripcion__c, SEG_Estado__c, SEG_Fecha_1_Reclamacion__c,SEG_Fecha_1a_Reclamacion_Proceso__c,
                                            SEG_Fecha_2_Reclamacion__c, SEG_Fecha_2a_Reclamacion_Proceso__c,SEG_Fecha_3_Reclamacion__c, SEG_Fecha_3a_Reclamacion_Proceso__c, 
                                            SEG_Fecha_Contrato__c, SEG_Fecha_Envio_Gestor__c, SEG_Fecha_Envio_Gestor_Proceso__c, SEG_Fecha_Firma__c, 
                                            SEG_Fecha_Parada_Reclamacion__c,SEG_Fecha_Recepcion_Original__c, SEG_Gestor_comercial__c, SEG_Idioma__c, 
                                            SEG_Motivo_No_Reclamacion__c,SEG_NombreCliente__c, 
                                            SEG_NombreCuenta__r.SEG_Prioridad_Carterizacion_Segmentos__c, SEG_NombreCuenta__r.SEG_Empleado_gestor_Segmentos__c, SEG_NombreCuenta__r.CC_EmpleadoGestorId__c,
                                            SEG_NombreCuenta__r.SEG_GestorOperativaNacional__c,SEG_NombreCuenta__c, SEG_NombreCuenta__r.SEG_GestorOperativaInternacional__c,SEG_NombreCuenta__r.SEG_GestorFinEstructurada__c, 
                                            SEG_NombreCuenta__r.CC_OficinaGestoraId__r.CC_Numero_Oficina__c, 
                                            SEG_NombreCliente__r.FirstName,SEG_NombreCliente__r.LastName, SEG_NombreCliente__r.Name, SEG_NombreCliente__r.CC_Idioma__c,SEG_NombreCliente__r.Email,
                                            SEG_Situacion_Contrato__c, SEG_SR_Seguimiento__c, SEG_SROriginal__c, SEG_Zona__c,SEG_SR_Seguimiento__r.Status,SEG_SR_Seguimiento__r.ContactId,SEG_SR_Seguimiento__r.AccountId,
                                            SEG_SR_Seguimiento__r.SEG_Organizacion__c,SEG_SR_Seguimiento__r.SEG_Zona__c,SEG_SR_Seguimiento__r.SEG_Grupo__c,SEG_SR_Seguimiento__r.SEG_Grupo_Empresa__c,
                                            SEG_SR_Seguimiento__r.SEG_ClasificacionRapida__c,SEG_SR_Seguimiento__r.CC_MCC_Motivo__c,SEG_SR_Seguimiento__r.CC_MCC_ProdServ__c,
                                            SEG_SR_Seguimiento__r.CC_MCC_Tematica__c,SEG_SR_Seguimiento__r.SEG_Numero_de_centro__c,SEG_SR_Seguimiento__r.SEG_Detalle__c, SEG_SR_Seguimiento__r.SEG_Reclamacion_Fallida__c 
                                            FROM SEG_Contratos__c 
                                            WHERE SEG_SR_Seguimiento__c = :setCaseId
                                            AND SEG_Estado__c = 'No firmado' AND SEG_SR_Seguimiento__r.Status = 'Cerrado' AND SEG_NombreCuenta__c != null AND SEG_NombreCliente__c != null 
                                            AND SEG_SR_Seguimiento__r.SEG_Grupo__c != null
                                            AND ((SEG_Fecha_1_Reclamacion__c <= TODAY AND SEG_1a_Reclamacion_ejecutada_manualmente__c = false AND SEG_Fecha_1a_Reclamacion_Proceso__c = null)
                                            OR (SEG_Fecha_2_Reclamacion__c <= TODAY AND SEG_2a_Reclamacion_ejecutada_manualmente__c = false AND SEG_Fecha_2a_Reclamacion_Proceso__c = null)
                                            OR (SEG_Fecha_3_Reclamacion__c <= TODAY AND SEG_3a_Reclamacion_ejecutada_manualmente__c = false AND SEG_Fecha_3a_Reclamacion_Proceso__c = null)
                                            OR (SEG_Fecha_Envio_Gestor__c <= TODAY))
                                            ORDER BY SEG_SR_Seguimiento__c DESC];
            if (scope.isEmpty()) {
                return;
            }
            // Indicar el número de registros a tratar en el lote.
            //Modificador para deshabilitar eltrigger
            SEG_Modificadores_Trigger.activarModificador('SEG_EmailMessage_AI_TRHan: bypass');
            //SEG_Modificadores_Trigger.activarModificador('AV_Task_BI_TRHan: bypass');
            Map<Id, SEG_Contratos__c> mapContratosUpd = new Map<Id, SEG_Contratos__c> ();
            List<FeedItem> lstFeedsInsert = new List<FeedItem> ();
            Map<Id, CaseWrapper> mapCaseContracts = new Map<Id, CaseWrapper> ();
            Map<Id, Id> mapCaseIdContactId = new Map<Id, Id> ();
            for (SEG_Contratos__c contrato : scope) {
                //Rellenamos mapa con primeras reclamaciones
                if (contrato.SEG_Fecha_1_Reclamacion__c <= todayDate && contrato.SEG_Fecha_1a_Reclamacion_Proceso__c == null) {
                    fillContractMap('1ª Reclamación', mapCaseContracts, contrato);
                }
                //Rellenamos mapa con segundas reclamaciones
                if (contrato.SEG_Fecha_2_Reclamacion__c <= todayDate && contrato.SEG_Fecha_2a_Reclamacion_Proceso__c == null) {
                    fillContractMap('2ª Reclamación', mapCaseContracts, contrato);
                }
                //Rellenamos mapa con terceras reclamaciones
                if (contrato.SEG_Fecha_3_Reclamacion__c <= todayDate && contrato.SEG_Fecha_3a_Reclamacion_Proceso__c == null) {
                    fillContractMap('3ª Reclamación', mapCaseContracts, contrato);
                }
                //Rellenamos mapa con reclamaciones agotadas
                if (contrato.SEG_Fecha_Envio_Gestor__c <= todayDate && contrato.SEG_Fecha_Envio_Gestor_Proceso__c == null) {
                    fillContractMap('Reclamaciones Agotadas', mapCaseContracts, contrato);
                }
                if (!mapCaseIdContactId.containsKey(contrato.SEG_SR_Seguimiento__c)) {
                    mapCaseIdContactId.put(contrato.SEG_SR_Seguimiento__c, contrato.SEG_SR_Seguimiento__r.ContactId);
                } else {
                    handlePostChatterbyContract(lstFeedsInsert, contrato, 'PreConditionFailed', null);
					if(!casosConError.contains(contrato.SEG_SR_Seguimiento__c)){
						Case csSegumiento = new Case();
						csSegumiento.id = contrato.SEG_SR_Seguimiento__c;
						csSegumiento.SEG_Reclamacion_Fallida__c = true;
						casosConError.add(contrato.SEG_SR_Seguimiento__c);
						casosUpd.add(csSegumiento);
					}
                }
            }

            //Map<Id, Case> mapCases = new Map<Id, Case> ();
            Map<String, List<SEG_Contratos__c>> mapContractsOk = new Map<String, List<SEG_Contratos__c>> ();
            //rellenamos el mapa de datos en cada metodo
            if (!mapCaseContracts.isEmpty()) {
                //Rellenamos el CaseWrapper con el contacto del contrato si coincide con el del caso.
                fillContactsMap(mapCaseIdContactId, mapCaseContracts);
                //Rellenamos el ContractWrapper con la plantilla para cada tipo de reclamacion.
                fillTemplates(mapCaseContracts);
                //Rellenamos el contractWrapper con el listado de id's de los adjuntos
                fillAttachments(mapCaseContracts);
                fillColaboradores(mapCaseContracts);
                mapContractsOk = sendEmailsContracts(mapCaseContracts, lstFeedsInsert);
            }

            //Actualizar fields Proceso de los contratos con la fecha de procesado
            updateResultados(mapContractsOk, mapContratosUpd,lstFeedsInsert);

			for(SEG_Contratos__c contrato : scope){
				if(contrato.SEG_SR_Seguimiento__r.SEG_Reclamacion_Fallida__c && (casosConError.isEmpty() || (!casosConError.isEmpty() && !casosConError.contains(contrato.SEG_SR_Seguimiento__c)))){
					Case csSegumiento = new Case();
					csSegumiento.id = contrato.SEG_SR_Seguimiento__c;
					csSegumiento.SEG_Reclamacion_Fallida__c = false;
					casosConError.add(contrato.SEG_SR_Seguimiento__c);
					casosUpd.add(csSegumiento);
				}
			}

			if(!casosUpd.isEmpty()){
				// revisar si esto es true o false
				// pasar a lista casosConError
				Database.update(casosUpd, false);
			}
        } catch (Exception e) {
            CBK_Log.error(String.valueOf(setCaseId),e);
        }
    }

	private void updateResultados(Map<String, List<SEG_Contratos__c>> mapContractsOk, Map<Id, SEG_Contratos__c> mapContratosUpd, List<FeedItem> lstFeedsInsert) {
        Date todayDate = date.today();
        //Actualizar fields Proceso de los contratos con la fecha de procesado
		for (string plantila : mapContractsOk.keySet()) {
			for (SEG_Contratos__c c : mapContractsOk.get(plantila)) {
				if (mapContratosUpd.containsKey(c.Id)) {
					mapContratosUpd.get(c.Id).put(mapPlantillaFields.get(plantila), todayDate);
				} else {
					c.put(mapPlantillaFields.get(plantila), todayDate);
					mapContratosUpd.put(c.Id, c);
				}
				if (mapContratosUpd.get(c.Id).SEG_Fecha_1a_Reclamacion_Proceso__c != null
					&& mapContratosUpd.get(c.Id).SEG_Fecha_2a_Reclamacion_Proceso__c != null
					&& mapContratosUpd.get(c.Id).SEG_Fecha_3a_Reclamacion_Proceso__c != null
					&& mapContratosUpd.get(c.Id).SEG_Fecha_Envio_Gestor__c != null)
				{
					mapContratosUpd.get(c.Id).SEG_Estado__c = 'Reclamaciones agotadas';
				}
			}
		}
		//DML Operations
		//if (mapContratosUpd.size() > 0 || lstFeedsInsert.size() > 0 || mapCases.values().size() > 0){
			if (mapContratosUpd.size() > 0 || lstFeedsInsert.size() > 0){    
			// Actualizar los datos del caso, donde aligeramos la ejecución del trigger.
			SEG_Case_BU_TRHan.procesado = true;
			SEG_Modificadores_Trigger.desactivarModificador('SEG_Case_BU_TRHan: reejecutar lógica');
			SEG_Modificadores_Trigger.activarModificador('SEG_Case_AU_TRHan: bypass');
		}
		
		if (!mapContratosUpd.isEmpty()) {
			List<Database.SaveResult> updateResults = CBK_DMLUtility.updateRecords(mapContratosUpd.values(), false);
		}

		if (!lstFeedsInsert.isEmpty()) {
			Database.insert(lstFeedsInsert, false);
		}
    }

	private Map<String, List<SEG_Contratos__c>> sendEmailsContracts(Map<Id, CaseWrapper> mapCaseContracts, List<FeedItem> lstFeedsInsert) {
		Map<String, List<SEG_Contratos__c>> mapContractsOk = new Map<String, List<SEG_Contratos__c>> ();
		Contact cliente;
		List<String> colaboradores;
		ContractWrapper contractW;
		Boolean sendOk;
		List<SEG_Contratos__c> lstContr;
		// Recuperar la configuración de los OWA de contratos.
		Map<String,String> mapaBuzonesOrgZona = SEG_MetodosComunes.recuperarOWASegmentos();
		List<EmailWrapper> datosEnviosEmailsAgotadas = new List<EmailWrapper>();
		List<EmailWrapper> datosEnviosEmailsNoAgotadas = new List<EmailWrapper>();
		for (Id caseId : mapCaseContracts.KeySet()) {
			cliente = mapCaseContracts.get(caseId).cliente;
			colaboradores = mapCaseContracts.get(caseId).colaboradores;
			for (String plantilla : mapCaseContracts.get(caseId).contractWrapperMap.keySet()) {
				contractW = mapCaseContracts.get(caseId).contractWrapperMap.get(plantilla);
				lstContr = contractW.lstContractos;
				sendOk = false;
				if ((String.isNotEmpty(contractW.plantillaIdioma))||(plantilla == 'Reclamaciones agotadas')) {

                    if (plantilla != 'Reclamaciones agotadas') {
						EmailWrapper datosEnvioMail = new EmailWrapper();
						datosEnvioMail.plantillaIdioma = contractW.plantillaIdioma;
						datosEnvioMail.caseId = caseId;
						datosEnvioMail.contacto= cliente;
						datosEnvioMail.listaContratos = new List<SEG_Contratos__c>();
						datosEnvioMail.listaContratos.addall(lstContr);
						datosEnvioMail.contentVersionData = new List<contentVersion>();
						datosEnvioMail.contentVersionData.addall(contractW.contentVersionData);
						datosEnvioMail.mapaBuzonesOrgaZona = mapaBuzonesOrgZona;
						datosEnviosEmailsNoAgotadas.add(datosEnvioMail);	
                    } else {
						if(!casosConError.contains(caseId)){
							Case csSegumiento = new Case();
							csSegumiento.id = caseId;
							csSegumiento.SEG_Reclamacion_Fallida__c = true;
							casosConError.add(caseId);
							casosUpd.add(csSegumiento);
						}
                    }
					if (mapContractsOk.containsKey(plantilla)) {
						mapContractsOk.get(plantilla).addAll(lstContr);
					} else {
						mapContractsOk.put(plantilla, new List<SEG_Contratos__c> (lstContr));
					}
				}
				else {
					Boolean fallido = false;
					for (SEG_Contratos__c c : lstContr) {
						handlePostChatterbyContract(lstFeedsInsert, c, 'TemplateNotFound', plantilla);
						fallido = true;
					}

					if(fallido && !casosConError.contains(caseId)){
						Case csSegumiento = new Case();
						csSegumiento.id = caseId;
						csSegumiento.SEG_Reclamacion_Fallida__c = true;
						casosConError.add(caseId);						
						casosUpd.add(csSegumiento);
					}
				}
			}
		}

		if (!datosEnviosEmailsAgotadas.isEmpty()) {		
			enviarCorreoContratos(datosEnviosEmailsAgotadas);	
		}
		
		if (!datosEnviosEmailsNoAgotadas.isEmpty()){
			enviarCorreoContratos(datosEnviosEmailsNoAgotadas);
		}
        
		return mapContractsOk;
	}
	private void fillColaboradores(Map<Id, CaseWrapper> mapCaseContracts) {
		Set<Id> setGrupos = new Set<Id> ();
		Set<Id> users = new Set<Id> ();
		Map<Id,String> mapContacts = new Map<Id,String> ();
		Map<Id, List<Id>> mapGrupoCase = new Map<Id, List<Id>> ();
		for (CaseWrapper cw : mapCaseContracts.values()) {
			if (cw.contractWrapperMap.containsKey('Reclamaciones Agotadas')) {
				setGrupos.add(cw.cs.SEG_Grupo__c);
				if (mapGrupoCase.containsKey(cw.cs.SEG_Grupo__c)) {
					mapGrupoCase.get(cw.cs.SEG_Grupo__c).add(cw.cs.Id);
				} else {
					mapGrupoCase.put(cw.cs.SEG_Grupo__c, new List<Id> { cw.cs.Id });
				}
			}
		}
		
		if (setGrupos.size() > 0) {
			Map<Id, List<Id>> mapUserCases = new Map<Id, List<Id>> ();
			List<CC_Grupo_Colaborador_Contact__c> lstGContacts = [SELECT CC_Contacto__c, CC_Grupo_Colaborador__c, CC_Email__C
			                                                      FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Grupo_Colaborador__c IN :setGrupos AND CC_Contacto__c != null];
			for (CC_Grupo_Colaborador_Contact__c gc : lstGContacts) {
				mapContacts.put(gc.CC_Contacto__c, gc.CC_Email__C);
				for (Id caseId : mapGrupoCase.get(gc.CC_Grupo_Colaborador__c)) {
					if (mapUserCases.containsKey(gc.CC_Contacto__c)) {
						mapUserCases.get(gc.CC_Contacto__c).add(caseId);
					} else {
						mapUserCases.put(gc.CC_Contacto__c, new List<Id> { caseId });
					}
				}
			}
			//List<Contact> lstContacts = [SELECT id, Email, OwnerId FROM Contact WHERE OwnerId IN :users];
			Map<Id, List<String>> mapCaseContacts = new Map<Id, List<String>> ();
			for (Id contact : mapContacts.keySet()) {
				for (Id csId : mapUserCases.get(contact)) {
					if (mapCaseContacts.containsKey(csId)) {
						mapCaseContacts.get(csId).add(mapContacts.get(contact));
					} else {
						mapCaseContacts.put(csId, new List<String> { mapContacts.get(contact) });
					}
				}
			}
			for (CaseWrapper cw : mapCaseContracts.values()) {
				if (cw.contractWrapperMap.containsKey('Reclamaciones Agotadas')) {
					cw.colaboradores = mapCaseContacts.get(cw.cs.Id);
				}
			}
		}
	}



	private void fillAttachments(Map<Id, CaseWrapper> mapCaseContracts) {
		//Generamos una set con las id's de todos los contratos a reclamar.
		Set<Id> setContractId = new Set<Id> ();
		for (CaseWrapper cw : mapCaseContracts.values()) {
			for (ContractWrapper contractW : cw.contractWrapperMap.values()) {
				for (SEG_Contratos__c cont : contractW.lstContractos) {
					setContractId.add(cont.Id);
				}
			}
		}
		//Llamamos al metodo para recuperar los adjuntos de los contratos
		Map<Id, List<ContentVersion>> wrapperDatos = SEG_MetodosComunes.getAttachmentsFromObject(setContractId, 'and SEG_Firmado__c = false');
		
		//Rellenamos el contractWrapper con los id's de los adjuntos
		for (CaseWrapper cw : mapCaseContracts.values()) {
			for (ContractWrapper contractW : cw.contractWrapperMap.values()) {
				contractW.contentVersionData = new List<ContentVersion>();
				for (SEG_Contratos__c cont : contractW.lstContractos) {
					if (wrapperDatos.containsKey(cont.Id)) {
						contractW.contentVersionData.addAll(wrapperDatos.get(cont.Id));
					}
				}
			}
		}
	}
	private void fillTemplates(Map<Id, CaseWrapper> mapCaseContracts) {
		//Rellenamos el ContractWrapper con la plantilla para cada tipo de reclamacion.

		/*mapPlantillas = new Map<Id, SEG_Plantilla__c> ([SELECT id, SEG_Organizacion__c, SEG_Zona__c, SEG_Activa__c,
		                                               SEG_PlantillaCastellanoID__c, SEG_PlantillaCatalanID__c, SEG_PlantillaEuskeraID__c, SEG_PlantillaGalegoID__c,
		                                               SEG_PlantillaInglesID__c, SEG_TipoOperativa__c, Reclamaciones__c, SEG_Resultado__c FROM SEG_Plantilla__c
		                                               WHERE SEG_TipoOperativa__c = 'Reclamaciones' AND Reclamaciones__c IN('1ª Reclamación', '2ª Reclamación', '3ª Reclamación', 'Reclamaciones Agotadas')
		                                               AND SEG_Activa__c = true]);*/

		List<String> lstOrganizacion;
		List<String> lstZona;
		String lang;
		Map<Id, SEG_Plantilla__c> mapPlantByCaseRecla = new Map<Id, SEG_Plantilla__c> ();
		for (CaseWrapper caseW : mapCaseContracts.Values()){
			Map<Id, SEG_Plantilla__c> mapPlantillas = SEG_MetodosComunes.determinarPlantillaExclusiva(caseW.cs, 'Reclamaciones');
			lang = caseW.cliente.CC_Idioma__c;
			ContractWrapper contractW;
			for (String reclamacion : caseW.contractWrapperMap.keySet()) {
				contractW = caseW.contractWrapperMap.get(reclamacion);
				mapPlantByCaseRecla = new Map<Id, SEG_Plantilla__c> ();
				//filtrar plantillas por caso, tipo reclamacion, Organizacion y Zona
				for (SEG_Plantilla__c plantilla : mapPlantillas.Values()) {
					lstOrganizacion = null;
					lstZona = null;
					if (plantilla.SEG_Organizacion__c != null) {
						lstOrganizacion = plantilla.SEG_Organizacion__c.split(';');
					}
					if (plantilla.SEG_Zona__c != null) {
						lstZona = plantilla.SEG_Zona__c.split(';');
					}

					if (plantilla.Reclamaciones__c == reclamacion && lstOrganizacion != null && lstOrganizacion.contains(caseW.cs.SEG_Organizacion__c) && (lstZona == null || lstZona.contains(caseW.cs.SEG_Zona__c))) {
						mapPlantByCaseRecla.put(plantilla.Id, plantilla);
					}
				}

				if (mapPlantByCaseRecla.size() > 0) {
					String field = lang != null && mapLangFields.containsKey(lang) ? mapLangFields.get(lang) : 'SEG_PlantillaCastellanoID__c';
					contractW.plantillaIdioma = (String) mapPlantByCaseRecla.values() [0].get(field);
				}
			}
		}
	}

	private void fillContactsMap(Map<Id, Id> mapCaseIdContactId, Map<Id, CaseWrapper> mapCaseContracts) {
		//Rellenamos el caseWrapper con el contacto del contato si coincide con el del caso.
		for (CaseWrapper cw : mapCaseContracts.values()) {
			for (ContractWrapper contW : cw.contractWrapperMap.Values()){
				for(Id cliente : contw.mapaContratoContact.keyset()){
					for (Id caseId : mapCaseIdContactId.KeySet()) {
						if (mapCaseContracts.containsKey(caseId) && mapCaseContracts.get(caseId).cliente == null) {
							mapCaseContracts.get(caseId).cliente = contw.mapaContratoContact.get(cliente);
						}
					}
				}
			}		
		}
	}

	private void fillContractMap(String nRecl, Map<Id, CaseWrapper> mapCaseContracts, SEG_Contratos__c contratos) {
		if (mapCaseContracts.containsKey(contratos.SEG_SR_Seguimiento__c) && mapCaseContracts.get(contratos.SEG_SR_Seguimiento__c).contractWrapperMap.containsKey(nRecl)) {
			mapCaseContracts.get(contratos.SEG_SR_Seguimiento__c).contractWrapperMap.get(nRecl).lstContractos.add(contratos);
		}
		else {
            Account cuenta = new Account();
            ContractWrapper contractW = new ContractWrapper();
            contractW.lstContractos = new List<SEG_Contratos__c> { contratos };
            contractW.MapaContratoCuenta = new Map<Id, Account>();
            contractW.mapaContratoContact = new Map<Id, Contact>();
            Contact contacto = new Contact();

            //Cuenta del contrato
            if(contratos.SEG_NombreCuenta__r != null){	
                cuenta.id = contratos.SEG_NombreCuenta__c;	
                if (contratos.SEG_NombreCuenta__r.SEG_Prioridad_Carterizacion_Segmentos__c != null)  {cuenta.SEG_Prioridad_Carterizacion_Segmentos__c = contratos.SEG_NombreCuenta__r.SEG_Prioridad_Carterizacion_Segmentos__c;}
                if (contratos.SEG_NombreCuenta__r.SEG_Empleado_gestor_Segmentos__c!= null)  {cuenta.SEG_Empleado_gestor_Segmentos__c = contratos.SEG_NombreCuenta__r.SEG_Empleado_gestor_Segmentos__c;}
                if (contratos.SEG_NombreCuenta__r.CC_EmpleadoGestorId__c != null)  {cuenta.CC_EmpleadoGestorId__c = contratos.SEG_NombreCuenta__r.CC_EmpleadoGestorId__c;}
                if (contratos.SEG_NombreCuenta__r.SEG_GestorOperativaNacional__c != null)  {cuenta.SEG_GestorOperativaNacional__c = contratos.SEG_NombreCuenta__r.SEG_GestorOperativaNacional__c;}
                if (contratos.SEG_NombreCuenta__r.SEG_GestorOperativaInternacional__c != null)  {cuenta.SEG_GestorOperativaInternacional__c = contratos.SEG_NombreCuenta__r.SEG_GestorOperativaInternacional__c;}
                if (contratos.SEG_NombreCuenta__r.SEG_GestorFinEstructurada__c != null)  {cuenta.SEG_GestorFinEstructurada__c = contratos.SEG_NombreCuenta__r.SEG_GestorFinEstructurada__c;}
        
                if (contratos.SEG_NombreCuenta__r.CC_OficinaGestoraId__r != null)  {cuenta.CC_OficinaGestoraId__r = contratos.SEG_NombreCuenta__r.CC_OficinaGestoraId__r;}
                if (cuenta != null) {contractW.mapaContratoCuenta.put(contratos.Id, cuenta);}
            }

            if (!mapCaseContracts.containsKey(contratos.SEG_SR_Seguimiento__c)) {

                CaseWrapper caseW = new CaseWrapper();
                caseW.cs = new Case();
                caseW.cs.Id = contratos.SEG_SR_Seguimiento__c;
                caseW.cs.SEG_Zona__c = contratos.SEG_SR_Seguimiento__r.SEG_Zona__c;
                caseW.cs.SEG_Organizacion__c = contratos.SEG_SR_Seguimiento__r.SEG_Organizacion__c;
                caseW.cs.SEG_Numero_de_centro__c = contratos.SEG_SR_Seguimiento__r.SEG_Numero_de_centro__c;
                caseW.cs.AccountId = contratos.SEG_SR_Seguimiento__r.AccountId;
                caseW.cs.SEG_Detalle__c = contratos.SEG_SR_Seguimiento__r.SEG_Detalle__c;
                caseW.cs.CC_MCC_Motivo__c = contratos.SEG_SR_Seguimiento__r.CC_MCC_Motivo__c;
                caseW.cs.CC_MCC_ProdServ__c = contratos.SEG_SR_Seguimiento__r.CC_MCC_ProdServ__c;
                caseW.cs.CC_MCC_Tematica__c = contratos.SEG_SR_Seguimiento__r.CC_MCC_Tematica__c;
                caseW.cs.SEG_ClasificacionRapida__c = contratos.SEG_SR_Seguimiento__r.SEG_ClasificacionRapida__c;
                caseW.cs.SEG_Grupo__c = contratos.SEG_SR_Seguimiento__r.SEG_Grupo__c;
                
                //Cliente del contrato
                if (contratos.SEG_NombreCliente__c != null) {
                    contacto.Id = contratos.SEG_NombreCliente__c;
                    if (contratos.SEG_NombreCliente__r.FirstName != null) {contacto.FirstName = contratos.SEG_NombreCliente__r.FirstName;}
                    if (contratos.SEG_NombreCliente__r.LastName != null) {contacto.LastName = contratos.SEG_NombreCliente__r.LastName;}
                    if (contratos.SEG_NombreCliente__r.CC_Idioma__c != null) {contacto.CC_Idioma__c = contratos.SEG_NombreCliente__r.CC_Idioma__c;}
                    if (contratos.SEG_NombreCliente__r.Email != null) {contacto.Email = contratos.SEG_NombreCliente__r.Email;}
                    if (contacto != null){ contractW.mapaContratoContact.put(contratos.Id, contacto); }
                }
                
                caseW.contractWrapperMap = new Map<String, ContractWrapper> ();
                caseW.contractWrapperMap.put(nRecl, contractW);
                mapCaseContracts.put(contratos.SEG_SR_Seguimiento__c, caseW);
            }
            else {
                //Cliente del contrato
                if (contratos.SEG_NombreCliente__c != null) {
                    contacto.Id = contratos.SEG_NombreCliente__c;
                    if (contratos.SEG_NombreCliente__r.FirstName != null) {contacto.FirstName = contratos.SEG_NombreCliente__r.FirstName;}
                    if (contratos.SEG_NombreCliente__r.LastName != null) {contacto.LastName = contratos.SEG_NombreCliente__r.LastName;}
                    if (contratos.SEG_NombreCliente__r.CC_Idioma__c != null) {contacto.CC_Idioma__c = contratos.SEG_NombreCliente__r.CC_Idioma__c;}
                    if (contratos.SEG_NombreCliente__r.Email != null) {contacto.Email = contratos.SEG_NombreCliente__r.Email;}
                    if (contacto != null){ contractW.mapaContratoContact.put(contratos.Id, contacto); }
                }
                mapCaseContracts.get(contratos.SEG_SR_Seguimiento__c).contractWrapperMap.put(nRecl, contractW);
            }
        }
	}

	private void handlePostChatterbyContract(List<FeedItem> lstFeedsInsert, SEG_Contratos__c c, String keyMessage, string plantilla)
	{
		String message = getMessageChatter(c, keyMessage, plantilla);
		if (String.isNotEmpty(message)) {
			FeedItem feed = new FeedItem();
			feed.ParentId = c.SEG_SR_Seguimiento__c;
			feed.Body = message;
			lstFeedsInsert.add(feed);
		}
		
	}

	private string getMessageChatter(SEG_Contratos__c co, String keyMessage, string plantilla)
	{

		if (keyMessage == 'TemplateNotFound') {
			return 'Reclamación Contrato nº ' + co.Name + ': No se ha encontrado la plantilla: ' + plantilla + ', por esa razón no se ha enviado el mail.\n';
		}
		if (keyMessage == 'PreConditionFailed' && co.SEG_Estado__c != 'No firmado') {
			return 'Reclamación Contrato nº ' + co.Name + ': El contrato está en estado \'' + co.SEG_Estado__c + '\' por esa razón no se ha realizado la reclamación.\n';
		}
		else if (keyMessage == 'PreConditionFailed' && co.SEG_SR_Seguimiento__r.Status != 'Cerrado') {
			return 'Reclamación Contrato nº ' + co.Name + ': La SR está en estado \'' + co.SEG_SR_Seguimiento__r.Status + '\' por esa razón no se ha realizado la reclamación.\n';
		}
		return null;
	}

	private void handlePostChatterListbyContract(List<FeedItem> lstFeedsInsert, List<SEG_Contratos__c> lstContratos, string caseId) {
		FeedItem feed = new FeedItem();
		feed.ParentId = caseId;
		feed.Body = getMessageChatterByList(lstContratos);
		feed.Type = 'TextPost';
		lstFeedsInsert.add(feed);
	}

	private string getMessageChatterByList(List<SEG_Contratos__c> lstContratos) {
		string mssg = 'Reclamación Contrato: Realizar la LLAMADA de reclamación';
		mssg += lstContratos.size() > 1 ? ' de los contratos:\n' : ' del contrato:\n';
		for (SEG_Contratos__c c : lstContratos) {
			mssg += c.Name + '\n';
		}
		return mssg;
	}

	//private void enviarCorreoContratos(String plantillaIdioma, String caseId, Contact contacto, List<SEG_Contratos__c> lstContr, List<Messaging.EmailFileAttachment> attachments, Map<String,String> mapaBuzonesOrgZona)
	private void enviarCorreoContratos(List<EmailWrapper> listadoDatos)	{
		List<String> numbero = new List<String>();
		List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
		Map<Id, String> mapaCasoSubject = new Map<Id,String>();
		Map<Id, String> mapaCasoOWA = new Map<Id,String>();
		Map<Id,List<Id>> mapaCasoContents = new Map<Id,List<Id>>();
		List<SEG_Contratos__c> contratosSinEmail = new List<SEG_Contratos__c>();
		
		for (EmailWrapper datos : listadoDatos) {
			if (String.isNotBlank(datos.contacto.Email) || String.IsNotBlank(datos.colabEmail)){
				// Determinar el OWA de envío.
				String claveBuzon = 'N/A';
				if (datos.listaContratos != null && !datos.listaContratos.isEmpty()){
					// Nos quedamos con los datos del primer contrato, obtenemos la Org y Zona del caso vinculado de seguimiento.
					SEG_Contratos__c primerContrato = datos.listaContratos[0];
					claveBuzon = primerContrato?.SEG_SR_Seguimiento__r?.SEG_Organizacion__c + '##' + primerContrato?.SEG_SR_Seguimiento__r?.SEG_Zona__c;
				}
				String owaSalienteId = String.isNotBlank(datos.mapaBuzonesOrgaZona.get(claveBuzon)) ? datos.mapaBuzonesOrgaZona.get(claveBuzon) : datos.mapaBuzonesOrgaZona.get('Por defecto##Por defecto');

				List<String> address = new List<String> ();
				if(datos.contacto != null){
					address.add(datos.contacto.Email);
				}
				else if (datos.colabEmail != null){
					address.add(datos.colabEmail);
				}
				
				Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
				Messaging.SingleEmailMessage messageRendered = Messaging.renderStoredEmailTemplate(datos.plantillaIdioma, datos.contacto.Id, datos.caseId);

				String subject = messageRendered.getSubject();
				String body = messageRendered.getHtmlBody();
				String[] aBody = body ?.split('</tr>', 2);

				if (aBody.size() == 2) {
					String tableRowsHtml = '';
					for (SEG_Contratos__c c : datos.listaContratos) {
						tableRowsHtml += '<tr><td>' + (String.isNotBlank(c.Name) ? c.Name : '') + '</td><td>' + (c.SEG_Fecha_Contrato__c != null ? c.SEG_Fecha_Contrato__c.format() : '')
						+ '</td><td>' + (String.isNotBlank(c.SEG_Descripcion__c) ? c.SEG_Descripcion__c : '') + '</td></tr>';
					}
					body = aBody[0] + '</tr>' + tableRowsHtml + aBody[1];
				}
				if (!datos.contentVersionData.isEmpty()) {
					List<Id> contentVersIds = new List<Id>();
					for (ContentVersion content : datos.contentVersionData) {
						contentVersIds.add(content.id);
					}
					message.setEntityAttachments(contentVersIds);
					mapaCasoContents.put(datos.caseId, contentVersIds);
				}
				message.setSubject(subject);
				message.setToAddresses(address);
				message.setOrgWideEmailAddressId(owaSalienteId);
				message.setUseSignature(false);
				message.setBccSender(false);
				message.setSaveAsActivity(true);
				message.setWhatId(datos.caseId);
				message.setHtmlBody(body);
    			messages.add(message);
                
			} else {
				for (SEG_Contratos__c contrato : datos.listaContratos){
					contratosSinEmail.add(contrato);
				}
			}
		}

		if(!messages.isEmpty()){
			//Messaging.SendEmailResult[] results = Messaging.sendEmail(messages, false);
            //Cambiamos de false a true. para forzar Rollback(Los emails son del mismo caso)  
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(messages, true);
			// Vincular los ficheros con el email enviado.
			if (results != null && !results.isEmpty() && results[0].isSuccess() == true){				
				linkAttachmentsToEmail(mapaCasoContents);
			} else{
				// Error enviando el correo.
				for (Messaging.SendEmailResult resultado : results) {
					if (!resultado.isSuccess()) {
						CBK_Log.addError('SEG Reclamaciones Emails', null, 'Send Email result: ' + resultado.getErrors(), results,null);
					}
				}
                CBK_Log.insertDML();
			}
		} 
		
		if(!contratosSinEmail.isEmpty()){
			List<FeedItem> lstFeedsInsert= new List<FeedItem>();
			for (SEG_Contratos__c contrato : contratosSinEmail){
				String message = 'Reclamación Contrato - El contacto de la reclamacion: ' + contrato.Name + ' no tiene email assignado. No se ha podido mandar la reclamacion';
				FeedItem feed = new FeedItem();
				feed.ParentId = contrato.SEG_SR_Seguimiento__c;
				feed.Body = message;
				lstFeedsInsert.add(feed);
			}
			insert lstFeedsInsert;
		}
	}

	//Relacionamos los anexos salientes al email saliente para que se muestren en la previsualización de emails posteriormente
    public static void linkAttachmentsToEmail(Map<Id,List<Id>> mapaCasoContents){
        List<EMailMessage> emailAUpdatear = new List<EMailMessage>();
        Map<Id, List<ContentDocumentLink>> casosLink = new Map<Id, List<ContentDocumentLink>>();
        List<Case> casosConMails = [SELECT id, (SELECT Id, HasAttachment, ParentId, SEG_HasAnexo__c FROM EmailMessages WHERE Incoming = FALSE ORDER BY createdDate DESC LIMIT 1) 
                                    FROM case WHERE Id IN: mapaCasoContents.keySet() ORDER BY createdDate DESC LIMIT 20];
        Map<Id,EmailMessage> casosConEmails = new Map<Id,EmailMessage>();
        for (Case casos : casosConMails){
            if(!casos.EmailMessages.isEmpty()){
                casosConEmails.put(casos.Id, casos.EmailMessages);
            }
        }
        for (Id casoId : casosConEmails.keySet()){
            if (casosConEmails.get(casoId).HasAttachment == true) {
                casosConEmails.get(casoId).SEG_HasAnexo__c = true;
                emailAUpdatear.add(casosConEmails.get(casoId));
            }
        }
    
        if(!emailAUpdatear.isEmpty()){
            update emailAUpdatear;
        }
    }
}