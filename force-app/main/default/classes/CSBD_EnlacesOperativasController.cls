public with sharing class CSBD_EnlacesOperativasController {

    @AuraEnabled
    public static SObject getRegistroRelacionado(Id recordId, String campoLookup, String nombreObjeto) {
        String query = 'SELECT Id, ' + String.escapeSingleQuotes(campoLookup) + ' FROM ' + String.escapeSingleQuotes(nombreObjeto) + ' WHERE Id = \'' + String.escapeSingleQuotes(recordId) + '\' LIMIT 1';
        SObject result = Database.query(query);
        return result;
    }

}