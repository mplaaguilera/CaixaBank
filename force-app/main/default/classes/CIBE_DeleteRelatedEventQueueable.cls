/**********************************************************************************************************************
Name:	  CIBE_DeleteRelatedEventQueueable
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase Queueable para eliminar la entidades relacionandas con el evento
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			Init version        Luis Martinez		12/05/2023			Init version

***********************************************************************************************************************/
public with sharing class CIBE_DeleteRelatedEventQueueable implements Queueable{


    public List<AV_ManagementHistory__c> listManagementHistory = new List<AV_ManagementHistory__c>();
	public List<CBK_Activity_Extension__c> listEventExtension= new List<CBK_Activity_Extension__c>();
	public List<AV_CustomActivityOpportunity__c> listEventOpp = new List<AV_CustomActivityOpportunity__c>();
    public List<AV_HeaderCustomActivity__c> listHeaderEvent = new List<AV_HeaderCustomActivity__c>();
	
	public CIBE_DeleteRelatedEventQueueable(List<AV_ManagementHistory__c> listManagementHistory, List<CBK_Activity_Extension__c> listEventExtension, List<AV_CustomActivityOpportunity__c> listEventOpp,list<AV_HeaderCustomActivity__c> listHeaderEvent) {
		this.listManagementHistory = listManagementHistory;
		this.listEventExtension = listEventExtension;
		this.listEventOpp = listEventOpp;
        this.listHeaderEvent = listHeaderEvent;
	}

    public void execute(System.QueueableContext qc){
		String methodName = 'executeDeleteRelatedEvent';
        Map<String,String> mapErrors = new Map<String,String> ();
        List<SObject> lstObjeto = new List<SObject> ();

		if(listManagementHistory != null && !listManagementHistory.isEmpty()){
            List<Database.DeleteResult> updateResults = Database.delete(listManagementHistory, false);
            Database.emptyRecycleBin(listManagementHistory);
            Integer i = 0;
            for (Database.DeleteResult sr : updateResults) {
                if (sr.getErrors()!=null) {
                    for(Database.Error err : sr.getErrors()) {
                        mapErrors.put(listManagementHistory.get(i).Id,err.getMessage());
                        lstObjeto.add(listManagementHistory.get(i));     
                    } 
                }
                i++;
            }
		}
        if(listEventExtension != null && !listEventExtension.isEmpty()){
            List<Database.DeleteResult> updateResults = Database.delete(listEventExtension, false);
            Database.emptyRecycleBin(listEventExtension);
            Integer i = 0;
            for (Database.DeleteResult sr : updateResults) {
                if (sr.getErrors()!=null) {
                    for(Database.Error err : sr.getErrors()) {
                        mapErrors.put(listEventExtension.get(i).Id,err.getMessage());
                        lstObjeto.add(listEventExtension.get(i));    
                    } 
                }
                i++;
            }
		}
        if(listEventOpp != null && !listEventOpp.isEmpty()){
            List<Database.DeleteResult> updateResults = Database.delete(listEventOpp, false);
            Database.emptyRecycleBin(listEventOpp);
            Integer i = 0;
            for (Database.DeleteResult sr : updateResults) {
                if (sr.getErrors()!=null) {
                    for(Database.Error err : sr.getErrors()) {
                        mapErrors.put(listEventOpp.get(i).Id,err.getMessage());
                        lstObjeto.add(listEventOpp.get(i));  
    
                    } 
                }
                i++;
            }
		}
        if(listHeaderEvent != null && !listHeaderEvent.isEmpty()){
            List<Database.DeleteResult> updateResults = Database.delete(listHeaderEvent, false);
            Database.emptyRecycleBin(listHeaderEvent);
            Integer i = 0;
            for (Database.DeleteResult sr : updateResults) {
                if (sr.getErrors()!=null) {
                    for(Database.Error err : sr.getErrors()) {
                        mapErrors.put(listHeaderEvent.get(i).Id,err.getMessage());
                        lstObjeto.add(listHeaderEvent.get(i));  
                    } 
                }
                i++;
            }
		}

        if(mapErrors!=null && mapErrors.size()>0){
            CBK_Log.Error(mapErrors,lstObjeto);      
        }

	}
}