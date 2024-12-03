/*****************************************************************
 Name:  SIRE_LCMP_FormularioDinamicoOPC
 Copyright © 2024  CaixaBank

 @description Clase controladora externa del LWC Sir_lwc_sincronizarProceso                                                                                                                 

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0                             Atmira         26/02/2024     	  Created    

*****************************************************************/
public with sharing class SIR_LCMP_SincronizarProceso {

    /*****************************************************************
        @description Llamamos al metodo de Sincronizar Proceso                                                      
        Parameters: procesoId
        @returns List<String>                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         26/02/2024     	  Created   
        
	*****************************************************************/     
    @AuraEnabled
    public static List<String> sincronizarProceso(String procesoId){    
        List<String> resp = new List<String>();
        String[] resultado = new String[]{''}; 
        resp = SIR_cls_gestorMotor.procesoInfo(procesoId);             
        resultado = resp;                
        return resultado;
    } 

}