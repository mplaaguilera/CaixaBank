@isTest
public with sharing class CC_Llamada_Casos_Controller_Test {
    @isTest
    public static void testSetup() {

        Id recordTypeCasoCliente = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('SACH_Cliente').getRecordTypeId();

        Case caso = new Case();
        caso.Subject = 'Caso de prueba mcc';
        caso.recordtypeId= recordTypeCasoCliente;
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'SACH';
        caso.CC_Tipo_Contacto__c = 'Consulta de Cliente';
        caso.Status = 'Activo';
        insert caso;

        CC_Llamada_Input input = new CC_Llamada_Input();
        input.usuario = '1218';
        input.extension = '1118';
        input.connId = '12345678';
        input.ani = '666666666';
        input.dnis = '666666666';
        input.servicio = 'SACH_PRUEBAS';
        input.asunto = 'Asunto llamada';
        input.numPerso = '432423';
        input.idioma = 'Castellano';
        input.datos = 'Datos';
        input.casoId = caso.Id;

        CC_Llamada__c llamadaSaliente = SACH_Llamada.registrarLlamadaSaliente(input);

        Task actividad = new Task();

        actividad.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'SACH_Task');
        actividad.CC_Llamada_Id__c = llamadaSaliente.Id;
        actividad.Status = 'Open';

        insert actividad;

        Test.startTest();

        List<Case> casos = CC_Llamada_Casos_Controller.getCasos(llamadaSaliente.Id);
        Test.stopTest();
         System.assertEquals(1, casos.size());
    }
}