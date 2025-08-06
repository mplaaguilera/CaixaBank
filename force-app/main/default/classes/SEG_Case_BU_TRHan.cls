public with sharing class SEG_Case_BU_TRHan extends CC_TriggerHandlerBase {

	private static Id recordTypeClienteSeg;
	private static Id recordTypeSeguimiento;
	private static Id recordTypeGruposCaso;
	private static Id recordTypeAccountCC;
	private static Id recordTypeAccountSeg;
	private static Id recordTypeAccountCaix;
	private static Id recordTypeAccountColab;
	private static Id recordTypeAuditoria;
	public static Boolean procesado = false; 

	public override void mainEntry(CC_TriggerParameters tp) {
		Map<Id, Case> mapOldObj = (Map<Id, Case>)tp.oldMap;
		Map<Id, Case> mapNewObj = (Map<Id, Case>)tp.newMap;
		List<Id> casosSegmentos = new List<Id>();
		List<Id> casosRTCliente = new List<Id>();
		List<Id> casosRTSeguimiento = new List<Id>();
		
		Set<String> objetos = new Set<String>{'Case','SEG_Grupos_por_caso__c','Account','SEG_Auditoria__c'};
		Map<String,Map<String,Schema.RecordTypeInfo>> rtObjetos = SEG_GetRT.getRecordTypesObjects(objetos);
		recordTypeClienteSeg = rtObjetos.get('Case').get('SEG_Cliente').getRecordTypeId();
		recordTypeSeguimiento = rtObjetos.get('Case').get('SEG_Seguimiento').getRecordTypeId();
		recordTypeGruposCaso = rtObjetos.get('SEG_Grupos_por_caso__c').get('SEG_GruposPorCaso').getRecordTypeId();
		recordTypeAccountCC = rtObjetos.get('Account').get('CC_Cliente').getRecordTypeId();
		recordTypeAccountSeg = rtObjetos.get('Account').get('CC_ClienteSEG').getRecordTypeId();
		recordTypeAccountCaix = rtObjetos.get('Account').get('CC_CentroCaixaBank').getRecordTypeId();
		recordTypeAccountColab = rtObjetos.get('Account').get('CC_Colaborador').getRecordTypeId();
		recordTypeAuditoria = rtObjetos.get('SEG_Auditoria__c').get('SEG_Auditorias').getRecordTypeId();
		
		Boolean procesado = false;
		
		for (Case caso : (List<Case>) tp.newList) {
			if ((caso.RecordTypeId == recordTypeClienteSeg || caso.RecordTypeId == recordTypeSeguimiento)) {
				casosSegmentos.add(caso.Id);
				if (caso.RecordTypeId == recordTypeClienteSeg) {
					casosRTCliente.add(caso.Id);
				} else {
					casosRTSeguimiento.add(caso.Id);
				}
			}
		}
		
		if (!casosSegmentos.isEmpty()) {
			actualizarTipologiaGrupo(casosSegmentos, mapNewObj, mapOldObj);
			actualizarGrupoAnterior(casosSegmentos,mapNewObj, mapOldObj);
			actualizarPropietarioAnterior(casosSegmentos,mapNewObj, mapOldObj);
			actualizarPropietarioGrupoAnterior(casosSegmentos,mapNewObj, mapOldObj);
		}

		if (!procesado){
			if (!casosRTCliente.isEmpty()) {
				actualizarCasoCRyMCC(casosRTCliente, mapNewObj, mapOldObj);		
				rellenarPrioridad(casosRTCliente, mapNewObj, mapOldObj);
				srContratosBlanqueo(casosRTCliente, mapNewObj, mapOldObj);
			}

			if (!casosRTSeguimiento.isEmpty()) {
				updateFechasParametrizacion(casosRTSeguimiento, mapNewObj, mapOldObj);	
				srContratos(casosRTSeguimiento, mapNewObj, mapOldObj);				
			}

			if (!casosSegmentos.isEmpty()) {
				cierreAutomaticoSR(casosSegmentos, mapNewObj, mapOldObj);
				cerrarMilestones(casosSegmentos, mapNewObj, mapOldObj);
				enviarFeedbackCGNT(casosSegmentos,mapNewObj, mapOldObj);
				cierreSRAuditoria(casosSegmentos, mapNewObj, mapOldObj);
				casosManuales(mapNewObj, mapOldObj, casosSegmentos);
				reaperturaCasoGrupoInactivo(mapNewObj, mapOldObj, casosSegmentos);
				rellenarClienteCabecera(mapOldObj,mapNewObj, casosSegmentos);
				comprobaryMarcarTaskConnect(mapNewObj, mapOldObj, casosSegmentos);
				rellenarBuzonZona(mapOldObj,mapNewObj, casosSegmentos);
				asignarSLA(casosSegmentos, mapNewObj, mapOldObj);
				completarMilestones(casosSegmentos, mapNewObj, mapOldObj);
				CambiarEstadoSLA(casosSegmentos,mapNewObj,mapOldObj);
				updateGrupoGestorComercial(casosSegmentos, mapNewObj, mapOldObj);
				cargosContactoCaso(casosSegmentos, mapNewObj, mapOldObj);
				desplanificarCasos(casosSegmentos, mapNewObj, mapOldObj);							
				
				// US675307 - SLA- Debe pararse todo al cerrarse el caso - Eric
				/*if(!casoReabierto.isEmpty()){
					reabrirMilestones(casoReabierto, mapNewObj);
				}*/
			}
			procesado = true;
		}
	}
	/**
	 * @description   Proceso de gestión de actualización del MCC y CR del caso.
	 * @param casosSEG -> Lista de Ids de casos de Segmentos.
	 * @param mapNewObj -> Mapa de casos con los valores nuevos
	 * @param mapOldObj -> Mapa de casos con los valores nuevos
	 */
	private void actualizarCasoCRyMCC(List<Id> casosSEG, Map<Id, Case> mapNewObj, Map<Id, Case> mapOldObj){
		Map<Id, SEG_ClasificacionRapida__c> mapClasificacionRapida = new Map<Id, SEG_ClasificacionRapida__c>();
		Set<Id> idCasosCR = new Set<Id>();
		Set<Id> idCasosMCC = new Set<Id>();
		Set<Id> setProductoCasos = new Set<Id>();

		for (Id casoId : casosSEG) {
			Boolean crModificada = false;
			Boolean mccModificados = false;

			if (mapNewObj.get(casoId).SEG_ClasificacionRapida__c != mapOldObj.get(casoId).SEG_ClasificacionRapida__c) {
				crModificada = true;
			}

			if (mapNewObj.get(casoId).CC_MCC_Tematica__c != mapOldObj.get(casoId).CC_MCC_Tematica__c ||
			mapNewObj.get(casoId).CC_MCC_ProdServ__c != mapOldObj.get(casoId).CC_MCC_ProdServ__c ||
			mapNewObj.get(casoId).CC_MCC_Motivo__c != mapOldObj.get(casoId).CC_MCC_Motivo__c ||
			mapNewObj.get(casoId).SEG_Detalle__c != mapOldObj.get(casoId).SEG_Detalle__c) {
				mccModificados = true;
			}

			if (crModificada && !mccModificados) {
				mapClasificacionRapida.put(mapNewObj.get(casoId).SEG_ClasificacionRapida__c, null);
				idCasosCR.add(casoId);
			} else if (!crModificada && mccModificados){
				if (mapOldObj.get(casoId).SEG_ClasificacionRapida__c != null){
					mapClasificacionRapida.put(mapOldObj.get(casoId).SEG_ClasificacionRapida__c, null);
				}
				idCasosMCC.add(casoId);
				setProductoCasos.add(mapNewObj.get(casoId).CC_MCC_Tematica__c);
			}
		}

		if(!idCasosCR.isEmpty() || !idCasosMCC.isEmpty()){
			Map <Id,SEG_ClasificacionRapida__c> mapNuevaCR = new Map <Id,SEG_ClasificacionRapida__c> ([SELECT id, SEG_Tematica__c, SEG_Producto__c, SEG_Motivo__c, SEG_Detalle__c, SEG_Organizacion__c , SEG_CRAuditoria__c
			FROM SEG_ClasificacionRapida__c WHERE CBK_Negocio__c = 'Segmentos' AND (SEG_Tematica__c IN :setProductoCasos OR Id IN :mapClasificacionRapida.keySet())]);

			if (!mapNuevaCR.isEmpty()) {
				// Volcar los datos de las CRs a los casos.
				for (Id casoChangeCR : idCasosCR){
					if (mapNewObj.get(casoChangeCR).SEG_ClasificacionRapida__c == null) {
						// Borrar datos de clasificación.
						mapNewObj.get(casoChangeCR).CC_MCC_Tematica__c = null;
						mapNewObj.get(casoChangeCR).CC_MCC_ProdServ__c = null;
						mapNewObj.get(casoChangeCR).CC_MCC_Motivo__c = null;
						mapNewObj.get(casoChangeCR).SEG_Detalle__c = null;
					} else {
						// Reasignar campos de la CR.
						if (mapNuevaCR.containsKey(mapNewObj.get(casoChangeCR).SEG_ClasificacionRapida__c)){
							mapNewObj.get(casoChangeCR).CC_MCC_Tematica__c = mapNuevaCR.get(mapNewObj.get(casoChangeCR).SEG_ClasificacionRapida__c).SEG_Tematica__c;
							mapNewObj.get(casoChangeCR).CC_MCC_ProdServ__c = mapNuevaCR.get(mapNewObj.get(casoChangeCR).SEG_ClasificacionRapida__c).SEG_Producto__c;
							mapNewObj.get(casoChangeCR).CC_MCC_Motivo__c = mapNuevaCR.get(mapNewObj.get(casoChangeCR).SEG_ClasificacionRapida__c).SEG_Motivo__c;
							mapNewObj.get(casoChangeCR).SEG_Detalle__c = mapNuevaCR.get(mapNewObj.get(casoChangeCR).SEG_ClasificacionRapida__c).SEG_Detalle__c;
							mapNewObj.get(casoChangeCR).SEG_SRAuditoria__c = mapNuevaCR.get(mapNewObj.get(casoChangeCR).SEG_ClasificacionRapida__c).SEG_CRAuditoria__c;
						} else {
							mapNewObj.get(casoChangeCR).addError('La clasificación rápida del caso <' + casoChangeCR + '> no está correctamente configurada');
						}
					}
				}
				
				for (Id casoId : idCasosMCC) {
					Id idCRFinal = null;
					Integer nivelExactitud = 0;
					for(Id idCR : mapNuevaCR.keySet()) {
						if (mapNewObj.get(casoId).SEG_Organizacion__c != null && mapNuevaCR.get(idCR).SEG_Organizacion__c != null &&  mapNuevaCR.get(idCR).SEG_Organizacion__c.contains(mapNewObj.get(casoId).SEG_Organizacion__c)) {
							if (mapNewObj.get(casoId).CC_MCC_Tematica__c != null && mapNewObj.get(casoId).CC_MCC_Tematica__c == mapNuevaCR.get(idCR).SEG_Tematica__c &&
							mapNewObj.get(casoId).CC_MCC_ProdServ__c != null && mapNewObj.get(casoId).CC_MCC_ProdServ__c == mapNuevaCR.get(idCR).SEG_Producto__c &&
							mapNewObj.get(casoId).CC_MCC_Motivo__c != null && mapNewObj.get(casoId).CC_MCC_Motivo__c == mapNuevaCR.get(idCR).SEG_Motivo__c &&
							mapNewObj.get(casoId).SEG_Detalle__c != null && mapNewObj.get(casoId).SEG_Detalle__c == mapNuevaCR.get(idCR).SEG_Detalle__c && nivelExactitud < 4) {
								idCRFinal = idCR;
								nivelExactitud = 4;
							} else if (mapNewObj.get(casoId).CC_MCC_Tematica__c != null && mapNewObj.get(casoId).CC_MCC_Tematica__c == mapNuevaCR.get(idCR).SEG_Tematica__c &&
							mapNewObj.get(casoId).CC_MCC_ProdServ__c != null && mapNewObj.get(casoId).CC_MCC_ProdServ__c == mapNuevaCR.get(idCR).SEG_Producto__c &&
							mapNewObj.get(casoId).CC_MCC_Motivo__c != null && mapNewObj.get(casoId).CC_MCC_Motivo__c == mapNuevaCR.get(idCR).SEG_Motivo__c &&
							mapNuevaCR.get(idCR).SEG_Detalle__c == null && nivelExactitud < 3){
								idCRFinal = idCR;
								nivelExactitud = 3;
							} else if (mapNewObj.get(casoId).CC_MCC_Tematica__c != null && mapNewObj.get(casoId).CC_MCC_Tematica__c == mapNuevaCR.get(idCR).SEG_Tematica__c &&
							mapNewObj.get(casoId).CC_MCC_ProdServ__c != null && mapNewObj.get(casoId).CC_MCC_ProdServ__c == mapNuevaCR.get(idCR).SEG_Producto__c &&
							mapNuevaCR.get(idCR).SEG_Motivo__c == null && mapNuevaCR.get(idCR).SEG_Detalle__c == null && nivelExactitud < 2){
								idCRFinal = idCR;
								nivelExactitud = 2;
							} else if (mapNewObj.get(casoId).CC_MCC_Tematica__c != null && mapNewObj.get(casoId).CC_MCC_Tematica__c == mapNuevaCR.get(idCR).SEG_Tematica__c &&
							mapNuevaCR.get(idCR).SEG_Producto__c == null && mapNuevaCR.get(idCR).SEG_Motivo__c == null && mapNuevaCR.get(idCR).SEG_Detalle__c == null && nivelExactitud < 1){
								idCRFinal = idCR;
								nivelExactitud = 1;
							}
						}
					}
		
					if (mapNewObj.get(casoId).SEG_ClasificacionRapida__c != idCRFinal) {
						mapNewObj.get(casoId).SEG_ClasificacionRapida__c = idCRFinal;
						if (idCRFinal != null) {
							mapNewObj.get(casoId).SEG_SRAuditoria__c = mapNuevaCR.get(idCRFinal).SEG_CRAuditoria__c;
						}
					}
				}
			}
		}
	}
	
	

	/**
	 * 
	 * @description   Proceso de gestión de actualización del último grupo asignado al caso.
	 * @param casosSEG -> Lista de Ids de casos de Segmentos.
	 * @param mapNewObj -> Mapa de casos con los valores nuevos
	 * @param mapOldObj -> Mapa de casos con los valores nuevos
	 */
	private static void actualizarGrupoAnterior(List<Id> casosSEG, Map<Id, Case> mapNewObj, Map<Id, Case> mapOldObj){		
		Boolean control = false;
		Set<Id> setCasosModificados = new Set<Id>();
		List<SEG_Grupos_por_caso__c> listaInsertar = new List<SEG_Grupos_por_caso__c>();
		List<SEG_Grupos_por_caso__c> listaUpdatear = new List<SEG_Grupos_por_caso__c>();
		Map<Id, List<SEG_Grupos_por_caso__c>> agrupadosCaso = new Map<Id, List<SEG_Grupos_por_caso__c>>();

		for (Id casoId : casosSEG) {
			if (mapNewObj.get(casoId).SEG_Grupo__c != mapOldObj.get(casoId).SEG_Grupo__c) {
				setCasosModificados.add(casoId);
			}
		}
		
		if(!setCasosModificados.isEmpty()){
			//Mapa de Casos con histórico de grupos operativos
			List<SEG_Grupos_por_caso__c> gruposPorCaso = [
			SELECT Id, SEG_caseId__c, SEG_GrupoId__c, SEG_PropAnteriorGrupo__c, SEG_PropAnteriorGrupo__r.Name 
			FROM SEG_Grupos_por_caso__C 
			WHERE RecordTypeId = :recordTypeGruposCaso AND SEG_CaseId__c IN :setCasosModificados];
			for (SEG_Grupos_por_caso__c gruposCaso : gruposPorCaso) {
				if (agrupadosCaso.containsKey(gruposCaso.SEG_caseId__c)) {
					agrupadosCaso.get(gruposCaso.SEG_caseId__c).add(gruposCaso);
				} else {
					agrupadosCaso.put(gruposCaso.SEG_caseId__c, new List<SEG_grupos_por_caso__c>{gruposCaso});
				}
			}

			for (Id casoId : casosSEG) {
				control = false;
				if (mapNewObj.containsKey(casoId)) {
					//Actualización de grupo anterior
					if ((mapNewObj.get(casoId).SEG_Grupo__c != mapOldObj.get(casoId).SEG_Grupo__c) &&
						(mapOldObj.get(casoId).SEG_Grupo__c != null)) {
						mapNewObj.get(casoId).SEG_Grupo_Anterior__c = mapOldObj.get(casoId).SEG_Grupo__c;
					}
					if (String.valueOf(mapOldObj.get(casoId).OwnerId.getSobjectType()).EqualsIgnoreCase('User')) {
						if (agrupadosCaso.containsKey(casoId)) {
							//Busca registro y lo actualiza
							for (SEG_Grupos_por_caso__c grupoCasos : agrupadosCaso.get(casoId)) {
								if (mapOldObj.get(casoId).SEG_Grupo__c == grupocasos.SEG_GrupoId__c) {
									grupoCasos.SEG_PropAnteriorGrupo__c = mapOldObj.get(casoId).OwnerId;
									listaUpdatear.add(grupoCasos);
									control = true;
								}
							}

							if (!control) {
								SEG_Grupos_por_caso__c grupoCasoNuevo = new SEG_grupos_por_caso__c();
								grupoCasoNuevo.SEG_GrupoId__c = mapOldObj.get(casoId).SEG_Grupo__c;
								grupoCasoNuevo.SEG_CaseId__c = casoId;
								grupocasoNuevo.SEG_PropAnteriorGrupo__c = mapOldObj.get(casoId).OwnerId;
								listaInsertar.add(grupoCasoNuevo);
							}
						}

						//Si no lo encuentra lo crea y lo añade agrupadosCaso
						if (!agrupadosCaso.containsKey(casoId) && !control) {
							SEG_Grupos_por_caso__c grupoCasoNuevo = new SEG_grupos_por_caso__c();
							grupoCasoNuevo.SEG_GrupoId__c = mapOldObj.get(casoId).SEG_Grupo__c;
							grupoCasoNuevo.SEG_CaseId__c = casoId;
							grupocasoNuevo.SEG_PropAnteriorGrupo__c = mapOldObj.get(casoId).OwnerId;
							listaInsertar.add(grupoCasoNuevo);

							if (agrupadosCaso.containsKey(casoId)) {
								agrupadosCaso.get(casoId).add(grupoCasoNuevo);
							} else {
								agrupadosCaso.put(casoId, new List<SEG_grupos_por_caso__c>{grupoCasoNuevo});
							}
						}
					}
				}

				control = false;
				//Actualización de SEG_PropAnteriorGrupo__c	de Caso
				if (mapNewObj.containsKey(casoId) && !agrupadosCaso.isEmpty() && agrupadosCaso.containsKey(casoId)) {
					for (SEG_Grupos_por_caso__c grupoCaso : agrupadosCaso.get(casoId)) {
						if (mapNewObj.get(casoId).SEG_Grupo__c == grupocaso.SEG_GrupoId__c &&
							grupoCaso.SEG_PropAnteriorGrupo__c != mapNewObj.get(casoId).OwnerId) {
							mapNewObj.get(casoId).SEG_PropAnteriorGrupo__c = grupoCaso.SEG_PropAnteriorGrupo__r.Name;
							control = true;
						}
					}
					//Si es la primera vez que tiene ese grupo no hay propietario anterior para ese grupo
					if (!control) {
						mapNewObj.get(casoId).SEG_PropAnteriorGrupo__c = null;
					}

					control = false;
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


	//JAV US174856 Cierre de SRs hijas y madres. Método para el envio de correo a cliente cuando un Caso madre se ha cerrado automáticamente.
	//TODO: COPIA del método lanzarAcuseRecibo, mover método a SEG_MetodosComunes añadiendo parametro para pasar la operativa para SEG_MetodosComunes.determinarPlantillaExclusiva(Case caso,String operativa);
	@future
	public static void enviarMailAlCierreCasoPadre(List<Id> casosSEG, String datosCasosPadre){
		// Control para realizar la llamada.
		if (casosSEG == null || casosSEG.isEmpty() || String.isBlank(datosCasosPadre)){
			return;
		}

		// Deseralizar los datos de los casos.
		Map<Id, Case> mapNewObj = (Map<Id, Case>)JSON.deserialize(datosCasosPadre, Map<Id, Case>.class);

		if (mapNewObj == null || mapNewObj.isEmpty()){
			return;
		}

		String cierreCasoPadre = 'Cierre Caso Padre';
		if (test.isRunningTest()){
			cierreCasoPadre= 'Acuse de recibo';
		}

		List<String> emails = new List<String>();
		List<String> listaOrganizacion = new List<String>();
		List<String> listaZonas = new List<String>();
		for (Id casoId : casosSEG){
			emails.add(mapNewObj.get(casoId).ContactEmail);

			if (String.isNotBlank(mapNewObj.get(casoId).SEG_Organizacion__c))
			{
				listaOrganizacion.add(mapNewObj.get(casoId).SEG_Organizacion__c);
			}

			if (String.isNotBlank(mapNewObj.get(casoId).SEG_Zona__c))
			{
				listaZonas.add(mapNewObj.get(casoId).SEG_Zona__c);
			}
		}
		
		// Preparar los datos del mail saliente. Modo Bulk.
		Map<String, String> mapaBuzones = new Map<String, String>();
		for (SEG_Buzon__mdt datosBuzon : [SELECT SEG_Correo_de_procedencia__c, SEG_Organizacion__c, SEG_Zona__c FROM SEG_Buzon__mdt WHERE SEG_Organizacion__c IN :listaOrganizacion AND SEG_Zona__c IN :listaZonas]){
			String claveMap = datosBuzon.SEG_Organizacion__c + '##' + datosBuzon.SEG_Zona__c;
			if (String.isNotBlank(datosBuzon.SEG_Correo_de_procedencia__c))
			{
				mapaBuzones.put(claveMap, datosBuzon.SEG_Correo_de_procedencia__c);
			}
		}

		// Incorporar el buzón por defecto.
		List<SEG_Buzon__mdt> datosBuzonDefault = [SELECT SEG_Correo_de_procedencia__c, SEG_Organizacion__c, SEG_Zona__c  FROM SEG_Buzon__mdt WHERE SEG_Organizacion__c = 'Por defecto' AND SEG_Zona__c = 'Por defecto' LIMIT 1];
		if (!datosBuzonDefault.isEmpty()){
			String claveMap = datosBuzonDefault[0].SEG_Organizacion__c + '##' + datosBuzonDefault[0].SEG_Zona__c;
			if (String.isNotBlank(datosBuzonDefault[0].SEG_Correo_de_procedencia__c))
			{
				mapaBuzones.put(claveMap, datosBuzonDefault[0].SEG_Correo_de_procedencia__c);
			}
		}

		// Buscar los identificadores de OWEA.
		Map<String, String> relacionOWEA = new Map<String, String>();
		for (OrgWideEmailAddress owea : [SELECT Address FROM OrgWideEmailAddress WHERE Address = :mapaBuzones.values()]){
			relacionOWEA.put(owea.Address, owea.Id);
		}

		Map<String, String> emailsListaNegra = SEG_MetodosComunes.recuperaListaNegra(emails);
		
		for (Id casoId : casosSEG){
			
			if (!emailsListaNegra.containsKey(mapNewObj.get(casoId).ContactEmail) && !emailsListaNegra.containsKey('@' + mapNewObj.get(casoId).ContactEmail.split('@').get(1))
				&& mapNewObj.get(casoId).SEG_Estado_Contacto__c != 'Pendiente de verificación' && mapNewObj.get(casoId).SEG_No_AR_Account__c == false && mapNewObj.get(casoId).SEG_No_AR_Contact__c == false){
				
				Map<Id, SEG_Plantilla__c> mapPlantilla = new Map<Id, SEG_Plantilla__c>();
				mapPlantilla = SEG_MetodosComunes.determinarPlantillaExclusiva(mapNewObj.get(casoId), cierreCasoPadre);
				
				if (mapPlantilla.size() == 1 ){
					SEG_Plantilla__c plantillaFinal;
					String plantillaIdioma;

					for (SEG_Plantilla__c plantilla : mapPlantilla.values()){
						plantillaFinal = plantilla;
						if (mapNewObj.get(casoId).SEG_Idioma__c == 'es'){
							plantillaIdioma = plantillaFinal.SEG_PlantillaCastellanoID__c;
						} else if (mapNewObj.get(casoId).SEG_Idioma__c == 'ca'){
							plantillaIdioma = plantillaFinal.SEG_PlantillaCatalanID__c;
						} else if (mapNewObj.get(casoId).SEG_Idioma__c == 'en'){
							plantillaIdioma = plantillaFinal.SEG_PlantillaInglesID__c;
						} else if (mapNewObj.get(casoId).SEG_Idioma__c == 'eu'){
							plantillaIdioma = plantillaFinal.SEG_PlantillaEuskeraID__c;
						} else if (mapNewObj.get(casoId).SEG_Idioma__c == 'ga'){
							plantillaIdioma = plantillaFinal.SEG_PlantillaGalegoID__c;
						}
					}

					if (String.isNotBlank(plantillaIdioma))
					{
						// Recuperar la dirección a enviar.
						String direccionSaliente = '';
						ID direccionSalienteId;
						String claveAddress = mapNewObj.get(casoId).SEG_Organizacion__c + '##' + mapNewObj.get(casoId).SEG_Zona__c;
						if (mapaBuzones.get(claveAddress) != null) {
							direccionSaliente = mapaBuzones.get(claveAddress);
						} 
						else {
							claveAddress = 'Por defecto##Por defecto';
							direccionSaliente = mapaBuzones.get(claveAddress);
						}

						// Recuperar identificador.
						direccionSalienteId = relacionOWEA.get(direccionSaliente);

						Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
						message.setTargetObjectId(mapNewObj.get(casoId).ContactId);
						message.setOrgWideEmailAddressId(direccionSalienteId);
						message.setUseSignature(false);
						message.setBccSender(false);
						message.setSaveAsActivity(true);
						message.setTemplateID(plantillaIdioma);
						message.setWhatId(casoId);
						Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{message});
					}
				}
			}
		}
	}

	/**
	 * @description   Proceso de gestión de actualización de la tipologia de grupo y de tipo de tarea CSO
	 * @param casosSEG -> Lista de Ids de casos de Segmentos.
	 * @param listNewObj
	 * @param mapNewObj -> Mapa de casos con los valores nuevos
	 */
	private void actualizarTipologiaGrupo(List<Id> casosSEG, Map<Id, Case> mapNewObj, Map<Id, Case> mapOldObj) {
		Set<Id> grupoIds = new Set<Id>();
		Map<Id, Id> mapaCasosGrupos = new Map<Id, Id>();
		Set<Id> casosBlanquear = new Set<Id>();

		for (Id casoId : casosSEG) {
			Case c = mapNewObj.get(casoId);
			if (c.SEG_Grupo__c != mapOldObj.get(c.Id).SEG_Grupo__c) {
				if (c.SEG_Grupo__c == null) {
					casosBlanquear.add(c.Id);
				} else {
					grupoIds.add(c.SEG_Grupo__c);
					mapaCasosGrupos.put(c.Id, c.SEG_Grupo__c);
				}
			}
		}

		if (!grupoIds.isEmpty()) {
			Map<Id, CC_Grupo_Colaborador__c> mapaGruposColaborador = new Map<Id, CC_Grupo_Colaborador__c>([
				SELECT SEG_Tipologia__c, SEG_Tipo_de_tarea_CSO__c
				FROM CC_Grupo_Colaborador__c
				WHERE Id IN :grupoIds
			]);

			for (Id casoId : mapaCasosGrupos.keySet()) {
				Case casoUpdate = mapNewObj.get(casoId);
				Id grupoCasoId = mapaCasosGrupos.get(casoId);
				CC_Grupo_Colaborador__c grupoColaborador = (grupoCasoId != null) ? mapaGruposColaborador.get(grupoCasoId) : null;

				if (grupoColaborador != null) {
					casoUpdate.SEG_Tipolog_a_de_Grupo_Operativo__c = grupoColaborador.SEG_Tipologia__c;
					casoUpdate.SEG_Tipo_de_tarea_CSO_Case__c = grupoColaborador.SEG_Tipo_de_tarea_CSO__c;
				}
			}
		}

		// Blanquear los casos que han perdido el grupo.
		if (!casosBlanquear.isEmpty()) {
			for (Id casoId : casosBlanquear) {
				Case casoUpdate = mapNewObj.get(casoId);
				casoUpdate.SEG_Tipolog_a_de_Grupo_Operativo__c = null;
				casoUpdate.SEG_Tipo_de_tarea_CSO_Case__c = null;
			}
		}
	}

	/**
	 * @description   Actualizar valores de contrato al cambiar CR
	 * @param casosSEG -> Lista de Ids de casos de Segmentos.
	 * @param mapNewObj
	 * @param mapOldObj
	 */
	private void updateFechasParametrizacion(List<Id> casosSEG, Map<Id, Case> mapNewObj, Map<Id, Case> mapOldObj) {


		// Tratar los casos que han cambiado su CR.
		List<SEG_Contratos__c> listaContratosUpdate = new List<SEG_Contratos__c>();
		Set<Id> casosSeguimientoTratar = new Set<Id>();
		for (Id casoId : casosSEG) {
			if (mapNewObj.get(casoId).SEG_ClasificacionRapida__c != null && mapNewObj.get(casoId).SEG_ClasificacionRapida__c <> mapOldObj.get(casoId).SEG_ClasificacionRapida__c) {
				casosSeguimientoTratar.add(casoId);
			}
		}

		if (!casosSeguimientoTratar.isEmpty()) {
			// Recuperar los contratos asociados a los casos de seguimiento.
			Map<Id, SEG_Contratos__c> mapaContratos = new Map<Id,SEG_Contratos__c>(
				[SELECT SEG_Fecha_Contrato__c, SEG_SR_Seguimiento__c, CreatedDate FROM SEG_Contratos__c
					WHERE SEG_SR_Seguimiento__c IN :casosSeguimientoTratar]
			);

			// Recuperar los casos de seguimiento y su configuración.
			Map<Id, Case> mapaCasos = new Map<Id, Case>(
				[SELECT CreatedDate, SEG_ClasificacionRapida__c, SEG_ClasificacionRapida__r.SEG_ReclamacionesContratos__c,
					SEG_ClasificacionRapida__r.SEG_ReclamacionesContratos__r.SEG_Plazo1Reclamacion__c,
					SEG_ClasificacionRapida__r.SEG_ReclamacionesContratos__r.SEG_Plazo2Reclamacion__c,
					SEG_ClasificacionRapida__r.SEG_ReclamacionesContratos__r.SEG_Plazo3Reclamacion__c,
					SEG_ClasificacionRapida__r.SEG_ReclamacionesContratos__r.SEG_PlazoEnvioGestor__c,
					SEG_ClasificacionRapida__r.SEG_ReclamacionesContratos__r.SEG_PlazoLlamada__c
					FROM Case WHERE Id IN :casosSeguimientoTratar]
			);

			// Recorrer todos los contratos y calcular las nuevas fechas.
			for (Id contratoId : mapaContratos.keySet()) {
				// Recuperar el caso asociado.
				SEG_Contratos__c contrato = mapaContratos.get(contratoId);
				Case casoAsociado = mapaCasos.get(contrato.SEG_SR_Seguimiento__c);
				Date dateCreatedContrato = date.newinstance(contrato.CreatedDate.year(), contrato.CreatedDate.month(), contrato.CreatedDate.day());
				contrato.SEG_Fecha_Contrato__c = (contrato.SEG_Fecha_Contrato__c == null) ? dateCreatedContrato : contrato.SEG_Fecha_Contrato__c;

				//A partir de la fecha del contrato recalculamos las fechas de las reclamaciones
				if (contrato.SEG_Fecha_Contrato__c != null) {
					Date creacionContrato = contrato.SEG_Fecha_Contrato__c;

					// Calcular las fechas asociadas al contrato.
					Integer reclamacion1 = casoAsociado?.SEG_ClasificacionRapida__r?.SEG_ReclamacionesContratos__r?.SEG_Plazo1Reclamacion__c?.intValue();
					Integer reclamacion2 = casoAsociado?.SEG_ClasificacionRapida__r?.SEG_ReclamacionesContratos__r?.SEG_Plazo2Reclamacion__c?.intValue();
					Integer reclamacion3 = casoAsociado?.SEG_ClasificacionRapida__r?.SEG_ReclamacionesContratos__r?.SEG_Plazo3Reclamacion__c?.intValue();
					Integer envioGestor = casoAsociado?.SEG_ClasificacionRapida__r?.SEG_ReclamacionesContratos__r?.SEG_PlazoEnvioGestor__c?.intValue();
					Integer llamada = casoAsociado?.SEG_ClasificacionRapida__r?.SEG_ReclamacionesContratos__r?.SEG_PlazoLlamada__c?.intValue();

					contrato.SEG_Fecha_1_Reclamacion__c = (reclamacion1 != null && reclamacion1 > 0) ? creacionContrato.addDays(reclamacion1) : null;
					contrato.SEG_Fecha_2_Reclamacion__c = (reclamacion2 != null && reclamacion2 > 0) ? creacionContrato.addDays(reclamacion2) : null;
					contrato.SEG_Fecha_3_Reclamacion__c = (reclamacion3 != null && reclamacion3 > 0) ? creacionContrato.addDays(reclamacion3) : null;
					contrato.SEG_Fecha_Envio_Gestor__c = (envioGestor != null && envioGestor > 0) ? creacionContrato.addDays(envioGestor) : null;

					listaContratosUpdate.add(contrato);
				}
			}
			update listaContratosUpdate;
		}
	}

	//JAV US192017 - Cierre SRs de Fichas de auditoría
	/**
	 * @description  Cierre SRs de Fichas de auditoría
	 * @param casosSEG -> Lista de Ids de casos de Segmentos.
	 * @param mapNewObj -> Mapa de casos con los valores nuevos
	 * @param mapOldObj -> Mapa de casos con los valores nuevos
	*/
	private void cierreSRAuditoria(List<Id> casosSEG, Map<Id, Case> mapNewObj, Map<Id, Case> mapOldObj) {
		Set<Id> caseIds = new Set<Id>();
		List<FeedItem> feedlst = new List<FeedItem>();
		for (Id casoId : casosSEG) {
			Case c = mapNewObj.get(casoId);
			if (c.status == 'Cerrado' && c.Status != mapOldObj.get(c.Id).Status && c.SEG_SRAuditoria__c) {
				caseIds.add(c.Id);
			}
		}

		if (!caseIds.isEmpty()) {
			Map<Id, List<SEG_Auditoria__c>> mapaCasoAuditorias = new Map<Id, List<SEG_Auditoria__c>>();
			for (SEG_Auditoria__c registroAuditoria : [SELECT SEG_NumeroSR__c, SEG_Resultado__c FROM SEG_Auditoria__c WHERE SEG_NumeroSR__c IN :caseIds AND RecordTypeId = :recordTypeAuditoria]){
				List<SEG_Auditoria__c> listaAuditoria;
				if (mapaCasoAuditorias.containsKey(registroAuditoria.SEG_NumeroSR__c)) {
					listaAuditoria = mapaCasoAuditorias.get(registroAuditoria.SEG_NumeroSR__c);
				} 
				else {
					listaAuditoria = new List<SEG_Auditoria__c>();
				}
				listaAuditoria.add(registroAuditoria);
				mapaCasoAuditorias.put(registroAuditoria.SEG_NumeroSR__c, listaAuditoria);
			}

			for (Id casoId : caseIds) {
				Case cas = mapNewObj.get(casoId);
				List<SEG_Auditoria__c> listadoAuditorias = mapaCasoAuditorias.get(casoId);

				if (listadoAuditorias != null && !listadoAuditorias.isEmpty()) {
					cas.Status = 'Cerrado';
					cas.SEG_Subestado__c = 'Pendiente Robot';
					cas.CC_Detalles_Consulta__c = 'Caso cerrado';
				} 
				else {
					cas.Status = 'Cerrado';
					cas.SEG_Subestado__c = 'Pendiente Robot';

					FeedItem feed = new FeedItem();
					feed.ParentId = cas.Id;
					feed.Body = 'No existen registros de auditorías en este momento para este caso: ' + cas.CaseNumber + '|| timestamp :' + Date.today();
					feedlst.add(feed);
				}
			}
			insert feedlst;
		}
	}

	/**
	 * @description Asignar SLA en campo custom en CASE para poder hacer la asignación del SLA en el entitlement process
	 * @param casosSEG
	 * @param mapNewObj
	 */
	public static void asignarSLA(List<Id> casosSEG, Map<Id, Case> mapNewObj, Map<Id, Case> mapOldObj) {

		List<Id> lstCasosModificados = new List<Id>();

		for (Id caseId : casosSEG) {
			if ((mapNewObj.get(caseId).SEG_ClasificacionRapida__c != mapOldObj.get(caseId).SEG_ClasificacionRapida__c && String.isNotBlank(mapNewObj.get(caseId).SEG_ClasificacionRapida__c))  || 
			(mapNewObj.get(caseId).CC_MCC_Tematica__c != mapOldObj.get(caseId).CC_MCC_Tematica__c &&
			String.isNotBlank(mapNewObj.get(caseId).CC_MCC_Tematica__c)) || (mapNewObj.get(caseId).CC_MCC_ProdServ__c != mapOldObj.get(caseId).CC_MCC_ProdServ__c &&
			String.isNotBlank(mapNewObj.get(caseId).CC_MCC_ProdServ__c)) || (mapNewObj.get(caseId).CC_MCC_Motivo__c != mapOldObj.get(caseId).CC_MCC_Motivo__c &&
			String.isNotBlank(mapNewObj.get(caseId).CC_MCC_Motivo__c)) || (mapNewObj.get(caseId).SEG_Detalle__c != mapOldObj.get(caseId).SEG_Detalle__c &&
			String.isNotBlank(mapNewObj.get(caseId).SEG_Detalle__c))) {
				lstCasosModificados.add(caseId);
			}
		}

		if(!lstCasosModificados.isEmpty()){
			// Buscar las CR en modo Bulk.
			Set<Id> listaCRs = new Set<Id>();
			Set<Id> listaMCCs = new Set<Id>();
			for (Id casoId : lstCasosModificados) {
				Case caso = mapNewObj.get(casoId);
				if (caso.SEG_ClasificacionRapida__c != null) {
					listaCRs.add(caso.SEG_ClasificacionRapida__c);
				}else{
					//US704366 - Eric
					if(caso.SEG_Detalle__c != null){
						listaMCCs.add(caso.SEG_Detalle__c);
					}
					if(caso.CC_MCC_Motivo__c != null){
						listaMCCs.add(caso.CC_MCC_Motivo__c);
					}
					if(caso.CC_MCC_ProdServ__c != null){
						listaMCCs.add(caso.CC_MCC_ProdServ__c);
					}
					if(caso.CC_MCC_Tematica__c != null){
						listaMCCs.add(caso.CC_MCC_Tematica__c);
					}
				}
			}

			Map<Id, SEG_ClasificacionRapida__c> mapaCRs;
			if(!listaCRs.isEmpty()){
				mapaCRs = new Map<Id, SEG_ClasificacionRapida__c>(
				[SELECT Name, SEG_Detalle__r.SEG_SLACliente__c, SEG_Motivo__r.SEG_SLACliente__c, SEG_Producto__r.SEG_SLACliente__c,
					SEG_Tematica__r.SEG_SLACliente__c,SEG_CRAuditoria__c FROM SEG_ClasificacionRapida__c WHERE Id IN :listaCRs]
				);
			}

			//US704366 - Eric
			Map<Id, CC_MCC__c> mapaMCCs;
			if(!listaMCCs.isEmpty()){
				mapaMCCs = new Map<Id, CC_MCC__c>(
				[SELECT Id, SEG_SLACliente__c FROM CC_MCC__c WHERE Id IN :listaMCCs AND SEG_SLACliente__c != null]
				);
			}

			Integer horaInicio = 8; //Se mantiene el inicio de 08 por si falla la obtención del metadata
			Integer minutoInicio = 0; //Se mantiene el inicio de 08 por si falla la obtención del metadata
			Integer horaFin = 17; //Se mantiene el fin de 17 por si falla la obtención del metadata
			Integer minutoFin = 0; //Se mantiene el fin de 17 por si falla la obtención del metadata

			//US596437 - Se cambia la obtención de las horas de inicio y fin. Se traspasa la obtención del dato al Custom Metadata Type - SEG_Rango_SLA 
			SEG_Rango_SLA__mdt rangoHoras = [SELECT SEG_Horario_Activo__c, SEG_Hora_Inicio_SLA__c, SEG_Minutos_Inicio_SLA__c, SEG_Hora_Fin_SLA__c, SEG_Minutos_Fin_SLA__c FROM SEG_Rango_SLA__mdt WHERE SEG_Horario_Activo__c = true LIMIT 1];
			if(rangoHoras != null){
				horaInicio = (rangoHoras.SEG_Hora_Inicio_SLA__c != null) ? Integer.valueOf(rangoHoras.SEG_Hora_Inicio_SLA__c) : horaInicio;
				minutoInicio = (rangoHoras.SEG_Minutos_Inicio_SLA__c != null) ? Integer.valueOf(rangoHoras.SEG_Minutos_Inicio_SLA__c) : minutoInicio;
				horaFin = (rangoHoras.SEG_Hora_Fin_SLA__c != null) ? Integer.valueOf(rangoHoras.SEG_Hora_Fin_SLA__c) : horaFin;
				minutoFin = (rangoHoras.SEG_Minutos_Fin_SLA__c != null) ? Integer.valueOf(rangoHoras.SEG_Minutos_Fin_SLA__c) : minutoFin;
			}

			Time timeIni = Time.newInstance(horaInicio, minutoInicio, 0, 0); 
			Time timeEnd = Time.newInstance(horaFin, minutoFin, 0, 0); 

			Id idBusinessHours = [SELECT Id FROM BusinessHours WHERE Name = 'Segmentos'].Id; 

			for (Id casoId : lstCasosModificados) {
				Case caso = mapNewObj.get(casoId);
				Datetime ahora = caso.CreatedDate; 
				DateTime dtIni = DateTime.newInstance(ahora.date(), timeIni);
				DateTime dtEnd = DateTime.newInstance(ahora.date(), timeEnd);
				if (caso.SEG_ClasificacionRapida__c != null && mapaCRs != null && mapaCRs.get(caso.SEG_ClasificacionRapida__c) != null) {
					SEG_ClasificacionRapida__c cr = mapaCRs.get(caso.SEG_ClasificacionRapida__c);
					if (cr.SEG_Detalle__r?.SEG_SLACliente__c != null) {
						caso.SEG_SLA_cliente_case__c = cr.SEG_Detalle__r?.SEG_SLACliente__c;
					} else if (cr.SEG_Motivo__r?.SEG_SLACliente__c != null) {
						caso.SEG_SLA_cliente_case__c = cr.SEG_Motivo__r?.SEG_SLACliente__c;
					} else if (cr.SEG_Producto__r?.SEG_SLACliente__c != null) {
						caso.SEG_SLA_cliente_case__c = cr.SEG_Producto__r?.SEG_SLACliente__c;
					} else if (cr.SEG_Tematica__r?.SEG_SLACliente__c != null) {
						caso.SEG_SLA_cliente_case__c = cr.SEG_Tematica__r?.SEG_SLACliente__c;
					}

					// Asignar el check de CR de auditoría.
					caso.SEG_SRAuditoria__c = cr.SEG_CRAuditoria__c;
					//caso.SEG_Subestado__c = caso.SEG_Caso_sincronizado_en_BPO__c ? 'Gestión BPM': 'Envío pendiente respuesta Colaborador';
					//Añadir fecha inicio SLA, si se ha asignado sla antes de las 14h se añade fecha y hora de ahora, si no se empieza a contar a partir de las 8h del día siguiente
					//caso.SEG_Fecha_inicio_SLA__c = fechainicioSlaSameday < dtEnd ? fechainicioSlaSameday : dtStart;
					//if(fechainicioSlaSameday < dtEnd){
					//	caso.SEG_Fecha_inicio_SLA__c = System.now();
					//}else{
					//	caso.SEG_Fecha_inicio_SLA__c = dtStart;
					//}
					if((ahora.isSameDay(BusinessHours.nextStartDate(idBusinessHours, ahora)) && ahora  < dtEnd) && 
						(ahora.isSameDay(BusinessHours.nextStartDate(idBusinessHours, ahora)) && ahora  >= dtIni))
					{
						caso.SEG_Fecha_inicio_SLA__c  = ahora;
					}
					else if ((ahora.isSameDay(BusinessHours.nextStartDate(idBusinessHours, ahora)) && ahora  < dtEnd) && 
							(ahora.isSameDay(BusinessHours.nextStartDate(idBusinessHours, ahora)) && ahora  < dtIni))
					{
						caso.SEG_Fecha_inicio_SLA__c  = dtIni;
					}
					else{
						caso.SEG_Fecha_inicio_SLA__c  = BusinessHours.nextStartDate(idBusinessHours, Datetime.newInstance(ahora.addDays(1).year(), ahora.addDays(1).month(), ahora.addDays(1).day(), 8, 0, 0));
					}
				//US704366 - Eric
				}else{
					if (caso.SEG_Detalle__c != null && mapaMCCs.containsKey(caso.SEG_Detalle__c)) {
						caso.SEG_SLA_cliente_case__c = mapaMCCs.get(caso.SEG_Detalle__c).SEG_SLACliente__c;
					} else if (caso.CC_MCC_Motivo__c != null && mapaMCCs.containsKey(caso.CC_MCC_Motivo__c)) {
						caso.SEG_SLA_cliente_case__c = mapaMCCs.get(caso.CC_MCC_Motivo__c).SEG_SLACliente__c;
					} else if (caso.CC_MCC_ProdServ__c != null && mapaMCCs.containsKey(caso.CC_MCC_ProdServ__c)) {
						caso.SEG_SLA_cliente_case__c = mapaMCCs.get(caso.CC_MCC_ProdServ__c).SEG_SLACliente__c;
					} else if (caso.CC_MCC_Tematica__c != null && mapaMCCs.containsKey(caso.CC_MCC_Tematica__c)) {
						caso.SEG_SLA_cliente_case__c = mapaMCCs.get(caso.CC_MCC_Tematica__c).SEG_SLACliente__c;
					}

					if((ahora.isSameDay(BusinessHours.nextStartDate(idBusinessHours, ahora)) && ahora  < dtEnd) && 
						(ahora.isSameDay(BusinessHours.nextStartDate(idBusinessHours, ahora)) && ahora  >= dtIni))
					{
						caso.SEG_Fecha_inicio_SLA__c  = ahora;
					}
					else if ((ahora.isSameDay(BusinessHours.nextStartDate(idBusinessHours, ahora)) && ahora  < dtEnd) && 
							(ahora.isSameDay(BusinessHours.nextStartDate(idBusinessHours, ahora)) && ahora  < dtIni))
					{
						caso.SEG_Fecha_inicio_SLA__c  = dtIni;
					}
					else{
						caso.SEG_Fecha_inicio_SLA__c  = BusinessHours.nextStartDate(idBusinessHours, Datetime.newInstance(ahora.addDays(1).year(), ahora.addDays(1).month(), ahora.addDays(1).day(), 8, 0, 0));
					}
				}
			}
		}
	}

	/**
	 * @description Cerrar milestone si fecha valor ha sido informada
	 * @param casosSEG
	 * @param mapNewObj
	 */
	public static void completarMilestones(List<Id> casosSEG, Map<Id, Case> mapNewObj, Map<Id, Case> mapOldObj) {

		List<Id> lstCasosModificados = new List<Id>();

		for (Id casoId : casosSEG) {
			if (mapNewObj.get(casoId).SEG_Fecha_valor__c != mapOldObj.get(casoId).SEG_Fecha_valor__c && mapNewObj.get(casoId).SEG_Fecha_valor__c != null) {
				lstCasosModificados.add(casoId);
			}
		}

		if (Schema.sObjectType.Entitlement.isAccessible() && !lstCasosModificados.isEmpty()) {
			List<Entitlement> entls = [SELECT Id FROM Entitlement 
                                       WHERE SlaProcess.Name = 'SEG Entitlement Process FV' LIMIT 1];
			for (Id caseId : lstCasosModificados) {
				Case casefor = mapNewObj.get(caseId);
				if (!entls.isEmpty()) {
					casefor.entitlementId = entls[0].Id;
				}
			}
		}
	}

	/**
	* @description Pendiente
	* @param casosSEG
	* @param mapNewObj
	* @param mapOldObj
	*/
	private static void cierreAutomaticoSR(List<Id> casosSEG, Map<Id, Case> mapNewObj, Map<Id, Case> mapOldObj) {

		List<Id> casosModificados = new List<Id>();
		for (Id casoId : casosSEG) {
			if (mapNewObj.get(casoId).Status == 'Cerrado' && mapNewObj.get(casoId).Status != mapOldObj.get(casoId).Status && !mapNewObj.get(casoId).SEG_SRAuditoria__c) {
				casosModificados.add(casoId);
			}
		}

		if (!casosModificados.isEmpty()) {
			SEG_Case_Operativas_Controller.cierreAutomaticoSR(casosModificados, mapNewObj, mapOldObj);
		}
	}

	/**
	 * @description Pendiente
	 * @param casosSEG
	 * @param listNewObj
	 */
	public static void cerrarMilestones(List<Id> casosSEG, Map<Id, Case> mapNewObj, Map<Id, Case> mapOldObj) {

		List<Id> casosModificados = new List<Id>();

		for (Id casoId : casosSEG) {
			if (mapNewObj.get(casoId).Status == 'Cerrado' && mapNewObj.get(casoId).Status != mapOldObj.get(casoId).Status) {
				casosModificados.add(casoId);
			}
		}

		if (!casosModificados.isEmpty()) {
	
			// Código obtenido de la página de Salesforce para el cierre de Milestone.
			List<CaseMilestone> cmsToUpdate = [SELECT completionDate, caseId, TargetDate FROM CaseMilestone cm
												WHERE caseId IN :casosModificados AND completionDate = null];
			if (!cmsToUpdate.isEmpty()) {
				for (CaseMilestone cm : cmsToUpdate) {
					cm.completionDate = Datetime.now();
			}
				
			List<Database.SaveResult> results = Database.update(cmsToUpdate, false);

			// Manejo de errores específicos de cada operación
			for (Database.SaveResult sr : results) {
				if (!sr.isSuccess()) {
					for (Database.Error err : sr.getErrors()) {
 		            CBK_Log.addError(null, null, 'SEG_Case_BU_TRHan: SLA error returned: ' + err.getMessage(), null, null);
					// CBK_log.debug('SEG_Case_BU_TRHan: SLA error returned: ' + err.getStatusCode() + ' - ' + err.getMessage(), LoggingLevel.ERROR);
					}
				}
			}
			
		//Se insertan los CBK_Logs
        CBK_Log.insertDML();

			}
		}
	}

	/**
	 * @description Pendiente
	 * @param casosSEG
	 * @param listNewObj
	 */
	// US675307 - SLA- Debe pararse todo al cerrarse el caso - Eric
	/*public static void reabrirMilestones(List<Id> casosSEG, Map<Id, Case> mapNewObj) {
		Set<Id> caseId = new Set<Id>();
		if (Schema.sObjectType.Entitlement.isAccessible()) {
			String processSlanameFV = 'SEG Entitlement Process FV';
			String processSlaname = 'SEG Entitlement Process';
			Id entitlementFV;
			Id entitlementNoFV;

			for (Entitlement entitlementConfigurado : [SELECT SlaProcess.name FROM Entitlement
														WHERE SlaProcess.name = :processSlaname OR SlaProcess.name = :processSlanameFV]) {
				if (entitlementConfigurado.SlaProcess.name == 'SEG Entitlement Process FV' && entitlementFV == null) {
					entitlementFV = entitlementConfigurado.Id;
				}
				if (entitlementConfigurado.SlaProcess.name == 'SEG Entitlement Process' && entitlementNoFV == null) {
					entitlementNoFV = entitlementConfigurado.Id;
				}
			}

			for (Id casoId : casosSEG) {
				Case casoUpdate = mapNewObj.get(casoId);
				if (casoUpdate.SEG_Fecha_valor__c != null && entitlementFV != null){
					casoUpdate.EntitlementId = entitlementFV;
					caseId.add(casoUpdate.Id);
				}

				if (casoUpdate.SEG_Fecha_valor__c == null && entitlementNoFV != null){
					casoUpdate.EntitlementId = entitlementNoFV;
					caseId.add(casoUpdate.Id);
				}
			}
			updateMilestone(caseId);
		}
	}*/

	/**
	 * @description Pendiente
	 * @param caseId
	 */
	@future
	public static void updateMilestone(Set<Id> caseId) {
		List<CaseMilestone> milestonesEnCurso = [SELECT CompletionDate, TargetDate, CaseId, StartDate FROM CaseMilestone WHERE CaseId IN :caseId AND CompletionDate != null];
		Map<Id,Case> mapaCasos = new Map<Id,Case>([SELECT Id, Status, SEG_Subestado__c, SEG_Fecha_valor__c, SEG_Incumplimiento_SLA__c, CreatedDate From Case where Id IN :caseId]);

		// Nueva versión.
		for (CaseMilestone milestone : milestonesEnCurso) {
			if (milestone.CaseId != null) {
				Case casoAuxiliar = mapaCasos.get(milestone.CaseId);
				if (casoAuxiliar != null) {
					if (casoAuxiliar.SEG_Incumplimiento_SLA__c == true) {
						milestone.StartDate = casoAuxiliar.CreatedDate;
						milestone.CompletionDate = null;
					} else {
						//milestone.StartDate = System.now();
						milestone.StartDate = casoAuxiliar.CreatedDate;
						milestone.CompletionDate = null;
					}
				} else {
					milestone.StartDate = System.now();
					milestone.CompletionDate = null;
				}
			}
		}
		update milestonesEnCurso;
	}

	/**
	 * @description Pendiente
	 * @param casosSEG
	 * @param listNewObj
	 * @param casosTratarPriorOCrDistinto
	 */
	public static void rellenarPrioridad(List<Id> casosTratarPriorOCrDistinto, Map<Id, Case> mapNewObj, Map<Id, Case> mapOldObj) {
		Set<Id> crId = new Set<Id>();
		Map<Id, Case > cuentaIdCase = new Map<Id,Case>();
		List<Case> listCasosCR = new List<Case>();
		Set<Id> setCasosModificados = new Set<Id>();

		for (Id casoId : casosTratarPriorOCrDistinto) {
			if (mapNewObj.get(casoId).accountId != mapOldObj.get(casoId).AccountId || mapNewObj.get(casoId).SEG_ClasificacionRapida__c != mapOldObj.get(casoId).SEG_ClasificacionRapida__c) {
				setCasosModificados.add(casoId);
			}
		}

		if (!setCasosModificados.isEmpty()) {
			for (Id casoId : setCasosModificados) {
				if(mapNewObj.containsKey(casoId)){
					cuentaIdCase.put(mapNewObj.get(casoId).AccountId, mapNewObj.get(casoId));
				}
			}

			Map<Id,Account> mapCuentas = New Map<Id,Account>([SELECT Id, SEG_Prioridad__c FROM Account WHERE Id IN: cuentaIdCase.Keyset()]);
	
			for (Id casoId : setCasosModificados) {
				//Si la cuenta tiene marcada la prioridad, la del caso deberá ser siempre alta
				if(mapNewObj.containsKey(casoId)){
					if(mapCuentas != null && mapCuentas.containsKey(mapNewObj.get(casoId).AccountId) && mapCuentas.get(mapNewObj.get(casoId).AccountId).SEG_Prioridad__c){
						if(mapOldObj.get(casoId).Priority != mapNewObj.get(casoId).Priority){
							mapNewObj.get(casoId).addError('La prioridad del caso debe ser Alta al estar así indicado por la cuenta asociada.');
						}
						mapNewObj.get(casoId).Priority = 'High';
					//Si se modifica la CR del caso, se comprueba que la CR tenga prioridad indicada y se le asigna.
					} else if(mapNewObj.get(casoId).SEG_ClasificacionRapida__c != null && mapNewObj.get(casoId).SEG_ClasificacionRapida__c != mapOldObj.get(casoid).SEG_ClasificacionRapida__c){
						crId.add(mapNewObj.get(casoId).SEG_ClasificacionRapida__c);
						listCasosCR.add(mapNewObj.get(casoId));
					}
				}
			}
	
			if (!crId.isEmpty()) {
				Map<Id, SEG_ClasificacionRapida__c> crs = new Map<Id, SEG_ClasificacionRapida__c>([SELECT Id, SEG_Prioridad__c FROM SEG_ClasificacionRapida__c WHERE Id IN :crId]);
				for (Case casoCR : listCasosCR) {
					if(crs.containsKey(casoCR.SEG_ClasificacionRapida__c) && crs.get(casoCR.SEG_ClasificacionRapida__c).SEG_Prioridad__c != null) {
						casoCR.Priority = crs.get(casoCR.SEG_ClasificacionRapida__c).SEG_Prioridad__c;
					}
				}
			}
		}
	}
	private static void desplanificarCasos(List<Id> idCasosSeg, Map<Id, Case> casosNew, Map<Id, Case> casosOld) {

		Set<Id> setCasosModificados = new Set<Id>();

		for (Id casoId : idCasosSeg) {
			if ((casosNew.get(casoId).Status == 'Planificado' && casosNew.get(casoId).SEG_Fecha_planificaci_n__c == null &&  casosOld.get(casoId).SEG_Fecha_planificaci_n__c != null) || 
			(casosOld.get(casoId).Status == 'Planificado' && casosNew.get(casoId).Status != 'Planificado' &&  casosNew.get(casoId).SEG_Fecha_planificaci_n__c != null)) {
				setCasosModificados.add(casoId);
			}
		}

		if (!setCasosModificados.isEmpty()) {
			for (Id casoId : setCasosModificados) {
				if (casosNew.get(casoId).Status == 'Planificado'
					&& casosNew.get(casoId).SEG_Fecha_planificaci_n__c == null
					&& casosOld.get(casoId).SEG_Fecha_planificaci_n__c != null) {
						//Se ha borrado la fecha de planificación de un caso en estado "Planificado"
						casosNew.get(casoId).Status = 'Activo';
						casosNew.get(casoId).SEG_Subestado__c = 'En curso';
					} else if (casosOld.get(casoId).Status == 'Planificado'
					&& casosNew.get(casoId).Status != 'Planificado'
					&& casosNew.get(casoId).SEG_Fecha_planificaci_n__c != null) {
						//Se ha salido de estado "Planificado" de un caso confecha de planificación informada
						casosNew.get(casoId).SEG_Fecha_planificaci_n__c = null;
					}
			}
		}
	}

	/**
	 * @description Metodo para calcular los cargos de un contacto en el caso segun la empresa.
	 * @param case
	 */
	public static void cargosContactoCaso (List<Id> casosSegmentos, Map<Id, Case> mapNewObj, Map<Id, Case> mapOldObj){
		//Id recordTypeAccountPA = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
		Map<Id, Id> contactCase = new Map<Id, Id>();
		Map<Id, Id> accountCase = new Map<Id, Id>();
		Map<Id, String> contactCargosOp = new Map<Id, String>();
		Map<Id, String> accountCargosOp = new Map<Id, String>();
		Map<Id, String> contactCargosSind = new Map<Id, String>();
		Map<Id, String> accountCargosSind = new Map<Id, String>();
		Map<Id, String> casoCargosContactOp = new Map<Id, String>();
		Map<Id, String> casoCargosAccountOp = new Map<Id, String>();
		Map<Id, String> casoCargosContactSind = new Map<Id, String>();
		Map<Id, String> casoCargosAccountSind = new Map<Id, String>();
		Map<Id, String> casoCargosOp = new Map<Id, String>();
		Map<Id, String> casoCargosSind = new Map<Id, String>();
		Map<Id, String> contactosSinCuenta = new Map<Id, String>();
		Map<Id, Id> contactoCuenta = new Map<Id, Id>();
		Map<String, AccountContactRelation> mapaRelaciones = new Map<String, AccountContactRelation> ();
		List<Case> casosUpdate = new List<Case> ();

		List<Id> listCasosModificados = new List<Id>();
		for (Id casoId : casosSegmentos) {
			if (mapNewObj.get(casoId).contactId != mapOldObj.get(casoId).contactId || mapNewObj.get(casoId).accountId != mapOldObj.get(casoId).accountId) {
				listCasosModificados.add(casoId);
			}
		}
		
		if (!listCasosModificados.isEmpty()) {
			for (Id casoId : listCasosModificados){
				if ((mapNewObj.get(casoId).contactId <> mapOldObj.get(casoId).contactId || mapNewObj.get(casoId).accountId <> mapOldObj.get(casoId).accountId)){
					if (mapNewObj.get(casoId).contactId != null){
						contactCase.put(casoId, mapNewObj.get(casoId).ContactId );
						if (mapNewObj.get(casoId).AccountId != null){
							accountCase.put(casoId, mapNewObj.get(casoId).AccountId );
							contactoCuenta.put(mapNewObj.get(casoId).ContactId, mapNewObj.get(casoId).AccountId) ;
						}
						else{
							contactosSinCuenta.put(casoId, mapNewObj.get(casoId).ContactId );
						}
					}
					else{
						Case caso = mapNewObj.get(casoId);
						caso.SEG_Cargos_Operativa__c = null;
						caso.SEG_Creditos_sindicadosContacto__c = null;
					}
				}	
			}
			Map<Id, Contact> mapaContactoSinCuenta = new Map<Id, Contact> ([SELECT id ,accountId FROM contact WHERE id IN: contactosSinCuenta.values()]);
			
			for(Id key : contactosSinCuenta.keySet()){ 
				Id contactIdAux = contactosSinCuenta.get(key) ;
				Id accountIdAux = mapaContactoSinCuenta.get(contactIdAux)?.accountId;
				if(accountIdAux != null){
					accountCase.put(key, accountIdAux);
					contactoCuenta.put(contactIdAux, accountIdAux);
				}
			}
	
			for(AccountContactRelation accContctRelat : [SELECT id,SEG_Cargos_Operativa__c, SEG_Creditos_sindicados__c, AccountId, ContactId 
															FROM AccountContactRelation 
															WHERE AccountId IN:contactoCuenta.values() 
															AND ContactId IN: contactoCuenta.keyset() 
															AND	(Account.recordTypeId =: recordTypeAccountCC 
															OR Account.recordTypeId =: recordTypeAccountSeg
															OR Account.recordTypeId =: recordTypeAccountCaix 
															OR Account.recordTypeId =: recordTypeAccountColab)])
			{
				mapaRelaciones.put(accContctRelat.contactId + '_' + accContctRelat.accountId, accContctRelat);
	
			}	
	
			for(Id key : contactCase.keySet()){ 
				Case caso = mapNewObj.get(key);
				String claveRelacion = contactCase.get(key) + '_' + accountCase.get(key);
				String cargosOperativa = mapaRelaciones.get(claveRelacion)?.SEG_Cargos_Operativa__c;
				String cargosSindicados = mapaRelaciones.get(claveRelacion)?.SEG_Creditos_sindicados__c;			
				caso.SEG_Cargos_Operativa__c = (string.isBlank(cargosOperativa)) ? null : (String.isNotBlank(cargosOperativa) && cargosOperativa.length() <= 255) ? cargosOperativa : cargosOperativa.left(252) + '...';
				caso.SEG_Creditos_sindicadosContacto__c = (string.isBlank(cargosSindicados)) ? null :(String.isNotBlank(cargosSindicados) && cargosSindicados.length() <= 255) ? cargosSindicados : cargosSindicados.left(252) + '...';
			}	
		}
	}

	public static void updateGrupoGestorComercial(List<Id> casosSEG, Map<Id, Case> mapNewObj, Map<Id, Case> mapOldObj) {

		List<Id> lstCasosModificados = new List<Id>();

		for (Id casoId : casosSEG) {
			if (mapNewObj.get(casoId).SEG_IDGestorComercial__c != mapOldObj.get(casoId).SEG_IDGestorComercial__c && mapNewObj.get(casoId).SEG_IDGestorComercial__c != null) {
				lstCasosModificados.add(casoId);
			}
		}

		if (!lstCasosModificados.isEmpty()) {
			String gestorComercialId;
			Map<Id,String> mapaIdGestor = new map<Id,String>();

			for (Id casoId : casosSEG){
				if (mapNewObj.containskey(casoId)){
					gestorComercialId = mapNewObj.get(casoId).SEG_IDGestorComercial__c;
					if(String.isNotBlank(gestorComercialId)){
						mapaIdGestor.put(casoId, gestorComercialId);
					}
					else{
						mapNewObj.get(casoId).SEG_Grupo_BO_Gestor_Comercial__c = '';
					}
				}
			}
			if (!mapaIdGestor.isEmpty()){
				List<SEG_Gestor_Grupo__c> gruposGestores = [SELECT id, SEG_GrupoOperativa__r.Name, SEG_GrupoOperativa__r.SEG_Tipologia__c, SEG_EmpleadoGestor__c
															FROM SEG_Gestor_Grupo__c 
															WHERE SEG_GrupoOperativa__r.SEG_Tipologia__c = 'BO' AND SEG_EmpleadoGestor__c IN: mapaIdGestor.values()]; 

				Map<String,SEG_Gestor_Grupo__c> idGestGrupo = new Map<String, SEG_Gestor_Grupo__c>();			
				
				for (SEG_Gestor_Grupo__c grupoGestor : gruposGestores){
					for(String ide : mapaIdGestor.values()){ 
						if (ide == grupoGestor.SEG_EmpleadoGestor__c){
							idGestGrupo.put(ide, grupoGestor);
						}	
					}
				}
				
				for(Id caseId : mapaIdGestor.keySet()){ 
					if(idGestGrupo.containsKey(mapaIdGestor.get(caseId))){
						mapNewObj.get(caseId).SEG_Grupo_BO_Gestor_Comercial__c = idGestGrupo.get(mapaIdGestor.get(caseId)).SEG_GrupoOperativa__r.Name;
					}	
					else{
						mapNewObj.get(caseId).SEG_Grupo_BO_Gestor_Comercial__c = '';
					}
				}
			}
		}
    }

    public static void CambiarEstadoSLA(List<Id> casosSEG,Map<Id, Case> mapNewObj, Map<Id, Case> mapOldObj){

		List<Id> lstCasosModificados = new List<Id>();

		for (Id casoId : casosSEG) {
			if ((mapNewObj.get(casoId).Status == 'Activo' || mapNewObj.get(casoId).Status == 'Pendiente') && mapNewObj.get(casoId).Status != mapOldObj.get(casoId).Status) {
				lstCasosModificados.add(casoId);
			}
		}

		if (!lstCasosModificados.isEmpty()) {
			List<FeedItem> feedlst = new List<FeedItem>();
			for (Id casoId : lstCasosModificados) {
				if (mapNewObj.get(casoId).Status == 'Activo'){ 
					mapNewObj.get(casoId).IsStopped = false;
				}else if(mapNewObj.get(casoId).Status == 'Pendiente'){
					mapNewObj.get(casoId).IsStopped = true; 
				}
			}
		}
    }
	
	//Actualización de Owner Anterior - US704373 - Cambios en campos de propietarios anteriores
	public static void actualizarPropietarioAnterior(List<Id> casosSEG, Map<Id, Case> mapNewObj, Map<Id, Case> mapOldObj){
		for (Id casoId : casosSEG){
			if (mapNewObj.containsKey(casoId) && mapNewObj.get(casoId).OwnerId != mapOldObj.get(casoId).OwnerId && mapNewObj.get(casoId).CC_Owner_Anterior__c != mapOldObj.get(casoId).OwnerId) {		
				mapNewObj.get(casoId).CC_Owner_Anterior__c=(String.valueOf(mapOldObj.get(casoId).OwnerId.getSobjectType()).EqualsIgnoreCase('User')) ? mapOldObj.get(casoId).OwnerId : mapOldObj.get(casoId).CC_Owner_Anterior__c;
			}
		}
	}

	/**
	* @description Método para indicar el propietario anterior de un caso cuando se mantiene dentro del mismo grupo.
	* @param casosSEG Lista de Ids de los casos
	* @param mapNewObj Mapa de casos nuevos
	* @param mapOldObj Mapa de casos viejos
	*/
	public static void actualizarPropietarioGrupoAnterior(List<Id> casosSEG,Map<Id, Case> mapNewObj, Map<Id, Case> mapOldObj){
		for (Id casoId : casosSEG){
			if (mapNewObj.containsKey(casoId) && mapNewObj.get(casoId).OwnerId != mapOldObj.get(casoId).OwnerId 
			&& mapNewObj.get(casoId).SEG_Grupo__c == mapOldObj.get(casoId).SEG_Grupo__c 
			&& String.valueOf(mapOldObj.get(casoId).OwnerId.getSobjectType()).EqualsIgnoreCase('User')){
				//Si se modifica el propietario sin cambiar de grupo y tanto el nuevo propietario como viejo son usuarios se indicará el propietario viejo en el campo "Propietario anterior del grupo" 				
				mapNewObj.get(casoId).SEG_PropAnteriorGrupo__c = mapOldObj.get(casoId).SEG_Case_Owner__c;
			}
		}
	}

	public static void enviarFeedbackCGNT(List<Id> casosSEG,Map<Id, Case> mapNewObj, Map<Id, Case> mapOldObj){
		// Buscar las CR en modo Bulk.
		Set<Id> listaCRs = new Set<Id>();
		List<Id> listCasosModificados = new List<Id>();

		for (Id casoId : casosSEG) {
			Case caso = mapNewObj.get(casoId);
			if (caso.Status == 'Cerrado' && caso.Status != mapOldObj.get(casoId).Status && caso.SEG_ClasificacionRapida__c != null) {
				listCasosModificados.add(casoId);
				listaCRs.add(caso.SEG_ClasificacionRapida__c);
			}
		}

		if (!listCasosModificados.isEmpty() && !listaCRs.isEmpty()) {
			Map<Id, SEG_ClasificacionRapida__c> mapCognitive = new Map<Id, SEG_ClasificacionRapida__c>([SELECT Name, SEG_Nombre_CR_Cognitive__c FROM SEG_ClasificacionRapida__c WHERE Id IN :listaCRs]);
			
			if(mapCognitive.size() > 0){
				for (Id casoModificado : listCasosModificados) {
					if(mapCognitive.containsKey(mapNewObj.get(casoModificado).SEG_ClasificacionRapida__c) && mapCognitive.get(mapNewObj.get(casoModificado).SEG_ClasificacionRapida__c) != null){
						DateTime dt = DateTime.now();
						Long dateInMilliseconds = dt.getTime();

						AsyncOptions options = new AsyncOptions();
						options.DuplicateSignature = QueueableDuplicateSignature.Builder().addId(casoModificado).addString(String.valueOf(dateInMilliseconds)).build();
						
						if(mapNewObj.get(casoModificado).SEG_Organizacion__c == 'Financiación Estructurada'){
							SEG_feedbackCogFFEE fbCognitiveFFEE = new SEG_feedbackCogFFEE(mapNewObj.get(casoModificado).CaseNumber, mapCognitive.get(mapNewObj.get(casoModificado).SEG_ClasificacionRapida__c).SEG_Nombre_CR_Cognitive__c);
							System.enqueueJob(fbCognitiveFFEE,options);
						}
						else{
							SEG_feedbackCognitive fbCognitive = new SEG_feedbackCognitive(mapNewObj.get(casoModificado).CaseNumber, mapCognitive.get(mapNewObj.get(casoModificado).SEG_ClasificacionRapida__c).SEG_Nombre_CR_Cognitive__c);
							System.enqueueJob(fbCognitive,options);
						}
						
					}
				}
			}
		}
	}

	/**
	 * @description Metodo para rellenar el Buzon de la Zona del caso
	 * @param casosSEG
	 * @param listNewObj
	 * @param allCasosSegmentos
	 */
	public static void rellenarBuzonZona (Map<Id, Case> mapOldObj,Map<Id, Case> mapNewObj, List<Id> allCasosSegmentos){

		List<Id> lastCasosModificados = new List<Id>();

		for (Id casoId : allCasosSegmentos) {
			if ((mapOldObj.get(casoId).SEG_Organizacion__c != mapNewObj.get(casoId).SEG_Organizacion__c ||
			mapOldObj.get(casoId).SEG_Zona__c != mapNewObj.get(casoId).SEG_Zona__c)
			&& mapNewObj.get(casoId).SEG_Zona__c != null && mapNewObj.get(casoId).SEG_Organizacion__c != null) {
				lastCasosModificados.add(casoId);
			}
		}

		if (!lastCasosModificados.isEmpty()) {
			// Query para nombre Zonas e Ids y ORG --> SEG_EMail_SF__c No empezar por invalid
			List<SEG_Buzon__mdt> listaBuzones = [SELECT Id, SEG_Zona__c, SEG_Organizacion__c, SEG_Correo_de_procedencia__c, SEG_EMail_SF__c FROM SEG_Buzon__mdt WHERE (NOT SEG_EMail_SF__c LIKE 'Invalid%')];
			if(!listaBuzones.isEmpty()){
				Map<String, Map<String, String>> mapOrgBuzon = new Map<String, Map<String, String>>();
				for(SEG_Buzon__mdt buzon : listaBuzones){
					if(mapOrgBuzon.containsKey(buzon.SEG_Organizacion__c)){
						mapOrgBuzon.get(buzon.SEG_Organizacion__c).put(buzon.SEG_Zona__c,  buzon.SEG_Correo_de_procedencia__c);
					}else{
						Map<String, String> mapaZonaCorreo = new Map<String, String>();
						mapaZonaCorreo.put(buzon.SEG_Zona__c,  buzon.SEG_Correo_de_procedencia__c);
						// Pasar el mapa 
						mapOrgBuzon.put( buzon.SEG_Organizacion__c, mapaZonaCorreo);
					}
				}
				for(Id casoUpdate : lastCasosModificados){
					if(mapNewObj.containsKey(casoUpdate) && mapOrgBuzon.containsKey(mapNewObj.get(casoUpdate).SEG_Organizacion__c)){
						if(mapOrgBuzon.get(mapNewObj.get(casoUpdate).SEG_Organizacion__c).containsKey(mapNewObj.get(casoUpdate).SEG_Zona__c)){
							mapNewObj.get(casoUpdate).SEG_Buz_n_de_la_zona__c = mapOrgBuzon.get(mapNewObj.get(casoUpdate).SEG_Organizacion__c).get(mapNewObj.get(casoUpdate).SEG_Zona__c);
						}	
					}		
				}
			}
		}
	}

	/**
	 * @description Cliente de la cabecera
	 * @param casosSEG
	 * @param listNewObj
	 * @param casosRellenarCliCabe
	 */
	public static void rellenarClienteCabecera(Map<Id, Case> mapOldObj, Map<Id, Case> mapNewObj,List<Id> casosRellenarCliCabe) {
		List<Id> lstCasosUpdate = new List<Id>();
		Set<Id> setIdAccounts = new Set<Id>();
		
		for(Id casoId : casosRellenarCliCabe){
			if(mapNewObj.containsKey(casoId) && mapOldObj.get(casoId).AccountId != mapNewObj.get(casoId).AccountId){
				if(mapNewObj.get(casoId).AccountId == null){
					mapNewObj.get(casoId).SEG_Cliente_de_la_cabecera__c = null;
				}else{
					lstCasosUpdate.add(casoId);
					setIdAccounts.add(mapNewObj.get(casoId).AccountId);
				}
			}
		}

		if(!lstCasosUpdate.isEmpty() && !setIdAccounts.isEmpty()){
			Map<Id,Account> mapAccount = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id IN :setIdAccounts]);
			for(Id casoCabeceraId : lstCasosUpdate){
				if(mapNewObj.containsKey(casoCabeceraId)){
					if(mapAccount.containsKey(mapNewObj.get(casoCabeceraId).AccountId)){
						mapNewObj.get(casoCabeceraId).SEG_Cliente_de_la_cabecera__c = mapAccount.get(mapNewObj.get(casoCabeceraId).AccountId).Name;
					}
				}
			}
		}
	}

	/**
	* @description US697153 - Comprobación y marcado de casos para el envío a taskconnect SEG_sincronizado_con_TaskConnect__c
	* @param mapNewObj
	* @param casosComprobarEnvioTaskConnect
	*/
	public static void comprobaryMarcarTaskConnect(Map<Id, Case> mapNewObj, Map<Id, Case> mapOldObj, List<Id> casosComprobarEnvioTaskConnect) {

		List<Id> lstCasosModificados = new List<Id>();
		for (Id casoId : casosComprobarEnvioTaskConnect) {
			if ((mapOldObj.get(casoId).SEG_Grupo__c != mapNewObj.get(casoId).SEG_Grupo__c && mapNewObj.get(casoId).SEG_Grupo__c != null) ||
			(mapOldObj.get(casoId).CC_MCC_Tematica__c != mapNewObj.get(casoId).CC_MCC_Tematica__c && mapNewObj.get(casoId).CC_MCC_Tematica__c != null) ||
			(mapOldObj.get(casoId).CC_MCC_ProdServ__c != mapNewObj.get(casoId).CC_MCC_ProdServ__c && mapNewObj.get(casoId).CC_MCC_ProdServ__c != null) ||
			(mapOldObj.get(casoId).CC_MCC_Motivo__c != mapNewObj.get(casoId).CC_MCC_Motivo__c && mapNewObj.get(casoId).CC_MCC_Motivo__c != null) ||
			(mapOldObj.get(casoId).SEG_Detalle__c != mapNewObj.get(casoId).SEG_Detalle__c && mapNewObj.get(casoId).SEG_Detalle__c != null)) {
				lstCasosModificados.add(casoId);
			}
		}

		Boolean grupoGlobalTaskConnect = false;
		Boolean grupoTaskConnect = false;
		Boolean mccTaskConnect = false;

		Set<Id> gruposComprobar = new Set<Id>();
		Set<Id> mccsComprobar = new Set<Id>();

		Map<Id, CC_Grupo_Colaborador__c> mapIdGrupos;
		Map<Id, CC_MCC__c> mapIdMCCs;

		for(Id casoId : lstCasosModificados){
			if(mapNewObj.containsKey(casoId)){
				if(mapNewObj.get(casoId).SEG_Grupo__c != null){
					gruposComprobar.add(mapNewObj.get(casoId).SEG_Grupo__c);
				}
				if(mapNewObj.get(casoId).CC_MCC_Tematica__c != null){
					mccsComprobar.add(mapNewObj.get(casoId).CC_MCC_Tematica__c);
				}
				if(mapNewObj.get(casoId).CC_MCC_ProdServ__c != null){
					mccsComprobar.add(mapNewObj.get(casoId).CC_MCC_ProdServ__c);
				}
				if(mapNewObj.get(casoId).CC_MCC_Motivo__c != null){
					mccsComprobar.add(mapNewObj.get(casoId).CC_MCC_Motivo__c);
				}
				if(mapNewObj.get(casoId).SEG_Detalle__c != null){
					mccsComprobar.add(mapNewObj.get(casoId).SEG_Detalle__c);
				}
			}
		}

		if(!gruposComprobar.isEmpty()) {
			mapIdGrupos = new Map<Id, CC_Grupo_Colaborador__c>([SELECT Id, SEG_envio_a_TaskConnect__c, SEG_Gestion_global_TaskConnect__c FROM CC_Grupo_Colaborador__c WHERE Id IN :gruposComprobar]);
		}

		if(!mccsComprobar.isEmpty()) {
			mapIdMCCs = new Map<Id, CC_MCC__c>([SELECT Id, SEG_envio_a_TaskConnect__c FROM CC_MCC__c WHERE Id IN :mccsComprobar]);
		}

		if(mapIdGrupos != null && !mapIdGrupos.isEmpty() || mapIdMCCs != null && !mapIdMCCs.isEmpty()){
			for(Id casoId : lstCasosModificados){
				grupoTaskConnect = false;
				
				mccTaskConnect = false;
				if(mapNewObj.get(casoId).SEG_Grupo__c != null && mapIdGrupos.containsKey(mapNewObj.get(casoId).SEG_Grupo__c)){
					
					if(mapIdGrupos.get(mapNewObj.get(casoId).SEG_Grupo__c).SEG_envio_a_TaskConnect__c){
					   grupoTaskConnect = true;
					} 
					if(mapIdGrupos.get(mapNewObj.get(casoId).SEG_Grupo__c).SEG_Gestion_global_TaskConnect__c){
						grupoGlobalTaskConnect=true;					
					}
				}

				if((mapNewObj.get(casoId).CC_MCC_Tematica__c != null && mapIdMCCs.containsKey(mapNewObj.get(casoId).CC_MCC_Tematica__c) && mapIdMCCs.get(mapNewObj.get(casoId).CC_MCC_Tematica__c).SEG_envio_a_TaskConnect__c && mapNewObj.get(casoId).CC_MCC_ProdServ__c == null && mapNewObj.get(casoId).CC_MCC_Motivo__c == null &&  mapNewObj.get(casoId).SEG_Detalle__c == null) ||
					(mapNewObj.get(casoId).CC_MCC_Tematica__c != null && mapIdMCCs.containsKey(mapNewObj.get(casoId).CC_MCC_Tematica__c) && mapIdMCCs.get(mapNewObj.get(casoId).CC_MCC_Tematica__c).SEG_envio_a_TaskConnect__c && mapNewObj.get(casoId).CC_MCC_ProdServ__c != null && mapIdMCCs.containsKey(mapNewObj.get(casoId).CC_MCC_ProdServ__c) && mapIdMCCs.get(mapNewObj.get(casoId).CC_MCC_ProdServ__c).SEG_envio_a_TaskConnect__c && mapNewObj.get(casoId).CC_MCC_Motivo__c == null &&  mapNewObj.get(casoId).SEG_Detalle__c == null) ||
					(mapNewObj.get(casoId).CC_MCC_Tematica__c != null && mapIdMCCs.containsKey(mapNewObj.get(casoId).CC_MCC_Tematica__c) && mapIdMCCs.get(mapNewObj.get(casoId).CC_MCC_Tematica__c).SEG_envio_a_TaskConnect__c && mapNewObj.get(casoId).CC_MCC_ProdServ__c != null && mapIdMCCs.containsKey(mapNewObj.get(casoId).CC_MCC_ProdServ__c) && mapIdMCCs.get(mapNewObj.get(casoId).CC_MCC_ProdServ__c).SEG_envio_a_TaskConnect__c && mapNewObj.get(casoId).CC_MCC_Motivo__c != null && mapIdMCCs.containsKey(mapNewObj.get(casoId).CC_MCC_Motivo__c) && mapIdMCCs.get(mapNewObj.get(casoId).CC_MCC_Motivo__c).SEG_envio_a_TaskConnect__c && mapNewObj.get(casoId).SEG_Detalle__c == null) ||
					(mapNewObj.get(casoId).CC_MCC_Tematica__c != null && mapIdMCCs.containsKey(mapNewObj.get(casoId).CC_MCC_Tematica__c) && mapIdMCCs.get(mapNewObj.get(casoId).CC_MCC_Tematica__c).SEG_envio_a_TaskConnect__c && mapNewObj.get(casoId).CC_MCC_ProdServ__c != null && mapIdMCCs.containsKey(mapNewObj.get(casoId).CC_MCC_ProdServ__c) && mapIdMCCs.get(mapNewObj.get(casoId).CC_MCC_ProdServ__c).SEG_envio_a_TaskConnect__c && mapNewObj.get(casoId).CC_MCC_Motivo__c != null && mapIdMCCs.containsKey(mapNewObj.get(casoId).CC_MCC_Motivo__c) && mapIdMCCs.get(mapNewObj.get(casoId).CC_MCC_Motivo__c).SEG_envio_a_TaskConnect__c && mapNewObj.get(casoId).SEG_Detalle__c != null && mapIdMCCs.containsKey(mapNewObj.get(casoId).SEG_Detalle__c) && mapIdMCCs.get(mapNewObj.get(casoId).SEG_Detalle__c).SEG_envio_a_TaskConnect__c)){
					mccTaskConnect = true;
				}

				if((grupoTaskConnect && mccTaskConnect) || grupoGlobalTaskConnect){
					mapNewObj.get(casoId).SEG_sincronizado_con_TaskConnect__c = true;
				}
			}
		}
	}

	/**
	* @description US686562 - Casos manuales- pestaña gestión
	* @param mapNewObj
	* @param casosSegmentos
	*/
	public static void casosManuales(Map<Id, Case> mapNewObj, Map<Id, Case> mapOldObj, List<Id> casosSegmentos) {
		List<Case> casosOrgModificada = new List<Case>();
		Set<Id> idsClasificaciones = new Set<Id>();
		for (Id casoSeg : casosSegmentos) {
			if(mapNewObj.get(casoSeg).SEG_ClasificacionRapida__c != null &&	mapNewObj.get(casoSeg).SEG_Organizacion__c != mapOldObj.get(casoSeg).SEG_Organizacion__c){
				if (mapNewObj.get(casoSeg).SEG_Organizacion__c != null) {
					casosOrgModificada.add(mapNewObj.get(casoSeg));
					idsClasificaciones.add(mapNewObj.get(casoSeg).SEG_ClasificacionRapida__c);
				} else {
					mapNewObj.get(casoSeg).SEG_ClasificacionRapida__c = null;
					mapNewObj.get(casoSeg).CC_MCC_Tematica__c = null;
					mapNewObj.get(casoSeg).CC_MCC_ProdServ__c = null;
					mapNewObj.get(casoSeg).CC_MCC_Motivo__c = null;
					mapNewObj.get(casoSeg).SEG_Detalle__c = null;
				}
			}
		}

		if (!casosOrgModificada.isEmpty() && !idsClasificaciones.isEmpty()) {
			Map<Id, SEG_ClasificacionRapida__c> mapaCRs = new Map<Id, SEG_ClasificacionRapida__c>([SELECT Id, SEG_Organizacion__c FROM SEG_ClasificacionRapida__c WHERE Id IN :idsClasificaciones]);

			for (Case casoOrgModificada : casosOrgModificada) {
				if(mapaCRs != null && casoOrgModificada.SEG_ClasificacionRapida__c != null && casoOrgModificada.SEG_Organizacion__c != null && mapaCRs.containsKey(casoOrgModificada.SEG_ClasificacionRapida__c) && mapaCRs.get(casoOrgModificada.SEG_ClasificacionRapida__c).SEG_Organizacion__c != null && !mapaCRs.get(casoOrgModificada.SEG_ClasificacionRapida__c).SEG_Organizacion__c.contains(casoOrgModificada.SEG_Organizacion__c)){
					casoOrgModificada.SEG_ClasificacionRapida__c = null;
					casoOrgModificada.CC_MCC_Tematica__c = null;
					casoOrgModificada.CC_MCC_ProdServ__c = null;
					casoOrgModificada.CC_MCC_Motivo__c = null;
					casoOrgModificada.SEG_Detalle__c = null;
				}
			}
		}
	}

	/**
	* @description US752749 - Reapertura de casos - Grupo alternativo
	* @param mapNewObj
	* @param mapOldObj
	* @param casosSegmentos
	*/
	public static void reaperturaCasoGrupoInactivo(Map<Id, Case> mapNewObj, Map<Id, Case> mapOldObj, List<Id> casosSegmentos) {
		List<Case> casosReabiertos = new List<Case>();
		Set<Id> idsGrupos = new Set<Id>();
		for (Id casoSeg : casosSegmentos) {
			if(mapOldObj.get(casoSeg).Status == 'Cerrado' && mapNewObj.get(casoSeg).Status != 'Cerrado' && mapNewObj.get(casoSeg).SEG_Grupo__c != null){
				casosReabiertos.add(mapNewObj.get(casoSeg));
				idsGrupos.add(mapNewObj.get(casoSeg).SEG_Grupo__c);
			}
		}

		if (!casosReabiertos.isEmpty() && !idsGrupos.isEmpty()) {
			Map<Id, CC_Grupo_Colaborador__c> mapGruposColaboradores = new Map<Id, CC_Grupo_Colaborador__c>([SELECT Id, SEG_Inactivo__c, SEG_GrupoAlternativo__c FROM CC_Grupo_Colaborador__c WHERE Id IN: idsGrupos]);
			for (Case casoReabierto : casosReabiertos) {
				if(casoReabierto.SEG_Grupo__c != null && mapGruposColaboradores.containsKey(casoReabierto.SEG_Grupo__c) && mapGruposColaboradores.get(casoReabierto.SEG_Grupo__c).SEG_Inactivo__c && mapGruposColaboradores.get(casoReabierto.SEG_Grupo__c).SEG_GrupoAlternativo__c != null){
					casoReabierto.SEG_Grupo__c = mapGruposColaboradores.get(casoReabierto.SEG_Grupo__c).SEG_GrupoAlternativo__c;
				}
			}
		}
	}

	/**
     * @description Actualizar campo SEG_Check_Contratos__c y SEG_SRContratos__c
     *  @param casosSEG -> Lista de casos con los valores nuevos.
	 *  @param mapNewObj
	 *  @param mapOldObj
     */ 
    public static void srContratos(List<Id> casosSEG, Map<Id, Case> mapNewObj, Map<Id, Case> mapOldObj)
    {          
		for (Id casoId : casosSEG){
			if (mapOldObj.get(casoId).SEG_SRContratos__c!=mapNewObj.get(casoId).SEG_SRContratos__c){ 
        		
				if(mapOldObj.get(casoId).SEG_SRContratos__c!='Contratos'){
						mapNewObj.get(casoId).SEG_SRContratos__c='Contratos';
				}
                    
				mapNewObj.get(casoId).SEG_Check_Contratos__c=true;            	
        	}    
		}  
    }

	/**
     * @description Blanquear campo SEG_SRContratos__c si no tiene el record type SEG_Seguimiento
     *  @param casosSEG -> Lista de casos con los valores nuevos.
	 *  @param mapNewObj
	 *  @param mapOldObj
     */ 
    public static void srContratosBlanqueo(List<Id> casosSEG, Map<Id, Case> mapNewObj, Map<Id, Case> mapOldObj)
    {    
		for (Id casoId : casosSEG){        				
            if(mapOldObj.get(casoId).SEG_SRContratos__c!=mapNewObj.get(casoId).SEG_SRContratos__c){
				mapNewObj.get(casoId).SEG_SRContratos__c='';
			}                                        	
        }      		
    }

}