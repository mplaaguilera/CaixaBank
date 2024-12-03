/**********************************************************************************************************************
Name:	  CIBE_gestorClient
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase controladora del componente cibe_GestorClient
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY       AUTHOR			DATE			Description
1.0			US561277         Lucía Muñoz    12/04/2023		Init Version
    
***********************************************************************************************************************/

public with sharing class CIBE_GestorClient_Controller {

    /**
     * Obtiene los gestores de los clientes de una cuenta
     * @param recordId campo Id de una cuenta
     */
    @AuraEnabled(cacheable=true)
    public static List<String> getGestor(String recordId){
        List<FinServ__AccountAccountRelation__c> relations = new List<FinServ__AccountAccountRelation__c>();
        if(FinServ__AccountAccountRelation__c.SObjectType.getDescribe().isAccessible()
            && Schema.SObjectType.FinServ__AccountAccountRelation__c.fields.Id.isAccessible()
            && Schema.SObjectType.FinServ__AccountAccountRelation__c.fields.FinServ__Account__c.isAccessible()
            && Schema.SObjectType.FinServ__AccountAccountRelation__c.fields.FinServ__RelatedAccount__c.isAccessible()
            && Schema.SObjectType.FinServ__AccountAccountRelation__c.fields.CIBE_Matriz__c.isAccessible()) {
            relations = [SELECT Id,
                                FinServ__Account__c,
                                FinServ__Account__r.RecordType.DeveloperName,
                                FinServ__RelatedAccount__c,
                                FinServ__RelatedAccount__r.Id,
                                FinServ__RelatedAccount__r.AV_EAPGestor__c,
                                FinServ__RelatedAccount__r.AV_EAPGestor__r.Name,
                                FinServ__RelatedAccount__r.RecordType.DeveloperName,
                                FinServ__RelatedAccount__r.Name,
                                FinServ__RelatedAccount__r.AV_Interlocutor__r.Name,
                                FinServ__RelatedAccount__r.AV_Interlocutor__c,
                                FinServ__RelatedAccount__r.AV_PctRar__c,
                                FinServ__RelatedAccount__r.CIBE_Facturacion__c,
                                FinServ__RelatedAccount__r.AV_AhorroEInversion__c,
                                FinServ__RelatedAccount__r.AV_Rentabilidad__c,
                                FinServ__RelatedAccount__r.CIBE_RARGrupo__c,
                                FinServ__RelatedAccount__r.CIBE_LEXFechaFinVigencia__c,
                                FinServ__RelatedAccount__r.CIBE_LEXAprobado__c,
                                FinServ__RelatedAccount__r.AV_Financiacion__c,
                                CIBE_Matriz__c
                        FROM FinServ__AccountAccountRelation__c 
                        WHERE   RecordType.DeveloperName = 'CIBE_GrupoComercial' 
                                AND FinServ__Role__r.Name = 'Parent'
                                AND FinServ__RelatedAccount__c != null
                                AND FinServ__Account__c = :recordId
                                AND FinServ__Account__r.RecordType.DeveloperName = 'CIBE_GrupoComercial'];
        }

        List<String> clientIds = new List<String>();
        List<String> clients = new List<String>();
       

        for(FinServ__AccountAccountRelation__c relation : relations) {
            clients.add(relation.FinServ__RelatedAccount__r.AV_EAPGestor__r.Name);
            clientIds.add(relation.FinServ__RelatedAccount__c);
        }    
        if(clientIds.isEmpty()) {
            throw new IllegalArgumentException('El grupo comercial no tiene ningún cliente.');
        }

        List<String> clientes = new List <String> (new Set <String> (clients));

        return clientes;
    }
}