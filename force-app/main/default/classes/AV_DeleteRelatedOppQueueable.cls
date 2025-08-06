/**********************************************************************************************************************
 Name:	  AV_DeleteRelatedOppQueueable
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase Queueable para eliminar las Tareas-Oportunidades relacionandas con la Oportunidad
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			US482011            Patricia Solano		28/03/2023			Init version
    1.1			Fix					Gonzalo Ávila		27/09/2023			Fix CBK_Log Error
	
***********************************************************************************************************************/
public with sharing class AV_DeleteRelatedOppQueueable implements Queueable {
    
	public List<AV_CustomActivityOpportunity__c> custActOppList = new List<AV_CustomActivityOpportunity__c>();

	public AV_DeleteRelatedOppQueueable(List<AV_CustomActivityOpportunity__c> custActOppList) {
		this.custActOppList = custActOppList;
	}

    public void execute(System.QueueableContext qc){
        List<String> listErrorsExecute = new List<String>();
		String methodName = 'executeDeleteRelatedCustomActivityOpp';
        if(custActOppList != null && !custActOppList.isEmpty()){
            AV_LogDebug.printLogDebug(methodName, 'AV_CustomActivityOpportunity__c que se eliminan: '+custActOppList.size());
            List<Database.DeleteResult> updateResults = Database.delete(custActOppList, false);
            Database.emptyRecycleBin(custActOppList);
            Integer i = 0;
            for (Database.DeleteResult sr : updateResults) {
                if (sr.getErrors()!=null) {
                    for(Database.Error err : sr.getErrors()) {
                        AV_LogDebug.printLogDebug(methodName, 'Error: ' + err.getMessage() + ' -> Id: ' + custActOppList.get(i).Id);
                        listErrorsExecute.add('Error: ' + err.getMessage() + ' -> Id: ' + custActOppList.get(i).Id);
                    } 
                }
                i++;
            }
            if(!listErrorsExecute.isEmpty()) {
                CBK_log.error('Metodo: '+methodName+' listErrorsExecute: '+listErrorsExecute,listErrorsExecute);
            }
		}
	}
}