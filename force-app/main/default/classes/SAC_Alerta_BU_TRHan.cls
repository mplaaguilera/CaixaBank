public without  sharing class SAC_Alerta_BU_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<SAC_Alerta__c>)tp.newList, (Map<Id, SAC_Alerta__c>)tp.newMap, (List<SAC_Alerta__c>)tp.oldList, (Map<Id, SAC_Alerta__c>)tp.oldMap);
	}

    private void process(List<SAC_Alerta__c> listNewObj, Map<Id, SAC_Alerta__c> mapNewObj, List<SAC_Alerta__c> listOldObj, Map<Id, SAC_Alerta__c> mapOldObj) {
        //Record types SAC
        Id recTypeAlertaSAC = Schema.SObjectType.SAC_Alerta__c.getRecordTypeInfosByDeveloperName().get('SAC_Alerta').getRecordTypeId();
        Id recTypeReclamacion = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();

        List<Id> idReclamacionesAdd = new List<Id>();
        List<Id> idReclamacionesSubtract = new List<Id>();
        List<Case> listaSelectReclamaciones = new List<Case>();
        List<SAC_Alerta__c> listaAlertasMarcarLeidas = new List<SAC_Alerta__c>();
        List<SAC_Alerta__c> listaAlertasMarcarNoLeidas = new List<SAC_Alerta__c>();
        Map<Id, Case> mapaReclamacionesUpdatear = new Map<Id, Case>();

        //Filtrar record types
        for (SAC_Alerta__c alerta : listNewObj) {
            if (alerta.RecordTypeId == recTypeAlertaSAC) {
                if(mapOldObj.containsKey(alerta.Id) && alerta.SAC_Leido__c != mapOldObj.get(alerta.Id).SAC_Leido__c && alerta.SAC_Leido__c){
                    listaAlertasMarcarLeidas.add(alerta);
                    idReclamacionesAdd.add(alerta.SAC_Reclamacion__c);
                }
                if(mapOldObj.containsKey(alerta.Id) && alerta.SAC_Leido__c != mapOldObj.get(alerta.Id).SAC_Leido__c && !alerta.SAC_Leido__c){
                    listaAlertasMarcarNoLeidas.add(alerta);
                    idReclamacionesSubtract.add(alerta.SAC_Reclamacion__c);
                }
            }
        }

        //Select a las reclamaciones en caso de que las necesitemos
        if (!idReclamacionesAdd.isEmpty() || !idReclamacionesSubtract.isEmpty()) {
            listaSelectReclamaciones = [SELECT Id, SAC_AlertasPtes__c FROM  Case 
                                        WHERE RecordTypeId = :recTypeReclamacion 
                                        AND (Id IN:idReclamacionesAdd OR Id IN: idReclamacionesSubtract)];
        }

        //LLamada a los metodos
        if (!listaAlertasMarcarLeidas.isEmpty()) {
            alertaCambioALeida(listaAlertasMarcarLeidas, listaSelectReclamaciones, mapaReclamacionesUpdatear);
        }
        if (!idReclamacionesSubtract.isEmpty()) {
            alertaCambioANoLeida(listaAlertasMarcarNoLeidas, listaSelectReclamaciones, mapaReclamacionesUpdatear);
        }

        //Update final de los casos si es necesario
        if (!mapaReclamacionesUpdatear.isEmpty()) {
            update mapaReclamacionesUpdatear.values();
        }
    }

    public static void alertaCambioALeida(List<SAC_Alerta__c> listaAlertasMarcarLeidas, List<Case> listaSelectReclamaciones, Map<Id, Case> mapaReclamacionesUpdatear) {
        //Pasar la lista que traemos del select a un mapa
        Map<Id, Case> mapaSelectReclamaciones = new Map<Id, Case>(listaSelectReclamaciones);

        //Recorrer las alertas que se han marcado como leidas para añadir el usuario lector y la fecha de lectura
        //Busca la reclamación padre de cada alerta y la añade al mapaReclamacionesUpdatear para poder updatear las reclamaciones al final del trigger
        for (SAC_Alerta__c alerta : listaAlertasMarcarLeidas) {
            alerta.SAC_UsuarioLector__c = UserInfo.getUserId();
            alerta.SAC_FechaLectura__c = System.now();
            //Preparar reclamación a actualizar
            if (mapaSelectReclamaciones.containsKey(alerta.SAC_Reclamacion__c)) {
                if (mapaReclamacionesUpdatear.containsKey(alerta.SAC_Reclamacion__c)) {
                    mapaReclamacionesUpdatear.get(alerta.SAC_Reclamacion__c).SAC_AlertasPtes__c = mapaSelectReclamaciones.get(alerta.SAC_Reclamacion__c).SAC_AlertasPtes__c - 1;
                } else {
                    mapaSelectReclamaciones.get(alerta.SAC_Reclamacion__c).SAC_AlertasPtes__c = mapaSelectReclamaciones.get(alerta.SAC_Reclamacion__c).SAC_AlertasPtes__c - 1;
                    mapaReclamacionesUpdatear.put(mapaSelectReclamaciones.get(alerta.SAC_Reclamacion__c).Id, mapaSelectReclamaciones.get(alerta.SAC_Reclamacion__c));
                }    
            }
        }
    }

    public static void alertaCambioANoLeida(List<SAC_Alerta__c> listaAlertasMarcarNoLeidas, List<Case> listaSelectReclamaciones, Map<Id, Case> mapaReclamacionesUpdatear) {
        //Pasar la lista que traemos del select a un mapa
        Map<Id, Case> mapaSelectReclamaciones = new Map<Id, Case>(listaSelectReclamaciones);

        //Recorrer las alertas que se han marcado como NO leidas para eliminar el usuario lector y la fecha de lectura
        //Busca la reclamación padre de cada alerta y la añade al mapaReclamacionesUpdatear para poder updatear las reclamaciones al final del trigger
        for (SAC_Alerta__c alerta : listaAlertasMarcarNoLeidas) {
            alerta.SAC_UsuarioLector__c = null;
            alerta.SAC_FechaLectura__c = null;
            //Preparar reclamación a actualizar
            if (mapaSelectReclamaciones.containsKey(alerta.SAC_Reclamacion__c)) {
                if (mapaReclamacionesUpdatear.containsKey(alerta.SAC_Reclamacion__c)) {
                    mapaReclamacionesUpdatear.get(alerta.SAC_Reclamacion__c).SAC_AlertasPtes__c = mapaSelectReclamaciones.get(alerta.SAC_Reclamacion__c).SAC_AlertasPtes__c + 1;
                } else {
                    mapaSelectReclamaciones.get(alerta.SAC_Reclamacion__c).SAC_AlertasPtes__c = mapaSelectReclamaciones.get(alerta.SAC_Reclamacion__c).SAC_AlertasPtes__c + 1;
                    mapaReclamacionesUpdatear.put(mapaSelectReclamaciones.get(alerta.SAC_Reclamacion__c).Id, mapaSelectReclamaciones.get(alerta.SAC_Reclamacion__c));
                }    
            }
        }
    }
}