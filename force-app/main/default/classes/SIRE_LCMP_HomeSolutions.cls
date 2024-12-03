public with sharing class SIRE_LCMP_HomeSolutions {

    public class ChartData {
        @AuraEnabled
        public Integer numRecords;
        @AuraEnabled
        public String title;
    }

    /*****************************************************************
        Proposito:  Método que obtiene los datos para pasarlos al LWC                                                     
        Parameters: tiposProcesos - Tipos de datos de procesos a mostrar                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         10/10/2023     	  Created    
	*****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static Map<String,Integer> getData(String tiposProcesos) {
		Set<String> setSituaciones = new Set<String>{SIR_Constantes.PROCESO_SITUACION_SIRE_PENDIENTE_INICIO_GESTION};
        Id recordTypeIdFlujo = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByName().get(SIR_Constantes.PROCESO_RECORDTYPE_NAME_EMP_FLUJO).getRecordTypeId();
        Id recordTypeIdPreventivo = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByName().get(SIR_Constantes.PROCESO_RECORDTYPE_NAME_EMP_PREVENTIVO).getRecordTypeId();
        
        List<SIREC__SIREC_obj_proceso__c> lstProcesosFlujo = new List<SIREC__SIREC_obj_proceso__c>();
        List<SIREC__SIREC_obj_proceso__c> lstProcesosPreventivo = new List<SIREC__SIREC_obj_proceso__c>();
        Map<String,Integer> mapProcesos = new Map<String,Integer>();

        if(tiposProcesos == SIR_Constantes.TIPOPROCESO_FLUJO){
            lstProcesosFlujo = [SELECT Id, Name, OwnerId, Owner.Name, SIR_ObjetivoProceso__c
                                FROM SIREC__SIREC_obj_proceso__c 
                                WHERE SIR_fld_Situacion_SF__c IN :setSituaciones
                                AND OwnerId =: UserInfo.getUserId() 
                                AND SIR_ObjetivoProceso__c !=: SIR_Constantes.PROCESO_OBJETIVO_INFORMATIVO
                                AND RecordTypeId =: recordTypeIdFlujo];
        }

        if(tiposProcesos == SIR_Constantes.TIPOPROCESO_PREVENTIVO){
            lstProcesosPreventivo = [SELECT Id, Name, OwnerId, Owner.Name, SIR_agrupacionSituacion__c
                                FROM SIREC__SIREC_obj_proceso__c 
                                WHERE SIR_agrupacionSituacion__c =: SIR_Constantes.PROCESO_PENDIENTE
                                AND SIR_AccionActual__c =: true
                                AND OwnerId =: UserInfo.getUserId()
                                AND RecordTypeId =: recordTypeIdPreventivo];
        }
        
        if(!lstProcesosFlujo.isEmpty()){
            mapProcesos.put(SIR_Constantes.TIPOPROCESO_FLUJO,lstProcesosFlujo.size());
        }else{
            mapProcesos.put(SIR_Constantes.TIPOPROCESO_FLUJO,0);
        }

        if(!lstProcesosPreventivo.isEmpty()){
            mapProcesos.put(SIR_Constantes.TIPOPROCESO_PREVENTIVO,lstProcesosPreventivo.size());
        }else{
            mapProcesos.put(SIR_Constantes.TIPOPROCESO_PREVENTIVO,0);
        }
		return mapProcesos;
    }

    /*****************************************************************
        Proposito:  Creamos la URL que hara la navegacion hacia la home de IMPA o PRESOL                                                      
        Parameters: No
        Returns: URL                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         16/03/2023     	  Created    
	*****************************************************************/
    @AuraEnabled(Cacheable=false)
    public static String getURL(String proceso){
        if(proceso == SIR_Constantes.TIPOPROCESO_FLUJO){
            String urlIMPA = /*'https://' + Url.getSalesforceBaseUrl().getHost() + */'/lightning/n/SIRE_Inicio_FLUJO';
            return urlIMPA;
        }else if(proceso == SIR_Constantes.TIPOPROCESO_PREVENTIVO){
            String urlPRESOL = /*'https://' + Url.getSalesforceBaseUrl().getHost() + */'/lightning/n/SIRE_Inicio_Preventivo';
            return urlPRESOL;
        }else{
            return null;
        }  
    }
}