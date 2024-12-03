public with sharing class GRR_CaseTriggerHelper {

    public static List<Case> filtrarCasosGRR(List<Case> lstCasos) {
        List<Case> casosGRR = new List<Case>();
        Id grrCasoRTId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'GRR_Cliente');
        for (Case caso : lstCasos) {
            if (caso.recordTypeId == grrCasoRTId) {
                casosGRR.add(caso);
            }
        } 
        return casosGRR;
    }

    public static void crearActividadReasignacion( List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        List<Task> lstTareas = new List<Task>();
        List<Case> casosTraspasados = new List<Case>();
        Set<Id> setIdCasos = new Set<Id>();
        for (Case caso : lstCasos) {
            if(mapOldObj.containsKey(caso.Id) && caso.OwnerId != mapOldObj.get(caso.Id).OwnerId && caso.OwnerId != null){
                casosTraspasados.add(caso);
                setIdCasos.add(caso.Id);
            }
        }
    
        if(!casosTraspasados.isEmpty()){
            Map<ID, Case> mapCasos = new Map<ID, Case>([SELECT Id, Owner.Name FROM Case WHERE Id IN :setIdCasos]);
            System.debug('mapCasos: '+ mapCasos.size());
            if(!mapCasos.isEmpty()){
                for (Case casoTrasladado : casosTraspasados) {
                    String titulo = 'Reasignación del caso';
                
                    if((String.valueOf(casoTrasladado.OwnerId).startsWith('005') || String.valueOf(casoTrasladado.OwnerId).startsWith('00G')) && mapCasos.containsKey(casoTrasladado.Id)){
                        titulo = 'Reasignación del caso a ' + mapCasos.get(casoTrasladado.Id).Owner.Name;
                        Task createTask = new Task(Type = 'Reasignación' , Subject = 'Reasignación', ActivityDate = System.today(), Status = 'Completed', WhatId = casoTrasladado.Id,
                        Description = titulo, RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'GRR_Task'));
                        lstTareas.add(createTask);
                    }

                    // Task createTask = new Task(Type = 'Reasignación' , Subject = 'Reasignación', ActivityDate = System.today(), Status = 'Completed', WhatId = casoTrasladado.Id,
                    // Description = titulo, RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'GRR_Task'));
                    // lstTareas.add(createTask);
                }
            }
        }
    
        if(!lstTareas.isEmpty()){
            System.debug('lstTareas: ' + lstTareas.size());
            insert lstTareas;
        }
        
    }

    public static void informarCamposOficina(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        List<Case> lstCasosComprobar = new List<Case>();     
        Set<Id> setIdsOficinas = new Set<Id>();
        for (Case caso : lstCasos) {
            if (mapOldObj.containsKey(caso.Id) && caso.CC_Oficina__c != mapOldObj.get(caso.Id).CC_Oficina__c) {
                setIdsOficinas.add(caso.CC_Oficina__c);
                lstCasosComprobar.add(caso);
            }
        }

        if(!lstCasosComprobar.isEmpty()){
            Map<Id, Account> listaOficinas = new Map<Id, Account>([SELECT Id,CC_Gerencia_Comercial__c,CC_Direccion_Territorial__c
                                                        FROM Account WHERE Id = :setIdsOficinas]);

            for (Case caso : lstCasosComprobar) {
                if (caso.CC_Oficina__c != null) {
                    caso.CC_DAN__c = listaOficinas.get(caso.CC_Oficina__c).CC_Gerencia_Comercial__c;
                    caso.CC_Direccion_Territorial__c = listaOficinas.get(caso.CC_Oficina__c).CC_Direccion_Territorial__c; 
                } else {
                    caso.CC_DAN__c = null;
                    caso.CC_Direccion_Territorial__c = null;
                }   
            }
        }
    }

}