/**********************************************************************************************************************
Name:	  CIBE_OpportunitiesFromGroupsController
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
Historial
VERSION		USER_STORY		AUTHOR				DATE			Description
1.0			Test Class		Mikel Lezama		28/09/2022		Init version

-----------------------------------------------------------------------------------------------------------------------
**********************************************************************************************************************/
public with sharing class CIBE_OpportunitiesFromGroupsController {
  private static List<String> stages = new List<String>{ 'En curso', 'CIBE_Pendiente_Firma', 'Potencial' };

  private static Set<Id> recordTypes = CIBE_AppUtilities.getRecordTypeIdsInSet(
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

  @AuraEnabled(cacheable=true)
  public static List<OpportunityWrapper> getRecords(Integer offSet, List<String> recordIds) {
    List<Opportunity> opportunities = new List<Opportunity>();
    if (!recordIds.isEmpty() && Opportunity.SObjectType.getDescribe().isAccessible()) {
      opportunities = [
        SELECT Id, Name, AccountId, Account.Name, toLabel(StageName), AV_PF__r.Name, Amount, AV_FechaProximoRecordatorio__c, CIBE_ProbabilidadExito__c, OwnerId, Owner.Name, CloseDate
        FROM Opportunity
        WHERE RecordTypeId IN :recordTypes AND AccountId IN :recordIds AND StageName IN :stages AND AV_ToDelete__c = FALSE
        ORDER BY CloseDate
        LIMIT 10
        OFFSET :offSet
      ];
    }

    List<OpportunityWrapper> result = new List<OpportunityWrapper>();
    for (Opportunity o : opportunities) {
      OpportunityWrapper ow = new OpportunityWrapper();
      ow.id = o.Id;
      ow.idUrl = '/' + o.Id;
      ow.name = o.Name;
      ow.accountId = o.AccountId;
      ow.accountIdUrl = '/' + o.AccountId;
      ow.accountName = o.Account.Name;
      ow.stageName = o.StageName;
      ow.product = o.AV_PF__r.Name;
      ow.amount = o.Amount;
      ow.nextManagementDate = o.AV_FechaProximoRecordatorio__c;
      ow.probability = o.CIBE_ProbabilidadExito__c;
      ow.owner = o.Owner.Name;
      ow.ownerIdUrl = '/' + o.OwnerId;
      ow.closeDate = o.CloseDate;

      result.add(ow);
    }
    return result;
  }

  public class OpportunityWrapper {
    @AuraEnabled
    public String id { get; set; }
    @AuraEnabled
    public String idUrl { get; set; }
    @AuraEnabled
    public String name { get; set; }
    @AuraEnabled
    public String accountId { get; set; }
    @AuraEnabled
    public String accountIdUrl { get; set; }
    @AuraEnabled
    public String accountName { get; set; }
    @AuraEnabled
    public String stageName { get; set; }
    @AuraEnabled
    public String product { get; set; }
    @AuraEnabled
    public Decimal amount { get; set; }
    @AuraEnabled
    public Date nextManagementDate { get; set; }
    @AuraEnabled
    public String probability { get; set; }
    @AuraEnabled
    public String owner { get; set; }
    @AuraEnabled
    public String ownerIdUrl { get; set; }
    @AuraEnabled
    public Date closeDate { get; set; }

  }
}