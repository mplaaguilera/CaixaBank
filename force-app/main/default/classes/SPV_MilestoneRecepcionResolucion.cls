public with sharing class SPV_MilestoneRecepcionResolucion implements Support.MilestoneTriggerTimeCalculator{
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

        if(Schema.sObjectType.Case.isAccessible()){
            caso = [SELECT Id, CreatedDate, RecordTypeId, CBK_Case_Extension_Id__r.SPV_FechaEntraRecepcionResolucion__c FROM Case WHERE Id = :caseId];

            if(Cache.Org.contains('local.SAC.SACCalendario')){
                String calend = (String)Cache.Org.get('local.SAC.SACCalendario');
                ideBH = Id.valueOf(calend);
            }else{
                ideBH = [SELECT Id, name FROM BusinessHours WHERE name = 'SPV_Calendario'].id;
                Cache.Org.put('local.SAC.SACCalendario', String.valueOf(ideBH),300);
            }
            fechaInicial = calcularFechaInicial(caso);

            //Para empezar a contar desde el siguiente día hábil al momento en que entra en estado de envío debemos comprobar que es día hábil 
            //Para este SLA no se excluyen los días festivos o fines de semana -> El fin es siempre el día siguiente a las 23:59
            fechaFin = fechaInicial.addDays(1);

            // Añade los minutos necesarios a la fecha fin del SLA para que siempre acabe a las 23:59 del día de finalización
            Integer minutosDiaCompleto = SPV_Utils.minutosHastaMedianoche(fechaFin);
            fechaFin = fechaFin.addMinutes(minutosDiaCompleto);

            tiempo = (fechaFin.getTime() - fechaInicial.getTime()).intValue() / 60000;   //Se devuelve la diferencia de tiempo en minutos
    
        }
        return tiempo;
    }

    public DateTime calcularFechaInicial(Case caso) {
        DateTime fechaInicial;
        if(caso.CBK_Case_Extension_Id__r.SPV_FechaEntraRecepcionResolucion__c == null){
            fechaInicial = CBK_UtilsDate.nowSYS();
        }else{
            fechaInicial = caso.CBK_Case_Extension_Id__r.SPV_FechaEntraRecepcionResolucion__c;
        }
        return fechaInicial;
    }
}