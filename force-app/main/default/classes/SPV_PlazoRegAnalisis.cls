public with sharing class SPV_PlazoRegAnalisis implements Support.MilestoneTriggerTimeCalculator {
    //Obtener record Type
    Set<String> objetos = new Set<String>{'Case'};
    Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);
    Id recTypeReclamacion = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    Id recTypePretension = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();

    public Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId){
        Integer tiempo = 1440; // 1 días naturales
        Case caso;
        Id ideBH;
        Datetime fechaFin;
        Datetime fechaInicial; 

        if (Schema.sObjectType.Case.isAccessible()) {
            caso = [SELECT Id, CreatedDate, RecordTypeId FROM Case WHERE Id = :caseId];

            if (Cache.Org.contains('local.SAC.SACCalendario')) {
                String calend = (String)Cache.Org.get('local.SAC.SACCalendario');
                ideBH = Id.valueOf(calend);
            }
            else{
                ideBH = [SELECT Id, name FROM BusinessHours where name ='SPV_Calendario'].id;
                Cache.Org.put('local.SAC.SACCalendario', String.valueOf(ideBH),300);
            }

            fechaInicial = calcularFechaInicial(caso);
               
            //Para empezar a contar desde el siguiente día hábil a la fecha de recepción debemos comprobar que es día hábil 
            fechaFin = fechaInicial.addDays(1);
            while(!BusinessHours.isWithin(ideBH, fechaFin)) {  //Es día hábil? 
                fechaFin = fechaFin.addDays(1); 
            }

            // Añade los minutos necesarios a la fecha fin del SLA regulatorio para que siempre acabe a las 23:59 del día de finalización
            Integer minutosDiaCompleto = SPV_Utils.minutosHastaMedianoche(fechaFin);
            fechaFin = fechaFin.addMinutes(minutosDiaCompleto);

            tiempo = (fechaFin.getTime() - fechaInicial.getTime()).intValue() / 60000; 
        }
        
        return tiempo;
    }

    public Datetime calcularFechaInicial(Case caso) {
        Datetime fechaInicial; 
        if(caso.CreatedDate == null){
            fechaInicial = System.now();
        }else{
            fechaInicial = caso.CreatedDate;
        }
        return fechaInicial;
    }
}