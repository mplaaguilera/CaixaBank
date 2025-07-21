public with sharing class CSBD_MacRelatedListApex {

    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOtrasLlamadas(String telefono) {
        if (String.isBlank(telefono)) {
            return new List<Opportunity>();
        }

        return [SELECT OwnerId, Owner.Name, CSBD_Identificador__c, CSBD_Producto__c, CreatedDate
                FROM Opportunity WHERE IsClosed = FALSE AND RecordType.DeveloperName LIKE 'CSBD_%'
                AND CSBD_Telefono_Solicitud_Normalizado__c = :CSBD_Utils.normalizarNumeroTelefono(telefono)
                AND CSBD_Now_Origen__c != 'Asistencia Comercial Centralita'
                AND LastModifiedDate  = LAST_N_DAYS:21
                ORDER BY CreatedDate DESC LIMIT 14];
    }

    @AuraEnabled
    public static void crearTareaVinculacion(Id recordId, String identificadorParent) {

        String tipo = 'Vinculación a oportunidad padre';
        CSBD_Activity.crearActividad(recordId, tipo, 'Completed', tipo + ' ' + identificadorParent, null);

        CSBD_Opportunity.cerrarOportunidad(recordId, 'Perdida', 'Con oportunidad en curso');
    }
}