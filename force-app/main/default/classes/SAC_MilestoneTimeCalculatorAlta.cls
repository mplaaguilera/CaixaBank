/*****************************************************************
 * Name: SAC_MilestoneTimeCalculatorAlta
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Controlar el tiempo de vida del milestone para la SLA Alta
 *            de la reclamación
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US219258       Marcela Neira   16/06/21      Creación
 * 1.1            DE51364          Marcela Neira  03/09/21     Cambiar la calse para que retorne días en lugar de minutos
*****************************************************************/
public without sharing class SAC_MilestoneTimeCalculatorAlta implements Support.MilestoneTriggerTimeCalculator {
    /*****************************************************************
     * Proposito: En este método se calcula el tiempo del milestone 
     *          para la SLA Alta de la Reclamación
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US219258       Marcela Neira   16/06/21     Creación
    *****************************************************************/
    public Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId){
        //Integer tiempo = 2885; //Si no encuentra parametrización devuelve 2 dias Cuando los días eran de 24 horas
        //Integer tiempo = 600; //Si no encuentra parametrización devuelve 1 dia 10horas
        /**
         * Se cambia de nuevo a fecha 18/08/2022 las BBHH a 24 horas 
         */
        Integer tiempo = 1440; //Si no encuentra parametrización devuelve 1 dia 24horas
        Case caso;
        boolean necesitaQuery = false;
        //Id recTypeReclamacion = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        //Map<Id, Case> mapCase = new Map<Id, Case>(SAC_Case_AU_TRHan.caseslist);
        //Case caso = SAC_Case_AU_TRHan.casesMap.get(caseId);
        if (Schema.sObjectType.Case.isAccessible()) {
            if(SAC_Case_AU_TRHan.casesMap.containskey(caseId)) {
                caso = SAC_Case_AU_TRHan.casesMap.get(caseId);
            } else {
                caso = [SELECT Id, SEG_Detalle__c, CC_Canal_Procedencia__c, RecordTypeId, SAC_TiempoParadaSubsanacion__c FROM Case WHERE Id = :caseId];
                necesitaQuery = true;
            }
            //Case caso = [SELECT Id, SEG_Detalle__c, CC_Canal_Procedencia__c, RecordTypeId FROM Case WHERE Id = :caseId];
            
            /*if (caso.RecordTypeId == recTypeReclamacion && !String.isBlank(caso.SEG_Detalle__c)) {
                tiempo = buscarTiempoDeLaParametrizacion(caso);                
            }*/
            if (!String.isBlank(caso.SEG_Detalle__c)) {
                tiempo = buscarTiempoDeLaParametrizacion(caso, necesitaQuery);                
            }
        }
        //Llamada al método calcularTiempoParadaSubsanacion para que le sume al tiempo total devuelto el tiempo de la parada de subsanación US959472
        tiempo = SAC_Utils.calcularTiempoParadaSubsanacion(caso, tiempo);
        return tiempo;
    }

    public Integer buscarTiempoDeLaParametrizacion(Case caso, boolean necesitaQuery){
        //Integer sla = 600;
        Integer sla = 1440;
        List<SAC_ParametrizacionSLATME__c> lstParametrizacionAlta; 
        SAC_ParametrizacionSLATME__c parametrizacionAlta; 
        Id recTypeSLAAlta = Schema.SObjectType.SAC_ParametrizacionSLATME__c.getRecordTypeInfosByDeveloperName().get('SAC_SLAAlta').getRecordTypeId();
     
        if(necesitaQuery) {
            lstParametrizacionAlta = [select id, Name, SAC_Duracion__c, RecordTypeId, SAC_MCC__c, SAC_CanalProcedencia__c from SAC_ParametrizacionSLATME__c
                                                                where RecordTypeId = :recTypeSLAAlta
                                                                and SAC_MCC__c = :caso.SEG_Detalle__c
                                                                and SAC_CanalProcedencia__c = :caso.CC_Canal_Procedencia__c];
            if(!lstParametrizacionAlta.isEmpty()){
                    parametrizacionAlta = lstParametrizacionAlta.get(0);
            }
        } else {
            parametrizacionAlta = SAC_Case_AU_TRHan.mapParametrizacionAlta?.get(caso.SEG_Detalle__c + '|' + caso.CC_Canal_Procedencia__c);
        }
        

        /*if (!parametrizacionAlta.isEmpty() && (Integer.valueOf(parametrizacionAlta[0].SAC_Duracion__c) > 0)) {
            // Se vuelven a cambiar las BBHH de 10 a 24 horas (Antes se tenia una horario de 8:00 - 18:00)
            sla= Integer.valueOf(parametrizacionAlta[0].SAC_Duracion__c) * 1440 ; //Cuando las SLA los días eran de 24horas
            //sla= Integer.valueOf(parametrizacionAlta[0].SAC_Duracion__c) * 600 ;  //Con las Business Hours los días son de 10 horas
        }*/
        if (parametrizacionAlta != null && parametrizacionAlta.SAC_Duracion__c != null && (Integer.valueOf(parametrizacionAlta.SAC_Duracion__c) > 0)) {
            // Se vuelven a cambiar las BBHH de 10 a 24 horas (Antes se tenia una horario de 8:00 - 18:00)
            sla= Integer.valueOf(parametrizacionAlta.SAC_Duracion__c) * 1440 ; //Cuando las SLA los días eran de 24horas
            //sla= Integer.valueOf(parametrizacionAlta[0].SAC_Duracion__c) * 600 ;  //Con las Business Hours los días son de 10 horas
        }
        return sla;
    }
    
}