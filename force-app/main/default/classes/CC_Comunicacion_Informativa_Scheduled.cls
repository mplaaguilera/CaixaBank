global class CC_Comunicacion_Informativa_Scheduled implements Schedulable {
    
    global void execute(SchedulableContext sc) {
		cerrarComunicacionesInformativas();
    }
    
    public void cerrarComunicacionesInformativas() {
        Id comunicacionInformativaRecordTypeId = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Comunicacion_Informativa').getRecordTypeId();
        Id comunicacionInformativaCampanaRecordTypeId = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Comunicacion_Informativa_de_Campana').getRecordTypeId();
        Id comunicacionInformativaMarcaRecordTypeId = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Comunicacion_Informativa_de_Marca').getRecordTypeId();
        List<CC_Agrupador__c> comunicacionesInformativas = new List<CC_Agrupador__c>();
        for (CC_Agrupador__c comunicacionInformativa : [SELECT CC_Estado__c FROM CC_Agrupador__c WHERE (RecordTypeId = :comunicacionInformativaRecordTypeId OR RecordTypeId = :comunicacionInformativaCampanaRecordTypeId OR RecordTypeId = :comunicacionInformativaMarcaRecordTypeId) AND CC_Estado__c = 'Activo' AND CreatedDate < TODAY]) {
            comunicacionInformativa.CC_Estado__c = 'Cerrado';
            comunicacionInformativa.CC_Fecha_Cierre__c = Datetime.now();
            comunicacionesInformativas.add(comunicacionInformativa);
        }
        update comunicacionesInformativas;
    }
    
    public static String horario = '0 45 23 ? * *';  // Cada día a las 23:45
    global static String planificar() {
        String jobName = 'CC_Comunicacion_Informativa_Scheduled - Cada día a las 23:45';
        if (Test.isRunningTest()) {
            jobName = 'CC_Comunicacion_Informativa_Scheduled - Test';
        }
        CC_Comunicacion_Informativa_Scheduled sch = new CC_Comunicacion_Informativa_Scheduled(); 
        return System.schedule(jobName, horario, sch);
    }
}