/**********************************************************************************************************************
Name:	  CIBE_OpportunityComitePrecios
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para obtener la URL de Informe Precios.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY			AUTHOR				DATE				Description
    1.0			Data access		    Luis Martínez       19/12/2022		    Init version

***********************************************************************************************************************/

public with sharing class CIBE_OpportunityComitePrecios {

    @AuraEnabled (cacheable=true)
    public static String getUrl(String ref_ext){
        system.debug('refExt:: '+ref_ext);
        CIBE_Link__mdt result = CIBE_Link__mdt.getInstance('CIBE_AccesoInforme');
        system.debug('Get URL Result:: '+result);
        if(ref_ext!=null && String.isNotBlank(result?.CIBE_URL__c)) {
            system.debug('OK: '+result?.CIBE_URL__c.replace('{ref_ext}',ref_ext).replace('{org}', 'SRE'));
            return result?.CIBE_URL__c.replace('{ref_ext}',ref_ext).replace('{org}', 'SRE');
        }
        
        throw new AuraHandledException('Fallo en getUrl - El usuario no tiene permisos o CIBE_Link__mdt esta vacio.');
    }  
}