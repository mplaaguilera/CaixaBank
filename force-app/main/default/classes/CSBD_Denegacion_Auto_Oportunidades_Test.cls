@isTest
public with sharing class CSBD_Denegacion_Auto_Oportunidades_Test {

    @TestSetup
    private static void testSetup() {
        User usuarioGestor = CSBD_Usuarios.usuarioGestor();

        //Alta de las parametrizaciones que necesita el trigger BI de oportunidades
        CC_Lista_Valores__c listaValores = new CC_Lista_Valores__c();
        listaValores.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        listaValores.Name = 'CSBD: Días cierre oportunidad por defecto';
        listaValores.CC_Activa__c = true;
        insert listaValores;

        CC_Lista_Valores__c valorPrestamo = new CC_Lista_Valores__c();
        valorPrestamo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        valorPrestamo.CC_Lista__c = listaValores.Id;
        valorPrestamo.Name = 'Préstamo';
        valorPrestamo.CC_Valor__c = '1';
        insert valorPrestamo;

        Pricebook2 listaPreciosCsbd = new Pricebook2();
        listaPreciosCsbd.Name = 'CSBD Price Book';
        listaPreciosCsbd.Description = 'CSBD Price Book';
        listaPreciosCsbd.IsActive = true;
        insert listaPreciosCsbd;

        Product2 productoPrestamo = new Product2();
        productoPrestamo.Name = 'Préstamo';
        productoPrestamo.Family = 'Préstamos';
        productoPrestamo.IsActive = true;
        insert productoPrestamo;

        PricebookEntry precioProducto = new PricebookEntry();
        precioProducto.Pricebook2Id = Test.getStandardPricebookId();
        precioProducto.Product2Id = productoPrestamo.Id;
        precioProducto.UnitPrice = 0;
        precioProducto.IsActive = true;
        insert precioProducto;

        PricebookEntry precioProductoCsbd = new PricebookEntry();
        precioProductoCsbd.Pricebook2Id = listaPreciosCsbd.Id;
        precioProductoCsbd.Product2Id = productoPrestamo.Id;
        precioProductoCsbd.UnitPrice = 0;
        precioProductoCsbd.IsActive = true;
        insert precioProductoCsbd;

        CC_Lista_Valores__c listaProductosIniciales = new CC_Lista_Valores__c();
        listaProductosIniciales.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        listaProductosIniciales.Name = 'CSBD: Productos iniciales oportunidad';
        listaProductosIniciales.CC_Activa__c = true;
        insert listaProductosIniciales;

        CC_Lista_Valores__c valorProductosIniciales = new CC_Lista_Valores__c();
        valorProductosIniciales.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        valorProductosIniciales.CC_Lista__c = listaProductosIniciales.Id;
        valorProductosIniciales.Name = 'Préstamo';
        valorProductosIniciales.CC_Valor__c = 'Préstamo';
        valorProductosIniciales.CC_Orden__c = 1;
        valorProductosIniciales.CC_Activa__c = true;
        insert valorProductosIniciales;

        EmailTemplate plantillaCastellano = new EmailTemplate();
        plantillaCastellano.isActive = true;
        plantillaCastellano.Name = 'plantilla es';
        plantillaCastellano.DeveloperName = 'CSBD_Test_' + System.now().getTime();
        plantillaCastellano.TemplateType = 'text';
        plantillaCastellano.FolderId = usuarioGestor.Id;
        System.runAs( usuarioGestor ) {
            insert plantillaCastellano;
        }

        CSBD_Denegacion_Auto_Solicitud__c regla1 = new CSBD_Denegacion_Auto_Solicitud__c();
        regla1.CSBD_Record_Type_Oportunidad__c = 'CSBD_Prestamo';
        regla1.CSBD_Orden__c = 1;
        regla1.CSBD_Empresa_Proveedora__c = 'CaixaBank';
        regla1.CSBD_Circuito_Contratacion_Online__c = true;
        regla1.CSBD_Importe_Desde__c = 1000;
        regla1.CSBD_Importe_Hasta__c = 2000;
        regla1.CSBD_Escala_Maestra_Desde__c = 2;
        regla1.CSBD_Escala_Maestra_Hasta__c = 4;
        regla1.CSBD_Excluir_Clientes_Limite__c = false;
        regla1.CSBD_Denegada__c = true;
        regla1.CSBD_Resolucion__c = 'res1';
        regla1.CSBD_Enviar_Correo_Auto__c = true;
        regla1.CSBD_Plantilla_Correo_Castellano__c = 'plantilla es';
        regla1.CSBD_Plantilla_Correo_Catalan__c = 'plantilla ca';
        regla1.CSBD_Scoring_Riesgo__c = 'Denegado SIR';

        CSBD_Denegacion_Auto_Solicitud__c regla2 = new CSBD_Denegacion_Auto_Solicitud__c();
        regla2.CSBD_Record_Type_Oportunidad__c = 'CSBD_Prestamo';
        regla2.CSBD_Orden__c = 2;
        regla2.CSBD_Empresa_Proveedora__c = 'CaixaBank';
        regla2.CSBD_Circuito_Contratacion_Online__c = true;
        regla2.CSBD_Importe_Desde__c = 1000;
        regla2.CSBD_Importe_Hasta__c = 2000;
        regla2.CSBD_Escala_Maestra_Desde__c = 2;
        regla2.CSBD_Escala_Maestra_Hasta__c = 4;
        regla2.CSBD_Excluir_Clientes_Limite__c = false;
        regla2.CSBD_Denegada__c = true;
        regla2.CSBD_Resolucion__c = 'res1';
        regla2.CSBD_Enviar_Correo_Auto__c = true;
        regla2.CSBD_Plantilla_Correo_Castellano__c = 'plantilla es';
        regla2.CSBD_Plantilla_Correo_Catalan__c = 'plantilla ca';
        regla2.CSBD_Scoring_Riesgo__c = 'Denegado SIR';

        insert new List<CSBD_Denegacion_Auto_Solicitud__c>{regla1, regla2};

        Account cuenta = new Account();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        cuenta.Name = 'test@test.com';
        cuenta.CC_Numero_Documento__c = '123123123K';
        insert cuenta;
        
        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.AccountId = cuenta.Id;
        contacto.Email = 'test2@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        contacto.CSBD_Escala_Maestra__c = 3;
        insert contacto;

        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuenta.Id;
        acshare.UserOrGroupId = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1].Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        insert acshare;
    }

    @isTest
    public static void test() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '123123123K'];
        Contact contacto = [SELECT Id, Name, CC_Numero_Documento__c FROM Contact WHERE AccountId = :cuenta.Id];

        Map<String, Object> camposOportunidad1 = new Map<String, Object>();
        camposOportunidad1.put('CSBD_Empresa_Proveedora__c', 'CaixaBank');
        camposOportunidad1.put('CSBD_Importe_Producto_Principal__c', 1500);
        camposOportunidad1.put('CSBD_Circuito_Contratacion_Online__c', true);
        camposOportunidad1.put('Amount', 1000);
        camposOportunidad1.put('AccountId', cuenta.Id);
        camposOportunidad1.put('CSBD_Contact__c', contacto.Id);
        camposOportunidad1.put('CSBD_Email_Solicitud__c', 'test@test.com');
        camposOportunidad1.put('CSBD_Scoring_Riesgo__c', 'Denegado SIR');
        Opportunity oportunidad1 = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', camposOportunidad1);

        Map<String, Object> camposOportunidad2 = new Map<String, Object>();
        camposOportunidad2.put('CSBD_Empresa_Proveedora__c', 'CaixaBank');
        camposOportunidad2.put('CSBD_Circuito_Contratacion_Online__c', true);
        camposOportunidad2.put('Amount', 3000);
        camposOportunidad2.put('AccountId', cuenta.Id);
        camposOportunidad2.put('CSBD_Contact__c', contacto.Id);
        camposOportunidad2.put('CSBD_Email_Solicitud__c', 'test2@test.com');
        camposOportunidad2.put('CSBD_Scoring_Riesgo__c', 'Denegado SIR');
        Opportunity oportunidad2 = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', camposOportunidad2);

        System.runAs ( CSBD_Usuarios.usuarioAdministrador() ) {
            Test.startTest();
            CSBD_Denegacion_Automatica_Oportunidades.denegacionAutomaticaOportunidades(new List<Id>{oportunidad1.Id, oportunidad2.Id});
            Test.stopTest();

            Map<Id, Opportunity> oportunidades = new Map<Id, Opportunity>(
                [SELECT CSBD_Estado__c, StageName, CSBD_Resolucion__c
                    FROM Opportunity WHERE Id = :oportunidad1.Id OR Id = :oportunidad2.Id]
            );

            oportunidad1 = oportunidades.get(oportunidad1.Id);
            oportunidad2 = oportunidades.get(oportunidad2.Id);

            System.assertEquals('Cerrada', oportunidad1.CSBD_Estado__c, 'No se ha denegado la oportunidad');
            System.assertEquals('Perdida', oportunidad1.StageName, 'No se ha denegado la oportunidad');
            System.assertEquals('res1', oportunidad1.CSBD_Resolucion__c, 'La denegación automática no ha informado la resolución correcta');
            System.assertEquals(1, [SELECT Count() FROM Task WHERE WhatId = :oportunidad1.Id AND Type = 'Denegación automática'], 'La denegación automática no ha creado tarea');
            
            System.assertEquals('Nueva', oportunidad2.CSBD_Estado__c, 'Se ha denegado una solicitud que no cumple las reglas');
            System.assertEquals('Solicitud', oportunidad2.StageName, 'Se ha denegado una solicitud que no cumple las reglas');
            System.assertEquals(null, oportunidad2.CSBD_Resolucion__c, 'Se ha denegado una solicitud que no cumple las reglas');
            System.assertEquals(0, [SELECT Count() FROM Task WHERE WhatId = :oportunidad2.Id AND Type = 'Denegación automática'], 'Se ha denegado una solicitud que no cumple las reglas');
        }
    }
}