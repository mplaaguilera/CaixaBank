public with sharing class OS_User_AU_TRHan extends CC_TriggerHandlerBase{
	
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<User>)tp.newList, (Map<Id, User>)tp.newMap, (List<User>) tp.oldList, (Map<Id, User>) tp.oldMap);
	}
	
	private void process(List<User> listNewObj, Map<Id, User> mapNewObj, List<User> listOldObj, Map<Id, User> mapOldObj) {
        List<User> listNewObjCops= New List<User>();
        listNewObjCOPS = descartarUsuariosNoCops(listNewObj);
        if(listNewObjCOPS.size() != 0){
            programarBajaAgenteBackup(listNewObjCOPS, mapOldObj);
        }
        
	}
    private static void programarBajaAgenteBackup(List<User> listNewObj, Map<Id, User> mapOldObj){
        
        List<Id> idUsuarios = new List<Id>();
        List<CBK_SCH_PendingProcess__c> procesos = new List<CBK_SCH_PendingProcess__c>();
        for (User usuarioNew: listNewObj){
            User usuarioOld = mapOldObj.get(usuarioNew.Id);
            if (usuarioNew.OS_Fin_Vigencia_Agente_Backup__c != usuarioOld.OS_Fin_Vigencia_Agente_Backup__c
                && usuarioNew.OS_Fin_Vigencia_Agente_Backup__c != null
                && usuarioNew.OS_Fin_Vigencia_Agente_Backup__c >= System.today()
                && (usuarioNew.OS_Inicio_Vigencia_Agente_Backup__c >= DateTime.now() || usuarioNew.OS_Inicio_Vigencia_Agente_Backup__c <= DateTime.now())
                && (usuarioNew.OS_Agente_Backup__c != null || usuarioNew.OS_Cola_Backup__c != null))
            {
                    CBK_SCH_PendingProcess__c pendingProcessBackup = new CBK_SCH_PendingProcess__c();
                    pendingProcessBackup.RecordId__c = usuarioNew.Id;
                    pendingProcessBackup.Schedule_Time__c = usuarioNew.OS_Fin_Vigencia_Agente_Backup__c;
                    pendingProcessBackup.ClassName__c = 'CBK_SCH_OS_ScheduleAgenteBackup';
                	procesos.add(pendingProcessBackup);

                    if(usuarioNew.OS_Inicio_Vigencia_Agente_Backup__c <= DateTime.now()){
                        idUsuarios.add(usuarioNew.Id);
                    }
            }
            if(usuarioNew.OS_Inicio_Vigencia_Agente_Backup__c <= System.today()){
                idUsuarios.add(usuarioNew.Id);
            }
        }
        if(!procesos.isEmpty()){
            insert procesos;
        OS_Usuario_Backup.cambioPropietario(idUsuarios);
        }     
    }
    private static List<User> descartarUsuariosNoCops(List<User> usuarios) {
        List<User> usuariosCops = new List<User>();
        Set <Id> idUsers = new Set<Id>();
        for (User usuario : usuarios) {
        	idUsers.add(usuario.Id);
        }
        usuariosCops = [SELECT Id, OS_Fin_Vigencia_Agente_Backup__c, OS_Inicio_Vigencia_Agente_Backup__c, OS_Agente_Backup__c, OS_Cola_Backup__c FROM User WHERE Id IN :idUsers AND UserRole.DeveloperName = 'COPS'];
            
        return usuariosCops;
    }
}