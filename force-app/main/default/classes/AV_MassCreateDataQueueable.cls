/**********************************************************************************************************************
 Name: AV_MassCreateDataQueueable
 Copyright © 2021  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Propósito: Inserta tareas, eventos, oportunidades y Tareas-Oportunidad mediante un Queueable. Clase de apoyo para
AV_MassCreateData.
-----------------------------------------------------------------------------------------------------------------------
Historial
-----------------------------------------------------------------------------------------------------------------------
   VERSION        USER_STORY       AUTHOR           DATE                Description
   1.0            US196253         Víctor Santiago  11/06/2021          Init version

***********************************************************************************************************************/
global class AV_MassCreateDataQueueable implements Queueable {

    global Integer recordsProcessed = 0;
	global static final String BATCHNAME = 'AV_MassCreateDataQueueable';
	global List<sObject> lista = new List<sObject>();
	global String avLimit;
    global String objName;
    
    public AV_MassCreateDataQueueable(List<sObject> objList, String objName) {
        this.lista = objList;
        this.objName = objName;
    }

    global void execute(System.QueueableContext qc){
        if ('Task'.equals(objName)) {
            List<Database.SaveResult> rs = Database.insert((List<Task>) lista, false);


        } else if ('Event'.equals(objName)) {
            Database.insert((List<Event>) lista, false);
        } else if ('Opportunity'.equals(objName)) {
            Database.insert((List<Opportunity>) lista, false);
        } else if ('Tarea-Oportunidad'.equals(objName)) {
            Database.insert((List<AV_CustomActivityOpportunity__c>) lista, false);
        }
    }

}