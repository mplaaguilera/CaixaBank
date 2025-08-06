/**********************************************************************************************************************
 Name:	  CIBE_PortfolioEmployee_Batch
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch que se encarga de sacar las carteras asociadas al empleado para luego
pasarlas en un segundo nivel de batch(CIBE_TMPortfolioCustomer_Batch), que acabará gestionando
que usuarios se relacionan con los clientes que estén relacionados con las mismas carteras.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			App FSC				alexandre perez		03/05/2023			Init version

***********************************************************************************************************************/
public with sharing class CIBE_PortfolioEmployee_Batch implements Database.Batchable<sObject>, Database.Stateful {

    list<Id> contactIdList = new list<Id>();

    public CIBE_PortfolioEmployee_Batch(list<id> contactId) {
        //para cuando no se use el fwk de batches
        this.contactIdList = contactId;
    }

    public CIBE_PortfolioEmployee_Batch() {
        //el fwk de batches necesita un constructor vacío
        system.debug('constructor de CIBE_PortfolioEmployee_Batch');
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        list<Id> contactsList = this.contactIdList;
        string squery = 'SELECT Id, AV_EmpleadoGestor__c, AV_Cartera__c FROM AV_BookManagementMember__c WHERE AV_EmpleadoGestor__c IN : contactsList AND AV_CarteraActiva__c = \'S\'' +
        ' AND CIBE_NegocioCartera__c IN (\'COR\', \'CIB\', \'INS\', \'EMP\', \'PRO\', \'MIC\', \'INT\', \'MOR\', \'FIN\', \'TES\', \'CMX\', \'RIE\')';
        return Database.getQueryLocator(squery);
    }

    /**
     *  @description 
     *  @param bc -> Objeto contexto
     *  @param scope -> Lista de relaciones de contacts con carteras que se van a tratar
     */
    public void execute(Database.BatchableContext bc, List<AV_BookManagementMember__c> scope) {
        list<string> conCar = new list<String>();
        for(AV_BookManagementMember__c bManMemb : scope){
            if(bManMemb.AV_Cartera__c != null){
                conCar.add(bManMemb.AV_EmpleadoGestor__c + '|' + bManMemb.AV_Cartera__c);
            }    
        }
        if(!conCar.isEmpty()){
            map<String,Object> params = New map<String,Object>();
            params.put('contactCarteraList',conCar);
            //maximo 100 para evitar limites de dml(100x100)
            CBK_BatchJob.executeBatch('CIBE_TMPortfolioCustomer_Batch', 100, params,1);

        }
    }

      /**
     *  De momento no tiene funcionalidad alguna
     */
    public void finish(Database.BatchableContext bc){
        String methodName = 'finish';
		//CBK_Log.debug(methodName, ('Record Processes: ' + recordsProcessed));
    }
}