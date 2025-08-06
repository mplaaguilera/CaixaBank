public with sharing class CSBD_EnlacesOperativasController {

    @AuraEnabled
    public static SObject getRegistroRelacionado(Id recordId, String campoLookup, String nombreObjeto) {
        String query = 'SELECT Id, ' + String.escapeSingleQuotes(campoLookup) + ' FROM ' + String.escapeSingleQuotes(nombreObjeto) + ' WHERE Id = \'' + String.escapeSingleQuotes(recordId) + '\' LIMIT 1';
        SObject result = Database.query(query);
        return result;
    }

    @AuraEnabled
    public static Opportunity informarSLA(Id oportunidadId) {
        try {
            Opportunity opp = [SELECT Id, CreatedDate, RecordType.DeveloperName, CSBD_Horario_Contacto__c, CSBD_PrimerContactoSLA__c, CSBD_SLA_Primera_Respuesta__c
                               FROM Opportunity WHERE Id = :oportunidadId LIMIT 1];
                               
            Opportunity oppResult = CSBD_Llamada_GC.informarSla(null, opp);
            update oppResult;
            return oppResult;
        } catch (Exception error) {
            throw new AuraHandledException(error.getMessage());
        }
    }
}