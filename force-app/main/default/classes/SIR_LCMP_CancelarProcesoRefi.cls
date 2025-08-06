/*****************************************************************
 Name:  SIR_LCMP_CancelarProcesoRefi
 Copyright © 2021  CaixaBank
============================================================
Proposito:   Clase controladora externa del LWC Sir_lwc_CancelarProcesoRefi                                                                                                                 
============================================================
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US249673         Atmira         09/08/2021      	  Created    

*****************************************************************/
public with sharing class SIR_LCMP_CancelarProcesoRefi {
    @TestVisible
    public static Boolean throwException = false;
    
    /*****************************************************************
        Proposito:  Se comprueba que el usuario actual sea el propietario del proceso, sino no puede cancelar                                                     
        Parameters: String idProceso
        Returns: String                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US249673         Atmira         09/08/2021     	  Created    
        
	*****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static String comprobarPropietario(String idProceso){
        if(Schema.SObjectType.SIREC__SIREC_obj_proceso__c.isAccessible()){
            SIREC__SIREC_obj_proceso__c proceso = [SELECT Id, OwnerId FROM SIREC__SIREC_obj_proceso__c WHERE id=:idProceso LIMIT 1];
            if(proceso.OwnerId == UserInfo.getUserId()){
                return 'OK';
            }else{
                return 'No puede cancelar un proceso de refinanciación del que no es propietario.';
            }
        } 
        return ''; 
    }

    
    /*****************************************************************
        Proposito:  Realizamos query para buscar todos los procesos del cliente                                                      
        Parameters: String idProceso
        Returns: String                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US249673         Atmira         09/08/2021     	  Created    
        
	*****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static String[] cancelarProceso(String idProceso){
        String[] resultado = new String[]{''};
        if(Schema.SObjectType.SIREC__SIREC_obj_proceso__c.isAccessible()){
            SIREC__SIREC_obj_proceso__c proceso = [SELECT Id, SIREC__SIREC_fld_masterRecordId__c, SIREC__SIREC_fld_situacion__c FROM SIREC__SIREC_obj_proceso__c WHERE id=:idProceso LIMIT 1];
            if(proceso.SIREC__SIREC_fld_masterRecordId__c == null){
                resultado[0] = 'OK';                  
                return resultado;
            } else{
                // Llamar al WS de Cancelar Proceso              
                String[] resultadoWS;
                resultadoWS = SIR_CancelarProceso_WS.cancelarProceso(proceso.Id);            
                return resultadoWS;                
            }
        } return resultado; 
    }
    
    
    /*****************************************************************
        Proposito:  Realizamos los updates de Proceso y del Formulario                                                     
        Parameters: String idProceso
        Returns: String                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US249673         Atmira         09/08/2021     	  Created    
        
	*****************************************************************/
    @AuraEnabled(Cacheable=false)
    public static String updateRegistros(String idProceso){
        if(Schema.SObjectType.SIREC__SIREC_obj_proceso__c.isUpdateable() && Schema.SObjectType.SIR_FormularioRefinanciacion__c.isUpdateable()){
            try {
                SIREC__SIREC_obj_proceso__c procesoUpdate = [SELECT id, SIREC__SIREC_fld_situacion__c, SIR_fld_Situacion_SF__c, SIREC__SIREC_fld_motivosBaja__c FROM SIREC__SIREC_obj_proceso__c WHERE id=:idProceso LIMIT 1];
                procesoUpdate.SIREC__SIREC_fld_situacion__c = SIR_Constantes.PROCESO_SITUACION_FINALIZADO;
                procesoUpdate.SIR_fld_Situacion_SF__c = SIR_Constantes.PROCESO_SITUACION_FINALIZADO;
                procesoUpdate.SIREC__SIREC_fld_motivosBaja__c = 'Cancelado';
                update procesoUpdate;                
                
                SIR_FormularioRefinanciacion__c formUpdate = [SELECT SIR_Estado__c FROM SIR_FormularioRefinanciacion__c WHERE SIR_Proceso__c=:idProceso LIMIT 1];                
                formUpdate.SIR_Estado__c = 'Cancelado';
                update formUpdate;
                if(Test.isRunningTest() && throwException){
                    CalloutException e = new CalloutException();
                    e.setMessage('Error Test');
                    throw e;
                }      
                // Devolvemos un OK para mostrar en Front que todo ha ido bien.
                return 'OK';          
            } catch (Exception e) {
                CBK_log.error(e, 'Error : SIR_LCMP_CancelarProcesoRefi - ' + e.getTypeName() + ': ' + e.getMessage());
                return 'Ha ocurrido un error: ' + e.getMessage();
            }            
        } 
        return ''; 
    }
    
}