public with sharing class CSBD_CMN {

    public static void rechazarOportunidadesRobotPortal(List<Id> idOportunidades) {
        List<Opportunity> oportunidades = [SELECT CSBD_Now_Codigo_Producto__c, RecordTypeId
                                            FROM Opportunity WHERE Id IN :idOportunidades];

        List<Opportunity> oportunidadesCmn = new List<Opportunity>();
        for (Opportunity oportunidadCmn : descartarNoCmn(oportunidades)) {
            oportunidadesCmn.add(oportunidadCmn);
        }

        for (Opportunity oportunidadCmn : oportunidadesCmn) {
            if (oportunidadCmn.CSBD_Now_Codigo_Producto__c == 'PRUEBA') {
                CSBD_Opportunity.cerrarOportunidad(oportunidadCmn.Id, 'Rechazada', 'Robot Portal');
            }
        }
    }

    private static List<Opportunity> descartarNoCmn(List<Opportunity> oportunidades) {
        Id idRecordTypeHipoteca = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Opportunity', 'CSBD_CMN');
        List<Opportunity> retorno = new List<Opportunity>();
        for (Opportunity oportunidad : oportunidades) {
            if (oportunidad.RecordTypeId == idRecordTypeHipoteca) {
                retorno.add(oportunidad);
            }
        }
        return retorno;
    }
}