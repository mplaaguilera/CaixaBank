public with sharing class CC_Marcar_Casos_KPI_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts {
//Id batchJobId = Database.executeBatch(new CC_Marcar_Casos_KPI_Batch(), 200);
     public CC_Marcar_Casos_KPI_Batch() {
        CBK_Log.debug('Inicia - CC_Marcar_Casos_KPI_Batch',logginglevel.INFO);

    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = '';
         if (Test.isRunningTest()){
            query = 'SELECT CaseNumber, AccountId, CC_Detalles_Consulta__c, CC_Detalles_Solucion__c, Origin, CC_MCC_Tematica__c,  CC_MCC_Tematica__r.Name,CC_MCC_Motivo__r.CC_Excluir_Registro__c, RecordTypeId, Status, CC_NumeroCasoOrigenRep__c, CC_OTP_Valido__c, CC_OTP_Nivel__c, CC_MCC_Solucion__r.Name,CC_MCC_Solucion__r.CC_Agrupacion_Solucion__c, CC_Motivo_Derivacion__c, CC_Status_Autorizacion__c,CC_MCC_Tematica__r.CC_Excluir_Registro__c, CC_Repetitivo__c FROM Case WHERE RecordType.DeveloperName = \'CC_Cliente\' AND Status != \'Rechazado\' AND CreatedDate = TODAY order by AccountId asc';
         } else {
            query = 'SELECT CaseNumber, AccountId, CC_Detalles_Consulta__c, CC_Detalles_Solucion__c, Origin, CC_MCC_Tematica__c,  CC_MCC_Tematica__r.Name,CC_MCC_Motivo__r.CC_Excluir_Registro__c, RecordTypeId, Status, CC_NumeroCasoOrigenRep__c, CC_OTP_Valido__c, CC_OTP_Nivel__c, CC_MCC_Solucion__r.Name,CC_MCC_Solucion__r.CC_Agrupacion_Solucion__c, CC_Motivo_Derivacion__c, CC_Status_Autorizacion__c,CC_MCC_Tematica__r.CC_Excluir_Registro__c, CC_Repetitivo__c FROM Case WHERE RecordType.DeveloperName = \'CC_Cliente\' AND Status != \'Rechazado\' AND CreatedDate = YESTERDAY order by AccountId asc';
         }
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Case> scope) {

        List<Case> casosUpdate = new List<Case>();

        //List<Case> derivacionOficina = CC_Marcar_Casos_KPI.calcularDerivacionOficina(scope);
        List<Case> repetitividad = CC_Marcar_Casos_KPI.calcularRepetitividad(scope);

        casosUpdate.addAll(repetitividad);
        //casosUpdate.addAll(derivacionOficina);

        casosUpdate = new List<Case>(new Set<Case>(casosUpdate));

        if (!casosUpdate.isEmpty()){
            Database.update(casosUpdate, false);
        }

    }

    public void finish(Database.BatchableContext bc) {
        CBK_Log.debug('Finalización - CC_Marcar_Casos_KPI_Batch',logginglevel.INFO);
        // Lanzamos un nuevo batch para contar los casos.
        if (Test.isRunningTest()){
            system.debug('Hola Test');
        }else{
            CC_Contar_Casos_KPI_Batch batch = new CC_Contar_Casos_KPI_Batch();      
           Database.executeBatch(batch,200);
        }

    }
}