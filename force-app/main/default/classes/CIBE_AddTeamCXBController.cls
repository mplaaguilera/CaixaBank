/**********************************************************************************************************************
Name: CIBE_AddTeamCXBController
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller class for CIBE_AddTeamCXB LWC
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION     USER_STORY			AUTHOR				DATE            Description
1.0         US638991			Lucía		    	10/10/2023      Init version
***********************************************************************************************************************/

public with sharing class CIBE_AddTeamCXBController {
    
    @AuraEnabled(cacheable=true)
    public static List<AV_BookManagementMember__c> getCartera(String idUsuario){

        List<AV_BookManagementMember__c> carteraUsuario = new  List<AV_BookManagementMember__c>();
        List<Contact> contacto = new  List<Contact>();
        Set<Id> contactoId = new Set<Id>();

        if(Contact.SObjectType.getDescribe().isAccessible() 
        && Schema.SObjectType.Contact.fields.Id.isAccessible()
        && Schema.SObjectType.Contact.fields.AV_UsuarioAsociado__c .isAccessible()){
            contacto = [SELECT Id  FROM  Contact WHERE AV_UsuarioAsociado__c = :idUsuario LIMIT 1];
        }

        if(!contacto.isEmpty()){
            for (Contact c : contacto) {
                contactoId.add(c.Id);
            }
        }

        if(AV_BookManagementMember__c.SObjectType.getDescribe().isAccessible() 
            && Schema.SObjectType.AV_BookManagementMember__c.fields.Id.isAccessible()
            && Schema.SObjectType.AV_BookManagementMember__c.fields.AV_Cartera__c.isAccessible()){
                carteraUsuario = [SELECT Id, AV_Cartera__c, AV_Cartera__r.AV_ExternalID__c FROM  AV_BookManagementMember__c WHERE AV_EmpleadoGestor__c = :contactoId AND AV_Cartera__r.AV_Activa__c = 'S' ];
            }
        return carteraUsuario;    
    }

    @AuraEnabled
    public static void insertCXB(String memberId, List<String> carteraElegida){

        List<AV_BookMember__c> clientesCartera = new  List<AV_BookMember__c>();

        List<String> clientes = new List<String>();

        if(AV_BookMember__c.SObjectType.getDescribe().isAccessible() 
        && Schema.SObjectType.AV_BookMember__c.fields.Id.isAccessible()
        && Schema.SObjectType.AV_BookMember__c.fields.AV_Cartera__c.isAccessible()
        && Schema.SObjectType.AV_BookMember__c.fields.AV_Cliente__c.isAccessible()){
            clientesCartera = [SELECT Id, AV_Cartera__c, AV_Cliente__c, AV_Cliente__r.Name FROM  AV_BookMember__c WHERE AV_Cartera__r.AV_ExternalID__c IN :carteraElegida AND AV_Cliente__r.RecordType.DeveloperName = :CIBE_AppConstants.ACCOUNT_CLIENTE_RT];
        }

        if(!clientesCartera.isEmpty()){

            for (AV_BookMember__c cc : clientesCartera) {
                clientes.add(cc.AV_Cliente__c);
            }


            if(!System.isFuture() && !System.isBatch() && !System.isQueueable()){
                CIBE_CXBDisplayControllerDelete.createTeamMemberCartera(clientes, memberId);
            }

        }
    }
}