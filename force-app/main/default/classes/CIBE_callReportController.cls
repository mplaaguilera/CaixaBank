/**********************************************************************************************************************
 Name:	  CIBE_callReportController
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller class of CIBE_CallReport
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			US584193		    Lucía		        24/05/2023  		Init version
    1.1			US584194		    Lucía		        20/06/2023  		Modificado el metodo getRecords para añadir los campos CIBE_CategoriaAenor__c y CIBE_RelacionCliente__c
***********************************************************************************************************************/

public with sharing class CIBE_callReportController {

    @AuraEnabled(cacheable=true)
    public static Wrapper getRecords(String recordId) {
        List<Event> events = new List<Event>();
        List<CBK_Activity_Extension__c> activityExtensions = new List<CBK_Activity_Extension__c>();
        if(Event.SObjectType.getDescribe().isAccessible()
            && Schema.SObjectType.Event.fields.Id.isAccessible()
            && Schema.SObjectType.Event.fields.CSBD_Evento_Estado__c.isAccessible()
            && Schema.SObjectType.Event.fields.Description.isAccessible()) {
            events = [SELECT Id, CSBD_Evento_Estado__c, Description, AccountId FROM Event WHERE Id = :recordId];
        }

        String roleUser = [SELECT UserRole.DeveloperName FROM User WHERE Id =: UserInfo.getUserId()].UserRole.DeveloperName;

        if(roleUser == 'EMP'){
            if(CBK_Activity_Extension__c.SObjectType.getDescribe().isAccessible()
            && Schema.SObjectType.CBK_Activity_Extension__c.fields.Id.isAccessible()
            && Schema.SObjectType.CBK_Activity_Extension__c.fields.CIBE_ClienteEspana__c.isAccessible()
            && Schema.SObjectType.CBK_Activity_Extension__c.fields.CIBE_ClienteNuevo__c.isAccessible()
            && Schema.SObjectType.CBK_Activity_Extension__c.fields.CIBE_ConclusionesGestor__c.isAccessible()
            && Schema.SObjectType.CBK_Activity_Extension__c.fields.CIBE_ConclusionesCliente__c.isAccessible()
            && Schema.SObjectType.CBK_Activity_Extension__c.fields.CIBE_InformacionComplementariaGestor__c.isAccessible()
            && Schema.SObjectType.CBK_Activity_Extension__c.fields.CIBE_ProximosPasosCliente__c.isAccessible()
            ) {
            activityExtensions = [SELECT Id, CIBE_ClienteEspana__c, CIBE_ClienteNuevo__c, CIBE_ConclusionesGestor__c, CIBE_ConclusionesCliente__c, CIBE_InformacionComplementariaGestor__c, CIBE_ProximosPasosCliente__c FROM CBK_Activity_Extension__c WHERE AV_ActivityId__c = :recordId];
            }
        }else if(roleUser == 'CIB'){
            if(CBK_Activity_Extension__c.SObjectType.getDescribe().isAccessible()
            && Schema.SObjectType.CBK_Activity_Extension__c.fields.Id.isAccessible()
            && Schema.SObjectType.CBK_Activity_Extension__c.fields.CIBE_ClienteEspana__c.isAccessible()
            && Schema.SObjectType.CBK_Activity_Extension__c.fields.CIBE_ClienteNuevo__c.isAccessible()
            && Schema.SObjectType.CBK_Activity_Extension__c.fields.CIBE_ConclusionesGestor__c.isAccessible()
            && Schema.SObjectType.CBK_Activity_Extension__c.fields.CIBE_ConclusionesCliente__c.isAccessible()
            && Schema.SObjectType.CBK_Activity_Extension__c.fields.CIBE_CategoriaAenor__c.isAccessible()
            && Schema.SObjectType.CBK_Activity_Extension__c.fields.CIBE_RelacionCliente__c.isAccessible()
            ) {
            activityExtensions = [SELECT Id, CIBE_ClienteEspana__c, CIBE_ClienteNuevo__c, CIBE_ConclusionesGestor__c, CIBE_ConclusionesCliente__c, CIBE_CategoriaAenor__c, CIBE_RelacionCliente__c FROM CBK_Activity_Extension__c WHERE AV_ActivityId__c = :recordId];
            }
        }

        Wrapper w = new Wrapper();
        w.ev = !events.isEmpty() ? events.get(0) : null;
        w.activityExtension = !activityExtensions.isEmpty() ? activityExtensions.get(0) : null;
        return w;
    }

    public class Wrapper {
        @AuraEnabled public Event ev {get;set;}
        @AuraEnabled public CBK_Activity_Extension__c activityExtension {get;set;}
    }
}