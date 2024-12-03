public with sharing class SPV_MilestoneGeneral implements Support.MilestoneTriggerTimeCalculator {

    //Obtener record Type
    Set<String> objetos = new Set<String>{'Case'};
    Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);
    Id recTypeReclamacion = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    Id recTypePretension = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();

    public Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId){
        Integer tiempo = 30240; // 21 días naturales
        Integer tiempoRectificacion = 43200; // 30 días naturales
        Integer tiempoComplementarias = 15840; // 11 días naturales
        Integer tiempoProrroga = 0;
        Integer minutosDiaCompleto = 0;
        Integer tiempoSLA = 0;
        Case caso;

        if (Schema.sObjectType.Case.isAccessible()) {
            caso = [SELECT Id, Status, SAC_ProrrogaCounter__c, SPV_DiasProrroga__c, SAC_FechaRecepcion__c, RecordTypeId, SAC_FechaVencimientoSLA__c, SPV_MotivoComplementariaOrganismo__c, SPV_ComplementariaOrganismo__c FROM Case WHERE Id = :caseId];
            
            // Suma el tiempo de prorroga en la reclamación solo en el registro del SLA general en el que se ha prorrogado
            if (caso.SPV_DiasProrroga__c != 0 && ((caso.Status == 'SAC_002' && caso.SAC_ProrrogaCounter__c == 1) || (caso.SPV_ComplementariaOrganismo__c && caso.SAC_ProrrogaCounter__c == 2 && caso.Status == 'SPV_Rectificacion'))) {
                tiempoProrroga = calcularMinutos(Integer.valueOf(caso.SPV_DiasProrroga__c));
            }

            minutosDiaCompleto = minutosHastaMedianoche(caso.SAC_FechaRecepcion__c);

            if(caso.Status == 'SPV_Rectificacion') {
                tiempoSLA = minutosDiaCompleto + tiempoRectificacion + tiempoProrroga;
            } else if(caso.SPV_ComplementariaOrganismo__c == true && caso.SPV_MotivoComplementariaOrganismo__c == 'SPV_EscritoAlegacionesOrAllanamiento') {
                tiempoSLA = minutosDiaCompleto + tiempoComplementarias + tiempoProrroga;
            } else {
                tiempoSLA = minutosDiaCompleto + tiempo + tiempoProrroga;
            }

            DateTime fechaVencimientoActualizada = caso.SAC_FechaRecepcion__c.addMinutes(tiempoSLA);
            if (caso.SAC_FechaVencimientoSLA__c != fechaVencimientoActualizada && Schema.sObjectType.Case.isUpdateable()) {
                caso.SAC_FechaVencimientoSLA__c = fechaVencimientoActualizada;
                SPV_DatabaseDML.updateDML(caso, false);
            }
        }
  
        return tiempoSLA;
    }

    public Integer calcularMinutos(Integer dias) {
        Integer resultado = dias * 24 * 60; 
        return resultado;
    }

    public static Integer minutosHastaMedianoche(DateTime fecha) {
        // Calcula la fecha de medianoche del día actual
        DateTime medianoche = DateTime.newInstance(fecha.year(), fecha.month(), fecha.day(), 23, 59, 59);
        // Calcula la diferencia en minutos entre la fecha dada y medianoche
        Long diferenciaMinutos = (medianoche.getTime() - fecha.getTime()) / (1000 * 60);
        // Convierte la diferencia en minutos a un valor absoluto
        diferenciaMinutos = Math.abs(diferenciaMinutos);
        
        return Integer.valueOf(diferenciaMinutos);
    }
}