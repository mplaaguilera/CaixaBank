/*****************************************************************
 * Name: SAC_LCMP_RepresentanteValido_Test
 * Copyright © 2021  CaixaBank
 *
 * Proposito: Testear la clase SAC_LCMP_RepresentanteValido
 *
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US277143         Carlos Solis         30/11/21     Creación
 * 1.1            US643756         Jose Carlos Blanco  	03/07/23     Modificación (test modificada usando el SAC_TestDataFactory) 
*****************************************************************/
@isTest
public with sharing class SAC_LCMP_RepresentanteValido_Test {

    @TestSetup
    static void makeData(){

        User usuarioGeneral;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            //Usuario SAC General
            usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];     
            Database.insert(usuarioGeneral);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuarioGeneral.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            Database.insert(permiSetAssi);
        }

        /*PersonEmail, BillingStreet, BillingPostalCode, 
        BillingCity, BillingState, BillingCountry, Phone, PersonMobilePhone*/
        //Accounts
        List<Account> cuentas = SAC_TestDataFactory.crearCuentasNoClientePA(2);
        cuentas[0].PersonEmail = 'test@test.sactest';
        cuentas[0].BillingStreet = 'testStreet';
        cuentas[0].BillingPostalCode = '666';
        cuentas[0].BillingCity = 'testCity';
        cuentas[0].BillingState = 'tetState';
        cuentas[0].BillingCountry = 'testCountry';
        cuentas[0].Phone = '666666666';
        cuentas[0].PersonMobilePhone = '555555555';

        cuentas[1].PersonEmail = 'test@test.sactest';
        cuentas[1].BillingStreet = 'testStreet';
        cuentas[1].BillingPostalCode = '777';
        cuentas[1].BillingCity = 'testCity';
        cuentas[1].BillingState = 'tetState';
        cuentas[1].BillingCountry = 'testCountry';
        cuentas[1].PersonMobilePhone = '777777777';
        
        Database.insert(cuentas);

        //Cases
        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'testRec1');
        camposRecl.put('AccountId', cuentas[0].Id);
        camposRecl.put('CC_Idioma__c', 'es');
        camposRecl.put('OwnerId', usuarioGeneral.id);
        
        Case reclamacion1 = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl);

        //Reclamacion 2
        Map<String, Object> camposRecl2 = new Map<String, Object>();
        camposRecl2.put('Subject', 'testRec2');
        camposRecl2.put('AccountId', cuentas[1].Id);
        camposRecl2.put('CC_Idioma__c', 'es');
        camposRecl2.put('OwnerId', usuarioGeneral.id);
        
        Case reclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl2);

        //Reclamacion 3
        Map<String, Object> camposRecl3 = new Map<String, Object>();
        camposRecl3.put('Subject', 'testRec3');
        //camposRecl3.put('AccountId', cuentas[0].Id);
        camposRecl3.put('CC_Idioma__c', 'es');
        camposRecl3.put('SAC_NombreRepresentante__c', 'nombreTest');
        camposRecl3.put('SAC_UsarDatos__c', true);
        camposRecl3.put('OwnerId', usuarioGeneral.id);
        
        Case reclamacion3 = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl3);

        //Reclamacion 4
        Map<String, Object> camposRecl4 = new Map<String, Object>();
        camposRecl4.put('Subject', 'testRec4');
        //camposRecl4.put('AccountId', cuentas[1].Id);
        camposRecl4.put('CC_Idioma__c', 'es');
        camposRecl4.put('SAC_NombreRepresentante__c', 'nombreTest2');
        camposRecl4.put('SAC_UsarDatos__c', true);
        camposRecl4.put('OwnerId', usuarioGeneral.id);
        
        Case reclamacion4 = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl4);

        //Reclamacion 5
        Map<String, Object> camposRecl5 = new Map<String, Object>();
        camposRecl5.put('Subject', 'testRec5');
        camposRecl5.put('AccountId', cuentas[0].Id);
        camposRecl5.put('CC_Idioma__c', 'es');
        camposRecl5.put('SAC_NombreRepresentante__c', 'nombreTest2');
        camposRecl5.put('SAC_UsarDatos__c', false);
        camposRecl5.put('OwnerId', usuarioGeneral.id);
        
        Case reclamacion5 = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl5);

        List<Case> listaReclamaciones = new List<Case>();
        listaReclamaciones.add(reclamacion1);
        listaReclamaciones.add(reclamacion2);
        listaReclamaciones.add(reclamacion3);
        listaReclamaciones.add(reclamacion4);
        listaReclamaciones.add(reclamacion5);
        Database.insert(listaReclamaciones);

        CC_Caracteristica__c caracteristica2 = new CC_Caracteristica__c(
            Name = 'Caracteristica tipo representante Test SAC',
            RecordTypeId = Schema.SObjectType.CC_Caracteristica__c.getRecordTypeInfosByDeveloperName().get('SAC_CaracteristicaRepresentante').getRecordTypeId(),
            CC_Descripcion__c = 'PruebaSAC'
        );
        SAC_DatabaseDML.insertDML(caracteristica2, true);

        CC_Caracteristica_Detalle__c asignacion = new CC_Caracteristica_Detalle__c();
        asignacion.CC_Caracteristica__c = caracteristica2.Id;
        asignacion.SAC_Identificador__c = 'TEST123456';
        SAC_DatabaseDML.insertDML(asignacion, true);
    }

    @isTest
    static void getCaseTest() {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'testRec1'];
        User usuario = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];

        Case casoResultado = new Case();
        System.runAs(usuario){
            Test.startTest();
            casoResultado = SAC_LCMP_RepresentanteValido.getCase(caso.Id);
            Test.stopTest();
        }
        System.assertEquals(caso.Id, casoResultado.Id, 'No se ha podido recuperar el caso');
    }

    @isTest
    static void camposRepresentanteValidoTest() {
        List<Case> listaCasosSelect = [SELECT Id, Subject FROM Case WHERE Subject = 'testRec1' OR Subject = 'testRec2' OR Subject = 'testRec3' OR Subject = 'testRec5'];
        User usuario = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];

        Case caso1 = new Case();
        Case caso2 = new Case();
        Case caso3 = new Case();
        Case caso5 = new Case();

        for (Case caso : listaCasosSelect) {
            if (caso.Subject == 'testRec1') {
                caso1.Id = caso.Id;
            }
            if (caso.Subject == 'testRec2') {
                caso2.Id = caso.Id;
            }
            if (caso.Subject == 'testRec3') {
                caso3.Id = caso.Id;
            }
            if (caso.Subject == 'testRec5') {
                caso5.Id = caso.Id;
            }
        }

        System.runAs(usuario){
            caso1.SAC_NombreRepresentante__c = 'nombreTest';
            caso1.SAC_EmailRepresentante__c = 'test@test.test';
            caso1.SAC_DireccionRepresentante__c = 'direccionTest';
            caso1.SAC_CodigoPostalRepresentante__c = 'codigoPostalTest';
            caso1.SAC_PoblacionRepresentante__c = 'poblacionTest';
            caso1.SAC_ProvinciaRepresentante__c = 'provinciaTest';
            caso1.SAC_PaisRepresentante__c = 'paisTest';

            caso2.SAC_UsarDatos__c = true;

            caso3.SAC_NumeroDelDocumento__c = '666';


            caso5.SAC_NombreRepresentante__c = 'nombreTest';
            caso5.SAC_EmailRepresentante__c = 'test@test.test';
            caso5.SAC_DireccionRepresentante__c = 'direccionTest';
            caso5.SAC_CodigoPostalRepresentante__c = 'codigoPostalTest';
            caso5.SAC_PoblacionRepresentante__c = 'poblacionTest';
            caso5.SAC_ProvinciaRepresentante__c = 'provinciaTest';
            caso5.SAC_PaisRepresentante__c = 'paisTest';

            Test.startTest();
            List<Case> listaCasos = new List<Case>();
            listaCasos.add(caso1);
            listaCasos.add(caso2); //El caso 2 pasa por el if de cuando solo está activo el check SAC_UsarDatos__c
            listaCasos.add(caso3);
            listaCasos.add(caso5);
            Database.update(listaCasos);
            Test.stopTest();
        }

        Case casoResult = [SELECT Id, OS_Email__c, SAC_DireccionPostalNotificacion__c, SAC_DireccionRepresentante__c FROM Case WHERE Subject = 'testRec1'];

        //system.assertEquals(caso1.SAC_EmailRepresentante__c, casoResult.OS_Email__c, 'No se ha podido arrastrar el SAC_EmailRepresentante__c a OS_Email__c');
        System.assertEquals(caso1.SAC_DireccionRepresentante__c, casoResult.SAC_DireccionRepresentante__c, 'No se ha podido arrastrar el SAC_DireccionPostal__c a SAC_DireccionPostalNotificacion__c');
    }

    @isTest
    static void usarDatosDeAlfTest() {
        User usuario = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];
        List<Case> listaCasosSelect = [SELECT Id, Subject, AccountId, OS_Email__c, CC_Telefono_Contacto__c, SAC_DireccionPostalNotificacion__c FROM Case WHERE Subject = 'testRec3' OR Subject = 'testRec4'];
        Case caso3 = new Case();
        Case caso4 = new Case();
        List<Account> listaAccountsSelect = [SELECT Id, FirstName FROM Account WHERE FirstName = 'Target 0' OR FirstName = 'Target 1'];
        Account acc = new Account();
        Account acc2 = new Account();

        for (Case caso : listaCasosSelect) {
            if (caso.Subject == 'testRec3') {
                caso3.Id = caso.Id;
            }
            if (caso.Subject == 'testRec4') {
                caso4.Id = caso.Id;
            }
        }

        for (Account acco : listaAccountsSelect) {
            if (acco.FirstName == 'Target 0') {
                acc.Id = acco.Id;
            }
            if (acco.FirstName == 'Target 1') {
                acc2.Id = acco.Id;
            }
        }

        System.runAs(usuario){
            caso3.AccountId = acc2.Id;
            caso4.AccountId = acc.Id;

            Test.startTest();
            List<Case> listaCasos = new List<Case>();
            listaCasos.add(caso3);
            listaCasos.add(caso4);
            Database.update(listaCasos);
            Test.stopTest();
        }
        Case caso3Result = [SELECT Id, OS_Email__c, CC_Telefono_Contacto__c, SAC_DireccionPostalNotificacion__c FROM Case WHERE Subject = 'testRec3'];

        System.assertNotEquals(caso3.OS_Email__c, caso3Result.OS_Email__c, 'No se ha podido arrastrar el email del account a OS_Email__c');
        System.assertNotEquals(caso3.CC_Telefono_Contacto__c, caso3Result.CC_Telefono_Contacto__c, 'No se ha podido arrastrar el telefono del account a CC_Telefono_Contacto__c');
        System.assertNotEquals(caso3.SAC_DireccionPostalNotificacion__c, caso3Result.SAC_DireccionPostalNotificacion__c, 'No se ha podido arrastrar la dirección postal del account a SAC_DireccionPostalNotificacion__c');
    }

    @isTest
    static void comprobarCaractRepresentanteTest() {
        User usuario = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];

        List<CC_Caracteristica_Detalle__c> listCaratetisticas = new List<CC_Caracteristica_Detalle__c>();

        System.runAs(usuario){
            Test.startTest();
            listCaratetisticas = SAC_LCMP_RepresentanteValido.comprobarCaractRepresentante('TEST123456', '');
            Test.stopTest();
        }

        Assert.areNotEqual(null, listCaratetisticas[0].Id, 'No se ha podido recuperar las caracteristicas del representante');
    }
}