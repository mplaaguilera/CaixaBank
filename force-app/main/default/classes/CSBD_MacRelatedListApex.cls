public with sharing class CSBD_MacRelatedListApex {

    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOtrasLlamadas(String telefono) {
        if (String.isBlank(telefono)) {
            return new List<Opportunity>();
        }

        Map<String, SObject> numDias = CSBD_Utils.mapaCampo([SELECT Name, CC_Valor__c FROM CC_Lista_Valores__c
                                                            WHERE RecordType.DeveloperName = 'CC_Valor' AND CC_Activa__c = TRUE
                                                            AND CC_Lista__r.Name = 'CSBD: Configuración de rellamadas'
                                                            AND Name LIKE 'Permitir vincular a llamadas % días' LIMIT 2], 'Name');

        Integer numDiasAbiertas = Integer.valueOf(numDias.get('Permitir vincular a llamadas abiertas con antigüedad de hasta N días').get('CC_Valor__c'));
        Integer numDiasCerradas = Integer.valueOf(numDias.get('Permitir vincular a llamadas cerradas con antigüedad de hasta N días').get('CC_Valor__c'));

        if (numDiasAbiertas == null || numDiasAbiertas < 1) {
            numDiasAbiertas = 21;
        }
        if (numDiasCerradas == null || numDiasCerradas < 1) {
            numDiasCerradas = 2;
        }

        DateTime fechaInicioAbiertas = DateTime.now().addDays(-numDiasAbiertas);
        DateTime fechaInicioCerradas = DateTime.now().addDays(-numDiasCerradas);

        List<Id> idsRecordTypes = CSBD_Utils.listaCampo(
            [SELECT Id FROM RecordType WHERE DeveloperName LIKE 'CSBD_%' AND SObjectType = 'Opportunity'], 'Id'
        );

        List<Opportunity> oportunidades = [SELECT OwnerId, Owner.Name, CSBD_Identificador__c, CSBD_Producto__c,
                                            CreatedDate, LastModifiedDate, IsClosed, CSBD_Estado__c, CSBD_Parent_Id__c
                FROM Opportunity WHERE RecordTypeId IN :idsRecordTypes
                AND CSBD_Telefono_Solicitud_Normalizado__c = :CSBD_Utils.normalizarNumeroTelefono(telefono)
                AND CSBD_Now_Origen__c != 'Asistencia Comercial Centralita'
                AND LastModifiedDate >= :fechaInicioAbiertas
                ORDER BY LastModifiedDate DESC LIMIT 14];

        // Filtrar les oportunitats tancades que són més antigues que fechaInicioCerradas
        List<Opportunity> oportunidadesFiltradas = new List<Opportunity>();
        for (Opportunity opp : oportunidades) {
            if (!opp.IsClosed || (opp.IsClosed && opp.LastModifiedDate >= fechaInicioCerradas)) {
                oportunidadesFiltradas.add(opp);
            }
        }

        return oportunidadesFiltradas;
    }

    @AuraEnabled
    public static void crearTareaVinculacion(Id recordId, String identificadorParent) {
        String tipo = 'Vinculación a oportunidad padre';
        CSBD_Activity.crearActividad(recordId, tipo, 'Completed', tipo + ' ' + identificadorParent, null);

        CSBD_Opportunity.cerrarOportunidad(recordId, 'Perdida', 'Con oportunidad en curso');
    }
}