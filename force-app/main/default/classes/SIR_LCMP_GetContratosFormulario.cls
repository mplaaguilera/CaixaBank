/*****************************************************************
 Name:  SIR_LCMP_GetContratosFormulario
 Copyright © 2021  CaixaBank
============================================================
Proposito:   Clase controladora externa del LWC sir_lwc_GetContratosFormulario                                                                                                                    
============================================================
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US US244051      Atmira         05/07/2021     	  Created    

*****************************************************************/
public with sharing class SIR_LCMP_GetContratosFormulario {
public static string clase = 'SIR_LCMP_GetContratosFormulario';

    /*****************************************************************
    Proposito:  Recuperar los contratos con deuda que tiene el formulario                                                         
    Parameters: recordId
    Returns: List<Contract>
    Throws [Exceptions]: N/A                                                       
    
    Historial
    -------- 
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US US244051      Atmira         05/07/2021     	  Created    
    *****************************************************************/
    @AuraEnabled(cacheable=true)
	public static List<Contract> getcontratosDeuda(string recordId){
        String metodo = 'GetcontratosDeuda';
		List<Contract> listContract = new List<Contract>();
        SIR_Constantes constante = new SIR_Constantes();
        try{
            if(Schema.SObjectType.SIR_FormularioRefinanciacion__c.isAccessible()){
                SIR_FormularioRefinanciacion__c  formulario =[SELECT Id,SIR_Proceso__c   
                                                              FROM SIR_FormularioRefinanciacion__c 
                                                              WHERE Id=:recordId LIMIT 1];

                if(Schema.SObjectType.SIREC__SIREC_obj_procesoContrato__c.isAccessible()){
                    List<SIREC__SIREC_obj_procesoContrato__c> listContratoDeuda =  [SELECT SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_numeContrato__c, SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_tipoContrato__c, tolabel(SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_sitContable__c),
                                                                        tolabel(SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_sitMorosidade__c), SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_deudaTotalContrato__c, SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_deudaPendienteVencimiento__c,
                                                                        SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_deudaVencidaImpagada__c, SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_diasImpagados__c ,SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_refinanciado__c , 
                                                                        SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_refinanciador__c, SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_numContratosArrastre__c , SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_volArrastre__c , 
                                                                        SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_numContratosCura__c , SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_volCura__c, SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_importeImpagado__c
                                                                        FROM SIREC__SIREC_obj_procesoContrato__c   
                                                                        WHERE SIREC__SIREC_fld_proceso__c  =: formulario.SIR_Proceso__c 
                                                                        AND SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_indicadorDeuda__c =: constante.STRING_MAYUS_S 
                                                                        AND SIR_estadoCarga__c != 'B' ];
                    if(listContratoDeuda != null){
                        for(SIREC__SIREC_obj_procesoContrato__c proceso :listContratoDeuda){
                            Contract contraDeuda = new Contract();
                            contraDeuda.SIREC__SIREC_fld_numeContrato__c 				= proceso.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_numeContrato__c;
                            contraDeuda.SIREC__SIREC_fld_tipoContrato__c 				= proceso.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_tipoContrato__c;
                            contraDeuda.SIREC__SIREC_fld_sitContable__c 			    = proceso.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_sitContable__c;
                            contraDeuda.SIREC__SIREC_fld_sitMorosidade__c 	            = proceso.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_sitMorosidade__c;
                            contraDeuda.SIREC__SIREC_fld_importeImpagado__c 			= proceso.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_importeImpagado__c;
                            contraDeuda.SIREC__SIREC_fld_deudaTotalContrato__c 			= proceso.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_deudaTotalContrato__c;
                            contraDeuda.SIREC__SIREC_fld_deudaPendienteVencimiento__c	= proceso.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_deudaPendienteVencimiento__c;
                            contraDeuda.SIREC__SIREC_fld_deudaVencidaImpagada__c		= proceso.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_deudaVencidaImpagada__c;
                            contraDeuda.SIREC__SIREC_fld_diasImpagados__c				= proceso.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_diasImpagados__c;
                            contraDeuda.SIREC__SIREC_fld_refinanciado__c                = proceso.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_refinanciado__c;
                            contraDeuda.SIREC__SIREC_fld_refinanciador__c               = proceso.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_refinanciador__c;
                            contraDeuda.SIREC__SIREC_fld_numContratosArrastre__c        = proceso.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_numContratosArrastre__c;
                            contraDeuda.SIREC__SIREC_fld_volArrastre__c                 = proceso.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_volArrastre__c;
                            contraDeuda.SIREC__SIREC_fld_numContratosCura__c            = proceso.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_numContratosCura__c;
                            contraDeuda.SIREC__SIREC_fld_volCura__c                     = proceso.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_volCura__c;
                            listContract.add(contraDeuda);
                        }
                    }
                }
            }
           
        }catch(exception e){
            CBK_log.error(e, 'Error : Sir_lwc_GetContratosFormulario - ' + e.getTypeName() + ': ' + e.getMessage());
        }
        return listContract;
    }
     /*****************************************************************
    Proposito:  Recuperar los contratos sin deuda que tiene el formulario                           
    Parameters: recordId
    Returns: List<Contract>
    Throws [Exceptions]: N/A                                                       
    
    Historial
    -------- 
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US US244051      Atmira         05/07/2021     	  Created    
    *****************************************************************/
     @AuraEnabled(cacheable=true)
	public static List<Contract> getcontratosSinDeuda(string recordId){
        String metodo = 'GetcontratosSinDeuda';
		List<Contract> listContract = new List<Contract>();
        SIR_Constantes constante = new SIR_Constantes();
        try{
            if(Schema.SObjectType.SIR_FormularioRefinanciacion__c.isAccessible()){
                SIR_FormularioRefinanciacion__c  formulario =[SELECT Id,SIR_Proceso__c   
                                                              FROM SIR_FormularioRefinanciacion__c 
                                                              WHERE Id=:recordId LIMIT 1];
               
                if(Schema.SObjectType.SIREC__SIREC_obj_procesoContrato__c.isAccessible()){
                    List<SIREC__SIREC_obj_procesoContrato__c>  listContratoDeuda =  [SELECT SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_numeContrato__c, SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_tipoContrato__c, 
                                                                    tolabel(SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_sitContable__c), tolabel(SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_sitMorosidade__c), 
                                                                    SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_deudaTotalContrato__c, SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_deudaPendienteVencimiento__c,
                                                                    SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_deudaVencidaImpagada__c, SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_diasImpagados__c ,
                                                                    SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_refinanciado__c , SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_refinanciador__c,
                                                                    SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_numContratosArrastre__c , SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_volArrastre__c , 
                                                                    SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_numContratosCura__c , SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_volCura__c, SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_importeImpagado__c
                                                                    FROM SIREC__SIREC_obj_procesoContrato__c 
                                                                    WHERE SIREC__SIREC_fld_proceso__c  =: formulario.SIR_Proceso__c 
                                                                    AND SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_indicadorDeuda__c =: constante.STRING_MAYUS_N 
                                                                    AND SIR_estadoCarga__c != 'B' ];
                    if(listContratoDeuda != null){
                        for(SIREC__SIREC_obj_procesoContrato__c proceso :listContratoDeuda){
                            Contract contraDeuda = new Contract();
                            contraDeuda.SIREC__SIREC_fld_numeContrato__c 				= proceso.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_numeContrato__c;
                            contraDeuda.SIREC__SIREC_fld_tipoContrato__c 				= proceso.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_tipoContrato__c;
                            contraDeuda.SIREC__SIREC_fld_sitContable__c 			    = proceso.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_sitContable__c;
                            contraDeuda.SIREC__SIREC_fld_sitMorosidade__c 	            = proceso.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_sitMorosidade__c;
                            contraDeuda.SIREC__SIREC_fld_importeImpagado__c 			= proceso.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_importeImpagado__c;
                            contraDeuda.SIREC__SIREC_fld_deudaTotalContrato__c 			= proceso.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_deudaTotalContrato__c;
                            contraDeuda.SIREC__SIREC_fld_deudaPendienteVencimiento__c	= proceso.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_deudaPendienteVencimiento__c;
                            contraDeuda.SIREC__SIREC_fld_deudaVencidaImpagada__c		= proceso.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_deudaVencidaImpagada__c;
                            contraDeuda.SIREC__SIREC_fld_diasImpagados__c				= proceso.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_diasImpagados__c;
                            contraDeuda.SIREC__SIREC_fld_refinanciado__c                = proceso.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_refinanciado__c;
                            contraDeuda.SIREC__SIREC_fld_refinanciador__c               = proceso.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_refinanciador__c;
                            contraDeuda.SIREC__SIREC_fld_numContratosArrastre__c        = proceso.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_numContratosArrastre__c;
                            contraDeuda.SIREC__SIREC_fld_volArrastre__c                 = proceso.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_volArrastre__c;
                            contraDeuda.SIREC__SIREC_fld_numContratosCura__c            = proceso.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_numContratosCura__c;
                            contraDeuda.SIREC__SIREC_fld_volCura__c                     = proceso.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_volCura__c;
                            listContract.add(contraDeuda);
                        }
                    }
                }
            }
           
        }catch(exception e){
            CBK_log.error(e, 'Error : Sir_lwc_GetContratosFormulario - ' + e.getTypeName() + ': ' + e.getMessage());
        }
        return listContract;
    }
}