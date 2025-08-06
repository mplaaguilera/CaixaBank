public with sharing class HDT_Asociar_Casos_Masivas {

    @AuraEnabled(cacheable=true)
    public static List<Case> buscarCasos(String cadenaBusqueda) {
        return [SELECT CaseNumber, Subject, CreatedDate, CC_MCC_Tematica__r.Name, Status
                FROM Case WHERE CaseNumber LIKE :(cadenaBusqueda + '%') AND Status = 'Activo'
                AND RecordType.DeveloperName = 'HDT_Empleado'
                ORDER BY CreatedDate DESC LIMIT 10];
    }

    @AuraEnabled
    public static void vincularCasos(Id idAgrupador, List<Id> idCasos) {
        List<Case> casosUpdate = new List<Case>();
        try {
            for (Id idCaso : idCasos) {
                Case caso = new Case(Id = idCaso);
                caso.CC_Agrupador_Id__c = idAgrupador;
                caso.Status = 'Pendiente Incidencia';
                casosUpdate.add(caso);
            }
            Database.update(casosUpdate, true);

        } catch (Exception e) {
            CBK_Log.error(e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Integer numeroMaximoCasosAsociados() {
        List<HDT_Parametros__c> parametro =  [SELECT HDT_Configuracion_1__c FROM HDT_Parametros__c WHERE Name = 'HDT_Casos_Asociados_Maximo'];
        return Integer.valueOf(parametro[0].HDT_Configuracion_1__c);
    }
}