public with sharing class CIBE_BusinessGroupInfo_Controller {
  private static List<String> oppStages = new List<String>{ 'En curso', 'CIBE_Pendiente_Firma', 'Potencial' };

  private static List<String> eventStages = new List<String>{ 'Pendiente' };
  private static List<String> eventStages2 = new List<String>{ 'Planificada' };

  private static Set<Id> oppRecordTypes = CIBE_AppUtilities.getRecordTypeIdsInSet(
    new Set<CIBE_AppUtilities.SearchRT>{
      new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVACIB_RT),
      new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVAEMP_RT),
      new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_SUGERENCIACIB_RT),
      new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_SUGERENCIAEMP_RT),
      new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_ALERTACIB_RT),
      new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_ALERTAEMP_RT),
      new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_ACCIONCIB_RT),
      new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_ACCIONEMP_RT)
    }
  );

  private static Set<Id> eventRecordTypes = CIBE_AppUtilities.getRecordTypeIdsInSet(
    new Set<CIBE_AppUtilities.SearchRT>{
      new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_CLIENTE_RT),
      new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_CLIENTE_CIB_RT),
      new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_GESTOR_RT)
    }
  );

  private static List<String> taskStages = new List<String>{ 'Open' };

  private static Set<Id> taskRecordTypes = CIBE_AppUtilities.getRecordTypeIdsInSet(
    new Set<CIBE_AppUtilities.SearchRT>{
      new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_ALERTACOMERCIAL_CIB_RT),
      new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_ALERTACOMERCIAL_EMP_RT),
      new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_ONBOARDING_CIB_RT),
      new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_ONBOARDING_EMP_RT),
      new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_PRIORIZADOS_CIB_RT),
      new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_PRIORIZADOS_EMP_RT),
      new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_OTROS_CIB_RT),
      new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_OTROS_EMP_RT),
      new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_AVISOS_CIB_RT),
      new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_AVISOS_EMP_RT),
      new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_EXPERIENCIACLIENTE_CIB_RT),
      new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_EXPERIENCIACLIENTE_EMP_RT)
    }
  );

  @AuraEnabled
  public static BusinessGroupInfo getParentAccountOfCommercialGroup(String childAccountId) {
    List<FinServ__AccountAccountRelation__c> parentIds;

    parentIds = [
      SELECT FinServ__RelatedAccount__c, FinServ__RelatedAccount__r.CIBE_GrupoComercial__c, FinServ__RelatedAccount__r.Name
      FROM FinServ__AccountAccountRelation__c
      WHERE FinServ__Account__c = :childAccountId AND FinServ__Role__r.Name = 'Child' AND RecordType.Developername = 'CIBE_GrupoComercial' AND Av_ToDelete__c = false
    ];

    if (!parentIds.isEmpty()) {
      Id groupId = parentIds[0].FinServ__RelatedAccount__c;

      List<FinServ__AccountAccountRelation__c> childList;

      childList = [
        SELECT id, CIBE_GrupoInterlocutor__c, FinServ__RelatedAccount__r.Name, FinServ__RelatedAccount__r.Id
        FROM FinServ__AccountAccountRelation__c
        WHERE FinServ__Account__c = :groupId
        AND Av_ToDelete__c = false
      ];

      BusinessGroupInfo wrapper = new BusinessGroupInfo();

      if (!childList.isEmpty()) {
        wrapper.businessGroupName = parentIds[0].FinServ__RelatedAccount__r.Name;
        wrapper.businessGroupId = parentIds[0].FinServ__RelatedAccount__c;

        for (FinServ__AccountAccountRelation__c eachChild : childList) {
          if (eachChild.CIBE_GrupoInterlocutor__c == true) {
            wrapper.interlocutor = eachChild.FinServ__RelatedAccount__r.Name;
            wrapper.interlocutorId = eachChild.FinServ__RelatedAccount__r.Id;
          }
          wrapper.members.add(eachChild.FinServ__RelatedAccount__r);
        }

        Integer numOportunidades = [
          SELECT COUNT()
          FROM Opportunity
          WHERE RecordTypeId IN :oppRecordTypes AND AccountId IN :wrapper.members AND StageName IN :oppStages AND Av_ToDelete__c = false
        ];

        Integer numEventos = [
          SELECT COUNT()
          FROM Event
          WHERE
            RecordTypeId IN :eventRecordTypes
            AND WhatId IN :wrapper.members
            AND Av_ToDelete__c = false
            AND (CSBD_Evento_Estado__c = :eventStages[0]
            OR CSBD_Evento_Estado__c = :eventStages2[0])
        ];

        Integer numTask = [SELECT COUNT() FROM Task WHERE RecordTypeId IN :taskRecordTypes AND WhatId IN :wrapper.members AND Status = :taskStages AND Av_ToDelete__c = false];

        wrapper.countOpp = numOportunidades;
        wrapper.countEvents = numEventos;
        wrapper.countTask = numTask;

        return wrapper;
      }
    }
    return null;
  }

  public class BusinessGroupInfo {
    @AuraEnabled
    public String businessGroupName;
    @AuraEnabled
    public String businessGroupId;
    @AuraEnabled
    public String interlocutor;
    @AuraEnabled
    public String interlocutorId;
    @AuraEnabled
    public List<Account> members = new List<Account>();
    @AuraEnabled
    public Integer countOpp;
    @AuraEnabled
    public Integer countEvents;
    @AuraEnabled
    public Integer countTask;
  }
}