/*****************************************************************
 Name:  SIR_LCMP_interlocutor
 Copyright © 2022  CaixaBank
============================================================
Proposito:   Clase controladora externa del LWC Sir_lwc_interlocutor                                                                                                                 
============================================================
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0                             Atmira         13/06/2022     	  Created    

*****************************************************************/
public with sharing class SIR_LCMP_interlocutor {

    
    /*****************************************************************
        Proposito:  Realizamos query para buscar todos los procesos del cliente                                                      
        Parameters: String idCliente
        Returns: List<SIREC__SIREC_obj_proceso__c>                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         01/04/2022     	 Created   
        
	*****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static String getInterlocutores(String idCliente){
        String idInfoCliente;
        List<SIREC__SIREC_obj_informacionCliente__c> infoCliente = new List<SIREC__SIREC_obj_informacionCliente__c>();
        
        if(Schema.SObjectType.SIREC__SIREC_obj_informacionCliente__c.isAccessible()){
            infoCliente = [SELECT id FROM SIREC__SIREC_obj_informacionCliente__c WHERE SIREC__SIREC_fld_cliente__c =: idCliente ];
            if(!infoCliente.isEmpty()){
                idInfoCliente = infoCliente[0].id;
            }          
        }
        return idInfoCliente;
    }      
    
}