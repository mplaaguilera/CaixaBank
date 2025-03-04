/*****************************************************************
 * Name: SAC_MilestoneTimeCalculatorLetrado
 * Copyright © 2021  CaixaBank 
 * 
 * Proposito: Controlar el tiempo de vida del milestone para la SLA Letrado para el proyecto SAC
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US219264         Carlos Solis   16/04/21     Creación
*****************************************************************/
public with sharing class SAC_MilestoneTimeCalculatorLetrado implements Support.MilestoneTriggerTimeCalculator {
/*****************************************************************
 * Proposito: En este método se calcula el tiempo del milestone para el SLA Letrado del caso
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US219264         Carlos Solis   16/04/21     Creación
*****************************************************************/
    public Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId){
        Integer sla = 30;
        Integer slaTotal = 0;
        Id recTypePretension = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
        List<Case> listaPretensiones = new List<Case>();
        List<Case> caso = new list<Case>();

        if (Schema.sObjectType.Case.isAccessible()) {
            
            /*List<Case> caso = [SELECT id, RecordTypeId, Subject, Status,SAC_TiempoSLALetradoAlta__c, CC_Canal_Procedencia__c, SEG_Detalle__c, SAC_Reclamacion__c, SAC_FechaRecepcion__c 
            FROM Case WHERE Id = :caseId];*/
            if(SAC_Case_AU_TRHan.casesMap.containsKey(caseId)){
                //caso = mapCase.get(caseId);
                caso.add(SAC_Case_AU_TRHan.casesMap.get(caseId));
            } else {
                caso = [SELECT id, RecordTypeId, Subject, Status,SAC_TiempoSLALetradoAlta__c, CC_Canal_Procedencia__c, SEG_Detalle__c, SAC_Reclamacion__c, SAC_FechaRecepcion__c, SAC_MinutosParadaSubsanacion__c 
                FROM Case WHERE Id = :caseId];
            }

            if(!caso.isEmpty()){
                if (caso[0].RecordTypeId == recTypePretension && (caso[0].SAC_TiempoSLALetradoAlta__c == 0 || caso[0].SAC_TiempoSLALetradoAlta__c == null) ){
                    slaTotal = sla;
                }else{
                    slaTotal =  Integer.valueOf(caso[0].SAC_TiempoSLALetradoAlta__c); 
                }  
            }else{
                slaTotal = sla;
            }

            if(slaTotal == 30){

                Integer mesesAnadir = 1;
                //Id ideBH = [SELECT Id, name FROM BusinessHours where name ='SAC_Calendario'].id;
                Id ideBH;
                if (Cache.Org.contains('local.SAC.SACCalendario')) {
                    String calend = (String)Cache.Org.get('local.SAC.SACCalendario');
                    ideBH = Id.valueOf(calend);
                }
                else{
                    ideBH = [SELECT Id, name FROM BusinessHours where name ='SAC_Calendario'].id;
                    Cache.Org.put('local.SAC.SACCalendario', String.valueOf(ideBH),300);
                }

                Datetime fechaInicial; 
                if(caso.isEmpty() || caso[0].SAC_FechaRecepcion__c == null){
                    fechaInicial = System.now();
                }else{
                    fechaInicial = caso[0].SAC_FechaRecepcion__c;
                }
                Datetime fechaFin = fechaInicial.addMonths(mesesAnadir);
                Boolean esDiaHabil = BusinessHours.isWithin(ideBH, fechaFin);

                if(!esDiaHabil){//Si no entra en horario de BH necesitamos calcular el siguiente día hábil
                    fechaFin = BusinessHours.nextStartDate(ideBH, fechaFin);
                    Integer horas = fechaInicial.hour() - fechaFin.hour();
                    fechaFin = fechaFin.addHours(horas);
                }

                Long diferencia = BusinessHours.diff(ideBH, fechaInicial, fechaFin);
                //Double a = ((Double) diferencia)/36000000; cuando eran 10 horas 
                Double a = ((Double) diferencia)/(1440*60*1000);
                a = a.round();
                slaTotal = a.intValue();

            }              
                                
        }

        /** Se vuelven a cambiar las BBHH de 10 a 24 horas (Antes se tenia una horario de 8:00 - 18:00)*/
        slaTotal = (slaTotal * 1440);
        //Llamada al método calcularTiempoParadaSubsanacion para que le sume al tiempo total devuelto el tiempo de la parada de subsanación US959472
        slaTotal = SAC_Utils.calcularTiempoParadaSubsanacion(caso[0], slaTotal);

        return slaTotal; //días de 24horas
        //return slaTotal * 600;  // 600 son los minutos de 10 horas que son las que se han definido en las Business Hours
    }
}