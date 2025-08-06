@isTest
public with sharing class CSBD_ProductoOportunidadHija_Test {

    @TestSetup
    static void data() {
        CC_Lista_Valores__c listaValoresPrueba = new CC_Lista_Valores__c();
        listaValoresPrueba.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        listaValoresPrueba.Name = 'CSBD: Acciones comerciales oportunidad';
        listaValoresPrueba.CC_Activa__c = true;
        insert listaValoresPrueba;

		Id idRecordTypeValor = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        CC_Lista_Valores__c listaValoresPrueba1 = new CC_Lista_Valores__c();
		listaValoresPrueba1.RecordTypeId = idRecordTypeValor;
        listaValoresPrueba1.Name = 'Valores test';
        listaValoresPrueba1.CC_Valor2__c = 'Fondos';
        listaValoresPrueba1.CC_Valor__c = 'Seguros';
        listaValoresPrueba1.CC_Lista__c = listaValoresPrueba.Id;
        listaValoresPrueba1.CC_Valor_SFDC__c = 'Hipoteca';
        listaValoresPrueba1.CC_Activa__c = true;
        CC_Lista_Valores__c listaValoresPrueba2 = new CC_Lista_Valores__c();
        listaValoresPrueba2.RecordTypeId = idRecordTypeValor;
        listaValoresPrueba2.Name = 'Valores test 2';
        listaValoresPrueba2.CC_Valor2__c = 'MyBox Auto';
        listaValoresPrueba2.CC_Valor__c = 'Hipotecas';
        listaValoresPrueba2.CC_Lista__c = listaValoresPrueba.Id;
        listaValoresPrueba2.CC_Valor_SFDC__c = 'Hipoteca';
        listaValoresPrueba2.CC_Activa__c = true;
        insert new List<CC_Lista_Valores__c>{listaValoresPrueba1, listaValoresPrueba2};
    }

    @isTest
    private static void crearOportunidadesHijasTest() {
        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
			Opportunity oportunidadTest = new Opportunity();
			oportunidadTest.Name = 'test';
			oportunidadTest.stageName = 'Solicitud';
			Opportunity oportunidadTest1 = new Opportunity();
			oportunidadTest1.Name = 'test';
			oportunidadTest1.stageName = 'Rechazada';
			Opportunity oportunidadTest2 = new Opportunity();
			oportunidadTest2.Name = 'test';
			oportunidadTest2.stageName = 'Formalizada';
			insert new List<Opportunity>{oportunidadTest, oportunidadTest1, oportunidadTest2};

            Test.startTest();
			List<String> productos = new List<String>{'MyBox Auto','Fondos'};
            CSBD_ProductoOportunidadHija.crearOportunidadesHijas(productos, oportunidadTest.StageName, oportunidadTest.Id,'Hipoteca', '');
            CSBD_ProductoOportunidadHija.crearOportunidadesHijas(productos, oportunidadTest1.StageName, oportunidadTest1.Id,'Hipoteca', 'Duplicada');
            CSBD_ProductoOportunidadHija.crearOportunidadesHijas(productos, oportunidadTest2.StageName, oportunidadTest2.Id,'Hipoteca', 'Duplicada');
            List<Opportunity> oportunidadesHijas = [SELECT OwnerId, CSBD_Estado__c FROM Opportunity WHERE CSBD_Parent_Id__c = :oportunidadTest.Id];
            Opportunity oportunidad1 = [SELECT OwnerId, CSBD_Estado__c FROM Opportunity WHERE CSBD_Parent_Id__c = :oportunidadTest1.Id LIMIT 1];
            List<Task> tareaCierre = [SELECT Id FROM Task WHERE WhatId = :oportunidad1.Id AND Subject = :oportunidad1.CSBD_Estado__c];
            Test.stopTest();

            System.assert(!oportunidadesHijas.isEmpty(), 'No se han creado oportunidades hijas');
            System.assert(!tareaCierre.isEmpty(), 'No se ha creado tarea de cierre');
        }
    }

    @isTest
    private static void cerrarOportunidadesHijasTest() {
        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
			Opportunity padre = CSBD_Opportunity.crearOportunidad('CSBD_Accion_Comercial');
			CSBD_ProductoOportunidadHija.crearOportunidadesHijas(new List<String>{'MyBox Auto', 'Fondos'}, padre.StageName, padre.Id, 'Hipoteca', '');

			Test.startTest();
			CSBD_Opportunity.cerrarOportunidad(padre.Id, 'Rechazada', 'No aplica');
            CSBD_ProductoOportunidadHija.cerrarOportunidadesHijas(new Map<Id, Opportunity>{padre.Id => padre});
            Test.stopTest();

            List<Opportunity> oportunidadesHijas = [SELECT Id FROM Opportunity WHERE CSBD_Parent_Id__c = :padre.Id AND StageName = 'Rechazada' AND CSBD_Resolucion__c = 'No aplica' ];
            System.assert(!oportunidadesHijas.isEmpty(), 'No se han cerrado oportunidades hijas');
        }
    }

    @isTest
    private static void obtenerProductosTest() {
        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
			Test.startTest();
			List<CC_Lista_Valores__c> listaValores = CSBD_ProductoOportunidadHija.obtenerProductos('Hipoteca');
			Test.stopTest();

            System.assert(!listaValores.isEmpty(), 'No hay productos disponibles');
        }
    }

    @isTest
    private static void obtenerOportunidadesHijasTest() {
        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
			Opportunity opp1 = CSBD_Opportunity.crearOportunidad('CSBD_Accion_Comercial');
			Opportunity opp2 = CSBD_Opportunity.crearOportunidad('CSBD_Accion_Comercial', new Map<String, Object>{'CSBD_Parent_Id__c' => opp1.Id});

            Test.startTest();
            System.assertEquals(1, CSBD_ProductoOportunidadHija.obtenerOportunidadesHijas(opp1.Id).size(), 'El número de oportunidades hijas debe ser 1');
            Test.stopTest();
        }
    }

    @isTest
    private static void obtenerOportunidadesHijasAbiertasTest() {
        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
			Opportunity opp1 = CSBD_Opportunity.crearOportunidad('CSBD_Accion_Comercial');
			Opportunity opp2 = CSBD_Opportunity.crearOportunidad('CSBD_Accion_Comercial', new Map<String, Object>{'CSBD_Parent_Id__c' => opp1.Id});
			Opportunity opp3 = CSBD_Opportunity.crearOportunidad('CSBD_Accion_Comercial', new Map<String, Object>{'CSBD_Parent_Id__c' => opp2.Id});
			CSBD_Opportunity.cerrarOportunidad(opp3.Id, 'Rechazada', 'resolución');

            Test.startTest();
            System.assert(CSBD_ProductoOportunidadHija.obtenerOportunidadesHijasAbiertas(opp1.Id), 'La oportunidad 1 sí tiene oportunidades hijas abiertas');
            System.assert(!CSBD_ProductoOportunidadHija.obtenerOportunidadesHijasAbiertas(opp2.Id), 'La oportunidad 2 no tiene oportunidades hijas abiertas');
            Test.stopTest();
        }
    }

    @isTest
    private static void crearTareaCambioEmpresaProveedoraTest() {
		System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
			Opportunity oportunidadTest = new Opportunity();
			oportunidadTest.Name = 'test';
			oportunidadTest.stageName = 'Solicitud';
			oportunidadTest.CSBD_Empresa_Proveedora__c = 'CaixaBank';
			insert oportunidadTest;

            Test.startTest();
            oportunidadTest.CSBD_Empresa_Proveedora__c = 'imaginBank';
            update oportunidadTest;
            Test.stopTest();

            List<Task> tareas = [SELECT Id FROM Task WHERE WhatId = :oportunidadTest.Id AND Subject = 'Cambio empresa proveedora' LIMIT 1];
            System.assert(!tareas.isEmpty(), 'No se ha creado la tarea de Cambio empresa proveedora');
        }
    }

    @isTest
    private static void actualizarPropietarioOportunidadesHijasFutureTest() {
        User nuevoPropietario = CSBD_TestDataFactory.usuarioGestor();

        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
			Opportunity padre = CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca');
			Opportunity hija = CSBD_Opportunity.crearOportunidad('CSBD_Accion_Comercial', new Map<String, Object>{'CSBD_Parent_Id__c' => padre.Id});

            OpportunityShare oppSharePadre = new OpportunityShare();
            oppSharePadre.UserOrGroupId = nuevoPropietario.Id;
            oppSharePadre.OpportunityId = padre.Id;
            oppSharePadre.OpportunityAccessLevel = 'Edit';
            OpportunityShare oppShareHija = new OpportunityShare();
            oppShareHija.UserOrGroupId = nuevoPropietario.Id;
            oppShareHija.OpportunityId = hija.Id;
            oppShareHija.OpportunityAccessLevel = 'Edit';
            insert new List<OpportunityShare>{oppSharePadre, oppShareHija};

			System.runAs(nuevoPropietario) {
				Test.startTest();
				padre.OwnerId = nuevoPropietario.Id;
				update padre;
				Test.stopTest();

				Id hijaOwnerId = [SELECT OwnerId FROM Opportunity WHERE Id = :hija.Id].OwnerId;
				System.assertEquals(nuevoPropietario.Id, hijaOwnerId, 'No se ha sincronizado el propietario de la oportunidad padre con el de las hijas');
			}
		}
    }

    @isTest
    private static void searchAccounts() {
        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
            Account cuenta1 = new Account();
            cuenta1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            cuenta1.Name = 'JAIME MATEO';
            Account cuenta2 = new Account();
            cuenta2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            cuenta2.Name = 'MATEO CARIDE';
            insert new List<Account>{cuenta1, cuenta2};

            Test.startTest();
            Test.setFixedSearchResults(new List<Id>{cuenta1.Id, cuenta2.Id});
            List<Account> cuentas = CSBD_ProductoOportunidadHija.searchAccounts('MATEO');
            Test.stopTest();

            System.assertEquals(2, cuentas.size(), 'Debería devolver 2 cuentas');
        }
    }

    @isTest
    private static void duplicarOpp() {
        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
            Opportunity opp1 = CSBD_Opportunity.crearOportunidad('CSBD_Accion_Comercial');

            Test.startTest();
            Opportunity opp2 = CSBD_ProductoOportunidadHija.duplicarOpp(opp1.Id, 'CSBD_Accion_Comercial', null);
            Test.stopTest();

            System.assert(opp2 != null, 'No se ha duplicado la oportunidad');
        }
    }
}