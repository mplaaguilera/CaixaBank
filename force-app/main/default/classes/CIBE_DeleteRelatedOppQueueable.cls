/**********************************************************************************************************************
 Name:	  CIBE_DeleteRelatedOppQueueable
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase Queueable para eliminar las Tareas-Oportunidades relacionandas con la Oportunidad
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			US577980            Luis Martínez		16/05/2023			Init version
	
***********************************************************************************************************************/
public with sharing class CIBE_DeleteRelatedOppQueueable implements Queueable {
    
	public List<AV_CustomActivityOpportunity__c> custActOppList = new List<AV_CustomActivityOpportunity__c>();

	public CIBE_DeleteRelatedOppQueueable(List<AV_CustomActivityOpportunity__c> custActOppList) {
		this.custActOppList = custActOppList;
	}

    public void execute(System.QueueableContext qc){
		String methodName = 'executeDeleteRelatedCustomActivityOpp';
        if(custActOppList != null && !custActOppList.isEmpty()){
            List<Database.DeleteResult> updateResults = Database.delete(custActOppList, false);
            Database.emptyRecycleBin(custActOppList);
            Integer i = 0;
            for (Database.DeleteResult sr : updateResults) {
                if (sr.getErrors()!=null) {
                    for(Database.Error err : sr.getErrors()) {
                        CBK_Log.debug(methodName, 'Error: ' + err.getMessage() + ' -> Id: ' + custActOppList.get(i).Id);  
                    } 
                }
                i++;
            }
		}
	}
}