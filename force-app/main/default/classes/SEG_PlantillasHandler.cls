public class SEG_PlantillasHandler {
	
	public class SEG_AcuseRecibo implements Queueable {
		private Case caso { get; set; }
		private String operativa { get; set; }
		private Id contactId { get; set; }

		public SEG_AcuseRecibo(Case caso, String operativa, Id contId) {
			this.caso = caso;
			this.operativa = operativa;
			this.contactId = contId;
		}

		public void execute(QueueableContext context) {
			List<Contact> lstcontacto = [SELECT Name, CC_Idioma__C, Email FROM Contact WHERE id = :contactId];
			
			if (lstcontacto.size() == 1) {
				Contact contacto = lstcontacto[0];
				
				Map<Id, List<SEG_Plantilla__c>> plantillas = SEG_PlantillasHandler.determinarPlantillas(new List<Case>{caso}, operativa);
				//Account cuenta = SEG_PlantillasHandler.determinarCuenta(new List<Case> {caso});
				
				String plantillaIdioma;
				SEG_Plantilla__c plantillaCierre;
				List<SEG_Plantilla__c> plantilla = new List<SEG_Plantilla__c> ();
				
				if (plantillas.size() == 1) {
					for (List<SEG_Plantilla__c> lP : plantillas.values()) {
						for (SEG_Plantilla__c p : lP) {
							plantilla.add(p);
						}
					}
					plantillaCierre = plantilla[0];
					if (contacto.CC_Idioma__c != null) {
						if (contacto.CC_Idioma__c == 'ga') {plantillaIdioma = plantillaCierre.SEG_PlantillaGalegoID__c;
						} else if (contacto.CC_Idioma__c == 'ca') {plantillaIdioma = plantillaCierre.SEG_PlantillaCatalanID__c;
						} else if (contacto.CC_Idioma__c == 'en') {plantillaIdioma = plantillaCierre.SEG_PlantillaInglesID__c;
						} else if (contacto.CC_Idioma__c == 'eu') {plantillaIdioma = plantillaCierre.SEG_PlantillaEuskeraID__c;
						} else {
							plantillaIdioma = plantillaCierre.SEG_PlantillaCastellanoID__c;
						}
					} else {
						plantillaIdioma = plantillaCierre.SEG_PlantillaCastellanoID__c;
					}
					SEG_MetodosComunes.enviarCorreoAcuse(plantillaIdioma, caso.Id, contacto);
					//SEG_MetodosComunes.enviarCorreoAcuseBool(plantillaIdioma, caso.Id, contacto, cuenta);
				}
			}
		}
	}

	public static Account determinarCuenta(List<Case> lstCs) {
		Set<Id> caseIds = new Set<Id> ();
		for (Case cas : lstCs) {
			caseIds.add(cas.Id);
		}
		
		List<Case> lstCase = [SELECT AccountId, SEG_Organizacion__c, SEG_Zona__c, CC_MCC_Tematica__c, CC_MCC_ProdServ__c,
								CC_MCC_Motivo__c, SEG_Detalle__c, SEG_Grupo__c, SEG_Numero_centro__c, SEG_Grupo_Empresa__c,
								SEG_ClasificacionRapida__c,	Account.SEG_Oficina_Gestora_Segmentos__c, SEG_Resultado__c
								FROM Case WHERE Id IN :caseIds];
		
		List<Account> cuenta = [SELECT SEG_EnviarAcuse__c, SEG_No_enviar_Acuse_Recibo_Empresa__c FROM Account WHERE Id = :lstCase[0].AccountId];
		return cuenta[0];
	}
	
	public static Map<Id, List<SEG_Plantilla__c>> determinarPlantillas(List<Case> lstCs, String operativa) {
		return determinarPlantillas(lstCs, operativa, null);
	}

	public static Map<Id, List<SEG_Plantilla__c>> determinarPlantillas(List<Case> lstCs, String operativa, String resultado) {
		Map<Id, List<SEG_Plantilla__c>> mapCaseLstPlantillas = new Map<Id, List<SEG_Plantilla__c>>();
		
		/*
		Map<Id, SEG_Plantilla__c> mapPlantillas;
		
		if (operativa == 'Cierre' && String.isNotBlank(resultado)) {
			mapPlantillas = new Map<Id, SEG_Plantilla__c>(
				[SELECT SEG_Organizacion__c, SEG_Zona__c, SEG_Activa__c,
					SEG_PlantillaCastellanoID__c, SEG_PlantillaCatalanID__c, SEG_PlantillaEuskeraID__c, SEG_PlantillaGalegoID__c,
					SEG_PlantillaInglesID__c, SEG_TipoOperativa__c, Reclamaciones__c, SEG_Resultado__c FROM SEG_Plantilla__c
					WHERE SEG_TipoOperativa__c = :operativa AND SEG_Activa__c = TRUE AND SEG_Resultado__c = :resultado]);
		} else {
			mapPlantillas = new Map<Id, SEG_Plantilla__c>(
				[SELECT SEG_Organizacion__c, SEG_Zona__c, SEG_Activa__c,
					SEG_PlantillaCastellanoID__c, SEG_PlantillaCatalanID__c, SEG_PlantillaEuskeraID__c, SEG_PlantillaGalegoID__c,
					SEG_PlantillaInglesID__c, SEG_TipoOperativa__c, Reclamaciones__c, SEG_Resultado__c FROM SEG_Plantilla__c
					WHERE SEG_TipoOperativa__c = :operativa AND SEG_Activa__c = TRUE]);
		}
		*/

		Map<Id, SEG_Plantilla__c> mapPlantillas = new Map<Id, SEG_Plantilla__c>([SELECT SEG_Organizacion__c, SEG_Zona__c, SEG_Activa__c,
				SEG_PlantillaCastellanoID__c, SEG_PlantillaCatalanID__c, SEG_PlantillaEuskeraID__c, SEG_PlantillaGalegoID__c,
				SEG_PlantillaInglesID__c, SEG_TipoOperativa__c, Reclamaciones__c, SEG_Resultado__c FROM SEG_Plantilla__c
				WHERE SEG_TipoOperativa__c = :operativa AND SEG_Activa__c = TRUE]);

		Set<Id> idCasos = new Set<Id>();
		for (Case caso : lstCs) {
			idCasos.add(caso.Id);
		}
		
		List<Case> lstCase = [SELECT AccountId, SEG_Organizacion__c, SEG_Zona__c, CC_MCC_Tematica__c, CC_MCC_ProdServ__c,
								CC_MCC_Motivo__c, SEG_Detalle__c, SEG_Grupo__c, SEG_Numero_centro__c, SEG_Grupo_Empresa__c,
								SEG_ClasificacionRapida__c, Account.SEG_Prioridad_Carterizacion_Segmentos__c, Account.AV_OficinaPrincipal__c,
								Account.SEG_Oficina_Gestora_Segmentos__c, SEG_Resultado__c
								FROM Case WHERE Id IN :idCasos];

		Map<Id, Map<String, List<SEG_ExcepcionesCentro__c>>> mapPlantillaDetallesCenEmpresa = generateMapForSEG_ExcepcionesCentro(mapPlantillas);
		Map<Id, Map<String, List<SEG_ExcepcionesGrupo__c>>> mapPlantillaDetallesGrupoTrabajo = generateMapForSEG_ExcepcionesGrupo(mapPlantillas);
		Map<Id, Map<String, List<SEG_ExcepcionesGrupoEmpresa__c>>> mapPlantillaDetallesGrupoEmpresas = generateMapForSEG_ExcepcionesGrupoEmpresa(mapPlantillas);
		Map<Id, Map<String, List<SEG_ExcepcionesEmpresa__c>>> mapPlantillaDetallesEmpresas = generateMapForSEG_ExcepcionesEmpresa(mapPlantillas);
		Map<Id, Map<String, List<SEG_ExcepcionesCR__c>>> mapPlantillaCR = generateMapForSEG_ExcepcionesCR(mapPlantillas);

		List<String> lstOrganizacion;
		List<String> lstZona;
		String lang;
		Map<Id, SEG_Plantilla__c> mapPlantByCaseRecla = new Map<Id, SEG_Plantilla__c>();

		for (Case caso : lstCase) {
			for (SEG_Plantilla__c plantilla : mapPlantillas.values()) {
				lstOrganizacion = null;
				lstZona = null;
				
				if (plantilla.SEG_Organizacion__c != null) {
					lstOrganizacion = plantilla.SEG_Organizacion__c.split(';');
				}

				if (plantilla.SEG_Zona__c != null) {
					lstZona = plantilla.SEG_Zona__c.split(';');
				}

				if (lstOrganizacion != null && lstOrganizacion.contains(caso.SEG_Organizacion__c)
				&& lstZona == null || lstZona.contains(caso.SEG_Zona__c)
				&& (operativa != 'Cierre' || operativa == 'Cierre' && resultado == caso.SEG_Resultado__c)) {
					mapPlantByCaseRecla.put(plantilla.Id, plantilla);
				}
			}

			String centro = caso.Account?.AV_OficinaPrincipal__c;
			
			if (caso.Account?.SEG_Prioridad_Carterizacion_Segmentos__c && caso.Account?.SEG_Oficina_Gestora_Segmentos__c != null) {
				centro = caso.Account?.SEG_Oficina_Gestora_Segmentos__c;
			}

			filterTemplateByExceptionCentros(centro, mapPlantByCaseRecla, mapPlantillaDetallesCenEmpresa);
			filterTemplateByExceptionGrupos(caso.SEG_Grupo__c, mapPlantByCaseRecla, mapPlantillaDetallesGrupoTrabajo);
			filterTemplateByExceptionGruposEmpresas(caso, mapPlantByCaseRecla, mapPlantillaDetallesGrupoEmpresas, mapPlantillaDetallesEmpresas);
			filterTemplateByExceptionCR(caso.SEG_ClasificacionRapida__c, mapPlantByCaseRecla, mapPlantillaCR);

			if (mapPlantByCaseRecla.size() > 0) {
				mapCaseLstPlantillas.put(caso.Id, mapPlantByCaseRecla.values());
			}
		}
		return mapCaseLstPlantillas;
	}
	
	private static Map<Id, Map<String, List<SEG_ExcepcionesCentro__c>>> generateMapForSEG_ExcepcionesCentro(Map<Id, SEG_Plantilla__c> mapPlantillas) {
		List<SEG_ExcepcionesCentro__c> detallesCentros = [SELECT SEG_Plantilla__c, SEG_CentroEmpresa__c FROM SEG_ExcepcionesCentro__c
															WHERE SEG_Plantilla__c in :mapPlantillas.keySet()];
		
		Map<Id, Map<String, List<SEG_ExcepcionesCentro__c>>> mapPlantillaDetallesCenEmpresa = new Map<Id, Map<String, List<SEG_ExcepcionesCentro__c>>>();
		for (SEG_ExcepcionesCentro__c exCentro : detallesCentros) 
		{
			if (mapPlantillaDetallesCenEmpresa.containsKey(exCentro.SEG_Plantilla__c)&& mapPlantillaDetallesCenEmpresa.get(exCentro.SEG_Plantilla__c).containsKey(exCentro.SEG_CentroEmpresa__c)) {
				mapPlantillaDetallesCenEmpresa.get(exCentro.SEG_Plantilla__c).get(exCentro.SEG_CentroEmpresa__c).add(exCentro);
			} else if (mapPlantillaDetallesCenEmpresa.containsKey(exCentro.SEG_Plantilla__c)) {
				mapPlantillaDetallesCenEmpresa.get(exCentro.SEG_Plantilla__c).put(exCentro.SEG_CentroEmpresa__c, new List<SEG_ExcepcionesCentro__c>{exCentro});
			} else {
				Map<String, List<SEG_ExcepcionesCentro__c>> mapCenEmpresaDetallesCen = new Map<String, List<SEG_ExcepcionesCentro__c>>{exCentro.SEG_CentroEmpresa__c => new List<SEG_ExcepcionesCentro__c>{exCentro}};
				mapPlantillaDetallesCenEmpresa.put(exCentro.SEG_Plantilla__c, mapCenEmpresaDetallesCen);
			}
		}
		return mapPlantillaDetallesCenEmpresa;
	}
	
	private static Map<Id, Map<String, List<SEG_ExcepcionesGrupo__c>>> generateMapForSEG_ExcepcionesGrupo(Map<Id, SEG_Plantilla__c> mapPlantillas) {
		List<SEG_ExcepcionesGrupo__c> detallesGrupos = [SELECT SEG_Plantilla__c, SEG_GrupoTrabajoTexto__c FROM SEG_ExcepcionesGrupo__c
														WHERE SEG_Plantilla__c in :mapPlantillas.keySet()];
		
		Map<Id, Map<String, List<SEG_ExcepcionesGrupo__c>>> mapPlantillaDetallesGrupoTrabajo = new Map<Id, Map<String, List<SEG_ExcepcionesGrupo__c>>>();
		for (SEG_ExcepcionesGrupo__c exGrupo : detallesGrupos) 
		{
			if (mapPlantillaDetallesGrupoTrabajo.containsKey(exGrupo.SEG_Plantilla__c) && mapPlantillaDetallesGrupoTrabajo.get(exGrupo.SEG_Plantilla__c).containsKey(exGrupo.SEG_GrupoTrabajoTexto__c)) {
				mapPlantillaDetallesGrupoTrabajo.get(exGrupo.SEG_Plantilla__c).get(exGrupo.SEG_GrupoTrabajoTexto__c).add(exGrupo);
			} else if (mapPlantillaDetallesGrupoTrabajo.containsKey(exGrupo.SEG_Plantilla__c)) {
				mapPlantillaDetallesGrupoTrabajo.get(exGrupo.SEG_Plantilla__c).put(exGrupo.SEG_GrupoTrabajoTexto__c, new List<SEG_ExcepcionesGrupo__c>{exGrupo});
			} else {
				Map<String, List<SEG_ExcepcionesGrupo__c>> mapGrupoTraDetallesGrupo = new Map<String, List<SEG_ExcepcionesGrupo__c>>{
					exGrupo.SEG_GrupoTrabajoTexto__c => new List<SEG_ExcepcionesGrupo__c>{exGrupo}
				};
				mapPlantillaDetallesGrupoTrabajo.put(exGrupo.SEG_Plantilla__c, mapGrupoTraDetallesGrupo);
			}
		}
		return mapPlantillaDetallesGrupoTrabajo;
	}
	
	private static Map<Id, Map<String, List<SEG_ExcepcionesGrupoEmpresa__c>>> generateMapForSEG_ExcepcionesGrupoEmpresa(Map<Id, SEG_Plantilla__c> mapPlantillas) {
		List<SEG_ExcepcionesGrupoEmpresa__c> detallesGruposEmpresa = [SELECT SEG_Plantilla__c, SEG_GrupoEmpresa__c
																		FROM SEG_ExcepcionesGrupoEmpresa__c WHERE SEG_Plantilla__c IN :mapPlantillas.keySet()];
		Map<Id, Map<String, List<SEG_ExcepcionesGrupoEmpresa__c>>> mapPlantillaDetallesGrupoEmpresa = new Map<Id, Map<String, List<SEG_ExcepcionesGrupoEmpresa__c>>>();
		for (SEG_ExcepcionesGrupoEmpresa__c exGrupoEmpr : detallesGruposEmpresa) 
		{
			if (mapPlantillaDetallesGrupoEmpresa.containsKey(exGrupoEmpr.SEG_Plantilla__c)&& mapPlantillaDetallesGrupoEmpresa.get(exGrupoEmpr.SEG_Plantilla__c).containsKey(exGrupoEmpr.SEG_GrupoEmpresa__c)) {
				mapPlantillaDetallesGrupoEmpresa.get(exGrupoEmpr.SEG_Plantilla__c).get(exGrupoEmpr.SEG_GrupoEmpresa__c).add(exGrupoEmpr);
			} else if (mapPlantillaDetallesGrupoEmpresa.containsKey(exGrupoEmpr.SEG_Plantilla__c)) {
				mapPlantillaDetallesGrupoEmpresa.get(exGrupoEmpr.SEG_Plantilla__c).put(exGrupoEmpr.SEG_GrupoEmpresa__c, new List<SEG_ExcepcionesGrupoEmpresa__c> { exGrupoEmpr });
			} else {
				Map<String, List<SEG_ExcepcionesGrupoEmpresa__c>> mapGrupoGrupoDetallesGrupo = new Map<String, List<SEG_ExcepcionesGrupoEmpresa__c>>{
					exGrupoEmpr.SEG_GrupoEmpresa__c => new List<SEG_ExcepcionesGrupoEmpresa__c>{exGrupoEmpr}
				};
				mapPlantillaDetallesGrupoEmpresa.put(exGrupoEmpr.SEG_Plantilla__c, mapGrupoGrupoDetallesGrupo);
			}
		}
		return mapPlantillaDetallesGrupoEmpresa;
	}

	private static Map<Id, Map<String, List<SEG_ExcepcionesEmpresa__c>>> generateMapForSEG_ExcepcionesEmpresa(Map<Id, SEG_Plantilla__c> mapPlantillas) {
		List<SEG_ExcepcionesEmpresa__c> detallesEmpresa = [SELECT SEG_Plantilla__c, SEG_Empresa__c FROM SEG_ExcepcionesEmpresa__c WHERE SEG_Plantilla__c IN :mapPlantillas.keySet()];
		Map<Id, Map<String, List<SEG_ExcepcionesEmpresa__c>>> mapPlantillaDetallesEmpresas = new Map<Id, Map<String, List<SEG_ExcepcionesEmpresa__c>>>();
		for (SEG_ExcepcionesEmpresa__c exEmpr : detallesEmpresa) 
		{
			if (mapPlantillaDetallesEmpresas.containsKey(exEmpr.SEG_Plantilla__c)&& mapPlantillaDetallesEmpresas.get(exEmpr.SEG_Plantilla__c).containsKey(exEmpr.SEG_Empresa__c)) {
				mapPlantillaDetallesEmpresas.get(exEmpr.SEG_Plantilla__c).get(exEmpr.SEG_Empresa__c).add(exEmpr);
			} else if (mapPlantillaDetallesEmpresas.containsKey(exEmpr.SEG_Plantilla__c)) {
				mapPlantillaDetallesEmpresas.get(exEmpr.SEG_Plantilla__c).put(exEmpr.SEG_Empresa__c, new List<SEG_ExcepcionesEmpresa__c>{exEmpr});
			} else {
				Map<String, List<SEG_ExcepcionesEmpresa__c>> mapGrupoGrupoDetallesGrupo = new Map<String, List<SEG_ExcepcionesEmpresa__c>>{
					exEmpr.SEG_Empresa__c => new List<SEG_ExcepcionesEmpresa__c>{exEmpr}
				};
				mapPlantillaDetallesEmpresas.put(exEmpr.SEG_Plantilla__c, mapGrupoGrupoDetallesGrupo);
			}
		}
		return mapPlantillaDetallesEmpresas;
	}

	private static Map<Id, Map<String, List<SEG_ExcepcionesCR__c>>> generateMapForSEG_ExcepcionesCR(Map<Id, SEG_Plantilla__c> mapPlantillas) {
		List<SEG_ExcepcionesCR__c> detallesCR = [SELECT SEG_Plantilla__c, SEG_ClasificacionRapida__c
													FROM SEG_ExcepcionesCR__c WHERE SEG_Plantilla__c IN :mapPlantillas.keySet()];
		Map<Id, Map<String, List<SEG_ExcepcionesCR__c>>> mapPlantillaDetallesCR = new Map<Id, Map<String, List<SEG_ExcepcionesCR__c>>>();
		for (SEG_ExcepcionesCR__c exCR : detallesCR) 
		{
			if (mapPlantillaDetallesCR.containsKey(exCR.SEG_Plantilla__c)&& mapPlantillaDetallesCR.get(exCR.SEG_Plantilla__c).containsKey(exCR.SEG_ClasificacionRapida__c)) {
				mapPlantillaDetallesCR.get(exCR.SEG_Plantilla__c).get(exCR.SEG_ClasificacionRapida__c).add(exCR);
			} else if (mapPlantillaDetallesCR.containsKey(exCR.SEG_Plantilla__c)) {
				mapPlantillaDetallesCR.get(exCR.SEG_Plantilla__c).put(exCR.SEG_ClasificacionRapida__c, new List<SEG_ExcepcionesCR__c> { exCR });
			} else {
				Map<String, List<SEG_ExcepcionesCR__c>> mapCRDetalleCR = new Map<String, List<SEG_ExcepcionesCR__c>>{
					exCR.SEG_ClasificacionRapida__c => new List<SEG_ExcepcionesCR__c> {exCR}
				};
				mapPlantillaDetallesCR.put(exCR.SEG_Plantilla__c, mapCRDetalleCR);
			}
		}
		return mapPlantillaDetallesCR;
	}
	
	private static void filterTemplateByExceptionCentros(String numCentroCase, Map<Id, SEG_Plantilla__c> mapPlantByCaseRecla, Map<Id, Map<String, List<SEG_ExcepcionesCentro__c>>> mapPlantillaDetallesCenEmpresa) {
		Set<Id> setPlantillasIdByExCentrosNumeroCentro = new Set<Id>();
		Set<Id> setPlantillasIdByExCentros = new Set<Id>();
		//Filtrar plantillas (caso y tipo reclamacion) por excepciones
		for (SEG_Plantilla__c plantilla : mapPlantByCaseRecla.values()) 
		{
			if (mapPlantillaDetallesCenEmpresa?.get(plantilla.Id)?.get(numCentroCase) != null) {setPlantillasIdByExCentrosNumeroCentro.add(plantilla.Id);
			}
			if (mapPlantillaDetallesCenEmpresa?.get(plantilla.Id) != null) {setPlantillasIdByExCentros.add(plantilla.Id);
			}
		}
		if (setPlantillasIdByExCentrosNumeroCentro.size() > 0) {
			for (Id plantillaId : mapPlantByCaseRecla.keySet()) {
				if (!setPlantillasIdByExCentrosNumeroCentro.contains(plantillaId)) {mapPlantByCaseRecla.remove(plantillaId);
				}
			}
		} else {
			for (Id plantillaId : mapPlantByCaseRecla.keySet()) 
			{
				if (setPlantillasIdByExCentros.contains(plantillaId)) {
					mapPlantByCaseRecla.remove(plantillaId);
				}
			}
		}
	}
	
	private static void filterTemplateByExceptionGrupos(String numGrupoCase, Map<Id, SEG_Plantilla__c> mapPlantByCaseRecla, Map<Id, Map<String, List<SEG_ExcepcionesGrupo__c>>> mapPlantillaDetallesGrupoTrabajo) {
		Set<Id> setPlantillasIdByExGrupoGrTrabajo = new Set<Id>();
		Set<Id> setPlantillasIdByExGrupo = new Set<Id>();
		//Filtrar plantillas (caso y tipo reclamacion) por excepciones
		for (SEG_Plantilla__c plantilla : mapPlantByCaseRecla.values()) 
		{
			if (mapPlantillaDetallesGrupoTrabajo?.get(plantilla.Id)?.get(numGrupoCase) != null) {
				setPlantillasIdByExGrupoGrTrabajo.add(plantilla.Id);
			}
			if (mapPlantillaDetallesGrupoTrabajo?.get(plantilla.Id) != null) {
				setPlantillasIdByExGrupo.add(plantilla.Id);
			}
		}
		if (setPlantillasIdByExGrupoGrTrabajo.size() > 0) {
			for (Id plantillaId : mapPlantByCaseRecla.keySet()) 
			{
				if (!setPlantillasIdByExGrupoGrTrabajo.contains(plantillaId)) {mapPlantByCaseRecla.remove(plantillaId);
				}
			}
		} else {
			for (Id plantillaId : mapPlantByCaseRecla.keySet()) {
				if (setPlantillasIdByExGrupo.contains(plantillaId)) {mapPlantByCaseRecla.remove(plantillaId);
				}
			}
		}
	}
	
	private static void filterTemplateByExceptionGruposEmpresas(Case cs, Map<Id, SEG_Plantilla__c> mapPlantByCaseRecla, Map<Id, Map<String, List<SEG_ExcepcionesGrupoEmpresa__c>>> mapPlantillaDetallesGrupoEmpresas, Map<Id, Map<String, List<SEG_ExcepcionesEmpresa__c>>> mapPlantillaDetallesEmpresas) {
		Set<Id> setPlantillasIdByExGrupoEmpresaByGrupo = new Set<Id>();
		Set<Id> setPlantillasIdByExGrupoEmpresa = new Set<Id>();
		//Filtrar plantillas (caso y tipo reclamacion) por excepciones
		for (SEG_Plantilla__c plantilla : mapPlantByCaseRecla.Values()) 
		{
			if (mapPlantillaDetallesGrupoEmpresas?.get(plantilla.Id)?.get(cs.SEG_Grupo_Empresa__c) != null) {
				setPlantillasIdByExGrupoEmpresaByGrupo.add(plantilla.Id);
			}
			if (mapPlantillaDetallesGrupoEmpresas?.get(plantilla.Id) != null) {
				setPlantillasIdByExGrupoEmpresa.add(plantilla.Id);
			}
		}
		if (setPlantillasIdByExGrupoEmpresaByGrupo.size() > 0) {
			for (Id plantillaId : mapPlantByCaseRecla.keySet()) 
			{
				if (setPlantillasIdByExGrupoEmpresaByGrupo.contains(plantillaId)) {
					mapPlantByCaseRecla.remove(plantillaId);
				}
			}
		} else {
			filterTemplateByExceptionEmpresas(cs.AccountId, mapPlantByCaseRecla, mapPlantillaDetallesEmpresas);
		}
	}
	
	private static void filterTemplateByExceptionEmpresas(String accountId, Map<Id, SEG_Plantilla__c> mapPlantByCaseRecla, Map<Id, Map<String, List<SEG_ExcepcionesEmpresa__c>>> mapPlantillaDetallesEmpresa) {
		Set<Id> setPlantillasIdByExEmpresaAccountId = new Set<Id>();
		Set<Id> setPlantillasIdByExEmpresa = new Set<Id>();
		//Filtrar plantillas (caso y tipo reclamacion) por excepciones
		for (SEG_Plantilla__c plantilla : mapPlantByCaseRecla.values()) {
			if (mapPlantillaDetallesEmpresa?.get(plantilla.Id)?.get(accountId) != null) {setPlantillasIdByExEmpresaAccountId.add(plantilla.Id);
			}
			if (mapPlantillaDetallesEmpresa?.get(plantilla.Id) != null) {setPlantillasIdByExEmpresa.add(plantilla.Id);
			}
		}
		if (setPlantillasIdByExEmpresaAccountId.size() > 0) {
			for (Id plantillaId : mapPlantByCaseRecla.keySet()) {
				if (!setPlantillasIdByExEmpresaAccountId.contains(plantillaId)) {mapPlantByCaseRecla.remove(plantillaId);
				}
			}
		} else {
			for (Id plantillaId : mapPlantByCaseRecla.keySet()) {
				if (setPlantillasIdByExEmpresa.contains(plantillaId)) {mapPlantByCaseRecla.remove(plantillaId);
				}
			}
		}
	}

	private static void filterTemplateByExceptionCR(String cR, Map<Id, SEG_Plantilla__c> mapPlantByCaseRecla, Map<Id, Map<String, List<SEG_ExcepcionesCR__c>>> mapPlantillaDetallesCR) {
		Set<Id> setPlantillasIdByExCRbyCaseCR = new Set<Id>();
		Set<Id> setPlantillasIdByExCR = new Set<Id>();
		//Filtrar plantillas (caso y tipo reclamacion) por excepciones
		for (SEG_Plantilla__c plantilla : mapPlantByCaseRecla.values()) 
		{
			if (mapPlantillaDetallesCR?.get(plantilla.Id)?.get(cR) != null) {setPlantillasIdByExCRbyCaseCR.add(plantilla.Id);
			}
			if (mapPlantillaDetallesCR?.get(plantilla.Id) != null) {setPlantillasIdByExCR.add(plantilla.Id);
			}
		}
		if (setPlantillasIdByExCRbyCaseCR.size() > 0) {
			for (Id plantillaId : mapPlantByCaseRecla.keySet()) {
				if (!setPlantillasIdByExCRbyCaseCR.contains(plantillaId)) {mapPlantByCaseRecla.remove(plantillaId);
				}
			}
		} else {
			for (Id plantillaId : mapPlantByCaseRecla.keySet()) 
			{
				if (setPlantillasIdByExCR.contains(plantillaId)) {mapPlantByCaseRecla.remove(plantillaId);
				}
			}
		}
	}
}