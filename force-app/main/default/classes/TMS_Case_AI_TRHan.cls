public with sharing class TMS_Case_AI_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Case>)tp.newList, (Map<Id, Case>)tp.newMap);
	}

    private void process(List<Case> listNewObj, Map<Id, Case> mapNewObj) {
        Id idRecordTypeTMS = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TMS_Expediente').getRecordTypeId();
        List<Case> casosTMS = new List<Case>();
        for (Case idCaso : listNewObj) {
            if (idCaso.RecordTypeId == idRecordTypeTMS) {
                casosTMS.add(idCaso);
            }
        }
        if(!casosTMS.isEmpty()){
            
            insertTasks(casosTMS);
        }
        
        
	}
    
    private static void insertTasks(List<Case> casosTMS) {
        List<Task> tareasTMS = new List<Task>();
        List<String> estados = new List<String>();
        for (Case caso : casosTMS) {
            estados.add(caso.Status);
        }
        Id rtTarea=Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('TMS_Tarea').getRecordTypeId();
        List<CaseStatus> estadoCaso =[SELECT MasterLabel, ApiName FROM CaseStatus WHERE ApiName IN :estados];
        List<String> estadoLista = new List<String>();
        Map<String, String> mapaEstados = new Map<String, String>();
        for (CaseStatus caso : estadoCaso) {
            estadoLista.add(caso.MasterLabel);
            mapaEstados.put(caso.ApiName, caso.MasterLabel);
        }
        if(!estadoLista.isEmpty()){

            List<CC_Lista_Valores__c> nombreActividad = [SELECT CC_Valor__c, Name FROM CC_Lista_Valores__c 
            WHERE CC_Lista__r.Name  = 'TMS - Creación de tareas automáticas' AND CC_Activa__c = true 
            AND Name IN :estadoLista ];

            Map<String, List<String>> mapaEstadoValores = new Map<String, List<String>> ();
            if(!nombreActividad.isEmpty()){
                for(CC_Lista_Valores__c valor : nombreActividad){
                    if(mapaEstadoValores.containsKey(valor.Name)){
                        mapaEstadoValores.get(valor.Name).add(valor.CC_Valor__c);
                    } else {
                        mapaEstadoValores.put(valor.Name, new List<String>{valor.CC_Valor__c});
                    }
                }
                /*if(!mapaEstadoValores.isEmpty()){
                    for (Case caso : casosTMS){
                        estado = mapaEstados.get(caso.Status);
                        List<String> tareas = mapaEstadoValores.get(estado);
                    }
                }*/
            }
            if(!nombreActividad.isEmpty()){
                for (Case caso : casosTMS) {
                    if(caso.Status != 'Rechazado email'){
                        for (CC_Lista_Valores__c nombre : nombreActividad) {
                            if( mapaEstadoValores.containsKey(nombre.Name) && mapaEstados.containsKey(caso.Status)){
                                if(mapaEstados.get(caso.Status) == nombre.Name){
                                    Task nuevaActividad = new Task();
                                    nuevaActividad.RecordTypeId = rtTarea;
                                    nuevaActividad.Subject = nombre.CC_Valor__c;
                                    nuevaActividad.Status = 'Open';
                                    nuevaActividad.WhatId = caso.Id;
                                    nuevaActividad.CC_Consulta__c = caso.TMS_Numexp__c;
                                    nuevaActividad.CC_Categoria__c = mapaEstados.get(caso.Status);
                                    nuevaActividad.Type = 'Automática';
                                    nuevaActividad.OwnerId = caso.OwnerId;
                                    tareasTMS.add(nuevaActividad);
                                }
                            }
                        }
                    }
                }
            }
            if(!tareasTMS.isEmpty()){
                insert tareasTMS;
            }
        }

    }
}