public with sharing class SPV_MilestoneRectificacionLetrado implements Support.MilestoneTriggerTimeCalculator {
    
    //Obtener record Type
    Set<String> objetos = new Set<String>{'Case'};
    Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);
    Id recTypeReclamacion = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    Id recTypePretension = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();

    public Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId){

        Integer tiempo = 1440;
        Case caso;
        Id ideBH;
        Datetime fechaFin;
        Datetime fechaInicial; 


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

        fechaFin = BusinessHours.add(ideBH, fechaInicial, calcularMilisegundos(10));
        
        // Añade los minutos necesarios a la fecha fin para que siempre acabe a las 23:59 del día de finalización
        Integer minutosDiaCompleto = SPV_Utils.minutosHastaMedianoche(fechaFin);
        fechaFin = fechaFin.addMinutes(minutosDiaCompleto);
        
        tiempo = ((fechaFin.getTime() - fechaInicial.getTime()) / 60000).intValue(); 

        return tiempo;
    }

    public Long calcularMilisegundos(Integer dias) {
        Long milisegundos = dias * 24 * 60 * 60 * 1000L;
        return milisegundos;
    }
}