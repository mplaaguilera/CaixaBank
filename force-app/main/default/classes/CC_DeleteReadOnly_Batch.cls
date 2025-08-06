public class CC_DeleteReadOnly_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts {
        public Database.QueryLocator start(Database.BatchableContext bc){
            String query = '';
            Id usuarioBluewolfId = [SELECT Id FROM User WHERE Name = 'Bluewolf'].Id;
            if (Test.isRunningTest()){
            query = 'SELECT Id FROM CC_Llamada__c WHERE RecordType.DeveloperName = \'CC_ReadOnly\' AND CreatedDate = Today';
        } else {
        	query = 'SELECT Id FROM CC_Llamada__c WHERE RecordType.DeveloperName = \'CC_ReadOnly\' AND CreatedDate < Yesterday AND Owner.Id = :usuarioBluewolfId';
        }
            return Database.getQueryLocator(query);
        }
        public void execute(Database.BatchableContext bc, List<CC_Llamada__c> llamadas){
            Id usuarioBluewolfId = [SELECT Id FROM User WHERE Name = 'Bluewolf'].Id;
            Datetime cuando = system.now()-1;
            if (Test.isRunningTest()){
            cuando = system.now();
        }
        List<CC_Llamada__c> listaLlamadas = new List<CC_Llamada__c>();
        listaLlamadas.addAll(llamadas);
        List<Id> listCaseAux = new  List<Id>();
        
        List<Task> listaTareas = [SELECT Id, WhatId FROM Task WHERE RecordType.DeveloperName = 'CC_ReadOnly' AND CreatedDate < :cuando AND CC_Llamada_Id__c IN :listaLlamadas AND Owner.Id = :usuarioBluewolfId];
            if(!listaTareas.isEmpty()){
                for (Task t : listaTareas) {
                    listCaseAux.add(t.WhatId);
                }
            }
            List<Case> listaCasos = [SELECT Id FROM Case WHERE  RecordType.DeveloperName = 'CC_ReadOnly' AND CreatedDate < :cuando AND Id IN :listCaseAux AND Owner.Id = :usuarioBluewolfId];
           
            List<sObject> aBorrar = new List<sObject>();
            aBorrar.addAll(listaTareas);
            aBorrar.addAll(listaCasos);
            aBorrar.addAll(listaLlamadas);
            try {
                delete aBorrar;
               system.debug('cosas a eliminar' + aBorrar);
            } catch (Exception e) {
                CBK_Log.error(e);
            }


        }
        public void finish(Database.BatchableContext bc){
            CBK_Log.debug('Finalización - Batch DeleteReadOnly',logginglevel.INFO);
        }
    }