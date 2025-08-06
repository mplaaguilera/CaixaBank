public with sharing class CSBD_Event_BI_TRHan extends CC_TriggerHandlerBase{

	public override void mainEntry(CC_TriggerParameters tp) {
		//process((List<Event>)tp.newList, (Map<Id, Event>)tp.newMap);
	}

	/*
	private void process(List<Event> listNewObj, Map<Id, Event> mapNewObj) {
		listNewObj = descartarEventosNoCsbd(listNewObj);
		sincronizarFechaFirma(listNewObj);
	}

	private static List<Event> descartarEventosNoCsbd(List<Event> eventos) {
		Map<Id, RecordTypeInfo> recordTypeInfos = Schema.SObjectType.Event.getRecordTypeInfosById();
        List<Event> eventosCsbd = new List<Event>();
        for (Event evento : eventos) {
            if (recordTypeInfos.containsKey(evento.RecordTypeId) &&
                recordTypeInfos.get(evento.RecordTypeId).getDeveloperName().startsWith('CSBD_')) {
                eventosCsbd.add(evento);
            }
        }
        return eventosCsbd;
    }

	private static void sincronizarFechaFirma(List<Event> listNewObj){
		//Set<Id> idOportunidadesCSBD = new Set<Id>();
		Map<Id, Event> mapaEventOp = new Map<Id, Event>();
		List<Opportunity> oportunidadesCSBD = new List<Opportunity>();
		List<Opportunity> oportunidadesActualizar = new List<Opportunity>();

		for (Event evento : listNewObj) {
			if (Schema.SObjectType.Event.getRecordTypeInfosById().get(evento.RecordTypeId).getDeveloperName() == 'CSBD_Firma_Cliente'){
				//idOportunidadesCSBD.add(evento.WhatId);
				mapaEventOp.put(evento.WhatId, evento);
			}

        }

		oportunidadesCSBD = [SELECT Id FROM Opportunity WHERE Id IN : mapaEventOp.keySet() AND RecordType.DeveloperName LIKE 'CSBD_%'];

		for(Opportunity oportunidad : oportunidadesCSBD){
			if(mapaEventOp.containsKey(oportunidad.Id)){
				oportunidad.CSBD_Fecha_Firma__c = mapaEventOp.get(oportunidad.Id).StartDateTime;
				oportunidadesActualizar.add(oportunidad);
			}
		}
		update oportunidadesActualizar;
	}
	*/
}