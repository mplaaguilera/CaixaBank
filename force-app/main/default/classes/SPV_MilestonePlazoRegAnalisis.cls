public with sharing class SPV_MilestonePlazoRegAnalisis implements Support.MilestoneTriggerTimeCalculator {
    //Obtener record Type
    Set<String> objetos = new Set<String>{'Case'};
    Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);
    Id recTypeReclamacion = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    Id recTypePretension = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();

    public Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId){
        Integer tiempo = 21600; // 15 días naturales
        Case caso;
        Id ideBH;
        Datetime fechaFin;
        Datetime fechaInicial; 

        if (Schema.sObjectType.Case.isAccessible()) {
            caso = [SELECT Id, CreatedDate, RecordTypeId, CBK_Case_Extension_Id__r.SPV_FechaAnalisisDecision__c, SAC_TipoConsumidor__c, SPV_Organismo__c, SAC_FechaRecepcion__c, SAC_FechaVencimientoSLA__c, SPV_DiasProrroga__c, CBK_Case_Extension_Id__r.SPV_MotivoAnulacionProrroga__c, CBK_Case_Extension_Id__r.SPV_FechaAnulacionProrroga__c FROM Case WHERE Id = :caseId];

            if (Cache.Org.contains('local.SAC.SACCalendario')) {
                String calend = (String)Cache.Org.get('local.SAC.SACCalendario');
                ideBH = Id.valueOf(calend);
            }
            else{
                ideBH = [SELECT Id, name FROM BusinessHours where name ='SPV_Calendario'].id;
                Cache.Org.put('local.SAC.SACCalendario', String.valueOf(ideBH),300);
            }

            
            fechaInicial = calcularFechaInicial(caso);
            fechaInicial = fechaInicial.addDays(1);

            // Si NO es organismo Consumo
            if(caso.SPV_Organismo__c != 'SPV_Consumo') {
                if(caso.SAC_TipoConsumidor__c == 'Si') {
                    fechaFin = fechaInicial.addDays(21); 
                } else {
                    fechaFin = BusinessHours.add(ideBH, fechaInicial, calcularMilisegundos(15));
                }
            // Si es organismo Consumo
            } else {
                if(caso.SAC_FechaVencimientoSLA__c != null) {
                    fechaFin = caso.SAC_FechaVencimientoSLA__c.addDays(1);
                }
            }

            if(fechaFin != null) {
                //Añade los días correspondientes en caso de que se haya prorrogado la reclamación y no se haya anulado la prórroga
                if(caso.SPV_DiasProrroga__c != 0 && caso.CBK_Case_Extension_Id__r.SPV_MotivoAnulacionProrroga__c == null) {
                    fechaFin = fechaFin.addDays(caso.SPV_DiasProrroga__c.intValue());   
                } 
            
                //Añade los minutos necesarios a la fecha fin del SLA regulatorio para que siempre acabe a las 23:59 del día de finalización
                Integer minutosDiaCompleto = SPV_Utils.minutosHastaMedianoche(fechaFin);
                fechaFin = fechaFin.addMinutes(minutosDiaCompleto);
                Long restaTiempo = fechaFin.getTime() - fechaInicial.getTime();
                tiempo = (restaTiempo / 60000).intValue(); 
            }   
        }
        
        return tiempo;
    }

    public Datetime calcularFechaInicial(Case caso) {
        Datetime fechaInicial; 
        if(caso.CBK_Case_Extension_Id__r.SPV_FechaAnalisisDecision__c == null){
            fechaInicial = CBK_UtilsDate.nowSYS();
        }else{
            fechaInicial = caso.CBK_Case_Extension_Id__r.SPV_FechaAnalisisDecision__c;
        }
        return fechaInicial;
    }


    public Long calcularMilisegundos(Integer dias) {
        Long milisegundos = dias * 24 * 60 * 60 * 1000L;
        return milisegundos;
    }
}