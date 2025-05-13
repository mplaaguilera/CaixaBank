@isTest
public class CC_CaseExtensionController_Test {
@TestSetup
    static void makeData() {
        User usuarioAdmin = CC_TestDataFactory.insertUserAdmin();

        System.runAs(usuarioAdmin) {
            User operador = CC_TestDataFactory.insertUserOperadorCliente('00000');

            Case caso = new Case();
            caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            caso.Origin = 'Email';
            caso.Status = 'Activo';
            caso.CC_Idioma__c = 'es';
            caso.CC_Canal_Respuesta__c = 'Email';
            caso.OwnerId = operador.Id;
            caso.CC_Canal_Procedencia__c = 'Formulario web';
            caso.Subject = 'Caso';
            insert caso;

            CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c();
            caseExtension.Case_Id__c = caso.Id;
            insert caseExtension;
            
        }
    }

    @isTest
    public static void getCaseExtensionId() {
        user operador = CC_TestDataFactory.getUserOperadorCliente();
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso' LIMIT 1];
        System.runAs(operador) {
            Id resultado = CC_CaseExtensionController.getCaseExtensionId(caso.Id);
            System.assertNotEquals(resultado, null, 'No se ha creado correctamente el case extension');
        }
    }
}