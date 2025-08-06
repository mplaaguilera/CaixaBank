/*****************************************************************
 Name: SIR_LCMP_ViewOnlineAgenciasExternas
 Copyright © 2024  CaixaBank

 Proposito: Clase controladora externa del LWC Sir_lwc_ViewOnlineAgenciasExternas                                                                                                                 

    Historial
    -------                                            

    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            			        Atmira         27/05/2024     	  Created    

*****************************************************************/
public with sharing class SIR_LCMP_ViewOnlineAgenciasExternas {    
    /*****************************************************************
        @description  Realizamos la llamada al WS                                           
        @param  String
        @return List<Object>                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         27/05/2024     	  Created    
        
	*****************************************************************/
    @AuraEnabled(Cacheable=false)
    public static List<Object> callWSAgenciasExternas(String recordId, Boolean historico){         
        List<Object> resultado = new List<Object>();        
        if(Schema.SObjectType.Account.isAccessible()){ 
            //List<SIREC__SIREC_obj_informacionCliente__c> infoCli = [SELECT SIREC__SIREC_fld_masterRecordId__c, cliente.numPerso FROM Account WHERE SIREC__SIREC_fld_cliente__c = :recordId LIMIT 1];                                                 
            List<Account> acc = [SELECT AV_NumPerso__c FROM Account WHERE Id = :recordId LIMIT 1];                                                 
            if(!acc.isEmpty()){
                resultado = SIR_cls_WS_procesosAgencias.procesosAgencias(acc[0].AV_NumPerso__c, historico);
            }
        }           
        return resultado;
    }
}