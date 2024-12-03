/**********************************************************************************************************************
 Name: CIBE_AccExtAccConRel_Batch
 Copyright © 2024  CaixaBank
------------------------------------------------------------------------------------------------------------------------
Proposito: Batch para controlar el cambio de oficina de los especialistas , inactiva la relación y crea el externalId
------------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				  DATE				Description
	1.0			US493757	    Borja Lavesiera  	  16/01/2024	    Init version     
***********************************************************************************************************************/
public without sharing class CIBE_AccExtAccConRel_Batch implements Database.Batchable<sObject>, Database.Stateful {
    public list<id> relationIds = new list<Id>();
    private map<string, AccountContactRelation> accConKeyMap;
    private map<Id, Id> usuarioAsociadoContactMap;
    private map<Id, Id> contactUserMap;

    public CIBE_AccExtAccConRel_Batch() {
        //necesario para el fwk de batches
        system.debug('constructor CIBE_AccExtAccConRel_Batch');
    }

    public CIBE_AccExtAccConRel_Batch(list<Id> relationIds) {
        //para lanzar el batch sin el fwk
        this.relationIds = relationIds;

    }

    private list<id> constructor() {
        list<id> accList = new list<id>();
        list<id> contactList = new list<id>();
        list<id> accConRelList = new list<id>();
        this.accConKeyMap = new map<string, AccountContactRelation>();
        this.usuarioAsociadoContactMap = new map<Id, Id>();
        this.contactUserMap = new map<Id, Id>();
        for(AccountContactRelation accConRel : [SELECT Id, AccountId, contactId, isActive, isDirect FROM AccountContactRelation WHERE Id IN : this.relationIds AND IsDirect = false]){
            accList.add(accConRel.AccountId);
            contactList.add(accConRel.ContactId);
            accConRelList.add(accConRel.Id);
        }
        return accConRelList;
    }

    /**
	 *
	 * @param bc  Database.BatchableContext param that contains the batch job ID
	 */	
	public Database.QueryLocator start(Database.BatchableContext bc) {

        list<id> accConRelList = constructor();
        string sQuery;

        sQuery = 'SELECT Id, AccountId,Account.CC_Numero_Oficina_Empresa__c, contactId, contact.CC_Identificador__c, isActive, isDirect, FinServ__SourceSystemId__c, Contact.recordtype.developerName  FROM AccountContactRelation WHERE Id IN : accConRelList';
        return Database.getQueryLocator(sQuery);
	}

    public void execute(Database.BatchableContext bc, List<AccountContactRelation> scope){

        list<AccountContactRelation> accConRelToUpdate = new list<AccountContactRelation>();

        try{
            for(AccountContactRelation accConRel : scope) {
                if(accConRel.FinServ__SourceSystemId__c == null && accConRel.Contact.recordtype.developerName == 'CC_empleado') {
                    accConRel.FinServ__SourceSystemId__c = String.valueOf('CIBE_'+ accConRel.Account.CC_Numero_Oficina_Empresa__c + '_' +accConRel.contact.CC_Identificador__c);
                    if(accConRel.IsActive) {
                        accConRel.IsActive = false;
                    }
                accConRelToUpdate.add(accConRel); 
                }
            }
            Database.SaveResult[] dmlResult = Database.update(accConRelToUpdate, false);
            for(Database.SaveResult res : dmlResult) {
                if(!res.isSuccess()) {
                    for(Database.Error err : res.getErrors()) {
                        CBK_Log.error(err.getStatusCode() + ': ' + err.getMessage());
                    }
                }
            }
        } catch(Exception e) {
            CBK_Log.error(e);
        }
    }
    /**
	 * Print the results of the batch process
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 */
	public void finish(Database.BatchableContext bc){
		String methodName='finish';
        system.debug('finish Method CIBE_AccConRelTriggerHelper');
	}
}