public with sharing class CBK_SCH_OS_ScheduleAgenteBackup extends CBK_SCH_Queueable_Abstract{
	public override void execute(QueueableContext ctx) {
        List<CBK_SCH_PendingProcess__c> incomingPendingProcessList = this.lstInfoProcess;
        work(incomingPendingProcessList);
 
    }
 
    private void work(List<CBK_SCH_PendingProcess__c> incomingPendingProcessList) {

        Set<Id> pendingProcessUserIdSet = new Set<Id>();

        for(CBK_SCH_PendingProcess__c pendingProcess: incomingPendingProcessList){
            pendingProcessUserIdSet.add(pendingProcess.RecordId__c);
        }
        
        User[] pendingProcessUserList = [SELECT Id, OS_Inicio_Vigencia_Agente_Backup__c, OS_Fin_Vigencia_Agente_Backup__c, OS_Agente_Backup__c, 
                                                       OS_Cola_Backup__c 
                                                       FROM User WHERE Id=:pendingProcessUserIdSet];
        Map<Id, User> idUserMap = new Map<Id, User>();

        for(User usuario: pendingProcessUserList){
            idUserMap.put(usuario.Id, usuario);
        }
        List <User> usersUpdate = new List <User>();
        for(CBK_SCH_PendingProcess__c pendingProcess: incomingPendingProcessList){
            if(idUserMap.containsKey(pendingProcess.RecordId__c)){
                User usuario = idUserMap.get(pendingProcess.RecordId__c);
                if(usuario.OS_Fin_Vigencia_Agente_Backup__c <= System.now()){
                    usuario.OS_Fin_Vigencia_Agente_Backup__c = null;
                    usuario.OS_Inicio_Vigencia_Agente_Backup__c = null;
                    usuario.OS_Agente_Backup__c = null;
                    usuario.OS_Cola_Backup__c = null;
                    usersUpdate.add(usuario);
                    
                }
            }
        }
        try {
            update usersUpdate;
        } catch (Exception e) {
            CBK_Log.error(e);
        }
    }
}