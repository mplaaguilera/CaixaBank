public with sharing class CSBD_AvisosOportunidadesUtility_Apex {

    @AuraEnabled
    public static Integer getFrecuenciaAvisosAuto() { //en minutos (0 o null: sin avisos automáticos)
        return Integer.valueOf(CSBD_IdentificarOppsPHDSetting__c.getInstance().CSBD_FrecuenciaAvisosAuto__c);
    }

    @AuraEnabled
    public static List<Opportunity> getNuevasSolicitudesPhd() {
        return [SELECT CSBD_Identificador__c, CSBD_OrigenLeadExistente__c,
                CSBD_FechaEntradaUltimoLead__c, Account.Name FROM Opportunity
                WHERE RecordType.DeveloperName LIKE 'CSBD_%'
                AND CSBD_FechaEntradaUltimoLead__c != NULL  AND CSBD_MostrarAviso__c = 'Nueva búsqueda en facilitea casa'
                AND CSBD_Now_Origen__c = 'faciliteacasa'
                AND OwnerId = :UserInfo.getUserId() ORDER BY CreatedDate ASC LIMIT 100];
    }
}