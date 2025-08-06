@isTest
public with sharing class CC_Caracteristica_Detalle_AD_TRHan_Test {

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
            Account cuentaCliente = new Account();
            cuentaCliente.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            cuentaCliente.Name = 'Cliente 1';
            insert new List<Account>{cuenta, cuentaCentro, cuentaCliente};

            Contact cliente = new Contact();
            cliente.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            cliente.AccountId = cuenta.Id;
            cliente.FirstName = 'Contacto';
            cliente.LastName = '01';
            cliente.CC_NumPerso__c = '12345569';
            cliente.CC_Idioma__c = 'Es';
            Contact empleado = new Contact();
            empleado.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
            empleado.AccountId = cuentaCentro.Id;
            empleado.FirstName = 'Contacto';
            empleado.LastName = '03';
            empleado.CC_NumPerso__c = '12345570';
            empleado.CC_Idioma__c = 'Es';
            insert new List<Contact>{cliente, empleado};



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
            // Borramos las 4 caracteristicas Detalla
            delete new List<CC_Caracteristica_Detalle__c>{
                caracteristicaDetalle1,
                caracteristicaDetalle2,
                caracteristicaDetalleCuentaCentro,
                caracteristicaDetalleCuentaCliente
            };
            
            Map<Id,Contact> mapContactos = new Map<Id,Contact>([SELECT Id, CC_Tiene_Caracteristica_Detalle__c FROM Contact WHERE Id IN :new List<Id>{cliente.Id, empleado.Id}]);
            Map<Id,Account> mapCuentas = new Map<Id,Account>([SELECT Id, CC_Tiene_Caracteristica_Detalle__c FROM Account WHERE Id IN :new List<Id>{cuentaCentro.Id, cuentaCliente.Id}]);
            System.assertEquals(false, mapContactos.get(cliente.Id).CC_Tiene_Caracteristica_Detalle__c, 'El contacto cliente 1 no tiene la característica detalle');
            System.assertEquals(false, mapContactos.get(empleado.Id).CC_Tiene_Caracteristica_Detalle__c, 'El contacto empleado 1 no tiene la característica detalle'); 
            System.assertEquals(false, mapCuentas.get(cuentaCentro.Id).CC_Tiene_Caracteristica_Detalle__c, 'La cuenta centro 1 no tiene la característica detalle');
            System.assertEquals(false, mapCuentas.get(cuentaCliente.Id).CC_Tiene_Caracteristica_Detalle__c, 'La cuenta cliente 1 no tiene la característica detalle');
            Test.stopTest();
            
        }
    }

}