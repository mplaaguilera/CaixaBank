public with sharing class SPV_MilestoneCompleOrganismoLetrado implements Support.MilestoneTriggerTimeCalculator{

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
        DateTime fechaInicialMediaNoche;
        DateTime fechaVencimientoPlazoReg;
        Long minutosDiferencia = 0;

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
            Integer minDiaCompletoInicial = SPV_Utils.minutosHastaMedianoche(fechaInicial);
            fechaInicialMediaNoche = fechaInicial.addMinutes(minDiaCompletoInicial);          //Se obtienen ambas fechas a la misma hora, para saber los días exactos que han pasado
            fechaVencimientoPlazoReg = obtenerFechaVencimientoPlazoReg(caso);
            
            //Se obtiene la diferencia entre las fechas en minutos
            minutosDiferencia = (fechaVencimientoPlazoReg.getTime() - fechaInicialMediaNoche.getTime()).intValue() / 60000;   

            if(minutosDiferencia <= 15840){ //En caso de que la fecha de vencimiento elegida sea menor o igual a 11 días, este SLA es de 5 días hábiles
                fechaFin = BusinessHours.add(ideBH, fechaInicial, obtenerMilisegundosDeDias(5));       //Se le añaden 5 días hábiles, que son 432000000 
                fechaFin = DateTime.newInstance(fechaFin.year(), fechaFin.month(), fechaFin.day(), 23, 59, 59);     //Se quiere que la fecha fin sea exactamente a las 23:59
                System.debug('Fecha y hora fin al principio ' + fechaFin + ' fecha inicial ' + fechaInicialMediaNoche + ' milisegundos ' + obtenerMilisegundosDeDias(5));



            }else{                          //Si no, este SLA dura 7 días hábiles
                fechaFin = BusinessHours.add(ideBH, fechaInicial, obtenerMilisegundosDeDias(7));       //Se le añaden 7 días hábiles, que son 604800000 milisegundos
                fechaFin = DateTime.newInstance(fechaFin.year(), fechaFin.month(), fechaFin.day(), 23, 59, 59);     //Se quiere que la fecha fin sea exactamente a las 23:59
                System.debug('Fecha y hora fin al principio ' + fechaFin + ' fecha inicial ' + fechaInicialMediaNoche + ' milisegundos ' + obtenerMilisegundosDeDias(7));
            }

            // Añade los minutos necesarios a la fecha fin del SLA regulatorio para que siempre acabe a las 23:59 del día de finalización
            /*Integer minutosDiaCompleto = SPV_Utils.minutosHastaMedianoche(fechaFin);
            fechaFin = fechaFin.addMinutes(minutosDiaCompleto);*/
            tiempo = (fechaFin.getTime() - fechaInicial.getTime()).intValue() / 60000;   //Se devuelve la diferencia de tiempo en minutos
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

    public DateTime obtenerFechaVencimientoPlazoReg(Case caso) {
        Datetime fechaVencimientoPlazoReg;
        Date fechaFinEnCaso;
        fechaFinEnCaso = caso.CBK_Case_Extension_Id__r.SPV_FechaVencimientoPlazoRegOrganismo__c;
        fechaVencimientoPlazoReg = DateTime.newInstance(fechaFinEnCaso.year(), fechaFinEnCaso.month(), fechaFinEnCaso.day(), 23, 59, 59);
        return fechaVencimientoPlazoReg;
    }

    public Long obtenerMilisegundosDeDias(Integer numDias){
        return numDias * 24 * 60 * 60 * 1000L;
    }

}