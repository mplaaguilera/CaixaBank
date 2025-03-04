public with sharing class CSBD_BatchIdentificarCliente implements Database.Batchable<sObject> {

    public CSBD_BatchIdentificarCliente() {}

    public Database.QueryLocator start(Database.BatchableContext BC) {
        Map<String, Schema.RecordTypeInfo> mapa = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName();
        Set<Id> recordTypeIds = new Set<Id>();

        for (String rt : mapa.keySet()) {
            if (rt.startsWith('CSBD_')) {
                recordTypeIds.add(mapa.get(rt).getRecordTypeId());
            }
        }

        List<String> recordTypeIdsStrList = new List<String>();
        for (Id rtId : recordTypeIds) {
            recordTypeIdsStrList.add('\'' + rtId + '\'');
        }
        String recordTypeIdsStr = String.join(recordTypeIdsStrList, ',');

        String query = 'SELECT CSBD_Now_NIF__c FROM Opportunity WHERE ' +
        ' AccountId = null AND CSBD_Contact__c = null AND IsClosed = false AND CSBD_Now_NIF__c != null ' +
        ' AND RecordTypeId IN (' + recordTypeIdsStr + ')';

        return Database.getQueryLocator(query);             
    }

    public void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        try{
            List<Contact> contactos = [SELECT AccountId, CC_Numero_Documento__c, Name, AV_NumPerso__c FROM Contact WHERE 
                                            (RecordType.DeveloperName = 'CC_Cliente' OR Account.RecordType.DeveloperName = 'CC_ClientePA') 
                                            AND CC_Numero_Documento__c IN :CC_MetodosUtiles.listaCampo(scope, 'CSBD_Now_NIF__c')
                                            AND AV_NumPerso__c != null];
                                        
            //Creamos un mapa donde la key es el NIF, y los valores son las listas de contactos con ese NIF
            Map<String, List<Contact>> contactosMap = new Map<String, List<Contact>>(); 
            for (Contact c: contactos) { 
                if(!contactosMap.containsKey(c.CC_Numero_Documento__c)) { 
                    contactosMap.put(c.CC_Numero_Documento__c, new List<Contact>()); 
                } 
                contactosMap.get(c.CC_Numero_Documento__c).add(c); 
            }

            //Por cada oportunidad se asigna el account y el contact solo si existe uno con ese NIF, además se crea la tarea de identificación cliente
            List<Task> tareas = new List<Task>();
            List<Opportunity> oportunidades = new List<Opportunity>();

            for(Opportunity opp: scope){
                if(contactosMap.containsKey(opp.CSBD_Now_NIF__c)) {
                    //Ahora contactos es una lista de los contactos con el nif de la oportunidad, no el resultado de la query anterior
                    contactos = contactosMap.get(opp.CSBD_Now_NIF__c);

                    if(contactos != null && contactos.size() == 1){
                        opp.AccountId = contactos[0].AccountId;
                        opp.CSBD_Contact__c = contactos[0].Id;

                        oportunidades.add(opp);
                        tareas.add(CSBD_Activity.crearActividadReturn(new Task(), opp.Id, 'Identificación del cliente', 'Completed', 'Identificación automática del cliente', 'Identificación automática del cliente ' + contactos[0].Name + ' - ' + contactos[0].AV_NumPerso__c, null));
                    }
                }
            }

            if(!oportunidades.isEmpty()){
                CSBD_Bypass_Trigger.bypass('CC_Opportunity_AU_TRHan'); //Omite lógica del trigger AU
                update oportunidades;

                insert tareas;
            }
        }catch(Exception e){
            CBK_Log.error(e);
        } finally {
            CSBD_Bypass_Trigger.undoBypass('CC_Opportunity_AU_TRHan');
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        // Método opcional que se ejecuta después de que el proceso de lotes ha terminado
        CBK_Log.debug('Fin batch identificar cliente CSBD',logginglevel.INFO);
    }
}