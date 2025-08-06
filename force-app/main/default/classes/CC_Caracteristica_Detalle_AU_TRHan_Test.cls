@isTest
public with sharing class CC_Caracteristica_Detalle_AU_TRHan_Test {

    @istest
    static void test() {
        // Crear Caracteristica principal
        User admin = [SELECT Id FROM User WHERE LastName = 'Administrador de sistema' LIMIT 1];
        System.runAs(admin) {
            // Crear una característica en desuso
            CC_Caracteristica__c caracteristica = new CC_Caracteristica__c(
                RecordTypeId = Schema.SObjectType.CC_Caracteristica__c.getRecordTypeInfosByDeveloperName().get('Marca').getRecordTypeId(),
                Name = 'Test Característica',
                CC_Descripcion__c = 'Test Característica',
                CC_Fecha_vigencia_inicio__c= CBK_UtilsDate.todaySYS().addDays(-185),
                CC_Fecha_vigencia_fin__c= CBK_UtilsDate.todaySYS().addDays(2)
            );
            insert caracteristica;

            Account cuenta = new Account();
            cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            cuenta.Name = 'Cuenta01';
            Account cuentaCentro = new Account();
            cuentaCentro.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
            cuentaCentro.Name = 'Centro Caixabank 1';
			Account cuentaCentro2 = new Account();
            cuentaCentro2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
            cuentaCentro2.Name = 'Centro Caixabank 2';
            Account cuentaCliente = new Account();
            cuentaCliente.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            cuentaCliente.Name = 'Cliente 1';
            Account cuentaCliente2 = new Account();
            cuentaCliente2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            cuentaCliente2.Name = 'Cliente 2';
            insert new List<Account>{cuenta, cuentaCentro, cuentaCentro2, cuentaCliente, cuentaCliente2};

            Contact cliente = new Contact();
            cliente.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            cliente.AccountId = cuenta.Id;
            cliente.FirstName = 'Contacto';
            cliente.LastName = '01';
            cliente.CC_NumPerso__c = '12345569';
            cliente.CC_Idioma__c = 'Es';
			Contact cliente2 = new Contact();
            cliente2.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            cliente2.AccountId = cuenta.Id;
            cliente2.FirstName = 'Contacto';
            cliente2.LastName = '02';
            cliente2.CC_NumPerso__c = '12345568';
            cliente2.CC_Idioma__c = 'Es';
            Contact empleado = new Contact();
            empleado.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
            empleado.AccountId = cuentaCentro.Id;
            empleado.FirstName = 'Contacto';
            empleado.LastName = '03';
            empleado.CC_NumPerso__c = '12345570';
            empleado.CC_Idioma__c = 'Es';
			Contact empleado2 = new Contact();
            empleado2.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
            empleado2.AccountId = cuentaCentro.Id;
            empleado2.FirstName = 'Contacto';
            empleado2.LastName = '04';
            empleado2.CC_NumPerso__c = '12345571';
            empleado2.CC_Idioma__c = 'Es';
            insert new List<Contact>{cliente, cliente2, empleado, empleado2};



            CC_Caracteristica_Detalle__c caracteristicaDetalle1 = new CC_Caracteristica_Detalle__c();
            caracteristicaDetalle1.CC_Caracteristica__c = caracteristica.Id;
            caracteristicaDetalle1.CC_Cliente__c = cliente.Id;
            CC_Caracteristica_Detalle__c caracteristicaDetalle2 = new CC_Caracteristica_Detalle__c();
            caracteristicaDetalle2.CC_Caracteristica__c = caracteristica.Id;
            caracteristicaDetalle2.CC_Empleado__c = empleado.Id;
            CC_Caracteristica_Detalle__c caracteristicaDetalleCuentaCentro = new CC_Caracteristica_Detalle__c();
            caracteristicaDetalleCuentaCentro.CC_Caracteristica__c = caracteristica.Id;
            caracteristicaDetalleCuentaCentro.CC_Centro_CaixaBank__c = cuentaCentro.Id;
            CC_Caracteristica_Detalle__c caracteristicaDetalleCuentaCliente = new CC_Caracteristica_Detalle__c();
            caracteristicaDetalleCuentaCliente.CC_Caracteristica__c = caracteristica.Id;
            caracteristicaDetalleCuentaCliente.CC_Cuenta__c = cuentaCliente.Id;
            // Crear 4 Caracteristicas Detalle
            insert new List<CC_Caracteristica_Detalle__c>{
                caracteristicaDetalle1,
                caracteristicaDetalle2,
                caracteristicaDetalleCuentaCentro,
                caracteristicaDetalleCuentaCliente
            };
            Test.startTest();
            caracteristicaDetalle1.CC_Cliente__c = cliente2.Id;
            caracteristicaDetalle2.CC_Empleado__c = empleado2.Id;
            caracteristicaDetalleCuentaCentro.CC_Centro_CaixaBank__c = cuentaCentro2.Id;
            caracteristicaDetalleCuentaCliente.CC_Cuenta__c = cuentaCliente2.Id;
            update new List<CC_Caracteristica_Detalle__c>{
                caracteristicaDetalle1,
                caracteristicaDetalle2,
                caracteristicaDetalleCuentaCentro,
                caracteristicaDetalleCuentaCliente
            };
            Map<Id,Contact> mapContactos = new Map<Id,Contact>([SELECT Id, CC_Tiene_Caracteristica_Detalle__c FROM Contact WHERE Id IN :new List<Id>{cliente.Id, empleado.Id, cliente2.Id, empleado2.Id}]);
            Map<Id,Account> mapCuentas = new Map<Id,Account>([SELECT Id, CC_Tiene_Caracteristica_Detalle__c FROM Account WHERE Id IN :new List<Id>{cuentaCentro.Id, cuentaCentro2.Id, cuentaCliente.Id, cuentaCliente2.Id}]);
            System.assertEquals(false, mapContactos.get(cliente.Id).CC_Tiene_Caracteristica_Detalle__c, 'El contacto cliente 1 no tiene la característica detalle');
            System.assertEquals(true, mapContactos.get(cliente2.Id).CC_Tiene_Caracteristica_Detalle__c, 'El contacto cliente 2 tiene la característica detalle');
            System.assertEquals(false, mapContactos.get(empleado.Id).CC_Tiene_Caracteristica_Detalle__c, 'El contacto empleado 1 no tiene la característica detalle');  
            System.assertEquals(true, mapContactos.get(empleado2.Id).CC_Tiene_Caracteristica_Detalle__c, 'El contacto empleado 2 tiene la característica detalle');
            System.assertEquals(false, mapCuentas.get(cuentaCentro.Id).CC_Tiene_Caracteristica_Detalle__c, 'La cuenta centro 1 no tiene la característica detalle');
            System.assertEquals(true, mapCuentas.get(cuentaCentro2.Id).CC_Tiene_Caracteristica_Detalle__c, 'La cuenta centro 2 tiene la característica detalle');
            System.assertEquals(false, mapCuentas.get(cuentaCliente.Id).CC_Tiene_Caracteristica_Detalle__c, 'La cuenta cliente 1 no tiene la característica detalle');
            System.assertEquals(true, mapCuentas.get(cuentaCliente2.Id).CC_Tiene_Caracteristica_Detalle__c, 'La cuenta cliente 2 tiene la característica detalle');
            Test.stopTest(); 
            
        }
    }

}