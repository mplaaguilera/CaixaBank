/*****************************************************************
 Name:  SIR_LCMP_GastosIntervinientes
 Copyright © 2021  CaixaBank
============================================================
Proposito:   Clase controladora externa del LWC Sir_lwc_GastosIntervinientes                                                                                                                    
============================================================
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US249657         Atmira         13/07/2021     	  Created    

*****************************************************************/
public with sharing  class SIR_LCMP_GastosIntervinientes {  
    
    /*****************************************************************
        Proposito: Query para obtener los datos de ese formulario
        Parameters: String idFormulario
        Returns: List<SIR_FormularioRefinanciacion__c>                                                      
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
		1.0            US249657         Atmira         13/07/2021	      Created    
    *****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static List<SIR_FormularioRefinanciacion__c> getFormulario(String idFormulario) {
        List<SIR_FormularioRefinanciacion__c> formulario = new List<SIR_FormularioRefinanciacion__c>();
        if(SIR_FormularioRefinanciacion__c.SObjectType.getDescribe().isAccessible()){
            formulario = [SELECT id, SIR_MiembrosUnidadFamiliar__c, SIR_ImporteMinSubsistencia__c,
                          SIR_AlquilerViviendaHabitual__c, SIR_PensionAlimenticia__c, SIR_Otros__c, SIR_JustificarOtrosGastos__c, SIR_TotalGastos__c
                          FROM SIR_FormularioRefinanciacion__c WHERE id =: idFormulario]; 
            for(SIR_FormularioRefinanciacion__c formRefi: formulario){
                if(formRefi.SIR_ImporteMinSubsistencia__c == null){
                    formRefi.SIR_ImporteMinSubsistencia__c = 0;
                }
                if(formRefi.SIR_AlquilerViviendaHabitual__c == null){
                    formRefi.SIR_AlquilerViviendaHabitual__c = 0;
                }
                if(formRefi.SIR_PensionAlimenticia__c == null){
                    formRefi.SIR_PensionAlimenticia__c = 0;
                }
                if(formRefi.SIR_Otros__c == null){
                    formRefi.SIR_Otros__c = 0;
                }
                if(formRefi.SIR_TotalGastos__c == null){
                    formRefi.SIR_TotalGastos__c = 0;
                }
            }
        }
        return formulario;        
    }
    
    /*****************************************************************
        Proposito: Obtenemos los valores del metadata SIR_Variables
        Parameters: String idFormulario
        Returns: List<SIR_FormularioRefinanciacion__c>                                                      
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
		1.0            US249657         Atmira         15/07/2021	      Created    
    *****************************************************************/
    @AuraEnabled(Cacheable=false)
    public static Map<String, SIR_Variables__mdt> getMetadatos() {        
        Map<String, SIR_Variables__mdt> mapVariables = SIR_Variables__mdt.getAll();
		return mapVariables;
    }      
    
        
    /*****************************************************************
        Proposito: Realiza el update del formulario
        Parameters: Object data
        Returns: String                                                 
        Throws [Exceptions]: Se controla las Exceptions devolviendo el mensaje al LWC para que se muestre por pantalla

        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
		1.0            US249657         Atmira         13/07/2021	      Created    
    *****************************************************************/
    @AuraEnabled(Cacheable=false)
    public static string updateFormulario(String idFormulario ,List<String> data) {
        try {
            if(SIR_FormularioRefinanciacion__c.SObjectType.getDescribe().isUpdateable()){    
                SIR_FormularioRefinanciacion__c updateForm = new SIR_FormularioRefinanciacion__c();
                updateForm.Id = idFormulario;
                updateForm.SIR_MiembrosUnidadFamiliar__c = data[0];
                updateForm.SIR_ImporteMinSubsistencia__c = decimal.valueOf(data[1]);
                updateForm.SIR_AlquilerViviendaHabitual__c = decimal.valueOf(data[2]);
                updateForm.SIR_PensionAlimenticia__c = decimal.valueOf(data[3]);
                updateForm.SIR_Otros__c = decimal.valueOf(data[4]);        
                updateForm.SIR_JustificarOtrosGastos__c = data[5];
                updateForm.SIR_TotalGastos__c = decimal.valueOf(data[6]);
                update updateForm;
            }
            return 'OK';
        } catch (Exception e) {
            CBK_log.error(e, 'Error : Sir_lwc_GastosIntervinientes - ' + e.getTypeName() + ': ' + e.getMessage());
            return 'Ha ocurrido un error: ' + e.getMessage();
        }
    }
    

}