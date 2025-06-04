public with sharing class CSBD_MacRelatedListApex {

    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOtrasLlamadas(String telefono) {
        if (String.isBlank(telefono)) {
            return new List<Opportunity>();
        }

        return [SELECT OwnerId, Owner.Name, CSBD_Identificador__c, CSBD_Estado__c, CreatedDate
                FROM Opportunity WHERE RecordType.DeveloperName = 'CSBD_MAC' AND IsClosed = FALSE
                AND CSBD_Telefono_Solicitud_Normalizado__c = :CSBD_Utils.normalizarNumeroTelefono(telefono)
                AND CSBD_Now_Origen__c != 'Asistencia Comercial Centralita'
                ORDER BY CreatedDate DESC LIMIT 14];
    }

    @AuraEnabled
    public static void crearTareaVinculacion(Id recordId, String identificadorParent) {
        String tipo = 'Vinculación a oportunidad padre';
        CSBD_Activity.crearActividad(recordId, tipo, 'Completed', tipo + ' ' + identificadorParent, null);
    }
}