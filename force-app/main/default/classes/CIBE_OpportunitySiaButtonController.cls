/**********************************************************************************************************************
 Name:	  CIBE_OpportunitySiaButtonController
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para obtener la URL de SIA.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   VERSION		USER_STORY			AUTHOR				DATE				Description
   1.0			Data access		    Ali	y Bea           7/11/2022		    Init version

***********************************************************************************************************************/

public with sharing class CIBE_OpportunitySiaButtonController {

    @AuraEnabled (cacheable=true)
    public static String getUrl(String numberExpedient){
        CIBE_Link__mdt result = CIBE_Link__mdt.getInstance('CIBE_Expediente_SIA');
        if(String.isNotBlank(numberExpedient)){
            //comprobar permisos
            numberExpedient = numberExpedient.substring(0,numberExpedient.length()-2);
            if(String.isNotBlank(result.CIBE_URL__c)) {
                return result.CIBE_URL__c.replace('{idSolicitud}', numberExpedient).replace('{org}', 'SIA');
            }
            throw new AuraHandledException('Fallo en getUrl - El usuario no tiene permisos o CIBE_Link__mdt esta vacio.');

        }
        return null;
    }  
}