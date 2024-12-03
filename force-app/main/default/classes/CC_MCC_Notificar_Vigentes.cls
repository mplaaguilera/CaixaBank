public with sharing class CC_MCC_Notificar_Vigentes {
        private static Id motivoRecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();

    @AuraEnabled(cacheable=true)
    public static List<CC_MCC__c> obtenerMotivos() {
        /*  Obtenemos todos los registros de MCC de tipo Motivo con el checkbox de Notificar marcado
            que tienen una fecha de vigencia de inicio entre siete días antes de la fecha actual y siete
            días después de la fecha actual
        */
        List<CC_MCC__c> mccVigentesNotificar = [
            SELECT CC_Tematica_Formula__c,CC_Producto_Servicio_Formula__c,Name,CC_Fecha_Inicio_Vigencia_Max__c,CC_Detalle__c
            FROM CC_MCC__c 
            WHERE RecordTypeId = :motivoRecordTypeId
            AND(
                CC_Tipo_Cliente__c = 'Cliente'
                OR
                CC_Tipo_Cliente__c = 'Empleado'
            ) 
            AND (
                CC_Notificar__c= true 
                OR 
                CC_Producto_Servicio__r.CC_Notificar__c = true 
                OR 
                CC_Producto_Servicio__r.CC_Tematica__r.CC_Notificar__c = true
            ) 
            AND (
                CC_Fecha_Inicio_Vigencia_Max__c = NEXT_N_DAYS:7 
                OR 
                CC_Fecha_Inicio_Vigencia_Max__c = LAST_N_DAYS:7
            )
            ORDER BY CC_Fecha_Inicio_Vigencia_Max__c ASC
        ];

        return mccVigentesNotificar;
    }
}