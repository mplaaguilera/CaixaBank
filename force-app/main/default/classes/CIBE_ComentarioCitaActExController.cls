/**********************************************************************************************************************
Name: CIBE_ComentarioCitaActExController
Copyright © 2024  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase controladora del componente Cibe_ComentarioCitaActEx
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION        USER_STORY               AUTHOR              DATE                Description
    1.0            PPM100458164             Luis Martínez       07/08/2024          Init version
***********************************************************************************************************************/
public with sharing class CIBE_ComentarioCitaActExController {

    @AuraEnabled(cacheable=true)
    public static String getComentario(String recordId){
        String comentario;
        List <CBK_Activity_Extension__c> lstActEx;
            lstActEx = [select Id,CIBE_ComentarioCita__c FROM CBK_Activity_Extension__c WHERE AV_ActivityId__c =:recordId];
            if(!lstActEx.IsEmpty()){
                comentario = lstActEx[0].CIBE_ComentarioCita__c;
            }
        return comentario;
    }
}