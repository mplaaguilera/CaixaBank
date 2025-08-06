public with sharing class CC_Gestion_Derivar_CashBack {
    @AuraEnabled
    public static void actualizarDatosCashBack(Id recordId, String detallesConsulta, String idCliente, String nombreComercio, Date fechaCompra) {
        Case caso = [SELECT Id, CBK_Case_Extension_Id__c, CC_Detalles_Consulta__c FROM Case WHERE Id = :recordId LIMIT 1];
        caso.CC_Detalles_Consulta__c = detallesConsulta;
        if (caso.CBK_Case_Extension_Id__c != null) {
            CBK_Case_Extension__c caseExtension = [SELECT Id, CC_ID_cliente__c, CC_Nombre_Comercio__c, CC_Fecha_De_Compra__c FROM CBK_Case_Extension__c WHERE Id = :caso.CBK_Case_Extension_Id__c];
            caseExtension.CC_ID_cliente__c = idCliente;
            caseExtension.CC_Nombre_Comercio__c = nombreComercio;
            caseExtension.CC_Fecha_De_Compra__c = fechaCompra;
            update caseExtension;
        } else {
            CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c(
                Case_Id__c = caso.Id,
                CC_ID_cliente__c = idCliente,
                CC_Nombre_Comercio__c = nombreComercio,
                CC_Fecha_De_Compra__c = fechaCompra
            );
            insert caseExtension;
            caso.CBK_Case_Extension_Id__c = caseExtension.Id;
        }
        update caso;
    }
}