public class GRR_Case_AD_TRHan extends CC_TriggerHandlerBase {

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


        List <Id> lstIdsCasosCuentas = new List<Id>();
        List <Account> lstAccounts = new List<Account>();
        // Se borran los datos de la historia del cliente
        for (Case caso : lstCasesGRR) {
            lstIdsCasosCuentas.add(caso.AccountId);
            lstIdsCasosCuentas.add(caso.Id);
            if(caso.Account.GRR_Historia__c != null){
                Account acc = new Account();
                acc.Id = caso.AccountId;    // Se borra el ID del caso para que se actualice el Account
                acc.GRR_Historia__c = null;
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