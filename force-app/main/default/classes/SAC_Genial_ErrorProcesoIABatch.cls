/*
* @description: SAC_Genial_ErrorProcesoIABatch to update genial status when no response from AI
* @test: SAC_Genial_ErrorProcesoIABatchTest
* @author: iria.alvarez.novoa@ibm.com
* @date: june 2025
*/
public with sharing class SAC_Genial_ErrorProcesoIABatch implements Database.Batchable<sObject>, Database.Stateful{
    public SAC_Genial_ErrorProcesoIABatch() {
        CBK_Log.debug('Empty constructor');
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Datetime hace24h = CBK_UtilsDate.nowDT().addHours(-24);
        String hace24hString = hace24h.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        Datetime hace30min = CBK_UtilsDate.nowDT().addMinutes(-30);
        String hace30minString = hace30min.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        
        String query = 'SELECT Id, SAC_GenialEstado__c FROM Case WHERE SAC_GenialEstado__c = \'SAC_001\' ' +
            ' AND (RecordType.DeveloperName = \'SAC_Reclamacion\' OR RecordType.DeveloperName = \'SAC_Consulta\')' +
            ' AND CreatedDate > ' + hace24hString + 
            ' AND LastModifiedDate < ' + hace30minString;           
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Case> cases){
		List<Case> casesToUpdate = new List<Case>();
        // Get Pdte. Asignar Queue
        Group colaSAC = [SELECT Id FROM Group WHERE DeveloperName = 'SAC_PendienteAsignar' AND Type = 'Queue' LIMIT 1];

        for(Case currentCase: cases){
            currentCase.SAC_GenialEstado__c = 'SAC_008';
            currentCase.OwnerId = colaSAC.Id;
			casesToUpdate.add(currentCase);           
        }
        if(!casesToUpdate.isEmpty()){
            try {
                update casesToUpdate;
            } catch (Exception e){
                CBK_Log.error('Error en SAC_Genial_ErrorProcesoIABatch: ' + e.getMessage());
            }
        }
    }
    
    public void finish(Database.BatchableContext bc){
        // Fin
        CBK_Log.debug('Fin de SAC_Genial_ErrorProcesoIABatch');
    }
    
}