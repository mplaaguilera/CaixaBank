public with sharing class CSBD_Event_BU_TRHan extends CC_TriggerHandlerBase{
	
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Event>)tp.newList, (Map<Id, Event>)tp.newMap, (List<Event>) tp.oldList, (Map<Id, Event>) tp.oldMap);
	}
	
	private void process(List<Event> listNewObj, Map<Id, Event> mapNewObj, List<Event> listOldObj, Map<Id, Event> mapOldObj) {
        listNewObj = descartarEventosNoCsbd(listNewObj);
        actualizarFechaEvento(listNewObj, mapOldObj);
	}

    private static void actualizarFechaEvento(List<Event> listNewObj, Map<Id, Event> mapOldObj){

        Set<Id> idOportunidadesCSBD = new Set<Id>();
        Map<Id, Event> mapaEventOpCita = new Map<Id, Event>();
        Map<Id, Event> mapaEventOpFirma = new Map<Id, Event>();
        List<Opportunity> oportunidadesCSBD = new List<Opportunity>();

        for (Event evento: listNewObj){
            Event eventoOld = mapOldObj.get(evento.Id);
            //Se comprueba que se haya cambiado la fecha del evento y que tenga una oportunidad asociada
            if(evento.StartDateTime != eventoOld.StartDateTime && String.valueOf(evento.WhatId).startsWith('006')){
        
                if(Schema.SObjectType.Event.getRecordTypeInfosById().get(evento.RecordTypeId).getDeveloperName() == 'CSBD_Cita_Cliente'){
                    idOportunidadesCSBD.add(evento.WhatId);
                    mapaEventOpCita.put(evento.WhatId, evento);
                }
                if(Schema.SObjectType.Event.getRecordTypeInfosById().get(evento.RecordTypeId).getDeveloperName() == 'CSBD_Firma_Cliente'){
                    idOportunidadesCSBD.add(evento.WhatId);
                    mapaEventOpFirma.put(evento.WhatId, evento);
                }
            }
        }
        if(!idOportunidadesCSBD.isEmpty()){
            oportunidadesCSBD = [SELECT Id FROM Opportunity WHERE Id IN : idOportunidadesCSBD AND RecordType.DeveloperName LIKE 'CSBD_%'];
            if(!mapaEventOpCita.isEmpty()){
                actualizarCitasCliente(mapaEventOpCita, mapOldObj, oportunidadesCSBD);
            }
            if(!mapaEventOpFirma.isEmpty()){
                actualizarFirmaCliente(mapaEventOpFirma, oportunidadesCSBD);
            }
        }
        
    }

    private static void actualizarCitasCliente(Map<Id, Event> mapaEventOpCita, Map<Id, Event> mapOldObj, List<Opportunity> oportunidadesCSBD){
        List<Opportunity> oportunidadesActualizar = new List<Opportunity>();
        Set<Id> idOportunidadesCSBDFiltrado = new Set<Id>();
        List<CBK_SCH_PendingProcess__c> actualizarProcessCita = new List<CBK_SCH_PendingProcess__c>();
        List<CBK_SCH_PendingProcess__c> pendingProcessCita = new List<CBK_SCH_PendingProcess__c>();

        for(Opportunity oportunidad : oportunidadesCSBD){
            if(mapaEventOpCita.containsKey(oportunidad.Id)){
                oportunidad.CSBD_Fecha_Cita__c = mapaEventOpCita.get(oportunidad.Id).StartDateTime;
                oportunidadesActualizar.add(oportunidad);
                idOportunidadesCSBDFiltrado.add(oportunidad.Id);
            }
        }
        if(!idOportunidadesCSBDFiltrado.isEmpty()){
            pendingProcessCita = [SELECT Id, RecordId__c, Schedule_Time__c FROM CBK_SCH_PendingProcess__c WHERE RecordId__c IN : idOportunidadesCSBDFiltrado AND ClassName__c = 'CBK_SCH_CSBD_SchedulePendienteCita'];
    
            for(CBK_SCH_PendingProcess__c registrosCita : pendingProcessCita){
                if(mapaEventOpCita.containsKey(registrosCita.RecordId__c)){
                    Event eventoAsociado = mapaEventOpCita.get(registrosCita.RecordId__c);

                    if(registrosCita.Schedule_Time__c == mapOldObj.get(eventoAsociado.Id).StartDateTime){
                        registrosCita.Schedule_Time__c = eventoAsociado.StartDateTime;
                        actualizarProcessCita.add(registrosCita);       
                    }
                }
            }
            update oportunidadesActualizar;
            update actualizarProcessCita;
        }
    }

    private static void actualizarFirmaCliente(Map<Id, Event> mapaEventOpFirma, List<Opportunity> oportunidadesCSBDFirma){
        List<Opportunity> oportunidadesActualizarFirma = new List<Opportunity>();

        for(Opportunity oportunidad : oportunidadesCSBDFirma){
            if(mapaEventOpFirma.containsKey(oportunidad.Id)){
                oportunidad.CSBD_Fecha_Firma__c = mapaEventOpFirma.get(oportunidad.Id).StartDateTime;
                oportunidadesActualizarFirma.add(oportunidad);
            }   
        }
        update oportunidadesActualizarFirma;
    }

    private static List<Event> descartarEventosNoCsbd(List<Event> eventos) {
        List<Event> eventosCsbd = new List<Event>();
        for (Event evento : eventos) {
            if (Schema.SObjectType.Event.getRecordTypeInfosById().get(evento.RecordTypeId).getDeveloperName().startsWith('CSBD_')) {
                eventosCsbd.add(evento);
            }
        }
        return eventosCsbd;
    }
}