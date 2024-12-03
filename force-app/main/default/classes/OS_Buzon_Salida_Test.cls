@isTest
public with sharing class OS_Buzon_Salida_Test {

    @isTest
    public static void OS_BuzonSalidaTest() {
        User usuarioOperador = OS_Usuarios.usuarioOperador();

        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();

        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.RecordTypeId = recordTypeCaso;
        caso.Subject = 'Prueba cambiar cola Procedencia';
        caso.Status = 'Activo';
        caso.Origin = 'Email'; 
        caso.CC_Canal_Procedencia__c = 'Buzón Comercio Exterior';
        caso.CC_Canal_Resolucion__c = 'Buzón Comercio Exterior';
        caso.CC_Tipo_Contacto__c = 'Asesoramiento';
        insert caso;

        CaseShare csNuevo = new CaseShare();
        csNuevo.CaseId = caso.Id;
        csNuevo.UserOrGroupId = usuarioOperador.Id;
        csNuevo.CaseAccessLevel='Edit';
        insert csNuevo;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        insert contacto;

        System.runAs (usuarioOperador) {
            Test.startTest();
            OS_Buzon_Salida.actualizarBuzonSalida(new List<Id>{caso.Id});
            Test.stopTest();

            Case updatedCase = [SELECT Id,CC_Buzon_Salida__c FROM Case Where Id =:caso.id LIMIT 1];

            System.assertNotEquals(caso.CC_Buzon_Salida__c,updatedCase.id, 'Comprobamos el buzón de salida.');
        }
    }
}