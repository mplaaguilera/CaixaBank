/**********************************************************************************************************************
Name:      CIBE_AppConstants
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Batch que se lanza despues de cada carga de las divisas en la tabla CIBE_Divisas__C 
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION        USER_STORY       AUTHOR           DATE                Description
    1.0            Create Batch	    Jose Maria       21/12/2022          Init version
	2.0            DE72514          Jose Maria       17/03/2022          New version of divisas
***********************************************************************************************************************/
public class CIBE_OpportunityCurrency_Batch implements Database.Batchable<sObject>, Database.Stateful {

    public String avQuery;
    public Integer recordsProcessed = 0;
    public static final String BATCHNAME = 'CIBE_OpportunityCurrency_Batch';
    public static List<String> stagesNames = new List<String>{'Potencial', 'En curso', 'CIBE_Pendiente_Firma'};
    private Boolean error;

    public static Set<Id> recordTypes = CIBE_AppUtilities.getRecordTypeIdsInSet(
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
        
    private List<String> listDiv;

    public CIBE_OpportunityCurrency_Batch() {
        this.avQuery = setQuery();   
    }

    public CIBE_OpportunityCurrency_Batch(String avQuery) {
        this.avQuery = avQuery;
    }

    private String setQuery() {
		String batchLimit = AV_SchedulerBatches.getLimit(BATCHNAME);
        this.listDiv = new List<String>();
        List<CIBE_Divisas__c> divUpdated = new List<CIBE_Divisas__c>();
        if(
            CIBE_Divisas__c.SObjectType.getDescribe().isAccessible() &&
            Schema.SObjectType.CIBE_Divisas__c.fields.CIBE_CodigoDivisa__c.isAccessible() &&
            Schema.SObjectType.CIBE_Divisas__c.fields.CIBE_DivisaBase__c.isAccessible()&&
            Schema.SObjectType.CIBE_Divisas__c.fields.CIBE_FechaTipoCambio__c.isAccessible()&&
            Schema.SObjectType.CIBE_Divisas__c.fields.CIBE_NombreDivisa__c.isAccessible()&&
            Schema.SObjectType.CIBE_Divisas__c.fields.CIBE_TipoCambio__c.isAccessible()
        ) {
       		divUpdated = [SELECT Id, CIBE_CodigoDivisa__c, CIBE_DivisaBase__c, CIBE_FechaTipoCambio__c, CIBE_NombreDivisa__c, CIBE_TipoCambio__c FROM CIBE_Divisas__c WHERE CIBE_FechaTipoCambio__c >= :System.today()];
        }

        
        if(!divUpdated.isEmpty()){
            this.error = false;
            for(CIBE_Divisas__c divisa : divUpdated) {
                if(String.isNotBlank(divisa.CIBE_CodigoDivisa__c)) {
                    this.listDiv.add(divisa.CIBE_CodigoDivisa__c);
                }
            }

            if(String.isNotBlank(batchLimit)) {
                avQuery = 'SELECT Id, Name, CIBE_Divisa__c, CIBE_AmountDivisa__c, CIBE_BalanceDivisa__c, CIBE_FechaCambioDivisa__c, CIBE_ComisionesDivisa__c, CIBE_ImpactoDIvisaBalanceCierreAnio__c, CIBE_ImpactoDivisaComisionesCierreAnio__c FROM Opportunity WHERE RecordTypeId IN :recordTypes AND Stagename IN :stagesNames AND CIBE_Divisa__c IN :listDiv LIMIT ' + batchLimit;
            } else {
                avQuery = 'SELECT Id, Name, CIBE_Divisa__c, CIBE_AmountDivisa__c, CIBE_BalanceDivisa__c, CIBE_FechaCambioDivisa__c, CIBE_ComisionesDivisa__c, CIBE_ImpactoDIvisaBalanceCierreAnio__c, CIBE_ImpactoDivisaComisionesCierreAnio__c FROM Opportunity WHERE RecordTypeId IN :recordTypes AND Stagename IN :stagesNames AND CIBE_Divisa__c IN :listDiv';
            }
        }else{
            avQuery = 'SELECT Id FROM Opportunity WHERE RecordTypeId IN :recordTypes AND Stagename IN :stagesNames LIMIT 1';
            this.error = true;
        }
        return avQuery; 
    }

    /**
     *  @description Recuperar las opportunidades que tienen divisa distinta del Euro y que estan en uno de los estados abiertos.
     *  @param bc -> Objeto contexto
     *  @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String methodName = 'start';
        
       	if(String.isBlank(avQuery)){
            avQuery = setQuery();
        }
        
        CBK_Log.debug(methodName, ('Query: ' + avQuery));
        return Database.getQueryLocator(avQuery);
    }
    
    /**
     *  @description 
     *  @param bc -> Objeto contexto
     *  @param scope -> Lista de oportunidades que se van a tratar
     */
    public void execute(Database.BatchableContext bc, List<Opportunity> scope) {
		try{
            List<Opportunity> updateList = new List<Opportunity>();
            if(!scope.isEmpty()){
                recordsProcessed = scope.size();
                if(!error){
                    for(Opportunity opp : scope){
                        opp.CIBE_FechaCambioDivisa__c = System.today();
                    }
                }
               
                
                if(!scope.isEmpty() && Schema.Opportunity.SObjectType.getDescribe().isCreateable() && !error){
                    Database.SaveResult[] srList = Database.update(scope, false);
                    boolean hasError = false;
                    List<Object> objs = new List<Object>();
                    Map<String, String> msjs = new Map<String, String>();
                    for (Integer i = 0; i < scope.size(); i++) {
                        Database.SaveResult sr = srList[i];
                        if(!sr.isSuccess() && !sr.getErrors().isEmpty()) {
                            msjs.put(scope[i].Id + '_' + scope[i].Name, ((String)sr.getErrors()[0].getMessage()));
                            objs.add(scope[i]);
                            hasError = true;
                        }
                    }
                    
                    if(hasError) {
                        CBK_Log.error(msjs, objs);
                    }
                }
            }
        } catch(System.Exception e) {
            CBK_Log.error(e);
        }
    }

    /**
     *  De momento no tiene funcionalidad alguna
     */
    public void finish(Database.BatchableContext bc){
        String methodName = 'finish';
		CBK_Log.debug(methodName, ('Record Processes: ' + recordsProcessed));
    }
    
}