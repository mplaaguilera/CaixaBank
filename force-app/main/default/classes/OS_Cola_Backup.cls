public with sharing class OS_Cola_Backup {
	
    @InvocableMethod
    public static void cambioPropietario(List<Id> idUsuarios) {
        cambioPropietarioFuture(idUsuarios);
    }
    
    @future(callout=true)
    public static void cambioPropietarioFuture(List<Id> idUsuarios) {

        List<string> backupsColas = new List<string>();
        for (User usuario : [SELECT OS_Cola_Backup__c FROM User WHERE Id IN :idUsuarios
                                AND OS_Cola_Backup__c != NULL AND OS_Inicio_Vigencia_Agente_Backup__c <= TODAY AND OS_Fin_Vigencia_Agente_Backup__c >= TODAY]) {
            backupsColas.add(usuario.OS_Cola_Backup__c);
        }
        
		List<Group> grupos = [SELECT ID, DeveloperName, Name FROM Group WHERE Name IN :backupsColas AND Type ='Queue'];
        
        
        List<Case> casos = [SELECT OwnerId FROM Case WHERE OwnerId IN :idUsuarios
                            AND Status NOT IN ('Cerrado', 'Rechazado', 'Pendiente Alerta')];
    
        for (Case caso : casos) {
            caso.OwnerId = grupos[0].id;
        }
        update casos;
    }
}