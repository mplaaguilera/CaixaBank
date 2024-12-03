/**********************************************************************************************************************
Name:      CIBE_TMPortfolioCustomer_Batch
Copyright © 2023 CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Batch que se lanza con parametro de contactos y carteras relacionadas para sacar los accounts relacionados
con las carteras y asi construir la relacion entre user y account para la accountTeamMember
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION        USER_STORY       AUTHOR           DATE                Description
    1.0            Create Batch	    Alex Perez       02/05/2023          Init version
***********************************************************************************************************************/
public with sharing class CIBE_TMPortfolioCustomer_Batch implements Database.Batchable<sObject>, Database.Stateful {

    private Map<Id, list<Id>> carteraContactMap = new map<Id, list<Id>>();
    private map<id, id> contactUserMap = new map<Id, id>();
    private set<Id> contacts = new set<id>();
    private map<id, user> users = new map<id, user>();
    public list<string> contactCarteraList = new list<string>();

    public CIBE_TMPortfolioCustomer_Batch(list<string> contactCarteraList) {
        this.contactCarteraList = contactCarteraList;
    }

    public CIBE_TMPortfolioCustomer_Batch() {
        system.debug('constructor CIBE_TMPortfolioCustomer_Batch');
    }

    /* si se usa el fwk de batch primero se tiene que ejecutar el constructor en el start ya que el mismo constructor no se puede*/
    private void constructor(){
        this.contacts = new set<id>();
        this.carteraContactMap = new map<Id, list<Id>>();
        this.contactUserMap = new map<Id, id>();
        this.users = new map<id, user>(); 
        for(string conCar: this.contactCarteraList){
            string[] contactCar = conCar.split('\\|');
            this.contacts.add(contactCar[0]);
            if(carteraContactMap.containsKey(contactCar[1])) {
                carteraContactMap.get(contactCar[1]).add(contactCar[0]);
            } else {
                carteraContactMap.put(contactCar[1], new list<id>{contactCar[0]});
            }
        }
        system.debug(this.contacts);
        for(contact con : [SELECT Id, av_usuarioAsociado__c from Contact where id = : this.contacts]){
            this.contactUserMap.put(con.id, con.av_usuarioAsociado__c);
            system.debug('contactUserMap ' + contactUserMap);
        }
        for(user us : [SELECT Id, isActive from User where id = : this.contactUserMap.values()]){
            this.users.put(us.Id, us);
        }
    }

    /**
     *  @description Mira del listado de carteras cuantas están relacionadas con accounts y relaciona el account con el user en la accountTeamMember
     *  @param bc -> Objeto contexto
     *  @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        constructor();
        set<Id> carteras = this.carteraContactMap.keySet();
        string squery = 'SELECT Id, AV_Cliente__c, AV_Cartera__c FROM AV_BookMember__c WHERE AV_Cartera__c = : carteras AND AV_CarteraActiva__c = \'S\' AND AV_Cliente__r.recordType.developerName = \'CC_Cliente\'';
        return Database.getQueryLocator(squery);
    }

    /**
     *  @description 
     *  @param bc -> Objeto contexto
     *  @param scope -> Lista de oportunidades que se van a tratar
     */
    public void execute(Database.BatchableContext bc, List<AV_BookMember__c> scope) {
        map<id, id> clienteCarteraMap = new map<id, id>();
        set<Id> clienteIdMap = new set<Id>();
        map<id, list<id>> carteraClientesMap = new map<id, list<id>>();
        list<string> toIgnore = new list<string>();
        list<AccountTeamMember> accMemberToDelete = new list<AccountTeamMember>();
        list<AccountTeamMember> accMemberToInsert = new list<AccountTeamMember>();
		//try{
        for(AV_BookMember__c tMemb : scope) {
            system.debug(tMemb);
            //clienteCarteraMap.put(tMemb.AV_Cliente__c, tMemb.AV_Cartera__c);
            clienteIdMap.add(tMemb.AV_Cliente__c);
            if(carteraClientesMap.containsKey(tMemb.AV_Cartera__c)) {
                //carteraClientesMap.put(tMemb.AV_Cartera__c, (list<Id>)(carteraClientesMap.get(tMemb.AV_Cartera__c).add(tMemb.AV_Cliente__c)));
                carteraClientesMap.get(tMemb.AV_Cartera__c).add(tMemb.AV_Cliente__c);
            } else {
                //list<id> listClientes = new list<id>{tMemb.AV_Cliente__c};
                carteraClientesMap.put(tMemb.AV_Cartera__c, new list<id>{tMemb.AV_Cliente__c});
            }
            system.debug('carteraClientesMap ' + carteraClientesMap);
        }
        if(!scope.isEmpty()){
            for(AccountTeamMember accMember : [SELECT AccountId, UserId, cibe_isAutomatic__c FROM AccountTeamMember 
                                                WHERE AccountId IN : clienteIdMap AND UserId IN : users.keySet()]){
                //Id contactId = usuarioAsociadoContactMap.get(accMember.UserId);
                //Id accountId = clientesOficinasMap.get(accMember.AccountId);
                //if(accConKeyMap.containsKey(accountId+ '|' +contactId)) {
                if(this.users.get(accMember.UserId).isActive){
                    toIgnore.add(accMember.AccountId +'|'+ accMember.UserId);
                    system.debug('toIgnore ' + accMember.AccountId +'|'+ accMember.UserId);
                } else if(accMember.cibe_isAutomatic__c) {
                    accMemberToDelete.add(accMember);
                }  
                //}                                
            }
        }
        system.debug('this.contactUserMap' + this.contactUserMap);
        for(id cartera : carteraClientesMap.keySet()){
            for(id clienteId : carteraClientesMap.get(cartera)){
                if(carteraContactMap.containsKey(cartera)) {
                    for(id contactId : carteraContactMap.get(cartera)){
                        if(!toIgnore.contains(clienteId+'|'+this.contactUserMap.get(contactId))){
                            system.debug(clienteId+'|'+this.contactUserMap.get(contactId));
                            AccountTeamMember acctoInsert = new AccountTeamMember(
                                AccountId = clienteId,
                                UserId = this.contactUserMap.get(contactId),
                                CIBE_isAutomatic__c = true,
                                AccountAccessLevel = 'Read',
                                OpportunityAccessLevel = CIBE_AppConstants.NONE,
                                CaseAccessLevel = 'Read',
                                ContactAccessLevel = 'Edit',
                                TeamMemberRole = 'Participante'
                            );
                            accMemberToInsert.add(acctoInsert);
                            toIgnore.add(clienteId+'|'+this.contactUserMap.get(contactId));
                        }
                    }
                }
            }
        }
        Database.SaveResult[] dmlResult = Database.insert(accMemberToInsert, false);
        Database.deleteResult[] deleteResult = Database.delete(accMemberToDelete, false);
        for(Database.SaveResult res : dmlResult) {
            if(!res.isSuccess()) {
                for(Database.Error err : res.getErrors()) {
                    CBK_Log.error(err.getStatusCode() + ': ' + err.getMessage());
                }
            }
        }
        for(Database.deleteResult res : deleteResult) {
            if(!res.isSuccess()) {
                for(Database.Error err : res.getErrors()) {
                    CBK_Log.error(err.getStatusCode() + ': ' + err.getMessage());
                }
            }
        }
       /* } catch(System.Exception e) { al lanzarse con el fwk de batch, cualquier error del batch será capturado
            CBK_Log.error(e);
        }*/ 
    }

    /**
     *  De momento no tiene funcionalidad alguna
     */
    public void finish(Database.BatchableContext bc){
        String methodName = 'finish';
		//CBK_Log.debug(methodName, ('Record Processes: ' + recordsProcessed));
    }
}