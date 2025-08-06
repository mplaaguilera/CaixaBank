public with sharing class GRR_Case_BD_TRHan extends CC_TriggerHandlerBase {

	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Case>)tp.newList, (Map<Id, Case>)tp.newMap, (List<Case>)tp.oldList, (Map<Id, Case>)tp.oldMap);
	}

	private void process(List<Case> listNewObj, Map<Id, Case> mapNewObj, List<Case> listOldObj, Map<Id, Case> mapOldObj) {
		Id rtCliente = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'GRR_Cliente');
        
        List<Case> lstCasesGRR = new List<Case>();
        for (Case caso : listOldObj) {
            if (caso.RecordTypeId == rtCliente) {
                lstCasesGRR.add(caso);
            }
        }

        if (!lstCasesGRR.isEmpty()) {
            limpiarAdjuntos(lstCasesGRR);
        }
	}

    /************ 
    US1131018 - GRR - Purgado de información de Salesforce
    Ángel Picado - 11/06/2025
    ************/

    private void limpiarAdjuntos(List<Case> lstCasesGRR) {


        List <Id> lstIdsCasosCuentas = new List<Id>(); // Lista de los IDs de los casos y cuentas asociadas
        List <Case> lstCasos = [SELECT Id, AccountId, Account.GRR_Historia__c FROM Case WHERE Id IN :lstCasesGRR];
        List <Account> lstAccounts = new List<Account>();

        for (Case caso : lstCasos) {

            //Se añaden los IDs de los casos y cuentas asociadas para borrar los adjuntos
            lstIdsCasosCuentas.add(caso.AccountId);
            lstIdsCasosCuentas.add(caso.Id);

            //Si la historia del cliente no está vacía, se borra la historia
            if(caso.Account.GRR_Historia__c != null){
                Account acc = new Account();
                acc.Id = caso.AccountId;    // Se borra el ID de la cuenta para que se actualice el Account
                acc.GRR_Historia__c = '';
                lstAccounts.add(acc);
            }
        }

        // Se borran los adjuntos de los casos al borrar el caso
        List<ContentDocumentLink> lstIdsBorrar = [SELECT ContentDocumentId FROM ContentDocumentLink where LinkedEntityId IN :lstIdsCasosCuentas];
        if (!lstIdsBorrar.isEmpty()) {
            List<ContentDocument> docsToDelete = new List<ContentDocument>();
            for(ContentDocumentLink cdl : lstIdsBorrar) {
                docsToDelete.add(new ContentDocument(Id = cdl.ContentDocumentId));
            }
            delete docsToDelete;
        }

        if (!lstAccounts.isEmpty()) {
            update lstAccounts;
        }


    }
}