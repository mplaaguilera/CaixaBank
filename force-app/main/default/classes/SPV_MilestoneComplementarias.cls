public with sharing class SPV_MilestoneComplementarias implements Support.MilestoneTriggerTimeCalculator {

    //Obtener record Type
    Set<String> objetos = new Set<String>{'Case'};
    Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);
    Id recTypeReclamacion = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    Id recTypePretension = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();

    public Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId){
        Integer tiempoReplica = 15840; // 11 días naturales
        Integer tiempoAlegacionesAllanamiento = 10080; // 7 días naturales
        Integer tiempoProrrogaEscalado = 0;
        Integer tiempoSLA = 0;
        Case caso;

        if (Schema.sObjectType.Case.isAccessible()) {
            caso = [SELECT Id, SPV_EscaladoAJ__c, SAC_FechaRecepcion__c, RecordTypeId, SAC_FechaVencimientoSLA__c, SPV_MotivoComplementariaOrganismo__c, SPV_ComplementariaOrganismo__c FROM Case WHERE Id = :caseId];

            if (caso.SPV_EscaladoAJ__c == true) {
                tiempoProrrogaEscalado = calcularMinutos(1);
            }
        }
        
        if(caso.SPV_MotivoComplementariaOrganismo__c == 'SPV_EscritoAlegacionesOrAllanamiento') {
            tiempoSLA = tiempoReplica + tiempoProrrogaEscalado;
        } else {
            tiempoSLA = tiempoAlegacionesAllanamiento + tiempoProrrogaEscalado;
        }
        return tiempoSLA;
    }

    public Integer calcularMinutos(Integer dias) {
        Integer resultado = dias * 24 * 60; 
        return resultado;
    }
}