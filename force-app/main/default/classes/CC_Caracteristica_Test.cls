@isTest
public with sharing class CC_Caracteristica_Test {

    @isTest
    private static void test() {
        Account cuenta = new Account();
		cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        cuenta.Name = 'Cuenta01';
        Account cuentaCentro = new Account();
        cuentaCentro.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        cuentaCentro.Name = 'Centro Caixabank 1';
        Account cuentaCliente = new Account();
        cuentaCliente.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        cuentaCliente.Name = 'Cliente 1';
		insert new List<Account>{cuenta, cuentaCentro, cuentaCliente};

        Contact contacto = new Contact();
        contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contacto.AccountId = cuenta.Id;
        contacto.FirstName = 'Contacto';
        contacto.LastName = '01';
        contacto.CC_NumPerso__c = '12345569';
        contacto.CC_Idioma__c = 'Es';
        insert contacto;

        Case caso = new Case();
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
		caso.ContactId = contacto.Id;
		caso.CC_Idioma__c = 'es';
        caso.Status = 'Cerrado';
        caso.CC_Canal_Contacto__c = 'Chat';
        caso.CC_Canal_Procedencia__c = 'Web';
        caso.Reason = 'Helpdesk';
        caso.Origin = 'Chat';
        Case casoCliente = new Case();
        casoCliente.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
		casoCliente.AccountId = cuentaCliente.Id;
		casoCliente.CC_Idioma__c = 'es';
        casoCliente.Status = 'Cerrado';
        casoCliente.CC_Canal_Contacto__c = 'Chat';
        casoCliente.CC_Canal_Procedencia__c = 'Web';
        casoCliente.Reason = 'Helpdesk';
        casoCliente.Origin = 'Chat';
        Case casoCentro = new Case();
        casoCentro.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
		casoCentro.AccountId = cuentaCentro.Id;
		casoCentro.CC_Idioma__c = 'es';
        casoCentro.Status = 'Cerrado';
        casoCentro.CC_Canal_Contacto__c = 'Chat';
        casoCentro.CC_Canal_Procedencia__c = 'Web';
        casoCentro.Reason = 'Helpdesk';
        casoCentro.Origin = 'Chat';
        insert new List<Case>{caso, casoCliente, casoCentro};

        Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', new Map<String, Object>{'AccountId' => cuenta.Id, 'CSBD_Contact__c' => contacto.Id});

        Id idRtCaracteristicaContacto = Schema.SObjectType.CC_Caracteristica__c.getRecordTypeInfosByDeveloperName().get('CC_Cliente_Contacto').getRecordTypeId();
        CC_Caracteristica__c caracteristica1 = new CC_Caracteristica__c();
        caracteristica1.RecordTypeId = idRtCaracteristicaContacto;
        caracteristica1.Name = 'Característica 1';
        caracteristica1.CC_Descripcion__c = 'Esta es la descripción de la primera característica y ocupa más de cincuenta caracteres.';
        caracteristica1.CC_Prioridad__c = '2 - Media';
        caracteristica1.CC_Avisar_agente__c = true;
        caracteristica1.CC_Fecha_vigencia_inicio__c = Date.today().addDays(-1);
        caracteristica1.OS_Negocio__c = 'CC';
        CC_Caracteristica__c caracteristica2 = new CC_Caracteristica__c();
        caracteristica2.RecordTypeId = idRtCaracteristicaContacto;
        caracteristica2.Name = 'Característica 2';
        caracteristica2.CC_Descripcion__c = 'Esta es la descripción de la segunda característica y ocupa más de cincuenta caracteres.';
        caracteristica2.CC_Prioridad__c = '1 - Alta';
        caracteristica2.CC_Avisar_agente__c = true;
        caracteristica2.CC_Fecha_vigencia_inicio__c = Date.today().addDays(-1);
        caracteristica2.OS_Negocio__c = 'CC';
        CC_Caracteristica__c caracteristica3 = new CC_Caracteristica__c();
        caracteristica3.RecordTypeId = idRtCaracteristicaContacto;
        caracteristica3.Name = 'Característica 3';
        caracteristica3.CC_Descripcion__c = 'Esta es la descripción de la tercera característica y ocupa más de cincuenta caracteres.';
        caracteristica3.CC_Prioridad__c = '3 - Baja';
        caracteristica3.CC_Avisar_agente__c = true;
        caracteristica3.CC_Fecha_vigencia_inicio__c = Date.today().addDays(-1);
        caracteristica3.OS_Negocio__c = 'CC';
        CC_Caracteristica__c caracteristica4 = new CC_Caracteristica__c();
        caracteristica4.RecordTypeId = idRtCaracteristicaContacto;
        caracteristica4.Name = 'Característica 4';
        caracteristica4.CC_Descripcion__c = 'Esta es la descripción de la cuarta característica y ocupa más de cincuenta caracteres.';
        caracteristica4.CC_Prioridad__c = '3 - Baja';
        caracteristica4.CC_Avisar_agente__c = false;
        caracteristica4.CC_Fecha_vigencia_inicio__c = Date.today().addDays(-1);
        caracteristica4.OS_Negocio__c = 'CC';
        CC_Caracteristica__c caracteristica5 = new CC_Caracteristica__c();
        caracteristica5.RecordTypeId = idRtCaracteristicaContacto;
        caracteristica5.Name = 'Característica 5';
        caracteristica5.CC_Descripcion__c = 'Esta es la descripción de la quinta característica y ocupa más de cincuenta caracteres.';
        caracteristica5.CC_Prioridad__c = '3 - Baja';
        caracteristica5.CC_Avisar_agente__c = true;
        caracteristica5.CC_Fecha_vigencia_inicio__c = Date.today().addDays(-1);
        caracteristica5.OS_Negocio__c = 'CC';
        insert new List<CC_Caracteristica__c>{caracteristica1, caracteristica2, caracteristica3, caracteristica4, caracteristica5};

		CC_Caracteristica_Detalle__c caracteristicaDetalle1 = new CC_Caracteristica_Detalle__c();
        caracteristicaDetalle1.CC_Caracteristica__c = caracteristica1.Id;
        caracteristicaDetalle1.CC_Cliente__c = contacto.Id;
		CC_Caracteristica_Detalle__c caracteristicaDetalle2 = new CC_Caracteristica_Detalle__c();
        caracteristicaDetalle2.CC_Caracteristica__c = caracteristica2.Id;
        caracteristicaDetalle2.CC_Cliente__c = contacto.Id;
		CC_Caracteristica_Detalle__c caracteristicaDetalle3 = new CC_Caracteristica_Detalle__c();
        caracteristicaDetalle3.CC_Caracteristica__c = caracteristica3.Id;
        caracteristicaDetalle3.CC_Cliente__c = contacto.Id;
		CC_Caracteristica_Detalle__c caracteristicaDetalle4 = new CC_Caracteristica_Detalle__c();
        caracteristicaDetalle4.CC_Caracteristica__c = caracteristica4.Id;
        caracteristicaDetalle4.CC_Cliente__c = contacto.Id;
		CC_Caracteristica_Detalle__c caracteristicaDetalle5 = new CC_Caracteristica_Detalle__c();
        caracteristicaDetalle5.CC_Caracteristica__c = caracteristica5.Id;
        caracteristicaDetalle5.CC_Cliente__c = contacto.Id;
        CC_Caracteristica_Detalle__c caracteristicaDetalleCuentaCentro = new CC_Caracteristica_Detalle__c();
        caracteristicaDetalleCuentaCentro.CC_Caracteristica__c = caracteristica4.Id;
        caracteristicaDetalleCuentaCentro.CC_Centro_CaixaBank__c = cuentaCentro.Id;
        CC_Caracteristica_Detalle__c caracteristicaDetalleCuentaCliente = new CC_Caracteristica_Detalle__c();
        caracteristicaDetalleCuentaCliente.CC_Caracteristica__c = caracteristica4.Id;
        caracteristicaDetalleCuentaCliente.CC_Cuenta__c = cuentaCliente.Id;
        insert new List<CC_Caracteristica_Detalle__c>{
            caracteristicaDetalle1, caracteristicaDetalle2, caracteristicaDetalle3, caracteristicaDetalle4,
            caracteristicaDetalle5, caracteristicaDetalleCuentaCentro, caracteristicaDetalleCuentaCliente
        };

        LiveChatVisitor chatVisitor = new LiveChatVisitor();
		insert chatVisitor;

        LiveChatTranscript chat = new LiveChatTranscript();
        chat.CaseId = caso.Id;
        chat.AccountId = cuenta.Id;
        chat.CC_Cerrado_TimeOut__c = false;
        chat.CC_Idioma__c = 'es';
        chat.CC_NumPerso__c = contacto.CC_NumPerso__c;
        chat.LiveChatVisitorId = chatVisitor.Id;
        insert chat;

        User admin = [SELECT Id FROM User WHERE LastName = 'Administrador de sistema' LIMIT 1];
        System.runAs(admin) {
            Test.startTest();
            List<CC_Caracteristica_Detalle__c> caracteristicasContacto1 = CC_Caracteristica.conseguirCaracteristica(contacto.Id);
            List<CC_Caracteristica_Detalle__c> caracteristicasContacto2 = CC_Caracteristica.conseguirCaracteristica(oportunidad.Id);
            List<CC_Caracteristica_Detalle__c> caracteristicasContacto3 = CC_Caracteristica.getCaracteristicasContacto(contacto.Id, 'CC_Cliente');
            List<String> avisosContactoChat = CC_Caracteristica.getAvisosCaracteristicas(chat.Id);
            List<CC_Caracteristica_Detalle__c> caracteristicasAvisoContacto = CC_Caracteristica.getCaracteristicasConAviso(chat.Id);
            CC_Caracteristica.RelacionarCaso(new List<Id>{caso.Id});
            List<CC_Caracteristica_Detalle__c> caracteristicasCuentaCentro = CC_Caracteristica.conseguirCaracteristicaCuenta(casoCentro.Id);
            List<CC_Caracteristica_Detalle__c> caracteristicasCuentaCliente = CC_Caracteristica.conseguirCaracteristicaCuenta(casoCliente.Id);
            Test.stopTest();

            System.assertEquals(5, caracteristicasContacto1.size(), 'El número retornado de características del contacto no coincide');
            System.assertEquals(5, caracteristicasContacto2.size(), 'El número retornado de características del contacto no coincide');
            System.assertEquals(caracteristica2.Id, caracteristicasContacto1[0].CC_Caracteristica__c, 'Las características retornadas no están ordenadas por prioridad');
            System.assertEquals(caracteristica1.Id, caracteristicasContacto1[1].CC_Caracteristica__c, 'Las características retornadas no están ordenadas por prioridad');
            System.assertEquals(5, caracteristicasContacto3.size(), 'El número retornado de características del contacto no coincide');
            System.assertEquals(caracteristica2.Id, caracteristicasContacto3[0].CC_Caracteristica__c, 'Las características retornadas no están ordenadas por prioridad');
            System.assertEquals(caracteristica1.Id, caracteristicasContacto3[1].CC_Caracteristica__c, 'Las características retornadas no están ordenadas por prioridad');
            System.assertEquals(4, avisosContactoChat.size(), 'El número retornado de avisos del contacto del chat no coincide');
            System.assertEquals(4, caracteristicasAvisoContacto.size(), 'El número retornado de avisos del contacto no coincide');
            System.assertEquals(caracteristica2.Id, caracteristicasAvisoContacto[0].CC_Caracteristica__c, 'Los avisos retornados no están ordenados por prioridad');
            System.assertEquals(caracteristica1.Id, caracteristicasAvisoContacto[1].CC_Caracteristica__c, 'Los avisos retornados no están ordenados por prioridad');
            System.assertEquals(1, caracteristicasCuentaCentro.size(), 'El número retornado de características del centro del caso no coincide');
            System.assertEquals(1, caracteristicasCuentaCliente.size(), 'El número retornado de características de la cuenta del caso no coincide');
        }
    }
}