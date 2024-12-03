public with sharing class OS_Programar_Alerta {

    public static void programarAlerta(List<Id> idCaso) {

        Set<Id> caseIds = new Set<Id>(idCaso);
        Set<Id> usersIds = new Set<Id>();
        List<Case> listaCasos = new List<Case>();
        List<Case> lstCasesUpdt = new List<Case>();
        List<Event> listEventos = new List<Event>();
        List<Event> lstEventUpdt = new List<Event>();
        List<User> listUsuarios = new List<User>();
        Map<Id, Id> mapidCaseidEvent = new Map<Id, Id>();
        Map<Id, User> mapidUser = new Map<Id, User>();

        listaCasos = [SELECT CaseNumber, OS_Alerta_Fecha__c, OS_Alerta_Nuevo_Propietario__c, OwnerId FROM Case WHERE Id IN :idCaso];
        listEventos = [SELECT Id, WhatId FROM Event WHERE OS_Alerta_Vencida__c = false AND WhatId IN :caseIds ORDER BY StartDateTime];

        for (Case caso : listaCasos) {
            usersIds.add(caso.OwnerId);
        }

        if(!usersIds.isEmpty()){
            listUsuarios = [SELECT Id, OS_Agente_Backup__c, OS_Inicio_Vigencia_Agente_Backup__c, OS_Fin_Vigencia_Agente_Backup__c FROM User WHERE Id IN :usersIds];
        
            for (User usuario : listUsuarios) {
                mapidUser.put(usuario.Id, usuario);
            }
        }
        
        for (Event evento : listEventos) {
            if(!mapidCaseidEvent.containsKey(evento.WhatId)){
                mapidCaseidEvent.put(evento.WhatId, evento.Id);
            }
        }

        for (Case caso : listaCasos) {
            /*
            * En el caso de que el propietario de la alerta sea diferente al propietario actual del caso no hace falta modificar el owner id, porque el usuario que gestionara el caso serà el propietario de la alerta
            * Solo cambiamos el caso al usuario backup si el propietario de la alerta es el mismo que el OwnerId. Porque no estarà para gestionarlo 
            */
            if (mapidUser.get(caso.OwnerId).OS_Agente_Backup__c != null && mapidUser.get(caso.OwnerId).OS_Fin_Vigencia_Agente_Backup__c > caso.OS_Alerta_Fecha__c && caso.OS_Alerta_Fecha__c > mapidUser.get(caso.OwnerId).OS_Inicio_Vigencia_Agente_Backup__c) {
                caso.OwnerId = mapidUser.get(caso.OwnerId).OS_Agente_Backup__c;
            } else if(caso.OS_Alerta_Nuevo_Propietario__c != null){
                caso.OwnerId = caso.OS_Alerta_Nuevo_Propietario__c;
            }

            caso.OS_Alerta_Fecha__c = null;
            caso.OS_Alerta_Nuevo_Propietario__c = null;
            caso.Status = 'Activo';
            caso.OS_Alerta_Descripcion__c = null;
            lstCasesUpdt.add(caso);
            
            if (mapidCaseidEvent.get(caso.Id) != null) {
                Event evento = new Event();
                evento.Id = mapidCaseidEvent.get(caso.Id);
                evento.OS_Alerta_Vencida__c = true;
                evento.OwnerId = caso.OwnerId;
                evento.OS_CaseNumber__c = caso.CaseNumber;
                lstEventUpdt.add(evento);
            }
        }

        if(!lstCasesUpdt.isEmpty()){
            update lstCasesUpdt;
        }

        if(!lstEventUpdt.isEmpty()){
            update lstEventUpdt;
        }
    }
}