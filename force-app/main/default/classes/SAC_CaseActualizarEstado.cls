/*****************************************************************
 * Name: SAC_CaseActualizarEstado 
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Calcular el estado de la Reclamación (Caso padre)
 * en base a las modificaciones de estado de las  pretensiones (Casos Hijos)
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US219266         Jose Gonzalez  17/05/21     Creación
 * 1.1			  US242676		   Marcela Neira  30/06/2021   Modificación Cuando una pretension 
 * 															   se dé de baja la Reclamación quede como estaba 
 * 1.2			  DE72333		   Sergio Martín  01/03/2023   Modificación Cuando una reclamación tiene todas las pretensiones 
 * 															    en baja menos una inadmitida se pasa a redacción la reclamación 
 * 1.3			  DE73045		   Sergio Martín  06/03/2023   Modificación cuando se inadmite una pretensión se arrastra el motivo 
 * 															    de inadmisión a la reclamación 
 *****************************************************************/

public without sharing class SAC_CaseActualizarEstado {
	
	private static Set<String> objetos = new Set<String>{'Case','SAC_TMECaso__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPEPRETENSION = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();
	private static final Id RECTYPERECLAMACION = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
	private static final Id RECTYPETMOGLOBAL = mapRTsObjects.get('SAC_TMECaso__c').get('SAC_TMEGlobal').getRecordTypeId();

	public static void actualizarEstadoReclamacion(List<Case> listaCasosSelect, Set<Id> reclIds, Map<Id,Case> mapaDatosCasosActualizar) {		

		Map<Id, List<Case>> mapListPretensiones = new Map<Id, List<Case>> ();
		Map<Id, String> mapReclamacionStatus = new Map<Id, String> ();
		Map<Id, String> mapaIdsFiltradas = new Map<Id, String>();
		Map<Id, Case> mapaReclamacionSelect = new Map<Id, Case>();

		for (Id reclamacion : reclIds) {
			mapListPretensiones.put(reclamacion, new List<Case>());
		}

		List<Case> lstReclUpd = new List<Case> ();
		for (Case csPre : listaCasosSelect) {
			if(csPre.RecordTypeId == RECTYPEPRETENSION){
				if (mapListPretensiones.containsKey(csPre.SAC_Reclamacion__c) ) {
					mapListPretensiones.get(csPre.SAC_Reclamacion__c).add(csPre);
				}
				if (!mapReclamacionStatus.containsKey(csPre.SAC_Reclamacion__c)) {
					mapReclamacionStatus.put(csPre.Sac_Reclamacion__c, csPre.SAC_Reclamacion__r.Status);
				}
			}
			//Añadido US764571 borrar fecha resolución al volver a análisis si ya estaba informada. Mapa para acceder a las reclamaciones padre
			if (csPre.RecordtypeId == RECTYPERECLAMACION) {
				mapaReclamacionSelect.put(csPre.Id, csPre);
			}
		}
		
		for (Id reclId : mapListPretensiones.keySet()) {
			//Unipretensión						 US219266 
			if (mapListPretensiones.get(reclId).size() == 1) {
				if(mapListPretensiones.get(reclId) [0].status != 'SAC_009'){
					tratarUnipretensiones(reclId, mapListPretensiones.get(reclId) [0], lstReclUpd, mapaReclamacionSelect);
				}					
			}
			//Multipretensión
			else {
				if (mapReclamacionStatus.containsKey(reclId) && mapReclamacionStatus.get(reclId) != 'SAC_004') {
					tratarMultipretensiones(reclId, mapListPretensiones.get(reclId), lstReclUpd, mapaReclamacionSelect);
				} 
			}				
		}	

		for (Case caso : lstReclUpd) {
            if(mapaDatosCasosActualizar.containsKey(caso.id)){
                mapaDatosCasosActualizar.get(caso.id).Status = caso.Status;
				mapaDatosCasosActualizar.get(caso.id).SAC_StatusAuxiliar__c = caso.Status;
            }else if (!mapaDatosCasosActualizar.containsKey(caso.id)){
                mapaDatosCasosActualizar.put(caso.id, caso);
            }
        }

	}

	private static void tratarUnipretensiones(Id reclamacionId, Case pretension, List<Case> lstReclUpd, Map<Id, Case> mapaReclamacionSelect) {
		Case cs = new Case();
		cs.Id = reclamacionId;
		//Baja
		/*if (pretension.Status == 'SAC_009') { //Baja
			cs.Status = 'SAC_001'; //Alta
			lstReclUpd.add(cs);
		}
		else */if (pretension.Status != 'Cerrado' && pretension.Status != 'SAC_009') {
			cs.Status = pretension.Status;
			cs.SAC_StatusAuxiliar__c = pretension.Status;
			if(pretension.SAC_SentidoResolucion__c == 'SAC_004'){ 
				cs.SAC_MotivoInadmision__c = pretension.SAC_MotivoInadmision__c;
			}
			//Añadido US764571 limpiar la fecha de recepcion de la reclamación padre si este la tenía informada
			if (pretension.Status == 'SAC_002' && mapaReclamacionSelect.containsKey(pretension.SAC_Reclamacion__c) && mapaReclamacionSelect.get(pretension.SAC_Reclamacion__c).OS_Fecha_Resolucion__c != null) {
				cs.OS_Fecha_Resolucion__c = null;
				reabrirTPETMOGlobal(reclamacionId);
			}
			if (pretension.Status == 'SAC_006' && String.isNotBlank(pretension.SAC_TipoSubsanacion__c) && mapaReclamacionSelect.containsKey(pretension.SAC_Reclamacion__c)) {
				cs.SAC_TipoSubsanacion__c = pretension.SAC_TipoSubsanacion__c;
			}
			lstReclUpd.add(cs);
		}
	}

	private static void tratarMultipretensiones(Id reclamacionId, List<Case> pretensiones, List<Case> lstReclUpd, Map<Id, Case> mapaReclamacionSelect) {
		Case cs = new Case();
		cs.Id = reclamacionId;
		Set<String> statusPretensiones = new Set<String> ();
		List<Case> pretensionesInadmitidas = new List<Case> ();
		List<Case> listaPretsInadmitidasRedaccion = new List<Case>();
		Boolean inadmision = false;
		Boolean reclamacionCerrada = false;
		Boolean borrarFechaResolucion = false;
		String tipoSubsanacion = '';
		for (Case pre : pretensiones) {
			if(pre.SAC_Reclamacion__r.Status == 'Cerrado') { reclamacionCerrada = true; }
			if(pre.SAC_SentidoResolucion__c != 'SAC_004'){
				statusPretensiones.add(pre.Status);
			} else {
				inadmision = true;
				pretensionesInadmitidas.add(pre);
				if (pre.Status == 'SAC_003') {
					listaPretsInadmitidasRedaccion.add(pre);
				}
			}
			//Añadido US764571 limpiar la fecha de recepcion de la reclamación padre si este la tenía informada
			if (pre.Status == 'SAC_002' && mapaReclamacionSelect.containsKey(pre.SAC_Reclamacion__c) && mapaReclamacionSelect.get(pre.SAC_Reclamacion__c).OS_Fecha_Resolucion__c != null) {
				borrarFechaResolucion = true;
			}
			//Añadido 22/03/24. Llevar el SAC_TipoSubsanacion__c de la pretensión a la reclamación cuando la pretensión esté en subsanación
			if (pre.Status == 'SAC_006' && String.isNotBlank(pre.SAC_TipoSubsanacion__c)) {
				tipoSubsanacion = pre.SAC_TipoSubsanacion__c;
			}			
		}
		if (statusPretensiones.size() == 1 && !statusPretensiones.contains('SAC_009') && !statusPretensiones.contains('Cerrado')) {
			cs.Status = statusPretensiones.iterator().next();
			cs.SAC_StatusAuxiliar__c = cs.Status;
			lstReclUpd.add(cs);
		}else if (statusPretensiones.contains('SAC_007')) { //Negociación
			cs.Status = 'SAC_007';
			cs.SAC_StatusAuxiliar__c = cs.Status;
			lstReclUpd.add(cs);
		}else if (statusPretensiones.contains('SAC_006')) { //Subsanación
			cs.Status = 'SAC_006';
			cs.SAC_StatusAuxiliar__c = cs.Status;
			if (String.isNotBlank(tipoSubsanacion)) {
				cs.SAC_TipoSubsanacion__c = tipoSubsanacion;
			}
			lstReclUpd.add(cs);
		}else if (statusPretensiones.contains('SAC_002')) { //Análisis
			//Añadido US764571 limpiar la fecha de recepcion de la reclamación padre si este la tenía informada
			if (borrarFechaResolucion) {
				cs.OS_Fecha_Resolucion__c = null;
				reabrirTPETMOGlobal(reclamacionId);
			}
			cs.Status = 'SAC_002';
			cs.SAC_StatusAuxiliar__c = cs.Status;
			lstReclUpd.add(cs);

		}else if (statusPretensiones.contains('SAC_003')) { //Redacción
			cs.Status = 'SAC_003';
			cs.SAC_StatusAuxiliar__c = cs.Status;
			lstReclUpd.add(cs);

		} else if (statusPretensiones.contains('SAC_009') && inadmision) { //Baja y hay una pretension en inadmision
			Boolean todasBaja = true;
			// Se recorren las pretensiones comprobando que todas sean falsas
			for (String estado : statusPretensiones) {
				if(estado != 'SAC_009') {
					todasBaja = false;
				}
			}
			if(todasBaja) {
				if(!reclamacionCerrada) {
					cs.Status = 'SAC_003';
					cs.SAC_StatusAuxiliar__c = cs.Status;
				}
				
				for (Case pre : pretensionesInadmitidas) {
					if(pre.SAC_Reclamacion__r.SAC_PretensionPrincipal__c == pre.id){ cs.SAC_MotivoInadmision__c = pre.SAC_MotivoInadmision__c; }
				}
				lstReclUpd.add(cs);
			}
		} else if (inadmision && listaPretsInadmitidasRedaccion.size() == pretensiones.size()) { // Si todas las pretensiones de la reclamacion están en inadmision y en redacción
			cs.Status = 'SAC_003';
			cs.SAC_StatusAuxiliar__c = cs.Status;
			for (Case pre : pretensionesInadmitidas) {
				if(pre.SAC_Reclamacion__r.SAC_PretensionPrincipal__c == pre.id){
					cs.SAC_MotivoInadmision__c = pre.SAC_MotivoInadmision__c;
					lstReclUpd.add(cs);
				}
			}
		}
	}

	public static void reabrirTPETMOGlobal(Id reclamacionId) {
		//Buscar el tpe del tmo global de la reclamación
		List<SAC_TiempoEstados__c> listaTPE = [SELECT Id FROM SAC_TiempoEstados__c WHERE SAC_TMECaso__r.recordTypeId = :RECTYPETMOGLOBAL AND SAC_TMECaso__r.SAC_Caso__c = :reclamacionId ORDER BY createddate desc];

		listaTPE[0].SAC_Fin__c = null;
		SAC_DatabaseDML.updateDML(listaTPE[0], false);
	}
}