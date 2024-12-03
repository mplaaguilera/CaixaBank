public with sharing class SEG_Operacion_AI_TRHan extends CC_TriggerHandlerBase {

	public override void mainEntry(CC_TriggerParameters tp)
	{
		// Quedarnos solo operaciones asociadas a casos de segmento
		System.debug('Trigger SEG_Operacion_AI_TRHan: ');
		Set<Id> caseIds = new Set<Id> ();
		for (SEG_Operacion__c oper : (List<SEG_Operacion__c>) tp.newList) {
			caseIds.add(oper.SEG_SR__c);
		}
		Set<Id> recordTypesSeg = new Set<Id> ();
		Id recordTypeSEG = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
		Id recordTypeSeguimiento = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId();
		Id recordTypeCSO = Schema.SObjectType.SEG_Operacion__c.getRecordTypeInfosByDeveloperName().get('CSO').getRecordTypeId();
		recordTypesSeg.add(recordTypeSEG);
		recordTypesSeg.add(recordTypeSeguimiento);
		Map<Id, Case> mapCases = new Map<Id, Case> ([Select Id, SEG_N_operaciones_CSO__c,SEG_N_operaciones_BO__c From Case Where RecordTypeId IN :recordTypesSeg and Id IN :caseIds]);
		List<Id> lstOperacionesSegCSO = new List<Id> ();
		for (SEG_Operacion__c op : (List<SEG_Operacion__c>) tp.newList)
		{
			if (mapCases.containsKey(op.SEG_SR__c) && op.RecordTypeId == recordTypeCSO) {
				lstOperacionesSegCSO.add(op.Id);
			}
		}
		if (lstOperacionesSegCSO.size() > 0)
		{
			process(lstOperacionesSegCSO, mapCases, (List<SEG_Operacion__c>) tp.newList, (Map<Id, SEG_Operacion__c>) tp.newMap, (List<SEG_Operacion__c>) tp.oldList, (Map<Id, SEG_Operacion__c>) tp.oldMap);
		}
	}
	private void process(List<Id> lstOperacionesSegCSO, Map<Id, Case> mapCases, List<SEG_Operacion__c> listNewObj, Map<Id, SEG_Operacion__c> mapNewObj, List<SEG_Operacion__c> listOldObj, Map<Id, SEG_Operacion__c> mapOldObj)
	{
		updateOpCSOCases(lstOperacionesSegCSO, mapCases, mapNewObj);
		crearFotoFacturacion(lstOperacionesSegCSO, mapNewObj);
	}
	private void updateOpCSOCases(List<Id> lstOperacionesSegCSO, Map<Id, Case> mapCases, Map<Id, SEG_Operacion__c> mapNewObj) {
		Map<Id, Case> mapCaseUpd = new Map<Id, Case> ();
		Case cs;
		Integer caseNumOpe;
		for (Id opId : lstOperacionesSegCSO) {
			if (mapCaseUpd.containsKey(mapNewObj.get(opId).SEG_SR__c)) {
				cs = mapCaseUpd.get(mapNewObj.get(opId).SEG_SR__c);
				if(mapNewObj.get(opId).SEG_Tipo__c == 'CSO'){
					cs.SEG_N_Operaciones_CSO__c = cs.SEG_N_Operaciones_CSO__c != null
					? cs.SEG_N_Operaciones_CSO__c + mapNewObj.get(opId).SEG_N_Operaciones__c : mapNewObj.get(opId).SEG_N_Operaciones__c;
				}else {
					cs.SEG_N_operaciones_BO__c = cs.SEG_N_operaciones_BO__c != null
					? cs.SEG_N_operaciones_BO__c + mapNewObj.get(opId).SEG_N_Operaciones__c : mapNewObj.get(opId).SEG_N_Operaciones__c;
				}


			} else {
				cs = mapCases.get(mapNewObj.get(opId).SEG_SR__c);
				if(mapNewObj.get(opId).SEG_Tipo__c == 'CSO'){
					cs.SEG_N_Operaciones_CSO__c = cs.SEG_N_Operaciones_CSO__c != null 
					? cs.SEG_N_Operaciones_CSO__c + mapNewObj.get(opId).SEG_N_Operaciones__c : mapNewObj.get(opId).SEG_N_Operaciones__c;
				}else {
					cs.SEG_N_operaciones_BO__c = cs.SEG_N_operaciones_BO__c != null
					? cs.SEG_N_operaciones_BO__c + mapNewObj.get(opId).SEG_N_Operaciones__c : mapNewObj.get(opId).SEG_N_Operaciones__c;
				}

				mapCaseUpd.put(mapNewObj.get(opId).SEG_SR__c, cs);
			}
		}
		update mapCaseUpd.values();
	}
	private void crearFotoFacturacion(List<Id> lstOperacionesSegCSO, Map<Id, SEG_Operacion__c> mapNewObj) {
		Map<Id, List<SEG_Operacion__c>> caseOperaciones = new Map<Id, List<SEG_Operacion__c>> ();
		List<Id> lstCaseIds = new List<Id> ();
		Id detalleMCC, motivoMCC, productoMCC, tematicaMCC;
		String mccId = '';

		for (Id opId : lstOperacionesSegCSO) {
			if (caseOperaciones.containsKey(mapNewObj.get(opId).SEG_SR__c)) {
				caseOperaciones.get(mapNewObj.get(opId).SEG_SR__c).add(mapNewObj.get(opId));
			} else {
				caseOperaciones.put(mapNewObj.get(opId).SEG_SR__c, new List<SEG_Operacion__c> { mapNewObj.get(opId) });
			}
			lstCaseIds.add(mapNewObj.get(opId).SEG_SR__c);
			mccId = mapNewObj.get(opId).SEG_MCC__c;
		}

		if(mccId != null)
		{
			// Recuperar los datos de la clasificación.
			CC_MCC__c nuevaClasificacion = [SELECT Name, RecordType.DeveloperName, CC_Producto_Servicio__r.Name, CC_Producto_Servicio__r.CC_Tematica__r.Name,
											CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__r.Name,
											CC_Motivo__r.CC_Producto_Servicio__r.Name,
											CC_Motivo__r.Name, CC_Tematica__r.Name
											FROM CC_MCC__c WHERE RecordType.DeveloperName IN('CC_Producto_Servicio', 'CC_Motivo', 'SEG_Detalle') AND Id = :mccId];

			String tipoMCC = nuevaClasificacion.RecordType.DeveloperName;
		
			// Calcular el nivel de MCC seleccionado.
			detalleMCC = (tipoMCC == 'SEG_Detalle') ? nuevaClasificacion.Id : null;
			motivoMCC = (tipoMCC == 'SEG_Detalle') ? nuevaClasificacion.CC_Motivo__r.Id : ((tipoMCC == 'CC_Motivo') ? nuevaClasificacion.Id : null);
			productoMCC = (tipoMCC == 'SEG_Detalle') ? nuevaClasificacion.CC_Motivo__r.CC_Producto_Servicio__r.Id : ((tipoMCC == 'CC_Motivo') ? nuevaClasificacion.CC_Producto_Servicio__r.Id : ((tipoMCC == 'CC_Producto_Servicio') ? nuevaClasificacion.Id : null));
			tematicaMCC = (tipoMCC == 'SEG_Detalle') ? nuevaClasificacion.CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__r.Id : ((tipoMCC == 'CC_Motivo') ? nuevaClasificacion.CC_Producto_Servicio__r.CC_Tematica__r.Id : ((tipoMCC == 'CC_Producto_Servicio') ? nuevaClasificacion.CC_Tematica__r.Id : null));
		}
		 
		if (lstCaseIds.size() > 0) {
			SEG_FotoFacturacionHandler ffHandler = new SEG_FotoFacturacionHandler(lstCaseIds, SEG_FotoFacturacionHandler.Operativa.MCC, caseOperaciones, detalleMCC, productoMCC, motivoMCC, tematicaMCC);
			System.enqueueJob(ffHandler);
		}
	}
}