public with sharing class CSBD_MacRelatedListApex {

    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOtrasLlamadas(String telefono) {
        if (String.isBlank(telefono)) {
            return new List<Opportunity>();
        }

        List<RecordType> recordTypes = [SELECT Id FROM RecordType
                                        WHERE DeveloperName LIKE 'CSBD_%' AND SObjectType = 'Opportunity'];

        return [SELECT OwnerId, Owner.Name, CSBD_Identificador__c, CSBD_Producto__c, CreatedDate
                FROM Opportunity
                WHERE RecordTypeId IN :CSBD_Utils.listaCampo(recordTypes, 'Id')
                AND CSBD_Telefono_Solicitud_Normalizado__c = :CSBD_Utils.normalizarNumeroTelefono(telefono)
                AND CSBD_Now_Origen__c != 'Asistencia Comercial Centralita'
                AND ((IsClosed = FALSE AND LastModifiedDate = LAST_N_DAYS:1) OR (IsClosed = TRUE AND LastModifiedDate = LAST_N_DAYS:2))
                ORDER BY CreatedDate DESC LIMIT 14];
    }

    @AuraEnabled
    public static void crearTareaVinculacion(Id recordId, String identificadorParent) {
        String tipo = 'Vinculación a oportunidad padre';
        CSBD_Activity.crearActividad(recordId, tipo, 'Completed', tipo + ' ' + identificadorParent, null);

        CSBD_Opportunity.cerrarOportunidad(recordId, 'Perdida', 'Con oportunidad en curso');
    }
}