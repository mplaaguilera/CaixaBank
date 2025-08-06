/*****************************************************************
 Name:  SIR_cls_informacionClienteHandler
 Copyright © 2021  CaixaBank
  
 Proposito :   Clase handler para alojar los metodos que se invocan desde SIR_trg_informacionCliente                                                                                                                  
  
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0                             Atmira         18/11/2022     	 Created    

*****************************************************************/

public with sharing class SIR_cls_informacionClienteHandler {

    /*****************************************************************
     Name:  sendComentario
    Copyright © 2021  CaixaBank
    
    Proposito :   Metodo que filtra los registos por si se ha modificado el comentario, y si es así se envía a Sirec                                                                                                                  
    
        Historial
        -------                                                            
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         18/11/2022     	 Created    

    *****************************************************************/

    public static void sendComentario(List<SIREC__SIREC_obj_informacionCliente__c> lstInfomacionClienteNew, Map<Id,SIREC__SIREC_obj_informacionCliente__c> mapInformcionClientOld) {
        List<Id> lstInfomacionCliente = new List<Id>();
        for(SIREC__SIREC_obj_informacionCliente__c info : lstInfomacionClienteNew){
            if(info.SIREC__SIREC_fld_comentariosRecuperaciones__c != mapInformcionClientOld.get(info.Id).SIREC__SIREC_fld_comentariosRecuperaciones__c){
                lstInfomacionCliente.add(info.Id);
            }
        }
        if(!lstInfomacionCliente.isEmpty()){
            SIR_cls_WS_EnviarComentario.sendComentario(lstInfomacionCliente);
        }
        
    }
}