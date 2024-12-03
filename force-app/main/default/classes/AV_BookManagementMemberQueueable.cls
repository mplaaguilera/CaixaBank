/**********************************************************************************************************************
 Name:	  AV_BookManagementMemberQueueable
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase Queueable para actulizar Accounts asociados al BookManagementMember
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			Init version        Sandra Gómez		04/04/2022			Init version
	1.1			US603731			Sandra Gómez		18/05/2022			Restructuring
	1.2		    Fix PMD Errors 	    Daniel Rodriguez	16/11/2023	    	Check empty paremeters in queries
    1.3		    Fix          	    Sandra Gómez    	16/11/2023	    	duplicity correction
    1.4         US839366            Ángel Medina        14/03/2024          add logic enqueueJob in method execute
***********************************************************************************************************************/
public with sharing class AV_BookManagementMemberQueueable implements Queueable {

	@testVisible private static Boolean doChainJob = !Test.isRunningTest();
	
	private Map<String, String> empleadoUsuario = new Map<String, String>();
    private List<AV_BookManagementMember__c> carterasGestor = new List<AV_BookManagementMember__c>();
    private List<Opportunity> listOppToUpdate = new List<Opportunity>();
    private List<Task> listTaskToUpdate = new List<Task>();
    private List<Event> listEventToUpdate = new List<Event>();

    public AV_BookManagementMemberQueueable(List<AV_BookManagementMember__c> carterasGestor, Map<String, String> empleadoUsuario) {
        this.carterasGestor = carterasGestor != null ? carterasGestor : new List<AV_BookManagementMember__c>();
        this.empleadoUsuario = empleadoUsuario != null ? empleadoUsuario : new Map<String, String>();

        this.listOppToUpdate = listOppToUpdate != null ? listOppToUpdate : new List<Opportunity>();
        this.listTaskToUpdate = listTaskToUpdate != null ? listTaskToUpdate : new List<Task>();
        this.listEventToUpdate = listEventToUpdate != null ? listEventToUpdate : new List<Event>();
    }

    public void execute(System.QueueableContext qc) {
        Integer maxQueueSize = !Test.isRunningTest() ? (Integer) AV_Bypass__c.getOrgDefaults().AV_BMMMaxQueueSize__c : 1;
        Map<Id, AV_BookManagementMember__c> carterasGestorMap = new Map<Id, AV_BookManagementMember__c>();
        List<AV_BookManagementMember__c> nextChunk = new List<AV_BookManagementMember__c>();
        for (AV_BookManagementMember__c carteraGestor : carterasGestor) {
            if(maxQueueSize == carterasGestorMap.size()) {
                nextChunk.add(carteraGestor);
            } else {
                if(String.isNotBlank(carteraGestor.AV_Cartera__c)) {
                    carterasGestorMap.put(carteraGestor.AV_Cartera__c, carteraGestor);
                }
            }
        }
        Set<Id> gestorIds = new Set<Id>();
        Set<Id> gestorIdsOld = new Set<Id>();
        Map<Id,Account> clientesNew = new Map<Id,Account>();
        List<Account> clientesOld = new List<Account>();
        if(!carterasGestorMap.isEmpty() && AV_BookMember__c.SObjectType.getDescribe().isAccessible() && Account.SObjectType.getDescribe().isAccessible()) {
            Set<Id> accountIds = new Set<Id>();
            Map<Id, Set<Id>> carteraClientes = new Map<Id, Set<Id>>();
            for(AV_BookMember__c bookMember : [SELECT Id, AV_Cliente__c, AV_Cartera__c FROM AV_BookMember__c WHERE AV_Cartera__c IN :carterasGestorMap.keySet() AND AV_CarteraPrincipal__c = true]) {
                if(String.isNotBlank(bookMember.AV_Cliente__c)) {
                    if(!carteraClientes.containsKey(bookMember.AV_Cartera__c)) {
                        carteraClientes.put(bookMember.AV_Cartera__c, new Set<Id>());
                    }
                    carteraClientes.get(bookMember.AV_Cartera__c).add(bookMember.AV_Cliente__c);
                    accountIds.add(bookMember.AV_Cliente__c);
                }
            }
            if(!accountIds.isEmpty() && Account.SObjectType.getDescribe().isAccessible()){
                Map<Id, Account> accountsMap = new Map<Id, Account>([SELECT Id, AV_EAPGestor__c FROM Account WHERE Id IN :accountIds]);
                for(Id carteraId : carteraClientes.keySet()) {
                    Set<Id> clienteIds = carteraClientes.get(carteraId);
                    Id gestorId = carterasGestorMap.get(carteraId).AV_EmpleadoGestor__c;
                    if(String.isNotBlank(gestorId)) {
                        for(Id clienteId : clienteIds) {
                            Account cliente = accountsMap.get(clienteId);
                            gestorIds.add(gestorId);
                            gestorIdsOld.add(cliente.AV_EAPGestor__c);
                            clientesOld.add(cliente);
                            if(cliente.AV_EAPGestor__c != gestorId && empleadoUsuario.containsKey(gestorId)) {
                                clientesNew.put(clienteId,new Account(Id = clienteId, AV_EAPGestor__c = gestorId, OwnerId = empleadoUsuario.get(gestorId)));
                            }
                        }
                    }
                }
            }
        }
        if(clientesNew != null && !clientesNew.isEmpty()) {
            AV_GestorReassignmentFuture.ListsOppTaskEvent lists = AV_GestorReassignmentFuture.processRelatedToAccount(JSON.serialize(clientesNew.values()), gestorIds, JSON.serialize(clientesOld), gestorIdsOld, false);
            listOppToUpdate.addAll(lists.listOpportunity);
            listTaskToUpdate.addAll(lists.listTask);
            listEventToUpdate.addAll(lists.listEvent);
            List<Database.SaveResult> updateResults = Database.update(clientesNew.values(), false);
            boolean hasError = false;
            List<Object> objs = new List<Object>();
            Map<String, String> msjs = new Map<String, String>();
            for (Integer i = 0; i < clientesNew.values().size(); i++) {
                Database.SaveResult sr = updateResults[i];
                if(!sr.isSuccess() && !sr.getErrors().isEmpty()) {
                    msjs.put(clientesNew.values()[i].Id, ((String) sr.getErrors()[0].getMessage()));
                    objs.add(clientesNew.values()[i]);
                    hasError = true;
                }
            }
            if(hasError) {
                CBK_Log.error(msjs, objs);
            }
            if(doChainJob && !nextChunk.isEmpty()) {
                System.enqueueJob(new AV_BookManagementMemberQueueable(nextChunk, empleadoUsuario));
            }else{
                if (listOppToUpdate != null && !listOppToUpdate.isEmpty()){
                    System.enqueueJob(new AV_GestorReassignmentQueueable(listOppToUpdate,listTaskToUpdate, listEventToUpdate));
                } else if (listTaskToUpdate != null && !listTaskToUpdate.isEmpty()) {
                    System.enqueueJob(new AV_GestorReassignmentTaskQueueable(listTaskToUpdate,listEventToUpdate));
                } else if (listEventToUpdate != null && !listEventToUpdate.isEmpty()) {
                    System.enqueueJob(new AV_GestorReassignmentEventsQueueable(listEventToUpdate));
                }

            }
        } 
    }
}