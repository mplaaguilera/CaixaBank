public with sharing class CSBD_Opportunity_Crear_Controller {

    @AuraEnabled(cacheable=true)
    public static List<OT_Picklist.Item> getRecordTypesCSBD() {
        List<SObject> resultadosConsulta = Database.query('SELECT Name FROM RecordType WHERE SObjectType = \'Opportunity\' AND RecordType.DeveloperName LIKE \'CSBD_%\' AND RecordType.DeveloperName != \'CSBD_Compra_Estrella\'');
        return OT_Picklist.picklistSoql(resultadosConsulta, 'Id', 'Name');
    }

    @AuraEnabled(cacheable=true)
    public static Integer diasFechaCierre(String recordTypeName) {
        return CSBD_Opportunity.diasFechaCierre(recordTypeName);
    }

    @AuraEnabled
    public static void crearActividad(Id idOportunidad) {
        try {
            CSBD_Activity.crearActividad(idOportunidad, 'Alta manual de oportunidad', 'Completed', 'Alta manual de oportunidad', null);
        } catch (Exception e) { throw new AuraHandledException(e.getMessage()); }
    }

    @AuraEnabled
    public static void altaOportunidadesHijas(Id idOportunidad) {
        try {
            List<Opportunity> oportunidadCreada = [SELECT Id FROM Opportunity WHERE Id =:idOportunidad AND Recordtype.Name = 'Hipoteca' LIMIT 1];
            if(!oportunidadCreada.isEmpty()) {
                CSBD_WS_AltaOportunidad_NowInSales.insertarOportunidadesHijas(new List<Id>{oportunidadCreada[0].Id});
            }
        } catch (Exception e) { throw new AuraHandledException(e.getMessage()); }
    }

}