/*****************************************************************
 Name:  SIR_LCMP_GetOtrosProcesos
 Copyright © 2021  CaixaBank
  
Proposito:   Clase controladora externa del LWC SIR_LCMP_GetOtrosProcesos                                                                                                                 
  
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US249675         Atmira         09/08/2021      	  Created    

*****************************************************************/
public with sharing class SIR_LCMP_GetOtrosProcesos {
    @TestVisible
    public static Boolean throwException = false;
    
    /*****************************************************************
        Proposito:  Realizamos un consulta online para consultar otros procesos                                                  
        Parameters: String idCuenta
        Returns: String []                                                      
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US249675         Atmira         09/08/2021     	  Created    
        
	*****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static String[] getProcesos(String idCuenta){
        String[] resultado = new String[]{''};
		
		if(Schema.SObjectType.SIREC__SIREC_obj_informacionCliente__c.isAccessible()){
            List<SIREC__SIREC_obj_informacionCliente__c> infoCliente = [SELECT Id, SIREC__SIREC_fld_masterRecordId__c
                                                                  FROM SIREC__SIREC_obj_informacionCliente__c 
                                                                  WHERE SIREC__SIREC_fld_cliente__c =: idCuenta LIMIT 1];
            if(!infoCliente.isEmpty()){				
				String[] resultadoWS;
                resultadoWS = SIR_cls_WS_procOtrasUdsGest.getProcOtrasUdsGest(infoCliente.get(0));  
                return resultadoWS;                
            }
        }
        //O este usuario no tiene acceso a informacliente o este cliente no tiene el informaciónCliente relacionado
        return resultado; 
    }
    
}