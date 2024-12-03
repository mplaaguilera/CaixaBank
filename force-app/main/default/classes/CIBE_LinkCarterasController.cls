/**********************************************************************************************************************
Name:	  CIBE_LinkCarterasController
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase controladora del lwc CIBE_LinkCarteras
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY			AUTHOR				DATE				Description
    1.0			US644636		    Lucia Muñoz         12/09/2023		    Init version

***********************************************************************************************************************/

public with sharing class CIBE_LinkCarterasController {

    @AuraEnabled (cacheable=true)
    public static String getUrl(){
        CIBE_Link__mdt result = CIBE_Link__mdt.getInstance('CIBE_Carteras');
        Set<String> centros = new Set<String>();
        String url;

        Set<String> a = new Set<String>();
        Set<String> b = new Set<String>();
        Set<String> d = new Set<String>();
        String url2;
        
        if(Contact.SObjectType.getDescribe().isAccessible()
        && Schema.SObjectType.Contact.fields.Id.isAccessible()
        && Schema.SObjectType.Contact.fields.AccountId.isAccessible()){

            List<Contact> centroUser = [SELECT Id, AccountId, Account.Name, CC_Matricula__c, AV_UsuarioAsociado__r.AV_ExternalID__c,Account.CC_Numero_Oficina__c
            FROM Contact WHERE AV_UsuarioAsociado__c = :UserInfo.getUserId()];

            if(!centroUser.isEmpty() && String.isNotBlank(result.CIBE_URL__c)){
                String empleadoEx = String.isNotBlank(centroUser[0].CC_Matricula__c) ? centroUser[0].CC_Matricula__c : '';
                String centroEX = String.isNotBlank(centroUser[0].Account.CC_Numero_Oficina__c	) ? centroUser[0].Account.CC_Numero_Oficina__c : '';
                // String empleado = String.isNotBlank(centroUser[0].AV_UsuarioAsociado__r.AV_ExternalID__c) ? centroUser[0].AV_UsuarioAsociado__r.AV_ExternalID__c : '';
                // String centro = String.isNotBlank(centroUser[0].Account.CC_Numero_Oficina__c) ? centroUser[0].Account.CC_Numero_Oficina__c : '';
                url = result.CIBE_URL__c.replace('{empleadoEjec}', empleadoEx).replace('{centroEjec}', centroEX); //replace('{centro}', centro).replace('{empleado}', empleado);
            }
        }

        return url;
    }  
}