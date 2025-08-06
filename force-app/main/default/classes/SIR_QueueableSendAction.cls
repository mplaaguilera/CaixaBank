public with sharing class SIR_QueueableSendAction implements Queueable{
    public List<SIREC__SIREC_obj_acciones__c> lstAcciones; 
    public SIR_QueueableSendAction(List<SIREC__SIREC_obj_acciones__c> conListAcciones){
        lstAcciones = conListAcciones ;
        
    }
    public void execute(System.QueueableContext context) {
            for(SIREC__SIREC_obj_acciones__c accion : lstAcciones){
                SIR_SendNewAction_WS.futureSendAction(accion.Id);
            }

        }
}