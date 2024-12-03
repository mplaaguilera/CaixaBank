public with sharing class SEG_Case_Utilities{    
    public static void insertarMarcas(List<Id> casosSEG, Map<Id, Case> mapNewObj, Map<Id,Case> mapOldObj, String flag){
		List<SEG_Marcasdeuncaso__c> listaMarcas = new List<SEG_Marcasdeuncaso__c>();
		CC_Caracteristica__c caracteristicaOK = new CC_Caracteristica__c();
		CC_Caracteristica__c caracteristicaNOK = new CC_Caracteristica__c();
		caracteristicaOK = null;
		caracteristicaNOK = null;

		Id recordTypeId = Schema.SObjectType.CC_Caracteristica__c.getRecordTypeInfosByDeveloperName().get('SEG_Caracteristicacaso').getRecordTypeId();
		Map<Id, List<Id>> mapaCasoMcc = new Map<Id, List<Id>>();
		List<Id> caseIds = new List<Id>();
		List<Id> listadoMccs = new List<Id>();

		List<CC_Caracteristica__c> listaCaracteristicas = [SELECT id,name, recordTypeId FROM CC_Caracteristica__c WHERE (name = 'FIRMA NOK' OR name = 'FIRMA OK') AND OS_Negocio__c = 'SEGMENTOS'];
		
		if (listaCaracteristicas != null && !listaCaracteristicas.isEmpty()){
			for (CC_Caracteristica__c car : listaCaracteristicas){
				if(car.name == 'FIRMA NOK' && car.recordTypeId == recordTypeId){
					caracteristicaNOK = car;
				}
				else if(car.name == 'FIRMA OK' && car.recordTypeId == recordTypeId){
					caracteristicaOK = car;
				}
			}
		}
		
		if (caracteristicaNOK == null || caracteristicaOK == null) {
			List<CC_Caracteristica__c> caraceteristicas = new List<CC_Caracteristica__c>();
			if (caracteristicaOK == null){
				CC_Caracteristica__c caractOK = new CC_Caracteristica__c();
				caractOK.RecordTypeId = recordTypeId;
				caractOK.Name = 'FIRMA OK';
				caractOK.CC_Descripcion__c = 'FIRMA OK';
				caractOK.OS_Negocio__c = 'SEGMENTOS';
				caractOK.CC_Fecha_vigencia_inicio__c = System.now();
				caraceteristicas.add(caractOK);
			}

			if (caracteristicaNOK == null){
				CC_Caracteristica__c caractNOK = new CC_Caracteristica__c();
				caractNOK.RecordTypeId = recordTypeId;
				caractNOK.Name = 'FIRMA NOK';
				caractNOK.CC_Descripcion__c = 'FIRMA NOK';
				caractNOK.OS_Negocio__c = 'SEGMENTOS';
				caractNOK.CC_Fecha_vigencia_inicio__c = System.now();
				caraceteristicas.add(caractNOK);
			}

			if (!caraceteristicas.isEmpty()) {
				insert caraceteristicas;
				for (CC_Caracteristica__c car : caraceteristicas){
					if(car.name == 'FIRMA NOK' && car.recordTypeId == recordTypeId ){
						caracteristicaNOK = car;
					}
					else if(car.name == 'FIRMA OK' && car.recordTypeId == recordTypeId ){
						caracteristicaOK = car;
					}
				}
			}
		}
		
		if(caracteristicaNOK != null && caracteristicaOK != null){
			for(Id casoId : casosSEG){
				if (mapNewObj.containsKey(casoId) && flag == 'CaseAU'){
					List<Id> mccs = new List<Id>();
					if (mapNewObj.get(casoId).CC_MCC_Motivo__c != null && mapNewObj.get(casoId).CC_MCC_Motivo__c != mapOldObj.get(casoId).CC_MCC_Motivo__c){
						mccs.add(mapNewObj.get(casoId).CC_MCC_Motivo__c);
					}
					if (mapNewObj.get(casoId).SEG_Detalle__c != null && mapNewObj.get(casoId).SEG_Detalle__c != mapOldObj.get(casoId).SEG_Detalle__c){
						mccs.add(mapNewObj.get(casoId).SEG_Detalle__c);
					}
					if (!mccs.isEmpty()){
						mapaCasoMcc.put(casoId, mccs);
					}
				} else if (mapNewObj.containsKey(casoId) && flag == 'CaseAI'){
					List<Id> mccs = new List<Id>();
					if (mapNewObj.get(casoId).CC_MCC_Motivo__c != null){
						mccs.add(mapNewObj.get(casoId).CC_MCC_Motivo__c);
					}
					if (mapNewObj.get(casoId).SEG_Detalle__c != null){
						mccs.add(mapNewObj.get(casoId).SEG_Detalle__c);
					}
					if (!mccs.isEmpty()){
						mapaCasoMcc.put(casoId, mccs);
					}
				}
			}
	
			if (!mapaCasoMcc.isEmpty()){
				for(Id caseId : mapaCasoMcc.keySet()){
					for (Id mcc : mapaCasoMcc.get(caseId)){
						listadoMccs.add(mcc);
					}
				}
				
				Map<Id,CC_MCC__c> mccsQuery = new Map<Id,CC_MCC__c>([SELECT id, Name, recordTypeId FROM CC_MCC__c WHERE id IN: listadoMccs]);
									
				for(Id caseId : mapaCasoMcc.keySet()){ 
					for (Id mcc : mapaCasoMcc.get(caseId)){
						if (mccsQuery.containsKey(mcc)){
							if(mccsQuery.get(mcc).Name == 'FIRMA OK'){
								SEG_Marcasdeuncaso__c marcaCaso = new SEG_Marcasdeuncaso__c();
								marcaCaso.SEG_Caso__c = caseId;
								marcaCaso.SEG_Caracteristica__c = caracteristicaOK.id;
								marcaCaso.SEG_Usuario__c = UserInfo.getUserId();
								listaMarcas.add(marcaCaso);
							}
							if(mccsQuery.get(mcc).Name == 'FIRMA NOK'){	
								SEG_Marcasdeuncaso__c marcaCaso = new SEG_Marcasdeuncaso__c();
								marcaCaso.SEG_Caso__c = caseId;
								marcaCaso.SEG_Caracteristica__c = caracteristicaNOK.id;
								marcaCaso.SEG_Usuario__c = UserInfo.getUserId();
								listaMarcas.add(marcaCaso);
							}
						}
					}
				}
	
				if (!listaMarcas.isEmpty()) {
					insert listaMarcas;
				}
			}
		}
	}
}