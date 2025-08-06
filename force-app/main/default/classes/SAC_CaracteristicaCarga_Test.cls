/*****************************************************************
 * Name: SAC_CaracteristicaCarga_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Testear la clase SAC_CaracteristicaCarga.
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US274749         Raúl Santos        26/09/23     Creación Clase
*****************************************************************/

@isTest
public with sharing class SAC_CaracteristicaCarga_Test {
    @TestSetup
    static void makeData(){

        Id clienteCuentaCaracteristicaRecordTypeId = Schema.SObjectType.CC_Caracteristica__c.getRecordTypeInfosByDeveloperName().get('SAC_CaracteristicaClienteCuenta').getRecordTypeId();
        Id clienteCuentaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();

        User usuarioAdmin;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            //Usuario SAC General
            usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];     
            SAC_DatabaseDML.insertDML(usuarioAdmin, false);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_Administrador'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuarioAdmin.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            SAC_DatabaseDML.insertDML(permiSetAssi, false);
        }

        //Account
        Account cuenta = SAC_TestDataFactory.crearCuentas(1)[0];
        SAC_DatabaseDML.insertDML(cuenta, false);

        //Contact
		Contact contacto = SAC_TestDataFactory.crearContacto(1, cuenta.Id)[0];
        SAC_DatabaseDML.insertDML(contacto, false);

        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('AccountId', cuenta.Id);
        camposRecl.put('ContactId', contacto.Id);
        camposRecl.put('OwnerId', usuarioAdmin.id);
        
        Case reclamacion1 = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl);
        SAC_DatabaseDML.insertDML(reclamacion1, false);

        //Reclamantes
        SAC_CaseReclamante__c reclamantePrincipal = SAC_TestDataFactory.crearReclamante(true, reclamacion1, cuenta.Id);
        reclamantePrincipal.SAC_Contact__c = contacto.Id;
    
        SAC_CaseReclamante__c reclamanteSecundario1 = SAC_TestDataFactory.crearReclamante(false, reclamacion1, cuenta.Id);
        reclamanteSecundario1.SAC_Contact__c = contacto.Id;

        SAC_CaseReclamante__c reclamanteSecundario2 = SAC_TestDataFactory.crearReclamante(false, reclamacion1, cuenta.Id);
        reclamanteSecundario2.SAC_Contact__c = contacto.Id;
        
        List<SAC_CaseReclamante__c> listaReclamantes = new List<SAC_CaseReclamante__c>();
        listaReclamantes.add(reclamantePrincipal);
        listaReclamantes.add(reclamanteSecundario1);
        listaReclamantes.add(reclamanteSecundario2);
        SAC_DatabaseDML.insertListDML(listaReclamantes, false);

        ContentVersion contentVersionInsert = SAC_TestDataFactory.crearContentVersion(reclamacion1);
        SAC_DatabaseDML.insertDML(contentVersionInsert, false);

        ContentVersion contentVersion2 = new ContentVersion(
            Title = 'TestSAC2',
            PathOnClient = 'Test.txt',
            VersionData = Blob.valueOf( '00000000T\n'+
                                        '00000001R\n'+
                                       	'44445555X\n'+
                                        'nulo'),
            IsMajorVersion = true
        );
        SAC_DatabaseDML.insertDML(contentVersion2, false);

        CC_Caracteristica__c caracteristica = new CC_Caracteristica__c(
            Name = 'Caracteristica tipo Cliente_Cuenta Test SAC',
            RecordTypeId = clienteCuentaCaracteristicaRecordTypeId,
            CC_Descripcion__c = 'PruebaSAC'
        );
        SAC_DatabaseDML.insertDML(caracteristica, false);

        CC_Caracteristica__c caracteristica2 = new CC_Caracteristica__c(
            Name = 'Caracteristica tipo representante Test SAC',
            RecordTypeId = Schema.SObjectType.CC_Caracteristica__c.getRecordTypeInfosByDeveloperName().get('SAC_CaracteristicaRepresentante').getRecordTypeId(),
            CC_Descripcion__c = 'PruebaSAC'
        );
        SAC_DatabaseDML.insertDML(caracteristica2, true);
    }

    @isTest
    static void deleteFileTest() {
        ContentDocument contentDocument = [SELECT Id FROM ContentDocument WHERE Title = 'ABC Test' LIMIT 1];
        User usuarioAdmin = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];

        System.runAs(usuarioAdmin) {
            Test.startTest();
            SAC_CaracteristicaCarga.deleteFile(contentDocument.Id);
            Test.stopTest();
        }
        
        System.assertEquals(0, [SELECT Count() FROM ContentDocument WHERE Title = 'ABC Test'], 'No se ha podido eliminar el content document');
    }

    @isTest
    static void loadFileTest() {

        ContentDocument contentDocument = [SELECT Id FROM ContentDocument WHERE Title = 'TestSAC2' LIMIT 1];
        CC_Caracteristica__c caracteristica = [SELECT Id FROM CC_Caracteristica__c WHERE Name = 'Caracteristica tipo Cliente_Cuenta Test SAC' LIMIT 1];
        User usuarioAdmin = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        String logUrl = '';

        System.runAs(usuarioAdmin) {
            Test.startTest();
            logUrl = SAC_CaracteristicaCarga.loadFile(caracteristica.Id, contentDocument.Id);
            Test.stopTest();
        }
        
        System.assertNotEquals(0, logUrl.length(), 'No se ha podido cargar el cliente');
    }

    @isTest
    static void loadFileTest2() {

        ContentDocument contentDocument = [SELECT Id FROM ContentDocument WHERE Title = 'TestSAC2' LIMIT 1];
        CC_Caracteristica__c caracteristica = [SELECT Id FROM CC_Caracteristica__c WHERE Name = 'Caracteristica tipo representante Test SAC' LIMIT 1];
        User usuarioAdmin = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        String logUrl = '';

        System.runAs(usuarioAdmin) {
            Test.startTest();
            logUrl = SAC_CaracteristicaCarga.loadFile(caracteristica.Id, contentDocument.Id);
            Test.stopTest();
        }
        
        Assert.areNotEqual(0, logUrl.length(), 'No se ha podido cargar el cliente');
    }

    @isTest
    static void recuperarCaracteristicaTest() {

        CC_Caracteristica__c caracteristica = [SELECT Id FROM CC_Caracteristica__c WHERE Name = 'Caracteristica tipo Cliente_Cuenta Test SAC' LIMIT 1];
        User usuarioAdmin = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        CC_Caracteristica__c caractBuscada = new CC_Caracteristica__c();

        System.runAs(usuarioAdmin) {
            Test.startTest();
            caractBuscada = SAC_CaracteristicaCarga.recuperarCaracteristica(caracteristica.Id);
            Test.stopTest();
        }
        
        Assert.areNotEqual(null, caractBuscada, 'No se ha podido recuperar la característica');
    }
}