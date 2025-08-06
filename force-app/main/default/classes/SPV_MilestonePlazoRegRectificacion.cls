public with sharing class SPV_MilestonePlazoRegRectificacion implements Support.MilestoneTriggerTimeCalculator{
    
    //Obtener record Type
    Set<String> objetos = new Set<String>{'Case'};
    Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);
    Id recTypeReclamacion = mapRTsObjects.get('Case').get('SPV_Reclamacion').getRecordTypeId();

    public Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId){
        Integer tiempo = 2440; // 11 días naturales
        Case caso;
        Id ideBH;
        Datetime fechaFin;
        Datetime fechaInicial; 

        if (Schema.sObjectType.Case.isAccessible()) {
            caso = [SELECT Id, SPV_FechaRecepcionResolucion__c FROM Case WHERE RecordTypeId = :recTypeReclamacion AND Id = :caseId LIMIT 1];

            if (Cache.Org.contains('local.SAC.SACCalendario')) {
                String calend = (String)Cache.Org.get('local.SAC.SACCalendario');
                ideBH = Id.valueOf(calend);
            }
            else{
                ideBH = [SELECT Id, name FROM BusinessHours where name ='SPV_Calendario'].id;
                Cache.Org.put('local.SAC.SACCalendario', String.valueOf(ideBH),300);
            }

            fechaInicial = CBK_UtilsDate.nowSYS().addDays(1);
            while(!BusinessHours.isWithin(ideBH, fechaInicial)) {  //Es día hábil? -> Devuelve false y entra al while si es día no hábil
                fechaInicial = fechaInicial.addDays(1); 
            }

            Date fechaRecepcionResolucion = caso.SPV_FechaRecepcionResolucion__c;
            fechaFin = fechaRecepcionResolucion.addMonths(1);
            while(!BusinessHours.isWithin(ideBH, fechaFin)) {  //Es día hábil? -> Devuelve false y entra al while si es día no hábil
                fechaFin = fechaFin.addDays(1); 
            }

            // Añade los minutos necesarios a la fecha fin para que siempre acabe a las 23:59 del día de finalización
            Integer minutosDiaCompleto = SPV_Utils.minutosHastaMedianoche(fechaFin);
            fechaFin = fechaFin.addMinutes(minutosDiaCompleto);
          
            tiempo = ((fechaFin.getTime() - fechaInicial.getTime()) / 60000).intValue(); 
        }

        return tiempo;
    }
}