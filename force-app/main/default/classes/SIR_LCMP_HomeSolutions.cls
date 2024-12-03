/**********************************************************************************************************************
Name:	  SIR_LCMP_HomeSolutions
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase controladora del componente "sir_lwc_HomeSolutions"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION     USER_STORY              AUTHOR              DATE            Description
	1.0                                 ÁTMIRA              04/04/2022      Init version

***********************************************************************************************************************/
public with sharing class SIR_LCMP_HomeSolutions {

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
        1.0                             Atmira         04/04/2022     	  Created    
        
	*****************************************************************/
    
    @AuraEnabled(Cacheable=true)
    public static Map<String,Integer> getData(String tiposProcesos) {
		Set<String> setSituaciones = new Set<String>{SIR_Constantes.PROCESO_SITUACION_PENDIENTE_INICIO_GESTION};
        Id recordTypeIdAmistoso = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByName().get(SIR_Constantes.PROCESO_RECORDTYPE_NAME_AMISTOSO).getRecordTypeId();
        Id recordTypeIdPRESOL = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByName().get(SIR_Constantes.PROCESO_RECORDTYPE_NAME_PRESOL).getRecordTypeId();

        List<SIREC__SIREC_obj_proceso__c> lstProcesosIMPA = new List<SIREC__SIREC_obj_proceso__c>();
        List<SIREC__SIREC_obj_proceso__c> lstProcesosPRESOL = new List<SIREC__SIREC_obj_proceso__c>();
        Map<String,Integer> mapProcesos = new Map<String,Integer>();


        if(tiposProcesos == SIR_Constantes.tipoProceso_Gestion1_90){
            lstProcesosIMPA = [SELECT id, name, OwnerId, Owner.Name, SIR_ObjetivoProceso__c
                                FROM SIREC__SIREC_obj_proceso__c 
                                WHERE SIR_fld_Situacion_SF__c IN :setSituaciones
                                AND OwnerId = :UserInfo.getUserId() 
                                AND SIR_ObjetivoProceso__c !=: SIR_Constantes.PROCESO_OBJETIVO_INFORMATIVO
                                AND RecordTypeId =: recordTypeIdAmistoso];
        }
        if(tiposProcesos == SIR_Constantes.tipoProceso_PRESOL){
            // 02/01/2023 Modificacion -- P2253-997  --  Se retrocede el cambio realizado en las cajitas. Se muestran solo los procesos Pendientes
            lstProcesosPRESOL = [SELECT id, name, OwnerId, Owner.Name, SIR_agrupacionSituacion__c
                                FROM SIREC__SIREC_obj_proceso__c 
                                WHERE SIR_agrupacionSituacion__c =: SIR_Constantes.PROCESO_PENDIENTE
                                AND SIR_AccionActual__c =: true
                                AND OwnerId = :UserInfo.getUserId()
                                AND RecordTypeId =: recordTypeIdPRESOL];
        }
        
        if(!lstProcesosIMPA.isEmpty()){
            mapProcesos.put(SIR_Constantes.tipoProceso_Gestion1_90,lstProcesosIMPA.size());
        }else{
            mapProcesos.put(SIR_Constantes.tipoProceso_Gestion1_90,0);
        }
        if(!lstProcesosPRESOL.isEmpty()){
            mapProcesos.put(SIR_Constantes.tipoProceso_PRESOL,lstProcesosPRESOL.size());
        }else{
            mapProcesos.put(SIR_Constantes.tipoProceso_PRESOL,0);
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
        1.0                             Atmira         04/04/2022     	  Created    
        
	*****************************************************************/
    @AuraEnabled(Cacheable=false)
    public static String getURL(String proceso){
        if(proceso == SIR_Constantes.tipoProceso_Gestion1_90){
            String urlIMPA = /*'https://' + Url.getSalesforceBaseUrl().getHost() + */'/lightning/n/SIR_InicioIMPA';
            return urlIMPA;
        }else if(proceso == SIR_Constantes.tipoProceso_PRESOL){
            String urlPRESOL = /*'https://' + Url.getSalesforceBaseUrl().getHost() + */'/lightning/n/SIR_InicioPRESOL';
            return urlPRESOL;
        }else{
            return null;
        }
        
    }
}