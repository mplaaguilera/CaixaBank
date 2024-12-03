public without sharing class OT_Proyectos {

    public static String registroProyecto(Id recordId) {

        String retorno = null;
        List<sObject> registros = Database.query('SELECT RecordTypeId FROM ' + String.valueOf(recordId.getSobjectType()) + ' WHERE Id = \'' + recordId + '\'');

        if (!registros.isEmpty()) {
            retorno = [SELECT DeveloperName FROM RecordType WHERE Id = :(Id)registros[0].get('RecordTypeId')].DeveloperName.substringBefore('_');
        }

        return retorno;
    }
    
    public static Id getRecordTypeIdFromObjectId(Id objectId) {
        List<sObject> registros = Database.query('SELECT RecordTypeId FROM ' + String.valueOf(objectId.getSobjectType()) + ' WHERE Id = \'' + objectId + '\'');
        return (Id)registros[0].get('RecordTypeId');
    }
}