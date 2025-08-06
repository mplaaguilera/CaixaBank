@isTest
public class OS_Event_AU_Test {
    @TestSetup
    static void cargaDeDatos() {
        User usuarioOperador = OS_Usuarios.usuarioOperador();

        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        caso.Subject = 'Prueba Alerta';
        caso.Status = 'Pendiente Alerta';
        caso.Origin = 'Phone';
        caso.CC_Canal_Procedencia__c = 'Teléfono COPS atención clientes';
        caso.CC_Canal_Resolucion__c = 'Teléfono COPS atención clientes';
        caso.CC_Tipo_Contacto__c = 'Asesoramiento';
        caso.OS_Alerta_Fecha__c = System.now();
        insert caso;

        CaseShare csNuevo = new CaseShare();
        csNuevo.CaseId = caso.Id;
        csNuevo.UserOrGroupId = usuarioOperador.Id;
        csNuevo.CaseAccessLevel='Edit';
        insert csNuevo;

        Event evento = new Event();
        evento.WhatId = caso.Id;
        evento.StartDateTime = caso.OS_Alerta_Fecha__c;
        evento.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Event', 'OS_Alerta');
        evento.Type = 'Alerta programada';
        evento.Subject = 'Alerta programada Oliver';
        evento.EndDateTime = caso.OS_Alerta_Fecha__c;
        evento.OS_Alerta_Vencida__c = false;
        insert evento;
    }

    @isTest
    public static void alertaVencida() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Event evento = [SELECT Id, OS_Alerta_Vencida__c FROM Event WHERE Subject = 'Alerta programada Oliver'];

        System.runAs (usuarioOperador) {       
            Test.startTest();
            evento.OwnerId = usuarioOperador.Id;
            evento.OS_Alerta_Vencida__c = true;
            update evento;
            Test.stopTest();

            Event elEventoCreado = [SELECT OS_Alerta_Vencida__c, OS_CaseNumber__c, WhatId FROM Event WHERE Id = :evento.Id];

            System.assertEquals(true, elEventoCreado.OS_Alerta_Vencida__c);
        }
    }
}