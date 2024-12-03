/**
 *   @description SEG_Case_AU_TRHan 
*/
public with sharing class SEG_Case_AU_TRHan extends CC_TriggerHandlerBase {

	private static Id recordTypeSEG;
	private static Id recordTypeSeguimiento;
	private static Id recordTypeGruposCaso;
	private static String recordTypeCaixaBank;

	public override void mainEntry(CC_TriggerParameters tp) {
		// Bypass del trigger para operaciones rápidas de actualización del caso.
		if (SEG_Modificadores_Trigger.modificadorActivo('SEG_Case_AU_TRHan: bypass')) {
			return;
		}
		// Quedarnos solo con los registros de segmentos.
		List<Id> casosSegmentos = new List<Id> ();
		List<Id> casosSeguimiento = new List<Id> ();
		List<Id> allCasesSEG = new List<Id> ();

		Set<String> objetos = new Set<String>{'Case','SEG_Grupos_por_caso__c','Account'};
		Map<String,Map<String,Schema.RecordTypeInfo>> rtObjetos = SEG_GetRT.getRecordTypesObjects(objetos);
		recordTypeSEG = rtObjetos.get('Case').get('SEG_Cliente').getRecordTypeId();
		recordTypeSeguimiento = rtObjetos.get('Case').get('SEG_Seguimiento').getRecordTypeId();
		recordTypeGruposCaso = rtObjetos.get('SEG_Grupos_por_caso__c').get('SEG_GruposPorCaso').getRecordTypeId();
		recordTypeCaixaBank = rtObjetos.get('Account').get('CC_CentroCaixaBank').getRecordTypeId();

		/* Queda deprecada la obtención de RT por rendimiento
		Id recordTypeSEG = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
		Id recordTypeSeguimiento = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId();
		*/

		for (Case caso : (List<Case>) tp.newList) {
			if (caso.RecordTypeId == recordTypeSEG) {
				casosSegmentos.add(caso.Id);
			} else if (caso.RecordTypeId == recordTypeSeguimiento) {
				casosSeguimiento.add(caso.Id);
			}
		}

		if (casosSegmentos.size() > 0 || casosSeguimiento.size() > 0) {
			// Preparar la lista completa de los TODOS los casos de segmentos.
			allCasesSEG.addAll(casosSeguimiento);
			allCasesSEG.addAll(casosSegmentos);
			process(allCasesSEG, casosSeguimiento, casosSegmentos, (Map<Id, Case>) tp.newMap, (Map<Id, Case>) tp.oldMap);
		}
	}
	/**
	 * @description   Proceso de negocio del trigger.
	 * @param casosSEG -> Lista de Ids de casos de Segmentos.
	 * @param mapNewObj -> Mapa de casos con los valores nuevos
	 * @param mapOldObj -> Mapa de casos con los valores nuevos
	 */
	private void process(List<Id> allCasesSEG, List<Id> casosSeguimiento, List<Id> casosSEG, Map<Id, Case> mapNewObj, Map<Id, Case> mapOldObj)
	{
		List<Id> casosCambioOwner = new List<Id>();
		for (Id casoId : allCasesSEG) {
			if (mapNewObj.get(casoId).OwnerId != mapOldObj.get(casoId).OwnerId){
				casosCambioOwner.add(casoId);
			}
		}

		if(!casosCambioOwner.isEmpty()){
			crearFotoFacturacion(casosSeguimiento, casosSEG, mapNewObj, mapOldObj);
			actualizarPropietarioGrupoAnterior(casosSEG, mapNewObj, mapOldObj);
		} else{
			actualizarFotoFacturacion(casosSeguimiento, casosSEG, mapNewObj, mapOldObj);
			actualizarNumeroCentro(allCasesSEG, mapNewObj, mapOldObj);
			checkExcepciones(casosSEG, casosSeguimiento, mapNewObj, mapOldObj);
			if (casosSeguimiento.size() > 0 ) {
				actualizacionContactoSeguimiento(mapNewObj, mapOldObj, casosSeguimiento); //US617709 - Eric - Actualización contactos de contratos desde caso de seguimiento
			}

			//Actualizar campo fusion semilla en caso de merge de cases
			addSemillaToMasterrecord(allCasesSEG, mapNewObj, mapOldObj);			
			//Actualizar campos fecha de planificación
			addFechaPlanificacion(allCasesSEG, mapNewObj, mapOldObj);
			insertarMarcas(allCasesSEG, mapNewObj, mapOldObj);
		}
		insertarDatosChatter(allCasesSEG, mapNewObj, mapOldObj); // US820562 - Chatter - Incluir información del 1r contactocuenta informado en el caso
		conexionTaskConnect(allCasesSEG, mapNewObj, mapOldObj); //US697153 - Metodo para realizar la conexión con TaskConect para los casos identificados como tales cuando se modifique alguno de los siguientes campos: Grupo, Estado, Subestado, Prioridad, SLA, Propietario.
	}

	private void actualizarFotoFacturacion(List<Id> casosSeguimiento, List<Id> casosSEG, Map<Id, Case> mapNewObj, Map<Id, Case> mapOldObj) {
		List<Id> allCasesSEG = new List<Id> ();
		allCasesSEG.addAll(casosSeguimiento);
		allCasesSEG.addAll(casosSEG);
		List<String> lstFieldsChange = new List<String> { 'SEG_Organizacion__c', 'SEG_Zona__c', 'CC_MCC_Tematica__c',
			'CC_MCC_ProdServ__c', 'SEG_Grupo__c' };
		Set<Id> caseIds = new Set<Id> ();
		Boolean caseAdded;
		Integer count;
		for (Id caseId : allCasesSEG) {
			caseAdded = false;
			count = 0;
			while (lstFieldsChange.size() > count && !caseAdded) {
				if (mapNewObj.get(caseId).get(lstFieldsChange[count]) != mapOldObj.get(caseId).get(lstFieldsChange[count])) {
					caseIds.add(caseId);
					caseAdded = true;
				}
				++ count;
			}
		}
		if (caseIds.size() > 0) {
			List<SEG_Fotosdefacturacion__c> lstFF = [Select Id, SEG_Operativa__c From SEG_Fotosdefacturacion__c Where SEG_Estado__c = 'A determinar' and SEG_NumeroSR__c IN :caseIds];
			List<Id> lstFFGrupo = new List<Id> ();
			List<Id> lstFFMCC = new List<Id> ();
			List<Id> lstFFMarca = new List<Id> ();
			for (SEG_Fotosdefacturacion__c ff : lstFF) {
				if (ff.SEG_Operativa__c == SEG_FotoFacturacionHandler.Operativa.MCC.name()) {
					lstFFMCC.add(ff.Id);
				} else if (ff.SEG_Operativa__c == SEG_FotoFacturacionHandler.Operativa.Grupo.name()) {
					lstFFGrupo.add(ff.Id);
				} else if (ff.SEG_Operativa__c == SEG_FotoFacturacionHandler.Operativa.Marca.name()) {
					lstFFMarca.add(ff.Id);
				}

			}
			if (lstFFMarca.size() > 0) {
				SEG_FotoFacturacionHandler ffHandler = new SEG_FotoFacturacionHandler(SEG_FotoFacturacionHandler.Operativa.Marca, lstFFMarca);
				if (Limits.getQueueableJobs() != Limits.getLimitQueueableJobs()) {
					ffHandler.updateFF();
				} else {
					System.enqueueJob(ffHandler);
				}
			}
			if (lstFFGrupo.size() > 0) {
				SEG_FotoFacturacionHandler ffHandler = new SEG_FotoFacturacionHandler(SEG_FotoFacturacionHandler.Operativa.Grupo, lstFFGrupo);
				if (Limits.getQueueableJobs() != Limits.getLimitQueueableJobs()) {
					ffHandler.updateFF();
				} else {
					System.enqueueJob(ffHandler);
				}
			}
			if (lstFFMCC.size() > 0) {
				SEG_FotoFacturacionHandler ffHandler = new SEG_FotoFacturacionHandler(SEG_FotoFacturacionHandler.Operativa.MCC, lstFFMCC);
				if (Limits.getQueueableJobs() != Limits.getLimitQueueableJobs()) {
					ffHandler.updateFF();
				} else {
					System.enqueueJob(ffHandler);
				}
			}
		}
	}
	private void crearFotoFacturacion(List<Id> casosSeguimiento, List<Id> casosSEG, Map<Id, Case> mapNewObj, Map<Id, Case> mapOldObj) {
		List<Id> allCasesSEG = new List<Id> ();
		allCasesSEG.addAll(casosSeguimiento);
		allCasesSEG.addAll(casosSEG);
		List<Id> lstCaseFFGrupo = new List<Id> ();
		for (Id caseId : allCasesSEG) {
			if (mapNewObj.get(caseId).OwnerId != mapOldObj.get(caseId).OwnerId) {
				lstCaseFFGrupo.add(caseId);
			}
		}

		if (lstCaseFFGrupo.size() > 0) {
			SEG_FotoFacturacionHandler ffHandler = new SEG_FotoFacturacionHandler(lstCaseFFGrupo, SEG_FotoFacturacionHandler.Operativa.Grupo);
			if (Limits.getQueueableJobs() != Limits.getLimitQueueableJobs()) {
				ffHandler.createFF();
			} else {
				System.enqueueJob(ffHandler);
			}
		}
	}

	/**
	* @description Método para indicar el propietario anterior de un caso cuando se mantiene dentro del mismo grupo.
	* @param casosSEG Lista de Ids de los casos
	* @param mapNewObj Mapa de casos nuevos
	* @param mapOldObj Mapa de casos viejos
	*/
	private void actualizarPropietarioGrupoAnterior(List<Id> casosSEG, Map<Id, Case> mapNewObj, Map<Id, Case> mapOldObj) {
		
		List<Id> casosOwnerModificado = new List<Id>();
		/* Queda deprecada la obtención de RT por rendimiento
		Id recordTypeGruposCaso = Schema.SObjectType.SEG_Grupos_por_caso__c.getRecordTypeInfosByDeveloperName().get('SEG_GruposPorCaso').getRecordTypeId();
		*/
		Map<Id, List<SEG_Grupos_por_caso__c>> agrupadosCaso = new Map<Id, List<SEG_Grupos_por_caso__c>>();
		List<SEG_Grupos_por_caso__c> listaInsertar = new List<SEG_Grupos_por_caso__c>();
		List<SEG_Grupos_por_caso__c> listaUpdatear = new List<SEG_Grupos_por_caso__c>();
		Boolean controlGrupo;

		for (Id casoId : casosSEG){
			controlGrupo = false;
			if (mapNewObj.containsKey(casoId) && mapOldObj.containsKey(casoId)){
				//Si se modifica el propietario sin cambiar de grupo y tanto el nuevo propietario como viejo son usuarios se indicará el propietario viejo en el campo "Propietario anterior del grupo" 
				if (mapNewObj.get(casoId).OwnerId != mapOldObj.get(casoId).OwnerId 
				&& mapNewObj.get(casoId).SEG_Grupo__c == mapOldObj.get(casoId).SEG_Grupo__c 
				&& mapOldObj.get(casoId).OwnerId.getSobjectType() == Schema.getGlobalDescribe().get('User')){					
					casosOwnerModificado.add(casoId);
				}
			}
		}

		if (!casosOwnerModificado.isEmpty()) {
			List<SEG_Grupos_por_caso__c> gruposPorCaso = [SELECT Id, SEG_caseId__c, SEG_GrupoId__c, SEG_PropAnteriorGrupo__c, SEG_PropAnteriorGrupo__r.Name 
			FROM SEG_Grupos_por_caso__C 
			WHERE RecordTypeId = :recordTypeGruposCaso AND SEG_CaseId__c IN :casosOwnerModificado];

			for (SEG_Grupos_por_caso__c gruposCaso : gruposPorCaso) {
				if (agrupadosCaso.containsKey(gruposCaso.SEG_caseId__c)) {
					agrupadosCaso.get(gruposCaso.SEG_caseId__c).add(gruposCaso);
				} else {
					agrupadosCaso.put(gruposCaso.SEG_caseId__c, new List<SEG_grupos_por_caso__c>{gruposCaso});
				}
			}

			for (Id casoIdModificado : casosOwnerModificado) {
				if(agrupadosCaso.containsKey(casoIdModificado)){
					for (SEG_Grupos_por_caso__c grupoCasos : agrupadosCaso.get(casoIdModificado)) {
						if (mapNewObj.get(casoIdModificado).SEG_Grupo__c == grupocasos.SEG_GrupoId__c) {
							grupoCasos.SEG_PropAnteriorGrupo__c = mapOldObj.get(casoIdModificado).OwnerId;
							listaUpdatear.add(grupoCasos);
							controlGrupo = true;
						}
					}
				}

				if (!controlGrupo) {
					SEG_Grupos_por_caso__c grupoCasoNuevo = new SEG_grupos_por_caso__c();
					grupoCasoNuevo.SEG_GrupoId__c = mapNewObj.get(casoIdModificado).SEG_Grupo__c;
					grupoCasoNuevo.SEG_CaseId__c = casoIdModificado;
					grupocasoNuevo.SEG_PropAnteriorGrupo__c = mapOldObj.get(casoIdModificado).OwnerId;
					listaInsertar.add(grupoCasoNuevo);
				}

				//Si no lo encuentra lo crea y lo añade agrupadosCaso
				if (!agrupadosCaso.containsKey(casoIdModificado) && !controlGrupo) {
					SEG_Grupos_por_caso__c grupoCasoNuevo = new SEG_grupos_por_caso__c();
					grupoCasoNuevo.SEG_GrupoId__c = mapNewObj.get(casoIdModificado).SEG_Grupo__c;
					grupoCasoNuevo.SEG_CaseId__c = casoIdModificado;
					grupocasoNuevo.SEG_PropAnteriorGrupo__c = mapOldObj.get(casoIdModificado).OwnerId;
					listaInsertar.add(grupoCasoNuevo);

					if (agrupadosCaso.containsKey(casoIdModificado)) {
						agrupadosCaso.get(casoIdModificado).add(grupoCasoNuevo);
					} else {
						agrupadosCaso.put(casoIdModificado, new List<SEG_grupos_por_caso__c>{grupoCasoNuevo});
					}
				}
			}
	
			if (!listaInsertar.isEmpty()) {
				insert listaInsertar;
			}
	
			if (!listaUpdatear.isEmpty()) {
				update listaUpdatear;
			}
		}
	}

	private void actualizarNumeroCentro(List<Id> casosSEG, Map<Id, Case> mapNewObj, Map<Id, Case> mapOldObj)
	{
		Map<Id, Account> mapAcc = new Map<Id, Account>();
		Set<Id> accountId = new Set<Id> ();

		for (Id casoId : casosSEG)
		{
			// Recuperar las cuentas que han cambiado en los casos.
			if (mapNewObj.get(casoId).AccountId <> mapOldObj.get(casoId).AccountId && mapNewObj.get(casoId).AccountId != null)
			{
				accountId.add(mapNewObj.get(casoId).AccountId);
			}
		}

		if (accountId != null && !accountId.isEmpty())
		{
			mapAcc = new Map<Id, Account> ([SELECT Id, SEG_Organizacion__c,SEG_Zona__c, RecordTypeId, Name, CC_Numero_Oficina__c, SEG_N_centro__c,CC_Numero_Documento__c,
		                                                SEG_Oficina_Gestora_Segmentos__c, SEG_Oficina_Gestora_Segmentos__r.CC_Numero_Oficina__c,SEG_Prioridad_Carterizacion_Segmentos__c,
														SEG_Oficina_Gestora_Segmentos__r.SEG_Zona__c,SEG_Oficina_Gestora_Segmentos__r.SEG_Organizacion__c,
														AV_OficinaPrincipal__c,AV_OficinaPrincipal__r.CC_Numero_Oficina__c
		                                                FROM Account where Id IN :accountId]);
		}

		/* Queda deprecada la obtención de RT por rendimiento
		String recordTypeCaixaBank = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
		*/
		List<Case> lstCase = new List<Case> ();
		for (Id casoId : casosSEG)
		{
			// Preparar el caso para actualizar.
			Boolean bActualizar = false;
			Case cs = new Case();
			cs.Id = casoId;

			if (mapNewObj.get(casoId).AccountId<> mapOldObj.get(casoId).AccountId)
			{
				ID nuevaCuentaId = mapNewObj.get(casoId)?.AccountId;

				if (nuevaCuentaId == null)
				{
					// Blanquear el número de centro.
					cs.SEG_Numero_centro__c = '';
					cs.SEG_Numero_de_centro__c = null;
				}else if (mapAcc.containsKey(nuevaCuentaId))
				{
					// Evaluar la nueva cuenta.
					Account ac = mapAcc.get(nuevaCuentaId);
					if (ac.CC_Numero_Oficina__c != null && ac.RecordTypeId == recordTypeCaixaBank) {
						cs.SEG_Numero_de_centro__c = ac.Id;
						cs.SEG_Numero_centro__c = ac.CC_Numero_Oficina__c;
						cs.CC_Numero_Documento__c = ac.CC_Numero_Documento__c;
					}else if (ac.SEG_Oficina_Gestora_Segmentos__c != null && ac.SEG_Prioridad_Carterizacion_Segmentos__c) {

						cs.SEG_Numero_centro__c = ac.SEG_Oficina_Gestora_Segmentos__r.CC_Numero_Oficina__c;
						cs.SEG_Numero_de_centro__c = ac.SEG_Oficina_Gestora_Segmentos__c;
						cs.CC_Numero_Documento__c = ac.CC_Numero_Documento__c;
						
					}else if (ac.AV_OficinaPrincipal__c != null && !ac.SEG_Prioridad_Carterizacion_Segmentos__c) {
						cs.SEG_Numero_centro__c = ac.AV_OficinaPrincipal__r.CC_Numero_Oficina__c;
						cs.SEG_Numero_de_centro__c = ac.AV_OficinaPrincipal__c;
						cs.CC_Numero_Documento__c = ac.CC_Numero_Documento__c;
					}
					else {
						cs.SEG_Numero_centro__c = ac.SEG_N_centro__c;
					}
				}else{
					// Control adicional, no deberá entrar nunca dado que el caso si tiene cuenta la encontrará siempre.
					cs.SEG_Numero_centro__c = '';
				}

				// Añadir a la lista para actualizar.
				lstCase.add(cs);
			}
		}

		// Actualizar el caso.
		if (lstCase.size() > 0) {
			update lstCase;
		}
	}


	//VFR: 09/11/2021 Método para revisar las excepciones del caso cuando se modifican los campos
	private void checkExcepciones(List<Id> casosSEG, List<Id> casosSeguimiento, Map<Id, Case> mapNewObj, Map<Id, Case> mapOldObj) {
		/*
		String now = '';
		Id recordAsig = Schema.SObjectType.SEG_Excepciones__c.getRecordTypeInfosByDeveloperName().get('SEG_Asignacion').getRecordTypeId();
		Id recordText = Schema.SObjectType.SEG_Excepciones__c.getRecordTypeInfosByDeveloperName().get('SEG_Texto').getRecordTypeId();
		String userId = UserInfo.getUserId();
		*/

		List<SEG_Excepciones_Caso__c> lstExCase = new List<SEG_Excepciones_Caso__c> ();
		List<SEG_Excepciones__c> lstExcepcionesTexto = new List<SEG_Excepciones__c>();

        // Bulkify datos excepciones.
        Set<Id> listaCasosExcepciones = new Set<Id>();
        for (Id casoId : casosSEG)
        {
			if (mapNewObj.get(casoId).SEG_Organizacion__c <> mapOldObj.get(casoId).SEG_Organizacion__c || mapNewObj.get(casoId).SEG_Zona__c <> mapOldObj.get(casoId).SEG_Zona__c || 
				mapNewObj.get(casoId).SEG_ClasificacionRapida__c <> mapOldObj.get(casoId).SEG_ClasificacionRapida__c || mapNewObj.get(casoId).SEG_Grupo__c <> mapOldObj.get(casoId).SEG_Grupo__c ||
				mapNewObj.get(casoId).AccountId <> mapOldObj.get(casoId).AccountId || mapNewObj.get(casoId).SEG_Numero_de_centro__c <> mapOldObj.get(casoId).SEG_Numero_de_centro__c) {
                    listaCasosExcepciones.add(casoId);
            }
        }

		// Tratar los casos de seguimiento.
		Set<Id> setCasosSeguimientos = new Set<Id>();
        for (Id casoId : casosSeguimiento)
        {
			if (mapNewObj.get(casoId).SEG_Organizacion__c <> mapOldObj.get(casoId).SEG_Organizacion__c || mapNewObj.get(casoId).SEG_Zona__c <> mapOldObj.get(casoId).SEG_Zona__c || 
				mapNewObj.get(casoId).SEG_ClasificacionRapida__c <> mapOldObj.get(casoId).SEG_ClasificacionRapida__c || mapNewObj.get(casoId).SEG_Grupo__c <> mapOldObj.get(casoId).SEG_Grupo__c ||
				mapNewObj.get(casoId).AccountId <> mapOldObj.get(casoId).AccountId || mapNewObj.get(casoId).SEG_Numero_de_centro__c <> mapOldObj.get(casoId).SEG_Numero_de_centro__c) {
                    listaCasosExcepciones.add(casoId);
					setCasosSeguimientos.add(casoId);
            }
        }

		// Buscar los contratos asociados a los casos de seguimiento para evaluar sus excepciones.
		Set<Id> listaContratosExcepciones = new Set<Id>();
		if (!setCasosSeguimientos.isEmpty())
		{
			for (SEG_Contratos__c contrato : [SELECT Id FROM SEG_Contratos__c WHERE SEG_SR_Seguimiento__c IN :setCasosSeguimientos])
			{
				listaContratosExcepciones.add(contrato.Id);
			}
		}


        // Gestionar las excepciones de los casos.
        if (!listaCasosExcepciones.isEmpty())
        {
			List<Id> listaCasosEvaluar = new List<Id>(listaCasosExcepciones);
			List<Id> listaContratosEvaluar = new List<Id>(listaContratosExcepciones);
			SEG_ExcepcionesHandler.calcularExcepcionesCasosYContratos(2, listaCasosEvaluar, true, listaContratosEvaluar);
        }
	}

	/**
	 * @description   Actualizar campo Fusión semilla SEG_Fusion_Semilla1__c en el caso de que haya un merge de cuentas para poder recibir las comunicaciones en el caso master
	 * @param casosSEG -> Lista de Ids de casos de Segmentos.
	 * @param mapNewObj -> Mapa de casos con los valores nuevos
	 * @param mapOldObj -> Mapa de casos con los valores nuevos
	*/
	private void addSemillaToMasterrecord(List<Id> casosSEG, Map<Id, Case> mapNewObj, Map<Id, Case> mapOldObj)
	{
		Set<Id> mastercaseId = new Set<Id> ();
		Map<Id,String> mapaCasosSemilla = new Map<Id,String>();
		for (Id casoId : casosSEG)
		{
			if (mapNewObj.get(casoId).MasterRecordId != null && mapNewObj.get(casoId).MasterRecordId<> mapOldObj.get(casoId).MasterRecordId) {
				String semilla = mapNewObj.get(casoId).SEG_SemillaId__c;
				mastercaseId.add(mapNewObj.get(casoId).MasterRecordId);
				if (String.isNotBlank(semilla))
				{
					mapaCasosSemilla.put(mapNewObj.get(casoId).MasterRecordId, semilla);
				}
			}
		}

		if (!mapaCasosSemilla.isEmpty())
		{
			String semilla = JSON.serialize(mapaCasosSemilla);
			updateMasterCseFuture(mastercaseId, semilla);
		}

		/*
		String semilla;
		Set<Id> mastercaseId = new Set<Id> ();
		for (Id casoId : casosSEG)
		{
			System.debug('New semilla: ' + mapNewObj.get(casoId).MasterRecordId);
			System.debug('Old semilla: ' + mapOldObj.get(casoId).MasterRecordId);
			if (mapNewObj.get(casoId).MasterRecordId != null && mapNewObj.get(casoId).MasterRecordId<> mapOldObj.get(casoId).MasterRecordId) {
				semilla = mapNewObj.get(casoId).SEG_SemillaId__c;
				mastercaseId.add(mapNewObj.get(casoId).MasterRecordId);
			}
			System.debug('Semilla: ' + semilla);
		}

		if (String.isNotBlank(semilla)) {
			updateMasterCseFuture(mastercaseId, semilla);
		}*/
	}

	/**
	 * @description  Tiene que estar con anotación future porque al hacer merge de cases incurrimos en recursividad no permitida dentro del contexto del trigger. 
	 * @param mastercaseId
	 * @param semilla
	*/
	@future
	public static void updateMasterCseFuture(Set<Id> mastercaseId, String semilla)
	{
		// Deserializar los datos del campo semilla.
		if (String.isNotBlank(semilla))
		{
			Map<Id,String> mapaCasosSemilla = (Map<Id,String>)JSON.deserialize(semilla, Map<Id,String>.class);
			List<Case> caseMasterLst = new List<Case> ();
			List<Case> csLstMaster = [SELECT Id, Status, SEG_Subestado__c, SEG_Fusion_Semilla1__c From Case where Id IN :mastercaseId];
			for (Case caseMaster : csLstMaster)
			{
				String nuevaSemilla = mapaCasosSemilla.get(caseMaster.Id);
				if (String.isNotBlank(nuevaSemilla))
				{
					if (caseMaster.SEG_Fusion_Semilla1__c != null) {
						caseMaster.SEG_Fusion_Semilla1__c = caseMaster.SEG_Fusion_Semilla1__c + ', ' + nuevaSemilla;
					}
					else {
						caseMaster.SEG_Fusion_Semilla1__c = nuevaSemilla;
					}
					caseMasterLst.add(caseMaster);
				}
			}
	
			Database.update(caseMasterLst);
		}

		/*
		List<Case> caseMasterLst = new List<Case> ();
		List<Case> csLstMaster = [SELECT Id, Status, SEG_Subestado__c, SEG_Fusion_Semilla1__c From Case where Id IN :mastercaseId];
		for (Case caseMaster : csLstMaster) {
			if (caseMaster.SEG_Fusion_Semilla1__c != null) {
				caseMaster.SEG_Fusion_Semilla1__c = caseMaster.SEG_Fusion_Semilla1__c + ', ' + semilla;
			}
			else {
				caseMaster.SEG_Fusion_Semilla1__c = semilla;
			}
			caseMasterLst.add(caseMaster);
		}

		Database.update(caseMasterLst);
		*/
	}

	private void addFechaPlanificacion(List<Id> allCasesSEG, Map<Id, Case> mapNewObj, Map<Id, Case> mapOldObj) {

		String estadoCase;
		String subestadoCase;
		List<Case> lstCaseUpd = new List<Case>();
		List<CBK_SCH_PendingProcess__c> lstSchedule = new List<CBK_SCH_PendingProcess__c>();
		List<CBK_SCH_PendingProcess__c> lstScheduleUpdt = new List<CBK_SCH_PendingProcess__c>();
		List<CBK_SCH_PendingProcess__c> lstScheduleDel = new List<CBK_SCH_PendingProcess__c>();
		List<Id> casosPlanificar = new List<Id>();
		List<Id> casosDesPlanificar = new List<Id>();
		List<Id> casosTotalesPlanif = new List<Id>();
		Map<Id, CBK_SCH_PendingProcess__c> mapCasosProcesos = new Map<Id, CBK_SCH_PendingProcess__c>();

		for (Id casoId : allCasesSEG) {
			if (mapNewObj.get(casoId).SEG_Fecha_planificaci_n__c <> mapOldObj.get(casoId).SEG_Fecha_planificaci_n__c) {
				if(mapNewObj.get(casoId).SEG_Fecha_planificaci_n__c != null){
					casosPlanificar.add(casoId);
				} else {
					//DS1315 - Se controla si se ha desplanificado un caso para evitar que salte la desplanificación.
					casosDesPlanificar.add(casoId);
				}
			}
		}

		if (!casosPlanificar.isEmpty()) {
			casosTotalesPlanif.addAll(casosPlanificar);
		}
		
		if (!casosDesPlanificar.isEmpty()) {
			casosTotalesPlanif.addAll(casosDesPlanificar);
		}

		if(casosTotalesPlanif != null && !casosTotalesPlanif.isEmpty()){
			//DS1315 - Se añade una comprobación para actualizar los procesos ya exitentes de planificación y evitar que salten antes de tiempo.
			List<CBK_SCH_PendingProcess__c> procesosExistentes = [SELECT Id, Schedule_Time__c, RecordId__c FROM CBK_SCH_PendingProcess__c WHERE RecordId__c IN :casosTotalesPlanif AND Queued__c = false];
			for (CBK_SCH_PendingProcess__c procesoExistente : procesosExistentes) {
				mapCasosProcesos.put(procesoExistente.RecordId__c, procesoExistente);
			}
		}

		for (Id casoId : casosPlanificar) {
			estadoCase = '';
			subestadoCase = '';
			if (mapNewObj.get(casoId).SEG_Fecha_planificaci_n__c != null && mapNewObj.get(casoId).SEG_Fecha_planificaci_n__c <> mapOldObj.get(casoId).SEG_Fecha_planificaci_n__c) {
				estadoCase = 'Planificado';
				/* US847769 - Planificación- No modificar el subestado del caso
				if(mapOldObj.get(casoId).SEG_Subestado__c != 'Envío planificación Cliente' && mapOldObj.get(casoId).SEG_Subestado__c != 'Envío planificación Gestor' 
				&& mapOldObj.get(casoId).SEG_Subestado__c != 'Envío planificación Colaborador' && mapOldObj.get(casoId).SEG_Subestado__c != 'Envío planificación Colaborador WS'
				&& mapOldObj.get(casoId).SEG_Subestado__c != 'Envío planificación otros'){
					
					subestadoCase = 'Planificado manualmente';
				}
				*/

				//Datos para el batch
				//DS1315 - Se añade una comprobación para actualizar los procesos ya exitentes de planificación y evitar que salten antes de tiempo.
				if(mapCasosProcesos != null && mapCasosProcesos.containsKey(casoId)){
					CBK_SCH_PendingProcess__c procesoActualizar = mapCasosProcesos.get(casoId);
					procesoActualizar.Schedule_Time__c = mapNewObj.get(casoId).SEG_Fecha_planificaci_n__c;
					lstScheduleUpdt.add(procesoActualizar);
				} else {
					lstSchedule.add(new CBK_SCH_PendingProcess__c(Schedule_Time__c= mapNewObj.get(casoId).SEG_Fecha_planificaci_n__c,
					ClassName__c = 'SEG_SchedulePlanificacion', RecordId__c = casoId));
				}
			}
			if(String.isNotBlank(estadoCase) && String.isNotBlank(subestadoCase)){
				lstCaseUpd.add(new Case(Id= casoId, Status = estadoCase, SEG_Subestado__c = subestadoCase));
			}else if(String.isNotBlank(estadoCase) && String.isBlank(subestadoCase)){
				lstCaseUpd.add(new Case(Id= casoId, Status = estadoCase));
			}
		}

		//DS1315 - Se controla si se ha desplanificado un caso para evitar que salte la desplanificación.
		for (Id casoId : casosDesPlanificar) {
			if(mapCasosProcesos != null && mapCasosProcesos.containsKey(casoId)){
				CBK_SCH_PendingProcess__c procesoActualizar = mapCasosProcesos.get(casoId);
				lstScheduleDel.add(procesoActualizar);
			}
		}

		if(lstSchedule.size()>0){
			insert lstSchedule; 
		}
		if(lstCaseUpd.size()>0){
			update lstCaseUpd;
		}
		//DS1315 - Actualización de procesos automáticos encolados.
		if (!lstScheduleUpdt.isEmpty()) {
			update lstScheduleUpdt;
		}
		//DS1315 - Eliminar planificaciones canceladas
		if (!lstScheduleDel.isEmpty()) {
			delete lstScheduleDel;
		}
	}

	public static void insertarMarcas(List<Id> casosSEG, Map<Id, Case> mapNewObj, Map<Id,Case> mapOldObj){
		String flag = 'CaseAU';
		List<Id> lstIdCasosMarcas = new List<Id>();
		for (Id casoComprobar : casosSEG) {
			if((mapNewObj.get(casoComprobar).CC_MCC_Motivo__c != null && mapNewObj.get(casoComprobar).CC_MCC_Motivo__c != mapOldObj.get(casoComprobar).CC_MCC_Motivo__c) ||
			(mapNewObj.get(casoComprobar).SEG_Detalle__c != null && mapNewObj.get(casoComprobar).SEG_Detalle__c != mapOldObj.get(casoComprobar).SEG_Detalle__c)){
				lstIdCasosMarcas.add(casoComprobar);
			}
		}

        if (!lstIdCasosMarcas.isEmpty()) {
            SEG_Case_Utilities.insertarMarcas(lstIdCasosMarcas, mapNewObj, mapOldObj , flag);
        }
	}

	/** Eric - US617709 - Actualización automática de contactos de contratos desde el caso de seguimiento */
	public static void actualizacionContactoSeguimiento(Map<Id, Case> mapNewObj, Map<Id,Case> mapOldObj, List<Id> casosSeguimiento){

		List<SEG_Contratos__c> lstContratoUpd = new List<SEG_Contratos__c>();
		List<Id> casosModificados = new List<Id>();

		// Se recorren los casos de Seguimiento donde han sido modificados los Contactos y se guardan
		for (Id comprobarContacto : casosSeguimiento) {
			if(mapNewObj.get(comprobarContacto).ContactId != mapOldObj.get(comprobarContacto).ContactId && mapNewObj.get(comprobarContacto).ContactId != null){
				casosModificados.add(comprobarContacto);
			}
		}

		if (!casosModificados.isEmpty()) {
			// Saco la información de los Contratos de los Casos de Seguimiento que hayan sido modificado
			List<SEG_Contratos__c> lstContratosCaso = [SELECT Id, SEG_SR_Seguimiento__c, SEG_NombreCliente__c FROM SEG_Contratos__c WHERE SEG_SR_Seguimiento__c IN :casosModificados];
			
			// Creo un mapa que sea de Casos de Seguimiento con cada uno de sus Contratos (SEG_SR_Seguimiento__c , lista de contratos)
			Map<Id, List<SEG_Contratos__c>> mapCasoContratos = new Map<Id, List<SEG_Contratos__c>>();

			for(SEG_Contratos__c contratoSeguimiento : lstContratosCaso){
				List<SEG_Contratos__c> contratosCaso = new List<SEG_Contratos__c>();
				if(mapCasoContratos.containsKey(contratoSeguimiento.SEG_SR_Seguimiento__c)){
					contratosCaso = mapCasoContratos.get(contratoSeguimiento.SEG_SR_Seguimiento__c);
					contratosCaso.add(contratoSeguimiento);
					mapCasoContratos.put(contratoSeguimiento.SEG_SR_Seguimiento__c, contratosCaso);
				} else {
					contratosCaso.add(contratoSeguimiento);
					mapCasoContratos.put(contratoSeguimiento.SEG_SR_Seguimiento__c, contratosCaso);
				}
			}

			// Recorro y comparo los Contactos de los Casos de Seguimiento con los de sus Contratos
			for (Id contactoCasoUpd : casosModificados) {
				List<SEG_Contratos__c> lstContratosCasos = new List<SEG_Contratos__c>();
				if(mapCasoContratos.containsKey(contactoCasoUpd)){
					lstContratosCasos = mapCasoContratos.get(contactoCasoUpd);
					for (SEG_Contratos__c contratoCaso : lstContratosCasos) {
						if(contratoCaso.SEG_NombreCliente__c != mapNewObj.get(contactoCasoUpd).ContactId){
							contratoCaso.SEG_NombreCliente__c = mapNewObj.get(contactoCasoUpd).ContactId;
							lstContratoUpd.add(contratoCaso);
						}
					}
				}
			}

			if (!lstContratoUpd.isEmpty()) {
				update lstContratoUpd;
			}
		}
	}

	/**
	 * @description US697153 - Metodo para realizar la conexión con TaskConect para los casos identificados como tales cuando se modifique alguno de los siguientes campos: Grupo, Estado, Subestado, Prioridad, SLA, Propietario.
	 * @param allCasosSegmentos Lista de los casos
	 */
	public static void conexionTaskConnect(List<Id> casosSEG, Map<Id, Case> mapNewObj, Map<Id,Case> mapOldObj){
        Map<Id, String> mapCasosTaskConnect = new Map<Id, String>(); //US745996 - Task Connect - Diferenciar primera invocación de las siguientes - Se indica que es un alta Taskconnect

        for (Id idCaso : casosSEG) {
            if(mapNewObj.containsKey(idCaso) && mapOldObj.containsKey(idCaso) && mapNewObj.get(idCaso).SEG_sincronizado_con_TaskConnect__c && (
				mapNewObj.get(idCaso).SEG_NIF_peticionario__c != mapOldObj.get(idCaso).SEG_NIF_peticionario__c ||
				mapNewObj.get(idCaso).SEG_Observaciones__c != mapOldObj.get(idCaso).SEG_Observaciones__c ||
				mapNewObj.get(idCaso).CC_MCC_Motivo__c != mapOldObj.get(idCaso).CC_MCC_Motivo__c ||
				mapNewObj.get(idCaso).SEG_Grupo__c != mapOldObj.get(idCaso).SEG_Grupo__c ||
				mapNewObj.get(idCaso).Status != mapOldObj.get(idCaso).Status ||
				mapNewObj.get(idCaso).SEG_Subestado__c != mapOldObj.get(idCaso).SEG_Subestado__c ||
				mapNewObj.get(idCaso).Priority != mapOldObj.get(idCaso).Priority ||
				mapNewObj.get(idCaso).SEG_SLA_cliente_case__c != mapOldObj.get(idCaso).SEG_SLA_cliente_case__c ||
				mapNewObj.get(idCaso).OwnerId != mapOldObj.get(idCaso).OwnerId)){
				if (!mapOldObj.get(idCaso).SEG_sincronizado_con_TaskConnect__c) {
					mapCasosTaskConnect.put(idCaso, 'A'); //US745996 - Task Connect - Si el caso se acaba de marcar como TaskConnect se envía como alta
				} else if(mapOldObj.get(idCaso).Status != 'Cerrado' && mapOldObj.get(idCaso).Status != 'Rechazado'){
					mapCasosTaskConnect.put(idCaso, 'M'); //US745996 + US861784 - Task Connect - Si el caso ya estaba marcado como TaskConnect y no se cerró se envía como modificación.
				} else if(mapNewObj.get(idCaso).Status != 'Cerrado' && mapNewObj.get(idCaso).Status != 'Rechazado'){
					mapCasosTaskConnect.put(idCaso, 'R'); //US861784 - Se añade el envío con marca de R (Reapertura) si el caso estaba cerrado.
				}
            }
        }
        if (!mapCasosTaskConnect.isEmpty()){
			if(!System.isFuture()){
				SEG_TaskConnect.envioComunicacionTrigger(mapCasosTaskConnect);
			} else {
				String jsonMapaCasos = JSON.serialize(mapCasosTaskConnect);
				CBK_SCH_PendingProcess__c envioTask = new CBK_SCH_PendingProcess__c(Schedule_Time__c= DateTime.now().addMinutes(1),
				ClassName__c = 'SEG_Schedule_TaskConnect', CBK_ParamTextArea__c = jsonMapaCasos);
				insert envioTask;
			}
        }
	}

	/**
	* @description Método para indicar el contacto y cuenta de caso junto con su email y nif en el chatter.
	* @param casosSEG Lista de Ids de los casos
	* @param mapNewObj Mapa de casos nuevos
	* @param mapOldObj Mapa de casos viejos
	*/
	public static void insertarDatosChatter(List<Id> casosSEG, Map<Id, Case> mapNewObj, Map<Id, Case> mapOldObj){

        List<Id> listaComentariosChatter = new List<Id>();
        Map<Id, Account> mapIdCuenta;
        Map<Id, Contact> mapIdContacto;
        Set<Id> setCuentas = new Set<Id>();
        Set<Id> setContactos = new Set<Id>();
        List<FeedItem> comentariosChatter = new List<FeedItem>();

        for (Id idCaso : casosSEG) {
            if(mapNewObj.containsKey(idCaso) && (mapNewObj.get(idCaso).AccountId != null && mapOldObj.get(idCaso).AccountId == null || mapNewObj.get(idCaso).ContactId != null && mapOldObj.get(idCaso).ContactId == null )){
                listaComentariosChatter.add(idCaso);
                if(mapNewObj.get(idCaso).AccountId != null){
                    setCuentas.add(mapNewObj.get(idCaso).AccountId);
                }
                if(mapNewObj.get(idCaso).ContactId != null){
                    setContactos.add(mapNewObj.get(idCaso).ContactId);
                }
            }
        }

        if(!listaComentariosChatter.isEmpty()){
            if(!setCuentas.isEmpty()){
                mapIdCuenta = new Map<Id, Account>([SELECT id, Name, CC_Numero_Documento__c FROM Account WHERE id IN :setCuentas]);
            }
            if(!setContactos.isEmpty()){
                mapIdContacto = new Map<Id, Contact>([SELECT id, Name, Email FROM Contact WHERE id IN :setContactos]);
            }

            for(id casoChatter : listaComentariosChatter){
                // Variable donde se guardara el mensaje a insertar
                String msg = '';
                // Insertar en Chatter
                FeedItem feed = new FeedItem();
                feed.ParentId = casoChatter;
                feed.Type = 'TextPost';               

                if(mapIdContacto != null && !mapIdContacto.isEmpty() && mapNewObj.get(casoChatter).ContactId != null && mapOldObj.get(casoChatter).ContactId == null && mapIdContacto.containsKey(mapNewObj.get(casoChatter).ContactId) ){
                    msg += 'Nombre de contacto ' + mapIdContacto.get(mapNewObj.get(casoChatter).ContactId).Name + ' - ' + mapIdContacto.get(mapNewObj.get(casoChatter).ContactId).Email + ' ';
                }

                if(mapIdCuenta != null && !mapIdCuenta.isEmpty() && mapNewObj.get(casoChatter).AccountId != null && mapOldObj.get(casoChatter).AccountId == null && mapIdCuenta.containsKey(mapNewObj.get(casoChatter).AccountId)){
                    msg += 'Nombre de cliente ' + mapIdCuenta.get(mapNewObj.get(casoChatter).AccountId).Name + ' - ' + mapIdCuenta.get(mapNewObj.get(casoChatter).AccountId).CC_Numero_Documento__c;
                }

                feed.Body = msg;
                comentariosChatter.add(feed);
            }

            if(!comentariosChatter.isEmpty()){
            	Database.insert (comentariosChatter, false);
			}
        }
	}
}