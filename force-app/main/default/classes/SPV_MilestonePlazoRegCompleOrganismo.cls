public with sharing class SPV_MilestonePlazoRegCompleOrganismo implements Support.MilestoneTriggerTimeCalculator{

    //Obtener record Type
    Set<String> objetos = new Set<String>{'Case'};
    Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);
    Id recTypeReclamacion = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    Id recTypePretension = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();


    public Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId){
        Integer tiempo = 2440; // 11 días naturales
        Case caso;
        Id ideBH;
        Datetime fechaFin;
        Datetime fechaInicial; 

        if (Schema.sObjectType.Case.isAccessible()) {
            caso = [SELECT Id, SPV_EscaladoAJ__c, CBK_Case_Extension_Id__r.SPV_FechaComplementariaOrganismo__c, CBK_Case_Extension_Id__r.SPV_FechaVencimientoPlazoRegOrganismo__c FROM Case WHERE Id = :caseId];

            if (Cache.Org.contains('local.SAC.SPVCalendario')) {
                String calend = (String)Cache.Org.get('local.SAC.SPVCalendario');
                ideBH = Id.valueOf(calend);
            }
            else{
                ideBH = [SELECT Id, name FROM BusinessHours where name ='SPV_Calendario'].id;
                Cache.Org.put('local.SAC.SPVCalendario', String.valueOf(ideBH),300);
            }

            fechaInicial = calcularFechaInicial(caso);
            fechaFin = calcularFechaFin(caso);  //Para este SLA, el fin se indica en un campo, y la fecha de fin será ese día a las 23:59

            // Añade los minutos necesarios a la fecha fin del SLA regulatorio para que siempre acabe a las 23:59 del día de finalización
            Integer minutosDiaCompleto = SPV_Utils.minutosHastaMedianoche(fechaFin);
            fechaFin = fechaFin.addMinutes(minutosDiaCompleto);
            Long diferencia = (fechaFin.getTime() - fechaInicial.getTime()) / 60000;    //Si la diferencia es muy grande, se necesita que sea Long antes de poder pasarlo a int, porque se desborda si no
            tiempo = diferencia.intValue();         //Se devuelve la diferencia de tiempo en minutos
        }

        return tiempo;
    }

    public DateTime calcularFechaInicial(Case caso) {
        Datetime fechaInicial; 
        if(caso.CBK_Case_Extension_Id__r.SPV_FechaComplementariaOrganismo__c == null){
            fechaInicial = CBK_UtilsDate.nowSYS();
        }else{
            fechaInicial = caso.CBK_Case_Extension_Id__r.SPV_FechaComplementariaOrganismo__c;
        }
        return fechaInicial;
    }

    public DateTime calcularFechaFin(Case caso) {
        Datetime fechaFin;
        Date fechaFinEnCaso;
        fechaFinEnCaso = caso.CBK_Case_Extension_Id__r.SPV_FechaVencimientoPlazoRegOrganismo__c;
        fechaFin = DateTime.newInstance(fechaFinEnCaso.year(), fechaFinEnCaso.month(), fechaFinEnCaso.day(), 23, 59, 59);
        return fechaFin;
    }


}