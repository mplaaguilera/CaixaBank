public with sharing class OS_Usuario_Backup {

    @InvocableMethod
    public static void cambioPropietario(List<Id> idUsuarios) {
        System.debug('KEVIN DEBUG entrada metodo');
        cambioPropietarioFuture(idUsuarios);
    }
    
    @future(callout=true)
    public static void cambioPropietarioFuture(List<Id> idUsuarios) {

        Map<Id, Id> backupsAgentes = new Map<Id, Id>();
        for (User usuario : [SELECT OS_Agente_Backup__c FROM User WHERE Id IN :idUsuarios
                                AND OS_Agente_Backup__c != NULL AND OS_Inicio_Vigencia_Agente_Backup__c <= TODAY AND OS_Fin_Vigencia_Agente_Backup__c >= TODAY]) {
            backupsAgentes.put(usuario.Id, usuario.OS_Agente_Backup__c);
        }

        List<Case> casos = [SELECT OwnerId FROM Case WHERE OwnerId IN :backupsAgentes.keySet()
                            AND Status NOT IN ('Cerrado', 'Rechazado', 'Pendiente Alerta')];
    
        for (Case caso : casos) {
            caso.OwnerId = backupsAgentes.get(caso.OwnerId);
        }
        update casos;
    }
}