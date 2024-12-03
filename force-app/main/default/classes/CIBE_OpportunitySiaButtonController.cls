/**********************************************************************************************************************
 Name:	  CIBE_OpportunitySiaButtonController
Copyright © 2024  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para obtener la URL de SIA o ENS en función del número de expediente
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY			AUTHOR				DATE				Description
1.0			Data access		    Ali	y Bea           7/11/2022		    Init version
2.0          SIA/ENS             Borja Lavesiera     13/02/2024          Second Version
***********************************************************************************************************************/

public with sharing class CIBE_OpportunitySiaButtonController {

    @AuraEnabled (cacheable=true)
    public static String getUrl(String numberExpedient){
        
        if (String.isNotBlank(numberExpedient)) {
            //numberExpedient = numberExpedient.substring(0, Math.max(0, numberExpedient.length() - 2));
            String linkType = (numberExpedient.startsWith('9999')) ? 'CIBE_Expediente_ENS' : 'CIBE_Expediente_SIA';
            CIBE_Link__mdt result = CIBE_Link__mdt.getInstance(linkType);
            
            if (String.isNotBlank(result.CIBE_URL__c)) {
                if (linkType == 'CIBE_Expediente_ENS') {
                    return result.CIBE_URL__c.replace('{idPeticion}', numberExpedient);
                } else if (String.isNotBlank(result.CIBE_URL_Long__c) && linkType == 'CIBE_Expediente_SIA') {
                    String expSinEspacios = numberExpedient.replace(' ', '');
                    String oficina = expSinEspacios.substring(0, 4);
                    String modalidad = expSinEspacios.substring(4, 6);
                    String contrato = expSinEspacios.substring(6);
                    String longUrl = result.CIBE_URL_Long__c.replace('{Office}', oficina)
                                                            .replace('{Contract}', contrato)
                                                            .replace('{Modality}', modalidad);
                    return result.CIBE_URL__c + longUrl;
                }
            }
            else {
                throw new AuraHandledException('Fallo en getUrl - El usuario no tiene permisos o CIBE_Link__mdt está vacío.');
            }
        }
        return null;
    }
}