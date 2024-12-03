public with sharing class AM_Case_RelacionarParentCase_Controller {
    @AuraEnabled
    public static void relacionarConParentCaseController(Id childCaseId, Id recordId){
        Case caso = [SELECT Id, ParentId FROM Case WHERE Id = :childCaseId];
        caso.ParentId = recordId;
        update caso;
    }

    @AuraEnabled
    public static List<String> validarCampos(Id casoId, Id casoPadreId){
        Case casoHijo = [SELECT Id, CC_Detalles_Consulta__c, CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c,
        CC_MCC_Tematica__r.CC_Activo__c, CC_MCC_ProdServ__r.CC_Activo__c, CC_MCC_Motivo__r.CC_Activo__c,
        Origin, CC_Canal_Procedencia__c, CC_Idioma__c, CC_Tipo_Contacto__c, ContactId, Status FROM Case WHERE Id = :casoId];

        Case casoPadre = [SELECT Id, Status FROM Case WHERE Id = :casoPadreId];

        List<String> camposNoValidos = new List<String>();

        if (casoPadre.Status == 'Cerrado'){
            camposNoValidos.add('Agrupador Cerrado');
            return camposNoValidos;
        }
        if (casoHijo.CC_MCC_Tematica__c == null) {
            camposNoValidos.add('Temática');
        }
        if (casoHijo.CC_MCC_ProdServ__c == null) {
            camposNoValidos.add('Producto/Servicio');
        }
        if (casoHijo.CC_MCC_Motivo__c == null ) {
            camposNoValidos.add('Motivo');
        }
        if (casoHijo.Origin == null) {
            camposNoValidos.add('Canal de entrada');
        }
        if (casoHijo.CC_Canal_Procedencia__c == null) {
            camposNoValidos.add('Canal de procedencia');
        }
        if (casoHijo.CC_Idioma__c == null) {
            camposNoValidos.add('Idioma');
        }
        if (casoHijo.CC_Tipo_Contacto__c == null) {
            camposNoValidos.add('Tipo de contacto');
        }
        if (casoHijo.CC_Detalles_Consulta__c == null && (casoHijo.CC_Canal_Procedencia__c <> 'Buzón Carteras' && casoHijo.CC_Canal_Procedencia__c <> 'Buzón Fondos') ) {
            camposNoValidos.add('Detalles Consulta');
        }
        if (casoHijo.ContactId == null) {
            camposNoValidos.add('Cuenta y Contacto');
        }
        if (casoHijo.Status != 'Activo') {
            camposNoValidos.add('Estado Activo');
        }

        //Si las claves foráneas a MCCs no son nulas, se mira además que los MCCs a los que apuntan estén activos
        if (casoHijo.CC_MCC_Tematica__c != null && casoHijo.CC_MCC_ProdServ__c != null && casoHijo.CC_MCC_Motivo__c != null) {
            //Se preparan los Ids en una lista para poder la comprobación en una sola consulta
            List<Id> idsMCC = new List<Id>{casoHijo.CC_MCC_Tematica__c, casoHijo.CC_MCC_ProdServ__c, casoHijo.CC_MCC_Motivo__c};
            List<CC_MCC__c> mccs = [SELECT CC_Activo__c, RecordType.DeveloperName FROM CC_MCC__c WHERE Id IN :idsMCC];

            for (CC_MCC__c mcc : mccs) {
                if (!mcc.CC_Activo__c) {
                    camposNoValidos.add('Clasificación inactiva');
                    break;
                }
            }
        }
        return camposNoValidos;
    }
}