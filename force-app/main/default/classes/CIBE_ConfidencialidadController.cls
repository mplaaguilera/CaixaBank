/**********************************************************************************************************************
Name:      CIBE_ConfidencialidadController
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller del componente cibe_Confidencialidad
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION        USER_STORY 				AUTHOR              DATE                Description
    1.0            US379969    		        Alex Campos         28/06/2022          Init version
    2.0            US527030                Jose Maria           14/02/2023          Añadido el update de ESG
    3.0            US619216                Luis                 24/07/2023          Añadido el update de ECAs y Sindicaciones
    3.0            US682142                ALi                  25/07/2023          Añadido el update de Linea
***********************************************************************************************************************/
public with sharing class CIBE_ConfidencialidadController {
    
    @AuraEnabled
    public static void createNotification(String recordId){
        List<Opportunity> opps = [SELECT Id, Name, OwnerId FROM Opportunity WHERE Id = :recordId];
        List<CustomNotificationType> notificationTypes = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'CIBE_ConfidencialidadOportunidad'];
        
        if(!opps.isEmpty() && !notificationTypes.isEmpty()) {
            List<OpportunityTeamMember> teamMembers = [SELECT Id, UserId FROM OpportunityTeamMember WHERE OpportunityId = :opps.get(0).Id AND UserId != :opps.get(0).OwnerId];
            Set<String> memberIds = new Set<String>();
            for(OpportunityTeamMember teamMember : teamMembers) {
                memberIds.add(teamMember.UserId);
            }
            
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle('Confidencialidad oportunidad');
            notification.setBody('La oportunidad ' + opps.get(0).Name.trim() + ' ha sido marcada como confidencial.');
            notification.setNotificationTypeId(notificationTypes.get(0).Id);
            notification.setTargetId(opps.get(0).Id);
            if(!Test.isRunningTest() && !teamMembers.isEmpty()) {
                notification.send(memberIds);
            }
        }
    }
    @AuraEnabled
    public static void saveESG(String recordId, Boolean esg){
        List<Opportunity> opps = new List<Opportunity>();
        if(
            Opportunity.SObjectType.getDescribe().isAccessible() &&
            Schema.SObjectType.Opportunity.fields.CIBE_ESG__c.isAccessible()
        ) {
            opps = [SELECT Id, CIBE_ESG__c FROM Opportunity WHERE Id = :recordId];
        }
        if(!opps.isEmpty()){
            for(Opportunity opp : opps){
                opp.CIBE_ESG__c = esg;
            }

            if(
                Opportunity.SObjectType.getDescribe().isUpdateable()
            ) {
                update opps;
            }
        }
        
    }
    
    @AuraEnabled
    public static void saveFields(String recordId, Boolean bool, String name){
        List<Opportunity> opps = new List<Opportunity>();
        if(
            Opportunity.SObjectType.getDescribe().isAccessible() &&
            Opportunity.SObjectType.getDescribe().isUpdateable()
        ) {
            opps = [SELECT Id, CIBE_ESG__c, CIBE_ECAs__c, CIBE_Sindicaciones__c, CIBE_Linea__c FROM Opportunity WHERE Id = :recordId];

            if(!opps.isEmpty()){
                for(Opportunity opp : opps){
                    if(name.equalsIgnoreCase('esg')){
                        opp.CIBE_ESG__c = bool;
                    }
                    if(name.equalsIgnoreCase('ecas')){
                        opp.CIBE_ECAs__c = bool;
                    }
                    if(name.equalsIgnoreCase('sindicaciones')){
                        opp.CIBE_Sindicaciones__c = bool;
                    }
                    if(name.equalsIgnoreCase('linea')){
                        opp.CIBE_Linea__c = bool;
                    }
                }
                update opps;
            }
        }
    }

    @AuraEnabled (cacheable=true)
    public static Boolean getOpportunityRT(String recordId){
        List<Opportunity> opps = new List<Opportunity>();
        Boolean isCIB = false;
        if(
            Opportunity.SObjectType.getDescribe().isAccessible() 
        ) {
            opps = [SELECT Id, RecordType.DeveloperName FROM Opportunity WHERE Id = :recordId LIMIT 1];
            if(!opps.isEmpty()){
                for(Opportunity opp : opps){
                    if(!opp.RecordType.DeveloperName.contains('EMP')){
                        isCIB = true;
                    }
                }
            }
        }
        return isCIB;
    }

}